; #########################################
; # SERIAL PORT EXTENSION for             #
; # PE Tools - a toolkit to extend the    #
; # possibilities of the sharp 1403(H)    #
; # author   : Puehringer Edgar           #
; # date     : 18.12.2001                 #
; # version  : 1.1                        #
; # assembler: YASM 1.1                   #
; #########################################

	ORG $84CF		; 33999 = next free address after 
				; PE Tools part two

; commands which are not supported by YASM
PTC	EQU $7A		; Prepare table jump
DTC	EQU $69		; Do table jump, also called ETC

; addresses needed from part one of PE Tools

AB2M	EQU 32824
DISPAC	EQU 32895
GPRINI	EQU 33082
VARADR	EQU 33091
GPRINC	EQU 33038
GMODER	EQU 33238

; addresses needed from part two of PE Tools

GTEXTI	EQU 33741
 
; CPU registers

REG_I	EQU $00			; index register
REG_J	EQU $01			; index register
REG_A	EQU $02			; accumulator
REG_B	EQU $03			; accumulator
REG_XL	EQU $04			; LSB of adress pointer
REG_XH	EQU $05			; MSB of adress pointer
REG_YL	EQU $06			; LSB of adress pointer
REG_YH	EQU $07			; MSB of adress pointer
REG_K	EQU $08			; counter
REG_L	EQU $09			; counter
REG_M	EQU $0A			; counter
REG_N	EQU $0B			; counter

TBUF_L	EQU $5F			; LSB of print text buffer address
TBUF_H	EQU $FD			; LSB of print text buffer address
TBUF	EQU $FD60		; address of print text buffer

STR_ID	EQU $F5			; first byte of string varibles

SPTR	EQU $FF01		; basic program start pointer
EPTR	EQU $FF03		; basic program end pointer
VARPTR	EQU $FF2E		; address of least referenced
				; variable
BANKSW	EQU $3C00		; address of bankswitch hardware

; #########################################
; # SAVAIL since 1.1                      #
; # serial extension availability flag    #
; # if 0 -> serial port ext. not avail.   #
; # if 1 -> serial port ext. available    #
; #########################################

SAVAIL:	DB	$01		; available !

; #########################################
; # REMOTE since 1.1                      #
; # Starts the serial remote mode. A      #
; # prompt is displayed one a connected   #
; # terminal.                             #
; #                                       #
; # Side effects of this procedure:       #
; #  - GMODE "replace" is called          #
; #  - Std. var. M is used                #
; #########################################

REMOTE:	CALL	REMOTI
	RTN

; #########################################
; # SPRINT since 1.1                      #
; # Prints the print text buffer to the   #
; # serial port                           #
; #########################################

SPRINT:	CALL	SPRNTI
	RTN

; #########################################
; # SPRNTN since 1.1                      #
; # Prints the print text buffer to the   #
; # serial port; after this, a lf or a    #
; # cr-lf is sent. Which line end         #
; # character is used depends on the      #
; # setting of function CRLF              #
; #########################################

SPRNTN:	CALL	SPRNTI
	NOPW

; #########################################
; # CRLF since 1.1                        #
; # Prints a lf or a cr-lf to the serial  #
; # port                                  #
; #                                       #
; # If you want to use lf:                #
; #   Poke $0A to address CRLF+1          #
; # If you want to use cr-lf:             #
; #   Poke $0D to address CRLF+1          #
; #########################################

CRLF:	LIA	$0D
	JRP	CRLFI

; #########################################
; # CTRLZ since 1.1                       #
; # Prints a Ctrl-Z to the serial port    #
; #########################################

CTRLZ:	LIA	$1A
	JRP	SENDC

; #########################################
; # SINPUT since 1.1                      #
; # Reads from serial port and stores the #
; # result into the least refenced field  #
; # variable                              #
; #########################################

SINPUT:	CALL	SINPTI
	RTN

; #########################################
; # LLIST since 1.1                       #
; # Writes the basic listing to the       #
; # serial port.                          #
; # Note: The tokens must be decoded on   #
; # the host system                       #
; #########################################

LLIST:	CALL	LLISTI
	RTN

; #########################################
; # SLOAD since 1.1                       #
; # Reads a basic listing from the serial #
; # port and stores it into the RAM. An   #
; # existing program is replaced.         #            
; # Note: The tokens must be decoded on   #
; # the host system                       #
; #########################################

SLOAD:	CALL	SLOADI
	RTN

; #########################################
; # SMERGE since 1.1                      #
; # Reads a basic listing from the serial #
; # port and stores it into the RAM. The  #
; # program is merged to the existing     #
; # program.                              #
; # Note: The tokens must be decoded on   #
; # the host system                       #
; #########################################

SMERGE:	CALL	SMERGI
	RTN

; #########################################
; # Data section for the remote mode      #
; # symbol/text                           #
; #########################################

REMSY1:	DB	STR_ID
	DB	$33		; "3"
	DB	$45		; "E"
	DB	$34		; "4"
	DB	$31		; "1"
	DB	$35		; "5"
	DB	$35		; "5"
	DB	$00		; End of string

SY1_LSB EQU	$F4		; LSB of remote symbol 1
SY1_MSB EQU	$84		; MSB of remote symbol 1

REMSY2:	DB	STR_ID
	DB	$32		; "2"
	DB	$32		; "2"
	DB	$31		; "1"
	DB	$43		; "C"
	DB	$00		; End of string
	DB	$00		; End of string
	DB	$00		; End of string

SY2_LSB EQU	$FC		; LSB of remote symbol 2
SY2_MSB EQU	$84		; MSB of remote symbol 2

REMTX1:	DB	STR_ID
	DB	$20		; " "
	DB	$52		; "R"
	DB	$45		; "E"
	DB	$4D		; "M"
	DB	$4F		; "O"
	DB	$54		; "T"
	DB	$00		; End of string

TX1_LSB EQU	$04		; LSB of remote text 1
TX1_MSB EQU	$85		; MSB of remote text 1

REMTX2:	DB	STR_ID
	DB	$45		; "E"
	DB	$20		; " "
	DB	$4D		; "M"
	DB	$4F		; "O"
	DB	$44		; "D"
	DB	$45		; "E"
	DB	$00		; End of string

TX2_LSB EQU	$0C		; LSB of remote text 2
TX2_MSB EQU	$85		; MSB of remote text 2

; #########################################
; # Implementation of                     #
; # SPRINT, SPRNTN, CRLF and CTRLZ        #
; #########################################

SPRNTI: LIA	TBUF_L		; X = address of print
	LP	REG_XL		; text buffer
	EXAM
	LIA	TBUF_H
	LP REG_XH
	EXAM

LOOP3:	IXL			; Read byte
	CPIA	$0D		; If byte = 13 then
	JRNZP	CONT2		; return
	RTN

CONT2:	CALL	SENDC
	JRM	LOOP3

CRLFI:	CPIA	$0A		; If A = line feed, then
	JRZP	SENDC		; send the character imediatly

; Assert that A = $0D (charage return)	
	CALL	SENDC		; Send character	
	LIA	$0A		; A = line leed

SENDC:	LIP	$5F		; Set P to control byte for Xin
        ORIM	$50		; Set Xin active and Xout (DTR) to
	OUTC			; ready state

LOOP1:	TEST	$88		; Not clear to send or break pressed ?
	JRZM	LOOP1		; Loop until CTS or break
	LII	$08		; I = 8 (bit counter)
	LIP	$5E		; Set P to data byte for port F
        ORIM	$04             ; Set bit 3 and write it
	OUTF			; to pin 4 (TXD)		3
	WAIT	$0C		; Delay start bit 4800 bd	6+13

LOOP2:	SR			; Shift bit into carry		2
	JRNCP	LOW		; Jump if bit is low		4 (taken)
        ANIM    $FB             ; Clear bit 3			4
	WAIT	$04		; Smaller delay to respect jump	6+4

CONT1:	OUTF			; Write to pin 4 (TXD)		3
	WAIT	$0C		; Delay start bit 4800 bd	6+13
	DECI			; Dec. bit counter		4
	JRNZM	LOOP2		; Loop if bits left		4 (taken)
	ANIM	$FB		; Clear bit 3
	WAIT	$0D		; Delay stop bit 4800 bd
	OUTF			; Write to pin 4 (TXD)
	LIP	$5F
	ANIM	$AF		; Reset Xout (DTR)
	OUTC
	RTN

LOW:	ORIM	$04		; Set bit 3
	JRM	CONT1		; and jump back

; #########################################
; # Implementation of SINPUT              #
; #########################################

SINPTI:	LIDP	VARPTR		; Y = address of least
	LP REG_YL		; referenced variable
	MVBD
	DY			; First byte is the length
	IY			; copy it to K
	LP REG_K
	MVMD
	CALL	SINTRD		; Read string
	INCK
	DECK
	JRZP	CONT20		; If space available,
	RA			; write trailing zero
	IYS
CONT20:	RTN

SINTRD:	DECK			; Dec. K to detect overlength
	LIP	$5F		; Set P to control byte for Xin
	ORIM	$10		; Set bit 5 (Xout, DTR)
	OUTC
LOOP6:	LII	$08		; I = 8 (bit counter)
	TEST	$08		; If Break is pressed,
	JRNZP	CONT3		; jump ahead
LOOP4:	INB			; Read Port B			3
	SL			; Shift into carry		2
	JRCM	LOOP4		; Loop if no start bit detected 4/7
CONT3:	WAIT	$09		; Delay start bit 4800 bd	6+9
LOOP5:	WAIT	$1D		; Delay data bit 4800 bd	6+29
	INB			; Read data bit from port B	3
	SL			; Shift into carry		2
	EXAB			; A <=> B			3
	SR			; Shift carry into A		2
	EXAB			; A <=> B			3
	DECI			; Dec. bit counter		4
	JRNZM	LOOP5		; Loop if bits left		7 (taken)
	EXAB			; A <=> B			3
	IYS			; Store byte			6
	CPIA	$0D		; If end of line reached,	4
	JRZP	CONT4		; jump ahead			7/4
	DECK			; Dec. length counter		4
	JRNZM	LOOP6		; Jump if space available	4/7
CONT4:	LIP	$5F		; Reset bit 5 in
	ANIM	$EF		; control port
	OUTC			; and write it
	RTN

; #########################################
; # Implementation of LLIST               #
; #########################################

LLISTI: LIDP	SPTR		; Load X with content of basic
	LP	REG_XL		; start pointer
	MVBD
LOOP10:	LII	$07		; I is counter for 7 bits
	RA			; 0 => A
	LP	REG_L		; Clear internal RAM from L to $10
	FILM			; The BCD buffer is $0E $0F $10
	IXL			; Get first Byte
	CPIA	$FF		; If program end, then
	JRZM	CTRLZ		; jump to CTRLZ and return
	EXAB			; A <=> B
LOOP7:	DECB			; B-1 => B
	JRCP	CONT5		; If end of loop, jump ahead
	LIA	$56		; $56 => A
	LP	$10		; Last position of BCD buffer => P
	ADN			; BCD add $56 B times
	LIA	$02		; 2 => A
	LP	$0F		; Last position-1 of BCD buffer => P
	ADN			; BCD add = add 200
	JRM	LOOP7		; Loop jump
CONT5:	IXL			; Load low byte of line number
	EXAB			; A <=> B
LOOP8:	DECB			; B-1 => B
	JRCP	CONT6		; If end of loop, jump ahead
	LIA	$01		; 1 => A
	LP	$10		; Last position of BCD buffer => P
	ADN			; BCD add 1 B times
	JRM	LOOP8		; Loop jump
CONT6:	LP	REG_K		; 5 => K; counter for max. 5 BCD
	LIA	$05		; digits
	EXAM
LOOP9:	INCL			; Set L (Flag for leading zeros)
	RA			; 0 => A
	LP	$0E		; First position of BCD buffer => A
	EXAM
	ADIA	$30		; Add ASCII offset
	DECL			; L-1 => L; If L != 0 (no leading
	JRNZP	CONT18		; zero), jump ahead
	CPIA	$30		; If ASCII-"0", jump ahead
	JRZP	CONT7
	INCL			; Inc. L, so it will never be zero
CONT18:	CALL	SENDC		; Write character to serial port
CONT7:	LII	$02		; Shift the three byte long BCD buffer
	LP	$10		; on nibble to the left
	SLW
	DECK			; K-1 => K
	JRNZM	LOOP9		; Loop until last BCD digit written
	IX			; Skip line length byte
	LIA	$20		; ASCII-blank => A

LOOP11:	CPIA	$0D		; If character is not end-of-line,
	JRNZP	CONT8		; then jump ahead
	CALL	CRLF		; Call the line feed subprogram
	JRM	LOOP10		; Loop (next line)
CONT8:	PUSH			; A => stack
	CALL	SENDC		; Write the character to serial port
	POP			; stack => A
	IXL			; Load next byte
	JRM	LOOP11		; Loop (next byte)

;LOOP11:	PUSH			; A => stack
;	CALL	SENDC		; Write the character to serial port
;	POP			; stack => A
;	CPIA	$0D		; If character is not end-of-line,
;	JRNZP	CONT8		; then jump ahead
;	CALL	CRLF		; Call the line feed subprogram
;	JRM	LOOP10		; Loop (next line)
;CONT8:	IXL			; Load next byte
;	JRM	LOOP11		; Loop (next byte)

; #########################################
; # Implementation of SMERGE/SLOAD        #
; #########################################

SLOADI: CALL	READTB		; read a line into the text buffer

	LIDP	SPTR		; basic start pointer -> DP
	LP	REG_YL		; -> Y
	MVBD			; (J is allways 1)

	JRP	CONT15

SMERGI:	CALL	READTB		; read a line into the text buffer

	LIDP	EPTR		; basic end pointer -> DP
	LP	REG_YL		; -> Y
	MVBD			; (J is allways 1)
	DY			; Y--

CONT15:	LIA	TBUF_H		; address of text buffer -> X
	LP	REG_XH
	EXAM
	LIA	TBUF_L+1
	LP	REG_XL
	EXAM

	LII	$0F		; 0 -> K ... intram($18)
	RA
	LP	REG_K
	FILM

CONT13:	IXL			; read first byte
	CPIA	$0A		; if first byte is a line feed (from
	JRZM	CONT13		; last line), the skip it
	SBIA	$30		; subtract ASCII offset
	JRCP	CONT10		; if not a number, jump to end
	CPIA	$10		; >= $10 ?
	JRNCP	CONT10		; if not a number, jump to end
	LP	$10		; first byte -> intram($10)
	EXAM

CONT12:	IXL			; read next byte
	CPIA	$40		; if not a number, jump ahead
	JRNCP	CONT11
	CPIA	$30		; if not a number, jump ahead
	JRCP	CONT11
	SBIA	$30		; subtract ASCII offset
	PUSH			; save byte on stack

	LP	REG_A		; intram($11,$10) -> (B,A)
	LIQ	$10
	MVB
	
	LII	$09		; I = 9
LOOP12:	LP	$10
	ADB			; intram($11,$10)+(B,A)->intram($11,$10)
	DECI			; I++
	JRNZM	LOOP12		; 10 times add equals multiply by 10

	LIB	$00		; 0 -> B
	POP			; fetch byte from stack
	LP	$10
	ADB			; add the lower byte
	JRM	CONT12		; jump to read next byte
		
CONT11:	LP	$11		; intram($11) -> A (hibyte line num)
	EXAM
	IYS			; and store it

	LP	$10		; intram($10) -> A (lobyte line num)
	EXAM
	IYS			; and store it
	
	IY			; Y++ (skip line length byte)
	
	LIDP	SELFMN+1	; Y -> ram(SELFMN+2,SELFMN+1)
	LP	REG_YH		; Buffer for line length
	MVDM			; WARNING: this is self manipulating
	LIDP	SELFMN+2	; code !
	LP	REG_YL
	MVDM

LOOP13:	IXL			; read byte
	CPIA	$0D		; if end of line, jump ahead
	JRZP	CONT14
	CPIA	$0A
	JRZP	CONT14
	CPIA	$20		; skip blanks
	JRZM	LOOP13

; <<<< assert now A contains a char that should be written >>>>

	CPIA	$22		; quote character ?
	JRNZP	CONT17		; Yes -> read whole string
LOOP14:	IYS
	INCK
	IXL
	CPIA	$0D
	JRZP	CONT14
	CPIA	$0A
	JRZP	CONT14
	CPIA	$22		; check for string end	
	JRNZM	LOOP14

CONT17:	IYS			; store it
	INCK			; K++ (length counter)
	JRM	LOOP13

CONT14:	LIA	$0D		; could be $0A, so replace with $0D
	IYS			; store it
	INCK			; K++ (length counter)
	
SELFMN:	LIDP	$FFFF		; $FFFF will be replaced by the lengthattr
	LP	REG_K		; K -> ram(lengthattr)
	MVDM
	
	LIA	$FF		; store end mark
	IYS

	LIDP	EPTR		; basic end pointer -> DP
	LP	REG_YL
	EXBD

	TEST	$08		; break pressed ?
	JRZM	SMERGI		; if not, parse next line

CONT10:	RTN			; return to calling program

; <<<< Subroutine read line into text buffer >>>>

READTB:	LIA	TBUF_H		; address of text buffer -> Y
	LP	REG_YH
	EXAM
	LIA	TBUF_L+1
	LP	REG_YL
	EXAM

	LIA	$50		; 80 -> K
	LP	REG_K
	EXAM

	CALL	SINTRD		; read a line
	JRNCP	CONT9		; carry set -> line to long
	LIA	$0D		; carriage return on last char
	STD
CONT9:	RTN

; #########################################
; # Implementation of REMOTE              #
; #########################################

QUITI:	POP
	POP
	RTN

VERI:	LIA	$31		; Character 1
	CALL	SENDC
	LIA	$31		; Character 1
	CALL	SENDC
	CALL	CRLF
	RTN

REMOTI:	CALL	GMODER		; Set graphics mode "replace"
	LIA	SY1_LSB		; LSB of remote symbol 1
	LIB	SY1_MSB		; MSB of remote symbol 1
	CALL	AB2M		; Copy memory location to std. var. M
	LIA	$0D		; 13, offset std. var. A to M
	CALL	GPRINI		; Graphics print
	LIA	SY2_LSB		; LSB of remote symbol 2
	LIB	SY2_MSB		; MSB of remote symbol 2
	CALL	AB2M		; Copy memory location to std. var. M
	LIA	$0D		; 13, offset std. var. A to M
	CALL	GPRINI		; Graphics print
	LIA	TX1_LSB		; LSB of remote text 1
	LIB	TX1_MSB		; MSB of remote text 1
	CALL	AB2M		; Copy memory location to std. var. M
	LIA	$0D		; 13, offset std. var. A to M
	CALL	GTEXTI		; Text print
	LIA	TX2_LSB		; LSB of remote text 2
	LIB	TX2_MSB		; MSB of remote text 2
	CALL	AB2M		; Copy memory location to std. var. M
	LIA	$0D		; 13, offset std. var. A to M
	CALL	GTEXTI		; Text print
;	CAL04	$B8		; Syscall $4B8: display on (PockASM)
	CAL	$04B8		; Syscall $4B8: display on (YASM)
CONT16:	LIA	$3E		; The prompt  (>)
	CALL	SENDC
	CALL	READTB		; read a cmd line into text buffer
	TEST	$08		; break pressed ?
	JRNZP	CONT19		; if yes, jump to end
	CALL	CRLF		; crlf to separate prompt from output
	LIDP	TBUF+1		; (TBUF) -> A
	LDD
	DB	PTC		; PTC 5, CONT16
	DB	$05
	DW	CONT16
	DB	DTC		; DTC
	DB	$4C		; Character L = LOAD
	DW	SLOADI
	DB	$4D		; Character M = MERGE
	DW	SMERGI
	DB	$51		; Caharcter Q = QUIT
	DW	QUITI	
	DB	$53		; Character S = SAVE (LLIST)
	DW	LLISTI
	DB	$56		; Character V = (show) VERSION
	DW	VERI
	DW	CONT9		; Just a dummy return as default
CONT19:	RTN

	NOPW			; remove this after end of
	NOPW			; test phase
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	NOPW
	