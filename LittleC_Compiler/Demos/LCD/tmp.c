#org 0xE130;
char regA at 2, x at 3;
word radr at 4, wadr at 6, h at 8;
char readbyte(word adr)
{
radr = adr;
#asm;
DX
IXL
#endasm;
}
char writebyte(word adr2, char byt)
{
wadr = adr2;
regA = byt;
#asm;
DY
IYS
#endasm;
}
main()
{
for (h = 0x3000; h < 0x3000+60; h++)
x = writebyte (h, 91);
}
;