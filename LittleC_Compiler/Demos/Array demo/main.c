#org 33000

char a[6], b[7];			// normal array declaration will be stored in CPU memory
word c[3] = (32980, 32981, 32982);	// with init value

char d[5] at 10;			// in CPU memory at address 10
word xram e[100];			// in XRAM
byte xram f[2] at 0xFFD7 = (0x01, 0xE8);// in XRAM at address 0xFFD7 with init value
char xram g[12] = "Hi there!";

main()
{
	a[0] = b[0] + d[a[1]];
}