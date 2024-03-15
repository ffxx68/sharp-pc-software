
#org 0xE030

/*
Reserving 2 K on top of BASIC program memory:

PC-1403

NEW
MEM
 6878
POKE &FF01,&30,&E8
NEW
MEM
 4830
 
Machine code entry point at 0xE030 = 57576

*/

byte regI at 0, regJ 1;
char regA at 2, regB at 3; 
word regX at 4, regY at 6, addr at 8;

// locations for floating-point (BCD) operations
// X (10H to 17H) ; Y (18H to 1FH)
byte floatX[8] at 0x10 = (0x00, 0x20, 0x12, 0x30, 0x00, 0x00, 0x00, 0x00); // 1.23 x 10^2 = 123
byte floatY[8] at 0x18 = (0x00, 0x20, 0x34, 0x50, 0x00, 0x00, 0x00, 0x00); // 1.23 x 10^2 = 123
byte floatZ[8] at 0x20 = (0x00, 0x20, 0x67, 0x80, 0x00, 0x00, 0x00, 0x00); // 1.23 x 10^2 = 123
byte xram idx;


// numerical routines from ROM
// mostly taken from Hrast's notes

// floatX <-> floatY
f_swapXY(){
#asm
	CALL 0x027F
#endasm
}

// floatX + floatY -> floatX
f_add() {
#asm
	CALL 0x10C2
#endasm
}

// floatY - floatX -> floatX
f_subtr() {
#asm
	CALL 0x10D8
#endasm
}

// floatX * floatY -> floatX
f_mult() {
#asm
	CALL 0x10E1
#endasm
}

// floatY / floatX -> floatX
f_div() {
#asm
	CALL 0x10EA
#endasm
}


// binary_num --> floatX
uint2float(word binary_num) {
		// (0x19) msb, (0x18) lsb
		floatY[0] = 0xff; // should take from parameter!!
		floatY[1] = 0xff;
#asm
		; 0x1446 - Entry point for an UNSIGNED binary (0 to 65535)
		; 0x144D - Entry point for a SIGNED binary (-32768 to 32767)
		; converted decimal number (8-byte BCD Sharp format) is stored in float register X, at 0x10
		CALL 0x1446
#endasm
}



main()
{
	
	 // uint2float(); // verified
	 //f_swapXY(); // verified
	 //f_add(); // verified
	 //f_subtr(); // verified
	 //f_mult(); // verified
	 f_div(); // verified
	 
	 
}
