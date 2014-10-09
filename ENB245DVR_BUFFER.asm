; **********************************************
; ** ENB245DVR Library - Circular Buffer Module
; **  
; ** Implements a circular buffer in SRAM.
; ** Buffer length is set to 2 x 64 byte pages.
; **
; ** Configured to trigger EEPROM page write
; ** on write pointer page overflow.
; **
; ** HARDWARE RESOURCES::
; **   Top 128 bytes of SRAM
; **   Registers 28-31 (YL, YH, ZL, ZH)
; **
; ** REQUIRES:
; **   None
; **
; ** CALLBACKS:
; **   Callback_BufferPageEmpty
; **     Called on read pointer page overflow.
; **     Signifies page of buffer is empty and 
; **     ready to receive new data.
; **   Callback_BufferPageFull
; **     Called on write pointer page overflow.
; **     Signifies page of buffer is full and 
; **     ready to be read.
; **
; ** Version: v0.1
; ** Date:    19/07/2011
; ** Author:  Mark Broadmeadow
; ** 
; **********************************************

; ** 
; * CONSTANTS
; *
.equ BUFFER_START 		= SRAM_START				; Start buffer at top of SRAM
.equ BUFFER_END 			= SRAM_START + 128	; Length = 2 x 64 bytes
.equ BUFFER_PAGE2			= BUFFER_START + 64 ; Start of second 64 byte page

; **
; * BUFFER INITIALISATION
; * Sets read and write pointers to the 
; * begginning of the buffer.
; *
Buffer_Init:
	; Write pointer
	ldi YH, 	HIGH(BUFFER_START)
	ldi YL, 	LOW(BUFFER_START)
	; Read pointer
	ldi ZH, 	HIGH(BUFFER_START)
	ldi ZL, 	LOW(BUFFER_START)
	ret

; **
; * BUFFER RESET READ POINTER
; * Resets read pointer to beginning of buffer
; *
Buffer_ResetReadPointer:
	ldi ZH, 	HIGH(BUFFER_START)
	ldi ZL, 	LOW(BUFFER_START)
	ret

; **
; * BUFFER RESET WRITE POINTER
; * Resets write pointer to beginning of buffer
; *
Buffer_ResetWritePointer:
	ldi YH, 	HIGH(BUFFER_START)
	ldi YL, 	LOW(BUFFER_START)
	ret

; **
; * BUFFER CHECK WRITE OVERFLOW
; * Checks for overflow of the write pointer.
; * Resets write pointer if overflow has occured.
; *
CheckWriteOverflow:
	; test for buffer overflow
	cpi YL, 	LOW(BUFFER_END)
	ldi	r16, 	HIGH(BUFFER_END)
	cpc YH, 	r16
	brlo NoWriteOverflow
	; reset buffer pointer
	ldi YH, 	HIGH(BUFFER_START)
	ldi YL, 	LOW(BUFFER_START)	
NoWriteOverflow:
	ret

; **
; * BUFFER CHECK READ OVERFLOW
; * Checks for overflow of the read pointer.
; * Resets read pointer if overflow has occured.
; *
CheckReadOverflow:
	; test for buffer overflow
	cpi ZL, 	LOW(BUFFER_END)
	ldi	r16,	HIGH(BUFFER_END)
	cpc ZH, 	r16
	brlo NoReadOverflow
	; reset buffer pointer
	ldi ZH, 	HIGH(BUFFER_START)
	ldi ZL, 	LOW(BUFFER_START)	
NoReadOverflow:
	ret

; **
; * BUFFER CHECK WRITE PAGE OVERFLOW
; * Checks if write pointer has overflowed to a new page.
; * Triggers a callback if page overflow has occurred.
; * Resets write pointer if buffer overflow has occured.
; *
Buffer_CheckWritePageOverflow:
	; test for buffer overflow
	cpi YL, 	LOW(BUFFER_END)
	ldi	r16,	HIGH(BUFFER_END)
	cpc YH, 	r16
	brsh WriteOverflow	
	; test for new page
	cpi YL, 	LOW(BUFFER_PAGE2)
	ldi	r16,	HIGH(BUFFER_PAGE2)
	cpc YH, 	r16
	brne CheckWPODone
	; trigger page write
	rjmp NewPageFull
WriteOverflow:
	; reset write pointer
	ldi YH, 	HIGH(BUFFER_START)
	ldi YL, 	LOW(BUFFER_START)
	; trigger page write (fall through)
NewPageFull:
	call Callback_BufferPageFull
CheckWPODone:
	ret

; **
; * BUFFER CHECK READ PAGE OVERFLOW
; * Checks if read pointer has overflowed to a new page.
; * Triggers a callback if page overflow has occurred.
; * Resets read pointer if buffer overflow has occured.
; *
Buffer_CheckReadPageOverflow:
	; test for buffer overflow
	cpi ZL, 	LOW(BUFFER_END)
	ldi	r16,	HIGH(BUFFER_END)
	cpc ZH, 	r16
	brsh ReadOverflow	
	; test for new page
	cpi ZL, 	LOW(BUFFER_PAGE2)
	ldi	r16,	HIGH(BUFFER_PAGE2)
	cpc ZH, 	r16
	brne CheckRPODone
	; trigger page write
	rjmp NewPageEmpty
ReadOverflow:
	; reset read pointer
	ldi ZH, 	HIGH(BUFFER_START)
	ldi ZL, 	LOW(BUFFER_START)
	; trigger page write (fall through)
NewPageEmpty:
	call Callback_BufferPageEmpty
CheckRPODone:
	ret
