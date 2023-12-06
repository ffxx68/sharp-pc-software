#org 33000;
char a[6], b[7];
word c[3] = (32980, 32981, 32982);
char d[5] at 10;
word xram e[100];
byte xram f[2] at 0xFFD7 = (0x01, 0xE8);
char xram g[12] = "Hi there!";
main()
{
a[0] = b[0] + d[a[1]];
}
;