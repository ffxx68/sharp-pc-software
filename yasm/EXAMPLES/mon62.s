A	equ	2
B	equ	3
XL	equ	4
XH	equ	5
YL	equ	6
YH	equ	7
ADDR	equ	$3e
ADDRL	equ	ADDR
ADDRH	equ	ADDRL+1
DATA	equ	$36		; (DATA-1)は使用不可


	
#	ROM 内ルーチン定義
LCDON	equ	$043b
STX	equ	$225
STY	equ	$222
MVYX	equ	$1344
DSTX	equ	$22e
DSTY	equ	$242
OUTCA	equ	$043d

	org	$6000


	lib	$20		; 番地セット(仮よう)
	lia	$00
	lp	ADDR
	liq	2
	lii	1
	mvw
	
begin:	cal	LCDON
here0:	ldr
	sbia	2
	str
	stp
	lib	(here1-here0)>>8
	lia	(here1-here0)&$ff
	adb

	
	lii	1
	lia	$68
	lib	$66
	cal	DSTY
	lp	A
	liq	ADDR
	mvw
	lii	7
	lp	DATA
	data
	lidp	$6668
	lp	DATA
	lia	7
	push
chrlop:	ldm
	cpia	$20
	jrncp	chrl1
	lia	$20
	cpia	$ff
chrl1:	iys
	incp
	loop	chrlop
	clra
	iys
		
wrtaddr:
	liq	$10
	lij	1
	cal	$232		; LIX	PRTBUFF-1
	cal	MVYX
	lp	ADDRH

	
tohex:				; (P)の内容をHEX化して[+Y]に入れる
                                ; A,B 壊す
	ldm
	lib	1
	swp
tohex0:	ania	$0f
	adia	$30		; '0'
	cpia	$3a
	jrcp	tohex1
	adia	$41-10-$30
tohex1:	iys
	ldm
	decb
	jrzm	tohex0
	ldr
ret:	rtn

here1:	str
	stp
	lib	(here2-here1)>>8
	lia	(here2-here1)&$ff
	adb
	lp	ADDRL
	jrm	tohex
here2:	str
	stp
	lib	(here3-here2)>>8
	lia	(here3-here2)&$ff
	adb
	lia	$3a		; ':'
	iys


	lii	8
	lp	DATA-1
	clra
	exam
datlop:
	incp
	jrm	tohex
here3:	str
	decp
	ldm
	incp
	adm
	deci
	jrnzm	datlop
	ldr
	stp
	lib	(here4-here3)>>8
	lia	(here4-here3)&$ff
	adb
	lia	$3a
	iys
	lp	DATA+7
	jrm	tohex
here4:
	lidp	$661e
	lia	48
	std
	call	$d0f3

# 画面にパタンを40バイトくらい表示
	lia	$40
	lib	$28
	lii	1
	cal	DSTY
	lia	59		; loop you
	push
	lp	A
	liq	ADDR
	mvw
	cal	DSTX
patlop:	ix
	lp	2
	liq	4
	mvw
	lp	DATA
	data
	iy
	lp	DATA
	mvdm
	loop	patlop
	
endlop:
	lia	7
	cal	OUTCA
	cal	$3c1
	jrncm	endlop
	cpia	$19
	jrnzp	endend
	lp	ADDR
	lia	8
	lib	0
	adb
	jrm	begin

endend:	
	rc
	rtn
