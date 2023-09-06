50000 "D" clear :gosub 50840:W=peek 32968:wait W:print "*** PEDEMO ***"
50010 print "Shows the possibillities"
50020 rem using "&&&&&&&##.##"
50030 print "of PETOOLS ";str$ (X+Y/100)
50040 using :print "1. Read or write the"
50050 print "CAL-mode memory:":call 32820
50060 print "It is ";M
50070 wait 0:print "2. Flash the display !":call 32862:wait W
50080 wait W
50090 print "3. Desaster recovery:"
50100 print "In case of an accidental"
50110 print "NEW-command just type"
50120 print "CALL 33000":A=peek &FF01:B=peek &FF02
50130 print "In case of an accidental"
50140 print "ALL RESET just type"
50150 print "POKE &FF01,";str$ A;",";str$ B;" and"
50160 print "CALL 33000"
50170 print "4. Graphics PRINT"
50180 print "Single columns:"
50190 wait 0:print " ":call 33238:rem  GMODE replace
50200 poke 32964,0:rem GCURSOR=0
50210 call &4B8:rem Display on
50220 for I=1 to 24
50230 poke 33037,&1C:call 33036:poke 33037,&3E:call 33036
50240 poke 33037,&3E:call 33036:poke 33037,&36:call 33036
50250 poke 33037,&14:call 33036:next I:for I=1 to 200:next I
50260 wait W:print "Using std. variables:"
50270 wait 0:print " ":call 33238:rem  GMODE replace
50280 poke 32964,0:rem GCURSOR=0
50290 call &4B8:rem Display on
50300 S$="1C3E3E":T$="3614":for I=1 to 24
50310 poke 33081,19:call 33078:poke 33081,20:call 33078
50320 next I:for I=0 to 200:next I
50330 wait W:print "Using field variables:"
50340 wait 0:print " ":call 33238:rem  GMODE replace
50350 poke 32964,0:rem GCURSOR=0
50360 call &4B8:rem Display on
50370 dim BM$(0)*60
50380 A=256*peek 65288+peek 65287
50390 BM$(0)="1C3E3E36141C3E3E36141C3E3E36141C3E3E36141C3E3E36141C3E3E3614"
50400 poke 33105,A-int (A/256)*256,int (A/256):for I=1 to 4
50410 call 33107:next I:for I=0 to 200:next I:wait W
50420 print "5. Fast graphics FILL":call &4B8
50430 call 33270:rem  Invert mode
50440 poke 32965,&7F:rem  The fill pattern
50450 for I=1 to 11
50460 call 33330:for J=0 to 60:next J:next I
50470 call 33288:rem  Mask mode
50480 poke 32965,&2A:rem  The fill pattern
50490 for I=0 to 11
50500 poke 32966,I*10:poke 32967,10+I*10
50510 call 33330:next I
50520 poke 32965,&55:rem  The fill pattern
50530 for I=0 to 11
50540 poke 32966,I*10:poke 32967,10+I*10
50550 call 33330:next I
50560 wait W:goto 50580
50570 print "6.    SCROLLCLEAR":return 
50580 gosub 50570:call 33363
50590 gosub 50570:call 33369
50600 gosub 50570:call 33375
50610 gosub 50570:call 33381
50620 wait 0:print "7. Graphics":S$="Text":call &4B8
50630 call 33238:rem gmode replace
50640 poke 33740,19:rem Use S$
50650 for I=95 to 60 step -1:poke 32964,I:rem graphics cursor
50660 call 33737:next I:rem gtext
50670 wait W:call 33935:rem gwait
50680 wait W:print "8. Extended BEEP"
50690 restore 50790:call &4B8:poke 33450,10:rem  BEEP Duration
50700 for I=1 to 32:read A:A=int (A*4.437138-19.81)
50710 poke 33448,int A-256*int (A/256),(A/256):call 33452:next I
50720 wait W:print "9. Read the keyboard":wait 0:I=256:J=10
50730 call 33840:if I=peek 65374 goto 50730
50740 I=peek 65374:print "Keycode is ";I:call &4B8
50750 J=J-1:if J>0 goto 50730
50760 wait 1.6*W:print "10. Serial Port Ext.":S$="Not i":if peek &84CF let S$="I"
50770 print S$;"nstalled !!!"
50780 wait W:print "    *** The End ***":end 
50790 data 218,105,140,170,105,140,170,198,96
50800 data 132,160,96,132,160,218,105,140,170
50810 data 105,140,170,160,140,150,140,125,132
50820 data 125,109,118,109,105
50830 rem CHECK PRESENCE OF PETOOLS
50840 X=1,Y=10:wait 300:if 8<>peek &8030 or 15<>peek &8031 then 50890
50850 A=1000*peek &8032
50860 A=A+peek &8033
50870 if A<1000*X+Y then 50890
50880 return 
50890 print "This program requires"
50900 using "&&&&&&&##.##"
50910 print "PETOOLS";X+Y/100
50920 using :print " or higher":end 