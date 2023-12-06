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
	LIA	8	; &c
	LIDP	32995	; Store result in a
	STD

	LP	8	; Load variable c
	LDM
	LIB	0
	STP		; Set P
	LDM		; Load content LB *c
	EXAB
	INCP
	LDM		; Load content HB *c
	EXAB
	LIDP	32997	; Store 16bit variable b
	STD		; LB
	EXAB
	LIDL	LB(32997+1)
	STD		; HB

	LIA	32	; Load constant 32
	LP	8	; Store result in c
	EXAM

	LIA	LB(65)	; Load constant LB 65
	LIB	HB(65)	; Load constant HB 65
	PUSH
	EXAB
	PUSH
	LP	8	; Load variable c
	LDM
	LIB	0
	STP		; Set P
	POP
	EXAB
	POP
	EXAM		; Store content LB *
	EXAB
	EXAM		; Store content HB *

 EOP:	RTN



