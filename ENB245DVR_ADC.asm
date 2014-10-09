; **********************************************
; ** ENB245DVR Library - ADC Module 
; **  
; ** Configures ADC to sample CH0 at 7.8125kHz.
; ** Results are stored in a circular buffer.
; ** 
; ** HARDWARE RESOURCES:
; **   ADC
; **   Timer 0
; **
; ** REQUIRES:
; **   Circular Buffer Module
; **
; ** CALLBACKS:
; **   None
; **
; ** Version: v0.1
; ** Date:    19/07/2011
; ** Author:  Mark Broadmeadow
; ** 
; **********************************************

; **
; * ADC INITIALISATION
; * Initialises the ADC for 7.8125kHz sampling on CH0
; *
ADC_Init:
	
	; Init Timer 0 for 7.8125kHz sampling
	ldi r16, 		0b00000010
	out TCCR0A, r16					; CTC mode, no outputs
	ldi r16, 		255
	out OCR0A, 	r16					; 255 = 7.8125kHz
	
	; Init ADC for 8-bit sampling on Ch 0 @ OC0A
	ldi r16, 		0b01100000 	
	sts ADMUX, 	r16					; AVCC Ref, Left-adjust result, ADC0
	ldi r16,  	0b10111110 	
	sts ADCSRA,	r16					; Auto-SOC, Interrupt enable, /64 prescaler
	ldi r16,  	0b00000011 	
	sts ADCSRB,	r16					; Select OC0 as SOC source
	ldi r16,		0b00000001 	
	sts DIDR0,	r16					; Disable Ch 0 buffer

	ret

; **
; * ADC START
; * Starts ADC sampling
; *
ADC_Start:
	; Start PWM, CTC mode, /8 prescaler
	ldi r16,		0b00000010
	out TCCR0B, r16					
	ret

; **
; * ADC STOP
; * Stop ADC sampling
; *
ADC_Stop:
	; Stop PWM, reset counter
	ldi r16,		0b00000000
	out TCCR0B, r16					
	out TCNT0,	r16
	ret

; **
; * ADC INTERRUPT SERCVICE ROUTINE
; * Interrupts on ADC End-Of-Conversion.
; * ADC result is stored in circular buffer.
; *
ISR_ADC:
	
	; Save status
	push r16
	in r16, SREG
	push r16

	; Store ADC result in circular buffer
	lds r16, ADCH
	st Y+, r16

	; Check for buffer overflow
	call Buffer_CheckWritePageOverflow

	; Clear Timer 0 Interrupt Flag
	sbi TIFR0, 1

	; Restore status
	pop r16
	out SREG, r16
	pop r16

	reti
