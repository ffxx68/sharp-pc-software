50000 "D" clear :gosub 50770:W=60:wait W:print "*** PEDEMO ***"
50010 print "Shows the possibillities"
50020 using "&&&&&&&##.##"
50030 print "PETOOLS";X+Y/100
50040 using :print "1. Read or write the"
50050 print "CAL-mode memory:":call 32820
50060 print "It is ";M
50070 wait 0:print "2. Flash the display !":call 32862:wait W
50080 print "3. Reading display"
50090 print "columns:"
50100 wait 0:dim V(4):print "A":for I=0 to 4
50110 poke 32972,I:call 32971:V(I)=peek 32965:next I
50120 wait W:S$=","
50130 print "A=";str$ V(0);S$;str$ V(1);S$;str$ V(2);S$;str$ V(3);S$;str$ V(4)
50140 print "4. Desaster recovery:"
50150 print "In case of an accidental"
50160 print "NEW-command just type"
50170 print "CALL 33000":A=peek &FF01:B=peek &FF02
50180 print "In case of an accidental"
50190 print "ALL RESET just type"
50200 print "POKE &FF01,";str$ A;",";str$ B;" and"
50210 print "CALL 33000"
50220 print "5. Graphics PRINT"
50230 print "Single columns:"
50240 wait 0:print " ":call 33238:rem  GMODE replace
50250 poke 32964,0:rem GCURSOR=0
50260 call &4B8:rem Display on
50270 for I=1 to 24
50280 poke 33037,&1C:call 33036:poke 33037,&3E:call 33036
50290 poke 33037,&3E:call 33036:poke 33037,&36:call 33036
50300 poke 33037,&14:call 33036:next I:for I=1 to 200:next I
50310 wait W:print "Using std. variables:"
50320 wait 0:print " ":call 33238:rem  GMODE replace
50330 poke 32964,0:rem GCURSOR=0
50340 call &4B8:rem Display on
50350 S$="1C3E3E":T$="3614":for I=1 to 24
50360 poke 33081,19:call 33078:poke 33081,20:call 33078
50370 next I:for I=0 to 200:next I
50380 wait W:print "Using field variables:"
50390 wait 0:print " ":call 33238:rem  GMODE replace
50400 poke 32964,0:rem GCURSOR=0
50410 call &4B8:rem Display on
50420 dim BM$(0)*60
50430 A=256*peek 65288+peek 65287
50440 BM$(0)="1C3E3E36141C3E3E36141C3E3E36141C3E3E36141C3E3E36141C3E3E3614"
50450 poke 33105,A-int (A/256)*256,int (A/256):for I=1 to 4
50460 call 33107:next I:for I=0 to 200:next I:wait W
50470 print "6. Fast graphics FILL":call &4B8
50480 call 33270:rem  Invert mode
50490 poke 32965,&7F:rem  The fill pattern
50500 for I=1 to 11
50510 call 33330:for J=0 to 60:next J:next I
50520 call 33288:rem  Mask mode
50530 poke 32965,&2A:rem  The fill pattern
50540 for I=0 to 11
50550 poke 32966,I*10:poke 32967,10+I*10
50560 call 33330:next I
50570 poke 32965,&55:rem  The fill pattern
50580 for I=0 to 11
50590 poke 32966,I*10:poke 32967,10+I*10
50600 call 33330:next I
50610 wait W:goto 50630
50620 print "7.    SCROLLCLEAR":return 
50630 gosub 50620:call 33363
50640 gosub 50620:call 33369
50650 gosub 50620:call 33375
50660 gosub 50620:call 33381
50670 wait W:print "8. Extended BEEP"
50680 restore 50720:call &4B8:poke 33450,10:rem  BEEP Duration
50690 for I=1 to 32:read A:A=int (A*4.437138-19.81)
50700 poke 33448,int A-256*int (A/256),(A/256):call 33452:next I
50710 print "    *** The End ***":end 
50720 data 218,105,140,170,105,140,170,198,96
50730 data 132,160,96,132,160,218,105,140,170
50740 data 105,140,170,160,140,150,140,125,132
50750 data 125,109,118,109,105
50760 rem CHECK PRESENCE OF PETOOLS
50770 X=1,Y=0:wait 300:if 8<>peek &8030 or 15<>peek &8031 then 50820
50780 A=1000*peek &8032
50790 A=A+peek &8033
50800 if A<1000*X+Y then 50820
50810 return 
50820 print "This program requires"
50830 using "&&&&&&&##.##"
50840 print "PETOOLS";X+Y/100
50850 using :print " or higher":end 