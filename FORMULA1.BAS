50000 gosub 50040:goto 50110
50010 rem Do not use std. vars. N - P
50020 rem 64361 is loopcnt
50030 rem 64371 is delay
50040 poke 64360,2,255,52,18,95,89,101,16
50050 poke 64368,219,223,78,55,47,5,55
50060 return 
50070 poke 64352,16,&FB,&71,18,95,89,101,16
50080 poke 64360,218,2,255,52,218,219,218,223
50090 poke 64368,78,0,91,52,82,47,10,55
50100 return 
50110 "FORMULA1":goto 50150
50120 wait 90:print ""
50130 print "Q) up, Z) down, S)core"
50140 return 
50150 wait 100:print "*** Formula 1 *** H)elp"
50160 call &1494:T$=inkey$ 
50170 if T$<>"H" then 50190
50180 gosub 50120:goto 50150
50190 wait 1:print " ":random 
50200 A=0:B=0:C=0:D=0:E=0:F=0:G=0:H=0:I=0:L=0
50210 U=0:W=0:Y=0
50220 T$=inkey$ 
50230 if T$="Q" let Z=Z-1
50240 if T$="Z" let Z=Z+1
50250 if T$<>"S" then 50280
50260 print "            Score: ";L
50270 I=5
50280 if Z=-1 let Z=0
50290 if Z=7 let Z=6
50300 X=2^Z
50310 J=2^(Z-1)*5
50320 if J=2.5 let J=2
50330 if J=160 let J=32
50340 K=2^(Z-1)*7
50350 if K=3.5 let K=3
50360 if K=224 let K=96
50370 call 1208
50380 poke 12323,X,J,(X+H),(X+H),K
50390 L=L+1
50400 H=Y
50410 if X=H then 50630
50420 Y=W:W=U:U=G:G=F:F=E:E=D:D=C:C=B:B=A
50430 V=rnd (7):A=2^(V-1):TM=rnd (500)
50440 if L<TM then 50480
50450 TM=rnd (7)
50460 if TM=V then 50480
50470 A=A+2^(TM-1)
50480 if I=0 then 50500
50490 I=I-1:if I=0 print "                    "
50500 call 1208
50510 poke 12288,0,0,A,A,0
50520 poke 12293,0,0,B,B,0
50530 poke 12298,0,0,C,C,0
50540 poke 12303,0,0,D,D,0
50550 poke 12308,0,0,E,E,0
50560 poke 12313,0,0,F,F,0
50570 poke 12333,0,0,G,G,0
50580 poke 12338,0,0,U,U,0
50590 poke 12343,0,0,W,W,0
50600 poke 12318,0,0,Y,Y,0
50610 poke 12323,X,J,(X+H),(X+H),K
50620 goto 50220
50630 call 1208
50640 poke 12318,41,74,32,64,29,28,92,2,41,69
50650 for I=1 to 255:next I
50660 poke 12318,127,127,127,127,127,127,127,127,127,127
50670 wait 60:print "  *** Crash *** "
50680 for I=100 to 159 step 4
50690 poke 64361,255:poke 64371,I:call 64360
50700 next I
50710 pause "You have ";L:pause "   points!"
50720 if L>M then 50750
50730 print "High score: ";M
50740 goto 50820
50750 gosub 50070:for I=1 to 5
50760 call 64352
50770 next I
50780 gosub 50010
50790 print "You are the best!"
50800 print "High score: ";L
50810 M=L
50820 print "Once more (Y/N)?"
50830 call &1494:T$=inkey$ 
50840 if T$="Y" then 50190
50850 if T$="N" then 50870
50860 goto 50820
50870 print "Good bye!"
50880 end 