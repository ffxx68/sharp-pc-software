; pasm file - assemble with pasm!
; Compiled with lcc v1.0

.ORG	33000

	LP	0
	LIDP	SREG
	LII	11
	EXWD

	CALL	main	; Call procedure main
	LP	0
	LIDP	SREG
	LII	11
	MVWD
	RTN

SREG:	.DW 0, 0, 0, 0, 0, 0

MAIN:
	; If block: Boolean expression

	LIDP	32995	; Load variable a
	LDD
	PUSH
	LIDP	32999	; Load variable c
	LDD
	EXAB
	POP
	LP	3
	CPMA		; Compare for equal
	RA
	JRNZP	2
	DECA

	TSIA	255	; Branch if false
	JRZP	LB0


	; If expression = true
	LIA	1	; Load constant 1
	LIDP	32997	; Store result in b
	STD

	RJMP	LB1
  LB0:
	; If expression = false
	RA		; Load 0
	LIDP	32997	; Store result in b
	STD

	; End of if
  LB1:

	; If block: Boolean expression

	LIDP	32995	; Load variable a
	LDD
	LIB	100	; Load constant 100
	EXAB
	LP	3
	CPMA		; Compare for Greater or Equal
	RA
	JRCP	2
	DECA

	PUSH
	LIDP	32997	; Load variable b
	LDD
	LIB	10	; Load constant 10
	EXAB
	LP	3
	CPMA		; Compare for smaller
	RA
	JRNCP	2
	DECA

	EXAB
	POP
	LP	3
	ANMA		; AND
	EXAB
	TSIA	255	; Branch if false
	JRZP	LB2


	; If expression = true
	LIA	5	; Load constant 5
	LIDP	32999	; Store result in c
	STD

	; a++
	LIDP	32995	; Load variable a
	LDD
	INCA
	LIDP	32995	; Store result in a
	STD

	; End of if
  LB2:

 EOP:	RTN



