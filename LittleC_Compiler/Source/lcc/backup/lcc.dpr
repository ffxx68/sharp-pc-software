{--------------------------------------------------------------}
program lcc;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$APPTYPE CONSOLE}
uses Input, Output, Errors, Scanner, parser_new, sysutils;

begin
        outfile := true;
        writeln;
        writeln('lcc v1.1 - littleC Compiler for Hitachi SC61860 CPU');
        writeln('(c) Simon Lehmayr 2004');
        if paramcount = 2 then
        begin
                if not fileexists(ParamStr(1)) then exit;
                writeln('Compiling ',paramstr(1),'...');
                FirstScan(ParamStr(1));
                SecondScan(ParamStr(2));
        end else
        begin
                writeln('Usage: lcc inputfile outputfile');
                writeln('    input file must be the file the preprocessor created');
                writeln('    output file must be the assembler file to create');
        end;
end.

