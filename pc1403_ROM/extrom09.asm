; External ROM bank 09
; 

.ORG	04000


00A0			0112			LIJ			12
00A2			2C1F			JRP			LB90

;...

00C2	LB90:	791D48			JP			1D48  ; in int ROM?


; bitmap pointer calculation (?)
0489			34				PUSH		    ; save A (ascii code?)
048A			0200			LIA			00
048C			0341			LIB			41
048E			E39D			CAL	039D    ; (4100) --> Y
0490			5B				POP		
0491			0300			LIB			00
0493			6720			CPIA			20  ; blank
0495			3A1D			JRCP			LB10
0497			6780			CPIA			80  ; ? 
0499			3A36			JRCP			LB12
049B			67A0			CPIA			A0
049D			3A55			JRCP			LB14
049F			7520			SBIA			20
04A1			67C0			CPIA			C0
04A3			3A23			JRCP			LB19
04A5			67D0			CPIA			D0
04A7			3A0B			JRCP			LB10
04A9			7510			SBIA			10
04AB			67C5			CPIA			C5
04AD			3A19			JRCP			LB19
04AF			67CD			CPIA			CD
04B1			3A03			JRCP			LB13
04B3	LB10:	0220			LIA			20
04B5	LB13:	751F			SBIA			1F    ; A - 1F --> A
04B7			8B				LP	11
04B8			DB				EXAM		
04B9			59				LDM		
04BA			82				LP	2 ; B
04BB			14				ADB		
04BC			82				LP	2 ; B
04BD			14				ADB		
04BE			8B				LP	11
04BF			44				ADM		
04C0			59				LDM		
04C1			2A02			JRNCP			LB11
04C3			C2				INCB		
04C4	LB11:	84				LP	4  ; X
04C5			14				ADB		
04C6			37				RTN	
04C7	LB19:	10FF16			LIDP			FF16
04CA			D680			TSID			80            ; (DP) & 80 --> z
04CC			2918			JRNZM			LB13          ; if (FF16) != 80  go to LB13
04CE			2D1C			JRM				LB10
04D0	LB12:	10FF16			LIDP			FF16
04D3			D680			TSID			80
04D5			2921			JRNZM			LB13
04D7			675C			CPIA			5C
04D9			3807			JRZP			LB40
04DB			677E			CPIA			7E
04DD			380F			JRZP			LB43
04DF			2D2B			JRM			LB13
04E1	LB40:	0284			LIA			84
04E3			0344			LIB			44
04E5	LB113:	E39D			CAL	039D  ; block move (4484) -> (X) J+1 bytes
04E7			0205			LIA			05
04E9			0300			LIB			00
04EB			2D28			JRM			LB11
04ED			027F			LIA			7F
04EF	LB14:	0344			LIB			44
04F1			2D0D			JRM			LB113
04F3	LB14:	E89D			CAL	089D
04F5			D640			TSID			40
04F7			3945			JRZM			45
04F9			744D			ADIA			4D
04FB			2D47			JRM			LB13



; bitmapping character from printbuffer
04FD			88				LP	8
04FE			59				LDM		; K -> A
04FF			8A				LP	10
0500			C7				CPMA	; M - A -> c,z
0501			2806			JRNZP			LB30
0503			86				LP	6	; reg Y
0504			10FF3E			LIDP			FF3E ; pointer to character in printbuffer
0507			53				MVDM			; -> Y
0508	LB30:	30				STP		
0509			59				LDM		        ; ascii in A
050A			784489			CALL			4489 ; bitmap pointer calculation -> X
050D			37				RTN		

050E			10FF54			LIDP			FF54
0511			D610			TSID			10
0513			3825			JRZP			LB70
0515			D4EF			ANID			EF
0517			10FF3D			LIDP			FF3D
051A			57				LDD		
051B	LB71:	784489			CALL			4489
051E			10FF3E			LIDP			FF3E
0521			57				LDD		
0522			42				INCA		
0523			0330			LIB			30
0525			E3AE			CAL	03AE
0527			6740			CPIA			40
0529			0305			LIB			05
052B			2A07			JRNCP			LB72
052D	LB73:	25				DXL		
052E			26				IYS		
052F			C3				DECB		
0530			2904			JRNZM			LB73
0532			37				RTN		

0533	LB72:	25				DXL		
0534			27				DYS		
0535			C3				DECB		
0536			2904			JRNZM			LB72
0538			37				RTN		

0539	LB70:	D510			ORID			10
053B			02F9			LIA			F9
053D			2D23			JRM			LB71

0540			0003			LII			03
0542			30				STP		
0543			E3AE			CAL	03AE ; block move 
0545			0210			LIA			10
0547			88				LP	8
0548			DB				EXAM		
0549			020C			LIA			0C
054B			89				LP	9
054C			DB				EXAM		
054D	LB61:	88				LP	8
054E			59				LDM		
054F			30				STP		
0550			59				LDM		
0551			784489			CALL			4489
0554			0305			LIB			05
0556	LB60:	25				DXL		
0557			26				IYS		
0558			C3				DECB		
0559			2904			JRNZM			LB60
055B			48				INCK		
055C			C9				DECL		
055D			2911			JRNZM			LB61
055F			027C			LIA			7C
0561			86				LP	6
0562			DB				EXAM		
0563			020C			LIA			0C
0565			89				LP	9
0566			DB				EXAM		
0567	LB63:	88				LP	8
0568			59				LDM		
0569			30				STP		
056A			59				LDM		
056B			784489			CALL			4489
056E			0305			LIB			05
0570	LB62:	25				DXL		
0571			27				DYS		
0572			C3				DECB		
0573			2904			JRNZM			LB62
0575			48				INCK		
0576			C9				DECL		
0577			2911			JRNZM			LB63
0579			37				RTN	

0581			DB				EXAM		
0582			2C2A			JRP			LB80

; ?
0584			7840A0			CALL    40A0  ; goes to internal ROM 1D48 (init routines?)


; ASCII print buffer in memory 0x10... translated to bitmaps and written onto LCD
; entry with J = 1
0587			E844			CAL 	0844  ; data pointer: LIDP FF55 (?)
0589			D601			TSID			01  ; flag ?
058B			28BE			JRNZP			LB90
058D			D620			TSID			20  ; flag ?
058F			38BA			JRZP			LB90
0591			10FF3E			LIDP			FF3E ; pointer to current char ?
0594			8A				LP	10  ; reg_M
0595			55				MVMD		    ; (FF3E) --> M 
0596			59				LDM		        ; M --> A
0597			30				STP		        ; A --> M
0598			E82E			CAL	082E        ; FF54 -> DP (what is it?)
059A			D510			ORID			10  ; (FF54) | b0001 --> (FF54)
059C			D4FB			ANID			FB  ; (FF54) & b11111011 --> (FF54)
059E			6300			CPIM			00  ; testing bit xxxBxxxxx of (FF54)
05A0			025F			LIA			5F
05A2			3809			JRZP			LB96
05A4			D504			ORID			04
05A6			10FF3D			LIDP			FF3D ; ?
05A9			53				MVDM		
05AA			02F9			LIA			F9
05AC	LB96:	DB				EXAM		    ; M <--> A
; second entry point 45AD (used for example to print numeric variabile content)
05AD	LB80:	90				LP	16  ; reg_16 
05AE			20				LDP		        ; reg_16 --> A  ? 
05AF			88				LP	8   ; reg_K
05B0			DB				EXAM	        ; A <--> (K)
05B1			0200			LIA			00
05B3			0330			LIB			30
05B5			E3AE			CAL	03AE   ; 3000 --> Y
; fill LCD, 6 + 3 + 3 + 3 + 3 + 6 characters (different memory ranges)
; First 6 characters to print
05B7			0206			LIA			06 
05B9			89				LP	9  ; Using L as loop counter
05BA			DB				EXAM	  	
05BB	LB97:	7844FD			CALL	44FD ; map char bitmap address --> X
; move 5 bytes from (X), downward, to (Y), upward.
05BE			25				DXL		
05BF			26				IYS		
05C0			25				DXL		
05C1			26				IYS		
05C2			25				DXL		
05C3			26				IYS		
05C4			25				DXL		
05C5			26				IYS		
05C6			25				DXL		
05C7			26				IYS		
05C8			48				INCK		
05C9			C9				DECL		
05CA			2910			JRNZM			LB97
; next 3 characters to print	
05CC			022C			LIA			2C  ; 2C = 44 = LCD offset
05CE			86				LP	6 ; Y 
05CF			DB				EXAM	
05D0			0203			LIA			03  
05D2			89				LP	9 ; on L
05D3			DB				EXAM		
05D4	LB933:	7844FD			CALL	44FD
05D7			25				DXL		
05D8			26				IYS		
05D9			25				DXL		
05DA			26				IYS		
05DB			25				DXL		
05DC			26				IYS		
05DD			25				DXL		
05DE			26				IYS		
05DF			25				DXL		
05E0			26				IYS		
05E1			48				INCK		
05E2			C9				DECL		
05E3			2910			JRNZM			LB933
; next 3 characters
05E5			021D			LIA			1D ; LCD offset
05E7			86				LP	6
05E8			DB				EXAM		
05E9			0203			LIA			03
05EB			89				LP	9
05EC			DB				EXAM		
05ED	LB950:	7844FD			CALL			44FD
05F0			25				DXL		
05F1			26				IYS		
05F2			25				DXL		
05F3			26				IYS		
05F4			25				DXL		
05F5			26				IYS		
05F6			25				DXL		
05F7			26				IYS		
05F8			25				DXL		
05F9			26				IYS		
05FA			48				INCK		
05FB			C9				DECL		
05FC			2910			JRNZM			LB950
; next 3 characters
05FE			026D			LIA			6D ; LCD offset
0600			86				LP	6
0601			DB				EXAM		
0602			0203			LIA			03
0604			89				LP	9
0605			DB				EXAM		
0606	LB956:	7844FD			CALL			44FD
0609			25				DXL		
060A			27				DYS		
060B			25				DXL		
060C			27				DYS		
060D			25				DXL		
060E			27				DYS		
060F			25				DXL		
0610			27				DYS		
0611			25				DXL		
0612			27				DYS		
0613			48				INCK		
0614			C9				DECL		
0615			2910			JRNZM			LB956
; next 3 characters
0617			027C			LIA			7C ; LCD offset
0619			86				LP	6
061A			DB				EXAM		
061B			0203			LIA			03
061D			89				LP	9
061E			DB				EXAM		
061F	LB957:	7844FD			CALL	44FD
0622			25				DXL		
0623			27				DYS		
0624			25				DXL		
0625			27				DYS		
0626			25				DXL		
0627			27				DYS		
0628			25				DXL		
0629			27				DYS		
062A			25				DXL		
062B			27				DYS		
062C			48				INCK		
062D			C9				DECL		
062E			2910			JRNZM			LB957
; last 6 characters
0630			025E			LIA			5E ; LCD offset
0632			86				LP	6 ; to Y
0633			DB				EXAM		
0634			0206			LIA			06
0636			89				LP	9 ; loop on L
0637			DB				EXAM		
0638	LB958:	7844FD			CALL	44FD
063B			25				DXL		
063C			27				DYS		
063D			25				DXL		
063E			27				DYS		
063F			25				DXL		
0640			27				DYS		
0641			25				DXL		
0642			27				DYS		
0643			25				DXL		
0644			27				DYS		
0645			48				INCK		
0646			C9				DECL		
0647			2910			JRNZM			LB958
0649			37				RTN		 ; done

064A	LB90:	E82E			CAL	082E  ;  FF54 --> DP
064C			D4FB			ANID    FB ; -- ? means?
064E			2DA2			JRM	    LB80


;  ... 


089C			30		??
089D	LB15:	26				IYS		
089E			93				LP	19
089F			59				LDM		
08A0			64F0			ANIA			F0
08A2			2A04			JRNCP			LB16
08A4			3806			JRZP			LB110
08A6			D1				RC		
08A7	LB16:	58				SWP		
08A8			6530			ORIA			30
08AA			26				IYS		
08AB	LB110:	59				LDM		
08AC			640F			ANIA			0F
08AE			2A03			JRNCP			LB17
08B0			3804			JRZP			LB111
08B2	LB17:	6530			ORIA			30
08B4			26				IYS		
08B5	LB111:	94				LP	20
08B6			59				LDM		
08B7			58				SWP		
08B8			640F			ANIA			0F
08BA			6530			ORIA			30
08BC			26				IYS		
08BD			86				LP	6
08BE			59				LDM		
08BF			75A0			SBIA			A0
08C1			10FF5F			LIDP			FF5F
08C4			52				STD		
08C5			37				RTN		


; . . .




0B86			0220			LIA			20 ; blank
0B88			794CBA			JP			4CBA

; used while sending a number to LCD (see
0C63			10FF12			LIDP			FF12
0C66			D624			TSID			24
0C68			2803			JRNZP			LB230
0C6A			EAC9			CAL	0AC9
0C6C	LB230:	10FF63			LIDP			FF63
0C6F			84				LP	4
0C70			1B				EXBD		
0C71			784A7B			CALL			4A7B
0C74			EAB1			CAL	0AB1
0C76			0217			LIA			17  ; 24 characters?
0C78			88				LP	8
0C79			DB				EXAM		
0C7A			0210			LIA			10
0C7C			89				LP	9
0C7D			DB				EXAM		
0C7E	LB234:	89				LP	9
0C7F			59				LDM		
0C80			30				STP		
0C81			59				LDM		
0C82			6720			CPIA			20
0C84			3BFF			JRCM			FF
0C86			6780			CPIA			80
0C88			2A49			JRNCP			LB231
0C8A	LB233:	675C			CPIA			5C
0C8C			39FD			JRZM			FD
0C8E			677E			CPIA			7E
0C90			39F5			JRZM			F5
0C92			677F			CPIA			7F
0C94			7E4B86			JPZ			4B86
0C97			67F9			CPIA			F9
0C99			7E4B86			JPZ			4B86
0C9C			6730			CPIA			30
0C9E			7E4B72			JPZ			4B72
0CA1			674F			CPIA			4F
0CA3			7E4B77			JPZ			4B77
0CA6			67FA			CPIA			FA
0CA8			7E4B8B			JPZ			4B8B
0CAB			67FB			CPIA			FB
0CAD			7E4B7C			JPZ			4B7C
0CB0			67FC			CPIA			FC
0CB2			7E4B81			JPZ			4B81
0CB5			67FD			CPIA			FD
0CB7			7D4B86			JPNC			4B86
0CBA			C8				INCL		
0CBB			784A13			CALL			4A13
0CBE			49				DECK		
0CBF			2B42			JRNCM			LB234
0CC1			020D			LIA			0D
0CC3			784A13			CALL			4A13
0CC6			020E			LIA			0E
0CC8			784A13			CALL			4A13
0CCB			10FF63			LIDP			FF63
0CCE			84				LP	4
0CCF			1A				MVBD		
0CD0			D1				RC		
0CD1			37				RTN		

0CD2	LB231:	67A0			CPIA			A0
0CD4			7F4B86			JPC			4B86
0CD7			67E0			CPIA			E0
0CD9			3A0A			JRCP			LB232
0CDB			67F0			CPIA			F0
0CDD			7F4B86			JPC			4B86
0CE0			67F5			CPIA			F5
0CE2			2B59			JRNCM			LB233
0CE4	LB232:	E854			CAL	0854
0CE6			D680			TSID			80
0CE8			295F			JRNZM			LB233
0CEA			794B86			JP			4B86


; Clear internal RAM at 0x10 and transfer here 24 characters from FD60
; FF6C should pint to the end of string
0CED			10FF6C			LIDP	FF6C ; pointer to end of string ?
0CF0			86				LP	6             
0CF1			1A				MVBD		;  (FF6C) -> Y
0CF2			06				IY		
0CF3			0220			LIA		0x20
0CF5			0010			LII		0x10
0CF7			1F				FILD		
0CF8			10FD60			LIDP			FD60 ; Print BUFFER, from BASIC PRINT command
0CFB			90				LP	16        ; destination 0x10
0CFC			0017			LII		0x17  ;  24-1 characters
0CFE			18				MVWD		
0CFF			37				RTN	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ************************************************
; ** entry point to the print-screen routine ? ***
0DB7			784CED			CALL			4CED ; --> move PRINT buffer to internal RAM
0DBA			784587			CALL			4587 ; --> call to bitmapper and LCD writing
0DBD			ED4A			CAL	0D4A             ; ???
0DBF			E836			CAL	0836
0DC1			D604			TSID			04
0DC3			3809			JRZP			LB100
0DC5			B5				LP	53
0DC6			6108			ORIM			08
0DC8			E844			CAL	0844
0DCA			D501			ORID			01
0DCC			37				RTN		

0DCD	LB100:	F150			CAL	1150
0DCF			E89D			CAL	089D
0DD1			D501			ORID			01
0DD3			E4B8			CAL	04B8
0DD5			10FF47			LIDP			FF47
0DD8			82				LP	2
0DD9			1A				MVBD		
0DDA			88				LP	8
0DDB			15				SBB		
0DDC			3804			JRZP			LB103
0DDE			785B37			CALL			5B37
0DE1	LB103:	E89D			CAL	089D
0DE3			D4FE			ANID			FE
0DE5			E4B4			CAL	04B4
0DE7			D1				RC		
0DE8			37				RTN	

; ...
0E8D	LB833:	10FEB0			LIDP			FEB0
0E90			0220			LIA			20
0E92			004F			LII			4F
0E94			1F				FILD		
0E95			E864			CAL	0864   ;  = LIDP FF53
0E97			D400			ANID			00
0E99			116E			LIDL			6E
0E9B			D4FE			ANID			FE
0E9D			24				IXL		
0E9E			67CA			CPIA			CA
0EA0			282C			JRNZP			LB80
0EA2			24				IXL		
0EA3			673B			CPIA			3B
0EA5			3823			JRZP			LB82
0EA7			05				DX		
0EA8			B3				LP	51
0EA9			59				LDM		
0EAA			34				PUSH		
0EAB			EB28			CAL	0B28
0EAD			5B				POP		
0EAE			3A4E			JRCP			LB81
0EB0			F585			CAL	1585

0EC9	LB82:	FB3C			CAL	1B3C
0ECB			2C02			JRP			LB85
0ECE	LB85:	B3				LP	51
0ECF			59				LDM		
0ED0			34				PUSH		
0ED1			E864			CAL	0864
0ED3			57				LDD		
0ED4			34				PUSH		
0ED5			EB31			CAL	0B31
0ED7			5B				POP		
0ED8			E864			CAL	0864
0EDA			52				STD		
0EDB			5B				POP		
0EDC			3A20			JRCP			LB81
0EDE			B3				LP	51
0EDF			DB				EXAM		
0EE0			24				IXL		
0EE1			670D			CPIA			0D
0EE3			3805			JRZP			LB86
0EE5			673A			CPIA			3A
0EE7			2816			JRNZP			LB820
0EE9	LB86:	6202			TSIM			02
0EEB			3809			JRZP			LB87
0EED			10FFF4			LIDP			FFF4
0EF0			57				LDD		
0EF1			67D0			CPIA			D0
0EF3			2803			JRNZP			LB823
0EF5	LB87:	FAF7			CAL	1AF7
0EF7	LB823:	B3				LP	51
0EF8			6110			ORIM			10
0EFA			7857F4			CALL			57F4
0EFD	LB81:	37				RTN		

0EFE	LB820:	673B			CPIA			3B
0F00			2830			JRNZP			LB821
0F02			6201			TSIM			01
0F04			2829			JRNZP			LB822
0F06			6204			TSIM			04
0F08			3806			JRZP			LB832
0F0A			60FB			ANIM			FB
0F0C			FAF7			CAL	1AF7
0F0E			B3				LP	51
0F0F	LB832:	6102			ORIM			02
0F11	LB834:	784FC0			CALL			4FC0
0F14			3B18			JRCM			LB81
0F16			24				IXL		
0F17			05				DX		
0F18			670D			CPIA			0D
0F1A			3813			JRZP			LB822
0F1C			673A			CPIA			3A
0F1E			380F			JRZP			LB822
0F20			EAD3			CAL	0AD3
0F22			7857EA			CALL			57EA
0F25			7857FD			CALL			57FD
0F28			3B2C			JRCM			LB81
0F2A			EAE0			CAL	0AE0
0F2C			2DA0			JRM			LB833
0F2F			77		??
0F30			37				RTN		

0F31	LB821:	672C			CPIA			2C
0F33			2906			JRNZM			LB822
0F35			6203			TSIM			03
0F37			290A			JRNZM			LB822
0F39			6101			ORIM			01
0F3B			2D2B			JRM			LB834


; used while issuing 'A <enter>' in RUN mode
; (showing content of the A basic variable)

; ... entry point unknown


1216	LB0:	785124			CALL			5124 ; +1224
1219			37				RTN		

1224			8D				LP	13
1225			59				LDM		
1226			88				LP	8
1227			DB				EXAM		
1228			0230			LIA			30
122A			26				IYS		
122B			0309			LIB			09
122D			06				IY		
122E	LB200:	49				DECK		
122F			3941			JRZM			41
1231			26				IYS		
1232			C3				DECB		
1233			2906			JRNZM			LB200
1235			FB3C			CAL	1B3C
1237			EE15			CAL	0E15
1239			2A43			JRNCP			LB203
123B			103080			LIDP			LB2026
123E			0220			LIA			20
1240			0017			LII			17
1242			1F				FILD		
1243			B3				LP	51
1244			60DC			ANIM			DC
1246			6180			ORIM			80
1248			E864			CAL	0864
124A			D400			ANID			00
124C			784FD4			CALL			4FD4
124F			103080			LIDP			LB2026
1252			90				LP	16
1253			0017			LII			17
1255			19				EXWD		
1256			E8B7			CAL	08B7
1258			380E			JRZP			LB2027
125A			F738			CAL	1738
125C			281B			JRNZP			LB2061
125E			D608			TSID			08
1260			3806			JRZP			LB2027
1262			7854BB			CALL			54BB
1265	LB2062:	3A0F			JRCP			LB2028
1267	LB2027:	E844			CAL	0844
1269			D601			TSID			01
126B			3809			JRZP			LB2028
126D			F593			CAL	1593
126F			7845AD			CALL			45AD ; --> Send to LCD 0x10...
1272	LB2020:	D1				RC		
1273			F580			CAL	1580
1275	LB2028:	FB2F			CAL	1B2F
1277			37				RTN		

1278	LB2061:	784C63			CALL			4C63 ; populate 0x10
127B			2D17			JRM			LB2062
127E			93				LP	19
127F			F2F3			CAL	12F3
1281			24				IXL		
1282			34				PUSH		
1283			020D			LIA			0D
1285			52				STD		
1286			10FF6C			LIDP			FF6C
1289			84				LP	4
128A			1B				EXBD		
128B			E8B7			CAL	08B7
128D			381A			JRZP			LB2018
128F			F738			CAL	1738
1291			2805			JRNZP			LB2058
1293			D608			TSID			08
1295			3812			JRZP			LB2018
1297	LB2058:	EEFE			CAL	0EFE
1299			F2EC			CAL	12EC

; 54BB
14BB			F436			CAL	1436
14BD			785463			CALL			5463
14C0			F593			CAL	1593
14C2			78547B			CALL			547B
14C5			3A43			JRCP			LB2111
14C7			F42A			CAL	142A
14C9			E3B2			CAL	03B2
14CB			F589			CAL	1589

14CE			18				MVWD		
14CF			88				LP	8
14D0			DB				EXAM		
14D1			8F				LP	15
14D2	LB220:	50				INCP		
14D3			59				LDM		
14D4			26				IYS		
14D5			49				DECK		
14D6			2905			JRNZM			LB220
14D8			020D			LIA			0D
14DA			26				IYS		
14DB			07				DY		
14DC	LB221:	24				IXL		
14DD			6720			CPIA			20
14DF			3904			JRZM			LB221
14E1			05				DX		
14E2			86				LP	6
14E3			59				LDM		
14E4			DA				EXAB		
14E5			84				LP	4
14E6			59				LDM		
14E7			83				LP	3
14E8			45				SBM		
14E9			E88B			CAL	088B
14EB			57				LDD		
14EC			DA				EXAB		
14ED			45				SBM		
14EE			3A22			JRCP			LB222
14F0			380E			JRZP			LB2220
14F2			DA				EXAB		
14F3			89				LP	9
14F4			DB				EXAM		
14F5	LB2240:	0220			LIA			20
14F7			785484			CALL			5484
14FA			3A0E			JRCP			LB224
14FC			C9				DECL		
14FD			2909			JRNZM			LB2240
14FF	LB2220:	24				IXL		
1500			670D			CPIA			0D
1502			382E			JRZP			LB223
1504			785484			CALL			5484
1507			2B09			JRNCM			LB2220

1509	LB224:	F42A			CAL	142A
150B			F580			CAL	1580
150D			784798			CALL			4798
1510			37				RTN		

1511	LB222:	E88B			CAL	088B
1513			88				LP	8
1514			55				MVMD		
1515	LB2221:	24				IXL		
1516			670D			CPIA			0D
1518			3818			JRZP			LB223
151A			785484			CALL			5484
151D			3B15			JRCM			LB224
151F			49				DECK		
1520			290C			JRNZM			LB2221
1522			24				IXL		
1523			05				DX		
1524			670D			CPIA			0D
1526			380A			JRZP			LB223
1528			020D			LIA			0D
152A			785484			CALL			5484
152D			2B1D			JRNCM			LB222
152F			2D27			JRM			LB224
1532			54				MVMP		
1533			84				LP	4
1534			3B2C			JRCM			2C
1536			F42A			CAL	142A
1538			F580			CAL	1580
153A			D1				RC		
153B			37				RTN		
