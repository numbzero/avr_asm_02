.include "m32def.inc"

.cseg				; code segment
.org 0x0000			; set beginning of the address
	rjmp RESET

.org	INT0addr	; External Interrupt0 Vector Address
	rjmp EXT_INT_0

.org	INT1addr	; External Interrupt1 Vector Address
	rjmp EXT_INT_1


EXT_INT_0:
	// store state of SREG
	in R17, SREG
	
	// increment OCR1AL
	in R18, OCR1AL
	inc R18
	out OCR1AL, R18

	// decrement OCR1BL
	in R18, OCR1BL
	dec R18
	out OCR1BL, R18

	// restore state of SREG
	out SREG, R17
	// return from interrupt
	reti

EXT_INT_1:
	// store state of SREG
	in R17, SREG

	// decrement OCR1AL 
	in R18, OCR1AL
	dec R18
	out OCR1AL, R18
	
	// increment OCR1BL
	in R18, OCR1BL
	inc R18
	out OCR1BL, R18

	// restore state of SREG
	out SREG, R17
	// return from interrupt
	reti


RESET:
	// setup stack, we need it for interrupts
	ldi R16, LOW(RAMEND)
	out SPL, R16
	ldi R16, HIGH(RAMEND)
	out SPH, R16

	// explicit pins setup
	// in								  PD5 (OC1A)    PD4 (OC1B) 	  PD3 (INT1)	PD2 (INT0)
	ldi R16, (0 << DDD7) | (0 << DDD6) | (1 << DDD5) | (1 << DDD4) | (0 << DDD3) | (0 << DDD2) | (0 << DDD1) | (0 << DDD0)
	out DDRD, R16

	// disable interrupts
	cli

	// external interrupts setup
	ldi R16, (1 << INT1) | (1 << INT0)
	out GICR, R16
	// rising edge will generate an interrupt request
	ldi R16, (1 << ISC11) | (1 << ISC10) | (1 << ISC01) | (1 << ISC00)
	out MCUCR, R16

	// enable interrupts
	sei

	// timer/counter1 setup
	// prescaler  - 8
	// mode 	  - FastPWM
	// TOP = ICR1 - 110
	// clear OC1A on compare match (output to low  level)
	// set   OC1B on compare match (output to high level)

	ldi R16, (1 << COM1A1) | (1 << COM1A0) | (1 << COM1B1) | (1 << COM1B0) | (1 << WGM11) 
	out TCCR1A, R16

	ldi R16, (1 << WGM13) | (1 << WGM12) | (1 << CS11)
	out TCCR1B, R16

	ldi R16, 0x6d ; ICR1L  = 110 - 1
	out ICR1L, R16
	

	ldi R16, 0x00 ; OCR1AL =  0 - 0%;
	out OCR1AL, R16

	ldi R16, 0x6c ; OCR1BL = 109 - 100% 
	out OCR1BL, R16

MAIN:
	nop
	nop
	nop
	rjmp MAIN
