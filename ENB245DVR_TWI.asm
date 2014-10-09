; **********************************************
; ** ENB245DVR Library - TWI/EEPROM Module 
; **  
; ** Implements reading and writing an EEPROM
; ** via the TWI interface.
; **
; ** HARDWARE RESOURCES:
; **   Registers 23-25
; **   TWI 
; **
; ** REQUIRES:
; **   Circular Buffer Module
; **
; ** CALLBACKS:
; **   Callback_ReadPageDone
; **     Called when a page read operation has
; **     been completed.
; **   Callback_WritePageDone
; **     Called when a page write operation has
; **     been completed
; **   Callback_ErrorTWI
; **     Called if an error occurs with a TWI 
; **     operation.
; **
; ** Version: v0.1
; ** Date:    19/07/2011
; ** Author:  Mark Broadmeadow
; ** 
; **********************************************

; **
; * EEPROM STATE MACHINE STATES
; *

; SEQUENTIAL READ STATES
.equ TWI_RS_CTRL  		= 0x00
.equ TWI_RS_ADDH			= 0x01
.equ TWI_RS_ADDL			= 0x02
.equ TWI_RS_START			= 0x03
.equ TWI_RS_CTRL2			= 0x04
.equ TWI_RS_DATA0			= 0x05
.equ TWI_RS_DATA			= 0x06
.equ TWI_RS_DATAN			= 0x44
.equ TWI_RS_STOP			= 0x45
.equ TWI_RS_DONE			= 0x46

; PAGE WRITE STATES
.equ TWI_WP_CTRL  		= 0x80
.equ TWI_WP_ADDH			= 0x81
.equ TWI_WP_ADDL			= 0x82
.equ TWI_WP_DATA			= 0x83
.equ TWI_WP_STOP			= 0xC3
.equ TWI_WP_DONE			= 0xC4

; **
; * TWI STATUS CODES
; *
.equ TWI_ST_START			= 0x08
.equ TWI_ST_STARTR		= 0x10
.equ TWI_ST_WCTRLACK	= 0x18
.equ TWI_ST_WDATAACK	= 0x28
.equ TWI_ST_RCTRLACK	=	0x40
.equ TWI_ST_RDATAACK	= 0x50
.equ TWI_ST_RDATANACK	= 0x58

; **
; * EEPROM CONTROL BYTES
; *
.equ EEPROM_WRITE			= 0b10100000
.equ EEPROM_READ			= 0b10100001

; **
; * RESERVED WORKING REGISTERS
; *
.def AddressL = r23
.def AddressH = r24
.def StatusTWI = r25

; **
; * TWI INITIALISATION
; * Initialises TWI module
TWI_Init:
	ldi	r16,		10;
	sts TWBR, 	r16						; 400kHz clock
	call TWI_ResetPagePointers
	ret

; **
; * TWI ResetPagePointers
;	* Resets EEPROM page counters
; *
TWI_ResetPagePointers:
	ldi AddressH, 0x00
	ldi AddressL, 0x00
	ret

; **
; * TWI WritePage
;	* Initiates writing of a page of data from the 
; * circular buffer to the EEPROM.
; *
TWI_WritePage:
	ldi StatusTWI, TWI_WP_CTRL
	call TWI_Start
	ret

; **
; * TWI ReadPage
;	* Initiates Reading of a page of data from the 
; * EEPROM into the circular buffer.
; *
TWI_ReadPage:
	ldi StatusTWI, TWI_RS_CTRL
	call TWI_Start
	ret


; *************** START LOW LEVEL FUNCTIONS ***************

; **
; * TWI Start
;	* Transmits START condition on TWI
; *
TWI_Start:
	ldi r16,(1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)
	sts TWCR, r16
	ret

; **
; * TWI Restart
;	* Transmits repeated START condition on TWI
; *
TWI_Restart:
	ldi r16,(1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	sts TWCR, r16
	ret

; **
; * TWI Tx
;	* Transmits byte stored in r16 on TWI
; *
TWI_Tx:
	sts TWDR, r16
	ldi r16, (1<<TWINT)|(1<<TWEN)|(1<<TWIE)
	sts TWCR, r16
	ret

; **
; * TWI Rx
;	* Receives byte from TWI to r16
; *
TWI_Rx:
	ldi r16, (1<<TWINT)|(1<<TWEN)|(1<<TWIE)|(1<<TWEA)
	sts TWCR, r16
	ret

; **
; * TWI RxNACK
;	* Receives byte from TWI to r16 without ACK
; *
TWI_RxNACK:
	ldi r16, (1<<TWINT)|(1<<TWEN)|(1<<TWIE)
	sts TWCR, r16
	ret

; **
; * TWI Rx
;	* Transmits STOP condition on TWI
; *
TWI_Stop:
	ldi r16, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)|(1<<TWIE)
	sts TWCR, r16
	ret

; **
; * TWI GetStatus
;	* Loads TWI status into r16
; *
TWI_GetStatus:
	lds 	r16,	TWSR
	andi 	r16, 	0xF8
	ret

; *************** END LOW LEVEL FUNCTIONS ***************


; **
; * TWI INTERRUPT SERCVICE ROUTINE
; * Performs the TWI operations required to 
; * read of write from an EEPROM.
; *
ISR_TWI:
	
	; Save status
	push r16
	in r16, SREG
	push r16

	sbrc	StatusTWI, 7
	rjmp 	TWI_WP

	TWI_RS:
		cpi StatusTWI, TWI_RS_CTRL
			breq RS_CtrlByte
		cpi StatusTWI, TWI_RS_ADDH
			breq RS_AddrH
		cpi StatusTWI, TWI_RS_ADDL
			breq RS_AddrL
		cpi StatusTWI, TWI_RS_START
			breq RS_Start
		cpi StatusTWI, TWI_RS_CTRL2
			breq RS_CtrlByte2
		cpi StatusTWI, TWI_RS_DATA0
			breq RS_Data0
		cpi StatusTWI, TWI_RS_DATAN
			breq RS_DataN
		cpi StatusTWI, TWI_RS_DONE
			breq RS_Done
		cpi StatusTWI, TWI_RS_STOP
			brsh RS_Stop
		cpi StatusTWI, TWI_RS_DATA
			brsh RS_Data
		rjmp TWI_Error	

		RS_Done:
			rjmp	TWI_Done

		RS_CtrlByte:
			; Tx CTRL byte
			ldi 	r16, EEPROM_WRITE
			call 	TWI_Tx
			; Next state
			rjmp 	TWI_IncStatus

		RS_AddrH:	
			; Tx AddrH byte 
			mov 	r16, AddressH
			call	TWI_Tx
			; Next state
			rjmp 	TWI_IncStatus

		RS_AddrL:	
			; Tx AddrL byte 
			mov 	r16, AddressL
			call TWI_Tx
			; Next state
			rjmp TWI_IncStatus

		RS_Start:
			; Tx Start condition
			call TWI_Start
			; Next state
			rjmp TWI_IncStatus

		RS_CtrlByte2:
			; Tx CTRL byte
			ldi 	r16, EEPROM_READ
			call 	TWI_Tx
			; Next state
			rjmp TWI_IncStatus
		
		RS_Data0:		
			; Rx data byte
			call 	TWI_Rx
			; Next state
			rjmp 	TWI_IncStatus

		RS_Data:		
			; Store Rx'd byte to SRAM, increment data pointer
			lds		r16, TWDR
			st 		Y+,	r16
			call 	CheckWriteOverflow
			; Rx data byte
			call 	TWI_Rx
			; Next state
			rjmp 	TWI_IncStatus

		RS_DataN:		
			; Store Rx'd byte to SRAM, increment data pointer
			lds		r16, TWDR
			st 		Y+,	r16
			call 	CheckWriteOverflow
			; Tx data byte, increment data pointer
			call 	TWI_RxNACK
			; Next state
			rjmp 	TWI_IncStatus

		RS_Stop:		
			; Store Rx'd byte to SRAM, increment data pointer
			lds		r16, TWDR
			st 		Y+,	r16
			call 	CheckWriteOverflow
			; Stop TWI, increment page address
			call	TWI_Stop
			ldi		r16, 64
			add		AddressL, r16
			ldi		r16, 0
			adc		AddressH, r16
			call	Callback_EEPROMReadPageDone
			; Next state
			rjmp 	TWI_IncStatus

	TWI_WP:
		cpi StatusTWI, TWI_WP_CTRL
			breq WP_CtrlByte
		cpi StatusTWI, TWI_WP_ADDH
			breq WP_AddrH
		cpi StatusTWI, TWI_WP_ADDL
			breq WP_AddrL
		cpi StatusTWI, TWI_WP_DONE
			breq WP_Done
		cpi StatusTWI, TWI_WP_STOP
			brsh WP_Stop
		cpi StatusTWI, TWI_WP_DATA
			brsh WP_Data
		rjmp TWI_Error

		WP_CtrlByte:
			; Tx CTRL byte
			ldi r16, EEPROM_WRITE
			call 	TWI_Tx
			; Next state
			rjmp 	TWI_IncStatus

		WP_AddrH:	
			; Tx AddrH byte 
			mov 	r16, AddressH
			call	TWI_Tx
			; Next state
			rjmp 	TWI_IncStatus

		WP_AddrL:
			; Tx AddrL byte 
			mov 	r16, AddressL
			call 	TWI_Tx
			rjmp TWI_IncStatus

		WP_Data:		
			; Tx data byte, increment data pointer
			ld 		r16, Z+
			call 	TWI_Tx
			call 	CheckReadOverflow
			; Next state
			rjmp 	TWI_IncStatus

		WP_Stop:		
			; Stop TWI, increment page address
			call	TWI_Stop
			ldi		r16, 64
			add		AddressL, r16
			ldi		r16, 0
			adc		AddressH, r16
			call	Callback_EEPROMWritePageDone
			; Next state
			rjmp 	TWI_IncStatus

		WP_Done:
			rjmp	TWI_Done

	TWI_IncStatus:
		inc StatusTWI
		rjmp TWI_Done

	TWI_Error:
		call Callback_ErrorTWI		

	TWI_Done:	
	
	; Restore status
	pop r16
	out SREG, r16
	pop r16

	reti
