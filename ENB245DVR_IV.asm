; **********************************************
; ** ENB245DVR Library - Interrupt Vector Table
; **  
; ** Specifies interrupt and reset vectors used
; ** by other library modules and for code entry.
; ** 
; ** Any additional user interrupt vectors 
; ** should be inserted into this table.
; **
; ** Version: v0.1
; ** Date:    19/07/2011
; ** Author:  Mark Broadmeadow
; ** 
; **********************************************

; INTERRUPT VECTOR TABLE
.org $0000
	rjmp Entry
.org ADCCaddr
	rjmp ISR_ADC
.org TWIaddr
	rjmp ISR_TWI

