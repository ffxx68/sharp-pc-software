# pattern finder

data	equ	$5100		; $B8!:w%G!<%?(B $B@hF,0l%P%$%H$,%G!<%?D9(B
ans	equ	$5200
counter	equ	$3f	
	org	$5000

	lp	6		; 0->Y
	lia	0		; Y $B$,FbIt(BROM$B%]%$%s%?(B
	exam
	lp	7
	lia	0
	exam


mloop:	lp	4		; data$B$N%"%I%l%9(B->X
	lia	data&$ff	; X $B$,8!:w%G!<%?%]%$%s%?(B
	exam
	lp	5
	lia	data>> 8
	exam
	lidp	data
	ldd
	lp	counter
	exam			; $B%+%&%s%?%;%C%H(B
	lp	7		; Y $B$r(Bpush
	ldm			;  |
	push			;  |
	lp	6		;  |
	ldm			;  |
	push			; Y$B$r(Bpush
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
	jrnzp	next		; $B%G!<%?IT0lCW(B
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

	
