#org 33000

char a at 32995;
char b at 32997;
char c at 32999;

char test1(char loc1, char loc2)
{
	return 5 * loc1 + loc2;
}

word test2(char t2, word t1)
{
	return t1 - t2;
}

test3(char loc3)
{
	char h;
	a = loc3 + h;
}

main()
{
	test3(25 + b);
	b = test2(test1(a, 55), c << 8 + b) >> 8;
}
