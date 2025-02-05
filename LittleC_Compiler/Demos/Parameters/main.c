#org 0xE030
/*******************************************************************
After generating the binary, within a cmd window, from the 'lcc_b1' root dir

 cd [...]\lcc_b1
 make [...]\main.c tmp.bin
 
copy the newlygenerated binary to the MAME root dir:

 copy tmp.bin ..\mame
 
Then, from a different cmd window, start MAME in debug mode:

 cd [...]\mame
 mame pc1403 -debug -nomaximize

Sometimes the machine doesn't start up properly. It just doesn't respond to the keyboard.
Use MAME 'soft reset' from the debugger window, until you get

 MEMORY ALL CLEAR O.K.?
 
on the emulated device screen, then give <Enter> to confirm device reset.
Reserve 2 K on top of BASIC program memory for the machine language routine.
This should be done before uploading the binary in the emulated machine.
In BASIC <PRO> mode, enter:

 NEW
 MEM
 > 6878
 POKE &FF01,&30,&E8
 NEW
 MEM
 > 4830

Machine code entry point at 0xE030 = 57576, so an example BASIC program would call the routine with
Note that reserved areas and hence program entry points depend on PC model. This example is for PC-1403.

 10 CALL &E030

Then, in the MAME debugger console window, enter:

  load tmp.bin,e030:maincpu
  
If you want to set a breakpoint, for example at the program entry point, 
yet in the MAME debugger console, enter the "breakpoint set" command:

  bps e030

Back to the emulated PC-1403, in BASIC <RUN> mode

 RUN

and MAME debugger will stop at the breakpoint, where you can start your test from.
The debugger has the usual 'step' and 'run' commands.

For each new test cycle, rebuild the binary, load it on MAME and restart:

 (cmd)> make [...]\main.c tmp.bin
 (cmd)> copy tmp.bin ..\mame
 (debugger) load tmp.bin,e030:maincpu
 (debugger) 'soft reset' (repeat, if device is not responding)
 (Sharp PC) <PRO> mode
 (Sharp PC) RUN

No need to reenter POKE or CALL, as soft reset won't wipe memory out. 
******************************************************************/


char gbTest;
word gwVar;
float gfTest;
 
word testProc2(word pwT3) {
	
	return pwT3;
}
 
word testProc(word pwT2, byte pbT1, float pfT3) {
	byte lbTest4;  
	word lwTest2;  
	float lfTest3; 
	
	lwTest2 = testProc2( pwT2 );
	lfTest3 = pfT3;
	lbTest4 = pbT1;
	
	return lwTest2 ; 
}

main()
{
	byte lbTest5; 
	
	gwVar = testProc( 5678, 123, 1.2345678912E+15 ); // NOTE - return type vs. variable type NOT checked on assignment!
	
}