#org 33000;
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
break;
c = a + b;
}
do
a+=3;
while (a <= 50);
loop (33+c)
{
a -= b;
break;
b = a<<1;
}
}
;