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
	LIA	200	; Load constant 200
	PUSH
	LIDP	32999	; Load variable c
	LDD
	EXAB
	POP
	LP	3
	EXAB
	SBM		; Subtraction
	EXAB
	PUSH
	LIA	3	; Load constant 3
	PUSH
	LIDP	32997	; Load variable b
	LDD
	EXAB
	POP
	CALL	LIB_MUL8	; Multiplication
	EXAB
	POP
	LP	3
	ORMA		; OR
	EXAB
	LIDP	32995	; Store result in a
	STD

	LIDP	32999	; Load variable c
	LDD
	LIB	5	; Load constant 5
	CALL	LIB_SR8	; Shift right
	PUSH
	LIA	3	; Load constant 3
	PUSH
	LIDP	32995	; Load variable a
	LDD
	EXAB
	POP
	LP	3
	ANMA		; AND
	POP
	LP	3
	ADM		; Addition
	EXAB
	LIDP	32997	; Store result in b
	STD

	LIA	1	; Load constant 1
	PUSH
	LIDP	32997	; Load variable b
	LDD
	EXAB
	POP
	CALL	LIB_SL8	; Shift left
	PUSH
	LIDP	32995	; Load variable a
	LDD
	LIB	5	; Load constant 5
	CALL	LIB_MUL8	; Multiplication
	EXAB
	POP
	LP	3
	EXAB
	SBM		; Subtraction
	EXAB
	LIDP	32999	; Store result in c
	STD

 EOP:	RTN


; LIB Code
.include mul8.lib
.include sr8.lib
.include sl8.lib

