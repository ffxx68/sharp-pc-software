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
	; For loop
	LIA	1	; Load constant 1
	LIDP	32995	; Store result in a
	STD
  LB0:
	LIDP	32995	; Load variable a
	LDD
	LIB	50	; Load constant 50
	EXAB
	LP	3
	CPMA		; Compare for smaller
	RA
	JRNCP	2
	DECA

	TSIA	255	; Branch if false
	JRZP	LB1

	; a++
	LIDP	32995	; Load variable a
	LDD
	INCA
	LIDP	32995	; Store result in a
	STD

	; b--
	LIDP	32997	; Load variable b
	LDD
	DECA
	LIDP	32997	; Store result in b
	STD

	RJMP	LB0
  LB1:
	; End of for

	; For loop
	LIA	100	; Load constant 100
	LIDP	32997	; Store result in b
	STD
  LB2:
	LIDP	32997	; Load variable b
	LDD
	PUSH
	LIDP	32995	; Load variable a
	LDD
	EXAB
	POP
	LP	3
	CPMA		; Compare for greater
	RA
	JRNCP	2
	DECA

	TSIA	255	; Branch if false
	JRZP	LB3

	; b--
	LIDP	32997	; Load variable b
	LDD
	DECA
	LIDP	32997	; Store result in b
	STD

	RJMP	LB2
  LB3:
	; End of for

	; While

  LB4:
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
	JRZP	LB5

	; While expression = true
	; b--
	LIDP	32997	; Load variable b
	LDD
	DECA
	LIDP	32997	; Store result in b
	STD

	; a++
	LIDP	32995	; Load variable a
	LDD
	INCA
	LIDP	32995	; Store result in a
	STD

	; If block: Boolean expression

	LIDP	32997	; Load variable b
	LDD
	PUSH
	RA		; Load 0
	EXAB
	POP
	LP	3
	CPMA		; Compare for equal
	RA
	JRNZP	2
	DECA

	TSIA	255	; Branch if false
	JRZP	LB6


	; If expression = true
	RJMP	LB5	; Break


	; End of if
  LB6:

	LIDP	32995	; Load variable a
	LDD
	PUSH
	LIDP	32997	; Load variable b
	LDD
	EXAB
	POP
	LP	3
	ADM		; Addition
	EXAB
	LIDP	32999	; Store result in c
	STD

	RJMP	LB4
  LB5:
	; End of while

	; Do..while

  LB7:
	LIDP	32995	; Load variable a
	LDD
	LIB	3	; Load constant 3
	LP	3
	ADM		; Addition
	EXAB
	LIDP	32995	; Store result in a
	STD

	LIDP	32995	; Load variable a
	LDD
	LIB	50	; Load constant 50
	LP	3
	CPMA		; Compare for smaller or equal
	RA
	JRCP	2
	DECA

	TSIA	255	; Branch if false
	JRZP	LB8

	; While expression = true
	RJMP	LB7
  LB8:
	; End of do..while

	; Loop

	LIA	33	; Load constant 33
	PUSH
	LIDP	32999	; Load variable c
	LDD
	EXAB
	POP
	LP	3
	ADM		; Addition
	EXAB
	PUSH
  LB9:
	LIDP	32995	; Load variable a
	LDD
	PUSH
	LIDP	32997	; Load variable b
	LDD
	EXAB
	POP
	LP	3
	EXAB
	SBM		; Subtraction
	EXAB
	LIDP	32995	; Store result in a
	STD

	LEAVE		; Break


	LIDP	32995	; Load variable a
	LDD
	LIB	1	; Load constant 1
	CALL	LIB_SL8	; Shift left
	LIDP	32997	; Store result in b
	STD

	LOOP	LB9
  LB10:
	; End of loop

 EOP:	RTN


; LIB Code
.include sl8.lib

