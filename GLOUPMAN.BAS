50000 "GLOUPMAN" rem Hebdogiciel #89
50010 "A" gosub 51760:clear :wait 0:call 33238:rem GMODE REPLACE
50020 AA=0:dim A1$(0)*62:AA=256*peek 65288+peek 65287:A1$(0)="1C3E3E3614"
50030 BA=0:dim B1$(0)*10:BA=256*peek 65288+peek 65287:B1$(0)="14363E3E1C"
50040 gosub 51110:rem INTRO
50050 input "Explanations (Y/N) ? ";S$:if S$="Y" gosub 51320:rem EXPLANATION
50060 clear :print "Creating Laby 1 (50s)...":call &4B8
50070 LA=0:dim L1$(0)*34:LA=256*peek 65288+peek 65287
50080 VA=0:dim V1$(0)*32:VA=256*peek 65288+peek 65287
50090 BA=0:dim B1$(0)*10:BA=256*peek 65288+peek 65287
50100 dim A1$(6)*34:dim F(7),W1(16):T=0:V=2
50110 WA=0:dim W2$(0)*34:WA=256*peek 65288+peek 65287
50120 V1$(0)="07050500070500070505"
50130 PA=0:dim P1$(5)*10:PA=256*peek 65288+peek 65287
50140 P1$(3)="1C3E3E3614":P1$(2)="1C3E383E1C":P1$(4)="1C3E0E3E1C"
50150 P1$(1)="1C3E3E3E1C":P1$(5)="14363E3E1C"
50160 FA=0:dim F1$(0)*10:FA=256*peek 65288+peek 65287:F1$(0)="7E3B7F3B7E"
50170 gosub 51690
50180 for I=0 to 6:A1$(I)="":for J=0 to 16
50190 read A:if I=0 let W1(J)=0
50200 W1(J)=W1(J)+(A-1)*(2^I):rem MINI VIEW
50210 A1$(I)=A1$(I)+chr$ (456-A*207):rem DETAIL VIEW
50220 next J:next I:W2$(0)="":for I=0 to 16
50230 B=W1(I),A=int (B/16),B=B-16*A
50240 W2$(0)=W2$(0)+chr$ (A+48+7*(A>9))+chr$ (B+48+7*(B>9))
50250 next I
50260 read L2:rem NUMBER OF STARS
50270 H=4,P=8,TI=0
50280 wait 0:print "     READY":call &4B8
50290 poke 32964,18*5:poke 33105,LA-int (LA/256)*256,int (LA/256)
50295 call 33107:call &4B8
50300 for I=0 to 200:next I:poke 33448,1,168,10
50310 for I=0 to 4:call 33452:for J=0 to 30:next J:next I:gosub 50330
50320 goto 50410
50330 print A1$(H-1):call &4B8:TI=TI+1
50340 C=P:A=PA:gosub 51610:call &4B8
50350 C=F(H):A=FA:gosub 51610:call &4B8
50360 poke 32964,5*21:F=2^(H-1):poke 33037,F:call 33036:poke 33037,F*2+F/2
50370 call 33036:poke 33037,F:call 33036:call 33036:call 33036
50380 C=17:A=WA:gosub 51610:call &4B8
50390 A=20:poke 33450,10:I=int (A*4.437138-19.81)
50400 poke 33448,int I-256*int (I/256),(I/256):call 33452:return 
50410 S$=inkey$ :if S$="I" then 50550
50420 if S$="P" then 50490
50430 if S$="Q" then 50460
50440 if S$="Z" then 50520
50450 P1$(0)=P1$(1):goto 50570
50460 P1$(0)=P1$(2),A=H,H=H-1:if H=0 let H=7
50470 if 249=asc mid$ (A1$(H-1),P+1,1) let H=A
50480 goto 50580
50490 P1$(0)=P1$(3),A=P,P=P+1:if P=17 let P=0
50500 if 249=asc mid$ (A1$(H-1),P+1,1) let P=A
50510 goto 50570
50520 P1$(0)=P1$(4),A=H,H=H+1:if H=8 let H=1
50530 if 249=asc mid$ (A1$(H-1),P+1,1) let H=A
50540 goto 50580
50550 P1$(0)=P1$(5),A=P,P=P-1:if P=-1 let P=16
50560 if 249=asc mid$ (A1$(H-1),P+1,1) let P=A
50570 F(H)=F(H)+sgn (P-F(H)):if F(H)=P then 50610
50580 if "*"=mid$ (A1$(H-1),P+1,1) gosub 51650:if K=L2 then 51180
50590 gosub 50330:goto 50410
50600 rem GOTCHA
50610 wait 0:poke 33448,1,168,10:for I=0 to 9
50620 call 33452:for J=0 to 30:next J:next I
50630 print " ":poke 33448,0,0,80:call 33452
50640 V1$(0)="1C3E3E3E1C":C=P:A=VA:gosub 51610:call &4B8:restore 51060
50650 for I=1 to 11:read V1$(0):A=VA:gosub 51610:call &4B8
50660 read A,B:A=int (A*4.437138-19.81)
50670 poke 33448,int A-256*int (A/256),(A/256),10:call 33452:next I
50680 I=int (K/(20-TI*0.04)),SC=SC+I*(I>0):TI=0
50690 wait 100:if V>0 then 50720
50700 print "SCORE: ";SC
50710 print "   *** GAME OVER ***":goto 50000
50720 print "SCORE: ";SC;" LIFES: ";V
50730 V=V-1,H=4,P=8:for I=1 to 7:F(I)=0:next I:goto 50280
50740 data 218,208,105,419,140,313,170,262,105
50745 data 419,140,313,170,524,198,220,96,444
50750 data 132,332,160,278,96,444,132,332,160,556
50755 data 218,208,105,419,140,313,170,262
50760 data 105,419,140,313,170,655,160,139,140,313
50765 data 150,148,140,157,125,351,132,166
50770 data 125,176,109,395,118,187,109,198,105,419
50780 data 1,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,1
50790 data 2,2,2,1,1,2,2,2,2,2,2,2,1,1,2,2,2
50800 data 1,2,2,1,2,2,2,1,1,1,2,2,2,1,2,2,1
50810 data 1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1
50820 data 1,2,2,1,2,2,2,1,1,1,2,2,2,1,2,2,1
50830 data 2,2,2,1,1,2,2,2,2,2,2,2,1,1,2,2,2
50840 data 1,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,1,89
50850 data 1,2,2,2,2,1,2,2,2,2,2,1,2,2,2,2,1
50860 data 1,2,2,1,2,1,2,2,2,2,2,1,2,1,2,2,1
50870 data 1,1,2,2,2,2,2,1,1,1,2,2,2,2,2,1,1
50880 data 2,2,2,1,1,2,2,2,2,2,2,2,1,1,2,2,2
50890 data 1,1,2,2,2,2,2,1,1,1,2,2,2,2,2,1,1
50900 data 1,2,2,1,2,1,2,2,2,2,2,1,2,1,2,2,1
50910 data 1,2,2,2,2,1,2,2,2,2,2,1,2,2,2,2,1,81
50920 data 1,2,2,2,2,1,1,2,2,2,1,1,2,2,2,2,1
50930 data 1,2,2,1,2,2,2,2,1,2,2,2,2,1,2,2,1
50940 data 1,2,2,2,2,2,1,1,1,1,1,2,2,2,2,2,1
50950 data 1,1,1,2,2,2,2,2,2,2,2,2,2,2,1,1,1
50960 data 1,2,2,2,2,2,1,1,1,1,1,2,2,2,2,2,1
50970 data 1,2,2,1,2,2,2,2,1,2,2,2,2,1,2,2,1
50980 data 1,2,2,2,2,1,1,2,2,2,1,1,2,2,2,2,1,77
50990 data 1,2,2,2,1,1,2,2,1,2,2,1,1,2,2,2,1,
51000 data 2,2,2,2,2,1,2,2,1,2,2,1,2,2,2,2,2
51010 data 1,2,2,2,2,1,2,1,1,1,2,1,2,1,1,1,1
51020 data 1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1
51030 data 1,2,2,2,1,1,2,2,2,2,2,1,2,1,1,1,1
51040 data 2,2,2,2,1,1,2,2,1,2,2,1,2,2,2,2,2
51050 data 1,2,2,2,1,1,2,2,1,2,2,1,1,2,2,2,1,75
51060 data "1C3E3E3E1C",105,300,"183C3E3C18",105,300,"10383E3810",105,90
51070 data "00303E3000",105,270,"00203E20",82,300,"00003E00",93,90
51080 data "00003C",93,270,"000038",105,90,"000030",105,270,"000020",112,90
51090 data "000040",105,540,"1C3E3E3E1C"
51100 rem INTRO
51110 print "        GLOUPMAN":for I=0 to 5
51120 poke 32964,I*5:poke 33105,AA-int (AA/256)*256,int (AA/256)
51125 call 33107
51130 poke 32964,(I+18)*5:poke 33105,BA-int (BA/256)*256,int (BA/256)
51135 call 33107
51140 next I:poke 33450,10:restore 50740:call &4B8
51150 for I=1 to 32:read A,B:A=int (A*4.437138-19.81)
51160 poke 33448,int A-256*int (A/256),(A/256):call 33452:next I
51170 return 
51180 restore 50740:A$="1C2222221C",B$="001C1C1C00":wait 0:J=0
51185 for I=30 to 0 step -2
51190 poke 33448,int I-256*int (I/256),(I/256),10:call 33452:next I
51200 I=int (K/(20-TI*0.04)),SC=SC+I*(I>0):SC=SC+I:K=0:TI=0
51210 wait 150:print "SCORE: ";SC:B1$(0)="7E3B7F3B7E":wait 0:print ""
51220 poke 33037,8:for I=1 to 15:poke 32964,5*I:call 33036:next I
51230 P1$(0)=P1$(5),A=PA,J=0:for I=23 to 0 step -1
51240 C=I:gosub 51610:call &4B8:J=J+1
51250 poke 33448,int J-256*int (J/256),(J/256),10:call 33452
51260 A=BA:gosub 51610:call &4B8:next I
51270 beep 1:print " "
51280 V=V+1:print "LIFES: ";SC
51290 T=T+1,S$=chr$ (T+asc "1"):print "Creating Laby ";S$;" (50s)..."
51295 call &4B8
51300 for I=0 to 7:F(I)=0:next I:goto 50170
51310 rem Explanations
51320 wait 0:A=AA:print "You are:  . Eat the ";chr$ 34;"*";chr$ 34
51330 A1$(0)="1C3E3E3E1C":C=9:gosub 51610:W=150:gosub 51630
51340 wait 0:print "and avoid the ghosts: "
51350 A1$(0)="7E3B7F3B7E":C=22:gosub 51610:gosub 51630
51360 print "Infos on the screen:"
51370 print "The laby where you are:"
51380 wait 0:print "(1)        (2)"
51390 A1$(0)="227F7F495D7F7F6B2A6B7F7F5D497F7F22"
51400 C=4:gosub 51610
51410 A1$(0)="086B7F55771C7F6B6B6B7F1C77557F6B08"
51420 C=15:gosub 51610:gosub 51630:wait 0:print "(3)        (4)"
51430 A1$(0)="0077775D7F3E2A6B496B2A3E7F5D777700"
51440 C=4:gosub 51610
51450 A1$(0)="227F7F7F0E087F7B187B7F083E63636322"
51460 C=15:gosub 51610:gosub 51630:wait 0:print "Current row in laby:"
51470 A1$(0)="0808081408":C=21:gosub 51610:W=100:gosub 51630
51480 print "And the detail of the":print "row where you are in the"
51485 print "laby."
51490 wait 0:print "There is 1   per row..."
51500 A1$(0)="7E3B7F3B7E":C=11:gosub 51610:gosub 51630
51510 print "and it goes through":print "walls!":print "Movement with keys:"
51520 wait 0:print "  (I)              (P)":A1$(0)="14363E3E1C":C=0
51525 gosub 51610
51530 A1$(0)="1C3E3E3614":C=23:gosub 51610:W=150:gosub 51630
51540 wait 0:print "  (Q)              (Z)":A1$(0)="1C3E383E1C":C=0
51545 gosub 51610
51550 A1$(0)="1C3E0E3E1C":C=23:gosub 51610:gosub 51630
51560 wait 100:print "Note: 2 tunnels in"
51570 print "Laby #1, only 1 in":print "Laby #2, NONE in L#3,"
51580 print "and 2 in L#4. 1 extra":print "life per level..."
51590 print "      GOOD LUCK !":return 
51600 rem GPRINT,A=ADR,C=CURSOR
51610 poke 32964,5*C:poke 33105,A-int (A/256)*256,int (A/256)
51615 call 33107:return 
51620 rem WAIT,T=TIME
51630 wait W:for I=20 to W:call &4B8:next I:return 
51640 rem ERASE STAR
51650 let K=K+1,A1$(H-1)=left$ (A1$(H-1),P)+" "+right$ (A1$(H-1),16-P)
51660 A=8:poke 33450,10:I=int (A*4.437138-19.81)
51670 poke 33448,int I-256*int (I/256),(I/256):call 33452:return 
51680 rem MAP LEVELS TO DATA LINES
51690 if T>3 let T=T-4*int (T/4)
51700 if T>2 restore 50990
51710 if T=2 restore 50920
51720 if T=1 restore 50850
51730 if T<1 restore 50780
51740 return 
51750 rem CHECK PRESENCE OF PETOOLS
51760 V=1,W=0:wait 300:if 8<>peek &8030 or 15<>peek &8031 then 51810
51770 A=1000*peek &8032
51780 A=A+peek &8033
51790 if A<1000*V+W then 51810
51800 return 
51810 print "This program requires"
51820 using "&&&&&&&##.##"
51830 print "PETOOLS";V+W/100
51840 using :print " or higher":end 