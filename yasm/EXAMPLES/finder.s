# pattern finder

data	equ	$5100		; 検索データ 先頭一バイトがデータ長
ans	equ	$5200
counter	equ	$3f	
	org	$5000

	lp	6		; 0->Y
	lia	0		; Y が内部ROMポインタ
	exam
	lp	7
	lia	0
	exam


mloop:	lp	4		; dataのアドレス->X
	lia	data&$ff	; X が検索データポインタ
	exam
	lp	5
	lia	data>> 8
	exam
	lidp	data
	ldd
	lp	counter
	exam			; カウンタセット
	lp	7		; Y をpush
	ldm			;  |
	push			;  |
	lp	6		;  |
	ldm			;  |
	push			; Yをpush
loop1:	liq	6
	lp	2
	lij	1
	mvb			; Y -> BA
	lii	0
	lp	$38
	rst
	lp	$38
	ixl
	cpma
	jrnzp	next		; データ不一致
	iy
	lp	counter
	ldm
	deca
	exam
	jrnzm	loop1
	pop
	lidp	ans+1
	std
	pop
	lidp	ans
	std
	lidp	ans+2
	lia	0
	std
	rtn

next:	pop
	lp	6
	exam
	pop
	lp	7
	exam
	iy
	cpim	$20
	jrcm	mloop
	lidp	ans+2
	lia	$ff
	std
	rtn

	
