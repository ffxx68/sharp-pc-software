	org	$5280

	lia	$0	; 上位アドレス
	lib	$0
	lp	$38
	lii	15
	rst
	lp	6
	lia	$bf
	exam
	lp	7
	lia	$52
	exam
	lp	$38
	lia	15
	push
loop:	ldm
	incp
	iys
	loop	loop
	rtn
