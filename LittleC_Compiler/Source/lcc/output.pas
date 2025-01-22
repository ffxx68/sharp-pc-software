//{$MODE DELPHI}
{--------------------------------------------------------------}
unit Output;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{--------------------------------------------------------------}
interface
procedure writLn(s: string);		{ Emit an instruction line }
procedure addasm(s: string);

var
        f: textfile;
        asmtext: string;
        libtext: string;
        asmcnt: integer;
        asmlist: Array [0..10000] of string;
        outfile: boolean;


{--------------------------------------------------------------}
implementation
const TAB = ^I;

{--------------------------------------------------------------}
{ Emit an Instruction, Followed By a Newline }

procedure writln(s: string);
begin
        if outfile then
	    asmtext := asmtext + s + #13#10
        else
            addasm(s);
end;


procedure addasm(s: string);
begin
        asmlist[asmcnt] := s;
        inc(asmcnt);
end;

begin
        asmtext := '';
        libtext := '';
end.
