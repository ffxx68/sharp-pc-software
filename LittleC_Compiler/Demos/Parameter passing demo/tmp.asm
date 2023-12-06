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
	LIA	25	; Load constant 25
	PUSH
	LIDP	32997	; Load variable b
	LDD
	EXAB
	POP
	LP	3
	ADM		; Addition
	EXAB
	PUSH
	CALL	test3	; Call procedure test3
	POP

	LIDP	32995	; Load variable a
	LDD
	PUSH
	LIA	55	; Load constant 55
	PUSH
	CALL	test1	; Call procedure test1
	EXAB
	LDR
	ADIM	2
	STR
	EXAB
	PUSH
	LIDP	32999	; Load variable c
	LDD
	LIB	8	; Load constant 8
	CALL	LIB_SL8	; Shift left
	PUSH
	LIDP	32997	; Load variable b
	LDD
	EXAB
	POP
	LP	3
	ADM		; Addition
	EXAB
	PUSH
	CALL	test2	; Call procedure test2
	EXAB
	LDR
	ADIM	2
	STR
	EXAB
	LIB	8	; Load constant 8
	CALL	LIB_SR8	; Shift right
	LIDP	32997	; Store result in b
	STD

 EOP:	RTN


test1:	; Procedure
	LIA	5	; Load constant 5
	PUSH
	LDR
	ADIM	4
	STP
	LDM		; Load variable loc1
	EXAB
	POP
	CALL	LIB_MUL8	; Multiplication
	PUSH
	LDR
	ADIM	3
	STP
	LDM		; Load variable loc2
	EXAB
	POP
	LP	3
	ADM		; Addition
	EXAB
	RTN		; Return


	RTN


test2:	; Procedure
	LDR
	ADIM	2
	STP
	LDM	; HB - Load variable t1
	EXAB
	INCP
	LDM	; LB
	PUSH		; Push A then B
	EXAB
	PUSH
	LDR
	ADIM	6
	STP
	LDM		; Load variable t2
	LIB	0
	LP	0
	EXAM
	EXAB
	LP	1
	EXAM
	POP
	EXAB
	POP
	EXAB
	LP	0
	SBB		; Subtraction
	LP	1
	LDM
	EXAB
	LP	0
	LDM
	RTN		; Return


	RTN


test3:	; Procedure
	LDR
	ADIM	3
	STP
	LDM		; Load variable loc3
	PUSH
	LDR
	ADIM	3
	STP
	LDM		; Load variable h
	EXAB
	POP
	LP	3
	ADM		; Addition
	EXAB
	LIDP	32995	; Store result in a
	STD

	RTN


; LIB Code
.include sl8.lib
.include sr8.lib
.include mul8.lib

