#org 33000
#define LCD_LEFT 0x3000
#define LCD_RIGHT 0x306C

char regA at 2, x at 3; 
word radr at 4, wadr at 6, h at 8;

char readbyte(word adr)
{
	radr = adr;
#asm
	DX
	IXL
#endasm
}

char writebyte(word adr2, char byt)
{
	wadr = adr2;
	regA = byt;
#asm
	DY
	IYS
#endasm
}

main()
{
	for (h = LCD_LEFT; h < LCD_LEFT+60; h++) {
		//x = writebyte (h, 91); // NOT WORKING (procedure call in a for not parsed?)
		wadr = h;
		regA = 91;
		#asm
			DY
			IYS
		#endasm
	}
	

}

