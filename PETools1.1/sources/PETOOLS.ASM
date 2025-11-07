; #########################################
; # PE Tools - a toolkit to extend the    #
; # possibilities of the sharp 1403(H)    #
; # author   : Puehringer Edgar           #
; # date     : 22.03.2001                 #
; # version  : 1.1                        #
; # assembler: YASM 1.1                   #
; # changes  : FLASH now respects BREAK   #
; #            new routine VARADR         #
; #            enhanced performance on    #
; #            GPRINTF                    #
; #########################################

        ORG  $8030              ; 32816 = Start address of basic memory

; CPU registers

REG_I	EQU  $00                ; index register
REG_J	EQU  $01                ; index register
REG_A	EQU  $02                ; accumulator
REG_B	EQU  $03                ; accumulator
REG_XL	EQU  $04                ; LSB of adress pointer
REG_XH	EQU  $05                ; MSB of adress pointer
REG_YL	EQU  $06                ; LSB of adress pointer
REG_YH	EQU  $07                ; MSB of adress pointer
REG_K	EQU  $08                ; counter
REG_L	EQU  $09                ; counter
REG_M	EQU  $0A                ; counter
REG_N	EQU  $0B                ; counter

CAL_W	EQU  $FFE8              ; Memory location of the CAL-mode memory (x>M)
CAL_LSB EQU  $E8                ; LSB of the CAL-mode memory (x>M)
CAL_MSB EQU  $FF                ; MSB of the CAL-mode memory (x>M)

SV_Z	EQU  $FB10              ; Memory locations of the
SV_Z_L	EQU  $10                ; standard variables Z to A
SV_Y	EQU  $FB18
SV_X	EQU  $FB20
SV_W	EQU  $FB28
SV_V	EQU  $FB30
SV_U	EQU  $FB38
SV_T	EQU  $FB40
SV_S	EQU  $FB48
SV_R	EQU  $FB50
SV_Q	EQU  $FB58
SV_P	EQU  $FB60
SV_O	EQU  $FB68
SV_N	EQU  $FB70
SV_M	EQU  $FB78
SV_M_L	EQU  $78                ; LSB of M
SV_L	EQU  $FB80
SV_K	EQU  $FB88
SV_J	EQU  $FB90
SV_I	EQU  $FB98
SV_H	EQU  $FBA0
SV_G	EQU  $FBA8
SV_F	EQU  $FBB0
SV_E	EQU  $FBB8
SV_D	EQU  $FBC0
SV_C	EQU  $FBC8
SV_B	EQU  $FBD0
SV_A	EQU  $FBD8
SPTR_L	EQU  $FF01              ; LSB of basic program start pointer
SPTR_M	EQU  $FF02              ; MSB of basic program start pointer
EPTR_L	EQU  $FF03              ; LSB of basic program end pointer
EPTR_M	EQU  $FF04              ; MSB of basic program end pointer

SV_MSB	EQU  $FB                ; MSB of all standard variables

LCD_LEF EQU  $00                ; LSB display base address, left half
LCD_RIG EQU  $40                ; LSB display base address, right half
LCD_MSB EQU  $30                ; MSB of all display locations

; ROM routines

LCD_OFF EQU  $04B4              ; Turn LCD display off
LCD_ON	EQU  $04B8              ; Turn LCD display on

        DW   $080F              ; Magic number to identify PE tools
        DB   $01                ; Version number
        DB   $0A                ; Revision number

; #########################################
; # CAL to M                              #
; # Store the content of the CAL-mode     #
; # memory (x>M) into variable M          #
; #                                       #
; # AB2M is used from the serial port     #
; # remote mode implementation            #
; #########################################

C2M:    LIA  CAL_LSB		; LSB from CAL-mode memory
        LIB  CAL_MSB		; MSB from CAL-mode memory
AB2M:	LP   $10
        LII  $07                ; Copy eight bytes
	DATA			; (BA) in P-register
        LP   $10
        LIDP SV_M		; Adress from M
        EXWD
        RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # M to CAL                              #
; # Store the content of the variable M   #
; # into CAL-mode memory (x>M)            #
; # WARNING: If M is used as string       #
; # variable (M$) there will be random    #
; # results in the CAL-mode memory        #
; #########################################

M2C:    LIA  SV_M_L		; LSB from M
        LIB  SV_MSB		; MSB from M
        LP   $10
        LII  $07                ; Copy eight bytes
	DATA			; (BA) in P-register
        LP   $10
        LIDP CAL_W		; Adress from CAL-mode memory
        EXWD
        RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # FLASH mod 1.1                         #
; # Flashes the display n times           #
; # The routine has two entry points:     #
; # - FLASH : use default flash count     #
; # - FLASHC: use custom flash count,     #
; #           this can be poked to adress #
; #           FLASHC+1                    #
; #########################################

FLASHC: LIA  $0A                ; Flash count
JR1S:   JRP  JR1E		; Jump over default flash count
FLASH:  LIA  $0A                ; Flash count
JR1E:	PUSH			; "FOR Stack1=10 TO 0 STEP -1"
L1S:    TEST 8			; Check for break-key
JR2S:	JRNZP L1E		; If pressed: count loop fast!
        CALL LCD_ON		; Turn LCD on (ROM-routine) 
        LIA  $FF                ; "FOR Stack2=255 TO 0 STEP -1"
        PUSH
L2S:    WAIT $FF                ; Wait 255 cycles
L2E:    LOOP L2S		; "NEXT Stack2"
        CALL LCD_OFF		; Turn LCD off (ROM-routine) 
        LIA  $FF                ; "FOR Stack2=255 TO 0 STEP -1"
        PUSH
L3S:    WAIT $FF                ; Wait 255 cycles
L3E:    LOOP L3S		; "NEXT Stack2"
L1E:    LOOP L1S		; "NEXT Stack1"
        RTN
	NOPW			; Reserve instruction for
				; future releases

; #########################################
; # DISPADR                               #
; # Calculates the display adress of a    #
; # given horicontal location             #
; # The routine has two entry points:     #
; # - DISPAC: use horizontal position     #
; #           store in the B register     #
; # - DISPAD: use horizontal position     #
; #           poked to adress DISPAD+1    #
; #                                       #
; # The result is stored at position      #
; # DISPAD+1 and in the B register        #
; #                                       #
; # Positions that are to big to fit in   #
; # the display return the adress of the  #
; # most right display column             #
; #########################################

DISPAD: LIB  $10
DISPAC:	LP   REG_B		; Copy B to A
		LDM
        CPIA 60			; Char 1-12 ?
JR10S:	JRCP JR10E		; Jump to positive offset calculation

; Calculate negative offsets

        CPIA 120		; Valid char range ( < 25) ?
JR11S:	JRCP JR11E
        LIB  $B7                ; default: most right x position
        LIA  119
JR12S:  JRP  C10		; "break"
JR11E:  CPIA 90			; If not char 19-24, jump ahead
JR13S:	JRCP JR13E
        LIB  $B7                ; LSB is $B7 - REG_A
JR14S:  JRP  C10		; "break"
JR13E:  CPIA 75			; If not char 16-18, jump ahead
JR15S:	JRCP JR15E
        LIB  $C6                ; LSB is &C6 - REG_A
JR16S:  JRP  C10		; "break"
; Assert char position is in the range 13-15 
JR15E:  LIB  $A8                ; LSB is $A8 - REG_A

C10:    LP   REG_B
	RC
        SBM

JR17S:  JRP  C11		; Jump over positive offset calculation

; Calculate positive offsets

JR10E:  CPIA 45			; If not char 10-12, jump ahead
JR18S:	JRCP JR18E
        LP   REG_B      ; LSB is REG_B - $0F
        SBIM $0F              
JR19S:  JRP  C11		; "break"
JR18E:	CPIA 30			; If not char 7-9, jump ahead
JR20S:	JRCP JR20E
        LP   REG_B              ; LSB is REG_B + $0F
        ADIM $0F              
JR21S:  JRP  C11		; "break"
; Assert char position is in the range 1-6 
JR20E:				; LSB is REG_B - do nothing !

; Write result to memory

C11:	LP   REG_B		; Copy B to A
	LDM
	LIDP DISPAD+1		; Target adress
	STD

        RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # GCURSOR                               #
; # This memory location is used to poke  #
; # the graphics cursor position used     #
; # by the next GPRINT call               #
; #########################################

GCURS:  DB   $00                ; The graphics cursor position
BMAP:   DB   $00                ; Bitmap for a specified cursor position
FSTA:   DB   $00                ; Start of fill range for GFILL
FEND:	DB   120		; End of fill range for GFILL
DWAIT:	DB   60			; Default WAIT period
        DW   $0000		; Reserve instructions for
				; future releases
; #########################################
; # POINT                                 #
; # Returns the bitmap of the specified   #
; # display loacation                     #
; # input : poke it to POINT+1            #
; # output: peek it from BMAP             #
; #########################################

POINT:  LIB  $00
	CALL DISPAC
	LIA  LCD_MSB		; Copy high byte of display
	LP   REG_XH		; adress to MSB of X
	EXAM
	LP   REG_B		; Copy low byte of display
	LDM			; adress+1 to LSB of X
	INCA
        LP   REG_XL
        EXAM
	DXL			; Read display adress
	LIDP BMAP		; Target adress
	STD
        RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

	NOPW			; This extra istructions are
	NOPW			; to reach the adress 33000, which
	NOPW			; can be remembered easily by humans
	NOPW

; #########################################
; # RENEW                                 #
; # A "undo" for the NEW-command. Don't   #
; # use it if you haven't used new or     #
; # your sharp may crash.                 #
; #########################################

RENEW:  LIP  $04                ; Write adress from program start to
	LIDP SPTR_L		; X register, adress from program end
        LII  $03                ; to Y register
	MVWD
	DY			; Y=Y-1
        LIA  $00                ; Put zero behind program start
	IYS
JR30E:	IXL			; Search for 13 (end of line)
        CPIA $0D                ; end of line found ?
JR30S:	JRNZM JR30E		; No: continue search
        IXL                     ; Yes: is following byte $FF ?
        CPIA $FF
JR31S:	JRNZM JR30E		; No: continue search
	LIDP EPTR_L		; Yes: Set program end pointer to
        LIP  $04                ; found adress
        LII  $01
        EXWD
        RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # GPRINT                                #
; # Writes the specified bitmap to the    #
; # display loacation given by GCURS      #
; #                                       #
; # The routine has two entry points:     #
; # - GPRINC: use bitmap stored in the    #
; #           A register                  #
; # - GPRINT: use bitmap poked to adress  #
; #           GPRINT+1                    #
; #                                       #
; # The new cursor position is stored at  #
; # position GCURS and in the A register  #
; #########################################

GPRINT: LIA  $00
GPRINC:	LP   REG_M		; Copy A to M
	EXAM             ; A<->(P)
	LIDP GCURS		; Target adress
	LDD
	EXAB			; Cursor position now in B
	LP   REG_B		; Copy B to A
	LDM
	INCA
	STD			; Store increased cursor position
	LP   REG_N		; Copy A to N
        EXAM
	CALL DISPAC
	LIA  LCD_MSB		; Copy high byte of display
	LP   REG_YH		; adress to MSB of Y
	EXAM
	LP   REG_B		; Copy low byte of display
	LDM			; adress+1 to LSB of Y
	INCA
        LP   REG_YL
        EXAM
	DY			; Set DP register to display adress
	LP   REG_M		; Copy M to A
	LDD			; Load old pixel val
	CALL BITBLT
	STD			; Write new pixel val to display
	LP   REG_N		; Copy N to A
        LDM
        RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # GPRINTS                               #
; # Writes the content of a standard      #
; # variable. The index of the variable   #
; # (1-26) must be poked to adress        #
; # GPRINS+3. The standard variable       #
; # should contain hexadezimal digits,    #
; # e.g. "7F7F7F" to fill three full      #
; # columns. Don't use lowercase chars!   #
; #                                       #
; # GPRINI is used from the serial port   #
; # remote mode implementation            #
; #########################################

GPRINS:	LIA  26			; Convert to range 0 .. 25
        SBIA $01
GPRINI: CALL VARADR		; Call number to addr. conv.
        LIA  $06                ; Set string size
	LP   REG_K		; and write it to K
	EXAM
JR35S:	JRP JR35E		; Jump into GPRINTF routine

; #########################################
; # VARADR since 1.1                      #
; # Calculates the address of a standard  #
; # variable                              #
; #                                       #
; # input A: the index of the std. var.,  #
; #          where A=25 ... Z=0           #
; #                                       #
; # output X: result                      #
; #########################################

VARADR: RC			; Multiply with eight
	SL
	SL
	SL
	ADIA SV_Z_L		; Add offset 
        LP   REG_XL		; Write adress of std. var. to X
        EXAM
	LIA  SV_MSB
        LP   REG_XH
        EXAM
	RTN
	NOPW			; Reserve instruction for
				; future releases

; #########################################
; # GPRINTF                               #
; # Writes the content of a field         #
; # variable. The adress of the variable  #
; # must be poked to adress FVAR          #
; # The field variable (string)           #
; # should contain hexadezimal digits,    #
; # e.g. "7F7F7F7F" to fill four full     #
; # columns. Don't use lowercase chars!   #
; #########################################

FVAR:	DW   0			; Adress of field variable

GPRINF:	LP   REG_XL		; Write adress from field
	LIDP FVAR		; variable to X register
        LII  $01 
	MVWD
	LP   REG_XL
        LIB  $00
        LIA  $05
	ADB
	IXL			; Read string size
	RC			; Divide with two, cause two
	SR			; chars give one byte
	LP   REG_K		; and write it to K
	EXAM
JR35E:	LIA  0			; initialize loop counter L
	LP   REG_L
	EXAM
JR46E:	IXL			; Read MSB
        CPIA $00                ; end of string found ?
JR45S:	JRZP JR45E		; Jump to end
	CALL ASCBIN		
	SWP			; Move to high nibble
	EXAB
	IXL			; Read LSB
	CALL ASCBIN
	LP   REG_B
	ORMA
	LDM
	CALL GPRINC
	INCL			; Increase loop counter	
	LP   REG_K		; String size
	LDM
	LP   REG_L
	CPMA			; if loop counter < string size,
JR46S:	JRNZM JR46E		; do the loop
JR45E:	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW
        NOPW
        NOPW
        NOPW

; #########################################
; # ASC2BIN                               #
; #########################################

ASCBIN: CPIA $41                ; ASCII code < 'A' ?
JR40S:	JRCP JR40E
        SBIA $37                ; subtract 'A', add 10
	RTN
JR40E:  SBIA $30                ; subtract '0'
        RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # BITBLT                                #
; # Performs a bitblt operation           #
; #                                       #
; # input A: old pixel value              #
; # input M: new pixel value              #
; #                                       #
; # output A: result                      #
; #                                       #
; # temp B,I,one byte on the stack        #
; #########################################

BITBLT:	LP   REG_I		; \
	EXAM			; - old value in I
	LP   REG_M		; \
	LDM			; - new value in A
        LIB  $FF                ; \
	LP   REG_B		;  \ 
	SBM			;  / invert A
	EXAB			; /
	LP   REG_J		; \
	EXAM			; - inverted new value in J
	PUSH			; - push old value of J
	LP   REG_I		; \
	LDM			;  \
	LP   REG_M		;  / I --> M
	EXAM			; /
	LP   REG_J		; \
	LDM			; - J --> A
	LP   REG_M		; \
	ANMA			; - M (I) and A (J) --> M
	LP   REG_I		; \
	LDM			; - I --> A
        LIB  $FF                ; \
	LP   REG_B		;  \ 
	SBM			;  / invert A
	EXAB			; /
	LP   REG_I		; \
	EXAM			; - A --> I
	LP   REG_J		; \
	LDM			; - J --> A
        LIB  $FF                ; \
	LP   REG_B		;  \ 
	SBM			;  / invert A
	EXAB			; /
	LP   REG_J		; \
	EXAM			; - A --> J
	LP   REG_I		; \
	LDM			;  | I --> B
	EXAB			; /
	LP   REG_J		; \
	LDM			; - J --> A
	LP   REG_B		; \
	ANMA			; - B (I) and A (J) --> B
	POP			; pop old value of J
	LP   REG_J		; and store it
	EXAM			; to J
	EXAB			; - B --> A
	LP   REG_M		; \
	ORMA			; - M or A (B) --> M
	EXAM			; - M --> A
	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # GMODE                                 #
; # Switches the bitblt mode              #
; #                                       #
; # The routine has four entry points:    #
; # - GMODER: replace mode                #
; # - GMODEP: paint (or) mode             #
; # - GMODEI: invert (xor) mode           #
; # - GMODEM: mask (and) mode             #
; #                                       #
; # The cursor position stored at         #
; # position GCURS is set to zero, also   #
; # the BMAP byte used by GFILL and       #
; # GPRINT                                #
; #                                       #
; # WARNING: This routine changes the     #
; # code in routine BITBLT, if you        #
; # change BITBLT, you must also change   #
; # this                                  #
; #########################################

GMODER:	LP   REG_XL		
        LIA  $8A                ; Opcode of 'LP   REG_M'
	EXAM
	LP   REG_XH
        LIA  $59                ; Opcode of 'LDM'
	EXAM
	LP   REG_YL
        LIA  $37                ; Opcode of 'RTN'
	EXAM
GMODE1:	JRP  GMODE
GMODEP:	LP   REG_XL		
        LIA  $8A                ; Opcode of 'LP   REG_M'
	EXAM
	LP   REG_XH
        LIA  $47                ; Opcode of 'ORMA'
	EXAM
	LP   REG_YL
        LIA  $DB                ; Opcode of 'EXAM'
	EXAM
	LP   REG_YH
        LIA  $37                ; Opcode of 'RTN'
	EXAM
GMODE2:	JRP  GMODE
GMODEI:	LP   REG_XL		
        LIA  $80                ; Opcode of 'LP   REG_I'
	EXAM
	LP   REG_XH
        LIA  $DB                ; Opcode of 'EXAM'
	EXAM
	LP   REG_YL
        LIA  $8A                ; Opcode of 'LP   REG_M'
	EXAM
	LP   REG_YH
        LIA  $59                ; Opcode of 'LDM'
	EXAM
GMODE3:	JRP  GMODE
GMODEM:	LP   REG_XL		
        LIA  $8A                ; Opcode of 'LP   REG_M'
	EXAM
	LP   REG_XH
        LIA  $46                ; Opcode of 'ANMA'
	EXAM
	LP   REG_YL
        LIA  $DB                ; Opcode of 'EXAM'
	EXAM
	LP   REG_YH
        LIA  $37                ; Opcode of 'RTN'
	EXAM
GMODE:	LP   REG_XL		; Copy 4 bytes from registers
	LIDP BITBLT		; to the memory location of
        LII  $03                ; BITBLT
	EXWD
	RA			; 0 --> A
	LIDP GCURS		; erase the memory location of
        LII  $02                ; GCURS, BMAP and FSTA
	FILD
	LIA  120		; set default fill end
	LIDP FEND
	STD
	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW
	
; #########################################
; # GFILL                                 #
; # Writes the content of a field         #
; # variable. The adress of the variable  #
; # must be poked to adress FVAR          #
; # The field variable (string)           #
; # should contain hexadezimal digits,    #
; # e.g. "7F7F7F7F" to fill four full     #
; # columns. Don't use lowercase chars!   #
; #########################################

GFILL:	LP   REG_K		; Read start and end
	LIDP FSTA
        LII  $01 
	MVWD
	LP   REG_K
	LDM			; K --> A
	LIDP GCURS
	STD			; Set cursor position
JR50E:	LIDP BMAP		; Read Bitmap
	LDD
	CALL GPRINC
	INCK			; Increase loop counter	
	LP   REG_L		; end position
	LDM
	LP   REG_K
	CPMA			; if loop counter < end position,
JR50S:	JRNZM JR50E		; do the loop
	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW

; #########################################
; # SCROLLCLEAR                           #
; # Clears the display by scrolling it up #
; # or down.                              #
; #                                       #
; # The routine has four entry points:    #
; # - SCLR1: scroll up                    #
; # - SCLR2: left up, right down          #
; # - SCLR3: left down, right up          #
; # - SCLR4: scroll down                  #
; #                                       #
; # WARNING: This routine changes it's    #
; # own code at the position CLOP1 and    #
; # CLOP2                                 #
; #########################################

; left up, right up
SCLR1:  LIA  $D2                ; Opcode of 'SR'
        LIB  $D2                ; Opcode of 'SR'
SCLRC1:	JRP  SCLEAR
; left up, right down
SCLR2:  LIA  $D2                ; Opcode of 'SR'
        LIB  $5A                ; Opcode of 'SL'
SCLRC2:	JRP  SCLEAR
; left down, right up
SCLR3:  LIA  $5A                ; Opcode of 'SL'
        LIB  $D2                ; Opcode of 'SR'
SCLRC3:	JRP  SCLEAR
; left down, right down
SCLR4:  LIA  $5A                ; Opcode of 'SL'
        LIB  $5A                ; Opcode of 'SL'
SCLEAR:	LIDP CLOP1		; Set first display half up/down
	STD
	EXAB			; Set second display half up/down
	LIDP CLOP2
	STD
	CALL LCD_ON		; Turn LCD on (ROM-routine) 
        LIA  $08                ; Row loop counter
	PUSH
L57S:	LP   REG_XL		; Left disp. half base address --> X
	LIA  LCD_LEF
	EXAM
	INCP
	LIA  LCD_MSB
	EXAM
	INCP			; Right disp. half base address --> Y
	LIA  LCD_RIG
	EXAM
	INCP
	LIA  LCD_MSB
	EXAM
	DX
	DY
	LIA  59			; Column loop counter
	PUSH
L55S:	RC			; Clear carry
	IX
	LDD
CLOP1:	SR
	STD
	RC			; Clear carry
	IY
	LDD
CLOP2:	SL
        STD
L55E:   LOOP L55S		; "NEXT Column"
        LIA  $80                ; Adjust the speed here!
	PUSH
L56S:   WAIT $FF
L56E:   LOOP L56S		; Wait loop
L57E:   LOOP L57S		; "NEXT Row"
	RTN
	NOPW			; Reserve instructions for
        NOPW			; future releases
        NOPW
        NOPW
        NOPW
