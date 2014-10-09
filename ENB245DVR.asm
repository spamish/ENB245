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

.include "m32u4def.inc"
.include "m32u4def_twi.inc"

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
	call 	Buffer_ResetReadPointer
	call 	Buffer_ResetWritePointer
	call 	TWI_ResetPagePointers
	call 	ADC_Start
	ret

; PLAY - Initiates a playback sequence (UNFINISHED)
Play:
	; Insert code for PLAY functionality here
	ret

; STOP - Stops all playback or recording (UNFINISHED)
Stop:
	call 	ADC_Stop
	ret
	

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
	; Add additional init routines here
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
CodeStart:

	; Initialisation
	call Init

Main:
	
	; Main loop code goes here

	rjmp Main



