1 REM Non repeating random numbers
2 REM TINY MERSENNE TWISTER
3 REM By Zumstein Patrick
4 REM Tested on PC-1403 by F Fumi 5/9/2023

10 DIM mt(37)
20 LET UPPERM = 128
30 LET LOWERM = 127
40 LET TMB = 107
50 LET TMC = 128      
60 LET VL = 38
70 LET VM = 7

100 INPUT "Enter seed value: "; seed
110 GOSUB 600
120 LET r = 0
130 GOSUB 200
131 FOR r=1 to VL-1
132 LET mt(r) = (69*mt(r-1)) AND 127
133 NEXT R
135 FOR s = 1 TO VL-1
140 PRINT "Random number: "; mt(s)
145 NEXT s
150 END

200 REM generate rom number
210 IF mt(0) < 0 THEN GOSUB 400
220 LET y = mt(0)
230 LET y = y XOR (y / 11)
240 LET y = y XOR ((y * 7) AND TMB)
250 LET y = y XOR ((y * 15) AND TMC)
260 LET y = y XOR (y / 18)
270 LET mt(0) = y
280 RETURN

400 REM generate VL words at a time
410 LET kk = 0
420 IF mt(37) < 0 THEN GOSUB 600
430 IF mt(37) < 0 THEN GOSUB 600
440 IF mt(37) < 0 THEN GOSUB 600
450 FOR kk = 0 TO VL - VM - 1
460 LET y = (mt(kk) AND UPPERM) OR (mt(kk + 1) AND LOWERM)
470 LET mt(kk) = mt(kk + VM) XOR (y / 2) XOR ((y AND 1) * 107)
480 NEXT kk
490 LET kk = VL - VM
500 LET y = (mt(kk) AND UPPERM) OR (mt(0) AND LOWERM)
510 LET mt(kk) = mt(kk + (VM - VL)) XOR (y / 2) XOR ((y AND 1) * 107)
520 RETURN

600 REM initialize the generator
610 LET mt(0) = seed AND 255
620 FOR index = 1 TO VL - 1
630 LET mt(index) = (69 * mt(index - 1)) AND 255
640 NEXT index
650 RETURN