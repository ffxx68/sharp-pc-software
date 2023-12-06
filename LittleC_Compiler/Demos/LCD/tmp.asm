; pasm file - assemble with pasm!
; Compiled with lcc v1.0

.ORG	0xE130

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
	LIA	LB(0x3000)	; Load constant LB 0x3000
	LIB	HB(0x3000)	; Load constant HB 0x3000
	LP	8	; Store 16bit variable h
	EXAM		; LB
	EXAB
	INCP		; HB
	EXAM
  LB0:
	LP	9	; Load 16bit variable h
	LDM		; HB
	EXAB
	DECP		; LB
	LDM
	PUSH		; Push A then B
	EXAB
	PUSH
	LIA	LB(0x3000)	; Load constant LB 0x3000
	LIB	HB(0x3000)	; Load constant HB 0x3000
	PUSH		; Push A then B
	EXAB
	PUSH
	LIA	LB(60)	; Load constant LB 60
	LIB	HB(60)	; Load constant HB 60
	LP	0
	EXAM
	EXAB
	LP	1
	EXAM
	POP
	EXAB
	POP
	LP	0
	ADB		; Addition
	LP	1
	LDM
	EXAB
	LP	0
	LDM
	LP	0
	EXAM
	EXAB
	LP	1
	EXAM
	POP
	EXAB
	POP
	CALL	LIB_CPS16	; Compare for smaller

	TSIA	255	; Branch if false
	JRZP	LB1

	LP	9	; Load 16bit variable h
	LDM		; HB
	EXAB
	DECP		; LB
	LDM
	PUSH		; Push A then B
	EXAB
	PUSH
	LIA	LB(1)	; Load constant LB 1
	LIB	HB(1)	; Load constant HB 1
	LP	0
	EXAM
	EXAB
	LP	1
	EXAM
	POP
	EXAB
	POP
	LP	0
	ADB		; Addition
	LP	1
	LDM
	EXAB
	LP	0
	LDM
	LP	8	; Store 16bit variable h
	EXAM		; LB
	EXAB
	INCP		; HB
	EXAM

	RJMP	LB0
  LB1:
	; End of for

 EOP:	RTN


readbyte:	; Procedure
	LDR
	ADIA	2
	STP
	LDM	; HB - Load variable adr
	EXAB
	INCP
	LDM	; LB
	LP	4	; Store 16bit variable radr
	EXAM		; LB
	EXAB
	INCP		; HB
	EXAM

	
	DX
	IXL

	RTN


writebyte:	; Procedure
	LDR
	ADIA	3
	STP
	LDM	; HB - Load variable adr2
	EXAB
	INCP
	LDM	; LB
	LP	6	; Store 16bit variable wadr
	EXAM		; LB
	EXAB
	INCP		; HB
	EXAM

	LDR
	ADIA	2
	STP
	LDM		; Load variable byt
	LP	2	; Store result in regA
	EXAM

	
	DY
	IYS

	RTN


; LIB Code
.include cps16.lib

