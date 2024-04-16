program lcpp;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$APPTYPE CONSOLE}
uses
  sysutils;

var
        i, cline: integer;
        fout: textfile;
        cf: string;

        symcnt: integer = 0;
        sym, symval: Array [0..1000] of string;


procedure abort(t: string);
var s: string;
begin
	str(cline + 1, s);
	writeln('Line ' + s + ': ' + t + ' in file ' + cf);
	halt (1);
end;


function replace_text(text, such, ers: string): string;
var i: integer;
    c: char;
begin
	result := text;
        if (such = '') or (text = '') then
                 exit;
	text := ' ' + text + ' ';
        i := 1;
        c := ' ';
	while (i < length(text)) do
	begin
            if (text[i] in ['''','"']) then if c = ' ' then c := text[i]
                        else c := ' ';
            if (c = ' ') and (copy(text, i, length(such)) = such)
             and not ((upcase(text[i-1]) in ['_','0'..'9','A'..'Z']) or (upcase(text[i+length(such)]) in ['_','0'..'9','A'..'Z'])) then
            begin
		delete(text, i, length(such));
		insert(ers, text, i);
		i := i + length(ers) - length(such);
            end;
            inc(i);
	end;
	result := trim(text);
end;


function findsymbol(l: string): boolean;
var i: integer;
begin
	result := false;
	for i := 0 to symcnt - 1 do
	if sym[i] = l then
	begin
		result := true;
		break;
	end;
end;


procedure addsymbol(s1, s2: string);
begin
	if findsymbol(s1) then
           abort('Symbol ' + s1 + ' already defined!');
	sym[symcnt] := s1;
	symval[symcnt] := s2;
        writeln('SYMBOL: ' + s1 + ' - ' + s2);
        inc(symcnt);
end;


procedure parsefile(fname: string);
var datei: textfile;
    lcnt: integer;
    op, tok: string;
    lcom: boolean;

function extractparam(s: string; p: integer): string;
var i, c: integer;
begin
     i := 0;
     for c := 1 to p do
     begin
        s := trim(s);
        if pos (' ', s) > 0 then i := pos (' ', s);
        if (pos (#9, s) > 0) and (pos (#9, s) < i) then i := pos (#9, s);
        delete(s, 1, i);
        if pos (' ', s) > 0 then i := pos (' ', s);
        if (pos (#9, s) > 0) and (pos (#9, s) < i) then i := pos (#9, s);
        if i <> 0 then result := trim(copy(s, 1, i - 1))
        else result := trim(s);
     end;
end;


function readline: string;
var
	i: integer;
	c: char;

begin
    repeat
	repeat
		readln(datei, result);
                inc(lcnt);
                cline := lcnt;
                result := trim(result);
                if lcom then if (pos('*/',result) = 0) then result := ''
                             else begin delete(result, 1, pos('*/', result)+1); lcom := false; end;
	until eof(datei) or (result <> '');
	if eof(datei) and (result = '') then exit;

	c := ' ';
	for i := 1 to length(result)-1 do
	begin
		if (result[i] in ['''','"']) then if c = ' ' then c := result[i]
                        else c := ' ';
		if (c = ' ') and (copy(result,i,2) = '//') then
		begin
			delete(result, i, 255);
			break;
		end;
		if (c = ' ') and (copy(result,i,2) = '/*') then
		begin
			if pos('*/',result) > i then delete(result, i, pos('*/',result) - i + 1)
                           else delete(result, i, 255);
                        lcom := true;
			break;
		end;
	end;
        if result <> '' then
        begin
            if pos('#ifdef', lowercase(result)) = 0 then
            begin
                if symcnt > 0 then for i := 0 to symcnt - 1 do
                        result := replace_text(result, sym[i], symval[i]);
            end;
        end;
     until eof(datei) or (result <> '');
     result := trim(result);
end;

begin
  if not fileexists(fname) then
  begin
    writeln('File '+fname+' not found!');
    exit;
  end;
	assignfile(datei, fname);
	reset(datei);
        lcnt := 0;
        cf := fname;
        lcom := false;

	tok := readline;
	while (not eof(datei)) or (tok <> '') do
	begin
//            if pos('#endif', tok) = 0 then
            begin

                if pos('#define', tok) = 1 then
                begin
                        addsymbol(extractparam(tok, 1), extractparam(tok, 2));
                end
                else if (pos('#org', tok) = 1) or (pos('#asm', tok) = 1) or (pos('#endasm', tok) = 1) or (pos('#nosave', tok) = 1) then
                begin
                        writeln(fout, tok + ';');
                end
                else if pos('#ifdef', tok) = 1 then
                begin
                        if not findsymbol(extractparam(tok, 1)) then
                        while not eof(datei) and (op <> '#endif') do
                        begin
                                tok := readline;
                                if pos('#endif', tok) > 0 then
                                   op := '#endif';
                        end;
                end
                else if pos('#include', tok) = 1 then
                begin
                        op := extractparam(tok, 1);
                        if fileexists(op) then
                        begin
                                parsefile(op);
                        end else abort('Include file ' + op + ' not found!');
                end
                else if pos('#endif', tok) = 0 then
                        writeln(fout, tok);
            end;
            tok := readline;
	end;

	closefile(datei);
end;



begin
        writeln('lcpp v1.0 - preprocessor for lcc');
        writeln('(c) Simon Lehmayr 2004');
	      if paramcount < 2 then
        begin
          writeln('Usage: lcpp cfile [cfile]* outputfile');
          writeln('       You can enter multiple c files');
          exit;
        end;

        assignfile(fout, paramstr(paramcount));
        rewrite(fout);

        for i := 1 to paramcount - 1 do
          parsefile(paramstr(i));

        write(fout,';');
        closefile(fout);
end.

