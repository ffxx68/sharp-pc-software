#org 33000

word *c;
float f;
float *g;
float xram h;
char a at 32995;
word b at 32997;

main()
{
	a = &c;
	b = *c;
	c = 32;
	*c = 65;
}
