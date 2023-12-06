; pasm file - assemble with pasm!
; Compiled with lcc v1.0

.ORG	33000

	LP	0
	LIDP	SREG
	LII	11
	EXWD
	LP	14	; Variable c = 32980
	LIA	LB(32980)	; LB
	EXAM
	INCP
	LIA	HB(32980)	; HB
	EXAM

	LIDP	0	; Variable f = 0
	RA
	STD
	LIDL	LB(1)
	STD


	CALL	main	; Call procedure main
	LP	0
	LIDP	SREG
	LII	11
	MVWD
	RTN

SREG:	.DW 0, 0, 0, 0, 0, 0

MAIN:
	LP	9	; Load variable b
	LDM
	PUSH
	LP	10	; Load variable d
	LDM
	EXAB
	POP
	LP	3
	ADM		; Addition
	EXAB
	LP	8	; Store result in a
	EXAM

 EOP:	RTN

e:	; Variable e = 0
	.DW	0

g:	; Variable g = 0
	.DB	0

h:	; Variable h = 0
	.DB	0



