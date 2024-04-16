//{$MODE DELPHI}
{--------------------------------------------------------------}
unit Scanner;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{--------------------------------------------------------------}
interface
uses Input, Errors, Output, sysutils;

function IsAlpha(c: char): boolean;
function IsDigit(c: char): boolean;
function IsAlNum(c: char): boolean;
function IsAddop(c: char): boolean;
function IsMulop(c: char): boolean;

procedure Match(x: char);
function GetName: string;
function GetNumber: string;
function GetFloat: string;
function ExtrCust(var word: string; c: char): string;
function ExtrWord(var word: string): string;
function ExtrList(var list: string): string;
procedure GetToken(mode: integer; var s: string);
function CopyToken(s: string): string;
procedure rd(var c: char; var s: string);

var
        Tok: string;
        Level: integer;
        dummy: string;
        md: integer;
        linecnt: integer;

const
        SPACES = [' ', #9, #10, #11, #12, #13, #14];
        OPS = ['<', '>', '+', '-', '*', '/', '~', '&', '|', '!', '%', '^'];
        OPS2 = ['<', '>', '+', '-', '*', '/', '~', '&', '|', '!', '%', '^','='];
        HEX = ['A'..'F'];
        MODEKEYB = 0;
        MODEFILE = 1;
        MODESTR = 2;

        BO = #200;
        BA = #201;
        EQ = #202;
        NE = #203;
        GR = #204;
        SM = #205;
        GE = #206;
        SE = #207;
        PP = #210;
        MM = #211;
        SL = #212;
        SR = #213;

        REF = 1;
        ADR = 2;

{--------------------------------------------------------------}
implementation

var
        l: char;


  function converthex(s: string): integer;
  var i, c: integer;
  begin
    result := 0;
    c := 0;
//    writeln(s);

    for i := length(s) downto 1 do
    begin
      s[i]:=upcase(s[i]);
      if s[i] in ['1'..'9'] then result := result + ((ord(s[i])-48) shl (4*c));
      if s[i] in ['A'..'F'] then result := result + ((ord(s[i])-55) shl (4*c));
      if s[i] in ['0'..'9','A'..'F'] then inc(c);
    end;
  end;

  function convertbin(s: string): integer;
  var i, c: integer;
  begin
    result := 0;
    c := 1;
//    writeln(s);

    for i := length(s) downto 1 do
    begin
      if s[i] = '1' then result := result or c;
      if s[i] in ['0','1'] then c := c shl 1;
    end;
  end;

{--------------------------------------------------------------}
{ Split String in Words }

function ExtrCust(var word: string; c: char): string;
var sc: char;
begin
        result := '';
        if word = '' then exit;

        sc := ' ';
        while ((word <> '') and not (word[1] = c)) or (sc <> ' ') do //and not (word[1] in ['[', '(']) do
        begin
                if word[1] in ['"', ''''] then
                        if sc = word[1] then sc := ' '
                        else sc := word[1];
                result := result + word[1];
                delete(word, 1, 1);
        end;
        if word <> '' then
        begin
                if word[1] = c then
                        delete(word, 1, 1);
                if word <> '' then
                    if word[1] in SPACES then
                        delete(word, 1, 1);
        end;
        result := trim(result);
//        if word[1] in ['[', '('] then
//                word := word + ExtrWord(word);
end;


{--------------------------------------------------------------}
{ Split String in Words }

function ExtrWord(var word: string): string;
var c: char;
begin
        result := '';
        if word = '' then exit;

        c := ' ';
        while ((word <> '') and not (word[1] in SPACES)) or (c <> ' ') do //and not (word[1] in ['[', '(']) do
        begin
                if word[1] in ['"', ''''] then
                        if c = word[1] then c := ' '
                        else c := word[1];
                result := result + word[1];
                delete(word, 1, 1);
        end;
        if word <> '' then
                if word[1] in SPACES then
                        delete(word, 1, 1);
        result := trim(result);
//        if word[1] in ['[', '('] then
//                word := word + ExtrWord(word);
end;


{--------------------------------------------------------------}
{ Split List }

function ExtrList(var list: string): string;
var l: integer;
    c: char;
begin
        result := '';
        l := 0;

        if list = '' then exit;
        c := ' ';
        while ((list <> '') and not (list[1] = ',')) or (l > 0) or (c <> ' ') do
        begin
                if list[1] = '(' then inc(l);
                if list[1] = ')' then dec(l);
                if list[1] in ['"', ''''] then
                        if c = list[1] then c := ' '
                        else c := list[1];
                result := result + list[1];
                delete(list, 1, 1);
        end;
        delete(list, 1, 1);
        result := trim(result);
end;


{--------------------------------------------------------------}
{ Read Full Token From Input Stream }

procedure rd(var c: char; var s: string);
begin
        if md = 0 then Read(c)
        else if md = 1 then begin Read(f, c); if eof(f) then c := chr(27); end
        else if md = 2 then begin if s <> '' then c := s[1] else c := chr(27); delete(s, 1, 1); end;
        if l = ' ' then
        begin
                if c = '}' then
                        dec(Level);
                if c = '{' then
                        inc(Level);
        end;
        if (c = '''') then
        begin
                if (l = ' ') then
                        l := ''''
                else if (l = '''') then
                        l := ' ';
        end;
        if (c = '"') then
        begin
                if (l = ' ') then
                        l := '"'
                else if (l = '"') then
                        l := ' ';
        end;
        if c = chr(13) then inc ( linecnt );
end;

procedure GetToken(mode: integer; var s: string);
var i: integer;
//    l: char;
begin
        Tok := '';
        l := ' ';
        md := mode;

	repeat
                Rd(Look, s);
                if Look = chr(27) then exit;
        until not ((Look in SPACES) or (Look in ['{', '}']));

        while (l <> ' ') or not (Look in [';','{','}']) do
        begin
            if l = ' ' then
            begin
                if not (Look in SPACES) and not (Look in ['{', '}']) then
                begin
                        Tok := Tok + Look;
	                Rd(Look,s);
                end else
                begin
                        Tok := Tok + ' ';
                        while Look in SPACES do
                                Rd(Look, s);
                end;
            end else
            begin
                Tok := Tok + Look;
                Rd(Look, s);
            end;
        end;

        if Tok <> '' then if Tok[1] = ' ' then
                delete(Tok, 1, 1);
        if Tok[length(Tok)] = ' ' then
                delete(Tok, length(Tok), 1);

        i := 2;
        l := ' ';
        while i < length(Tok) do
        begin
            if (Tok[i] = '''') then begin if (l = ' ') then l := '''' else if (l = '''') then l := ' '; end;
            if (Tok[i] = '"') then begin if (l = ' ') then l := '"' else if (l = '"') then l := ' '; end;
            if (l = ' ') then
            begin
                if (Tok[i-1] <> ' ') and (Tok[i] in ['[', '(', '=']) then
                        begin insert(' ', Tok, i); inc(i, 1); end;
                if (Tok[i] in [']', ')']) and (Tok[i+1] <> ' ') then
                        begin insert(' ', Tok, i+1); inc(i, 1); end;
                if (Tok[i] in OPS2) and (Tok[i+1] = ' ') then
                        begin delete(Tok, i+1, 1); dec(i, 1); end;
                if (Tok[i-1] = ' ') and (Tok[i] in OPS) then
                        begin delete(Tok, i-1, 1); dec(i, 1); end;
            end;
            inc(i);
        end;
end;


function CopyToken(s: string): string;
var i: integer;
begin
        result := '';
        l := ' ';
        md := MODESTR;

	repeat
                Rd(Look, s);
        until not ((Look in SPACES) or (Look in ['{', '}']));

        while (l <> ' ') or not (Look in [';','{','}']) do
        begin
            if l = ' ' then
            begin
                if not (Look in SPACES) and not (Look in ['{', '}']) then
                begin
                        result := result + Look;
	                Rd(Look,s);
                end else
                begin
                        result := result + ' ';
                        while Look in SPACES do
                                Rd(Look, s);
                end;
            end else
            begin
                result := result + Look;
                Rd(Look, s);
            end;
        end;
        result := trim(result);

        i := 2;
        l := ' ';
        while i < length(result) do
        begin
            if (result[i] = '''') then begin if (l = ' ') then l := '''' else if (l = '''') then l := ' '; end;
            if (result[i] = '"') then begin if (l = ' ') then l := '"' else if (l = '"') then l := ' '; end;
            if (l = ' ') then
            begin
                if (result[i-1] <> ' ') and (result[i] in ['[', '(', '=']) then
                        begin insert(' ', result, i); inc(i, 1); end;
                if (result[i] in [']', ')']) and (result[i+1] <> ' ') then
                        begin insert(' ', result, i+1); inc(i, 1); end;
                if (result[i] in OPS2) and (result[i+1] = ' ') then
                        begin delete(result, i+1, 1); dec(i, 1); end;
                if (result[i-1] = ' ') and (result[i] in OPS) then
                        begin delete(result, i-1, 1); dec(i, 1); end;
            end;
            inc(i);
        end;
end;
{--------------------------------------------------------------}
{ Recognize an Alpha Character }

function IsAlpha(c: char): boolean;
begin
	result := UpCase(c) in ['A'..'Z','_'];
end;


{--------------------------------------------------------------}
{ Recognize a Numeric Character }

function IsDigit(c: char): boolean;
begin
	result := c in ['0'..'9'];
end;


{--------------------------------------------------------------}
{ Recognize an Alphanumeric Character }

function IsAlnum(c: char): boolean;
begin
	result := IsAlpha(c) or IsDigit(c);
end;


{--------------------------------------------------------------}
{ Recognize an Addition Operator }

function IsAddop(c: char): boolean;
begin
	result := (c in ['+','-','|','~',SL,SR]);
end;


{--------------------------------------------------------------}
{ Recognize a Multiplication Operator }

function IsMulop(c: char): boolean;
begin
	result := c in ['*','/', '&','%'];
end;


{--------------------------------------------------------------}
{ Match One Character }

procedure Match(x: char);
begin
	if Look = x then GetChar
	else Expected('''' + x + '''');
end;


{--------------------------------------------------------------}
{ Get an Identifier }

function GetName: string;
var n: string;
begin
	n := '';
	if not (upcase(Look) in ['A'..'Z','_']) then Expected('Name');
	while upcase(Look) in ['A'..'Z','0'..'9','_'] do begin
		n := n + Look;
                Rd(Look, tok); tok := trim(tok);
	end;
	result := n;
end;


{--------------------------------------------------------------}
{ Get an integer number }

function GetNumber: string;
var n: string;
    p: integer;
    isbin, ishex, ischr: boolean;
begin
	n := '';
        p := 0;
        ishex := false;
        isbin := false;
        ischr := false;

        writeln (' DEBUG GetNumber Look, tok ' , Look, ' ', tok );
	if not IsDigit(Look) and (Look <> '''') then
                Expected('Integer');
	while IsDigit(Look) or
                ( (p=0) and (Look='''') ) or
                ( (p=1) and ((upcase(Look)='B') or (upcase(Look)='X')) ) or
                ( ishex and (upcase(Look) in HEX) ) or
                ( isbin and (upcase(Look) in ['0','1']) ) or
                ischr do
        begin
                if (p = 1) then if upcase(look)='X' then ishex := true
                        else if upcase(look)='B' then isbin := true;
                if (p = 0) and (Look = '''') then ischr := true;
                if (p = 2) and ischr then ischr := false;
		n := n + Look;
                inc(p);
                Rd(Look, tok); if not ischr then tok := trim(tok);
                //writeln (' DEBUG GetNumber Look ' , Look );
	end;
{       if ishex then GetNumber := inttostr(converthex(n))
        else if isbin then GetNumber := inttostr(convertbin(n))
        else if n[1]='''' then GetNumber := inttostr(ord(n[2]))
        else}
        result := n;
end;

{--------------------------------------------------------------}
{ Get a floating point number }

function GetFloat: string;
var f: string;
    p: integer;
    isbin, ishex, ischr: boolean;
begin
	f := '';
        p := 0;
        ishex := false;
        isbin := false;
        ischr := false;
	if not IsDigit(Look) and (Look <> '''') then
                Expected('Floating point (' + Look + ')');
	while ( IsDigit(Look) or
           // extract only the floating point number from the token
           // needs review ... E.g.   aVar = 3.14 + bVar
           // fails because token is '3.14+'
           // workaround: use parenthesis  aVar = (3.14) + bVar
                ( (p>1) and (upcase(Look)='E') ) or
                ( (p>0) and (upcase(Look)='.') ) or
                ( (p>1) and (upcase(Look)='+') ) or
                ( (p>1) and (upcase(Look)='-') ) ) do
        begin
                f := f + Look;
                inc(p);
                Rd(Look, tok);
                //writeln (' DEBUG GetFloat Look ' , Look );
	end;
        //writeln (' DEBUG GetFloat: ' , f );
        try
           DecimalSeparator:='.';
           StrToFloat(f);
           // if there is no error the result is a floating point
           result := f;
        except
           Expected('Floating point <' + f + '>');
        end;
end;

begin
        Level := 0;
        linecnt := -1;
end.

