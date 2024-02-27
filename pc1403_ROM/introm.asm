; Sharp PC-1403 internal CPU ROM &0000-&1FFF


; BOOT from 0 ? 
00000000	LB111:	4EE0			WAIT			224
00000002			0201			LIA			1
00000004			125F			LIP			95
00000006			DB				EXAM		
00000007			DF				OUTC		
00000008	LB18:	4EE0			WAIT			224
0000000A			6000			ANIM			0
0000000C			DF				OUTC		; clear port C output
0000000D			6B40			TEST			64
0000000F			7E009F			JPZ			LB501
00000012			4EE0			WAIT			224
00000014			6B40			TEST			64  ; Test Xin
00000016			390F			JRZM			LB18
00000018			025C			LIA			92
0000001A			32				STR		
0000001B			4C				INA		
0000001C			6701			CPIA			1
0000001E			382C			JRZP			LB110
00000020			125F			LIP			95
00000022			100000			LIDP			LB111
00000025			57				LDD		
00000026			6702			CPIA			2
00000028			3A15			JRCP			LB112
0000002A			381A			JRZP			LB114
0000002C			66F3			TSIA			243
0000002E			3818			JRZP			LB119
00000030			0211			LIA			17
00000032			DB				EXAM		
00000033			0002			LII			2
00000035			02FF			LIA			255
00000037			125C			LIP			&5C 
00000039			1E				FILM		; set Port A, B and C to &FF
0000003A			5D				OUTA		
0000003B			DD				OUTB		
0000003C			5F				OUTF		
0000003D			DF				OUTC		
0000003E	LB112:	42				INCA		
0000003F			6B40			TEST		64  ; test Xin
00000041			2904			JRNZM		LB112
00000043			2D44			JRM			LB111

00000045	LB114:  0260			LIA			96
00000047	LB119:	DB				EXAM		
00000048			DF				OUTC		
00000049			2D0C			JRM			LB112

0000004A			0C				ADN		

; clear LCD and ... ?
0000004B			103000			LIDP		&3000  ; LCD left address ; clear screen memory
0000004E			00BF			LII			191
00000050			0200			LIA			0
00000052			1F				FILD		; ( A -> (DP); DP + 1 -> DP ) for I + 1 times
00000053			0201			LIA			1
00000055			E4BA			CAL	&000004BA ; turn LCD on
00000057			88				LP	8
00000058			004F			LII			79
0000005A			0296			LIA			150
0000005C			1E				FILM		
0000005D	LB118:	88				LP	8
0000005E			004F			LII			79
00000060			1C				SRW		
00000061			0023			LII			35
00000063			0203			LIA			3
00000065			34				PUSH		
00000066			AF				LP	47
00000067			1353			LIQ			83
00000069			0E				ADW		
0000006A			2F05			LOOP			5
0000006C			34				PUSH		
0000006D			AF				LP	47
0000006E			1353			LIQ			83
00000070			0F				SBW		
00000071			2F05			LOOP			5
00000073			003F			LII			63
00000075			103000			LIDP			12288  ; &3000 LCD left address
00000078			90				LP	16
00000079			19				EXWD		
0000007A			1100			LIDL			0
0000007C			90				LP	16
0000007D			18				MVWD		
0000007E	LB113:	6B40			TEST			64     ; test Xin
00000080			3981			JRZM			LB111
00000082			6B01			TEST			1      ; 0.5 sec delay
00000084			3907			JRZM			LB113
00000086			0101			LIJ			1
00000088			EE68			CAL	&00000E68
0000008A			2B0D			JRNCM			LB113
0000008C			82				LP	2
0000008D			6325			CPIM			37
0000008F			2912			JRNZM			LB113
00000091			125F			LIP			95
00000093			59				LDM		
00000094			6131			ORIM			49
00000096			6610			TSIA			16
00000098			3803			JRZP			LB117
0000009A			6021			ANIM			33
0000009C	LB117:	DF				OUTC		
0000009D			2D41			JRM			LB118

0000009F	LB501:	025C			LIA			92
000000A1			32				STR		
000000A2			0101			LIJ			1
000000A4			103C00			LIDP			15360
000000A7			0209			LIA			9
000000A9			52				STD		
000000AA			107FFE			LIDP			32766
000000AD			57				LDD		
000000AE			6755			CPIA			85
000000B0			280D			JRNZP			LB50
000000B2			103C00			LIDP			15360
000000B5			020B			LIA			11
000000B7			52				STD		
000000B8			107FFE			LIDP			32766
000000BB			57				LDD		
000000BC			6755			CPIA			85
000000BE	LB50:	103C00			LIDP			15360
000000C1			020A			LIA			10
000000C3			52				STD		
000000C4			7E4000			JPZ			&00004000  ; BASIC ROM

000000C7			103000			LIDP			12288  ; LCD left address
000000CA			0200			LIA			0
000000CC			00BF			LII			191    ; 12288 + 192 = 12480 
000000CE			1F				FILD		       ; clear LCD memory
000000CF			78404E			CALL			16462
000000D2			89				LP	9
000000D3			6000			ANIM			0
000000D5	LB57:	EF2A			CAL	&00000F2A    ; key scan ?? 
000000D7			2808			JRNZP			LB52
000000D9			6B01			TEST			1  ; 0.5 sec timer 
000000DB			3907			JRZM			LB57
000000DD			C8				INCL		
000000DE			2B0A			JRNCM			LB57
000000E0	LB52:	E4D6			CAL	&000004D6
000000E2			2D03			JRM			LB52


000000E5			2A		??
000000E6			28		??
000000E7			18		??

; ...


00000344			2C0C			JRP			LB60
; ...
00000351	LB60:	97				LP	23
00000352			6000			ANIM			00
00000354			37				RTN		

; Block Move
00000398			86				LP	6   ; Y
00000399			1302			LIQ	2   ; AB
0000039B			0A				MVB		; (AB) --> (Y), J+1 bytes
0000039C			37				RTN		

; Block Move 
0000039D			84				LP	4   ; X
0000039E			1302			LIQ	2   ; AB
000003A0			0A				MVB		; (AB) --> (Y), J+1 bytes
000003A1			37				RTN		

; Note as LCD string buffer is at location FEB0
000003A2			02B0			LIA			B0
000003A4			03FE			LIB			FE
000003A6			E39D			CAL	0000039D ; block move J+1 bytes (FEB0) -> (X)
000003A8			05				DX		
000003A9			37				RTN		

000003AA			02B0			LIA			B0
000003AC			03FE			LIB			FE
000003AE			E398			CAL	00000398 ; block move J+1 bytes (FEB0) -> (Y)
000003B0			07				DY		
000003B1			37				RTN		

000003B2			0200			LIA			00
000003B4			03FD			LIB			FD
000003B6			E3A6			CAL	000003A6
000003B8			37				RTN		


; ...

; LCD_OFF  : Turn LCD display off
; LCD_ON   : Turn LCD display on
000004B4			0200			LIA			0         ; LCD_OFF
000004B6			2C03			JRP			LB40
000004B8			0201			LIA			1         ; LCD_ON
000004BA	LB40:	125F			LIP			95        ; Port (&5F) 
000004BC			DB				EXAM		
000004BD			DF				OUTC		
000004BE			37				RTN		

; set &A5 = 1010 0101 to registers #32 to #40
000004BF	LB15:	02A5			LIA			165
000004C1			A0				LP	32      ; registers
000004C2			0007			LII			7
000004C4			1E				FILM	    ; ( A -> (P); P + 1 -> P ) for I + 1 times
000004C5			37				RTN		

; ?
000004C6			F5E8			CAL	&000015E8
000004C8			EF5E			CAL	&00000F5E
000004CA			E897			CAL	&00000897
000004CC			FD6A			CAL	&00001D6A
000004CE			10FF1E			LIDP			65310
000004D1			02A5			LIA			165
000004D3			52				STD		
000004D4			F1E0			CAL	&000011E0

; ?
000004D6			E4BF			CAL	&000004BF  ; set registers 32-40
000004D8			F30E			CAL	&0000130E  ; reset output ports
000004DA			0208			LIA			8
000004DC			E4BA			CAL	&000004BA  ; LCD OFF
000004DE			0208			LIA			8
000004E0			E4BA			CAL	&000004BA  ; LCD OFF
000004E2			37				RTN		

; pointers table from BASIC ROM --> DP
0000082E			10FF54			LIDP			65364
00000831			37				RTN		

00000832			10FF12			LIDP			65298
00000835			37				RTN		

00000836			10FF13			LIDP			65299
00000839			37				RTN		

00000840			14				ADB		
00000841			D620			TSID			32
00000843			37				RTN		

00000844			10FF55			LIDP			65365
00000847			37				RTN	

00000848			10FF55			LIDP			65365
0000084B			D4C0			ANID			192
0000084D			37				RTN		

0000084E			10FF55			LIDP			65365
00000851			D620			TSID			32
00000853			37				RTN		

00000854			10FF16			LIDP			65302
00000857			37				RTN	

00000858			10FF16			LIDP			65302
0000085B			D680			TSID			128
0000085D			37				RTN		

0000085E			10FF16			LIDP			65302
00000861			D640			TSID			64
00000863			37				RTN		

00000864			10FF53			LIDP			65363
00000867			37				RTN		

00000868			10FF17			LIDP			65303
0000086B			37				RTN	

0000086C			10FF56			LIDP			65366
0000086F			37				RTN		

00000870			10FF3F			LIDP			65343
00000873			37				RTN		

; ...



00000D4A			84				LP	4
00000D4B			1338			LIQ			38
00000D4D			0B				EXB		
00000D4E			37				RTN		


 

00000E56	LB123:	C2				INCB		
00000E57			2A08			JRNCP			LB124
00000E59	LB128:	D1				RC		
00000E5A			5A				SL		
00000E5B			3A04			JRCP			LB124
00000E5D			48				INCK		
00000E5E			2D06			JRM			LB128

00000E61			55		??

00000E62			2803			JRNZP			LB125
00000E64			88				LP	8
00000E65			59				LDM		
00000E66	LB125:	DA				EXAB		
00000E67			37				RTN		

00000E68	LB115:	0254			LIA			84
00000E6A			6B08			TEST			8     ; Test if Kon ( ON key ? )
00000E6C			2858			JRNZP			LB116
00000E6E			88				LP	8
00000E6F			6000			ANIM			0
00000E71			89				LP	9
00000E72			0207			LIA			7
00000E74			DB				EXAM		
00000E75			8A				LP	10
00000E76			61FF			ORIM			255
00000E78			03FF			LIB			255
00000E7A			125C			LIP			92
00000E7C			0201			LIA			1
00000E7E			DB				EXAM		
00000E7F			5D				OUTA		
00000E80			103E00			LIDP			15872   ; &3E00
00000E83			D400			ANID			0
00000E85			4E25			WAIT			37
00000E87	LB122:	59				LDM		
00000E88			D1				RC		
00000E89			5A				SL		
00000E8A			DB				EXAM		
00000E8B			8A				LP	10
00000E8C			4C				INA		
00000E8D			5D				OUTA		
00000E8E			DB				EXAM		
00000E8F			D1				RC		
00000E90			5A				SL		
00000E91			46				ANMA		
00000E92			DB				EXAM		
00000E93			3833			JRZP			LB120
00000E95			EE56			CAL	&00000E56
00000E97	LB121:	89				LP	9
00000E98			59				LDM		
00000E99			88				LP	8
00000E9A			44				ADM		
00000E9B			C9				DECL		
00000E9C			125C			LIP			92
00000E9E			2918			JRNZM			LB122
00000EA0			6000			ANIM			0
00000EA2			5D				OUTA		
00000EA3			8B				LP	11
00000EA4			0201			LIA			1
00000EA6			DB				EXAM		
00000EA7			89				LP	9
00000EA8			0207			LIA			7
00000EAA			DB				EXAM		
00000EAB	LB127:	8B				LP	11
00000EAC			59				LDM		
00000EAD			52				STD		
00000EAE			643F			ANIA			63
00000EB0			44				ADM		
00000EB1			4E25			WAIT			37
00000EB3			4C				INA		
00000EB4			3803			JRZP			LB126
00000EB6			EE56			CAL	&00000E56
00000EB8	LB126:	88				LP	8
00000EB9			7008			ADIM			8
00000EBB			C9				DECL		
00000EBC			2912			JRNZM			LB127
00000EBE			D400			ANID			0
00000EC0			DA				EXAB		
00000EC1			6756			CPIA			86
00000EC3			2A02			JRNCP			LB129
00000EC5	LB116:	D0				SC		
00000EC6	LB129:	37				RTN		

00000EC7	LB120:	4E05			WAIT			5
00000EC9			2D33			JRM			LB121

; ...

; key scan ??
00000F2A	LB12:	125C			LIP			92
00000F2C			0240			LIA			64
00000F2E			DB				EXAM		
00000F2F			5D				OUTA		
00000F30			103E00			LIDP			15872
00000F33			D400			ANID			0
00000F35			4E42			WAIT			66
00000F37			4C				INA		
00000F38			6680			TSIA			128
00000F3A			37				RTN		

00000F3B			125C			LIP			92
00000F3D			6000			ANIM			0
00000F3F			5D				OUTA		
00000F40			103E00			LIDP			15872
00000F43			0280			LIA			128
00000F45			52				STD		
00000F46			4E42			WAIT			66
00000F48			E854			CAL	&00000854
00000F4A			D47F			ANID			127
00000F4C			4C				INA		
00000F4D			6680			TSIA			128
00000F4F			2803			JRNZP			LB40
00000F51			D580			ORID			128
00000F53	LB40:	103E00			LIDP			15872
00000F56			D400			ANID			0
00000F58			37				RTN		

00000F59			10303C			LIDP			12348  ; Display flags 
00000F5C			D4FD			ANID			253
00000F5E			10FF6B			LIDP			65387
00000F61			D4F0			ANID			240
00000F63			10FF6B			LIDP			65387
00000F66			D4F9			ANID			249
00000F68			10FF70			LIDP			65392
00000F6B			02C8			LIA			200
00000F6D			52				STD		
00000F6E			11C8			LIDL			200
00000F70			0003			LII			3
00000F72			0200			LIA			0
00000F74			1F				FILD		
00000F75			37				RTN		


; reset output ports
0000130E	LB16:	125F			LIP			95
00001310			6001			ANIM			1  
00001312			DF				OUTC		       ; set 00000001 to C "control" port
00001313			125E			LIP			94
00001315			60FB			ANIM			251
00001317			5F				OUTF		       ; set 00110011 to F0 port
00001318			51				DECP		
00001319			607F			ANIM			127
0000131B			DD				OUTB		       ; set 00110011 to IB port
0000131C			103A00			LIDP			14848
0000131F			D400			ANID			0
00001321			125C			LIP			92
00001323			6000			ANIM			0
00001325			5D				OUTA		       ; set 00000000 to IA port
00001326			103E00			LIDP			15872
00001329			D400			ANID			0
0000132B			4E08			WAIT			8
0000132D			37				RTN		

; ...



;  Get keystroke
00001494			0203			LIA			3
00001496			E4BA			CAL	&000004BA
00001498			6B01			TEST			1
0000149A	LB26:	027D			LIA			125
0000149C			0330			LIB			48
0000149E			E3AE			CAL	&000003AE
000014A0			0201			LIA			1
000014A2			26				IYS		
000014A3			02FB			LIA			251
000014A5			26				IYS		
000014A6	LB212:	00FC			LII			252
000014A8	LB25:	EF2A			CAL	&00000F2A
000014AA			3805			JRZP			LB20
000014AC			E4C6			CAL	&000004C6
000014AE			2D15			JRM			LB26
000014B1			68		??
000014B2			2A5C			JRNCP			LB21
000014B4			34				PUSH		
000014B5			EE68			CAL	&00000E68
000014B7			DA				EXAB		
000014B8			5B				POP		
000014B9			2A55			JRNCP			LB21
000014BB			83				LP	3
000014BC			C7				CPMA		
000014BD			2851			JRNZP			LB21
000014BF			E82E			CAL	&0000082E
000014C1			D601			TSID			1
000014C3			280E			JRNZP			LB27
000014C5			D501			ORID			1
000014C7			D4FD			ANID			253
000014C9			10FF5E			LIDP			65374
000014CC			52				STD		
000014CD			34				PUSH		
000014CE			F710			CAL	&00001710
000014D0			5B				POP		
000014D1			37				RTN		

000014D2	LB27:	D602			TSID			2
000014D4			3844			JRZP			LB28
000014D6			10FF5E			LIDP			65374
000014D9			55				MVMD		
000014DA			C7				CPMA		
000014DB			283D			JRNZP			LB28
000014DD			E82E			CAL	&0000082E
000014DF			D608			TSID			8
000014E1			2815			JRNZP			LB223
000014E3			34				PUSH		
000014E4			10303E			LIDP			12350
000014E7			82				LP	2
000014E8			1A				MVBD		
000014E9			6700			CPIA			0
000014EB			2817			JRNZP			LB225
000014ED			DA				EXAB		
000014EE			6700			CPIA			0
000014F0			DA				EXAB		
000014F1			2811			JRNZP			LB225
000014F3			F70C			CAL	&0000170C
000014F5			5B		        POP
000014F6			37		        RTN

000014F7	LB223:	6B01			TEST			1
000014F9			3960			JRZM			LB26
000014FB			D604			TSID			4
000014FD			3964			JRZM			LB26
000014FF			FD54			CAL	&00001D54
00001501			2D68			JRM			LB26
00001504			2A02			JRNCP			LB226
00001506			C2				INCB		
00001507	LB226:	82				LP	2
00001508			10303E			LIDP			12350
0000150B			1B				EXBD		
0000150C			5B				POP		
0000150D			2D74			JRM			LB26
00001510			2E		??
00001511			D601			TSID			1
00001513			383D			JRZP			LB22
00001515			D602			TSID			2
00001517			3834			JRZP			LB29
00001519	LB28:	E82E			CAL	&0000082E
0000151B			D4FD			ANID			253
0000151D			00FC			LII			252
0000151F	LB23:	6B01			TEST			1
00001521			384B			JRZP			LB24
00001523			027D			LIA			125
00001525			0330			LIB			48
00001527			E3A6			CAL	&000003A6
00001529			0302			LIB			2
0000152B	LB224:	24				IXL		
0000152C			660F			TSIA			15
0000152E			280D			JRNZP			LB213
00001530			34				PUSH		
00001531			0200			LIA			0
00001533			E4BA			CAL	&000004BA
00001535			4EE0			WAIT			224
00001537			0201			LIA			1
00001539			E4BA			CAL	&000004BA
0000153B			5B				POP		
0000153C	LB213:	42				INCA		
0000153D			52				STD		
0000153E			2A28			JRNCP			LB214
00001540			C3				DECB		
00001541			2917			JRNZM			LB224
00001543			02FF			LIA			255
00001545			52				STD		
00001546			05				DX		
00001547			52				STD		
00001548			E4E3			CAL	&000004E3
0000154A			2DA5			JRM			LB212
0000154D			2BA6			JRNCM			LB25
0000154F			D4FE			ANID			254
00001551	LB22:	E497			CAL	&00000497
00001553			E82E			CAL	&0000082E
00001555			D608			TSID			8
00001557			3939			JRZM			LB23
00001559			10FF34			LIDP			65332
0000155C			02B0			LIA			176
0000155E			52				STD		
0000155F			FD46			CAL	&00001D46
00001561			E82E			CAL	&0000082E
00001563			D4E1			ANID			225
00001565			2DC0			JRM			LB212
00001568			2E		??
00001569			D604			TSID			4
0000156B			280B			JRNZP			LB215
0000156D	LB24:	E82E			CAL	&0000082E
0000156F			D601			TSID			1
00001571			29CA			JRNZM			LB25
00001573			E4A7			CAL	&000004A7
00001575			2DCE			JRM			LB25


; ...


0000170C	LB227:	02FE			LIA			254
0000170E			2C03			JRP			LB228
00001711			CE		??
00001712	LB228:	03FF			LIB			255
00001714			10303E			LIDP			12350
00001717			82				LP	2
00001718			1B				EXBD		
00001719			37				RTN		


; ...


00001D46	LB210:	016F			LIJ			111
; 1D48 also called from EXT rom bank 9 at the beginning of LCD update (?)
00001D48			1030B9			LIDP		30B9
00001D4B	LB222:	52				STD		        
00001D4C			10FF8F			LIDP		FF8F
00001D4F			0208			LIA			08
00001D51			52				STD		
00001D52			2C31			JRP			LB211

; ...
00001D5E	LB217:	1030B9			LIDP		30B9
00001D61			52				STD		
00001D62			10FF8F			LIDP		FF8F
00001D65			0209			LIA			9
00001D67			52				STD		
00001D68			2C1B			JRP			LB211

; ...
00001D84	LB211:	20				LDP		
00001D85			10FF71			LIDP		FF71
00001D88			52				STD		       	; A --> (FF71)
00001D89			10FF8C			LIDP		FF8C
00001D8C			0279			LIA			79
00001D8E			52				STD		       	; 79 --> (FF8C)
00001D8F			118D			LIDL		8D 	; low byte of DP
00001D91			0240			LIA			40
00001D93			52				STD		
00001D94			118E			LIDL		8E 	; low byte of DP
00001D96			81				LP	1 ; 1 -> J
00001D97			53				MVDM		
00001D98			0101			LIJ			01
00001D9A			86				LP	6 ; Y 
00001D9B			10FF72			LIDP		FF72
00001D9E			1B				EXBD			; (DP) <--> (P), J+1 bytes
00001D9F			103C00			LIDP		3C00
00001DA2			57				LDD		
00001DA3			26				IYS		
00001DA4			5B				POP		
00001DA5			26				IYS		
00001DA6			5B				POP		
00001DA7			26				IYS		
00001DA8			86				LP	6 ; Y
00001DA9			10FF72			LIDP		FF72
00001DAC			1B				EXBD		
00001DAD			10FF8F			LIDP		FF8F
00001DB0			57				LDD		
00001DB1			640F			ANIA		0F
00001DB3			103C00			LIDP		3C00
00001DB6			52				STD		
00001DB7			10FF71			LIDP		FF71
00001DBA			57				LDD		
00001DBB			30				STP		
00001DBC			1030B9			LIDP		30B9
00001DBF			57				LDD		
00001DC0			78FF8C			CALL		FF8C ; ?
00001DC3			1030B9			LIDP		30B9
00001DC6			52				STD		
00001DC7			20				LDP		
00001DC8			10FF71			LIDP		FF71
00001DCB			52				STD		
00001DCC			84				LP	4 ; X
00001DCD			10FF72			LIDP		FF72
00001DD0			1B				EXBD		
00001DD1			04				IX		
00001DD2			25				DXL		
00001DD3			34				PUSH		
00001DD4			25				DXL		
00001DD5			34				PUSH		
00001DD6			25				DXL		
00001DD7			103C00			LIDP		3C00
00001DDA			640F			ANIA		0F
00001DDC			52				STD		
00001DDD			05				DX		
00001DDE			84				LP	4 ; X
00001DDF			10FF72			LIDP		FF72
00001DE2			1B				EXBD		
00001DE3			10FF71			LIDP		FF71
00001DE6			57				LDD		
00001DE7			30				STP		
00001DE8			1030B9			LIDP		30B9
00001DEB			57				LDD		
00001DEC			37				RTN	


; ....


00001EAF			4D		??
00001EB0	LB221:	791D48			JP			LB222
00001EB3			4D		??
00001EB4			01		??

; ...

00001EFE			2D		??
00001EFF	LB220:	4F				IPXL		
00001F00			01B4			LIJ			180
00001F02			2D53			JRM			LB221
00001F05			B7		??
00001F06			2D		??

; ...

00001FFE			D7		??
00001FFF	LB219:	FEFF			CAL	&00001EFF
