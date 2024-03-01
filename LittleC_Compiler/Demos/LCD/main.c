#org 0xE030

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

byte regI at 0, regJ 1;
char regA at 2, regB at 3; 
word regX at 4, regY at 6, addr at 8;

char xram mystring[7] = "FFXX68";

char readbyte(word adr)
{
	regX = adr;
#asm
	DX
	IXL
#endasm
}

writebyte(word adr2, char byt)
{
	regY = adr2;
	regA = byt;
#asm
	DY
	IYS
#endasm
}

delay05() {
#asm
DELAY05_LOOP: 
	TEST  0x01          ; Test .5 s timer
	JRZM  DELAY05_LOOP
#endasm
}
 
// using display routine from ROM
puts(word str) {
	
	addr = str;
	
	// how to get string addresses dinamically?
	// hardcoded name 'mystring', for now ...
#asm
		; fill destination with 24 blanks, beforehand
		LII   0x16
		LP	  0x10   ; destination start (internal ram)
		LIA	  0x20   ; blank
		FILM
		
		; just like a C strncpy()
		LP	4			;  XL
		LIA	LB(mystring) 
		EXAM
		LP	5			;  XH
		LIA	HB(mystring)
		EXAM
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
		LIA		0x0D     ; always terminate with newline
		DECP
		EXAM
		LIJ 1 ; needed
		
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
}

char getchar () {
#asm	
    CALL  0x1494        ; Syscall: wait for a keystroke
#endasm
	return readbyte(0xFF5E); // get the key-code value stored in memory
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

main()
{
	//flashlcd(5);
	//regB=getchar();
	
	puts(mystring);
	regB=getchar();
	
	//flashlcd(5);
}
