  300 "F" CLEAR : DIM X(39): PRINT "Aurora
  301 RADIAN
  310 C=.0174532926:F=3.81971862
  311 GOTO 400
  315 L=280.46+.9856474*T:G=357.528+.9856003*T:G=C*G
  316 I=L+1.915*SIN (G)+.02*SIN (2*G):K=0:I=I-INT (I/360)*360
  317 RETURN
  320 E=23.452-.01301*T-.0000016*T*T+.0000005*T*T*T:E=C*E
  321 X=COS (B)*COS (L):Y=COS (B)*SIN (L)*COS (E)-SIN (B)*SIN (E)
  322 Z=COS (B)*SIN (L)*SIN (E)+SIN (B)*COS (E):R=ATN (Y/X)
  323 IF X<0 LET R=R+X(0)
  324 IF X>0 AND Y<0 LET R=R+X(1)
  325 O=ATN (Z/SQR (X*X+Y*Y)):x(31)=O*(180/3.141592654)
  326 RETURN
  330 P=Q:J=V:M=N
  331 IF M<3 LET M=M+12,J=J-1
  332 A=INT (J/100):B=2-A+INT (A/4)
  333 X(24)=INT (365.25*J)+INT (30.6001*(M+1))+P+B+1720994.5
  334 RETURN
  350 W=-105.1*SIN (L)+596.2*SIN (2*L)+4.3*SIN (3*L)-12.7*SIN (4*L)
  351 W=W-429.2*COS (L)-2.1*COS (2*L)+19.3*COS (3*L):W=W/3600
  352 RETURN
  360 IF X(2)>-7.5 LET X(3)=INT ((X(2)+7.5)/15)*15
  361 IF X(2)<=-7.5 LET X(3)=-INT (-(X(2)-7.5)/15)*15
  362 RETURN
  400 INPUT "Year (0=2024):";V: INPUT "Month:";N: INPUT "Day:";Q
  401 if v=0 let v=2024
  402 Input "1-A 2-B 3-C:";x(32)
  403 U=51.42:X(2)=-7.55:if x(32)=2 let U=-42.7:x(2)=-27.76
  404 if x(32)=3 let U=54.53:x(2)=-9.55
  405 x(37)=U
  406 U=C*U
  407 GOSUB 360: GOSUB 330
  408 X(24)=X(24)+.5+X(3)/360:T=X(24)-2451545
  409 GOSUB 315:L=C*I:B=C*K: GOSUB 350
  410 T=(X(24)-2415020)/36525: GOSUB 320:D=-W+(X(2)-X(3))/15:Z=90.833*C
  411 GOSUB 500:X(4)=T:Z=96*C: GOSUB 500:X(5)=T:Z=102*C
  412 GOSUB 500:X(6)=T:Z=108*C: GOSUB 500:X(7)=T
  413 X(8)=0:X(12)=0:X(9)=0:X(13)=0:X(10)=0:X(14)=0:X(11)=0:X(15)=0
  414 IF X(4)<>0 LET X(8)=12-X(4)+D:X(12)=12+X(4)+D
  415 IF X(5)<>0 LET X(9)=12-X(5)+D:X(13)=12+X(5)+D
  416 IF X(6)<>0 LET X(10)=12-X(6)+D:X(14)=12+X(6)+D
  417 IF X(7)<>0 LET X(11)=12-X(7)+D:X(15)=12+X(7)+D
  418 X(16)=INT ((X(8)-INT (X(8)))*60+.5):if x(16)=60 let x(16)=0: x(8)=x(8)+1
  419 X(17)=INT ((X(12)-INT (X(12)))*60+.5):if x(17)=60 let x(17)=0: x(12)=x(12)+1
  420 X(18)=INT ((X(9)-INT (X(9)))*60+.5):if x(18)=60 let x(18)=0: x(9)=x(9)+1
  421 X(19)=INT ((X(13)-INT (X(13)))*60+.5):if x(19)=60 let x(19)=0: x(13)=x(13)+1
  424 X(21)=INT ((X(11)-INT (X(11)))*60+.5):if x(21)=60 let x(21)=0: x(11)=x(11)+1
  425 X(22)=INT ((X(15)-INT (X(15)))*60+.5):if x(22)=60 let x(22)=0: x(15)=x(15)+1
  426 s=60-x(16):x(33)=int(x(8))+1
  427 if x(33)>23 let x(33)=x(33)-24
  428 h=int(x(12))-x(33):s=s+x(17)
  429 x(34)=h/2+x(8):x(35)=s/2+x(16)
  430 if x(34)<>int(x(34)) let x(35)=x(35)+30
  431 x(35)=int(x(35))
  432 if x(35)>59 let x(35)=x(35)-60:x(34)=x(34)+1
  433 if x(34)>23 let x(34)=x(34)-24
  434 if x(34)<0 then x(34)=x(34)+1
  435 x(36)=90-x(37)+x(31):if x(36)>90 let x(36)=x(36)-90:x(36)=90-x(36)
  436 x(38)=I/15:x(39)=x(38)-int(I/15):x(39)=x(39)*60:x(39)=int(x(39)):x(38)=int(x(38))
  446 A$=LEFT$ (STR$ X(8),1):B$=RIGHT$ ("0"+STR$ X(16),2):C$=LEFT$ (STR$ X(12),2):D$=RIGHT$ ("0"+STR$ X(17),2)
  447 PRINT "Rise Set ";A$;":";B$;"-";C$;":";D$
  448 A$=LEFT$ (STR$ X(11),1):B$=RIGHT$ ("0"+STR$ X(21),2):C$=LEFT$ (STR$ X(15),2):D$=RIGHT$ ("0"+STR$ X(22),2)
  449 PRINT "Astron. TwiL ";A$;":";B$;"-";C$;":";D$
  450 A$=LEFT$ (STR$ X(9),1):B$=RIGHT$ ("0"+STR$ X(18),2):C$=LEFT$ (STR$ X(13),2):D$=RIGHT$ ("0"+STR$ X(19),2)
  452 PRINT "Civil TwiL ";A$;":";B$;"-";C$;":";D$
  456 A$=left$(STR$ x(34),2):b$=right$ ("0"+STR$ x(35),2):c$=left$(str$ x(36),5)
  457 print "Noon-Height ";a$;":";b$;" ";c$
  458 a$=left$(str$ x(31),5):b$=right$("0"+str$ x(38),2)+"h":c$=right$("0"+str$ x(39),2)+"m"
  459 PRINT "Dekl:";a$;" Rekt:";b$;" ";c$
  460 GOTO 300
  500 IF Z>180*C-O-U LET T=0
  501 X(26)=(COS (Z)-SIN (U)*SIN (O))/COS (U)/COS (O)
  502 IF X(26)<=1 AND X(26)>=-1 LET T=1.57079633-ATN (X(26)/SQR (1-X(26)*X(26))):T=F*T
  503 RETURN