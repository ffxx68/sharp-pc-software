#org 33000

char a at 32995;
char b at 32997;
char c at 32999;


main()
{
	a = (200 - c) | (3 * b);
	b = c >> 5 + 3 & a;
	c = (1 << b) - a * 5;
}
