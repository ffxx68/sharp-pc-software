1"A": REM MATH DEMO
10 POKE 33000,128,16,128,250,0,11,25,120,129,6,128,16,128,250,0,11,24,55,0
20 POKE 33019,0,0,0,0,0,0,0,0,0,0,0,2,200,52,16,128,231,87,218,91,131,218
30 POKE 33041,69,218,52,2,3,52,16,128,229,87,218,91,120,129,103,218,91,131
40 POKE 33059,71,218,16,128,227,82,16,128,231,87,3,5,120,129,140,52,2,3,52
50 POKE 33078,16,128,227,87,218,91,131,70,91,131,68,218,16,128,229,82,2,1
60 POKE 33096,52,16,128,229,87,218,91,120,129,149,52,16,128,227,87,3,5,120
70 POKE 33114,129,103,218,91,131,218,69,218,16,128,231,82,55,134,96,0,135
80 POKE 33131,96,0,128,219,35,218,128,219,209,210,219,42,3,134,20,209,90,218
90 POKE 33149,90,218,128,99,0,56,3,45,20,135,219,218,134,219,55,194,195,56
100 POKE 33167,5,209,210,45,6,55,194,195,56,5,209,90,45,6,55
110 END
200 "B"
210 INPUT A: POKE 32995, A
220 INPUT B: POKE 32997, B
230 INPUT C: POKE 32999, C
240 CALL 33000