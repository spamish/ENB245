; ************************************************************
; ** Skeleton DVR Program
; **  
; ** Skeleton code for a digital voice recorder (DVR).
; ** 
; ** Privides example initilisation of ATmega32U4.
; ** Provides example initilisation of ENB245DVR Library.
; ** Provides example structure required to implement a DVR.
; ** Provides example code for initiation of record sequence.
; ** Provides example callback usage for record function.
; ** Provides example usage for unused callbacks.
; **
; ** Version: v0.1
; ** Date:    19/07/2011
; ** Author:  Mark Broadmeadow
; ** 
; ************************************************************
; Group 412.
; Alex Fernicola (n8609373)
; Rebecca Hopping (n8314217)
; Samuel Janetzki (n7402643)

.include "m32u4def.inc"

; **
; * CONSTANTS
; *
.equ RECORD_LIMIT	= 31250		; Number of EEPROM pages to use for recording

; **
; * INTERRUPT VECTORS
; *
.include "ENB245DVR_IV.asm"

.cseg
; **
; * CODE ENTRY
; *
Entry:

	; Setup stack (Bottom end of SRAM)
	ldi r16, 		HIGH(RAMEND)
	out SPH, 		r16
	ldi r16,		LOW(RAMEND)
	out	SPL,		r16

	; Jump to start of user code
	rjmp CodeStart
	

; **
; * INCLUDE LIBRARY MODULES
; *
.include "ENB245DVR_ADC.asm"
.include "ENB245DVR_BUFFER.asm"
.include "ENB245DVR_TWI.asm"

; **
; * INCLUDE USER MODULES
; *
;
; Include any other modules here
;

; **
; * CORE FUNCTIONALLITY
; *

; RECORD - Initiates a record sequence (UNFINISHED)
Record:
	
	; Debounce

	; Enable interrupts on INT3 (RED pin).

	call 	Buffer_ResetReadPointer
	call 	Buffer_ResetWritePointer
	call 	TWI_ResetPagePointers
	call 	ADC_Start

	; Insert code for RECORD functionality here.

	; Disable interrupts on INT3.

	ret

; PLAY - Initiates a playback sequence (UNFINISHED)
Play:
	
	; Debounce

	; Enable interrupts on INT2 (GREEN pin).

	; Insert code for PLAY functionality here.

	; Disable interrupts on INT2.

	ret

; STOP - Stops all playback or recording (UNFINISHED)
Stop:
	
	; Insert code for STOP functionality here.

	; Stop PWM

	call 	ADC_Stop

	;rjmp Main
	ret ;Replace with rjump;
	

; **
; * CALLBACK FUNCTIONS
; *

; CALLBACK BufferPageFull
Callback_BufferPageFull:
	call TWI_WritePage
	ret

; CALLBACK BufferPageEmpty
Callback_BufferPageEmpty:
  ; Empty callback, required for library to assemble
	ret

; CALLBACK EEPROMReadPageDone
Callback_EEPROMReadPageDone:
  ; Empty callback, required for library to assemble
	ret

; CALLBACK EEPROMWritePageDone
Callback_EEPROMWritePageDone:
  ; check for end of recording
	cpi AddressL, LOW(RECORD_LIMIT)
	ldi	r16, 			HIGH(RECORD_LIMIT)
	cpc	AddressH, r16
	brlo DoneCallbackEEPROMWritePage
	; stop recording
	call Stop
DoneCallbackEEPROMWritePage:
	ret

; CALLBACK ErrorTWI
; Stops playback or recording if a TWI error occurs
Callback_ErrorTWI:
	call Stop
	ret

; **
; * INITIALISATION ROUTINES
; *

; INIT - Calls all required initialisation routines
Init:
	cli								; Disable interrupts	
	call Clock_Init
	call Buffer_Init
	call ADC_Init
	call TWI_Init
	call PWM_Init
	call IO_Init
	call Int_Init

	; Add additional init routines here.

	sei								; Enable interrupts
	ret

; CLOCK INIT - Initialise clock to 16MHz
Clock_Init:
	ldi r16,		0b10000000
	sts CLKPR, 	r16					; Enable clock prescaler change
	ldi r16,		0b00000000
	sts CLKPR, 	r16					; Change clock prescalar to /1
	ret

; ****************** MAIN CODE BEGINS HERE ******************

PWM_Init:
	; Initialise PWM pins.
	
	; Set clear-on-compare for channel A and
	; Normal Mode with no prescaling, with a
	; Forced Output Compare Match set on Register A.
	ldi r16,(1<<COM1A1)
	ldi r17,(1<<CS11)
	ldi r18,(1<<FOC1A)
	
	; Push to pins.
	sts TCCR1A,r16
	sts TCCR1B,r17
	sts TCCR1C,r18

	; Set OC1A pin as output.
	sbi DDRB,DDB5

	; Set desired PWM.
	
	; Set clear-on-compare for channel A and
	; 8 bit Fast PWM mode with fclk/8 prescaling.
	; PWM clock at 7.84kHz
	ldi r16,(1<<WGM10)|(1<<COM1A1)
	ldi r17,(1<<WGM12)|(1<<CS11)
	ldi r18,0x00
	
	; Push to pins.
	sts TCCR1A,r16
	sts TCCR1B,r17
	sts TCCR1C,r18

	; Set default pulse width.
	ldi r16,0x7F
	sts OCR1AL,r16

	ret

IO_Init:
	; Set button pins.
	
	; Set pullup resistors and outputs.
	sbi PORTB,PB4
	sbi PORTB,PB6
	; Set direction of I/O.
	sbi DDRB,DDB4
	
	; Set pullup resistors.
	ldi r16,(1<<PD2)|(1<<PD3)

	; Push to pins.
	out PORTD,r16

	; Set high outputs.
	ldi r16,(1<<PF1)|(1<<PF4)|(1<<PF6)
	; Set direction of I/O.
	ldi r17,(1<<DDF1)|(1<<DDF4)|(1<<DDF6)

	; Push to pins.
	out PORTF,r16
	out DDRF,r17
	
	ret

Int_Init:
	
	; Set up disabled interrupts on INT2 and INT3.


	ret

CodeStart:

	; Initialisation
	call Init

	nop

Main:
	; Main loop code goes here

	;sbis PIND,PD3 ; RECORD button press.
	;rjmp Record
	
	;sbis PIND,PD2 ; PLAY button press.
	;rjmp Play

	rjmp Main
