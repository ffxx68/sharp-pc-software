#org 0xE0E8

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

 0xE031 to 0xE0E7 for local memory (182 bytes)
 0xE0E8 to 0xE82F for program (1865 bytes) 
 
Machine code entry point at 0xE0E8 = 57576


PC-1403 H

POKE &FF01,&30,&E8

Machine code entry point at 0x80E8 = 33000

*/

#define LCD_LEFT 0x3000
#define LCD_RIGHT 0x306C

#define PRT_BUF 0xFEB0

byte regI at 0, regJ 1;
char regA at 2, regB at 3; 
word regX at 4, regY at 6, addr at 8;

char mystring[7] at 0xE031 = "FFXX68";

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

delay (byte time) {
	byte j;

	for (j = 0; j < time; j++) {
#asm
WAIT 0x10
#endasm
/*
#asm
JR115E: TEST  0x02          ; Test 2 ms timer
		JRZM  JR115E		; Loop on timer signal off
#endasm
*/
	}
}

// using ROM display routines
printf() {

	// how to get string address dinamically ??
#asm	
		; FF6C gets the pointer to string end address in buffer
		; hardcoded for now to 0xE037!!
		LIA	  0x37	; low
		LIDP  0xFF6C
		STD
		LIA	  0xE0	; high
		LIDP  0xFF6D
		STD

		LIDP	0xFF6C ; pointer to end of string
		LP	6             
		MVBD		   ; -> Y
		IY		
		LIA		0x20
		LII		0x10
		FILD		
		LIDP	0xE030+1 ; 0xE030 : begin of Print BUFFER
		LP	    0x10   ; destination 0x10
		LII		0x17   ; 24-1 characters
		MVWD

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
	byte i;
	
	for (i = 0; i < num; i++) {
		for (addr = LCD_LEFT; addr < LCD_LEFT+15; addr++) {
			writebyte(addr, 91);
		}
		//delay (50);
		for (addr = LCD_LEFT; addr < LCD_LEFT+15; addr++) {
			writebyte(addr, 0);
		}
		//delay (50);
	}
}

main()
{
	char c, x;
	
	printf();
	
	c = getchar (); // stop
	
	// flash - DOES NOT WORK ! 
	/*
	for (addr = LCD_LEFT; addr < LCD_LEFT+60; addr++) {
		writebyte (addr, 91);
	}
	//flashlcd(5);
	*/
	
}
