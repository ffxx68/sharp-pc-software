//{$MODE DELPHI}
{--------------------------------------------------------------}
unit Errors;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{--------------------------------------------------------------}
interface
procedure Error(s: string);
procedure Expected(s: string);


{--------------------------------------------------------------}
implementation
uses scanner;

{--------------------------------------------------------------}
{ Write error Message and Halt }

procedure Error(s: string);
begin
	WriteLn;
	WriteLn('** ERROR ** in line: ', linecnt);
        WriteLn('** ', s);
  if tok <> '' then writeln('Token: '+tok);
  if dummy <> '' then writeln('Code: '+dummy);
	Halt (1);
end;

{--------------------------------------------------------------}
{ Write "<something> Expected" }

procedure Expected(s: string);
begin
	Error(s + ' Expected');
end;

end.

