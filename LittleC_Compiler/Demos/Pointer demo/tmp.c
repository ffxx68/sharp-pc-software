#org 33000;
char a at 32995;
word b at 32997;
word *c;
main()
{
a = &c;
b = *c;
c = 32;
*c = 65;
}
;