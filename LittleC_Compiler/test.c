#org 33000
#define BASICPTR 0xFFD7

word radr at 4, wadr at 6;
char regA at 2;



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
	word h;
	h = readbyte(BASICPTR) | (readbyte(BASICPTR+1) << 8);
}