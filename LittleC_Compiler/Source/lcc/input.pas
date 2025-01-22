//{$MODE DELPHI}
{--------------------------------------------------------------}
unit Input;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{--------------------------------------------------------------}
interface
var Look: char;              	{ Lookahead character }
procedure GetChar;            { Read new character  }

{--------------------------------------------------------------}
implementation

{--------------------------------------------------------------}
{ Read New Character From Input Stream }

procedure GetChar;
begin
	Read(Look);
end;


{--------------------------------------------------------------}
{ Unit Initialization }
begin
//GetChar;
end.

