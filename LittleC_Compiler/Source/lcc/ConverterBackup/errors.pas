//{$MODE DELPHI}
{--------------------------------------------------------------}
unit Errors;
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
	WriteLn({^G,} 'Error: ', s, '.');
  if tok <> '' then writeln('Token: '+tok);
  if dummy <> '' then writeln('Code: '+dummy);
	Halt;
end;

{--------------------------------------------------------------}
{ Write "<something> Expected" }

procedure Expected(s: string);
begin
	Error(s + ' Expected');
end;

end.

