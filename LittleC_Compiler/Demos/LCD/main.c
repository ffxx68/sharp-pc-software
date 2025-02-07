#org 0xE030
byte *pb;
/*
Reserving 2 K on top of BASIC program memory:

PC-1403

NEW
MEM
 6878
POKE &FF01,&30,&E8 
NEW
MEM
 4830

 0xE030 to 0xE82F for ASM program (1865 bytes) 
 0xE830 ... BASIC
 
Machine code entry point at 0xE0E8 = 57576

*/

#define LCD_LEFT 0x3000
#define LCD_RIGHT 0x306C

byte regI at 0, regJ at 1;
char regA at 2, regB at 3; 
word regX at 4, regY at 6;

char xram mystring[13] = "Hello World!";

char readbyte(word adr)
{
	// overwriting X!
	regX = adr;
#asm
	DX
	IXL
#endasm
}

writebyte(word adr2, char byt)
{
	// overwriting Y!
	regY = adr2;
	regA = byt;
#asm
	DY
	IYS
#endasm
  return;
}
 
// using display routines from ROM (PC-1403)
puts(word  stradr) {
 
	// overwriting X!
	regX = stradr;

#asm
		; just like a C strncpy(X, P, 24)
		
		; fill destination with 24 blanks, beforehand
		LII   0x16
		LP	  0x10   ; destination start (internal ram)
		LIA	  0x20   ; blank
		FILM
		
;		LP	4			;  XL
;		LIA	LB(mystring) 
;		EXAM
;		LP	5			;  XH
;		LIA	HB(mystring)
;		EXAM
		DX
		LII  0x16      ; max size (23 chars, terminator excluded)
		LP	 0x10      ; destination
PUTS_LOOP1:	
		IXL            ; X -> DP; DP+1 -> DP, X; (DP) -> A 
		MVMD     	   ; (DP) -> (P)
		INCP
		CPIA    0x00   ; string end reached
		JRZP    PUTS_LB1
		DECI
		JRNZM   PUTS_LOOP1 ; until max size

PUTS_LB1:
		LIA		0x0D	; always terminate with newline char
		DECP
		EXAM
		LIJ 1			; needed
		
		; change memory bank to External ROM
		LIDP 0x3C00	; Read current bank#
		LDD
		PUSH		; save it to stack
		LIA  0x09   ; select bank #9
		STD
	
		; ROM entry point for the print
		CALL 0x4587
		
		POP			; Restore original bank#
		LIDP 0x3C00	; bankswitch
		STD			; and write it
#endasm

  return;
  
}

char getchar () {
#asm	
    CALL  0x1494        ; Syscall: wait for a keystroke (PC-1403)
#endasm
	return readbyte(0xFF5E); // get the key-code value stored in memory
}

/*

delay05() {
#asm
DELAY05_LOOP: 
	TEST  0x01          ; Test .5 s timer // THIS IS NOT EMULATED ON MAME!!!
	JRZM  DELAY05_LOOP
#endasm
}

flashlcd(byte num){
	
	for (regB=0;regB<num;regB++) {
		for (addr=LCD_LEFT;addr<LCD_LEFT+15;addr++) {
			writebyte(addr,91);
		}
		delay05();
		for (addr=LCD_LEFT;addr<LCD_LEFT+15;addr++) {
			writebyte(addr,0);
		}
		delay05();
	}
}
*/

main()
{

	puts(&mystring);
	regB=getchar();

}