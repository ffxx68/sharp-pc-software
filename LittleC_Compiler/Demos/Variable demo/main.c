#org 33000

char a, b;	// normal var declaration will be stored in CPU memory
word c=32980;	// with init value

char d at 10;	// in CPU memory at address 10
word xram e;	// in XRAM
word xram f at 0xFFD7 = 0x01E8;	// in XRAM at address 0xFFD7 with init value

char xram g, h;	// both will be in XRAM

main()
{
	a = b + d;
}