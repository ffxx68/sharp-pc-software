# PC-1262 よう仮想 VRAM を用いた画面スクロール

vram1	equ	$2000
vram2	equ	$2800
vram3	equ	$2040
vram4	equ	$2840
vraml	equ	5*24/2		# length of half of vram

vvram	equ	$5800

# 仮想 VRAM の構成
# $5800(4dot画面外) $5804--------$587b (4dot画面外)$587f
# $5880(4dot画面外) $5880--------$58fb (4dot画面外)$58ff

XL	equ	4
XH	equ	5
YL	equ	6
YH	equ	7

	org	$5000
begin:
# 
# capture
#
	lp	YL
	lia	(vvram+3)&$ff
	exam
	lp	YH
	lia	(vvram+3)>>8
	exam

# transfer upper-left area
	lp	XL
	lia	(vram1-1) & $ff
	exam
	lp	XH
	lia	(vram1-1) >> 8
	exam
	lia	vraml-1
	push
vtrn1:	ixl
	iys
	loop	vtrn1
# transfer upper-right area
	lp	XL
	lia	(vram2-1) & $ff
	exam
	lp	XH
	lia	(vram2-1) >> 8
	exam
	lia	vraml-1
	push
vtrn2:	ixl
	iys
	loop	vtrn2
# transfer lower-left area
	lp	YL
	lia	8
	lib	0
	adb			; jump gap
	lp	XL
	lia	(vram3-1) & $ff
	exam
	lp	XH
	lia	(vram3-1) >> 8
	exam
	lia	vraml-1
	push
vtrn3:	ixl
	iys
	loop	vtrn3
# transfer lower-right area
	lp	XL
	lia	(vram4-1) & $ff
	exam
	lp	XH
	lia	(vram4-1) >> 8
	exam
	lia	vraml-1
	push
vtrn4:	ixl
	iys
	loop	vtrn4

# demo graphic pattern load
	lia	(patY-1) >> 8
	lp	XH
	exam
	lia	(patY-1) & $ff
	lp	XL
	exam
	lia	(vvram+49) >> 8
	lp	YH
	exam
	lia	(vvram+49)&$ff
	lp	YL
	exam
	lia	14
	push
patlop:	ixl
	iys
	loop	patlop

	lia	100
	push
mloop:
	call	vv2rv
	lia	(vvram-1) >> 8
	lp	YH
	exam
	lia	(vvram-1)&$ff
	lp	YL
	exam
	lia	vvram>>8
	lp	XH
	exam
	lia	vvram&$ff
	lp	XL
	exam
	lia	vraml*4-1
	push
rollop:	ixl
	iys
	loop	rollop
	loop	mloop

	rtn

vv2rv:	# virtual VRAM -> real VRAM
	lia	(vvram+3)>>8
	lp	XH
	exam
	lia	(vvram+3)&$ff
	lp	XL
	exam
	lia	(vram1-1)>>8
	lp	YH
	exam
	lia	(vram1-1)&$ff
	lp	YL
	exam
	lia	vraml-1
	push
vv2rv1:	ixl
	iys
	loop	vv2rv1
	lia	(vram2-1)>>8
	lp	YH
	exam
	lia	(vram2-1)&$ff
	lp	YL
	exam
	lia	vraml-1
	push
vv2rv2:	ixl
	iys
	loop	vv2rv2
	lp	YL
	lia	8
	lib	0
	adb			; jump gap
	lia	(vram3-1)>>8
	lp	YH
	exam
	lia	(vram3-1)&$ff
	lp	YL
	exam
	lia	vraml-1
	push
vv2rv3:	ixl
	iys
	loop	vv2rv3
	lia	(vram4-1)>>8
	lp	YH
	exam
	lia	(vram4-1)&$ff
	lp	YL
	exam
	lia	vraml-1
	push
vv2rv4:	ixl
	iys
	loop	vv2rv4
	rtn

	org	$5100
patY:   db      $03,$07,$7c,$7f,$07
patA:   db      $7c,$7e,$13,$7e,$7c
patG:   db      $3e,$7f,$41,$79,$79

