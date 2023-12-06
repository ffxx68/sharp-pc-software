#org 33000

char a at 32995;
char b at 32997;
char c at 32999;


main()
{
	for (a = 1; a < 50; a++)
		b--;

	for (b = 100; b > a;)
		b--;

	while (a >= 100 && b < 10)
	{
		b--;
		a++;
		if (b == 0)
			break;	// Exits the loop at once
		c = a + b;
	}

	do
		a+=3;
	while (a <= 50);

	loop (33+c)	// This will execute the loop 33+c+1 times
	{
		a -= b;
		break;	// Exits the loop (in this case it will do the loop until the last loop line)
		b = a<<1;
	}
}
