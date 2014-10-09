; ***** I/O REGISTER DEFINITIONS *****************************************
; NOTE:
; Definitions marked "MEMORY MAPPED"are extended I/O ports
; and cannot be used with IN/OUT instructions
; TWI definitions missing from include file
.equ	TWAMR	= 0xbd	; MEMORY MAPPED
.equ	TWCR	= 0xbc	; MEMORY MAPPED
.equ	TWDR	= 0xbb	; MEMORY MAPPED
.equ	TWAR	= 0xba	; MEMORY MAPPED
.equ	TWSR	= 0xb9	; MEMORY MAPPED
.equ	TWBR	= 0xb8	; MEMORY MAPPED

; ***** TWI **************************
; TWAMR - TWI (Slave) Address Mask Register
.equ	TWAM0	= 1	; 
.equ	TWAMR0	= TWAM0	; For compatibility
.equ	TWAM1	= 2	; 
.equ	TWAMR1	= TWAM1	; For compatibility
.equ	TWAM2	= 3	; 
.equ	TWAMR2	= TWAM2	; For compatibility
.equ	TWAM3	= 4	; 
.equ	TWAMR3	= TWAM3	; For compatibility
.equ	TWAM4	= 5	; 
.equ	TWAMR4	= TWAM4	; For compatibility
.equ	TWAM5	= 6	; 
.equ	TWAMR5	= TWAM5	; For compatibility
.equ	TWAM6	= 7	; 
.equ	TWAMR6	= TWAM6	; For compatibility

; TWBR - TWI Bit Rate register
.equ	TWBR0	= 0	; 
.equ	TWBR1	= 1	; 
.equ	TWBR2	= 2	; 
.equ	TWBR3	= 3	; 
.equ	TWBR4	= 4	; 
.equ	TWBR5	= 5	; 
.equ	TWBR6	= 6	; 
.equ	TWBR7	= 7	; 

; TWCR - TWI Control Register
.equ	TWIE	= 0	; TWI Interrupt Enable
.equ	TWEN	= 2	; TWI Enable Bit
.equ	TWWC	= 3	; TWI Write Collition Flag
.equ	TWSTO	= 4	; TWI Stop Condition Bit
.equ	TWSTA	= 5	; TWI Start Condition Bit
.equ	TWEA	= 6	; TWI Enable Acknowledge Bit
.equ	TWINT	= 7	; TWI Interrupt Flag

; TWSR - TWI Status Register
.equ	TWPS0	= 0	; TWI Prescaler
.equ	TWPS1	= 1	; TWI Prescaler
.equ	TWS3	= 3	; TWI Status
.equ	TWS4	= 4	; TWI Status
.equ	TWS5	= 5	; TWI Status
.equ	TWS6	= 6	; TWI Status
.equ	TWS7	= 7	; TWI Status

; TWDR - TWI Data register
.equ	TWD0	= 0	; TWI Data Register Bit 0
.equ	TWD1	= 1	; TWI Data Register Bit 1
.equ	TWD2	= 2	; TWI Data Register Bit 2
.equ	TWD3	= 3	; TWI Data Register Bit 3
.equ	TWD4	= 4	; TWI Data Register Bit 4
.equ	TWD5	= 5	; TWI Data Register Bit 5
.equ	TWD6	= 6	; TWI Data Register Bit 6
.equ	TWD7	= 7	; TWI Data Register Bit 7

; TWAR - TWI (Slave) Address register
.equ	TWGCE	= 0	; TWI General Call Recognition Enable Bit
.equ	TWA0	= 1	; TWI (Slave) Address register Bit 0
.equ	TWA1	= 2	; TWI (Slave) Address register Bit 1
.equ	TWA2	= 3	; TWI (Slave) Address register Bit 2
.equ	TWA3	= 4	; TWI (Slave) Address register Bit 3
.equ	TWA4	= 5	; TWI (Slave) Address register Bit 4
.equ	TWA5	= 6	; TWI (Slave) Address register Bit 5
.equ	TWA6	= 7	; TWI (Slave) Address register Bit 6
