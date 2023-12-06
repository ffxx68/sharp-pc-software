; pasm file - assemble with pasm!
; Compiled with lcc v1.0

.ORG	33000

	LP	0
	LIDP	SREG
	LII	11
	EXWD
	LII	5	; Variable c = (32980, 32981, 32982)
	LIDP	c
	LP	21
	MVWD

	LIDP	65495	; Variable f = (1, 232)
	LIA	1
	STD
	LIDL	LB(65496)
	LIA	232
	STD


	CALL	main	; Call procedure main
	LP	0
	LIDP	SREG
	LII	11
	MVWD
	RTN

SREG:	.DW 0, 0, 0, 0, 0, 0

MAIN:
	RA		; Load 0
	LIB	14	; Load array element from b
	LP	3
	ADM
	EXAB
	STP
	LDM
	PUSH
	RA		; Load 0
	LIB	8	; Store array element from a
	LP	3
	ADM
	EXAB
	STP
	POP
	EXAM

 EOP:	RTN

c:	; Variable init data c
	.DW	32980, 32981, 32982

e:	; Variable e = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	.DW	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

g:	; Variable g = (72, 105, 32, 116, 104, 101, 114, 101, 33, 0, 0, 0)
	.DB	72, 105, 32, 116, 104, 101, 114, 101, 33, 0, 0, 0



