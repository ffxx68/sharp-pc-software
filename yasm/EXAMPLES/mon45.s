#####################################################
#   PC-1245 (125x) $B$h$&%j%m%1%$%?%V%k5!3#8l%b%K%?(B   #
#                 yagmon1245                        #
#####################################################
	
# $B%-!<%3!<%IDj5A(B	
K_BRK	equ	7
K_UP	equ	$c
K_DOWN	equ	$d
K_RIGHT	equ	$e
K_LEFT	equ	$f

# $BFbIt(B RAM $B$N%o!<%/%(%j%"Dj5A(B	
ADRL	equ	$39
ADRH	equ	$3a
ADR	equ	ADRL		; $B8=:_$N%"%I%l%9(B
BUF5	equ	$3b		; 3b,3c,3d,3e,(3f) $B$r;H$&(B
SUM	equ	$3f		; $B%A%'%C%/%5%`7W;;$h$&(B

# $BFbIt(B RAM $B$N%l%8%9%?$H$+Dj5A(B
I	equ	0
J	equ	1
A	equ	2
B	equ	3
XL	equ	4
XH	equ	5
YL	equ	6
YH	equ	7
	
org	$c200			; $B3+;O%"%I%l%9!#$4<+M3$K$I$&$>!#(B

	lidp	$c6da
	orid	$20		; $B%+!<%=%kI=<((B on

begin:
	cal	$11e0		; $B2hLLI=<((B on
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
tohex:				; (P)$B$r(B16$B?J$K$7$F(B
				; $B%-%c%i%/%?%3!<%I$r(B[Y]$B$KF~$l$k(B
				; AB $B2u$9(B
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
	ldr			; $B5"$k;~$N(B R $B$r(B A $B$KF~$l$H$/(B
end:	rtn

here1:
	str
	stp
	lib	(here2-here1)>>8
	lia	(here2-here1)&$ff
	adb
	lp	ADRL
	jrm	tohex		; $B%j%?!<%s%"%I%l%9$O(B here2
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
	exam			; $B%A%'%C%/%5%`$r%/%j%"$9$k(B

	lp	BUF5
datlop:
	ldp
	push
	ldm
	lp	SUM
	adm
	pop
	stp
	jrm	tohex		; $B%j%?!<%s%"%I%l%9$O(B here3
here3:
	str
	incp
	deci
	jrncm	datlop

	stp
	lib	(here4-here3)>>8
	lia	(here4-here3)&$ff
	adb
	lia	$1d		; ':' $B$NFbIt%3!<%I(B
	iys
	lp	SUM
	jrm	tohex		; $B%j%?!<%s%"%I%l%9$O(B here4

####################
#  $B>e2<(B(4$B%P%$%H(B)$B0\F0(B		; $BAjBP%8%c%s%W$N4X78$G$3$3$KG[CV(B($B6l$7$$!D(B)
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
	cal	$11af		; $BI=<((B
keyin:	cal	$1d0d		; $B%-!<F~NOBT$A(B
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
	
bufwrt:	exab			; $B=q$-9~$_(B(0$B!A(B9,ABCDEF$B%-!<2!$5$l$?(B)
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
	jrncp	rddata		; $B=q$-9~$s$@$N$,%G!<%?$J$iHt$V(B
rdaddr:				; $B:8(B4$BJ8;zJ8$N%"%I%l%9$rFI$_!"%;%C%H(B
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

rddata:				; $B%G!<%?$rFI$s$G%a%b%j$K=q$-9~$`(B
	lij	1
	cal	$119a		; LIX CHRBUFF-1
	liq	ADR
	lij	1
	mvb			; cal $119a $BD>8e$O(B P $B$O(B YL $B$N$O$:(B
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
	iys			; $B%G!<%?$r%a%b%j$K<}G<(B
	loop	stdat1		; $B$=$N$^$^1&%+!<%=%k0\F0(B
#  $B:81&(B(1$B%K%V%k(B)$B0\F0(B
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
