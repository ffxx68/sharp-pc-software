; #########################################
; # PART TWO OF THE                       #
; # PE Tools - a toolkit to extend the    #
; # possibilities of the sharp 1403(H)    #
; # author   : Puehringer Edgar           #
; # date     : 22.03.2001                 #
; # version  : 1.1                        #
; # assembler: YASM 1.1                   #
; #########################################

	ORG	$82A8		; 33448 = next free address after 
				; PE Tools part one

; addresses needed from part one of PE Tools

DISPAC	EQU 32895
VARADR	EQU 33091
GPRINC  EQU 33038
 
; CPU registers

REG_I	EQU  $00		; index register
REG_J	EQU  $01		; index register
REG_A	EQU  $02		; accumulator
REG_B	EQU  $03		; accumulator
REG_XL	EQU  $04		; LSB of adress pointer
REG_XH	EQU  $05		; MSB of adress pointer
REG_YL	EQU  $06		; LSB of adress pointer
REG_YH	EQU  $07		; MSB of adress pointer
REG_K	EQU  $08		; counter
REG_L	EQU  $09		; counter
REG_M	EQU  $0A		; counter
REG_N	EQU  $0B		; counter
STR_ID	EQU  $F5		; first byte of string varibles
ESC_CH	EQU  $FE                ; escape character for special chars
BNK_SW	EQU  $3C00              ; address of bankswitch port
KEY_P	EQU  $3E00              ; address of key port
TBL_OF	EQU  $F0                ; Offset between character Tables
CHT_LSB EQU  $60                ; LSB of the character table (ROM)
CHT_MSB EQU  $40                ; MSB of the character table (ROM)

WAIT_FL EQU  $FF13              ; address of wait flag
WT_INT	EQU  $FF47              ; address of wait intervall (16 bit)
KEY_OUT EQU  $FF5E              ; output address of KEYCODE

; #########################################
; # SOUND                                 #
; # Create some noise with the beeper     #
; #                                       #
; #########################################

FREQ:   DW 0
DURAT:  DW 0
SOUND:	LIDP FREQ		; Load the freq in B,A
        LII  $01
	LP   REG_A
        MVWD

        LP   REG_L              ; L is $01 if A ^ $02 # 0
        ANIM $00
	ORMA
        ANIM $02
	EXAM
	RC
	SR
	EXAM
        LP   REG_M              ; M is $01 if A ^ $01 # 0
        ANIM $00
	ORMA
        ANIM $01
	RC			; B,A >> 2:
	EXAB
	SR			; Shift B
	EXAB
	SR			; Shift A
	EXAB
	SR			; Shift B
	EXAB
	SR			; Shift A
	LP   REG_K		; A --> K
	EXAM

	LP   REG_L		; L --> A
	LDM
	LP   REG_N		; A (L) --> N
	EXAM
	LP   REG_M		; M --> A
	LDM
	LP   REG_N		; N (L) ^ A (M) --> N
	ANMA

	LP   REG_L		; L --> A
	LDM
	LP   REG_M		; A (L) v M --> M
	ORMA

	LP   REG_K		; Restore K
	LDM

	LP   REG_L		; A + L --> L
	ADM
	LP   REG_M		; A + M --> M
	ADM
	LP   REG_N		; A + N --> N
	ADM
	; Now set the wait operation parameters
	LP   REG_K
	LDM
	LIDP CPOS1+1
	STD
	LP   REG_L
	LDM
	LIDP CPOS2+1
	STD
	LP   REG_M
	LDM
	LIDP CPOS3+1
	STD
	LP   REG_N
	LDM
	LIDP CPOS4+1
	STD

	LIDP DURAT		; Load the duration in A
	LDD
	LP   REG_I		; and move it to I
	EXAM

	; If freq < 52, go on, else do a duration liniarization
        LP   REG_K
	LDM
	CPIA 52               ; K < 52 ?
JR62S:	JRCP CHKI

	; Move content of K to M
	LP   REG_K
	LDM
	LP   REG_M
	EXAM

	LP   REG_XL		; 153 - (K >> 1) --> X
	LIA  153
	EXAM
	LP   REG_K
	LDM
	RC
	SR
	LP   REG_XL
	SBM
	INCP
	RA
	EXAM

	LP   REG_I		; I --> Y
	LDM
	LP   REG_YL
	EXAM
	INCP
	RA
	EXAM

	CALL MULT		; multiply !

	; Make a left shift of L,K and use L as result
	; This is equal to a division by 128
	LP   REG_K
	LDM
	SL
	INCP
	LDM
	SL
	LP   REG_I
	EXAM

CHKI:	LP   REG_I
	LDM
	CPIA 0			; I = 0 ?
JR63S:	JRNZP CPOS1
	INCI

CPOS1:  WAIT $00                ; 6 + Par. 1
CPOS2:  WAIT $00                ; 6 + Par. 2
        LIP  $5F                ; 4
SNDOP:  ORIM $10                ; 4
	OUTC			; 2
CPOS3:  WAIT $00                ; 6 + Par. 1
CPOS4:  WAIT $00                ; 6 + Par. 2
        ANIM $EF                ; 4
	OUTC			; 2
        TEST $02                ; 4
JR60S:	JRZM CPOS1		; 7 (taken)
	DECI			; 51 + 4*Par.
JR61S:	JRNZM CPOS1		; do the loop
	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # MULT                                  #
; # 16 bit multiplikation                 #
; #                                       #
; # input XH,XL: Factor 1                 #
; # input YH,YL: Factor 2                 #
; #                                       #
; # output K,L: Result                    #
; #########################################

MULT:   LIB  $10                ; Number of loop counts
        RA			; Initialize
        LP   REG_K		; K
        LII  $01                ; and
        FILM			; L
JR78E:	LP   REG_K		; Write #0
        LDM			; to the first bit
	RC			; of
	SL			; K
	EXAM			; The 7th bit is now in the carry
	INCP			; Write carry
	LDM			; to first bit of L
	SL			; The 7th bit is now
	EXAM			; in the carry
JR75S:	JRCP JR75E		; Jump to end, if carry = 1
	RC			; Write #0
        LP   REG_XL		; to the first bit
        LDM			; of
	SL			; XL
	EXAM			; The 7th bit is now in the carry
	INCP			; Write carry
	LDM			; to first of XH
	SL			; The 7th bit is now
	EXAM			; in the carry
JR76S:	JRNCP JR76E		; Jump if carry = 0
	RC			; Write #0 to carry
	LP   REG_YL
	LDM
	LP   REG_K		; Add
	ADM
	LP   REG_YH
	LDM			; Write the result to K
	LP   REG_L		; and L
	ADCM
JR77S:	JRCP JR75E		; Jump to end, if carry = 1
JR76E:	DECB			; B = B-1
JR78S:	JRNZM JR78E		; if B is not zero, do the loop
JR75E:	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # SOUND ON/OFF                          #
; # enables/disables sound output of the  #
; # SOUND routine                         #
; #                                       #
; # The routine has two entry points:     #
; # - SNDON: enable sound output          #
; # - SNDOF: disable sound output         #
; #########################################

SNDON:	LP   REG_XL		
        LIA  $61                ; Opcode of 'ORIM'
	EXAM
	LP   REG_XH
        LIA  $10
	EXAM
JR80S:	JRP  SNDOO
SNDOF:	LP   REG_XL		
        LIA  $60                ; Opcode of 'ANIM'
	EXAM
	LP   REG_XH
        LIA  $EF
	EXAM
SNDOO:	LP   REG_XL             ; Copy 2 bytes from registers
	LIDP SNDOP              ; to the memory location of
        LII  $01                ; of sound routine
	EXWD
	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # INITS, INITN since 1.1                #
; # Checks if a standard variable is of   #
; # string (numeric) type and initializes #
; # it otherwise. The index of the        #
; # variable (1-26) must be poked to      #
; # adress INITS+3 (INITN+3).             #
; #########################################

INITS:	LIA  26			; Convert to range 0 .. 25
        SBIA $01
        CALL VARADR		; Call number to addr. conv.
	LIB  STR_ID		; First byte of var.
	DX
	IXL			; Read first byte
	CPIA STR_ID
JR90S:	JRNZP JR90E		; Jump to erase, if no string
	RTN
INITN:	LIA  26			; Convert to range 0 .. 25
        SBIA $01
        CALL VARADR		; Call number to addr. conv.
	LIB  0			; First byte of var.
	DX
	IXL			; Read first byte
	CPIA STR_ID
JR91S:	JRNZP JR91E		; Jump to end, if no string
JR90E:  EXAB
	STD
	LII  6			; Erase 7 bytes
	IX
	RA			; 0->A
	FILD
JR91E:	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # GTEXT since 1.1                       #
; # Writes the content of a standard      #
; # variable as text without erasing the  #
; # display before. The index of the      #
; # variable (1-26) must be poked to      #
; # adress GTEXT+3. Only string variables #
; # are supported.                        #
; #                                       #
; # GTEXTI is used from the serial port   #
; # remote mode implementation            #
; #########################################

GTEXT:	LIA  26			; Convert to range 0 .. 25
        SBIA $01
GTEXTI:	CALL VARADR		; Call number to addr. conv.

	LIDP BNK_SW		; Read
	LDD			; bankswitch and
	PUSH			; push it to stack
        LIA $09                 ; ==> Bankswich
	STD			; Write new bankswitch

        LIA  $07                ; Set string size
	LP   REG_K		; and write it to K
	EXAM

	RA			; Initialize loop counter L with 0
	LP   REG_L
        EXAM

JR96E:	IXL			; Read a byte
	CPIA 0			; End of string found ?
JR95S:	JRZP JR95E		; Jump to end
	CPIA ESC_CH		; Escape character found ?
JR96S:	JRZM JR96E		; Jump to start of loop

	EXAB			; Prepare Stack for loop
	LIA  4			; "FOR Stack=4 TO 0 STEP -1"
	PUSH
	EXAB

L1S:	LIB  0			; Default table offset: 0
        TSIA $80                ; Not greater than 127 ?
JR98S:	JRZP JR98E		; Jump ahead
	LIB TBL_OF		; Offset to alternative table

; ***** Calculate table address *********
JR98E:	PUSH			; Save A (= ascii code)

	LIA  CHT_MSB		; Table address -> Y
	LP   REG_YH
	EXAM
	LIA  CHT_LSB
	LP   REG_YL
	EXAM
	
	RA			; (00 B) -> BA = Table offset 
	EXAB

	SBB			; 16 bit sub
	DECP

	POP			; (00 ascii) -> BA			
	
	ADB			; 16 bit add five times
	DECP
	ADB
	DECP
	ADB
	DECP
	ADB
	DECP
	ADB
; ***** End calculate table address *****

	EXAB

	POP			; loop counter -> B
	PUSH
	EXAB

	PUSH			; A->top of stack
	
	RA			; add loop count to address
	EXAB
	LP   REG_YL
	ADB

	DY			; Load bitmap
	IY
	LDD

	CALL GPRINC		; Call output routine

	POP			; top of stack->A
L1E:    LOOP L1S		; "NEXT Stack"

	INCL			; Increase loop counter	
	LP   REG_K		; String size
	LDM
	LP   REG_L
	CPMA 			; if loop counter < string size,
JR99S:	JRNZM JR96E		; do the loop

JR95E:	POP			; Get old
	LIDP BNK_SW		; bankswitch
	STD			; and write it
	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # KEYCODE since 1.1                     #
; # performs a non-blocking read on the   #
; # keyboard and stores the result at     #
; # address $FF5E                         #
; #########################################

KEYC:	RA			; 0->K (address)
	LP   REG_K
	EXAM
	LIB  7			; 7->B (increment)	
	LII  1			; 1->I (mask)

; ** Reading the keys from IA-port **
JR100E:	LP   REG_I
	LDM			; I->A (assert P == REG_I)
	LIP 92			; A->IA-Port
	EXAM
	OUTA
	INA			; IA-Port->A
	CPIA 0			; if != 0,
JR101S:	JRNZP JR101E		; jump to keycode calculation
	LP   REG_B		; K = K - B
	LDM
	LP   REG_K
	ADM
	DECB			; B--
	LP   REG_I		; I = I >> 1
	LDM
	SL
	EXAM
	CPIA 32			; If I != 64 (i.e. old val. != 32),
JR100S:	JRNZM JR100E		; do the loop

; ** Reseting the IA-Port **
	RA			; 0->IA-Port
	LIP 92
	EXAM
	OUTA

; ** Reading the keys from K-port **
	LIA  28			; 28->K (address)
	LP   REG_K
	EXAM
	LII  1			; 1->I (mask)
JR102E:	LP   REG_I
	LDM			; I->A (assert P == REG_I)
	LIDP KEY_P		; Address of key port
	STD
	INA			; Read port A
	CPIA 0			; if != 0,
JR103S:	JRNZP JR101E		; jump to keycode calculation
	LP   REG_K		; K = K - 8
	ADIM 8
	LP   REG_I		; I = I >> 1
	LDM
	SL
	EXAM
	CPIA 64			; If I != 128 (i.e. old val. != 64),
JR102S:	JRNZM JR102E		; do the loop

	LP   REG_K		; 255->K
        ORIM $FF
	LIA  128		; 128->A

; ** Key code calculation **
JR101E: CPIA 128		; If A == 128, jump
JR104S:	JRZP  JR104E		; to end (assert, A is never 0)
	RC
	SL			; A = A >> 1
	INCK			; K = K + 1			
JR105S:	JRM   JR101E		; do the loop

; ** Output $ end **
JR104E:	LP   REG_K		; K->A
	LDM
        LIDP KEY_OUT            ; A->($FF5E)
	STD
	RA			; 0->key port
	LIDP KEY_P
	STD
	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
	NOPW
        NOPW
        NOPW

; #########################################
; # GWAIT since 1.1                       #
; # Waits on ENTER key or delays program  #
; # execution like set with the BASIC     #
; # WAIT command; the display is turned   #
; # on                                    #
; #########################################

GWAIT:  LIDP WAIT_FL
	LDD
        TSIA $04
JR110S:	JRNZP KEYST
;        CAL04 $B8               ; Syscall $4B8: display on (POCKASM)
	CAL	$04B8		; Syscall $4B8: display on (YASM)
	LIDP WT_INT		; Copy wait intervall to K, L;
	LP   REG_K		; K is counter for inner loop,
	LII  1			; L for outer
	MVWD
	INCK
	INCL

; ** Delay 32 ms **
JR119E:	LIB  8			; 8->B (loop couter)	
JR115E: TEST $02                ; Test for 2 ms timer
JR115S:	JRZM  JR115E		; Loop on timer signal off
;JR116E: TEST $02		; Test for 2 ms timer
;JR116S: JRNZM JR116E		; Loop on timer signal on
	DECB
JR117S:	JRNZM JR115E		; do the loop

; ** Check for BREAK key
	TEST 8			; BREAK
JR118S:	JRNZP GWEND      

; ** Inner loop **
	DECK
JR119S:	JRNZM JR119E

; ** Outer loop **
	DECL
JR120S:	JRNZM JR119E

	RTN

;KEYST:  CAL20 $94               ; Syscall $1494: wait for keystroke (POCKASM)
KEYST:	CAL	$1494		; Syscall $1494: wait for keystroke (YASM)
	LIDP KEY_OUT
	LDD
	CPIA 18			; ENTER
JR112S: JRZP  GWEND
	CPIA 6			; CCE
JR113S: JRZP  GWEND	
	TEST 8			; BREAK
JR114S:	JRNZP GWEND      
JR111S:	JRM   KEYST
GWEND:	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
	NOPW
        NOPW
;	NOPW			; 7.8.2002 PUE removed, because
				; this byte is needed for the
				; serial extension availability
				; flag
;ENDPA1: