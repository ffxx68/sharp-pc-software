#####################################################
#   PC-1245 (125x) ようリロケイタブル機械語モニタ   #
#                 yagmon1245                        #
#####################################################
	
# キーコード定義	
K_BRK	equ	7
K_UP	equ	$c
K_DOWN	equ	$d
K_RIGHT	equ	$e
K_LEFT	equ	$f

# 内部 RAM のワークエリア定義	
ADRL	equ	$39
ADRH	equ	$3a
ADR	equ	ADRL		; 現在のアドレス
BUF5	equ	$3b		; 3b,3c,3d,3e,(3f) を使う
SUM	equ	$3f		; チェックサム計算よう

# 内部 RAM のレジスタとか定義
I	equ	0
J	equ	1
A	equ	2
B	equ	3
XL	equ	4
XH	equ	5
YL	equ	6
YH	equ	7
	
org	$c200			; 開始アドレス。ご自由にどうぞ。

	lidp	$c6da
	orid	$20		; カーソル表示 on

begin:
	cal	$11e0		; 画面表示 on
here0:	ldr
	sbia	2
	str
	stp
	lib	(here1-here0)>>8
	lia	(here1-here0)&$ff
	adb

	lij	1
	cal	$11f9		; LIY CHRBUFF-1
	
	lp	ADRH
tohex:				; (P)を16進にして
				; キャラクタコードを[Y]に入れる
				; AB 壊す
	ldm
	lib	1
	swp
tohex0:	ania	$0f
	adia	$40		; '0'
	cpia	$4a
	jrcp	tohex1
	adia	$51-10-$40	; 'A'-10-'0'
tohex1:	iys
	ldm
	decb
	jrzm	tohex0
	ldr			; 帰る時の R を A に入れとく
end:	rtn

here1:
	str
	stp
	lib	(here2-here1)>>8
	lia	(here2-here1)&$ff
	adb
	lp	ADRL
	jrm	tohex		; リターンアドレスは here2
here2:
	str
	stp
	lib	(here3-here2)>>8
	lia	(here3-here2)&$ff
	adb

	
	lia	$1d		; ':'
	iys

	lp	ADRH		; ADR -> BA
	ldm
	exab
	lp	ADRL
	ldm


	lii	3
	lp	BUF5
	data
	clra
	exam			; チェックサムをクリアする

	lp	BUF5
datlop:
	ldp
	push
	ldm
	lp	SUM
	adm
	pop
	stp
	jrm	tohex		; リターンアドレスは here3
here3:
	str
	incp
	deci
	jrncm	datlop

	stp
	lib	(here4-here3)>>8
	lia	(here4-here3)&$ff
	adb
	lia	$1d		; ':' の内部コード
	iys
	lp	SUM
	jrm	tohex		; リターンアドレスは here4

####################
#  上下(4バイト)移動		; 相対ジャンプの関係でここに配置(苦しい…)
mvup:	lib	$ff
	lia	$fc
	jrp	mvupdn
mvdn:	lib	$00
	lia	$04
mvupdn:	lp	ADR
	adb
gobegin:
	jrm	begin
######################


here4:
	clra
	iys
	cal	$11af		; 表示
keyin:	cal	$1d0d		; キー入力待ち
	cpia	K_UP
	jrzm	mvup
	cpia	K_DOWN
	jrzm	mvdn
	cpia	K_BRK
	jrzm	end
	cpia	K_LEFT
	jrzp	mvleft
	cpia	K_RIGHT
	jrzp	mvright
	cpia	$40
	jrcm	keyin
	cpia	$4a
	jrcp	bufwrt
	cpia	$51
	jrcm	keyin
	cpia	$57
	jrncm	keyin
	
bufwrt:	exab			; 書き込み(0〜9,ABCDEFキー押された)
	lidp	$c6ea
	ldd
	deca
	lp	YL
	exam
	lia	$c7
	lp	YH
	exam
	exab
	iys
	lp	YL
	cpim	$b4
	jrncp	rddata		; 書き込んだのがデータなら飛ぶ
rdaddr:				; 左4文字文のアドレスを読み、セット
	lij	1
	cal	$119a

	lp	ADRH
ldad1:
	ixl
	sbia	$40
	cpia	10
	jrcp	ldad2
	sbia	7
ldad2:	swp
	exam
	ixl
	sbia	$40
	cpia	10
	jrcp	ldad3
	sbia	7
ldad3:	orma
	decp
	ldp
	cpia	ADRL-1
	jrnzm	ldad1
	jrp	mvright

rddata:				; データを読んでメモリに書き込む
	lij	1
	cal	$119a		; LIX CHRBUFF-1
	liq	ADR
	lij	1
	mvb			; cal $119a 直後は P は YL のはず
	dy
	lp	XL
	adim	5
	lia	3
	push
stdat1:	ixl
	sbia	$40
	cpia	10
	jrcp	stdat2
	sbia	7
stdat2:	swp
	exab
	ixl
	sbia	$40
	cpia	10
	jrcp	stdat3
	sbia	7
stdat3:	lp	B
	orma
	exam
	iys			; データをメモリに収納
	loop	stdat1		; そのまま右カーソル移動
#  左右(1ニブル)移動
mvright:
	lidp	$c6ea
	ldd
	inca
	jrp	mvlr1
mvleft:
	lidp	$c6ea
	ldd
	deca
mvlr1:	cpia	$bd
	jrncp	mvlr3
	cpia	$b0
	jrcp	mvlr2
	std
mvlr2:	jrm	gobegin
mvlr3:	lia	$b5
	std
	jrm	mvdn
