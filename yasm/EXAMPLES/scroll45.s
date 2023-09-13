# PC-1245,125x よう左画面スクロール

	org	$c200

	cal	$11e0
	lp	6
	lia	$ff
	exam
	lp	7
	lia	$f7
	exam
	lia	5*12-1
	push
	lia	$ff
loop:	iys
	loop	loop
	lia	0
	push
loop2:	wait 	$ff
	loop	loop2
	rtn
