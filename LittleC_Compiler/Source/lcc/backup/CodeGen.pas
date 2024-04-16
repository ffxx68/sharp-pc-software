//{$MODE DELPHI}
{--------------------------------------------------------------}
unit CodeGen;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{--------------------------------------------------------------}
interface

uses Output, SysUtils;

procedure CompGreater;
procedure CompSmaller;
procedure CompSmOrEq;
procedure CompGrOrEq;
procedure CompEqual;
procedure CompNotEqual;
procedure Branch(L: string);
procedure BranchFalse(L: string);
procedure Negate;
procedure Push;
procedure PopAdd;
procedure PopSub;
procedure PopMul;
procedure PopDiv;
procedure PopOr;
procedure PopSr;
procedure PopSl;
procedure PopXor;
procedure PopAnd;
procedure PopMod;
procedure NotIt;
procedure varxram(Value, adr, size: integer; nm: string);
procedure varxarr(Value: string; adr, size: integer; nm, typ: string);
procedure varcode(Value, adr, size: integer; nm: string);
procedure varfcode(Value, nm: string);
procedure varcarr(Value: string; adr, size: integer; nm, typ: string);
procedure varfarr(Value: string; size: integer; nm: string);
procedure varreg(Value, adr, size: integer; nm: string);
procedure varrarr(Value: string; adr, size: integer; nm, typ: string);

type OpTypes = (byte, word, floatp);


var
  libins: array [0..100] of boolean;
  libname: array [0..100] of string;
  libcnt: integer;
  pc: string;
  isword: boolean;
  isfloat: boolean;
  pushcnt: integer;
  optype: OpTypes;


const   { Math }
  MUL8 = 0;
  DIVMOD8 = 1;
  SR8 = 3;
  SL8 = 4;
  XOR8 = 5;

  MUL16 = 12;
  DIV16 = 13;
  MOD16 = 14;
  AND16 = 15;
  OR16 = 16;
  XOR16 = 21;
  SR16 = 17;
  SL16 = 18;
  NOT16 = 19;
  NEG16 = 20;

  CPE16 = 30;
  CPNE16 = 31;
  CPS16 = 32;
  CPG16 = 33;
  CPSE16 = 34;
  CPGE16 = 35;

  tempFloat = 16; // using Xreg @ 0x10-0x17 as temporary floating-point register

  {--------------------------------------------------------------}
implementation



procedure load_x(s: string);
begin
  writln(#9'LP'#9'4'#9'; Load XL');
  writln(#9'LIA'#9'LB(' + s + ')');
  writln(#9'EXAM');
  writln(#9'LP'#9'5'#9'; Load XH');
  writln(#9'LIA'#9'HB(' + s + ')');
  writln(#9'EXAM');
end;


procedure load_y(s: string);
begin
  writln(#9'LP'#9'6'#9'; Load YL');
  writln(#9'LIA'#9'LB(' + s + ')');
  writln(#9'EXAM');
  writln(#9'LP'#9'7'#9'; Load YH');
  writln(#9'LIA'#9'HB(' + s + ')');
  writln(#9'EXAM');
end;


{--------------------------------------------------------------}
{ Inserts library code for used libs }

procedure addlib(lib: integer);
begin
  if libcnt = 0 then
    libtext := libtext + '; LIB Code'#13#10;
  Inc(libcnt);

  if (libins[lib] = False) then
  begin
    libins[lib] := True;
    libtext := libtext + '.include ' + libname[lib] + '.lib'#13#10;
  end;
end;


{--------------------------------------------------------------}
{ Generates init code for a var in xram }

procedure varxram(Value, adr, size: integer; nm: string);
begin
  writeln ( ' DEBUG varxram ', nm );
  writln(#9'LIDP'#9 + IntToStr(adr) + #9'; Variable ' + nm + ' = ' + IntToStr(Value));
  if size = 1 then
  begin
                {if value = 0 then
                        writln( #9'RA')
                else           }
    writln(#9'LIA'#9 + IntToStr(Value));
    writln(#9'STD');
  end
  else if size = 2 then
  begin
                {if value mod 256 = 0 then
                        writln( #9'RA')
                else     }
    writln(#9'LIA'#9'LB(' + IntToStr(Value) + ')');

    writln(#9'STD');
    if adr div 256 = (adr + 1) div 256 then
      writln(#9'LIDL'#9'LB(' + IntToStr(adr + 1) + ')')
    else
      writln(#9'LIDP'#9 + IntToStr(adr + 1));

    if Value mod 256 <> Value div 256 then
                {if value div 256 = 0 then
                        writln( #9'RA')
                else      }
      writln(#9'LIA'#9'HB(' + IntToStr(Value) + ')');
    writln(#9'STD');
  end
  else if size = 8 then
    writln(' ; varxram - Unsupported float');

  writln('');
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Generates init code for an array in xram }

procedure varxarr(Value: string; adr, size: integer; nm, typ: string);
var
  i: integer;
  v, c: integer;
  s: string;
begin
  writeln ( ' DEBUG varxarr ', nm );
  if (size = 0) then exit;

  s := '';
  for i := 1 to size do
  begin
    if i <= length(Value) then
    begin
      if ((typ = 'byte') or (typ = 'char')) then
        s := s + IntToStr(Ord(Value[i]))
      else if typ = 'word' then
        s := s + IntToStr(256 * Ord(Value[i * 2 - 1]) + Ord(Value[i * 2]))
      else if typ = 'float' then s := ''; // TODO  !!
    end
    else
      s := s + '0';

    if i < size then
      s := s + ', ';
  end;

  if ((typ = 'byte') or (typ = 'char')) and (size <= 5) then
  begin
    // Set up address and write 1st byte
    writln(#9'LIDP'#9 + IntToStr(adr) + #9'; Variable ' + nm + ' = (' + s + ')');
    v := Ord(Value[1]);
        { if v = 0 then
                writln( #9'RA')
        else  }
    writln(#9'LIA'#9 + IntToStr(v));
    writln(#9'STD');

    c := v;
    if size > 1 then for i := 2 to size do
      begin
        if (adr + i - 2) div 256 = (adr + i - 1) div 256 then
          writln(#9'LIDL'#9'LB(' + IntToStr(adr + i - 1) + ')')
        else
          writln(#9'LIDP'#9 + IntToStr(adr + i - 1));

        if i <= length(Value) then
          v := Ord(Value[i])
        else
          v := 0;

        if v <> c then
        begin
                        {if v = 0 then
                                writln( #9'RA')
                        else         }
          writln(#9'LIA'#9 + IntToStr(v));
          writln(#9'STD');
        end
        else
          writln(#9'STD');
        c := v;
      end;
  end
  else if ((typ = 'byte') or (typ = 'char')) then
  begin
    writln(#9'; Variable ' + nm + ' = (' + s + ')');
    load_x(nm + '-1');
    load_y(IntToStr(adr - 1));
    writln(#9'LII'#9 + IntToStr(size) + #9'; Load I as counter');
    writln(#9'IXL');
    writln(#9'IYS');
    writln(#9'DECI');
    writln(#9'JRNZM'#9'4');

    addasm(nm + ':'#9'; Variable init data ' + nm);
    s := #9'.DB'#9 + s;
    addasm(s);
    addasm('');
  end
  else if (typ = 'word') then
  begin
    writln(#9'; Variable ' + nm + ' = (' + s + ')');
    load_x(nm + '-1');
    load_y(IntToStr(adr - 1));
    writln(#9'LII'#9 + IntToStr(size * 2) + #9'; Load I as counter');
    writln(#9'IXL');
    writln(#9'IYS');
    writln(#9'DECI');
    writln(#9'JRNZM'#9'4');

    addasm(nm + ':'#9'; Variable init data ' + nm);
    s := #9'.DW'#9 + s;
    addasm(s);
    addasm('');
  end
  else if (typ = 'float') then
  begin
    //...  TODO - float
    writln(#9'; varxarr - Unsupported float ' + nm);
  end;

  writln('');
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Generates init code for a var in code space }

procedure varcode(Value, adr, size: integer; nm: string);
var
  i: integer;
  s: string;
begin
  //writeln ( ' DEBUG varcode ', nm );
  if Value = -1 then Value := 0;
  addasm(nm + ':'#9'; Variable ' + nm + ' = ' + IntToStr(Value));
  if size = 1 then
    addasm(#9'.DB'#9 + IntToStr(Value))
  else if size = 2 then
    addasm(#9'.DW'#9 + IntToStr(Value));
  addasm('');
end;
{--------------------------------------------------------------}

{--------------------------------------------------------------}
{ Generates init code for an array in code space }

procedure varcarr(Value: string; adr, size: integer; nm, typ: string);
var
  i: integer;
  s: string;
begin

  if (size = 0) then exit;
  s := '';
  for i := 1 to size do
  begin
    if i <= length(Value) then
    begin
      if not ( typ = 'word') then s := s + IntToStr(Ord(Value[i]))
      else if typ = 'word' then s := s + IntToStr(256 * Ord(Value[i * 2 - 1]) + Ord(Value[i * 2]));
    end
    else
      s := s + '0';

    if i < size then
      s := s + ', ';
  end;

  addasm(nm + ':'#9'; Variable ' + nm + ' = (' + s + ')');
  if (typ = 'char') or (typ = 'char') or (typ = 'float') then
    s := #9'.DB'#9 + s
  else if (typ = 'word') then
    s := #9'.DW'#9 + s;
  addasm(s);
  addasm('');
end;

{ Generates init code for a float in code space }

procedure varfcode(Value, nm: string);
var
  i: integer;
  s: string;
begin

  s := '';
  for i := 1 to 7 do begin s := s + '0x'+IntToHex(ord(Value[i])) + ',';
  end;
  s := s + '0x'+IntToHex(ord(Value[8]));
  //writeln ( '  DEBUG varfcode ', s );

  addasm(nm + ':'#9'; Floating-point  ' + nm ) ;
  s := #9'.DB'#9 + s;
  addasm(s);
  addasm('');
end;
{--------------------------------------------------------------}

{ Generates init code for a float array in code space }
procedure varfarr(Value: string; size: integer; nm: string);
var
  i, j : integer;
  s: string;
begin

  addasm(nm + ':'#9'; Floating-point array ' + nm
            + ' array (' + IntToStr( size ) + ')' ) ;
  for j := 0 to size-1 do begin
    s := '';
    for i := 1 to 7 do s := s + '0x'+IntToHex(ord(Value[j*8 + i])) + ',';
    s := s + '0x'+IntToHex(ord(Value[j*8 + 8]));
    s := #9'.DB'#9 + s + ' ; ' + IntToStr( j ) ;
    //writeln ( ' DEBUG varfarr ', s );
    addasm(s);
  end;
  addasm('');
end;
{--------------------------------------------------------------}

{--------------------------------------------------------------}
{ Generates init code for a variable in a register }

procedure varreg(Value, adr, size: integer; nm: string);
begin
  { Check for named register }
  if ((adr = 0) or (adr = 1)) and (size = 1) then
  begin
    if adr = 0 then
      writln(#9'LII'#9 + IntToStr(Value) + #9'; I is ' + nm + ' = ' + IntToStr(Value))
    else
      writln(#9'LIJ'#9 + IntToStr(Value) + #9'; J is ' + nm + ' = ' + IntToStr(Value));
    writln('');
    exit;
  end;

  if adr <= 63 then
    writln(#9'LP'#9 + IntToStr(adr) + #9'; Variable ' + nm + ' = ' + IntToStr(Value))
  else
  begin
    writln(#9'LIP'#9 + IntToStr(adr) + #9'; Variable ' + nm +
      ' = ' + IntToStr(Value));
  end;
  if size = 1 then
  begin
    writln(#9'LIA'#9 + IntToStr(Value));
    writln(#9'EXAM');
  end
  else if size = 2 then
  begin
                { if value mod 256 = 0 then
                        writln( #9'RA'#9'; LB')
                else    }
    writln(#9'LIA'#9'LB(' + IntToStr(Value) + ')' + #9'; LB');
    writln(#9'EXAM');

    writln(#9'INCP');
    if Value mod 256 <> Value div 256 then
                { if value div 256 = 0 then
                        writln( #9'RA'#9'; HB')    }
    else
      writln(#9'LIA'#9'HB(' + IntToStr(Value) + ')' + #9'; HB');
    writln(#9'EXAM');
  end
  else if size = 8 then
  begin
    writln(#9'; varreg - Unsupported float');
  end;
  writln('');
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Generates init code for an array variable in a register }

procedure varrarr(Value: string; adr, size: integer; nm, typ: string);
var
  i: integer;
  s: string;
begin
  if size = 0 then exit;
  if typ = 'float' then writln(#9'; varrarr - Unsupported float');

  s := '';
  for i := 1 to size do
  begin
    if i <= length(Value) then
    begin
      if typ <> 'word' then s := s + IntToStr(Ord(Value[i]))
      else if typ = 'word' then
        s := s + IntToStr(256 * Ord(Value[i * 2 - 1]) + Ord(Value[i * 2]));
    end
    else
      s := s + '0';

    if i < size then
      s := s + ', ';
  end;

  if typ <> 'word' then
    writln(#9'LII'#9 + IntToStr(size - 1) + #9'; Variable ' + nm + ' = (' + s + ')')
  else
    writln(#9'LII'#9 + IntToStr(size * 2 - 1) + #9'; Variable ' + nm + ' = (' + s + ')');
  writln(#9'LIDP'#9 + nm);
  if adr <= 63 then
    writln(#9'LP'#9 + IntToStr(adr))
  else
    writln(#9'LIP'#9 + IntToStr(adr));
  writln(#9'MVWD');

  addasm(nm + ':'#9'; Variable init data ' + nm);
  if typ <> 'word' then
    s := #9'.DB'#9 + s
  else
    s := #9'.DW'#9 + s;
  addasm(s);
  addasm('');

  writln('');
end;
{--------------------------------------------------------------}


{---------------------------------------------------------------}
{ Comparison Equal }

procedure CompEqual;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_CPE16'#9'; Compare for equal');
    addlib(CPE16);
  end
  else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'LP'#9'3');
    writln(#9'CPMA'#9#9'; Compare for equal');
    {writln( #9'RA')}writln(#9'LIA'#9'0');
    writln(#9'JRNZP'#9'2');
    writln(#9'DECA');
  end;
  writln('');
end;


{---------------------------------------------------------------}
{ Comparison Not Equal }

procedure CompNotEqual;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_CPNE16'#9'; Compare not equal');
    addlib(CPNE16);
  end
  else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'LP'#9'3');
    writln(#9'CPMA'#9#9'; Compare for not equal');
    {writln( #9'RA')}writln(#9'LIA'#9'0');
    writln(#9'JRZP'#9'2');
    writln(#9'DECA');
  end;
  writln('');
end;


{---------------------------------------------------------------}
{ Comparison Greater or Equal }

procedure CompGrOrEq;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_CPGE16'#9'; Compare for Greater or Equal');
    addlib(CPGE16);
  end
  else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'LP'#9'3');
    writln(#9'CPMA'#9#9'; Compare for Greater or Equal');
    {writln( #9'RA')}writln(#9'LIA'#9'0');
    writln(#9'JRCP'#9'2');
    writln(#9'DECA');
  end;
  writln('');
end;


{---------------------------------------------------------------}
{ Comparison smaller or equal }

procedure CompSmOrEq;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_CPSE16'#9'; Compare for smaller or equal');
    addlib(CPSE16);
  end
  else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'LP'#9'3');
    writln(#9'CPMA'#9#9'; Compare for smaller or equal');
    {writln( #9'RA')}writln(#9'LIA'#9'0');
    writln(#9'JRCP'#9'2');
    writln(#9'DECA');
  end;
  writln('');
end;


{---------------------------------------------------------------}
{ Comparison Greater }

procedure CompGreater;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_CPG16'#9'; Compare for greater');
    addlib(CPG16);
  end
  else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'LP'#9'3');
    writln(#9'CPMA'#9#9'; Compare for greater');
    {writln( #9'RA')}writln(#9'LIA'#9'0');
    writln(#9'JRNCP'#9'2');
    writln(#9'DECA');
  end;
  writln('');
end;


{---------------------------------------------------------------}
{ Comparison smaller }

procedure CompSmaller;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_CPS16'#9'; Compare for smaller');
    addlib(CPS16);
  end
  else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'LP'#9'3');
    writln(#9'CPMA'#9#9'; Compare for smaller');
    {writln( #9'RA')}writln(#9'LIA'#9'0');
    writln(#9'JRNCP'#9'2');
    writln(#9'DECA');
  end;
  writln('');
end;


{---------------------------------------------------------------}
{ Branch Unconditional  }

procedure Branch(L: string);
begin
  writln(#9'RJMP'#9 + L);
end;


{---------------------------------------------------------------}
{ Branch False }

procedure BranchFalse(L: string);
begin
  writln(#9'TSIA'#9'255'#9'; Branch if false');
  writln(#9'JRZP'#9 + L);
  writln('');
end;


{--------------------------------------------------------------}
{ Bitwise Not Primary }

procedure NotIt;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'1');
    writln(#9'ORIM'#9'255');
    writln(#9'LP'#9'0');
    writln(#9'ORIM'#9'255');
    writln(#9'SBB'#9#9'; Negate');
    writln(#9'LP'#9'1');
    writln(#9'LDM');
    writln(#9'EXAB');
    writln(#9'LP'#9'0');
    writln(#9'LDM');
  end
  else
  begin
    writln(#9'LIB'#9'0');
    writln(#9'LP'#9'3');
    writln(#9'SBM'#9#9'; Negate');
    writln(#9'EXAB');
  end;
{    if optype = word then
    begin
        writln( #9'LP'#9'0');
        writln( #9'EXAM');
        writln( #9'LP'#9'1');
        writln( #9'EXAB');
        writln( #9'EXAM');
        writln( #9'LIA'#9'255');
        writln( #9'SBM'#9#9'; NOT HB');
        writln( #9'EXAB');
        writln( #9'EXAM');
        writln( #9'EXAB');
        writln( #9'LP'#9'0');
        writln( #9'SBM'#9#9'; NOT LB');
        writln( #9'EXAM');
    end else
    begin
        writln( #9'EXAB');
        writln( #9'LIA'#9'255');
        writln( #9'LP'#9'3');
  writln( #9'SBM'#9#9'; NOT');
        writln( #9'EXAB');
    end;}
end;

{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Negate Primary }

procedure Negate;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'1');
    writln(#9'ORIM'#9'255');
    writln(#9'LP'#9'0');
    writln(#9'ORIM'#9'255');
    writln(#9'SBB'#9#9'; Negate');
    writln(#9'LP'#9'1');
    writln(#9'LDM');
    writln(#9'EXAB');
    writln(#9'LP'#9'0');
    writln(#9'LDM');
  end else if optype = floatp then
  begin
    writln(#9' ; TO-DO? Negate a floating point');
  end else
  begin
    writln(#9'LIB'#9'0');
    writln(#9'LP'#9'3');
    writln(#9'SBM'#9#9'; Negate');
    writln(#9'EXAB');
  end;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Or TOS with Primary }

procedure PopOr;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'ORMA'#9#9'; OR HB');
    writln(#9'LP'#9'0');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'ORMA'#9#9'; OR LB');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'EXAB');
  end else if optype = floatp then
  begin
    writln(#9' ; !!! USUPPORTED Floating-point OR');
  end else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'LP'#9'3');
    writln(#9'ORMA'#9#9'; OR');
    writln(#9'EXAB');
  end;
end;

{--------------------------------------------------------------}
{ Exclusive-Or TOS with Primary }

procedure PopXor;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_XOR16'#9'; XOR');
    addlib(XOR16);
    addlib(XOR8);
  end else if optype = floatp then
  begin
    writln(#9' ; !!! USUPPORTED Floating-point XOR');
  end else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_XOR8'#9'; XOR');
    addlib(XOR8);
  end;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Shift left TOS with Primary }

procedure PopSL;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_SL16'#9'; SL');
    addlib(SL16);
  end else if optype = floatp then
  begin
    writln(#9' ; !!! USUPPORTED Floating-point Shift');
  end
  else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_SL8'#9'; Shift left');
    addlib(SL8);
  end;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Shift right TOS with Primary }

procedure PopSR;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_SR16'#9'; SR');
    addlib(SR16);
  end else if optype = floatp then
  begin
    writln(#9' ; !!! UNSUPPORTED Floating-point Shift');
  end else begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_SR8'#9'; Shift right');
    addlib(SR8);
  end;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Modulo TOS with Primary }

procedure PopMod;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_MOD16'#9'; Modulo');
    addlib(MOD16);
  end
  else if optype = floatp then
  begin
    writln(#9' TO DO - Float Modulo');
  end else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_DIV8'#9'; Modulo');
    writln(#9'EXAB');
    addlib(DIVMOD8);
  end;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ And Primary with TOS }

procedure PopAnd;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'ANMA'#9#9'; AND HB');
    writln(#9'LP'#9'0');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'ANMA'#9#9'; AND LB');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'EXAB');
  end else if optype = floatp then
  begin
    writln(#9' ; !!! UNSUPPORTED Floating-point AND');
  end else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'LP'#9'3');
    writln(#9'ANMA'#9#9'; AND');
    writln(#9'EXAB');
  end;
end;
{--------------------------------------------------------------}

procedure PopFloat;
var i: integer;
begin
    writln(#9'LP 0x1F ; Pop 8 bytes, to Yreg');
    for i := 0 to 7 do begin
        writln(#9'POP');
        Dec(pushcnt);
        writln(#9'EXAM');
        writln(#9'DECP');
    end;
end;

{--------------------------------------------------------------}
{ Push Primary to Stack }

procedure Push;
var i: integer;
begin
  if optype = word then
  begin
    writln(#9'PUSH'#9#9'; Push A then B');
    Inc(pushcnt);
    writln(#9'EXAB');
    writln(#9'PUSH');
    Inc(pushcnt);
  end
  else if optype = floatp then
  begin
    writln(#9'LP 0x'+IntToHex(tempFloat,2)+' ; Push 8 bytes, from tempFloat');
    for i := 0 to 7 do begin
      writln(#9'LDM');
      writln(#9'PUSH');
      Inc(pushcnt);
      writln(#9'INCP');
    end;
  end
  else
  begin
    writln(#9'PUSH');
    Inc(pushcnt);
  end;
end;


{--------------------------------------------------------------}
{ Add TOS to Primary }

procedure PopAdd;
var i: integer;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    //      writln( #9'EXAB');
    writln(#9'LP'#9'0');
    writln(#9'ADB'#9#9'; Addition');
    writln(#9'LP'#9'1');
    writln(#9'LDM');
    writln(#9'EXAB');
    writln(#9'LP'#9'0');
    writln(#9'LDM');
  end
  else if optype = floatp then
  begin
    writln(#9'; PopAdd float');
    PopFloat;
    writln( #9'LP 0x10 ; tempFloat --> Xreg; (Q) -> (P), I+1 times' );
    writln( #9'LIQ 0x'+IntToHex(tempFloat,2) );
    writln( #9'LII 7'); // 8 bytes
    writln( #9'MVW');
    // Floating point addition
    writln( #9'CALL 0x10C2 ; Xreg + Yreg -> Xreg ( PC-1403 only? )');
    writln( #9'LP 0x'+IntToHex(tempFloat,2)+' ; Xreg --> tempFloat; (Q) -> (P), I+1 times' );
    writln( #9'LIQ 0x10' );
    writln( #9'LII 7'); // 8 bytes
    writln( #9'MVW');
  end else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'LP'#9'3');
    writln(#9'ADM'#9#9'; Addition');
    writln(#9'EXAB');
  end;
end;


{--------------------------------------------------------------}
{ Subtract TOS from Primary }

procedure PopSub;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAM');
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAM');
    writln(#9'SBB'#9#9'; Subtraction');
    writln(#9'LP'#9'1');
    writln(#9'LDM');
    writln(#9'EXAB');
    writln(#9'LP'#9'0');
    writln(#9'LDM');
  end else if optype = floatp then
  begin
    writln(#9'; PopSub float');
    PopFloat;
    writln( #9'LP 0x10 ; tempFloat --> Xreg; (Q) -> (P), I+1 times' );
    writln( #9'LIQ 0x'+IntToHex(tempFloat,2) );
    writln( #9'LII 7'); // 8 bytes
    writln( #9'MVW');
    // Floating point subtraction
    writln( #9'CALL 0x10D8 ; Yreg - Xreg -> Xreg ( PC-1403 only? )');
    writln( #9'LP 0x'+IntToHex(tempFloat,2)+' ; Xreg --> tempFloat; (Q) -> (P), I+1 times' );
    writln( #9'LIQ 0x10' );
    writln( #9'LII 7'); // 8 bytes
    writln( #9'MVW');
  end else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'LP'#9'3');
    writln(#9'EXAB');
    writln(#9'SBM'#9#9'; Subtraction');
    writln(#9'EXAB');
  end;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Multiply TOS by Primary }

procedure PopMul;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_MUL16'#9'; Multiplication');
    addlib(MUL16);
  end else if optype = floatp then
  begin
    writln(#9'; PopMul float');
    PopFloat;
    writln( #9'LP 0x10 ; tempFloat --> Xreg; (Q) -> (P), I+1 times' );
    writln( #9'LIQ 0x'+IntToHex(tempFloat,2) );
    writln( #9'LII 7'); // 8 bytes
    writln( #9'MVW');
    // Floating point multiplication
    writln( #9'CALL 0x10E1 ; Yreg * Xreg -> Xreg ( PC-1403 only? )');
    writln( #9'LP 0x'+IntToHex(tempFloat,2)+' ; Xreg --> tempFloat; (Q) -> (P), I+1 times' );
    writln( #9'LIQ 0x10' );
    writln( #9'LII 7'); // 8 bytes
    writln( #9'MVW');
  end else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_MUL8'#9'; Multiplication');
    addlib(MUL8);
  end;
end;

{--------------------------------------------------------------}
{ Divide Primary by TOS }

procedure PopDiv;
begin
  if optype = word then
  begin
    writln(#9'LP'#9'0');
    writln(#9'EXAM');
    writln(#9'EXAB');
    writln(#9'LP'#9'1');
    writln(#9'EXAM');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_DIV16'#9'; Division');
    addlib(DIV16);
  end else if optype = floatp then
  begin
    writln(#9'; PopDiv float');
    PopFloat;
    writln( #9'LP 0x10 ; tempFloat --> Xreg; (Q) -> (P), I+1 times' );
    writln( #9'LIQ 0x'+IntToHex(tempFloat,2) );
    writln( #9'LII 7'); // 8 bytes
    writln( #9'MVW');
    // Floating point division
    writln( #9'CALL 0x10EA ; Yreg / Xreg -> Xreg ( PC-1403 only? )');
    writln( #9'LP 0x'+IntToHex(tempFloat,2)+' ; Xreg --> tempFloat; (Q) -> (P), I+1 times' );
    writln( #9'LIQ 0x10' );
    writln( #9'LII 7'); // 8 bytes
    writln( #9'MVW');
  end else
  begin
    writln(#9'EXAB');
    writln(#9'POP');
    Dec(pushcnt);
    writln(#9'CALL'#9'LIB_DIV8'#9'; Division');
    addlib(DIVMOD8);
  end;
end;
{--------------------------------------------------------------}


begin
  for libcnt := 0 to 100 do
    libins[libcnt] := False;
  asmcnt := 0;
  libcnt := 0;

  libname[MUL8] := 'mul8';
  libname[DIVMOD8] := 'divmod8';
  libname[SR8] := 'sr8';
  libname[SL8] := 'sl8';
  libname[XOR8] := 'xor8';

  libname[MUL16] := 'mul16';
  libname[DIV16] := 'div16';
  libname[MOD16] := 'mod16';
  libname[AND16] := 'and16';
  libname[OR16] := 'or16';
  libname[XOR16] := 'xor16';
  libname[SR16] := 'sr16';
  libname[SL16] := 'sl16';
  libname[NOT16] := 'not16';
  libname[NEG16] := 'neg16';

  libname[CPE16] := 'cpe16';
  libname[CPNE16] := 'cpne16';
  libname[CPS16] := 'cps16';
  libname[CPG16] := 'cpg16';
  libname[CPSE16] := 'cpse16';
  libname[CPGE16] := 'cpge16';

end.

