50000 "DONKEY":rem Hebdogiciel #86
50010 "K" gosub 50800:wait 0:print "    **DONKEY-KONG**":call &4B8:for O=8 to 22:M=2:gosub 50750:next O
50020 A=O:clear :TA=0:dim TM$(0)*18:TA=256*peek 65288+peek 65287
50030 BA=0:dim GB$(11)*10:BA=256*peek 65288+peek 65287
50040 LA=0:dim LS$(0)*16:LA=256*peek 65288+peek 65287
50050 print " (1) Rules (2) Game":call &4B8
50060 R=val inkey$ :if R=2 then 50090
50070 if R=1 gosub 50590:goto 50090
50080 goto 50060
50090 print " ":P=15,E=3000,C=2,X=3,Y=23,GB$(11)="2A1C31C2A"
50100 GB$(1)="0050385000",GB$(2)="7F523A527F",LS$(0)="07456C1F1F6C4507"
50110 GB$(3)="7F2A272A7F",GB$(4)="7F2A2B2A7F",GB$(5)="0002030200"
50120 GB$(6)="00327B7A30"
50130 GB$(7)="0030787830",GB$(8)="7F3A7A7A7F",GB$(9)="7F2A2A2A7F"
50140 GB$(10)="7F3A7B3A7F"
50150 H=rnd 12+5
50160 X=X+1,Y=Y-1,E=E-10:if X=23 let X=3,Y=22
50170 R=asc inkey$ ,S=1,T=7,U=T,V=9
50180 if E=0 then 50510
50190 if R=52 and P>3 let P=P-1,A=A+2:M=1,O=99:gosub 50750
50200 if R=54 and P<23 let P=P+1,A=A+2:M=1,O=99:gosub 50750
50210 if R=53 let S=5:M=1,O=60:gosub 50750
50220 if X=H let T=8,V=T
50230 if Y=H let U=8,V=U
50240 if P=H let S=2:if R=56 let S=3,V=S,N=N+1,A=A+N*5:M=1,O=130:gosub 50750:goto 50350
50250 if P=H and R=53 let S=4,V=S
50260 if P=X and R<>53 let S=11,T=S,C=C-1:gosub 50310:goto 50490
50270 if P=Y and R<>53 let S=11,U=S,C=C-1:gosub 50310:goto 50490
50280 if X=P let S=6,T=S,A=A+50:if P=H let S=10,T=S,V=S
50290 if Y=P let S=6,U=S,A=A+50:if P=H let S=10,U=S,V=S
50300 M=1,O=234:gosub 50750:gosub 50310:goto 50160
50310 print " ";str$ N:call &4B8:L=H,K=BA:GB$(0)=GB$(V):gosub 50780:L=P:GB$(0)=GB$(S):gosub 50780
50320 L=X:GB$(0)=GB$(T):gosub 50780
50330 L=Y:GB$(0)=GB$(U):gosub 50780:gosub 50690
50340 return 
50350 gosub 50310:for D=0 to 20:next D:if N<10 goto 50150
50360 beep 5:A=A+200
50370 print " ":call &4B8:C=C-1,B=12,H=24,L=1,GB$(0)=GB$(1)
50380 print " ":call &4B8:L=1:K=TA:TM$(0)="7F557F557F7D7F08":gosub 50780:L=B:K=BA:gosub 50780
50390 L=H,K=LA:gosub 50780:R=asc inkey$ :M=1,O=234:gosub 50750:if H<=B then 50440
50400 if B=1 then 50470
50410 if R=52 let B=B-1:M=1,O=99:gosub 50750
50420 if R=54 let B=B+1
50430 H=H-2:goto 50380
50440 for I=0 to 7:poke 32964,5*H:TM$(0)="0000000000000000":gosub 50730
50450 poke 32964,5*B:TM$(0)="07155C5F5F5C150F":gosub 50730:M=1,O=234
50460 gosub 50750:poke 32964,5*B:TM$(0)=LS$(0):gosub 50730:next I:goto 50490
50470 print "   My saviour!":poke 32964,5:TM$(0)="060F1F3E1F0F06":gosub 50730:call &4B8
50480 for I=0 to 400:next I:A=A+100,J=1:goto 50490
50490 M=30,O=20:gosub 50750:if C>-1 let N=0:goto 50150
50500 print " ":if J=1 goto 50530
50510 if J=0 print "YOU LOST!":call &4B8:M=5,O=100:gosub 50750:print "SCORE:";A:call &4B8
50520 M=10,O=100:gosub 50750:goto 50560
50530 print "YOU WON!":call &4B8:M=5,O=100:gosub 50750:print "SCORE:";A;" BONUS:";E:call &4B8
50540 M=10,O=100:gosub 50750:print "** FINAL SCORE:";A+E;" **":call &4B8
50550 M=10,O=100:gosub 50750
50560 beep 1:input "PLAY AGAIN (Y/N) ? ";F$:if left$ (F$,1)="Y" then 50090
50570 poke 12348,0:end 
50580 rem RULES
50590 pause "10 levels to climb...":K=TA:L=15
50600 pause "Left/Right: <4>/<6>"
50610 pause "Up: <8>"
50620 pause "Jump: <5>"
50630 pause "Up there, beware of !"
50640 pause "Lives are displayed by":poke 12348,24
50650 pause "the MATRIX and STAT"
50660 pause "indicator"
50670 poke 12348,0:return 
50680 rem PRINT NUMBER OF LIFES
50690 if C=1 poke 12348,16:return 
50700 if C>1 poke 12348,24:return 
50710 poke 12348,0:return 
50720 rem GPRINT TM$(0)
50730 poke 33105,TA-int (TA/256)*256,int (TA/256):call 33107:call &4B8:return 
50740 rem BEEP,M=CNT,O=FREQ
50750 for Q=1 to M:W=int (O*4.437138-19.81)
50760 poke 33448,int W-256*int (W/256),(W/256),10:call 33452:next Q:return 
50770 rem GPRINT,K=ADR,L=CURSOR
50780 poke 32964,5*L:poke 33105,K-int (K/256)*256,int (K/256):call 33107:return 
50790 rem CHECK PRESENCE OF PETOOLS
50800 V=1,W=0:wait 300:if 8<>peek &8030 or 15<>peek &8031 then 50850
50810 A=1000*peek &8032
50820 A=A+peek &8033
50830 if A<1000*V+W then 50850
50840 return 
50850 print "This program requires"
50860 using "&&&&&&&##.##"
50870 print "PETOOLS";V+W/100
50880 using :print " or higher":end 