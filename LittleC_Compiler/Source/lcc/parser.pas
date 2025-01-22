//{$MODE DELPHI}
{--------------------------------------------------------------}
unit Parser;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{--------------------------------------------------------------}
interface
uses Input, Scanner, Errors, CodeGen, Output, sysutils, calcunit, math;

procedure FirstScan(filen: string);
procedure SecondScan(filen: string);
procedure Assignment;
procedure Expression;
procedure NotFactor;
procedure Factor;
procedure SignedTerm;
procedure Term;
procedure ProcCall;
function vardecl: string;


type
        VarEntry = record
        VarName: string;
        Xram, At, Arr, Local, Pointer: boolean;
        address, locproc: integer;
        size, initn: integer;
        initf: Float;
        Typ, PntTyp, inits: string;
        end;

type
        ProcEntry = record
        ProcName: string;
        ProcCode: string;
        hasreturn, ReturnIsWord, IsCalled: boolean;
        ReturnType: string;
        Params: string;
        ParCnt: integer;
        ParName, ParTyp: Array [0..20] of string;
        LocCnt: integer;
        LocName, LocTyp: Array [0..20] of string;
        end;



{--------------------------------------------------------------}
implementation

var VarList: Array [0..1000] of VarEntry;
    VarCount: integer;
    ProcList: Array [0..1000] of ProcEntry;
    ProcCount, CurrProc: integer;
    VarPos: integer;
    VarFound, ProcFound: integer;
    org, innerloop, exitlabel: string;
    pointer: integer;
    procd, firstp, nosave, mainfound: boolean;
//    MemImg: Array [0..95] of integer;

// Build a string of bytes in the Sharp floating point BCD format
// Numbers from -9.999999999 x 10^99 to 9.999999999 x 10^99 can be represented
function SharpBCD(x: Float): String;
var
  m: Float ;
  i, e, c: integer;
  d: string;
begin

  if x=0.0 then begin
      for i := 1 to 8 do Result := Result + chr(0);
      exit;
  end else
      e := round(Log10(abs(x)));

  if ( e < -99 ) or ( e > 99 ) then
     Error ( 'Float OUT OF RANGE :' + FloatToStr ( x ) );

  m := abs(x/intpower(10.0, e - 10 ));
  {if sign(e) = 1 then
  begin
      e := e - 1;
      m := m * 10;
  end;
  }

  Result := '';
  c := 0;

  // build a 12 digits mantissa
  for i := 1 to 6 do begin
       c := trunc ( m mod 10 );
       m := trunc (m / 10);
       c := trunc ( m mod 10 ) * 16 + c;
       m := trunc (m / 10);
       Result := chr(c) + Result ;
       c := 0;
  end;

  // mantissa sign
  // Zero is used when the mantissa is positive
  // Eight is used when the mantissa is negative.
  if sign(x) = -1 then c := 8
  else c := 0;

  // exponent
  // The most significant digit is zero for positive numbers.
  // Negative numbers are represented using a 100-complement.
  //   "901" ( 10E-99 ) to "099" (10E99)
  if sign(e) = -1 then
  begin
       e := e + 100;
       Result := chr ( trunc ( e mod 10 ) * 16 + c ) + Result;
       c := 9 * 16;
  end else
  begin
       Result := chr ( trunc ( e mod 10 ) * 16 + c ) + Result;
       c := 0;
  end;
  e := trunc (e / 10);
  Result := chr ( c + trunc ( e mod 10 ) ) + Result;
end;



function mathparse(s: string; w: integer): Float;
var i, p, k: integer;
    c, s2: string;
    lf: boolean;
    r: Float;

procedure skiphex(var hs: string; var hi:integer);
begin
    while (hi < length(hs)) and (upcase(hs[hi]) in ['0'..'9','A'..'F']) do
      inc(hi);
end;

procedure skipbin(var hs: string; var hi:integer);
begin
    while (hi < length(hs)) and (upcase(hs[hi]) in ['0','1']) do
      inc(hi);
end;

begin
        if pos('''', s) > 0 then
        begin
                i := 1;
                while (i <= length(s)) do
                begin
                    if (s[i] = '''') then
                    begin
                        c := inttostr(ord(s[i+1]));
                        delete(s, i, 3);
                        insert(c, s, i);
                        i := i - 3 + length(c);
                    end;
                    inc(i);
                end;
        end;

        i := 1;
        lf := false;
        while i < length(s) do
        begin
                if upcase(s[i]) in ['_','A'..'Z'] then
                begin
                    if (i > 1) and (s[i - 1] = '0') then
                    begin
                        inc(i);
                        if upcase(s[i-1]) = 'X' then skiphex(s, i)
                        else if upcase(s[i-1]) = 'B' then skipbin(s, i);
                        dec(i);
                    end
                    else begin
                        s2 := '';
                        while (i <= length(s)) and (upcase(s[i]) in ['0'..'9','_','A'..'Z']) do
                        begin
                                s2 := s2 + s[i];
                                inc(i);
                        end;
                        if (uppercase(s2) <> 'LB') and
                        (uppercase(s2) <> 'HB') and (uppercase(s2) <> 'NOT') and
                        (uppercase(s2) <> 'SIN') and (uppercase(s2) <> 'TAN') and
                        (uppercase(s2) <> 'COS') and (uppercase(s2) <> 'FAK') and
                        (uppercase(s2) <> 'ABS') and (uppercase(s2) <> 'SQRT') and
                        (uppercase(s2) <> 'SQR') and (uppercase(s2) <> 'LN') and
                        (uppercase(s2) <> 'LOG') and (uppercase(s2) <> 'EXP') and
                        (uppercase(s2) <> 'ARCTAN') and (uppercase(s2) <> 'PI') and
                        (uppercase(s2) <> 'E') then
                        begin
				lf := true;
                        end;
                    end;
                end;
                inc(i);
        end;
        if lf then begin result := 0; exit; end;

	Evaluate(s, w, r, p);
        if p <> 0 then
        begin
                writeln('Erroneous formula: <' + s + '>');
                Error('Formula error!');
        end;

        // r could evaluate to a floating point (w = 0)
        // truncate to integer size only if needed (e.g. w = 8 or w = 16)
        if not w = 0 then begin
           for i := 0 to w-1 do k:=k or (1 shl i);
           result := trunc(r) and k;
        end else
            result := r ; // handles floating point too!
end;


function find_text(such, text: string): integer;
var i: integer;
    c: char;
begin
	result := 0;
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
		result := i - 1;
                break;
            end;
            inc(i);
	end;
end;

{--------------------------------------------------------------}
{ Print Var Table }

procedure printvarlist;
var i, j, c, initn, adr, size, lproc: integer;
    s, name, typ, inits: string;
    initf: Float;
    xr, arr, loc: boolean;
begin
        writeln;
        writeln('VARIABLES DECLARED:');
        writeln;
        for i:=0 to varcount-1 do
        begin
                name := Varlist[i].varname;
                typ := varlist[i].typ;
                xr := varlist[i].xram;
                arr := varlist[i].arr;
                adr := varlist[i].address;
                size := varlist[i].size;
                initn := varlist[i].initn;
                initf := varlist[i].initf;
                inits := varlist[i].inits;
                if varlist[i].pointer then s:='*' else s:='';
                loc := varlist[i].local;
                lproc := varlist[i].locproc;

                write('VAR ',i+1,': ');
                write(s+name,', TYP: ',typ,', ADR: ',adr,', XRAM: ');
                if xr then write('yes, LOCAL: ') else write('no, LOCAL: ');
                if loc then s := ProcList[lproc].ProcName;
                if loc then write('yes, FUNC: '+s+', SIZE: ') else write('no, SIZE: ');
                write(size);
                if initn <> -1 then
                begin
                        write(', INIT=');
                        if arr then
                        begin
                                if typ = 'char' then
                                        writeln('"',inits,'"')
                                else if typ = 'byte' then
                                for c := 1 to size do
                                begin
                                        write(ord(inits[c]));
                                        if c < size then
                                                write(', ')
                                        else
                                                writeln;
                                end
                                else if typ = 'word' then
                                for c := 1 to size do
                                begin
                                        write(256*ord(inits[c*2-1])+ord(inits[c*2]));
                                        if c < size then
                                                write(', ')
                                        else
                                                writeln;
                                end
                                else if typ = 'float' then begin
                                  writeln();
                                  for c := 0 to size-1 do begin
                                      write(#9);
                                      for j := 1 to 7 do write(IntToHex(ord(inits[c*8+j]))+',');
                                      writeln(IntToHex(ord(inits[c*8+8])))
                                  end;
                                end;
                        end else
                                if typ = 'char' then
                                        writeln(chr(initn))
                                else if ( typ = 'byte' ) or ( typ = 'word') then
                                        writeln(initn)
                                else if ( typ = 'float') then
                                begin
                                        write (' ');
                                        for j := 1 to 7 do write(IntToHex(ord(inits[j]))+',');
                                        writeln(IntToHex(ord(inits[8])));
                                end;
                end else
                        writeln;
        end;
end;


{--------------------------------------------------------------}
{ Print Proc Table }

procedure printproclist;
var i: integer;
begin
        writeln;
        writeln('PROCEDURES DECLARED:');
        writeln;
        for i:=0 to proccount-1 do
        begin
                write('PROC ',i+1,': ');
                write(Proclist[i].procname);//,', CODE: ',proclist[i].proccode);
                if Proclist[i].hasreturn then
                begin
                  write(', RETURNS: ', Proclist[i].returntype);
                  {if Proclist[i].returnisword then write('word') else write('byte');}
                end;
                if Proclist[i].parcnt > 0 then writeln(', PARAMS: ',Proclist[i].params) else writeln;
        end;
        writeln;
end;


{--------------------------------------------------------------}
{ Test if variable is at address }

function IsVarAtAdr(adr, size: integer): boolean;
var i: integer;
begin
        result := false;
        VarFound := -1;
        if adr = -1 then exit;
{        for i:=adr to adr+size-1 do
                if memimg[i] <> -1 then
                begin
                        IsVarAtAdr := true;
                        VarFound := i;
                        break;
                end;
}
        for i := 0 to VarCount - 1 do
            begin
              // check whether two ranges [x1:x2] and [y1:y2] overlap
              //
              // The only time the ranges DON'T overlap is when
              // the end of one range is before the beginning of the other.
              //
              // So (in C syntax), we want    !(x2 < y1 || x1 > y2)
              // which is equivalent to        x2 >= y1 && x1 <= y2
              if ( (adr + size >= VarList[i].address)
              and  (adr < VarList[i].address + VarList[i].size) ) then
              begin
                      result := true;
                      VarFound := i;
                      break;
              end;
            end;
end;


{--------------------------------------------------------------}
{ Allocate Variable Declaration }

function AllocVar(xr, at: boolean; size, adr: integer): integer;
var s: string;
begin
        if not xr then
        begin
                if at then
                begin
                        result := adr;
                        if IsVarAtAdr(result, size) then
                           Error('Overlapping with '+VarList[VarFound].varname+'!');
                        { begin
                                if VarList[VarFound].at then
                                begin
                                        str(VarList[VarFound].address, s);
                                        Error('Previous var '+VarList[VarFound].varname+' at '+s+' already declared!');
                                end;
                                VarList[VarFound].address := VarPos;
                                inc(VarPos, VarList[VarFound].size);
                                if size = 2 then if IsVarAtAdr(result
                                   //+1
                                   , size) then
                                begin
                                        if VarList[VarFound].at then
                                        begin
                                                str(VarList[VarFound].address, s);
                                                Error('Overlap with '+VarList[VarFound].varname+' at '+s+'!');
                                        end;
                                        VarList[VarFound].address := VarPos;
                                        inc(VarPos, VarList[VarFound].size);
                                end;
                                result := adr;
                        end;
                        }
                end else
                begin
                     // look for first free position
                     while IsVarAtAdr(VarPos, size) do
                          inc(VarPos);//, VarList[VarFound].size);
                     result := VarPos;
                     inc(VarPos, size);
                end;
                //for i:=AllocVar to AllocVar+size-1 do memimg[i] := VarCount;
        end else
                result := -1;
end;


{--------------------------------------------------------------}
{ Find Variable Declaration }

function FindVar(t: string): boolean;
var i: integer;
begin
        result := false;
        for i := 0 to VarCount - 1 do
        if lowercase(VarList[i].VarName) = lowercase(t) then
        begin
                result := true;
                VarFound := i;
                exit;
        end;
end;


{--------------------------------------------------------------}
{ Add Variable Declaration }

procedure AddVar(t, typ: string; xr, pnt, loc: boolean);
var s, litem, bcd: string;
    temp, arsize: integer;
    b: char;
begin
        s := ExtrWord(t);
        if FindVar(s) then
           Error('Variable already declared: ' + s);

        VarList[VarCount].VarName := s;
        VarList[VarCount].pointer := pnt;
        VarList[VarCount].Xram := xr;
        VarList[VarCount].Local := loc;
        VarList[VarCount].Typ := typ;
        if pnt then
        begin
                VarList[VarCount].PntTyp := typ;
                if xr then
                    VarList[VarCount].Typ := 'word'
                else
                    VarList[VarCount].Typ := 'byte';
        end;

        if (typ = 'byte') or (typ = 'char') then
                VarList[VarCount].size := 1
        else if (typ = 'word') then
                VarList[VarCount].size := 2
        else if (typ = 'float') then
                VarList[VarCount].size := 8
        else Error ('Unsupported type: ' + typ) ;

        if (t <> '') and (t[1] = '[') then
        begin
                s := ExtrCust(t, ']');
                //if s[1] <> '[' then Expected('[size]');
                delete(s, 1, 1);
                arsize := trunc(mathparse(s, 16));
                //val(s, arsize, temp);
//                                if arsize >= 256 then Error('Array too big!');
                VarList[VarCount].size := arsize;
                VarList[VarCount].arr := true;
        end;

        VarList[VarCount].At := false;

        //s := ExtrWord(t);
        if not loc then
        begin
            if copy(t,1,2) = 'at' then
            begin
                s := ExtrWord(t);
                if pos('=', t) > 0 then
                begin
                        s := ExtrCust(t, '=');
                        if t <> '' then
                                if t[1] = '(' then t := ' ' + t;
                        t := '=' + t;
                end else
                        s := t;
                //val(s, temp, c);
                temp := trunc(mathparse(s, 16));
                if temp > 95 then xr := true;
                VarList[VarCount].Xram := xr;
                VarList[VarCount].At := true;
                VarList[VarCount].address := temp;
                if pnt then
                begin
                    if xr then
                        begin VarList[VarCount].Typ := 'word'; VarList[VarCount].size := 2; end
                    else
                        begin VarList[VarCount].Typ := 'byte'; VarList[VarCount].size := 1; end;
                end;
                AllocVar(xr, true, VarList[VarCount].size, temp);
                //s := ExtrWord(t);
            end else
            begin
                VarList[VarCount].At := false;
                {if typ = 'word' then
                        temp := AllocVar(xr, VarList[VarCount].At, VarList[VarCount].size, -1)
                else if (typ = 'byte') or (typ = 'char') then
                        temp := AllocVar(xr, VarList[VarCount].At, VarList[VarCount].size, -1)
                else if typ = 'float' then
                        temp := AllocVar(xr, VarList[VarCount].At, VarList[VarCount].size, -1);  }
                temp := AllocVar(xr, VarList[VarCount].At, VarList[VarCount].size, -1) ;
                VarList[VarCount].address := temp;
            end;
            if (t <> '') and (t[1] = '=') then
            begin // with an init value
                if Loc then error('Local vars can''t have init values!'); // why?
                if Pnt then error('Pointers can''t have init values!');
                delete(t, 1, 1);
                if VarList[VarCount].arr then
                begin // array
                  if(typ = 'char') then
                  begin
                          delete(t, 1, 1); delete(t, length(t), 1);
                          //VarList[VarCount].inits := stringparse(t, size);
                          VarList[VarCount].inits := t+chr(0);
                          VarList[VarCount].initn := 0;
                          VarList[VarCount].initf := 0;
                  end else if VarList[VarCount].arr and (typ = 'byte') then
                  begin
                          delete(t, 1, 2); delete(t, length(t), 1);
                          t := t + ',';
                          litem := ExtrList(t);
                          repeat
                                  VarList[VarCount].inits := VarList[VarCount].inits
                                                          + chr(trunc(mathparse(litem, 8)));
                                  litem := ExtrList(t);
                          until litem = '';
                          VarList[VarCount].initn := 0;
                          VarList[VarCount].initf := 0;
                  end else if VarList[VarCount].arr and (typ = 'word') then
                  begin
                          delete(t, 1, 2); delete(t, length(t), 1);
                          t := t + ',';
                          litem := ExtrList(t);
                          repeat
                                  VarList[VarCount].inits := VarList[VarCount].inits
                                                          + chr(trunc(mathparse(litem+'/256', 8)))
                                                          + chr(trunc(mathparse(litem+'%256', 8)));
                                  litem := ExtrList(t);
                          until litem = '';
                          VarList[VarCount].initn := 0;
                          VarList[VarCount].initf := 0;
                  end else if VarList[VarCount].arr and (typ = 'float') then
                  begin
                       delete(t, 1, 2); delete(t, length(t), 1);
                       t := t + ',';
                       litem := ExtrList(t);
                       VarList[VarCount].inits := '';
                       repeat
                             VarList[VarCount].inits := VarList[VarCount].inits
                                               + SharpBCD ( mathparse(  litem, 0 ));
                             litem := ExtrList(t);
                       until litem = '';
                       for b in VarList[VarCount].inits do
                           s := s + IntToHex(ord(b),2)+ ' ';
                       VarList[VarCount].initn := 0;
                       VarList[VarCount].initf := 0;
                  end
                end else
                begin // not an array
                   if not ( typ = 'float' ) then
                   begin
                      //val(t, VarList[VarCount].initn, temp);
                      VarList[VarCount].initn := trunc(mathparse(t, 16)) ;
                      VarList[VarCount].initf := 0;
                   end
                   else if ( typ = 'float' ) then
                   begin
                      VarList[VarCount].initf := mathparse(t, 0) ; // 0 = floating point
                      VarList[VarCount].initn := 0;
                      VarList[VarCount].inits := SharpBCD ( VarList[VarCount].initf ) ;
                   end;
                end;
            end else // not init value
                VarList[VarCount].initn := -1;
                VarList[VarCount].initf := -1;
                if ( typ = 'float' ) then
                    VarList[VarCount].inits := SharpBCD ( 0 ) ;

        end else
        begin // procedure local or parameters

               if copy(t,1,2) = 'at' then
                  Error ('Local vars can''t have "at" assignments!');
               if (t <> '') and (t[1] = '=') then
                  Error ('Local vars can''t have have init values');

                VarList[VarCount].initn := -1;
                VarList[VarCount].initf := -1;
                if ( typ = 'float' ) then
                    VarList[VarCount].inits := SharpBCD ( 0 ) ;
                if not procd then
                begin
                        ProcList[currproc].locname[ProcList[currproc].loccnt] := VarList[VarCount].VarName;
                        ProcList[currproc].loctyp[ProcList[currproc].loccnt] := VarList[VarCount].typ;
                        inc(ProcList[currproc].loccnt);
                end;
        end;

{                       write('Var add: NAME: ' + VarList[VarCount].VarName + ', XRAM: ');
        if VarList[VarCount].Xram then
                write('yes, ADR: ') else write('no, ADR: ');
        writeln(VarList[VarCount].address);
}

        inc(VarCount);

end;


{--------------------------------------------------------------}
{ Find Procedure Declaration }

function FindProc(t: string): boolean;
var i: integer;
begin
        result := false;
        for i := 0 to ProcCount - 1 do
        if lowercase(ProcList[i].ProcName) = lowercase(t) then
        begin
              //writeln('Proc found: ' + t);
              result := true;
              ProcFound := i;
              exit;
        end;
end;


{--------------------------------------------------------------}
{ Add Procedure Declaration }

procedure AddProc(t, c, p: string; pc: integer; hr, wd: boolean; rt: string);
var s: string;
begin
        s := ExtrWord(t);
        if not FindProc(s) then
        begin
                ProcList[ProcCount].ProcName := s;
                ProcList[ProcCount].ProcCode := c;
                ProcList[ProcCount].Params := p;
                ProcList[ProcCount].Parcnt := pc;
                ProcList[ProcCount].HasReturn := hr;
                ProcList[ProcCount].ReturnType := rt;
                ProcList[ProcCount].ReturnIsWord := wd;
                ProcList[ProcCount].IsCalled := false;
                inc(ProcCount);
                //writeln('Proc add: NAME: <' + s + '>');
        end else
                Error('Procedure already declared: <' + s + '>');
end;


procedure removelocvars(pn: string);
var i, c: integer;
begin
        i := 0;
        if not findproc(pn) then error('Procedure '+pn+' unknown!');
        if proclist[procfound].parcnt = 0 then exit;
        while (i < varcount) do
        begin
                if varlist[i].local and (varlist[i].locproc = ProcFound) then
                begin
                        for c := i to varcount - 2 do
                                varlist[c] := varlist[c+1];
                        dec(varcount);
                        dec(i);
                end;
                inc(i);
        end;
end;


{--------------------------------------------------------------}
{ Store the Primary Register to a Variable }

procedure StoreVariable(Name: string);
var typ, lb: string;
    xr,arr,loc: boolean;
    adr: integer;
begin

        if not FindVar(Name) then error('Variable not defined: '+name);

        typ := varlist[varfound].typ;
        adr := varlist[varfound].address;
        loc := varlist[varfound].local;
        arr := varlist[varfound].arr;
        xr := varlist[varfound].xram;

        if not arr then
        begin
            if (typ='char') or (typ='byte') then
            begin
//                if isword then
//                        writln(#9'EXAB'#9#9'; Store only HB in byte var!');
                if not xr then
                begin
                    if not loc then
                    begin
                        if adr <= 63 then
                            writln(#9'LP'#9+inttostr(adr)+#9'; Store result in '+name)
                        else
                            writln(#9'LIP'#9+inttostr(adr)+#9'; Store result in '+name);
                        writln(#9'EXAM');
                    end else
                    begin // Local char or byte
                        writln(#9'EXAB'); // save A (value to store) to B
                        writln(#9'LDR');  // get stack ptr R to A
                        writln(#9'ADIA'#9+inttostr(adr+2+pushcnt)); // add relative address
                        writln(#9'STP'); // move result to P (absolute address)
                        writln(#9'EXAB'); // restore A
                        writln(#9'EXAM'#9#9'; Store result in '+name); // store value to P location
                    end;
                end else
                begin
                        if adr <> -1 then
                                writln( #9'LIDP'#9+inttostr(adr)+#9'; Store result in '+name)
                        else
                                writln( #9'LIDP'#9+name+#9'; Store result in '+name);
                        writln( #9'STD')
                end ;
            end else if (typ='word') then
            begin
                if not xr then
                begin
                    if not loc then
                    begin
                        if adr < 64 then
                                writln( #9'LP'#9+inttostr(adr)+#9'; Store 16bit variable '+name)
                        else
                                writln( #9'LIP'#9+inttostr(adr)+#9'; Store 16bit variable '+name);
                        writln( #9'EXAM'#9#9'; LB');
                        writln( #9'EXAB');
                        writln( #9'INCP'#9#9'; HB');
                        writln( #9'EXAM');
                    end else
                    begin // Local word
                        //writln(#9'PUSH'); inc(pushcnt); // why save R?
                        writln(#9'LDR');
                        writln(#9'ADIA'#9+inttostr(adr+2+pushcnt)); //adr + size + pushcnt
                        writln(#9'STP');
                        //writln(#9'POP'); dec(pushcnt); // see above PUSH
                        writln(#9'EXAM'#9'; LB - Store result in '+name);
                        writln(#9'EXAB');
                        writln(#9'DECP');
                        writln(#9'EXAM'#9'; HB');
                    end;
                end else
                begin
                        if adr <> -1 then
                                writln( #9'LIDP'#9+inttostr(adr)+#9'; Store 16bit variable '+name)
                        else
                                writln( #9'LIDP'#9+name+#9'; Store 16bit variable '+name);
                        writln( #9'STD'#9#9'; LB');
                        writln( #9'EXAB');
                        if (adr <> -1) and ((adr + 1) div 256 = adr div 256) then
                                writln( #9'LIDL'#9'LB('+inttostr(adr)+'+1)')
                        else if adr <> -1 then
                                writln( #9'LIDP'#9+inttostr(adr)+'+1')
                        else
                                writln( #9'LIDP'#9+name+'+1'); // PASM doesn't parse "name + 1" !!!
                        writln( #9'STD'#9#9'; HB');
                end;
            end else if (typ='float') then
            begin // value is in temporary storage point 'FloatXReg'
                if not xr then
                begin
                    if loc then
                    begin
                        // a local variable is reverse-orderd in stack
                        writln('');
                        writln(#9'; Move 8 bytes from primary float reg local var storage, reversed');
                        // to:
                        writln(#9'LDR'); // R -> A
                        writln(#9'EXAB'); // save R in B first
                        writln(#9'LDR'); // R -> A
                        writln(#9'ADIA'#9+inttostr(adr+2+pushcnt+2)+#9'; to: '+name+' end + 2');
                        writln(#9'STR'); // now R points to the local variable start addr
                        // from:
                        writln(#9'LIP 0x'+IntToHex(FloatXReg,2)+#9'; from: primary float reg addr' );
                        // loop 8 times
                        writln(#9'LIJ 7');
                        lb := NewLabel;
                        PostLabel(lb);
                        // move using LDM+PUSH
                        writln(#9'LDM'); // (P) -> A
                        writln(#9'PUSH'); inc(pushcnt);
                        writln(#9'INCP');
                        writln(#9'DECJ');
                        writln(#9'JRNZM '+lb);
                        writln(#9'EXAB'); // restore R
                        writln(#9'STR'); // A -> R
                    end else
                    begin // not local
                        if adr < 64 then
                             writln( #9'LP'#9'0x'+IntToHex(adr,2)+#9'; store float var '+name )
                        else
                             writln( #9'LIP'#9'0x'+IntToHex(adr,2)+#9'; store float var '+name );
                        // store value to variable
                        writln( #9'LIQ 0x'+IntToHex(FloatXReg,2)+#9'; from temp float reg' );
                        writln( #9'LII 7');
                        writln( #9'MVW ; (FloatXReg) -> (P), 8 bytes');
                    end;
                end else
                begin // destination: xram or code space
                    if adr <> -1 then
                       writln( #9'LIDP'#9+'0x'+inttohex(adr,4)+#9'; Store float var '+name )
                    else
                       writln( #9'LIDP'#9+name+#9'; store var '+name );
                    writln( #9'LP 0x'+IntToHex(FloatXReg,2)+' ; temp float reg' );
                    writln( #9'LII 7');
                    writln( #9'EXWD ; (DP) <-> (FloatXReg), 8 bytes' );
                end;
            end ;
        end else
        begin  // arrays
            if loc then
               Error ( 'Local arrays unsupported yet');
            if (typ='char') or (typ='byte') then
            begin
                if not xr then
                begin
                        writln( #9'LIB'#9+inttostr(adr)+#9'; Store array element from '+name);
                        writln( #9'LP'#9'3');
                        writln( #9'ADM');
                        writln( #9'EXAB');
                        writln( #9'STP');
                        writln( #9'POP'); dec(pushcnt);
                        writln( #9'EXAM');
                end else
                begin
                        writln( #9'PUSH'#9#9'; Store array element from '+name); inc(pushcnt);
                        writln( #9'LP'#9'7'#9'; HB of address');
                        if adr <> -1 then
                        begin
                                writln( #9'LIA'#9'HB('+inttostr(adr)+'-1)');
                                writln( #9'EXAM');
                                writln( #9'LP'#9'6'#9'; LB');
                                writln( #9'LIA'#9'LB('+inttostr(adr)+'-1)');
                        end else
                        begin
                                writln( #9'LIA'#9'HB('+name+'-1)');
                                writln( #9'EXAM');
                                writln( #9'LP'#9'6'#9'; LB');
                                writln( #9'LIA'#9'LB('+name+'-1)');
                        end;
                        writln( #9'EXAM');
                        writln( #9'POP'); dec(pushcnt);
                        writln( #9'LIB'#9'0');
                        writln( #9'ADB');
                        writln( #9'POP'); dec(pushcnt);
                        writln( #9'IYS');
                end;
            end else if (typ='word') then
            begin
                if not xr then
                begin
                        writln( #9'RC');
                        writln( #9'SL');
                        writln( #9'LII'#9+inttostr(adr)+#9'; Store array element from '+name);
                        writln( #9'LP'#9'0');
                        writln( #9'ADM');
                        writln( #9'EXAM');
                        writln( #9'STP');
                        writln( #9'INCP');
                        writln( #9'POP'); dec(pushcnt);
                        writln( #9'EXAM');
                        writln( #9'DECP');
                        writln( #9'POP'); dec(pushcnt);
                        writln( #9'EXAM');
                end else
                begin
                        writln( #9'RC');
                        writln( #9'SL');
                        writln( #9'PUSH'#9#9'; Store array element from '+name); inc(pushcnt);
                        writln( #9'LP'#9'7'#9'; HB of address');
                        if adr <> -1 then
                        begin
                                writln( #9'LIA'#9'HB('+inttostr(adr)+'-1)');
                                writln( #9'EXAM');
                                writln( #9'LP'#9'6'#9'; LB');
                                writln( #9'LIA'#9'LB('+inttostr(adr)+'-1)');
                        end else
                        begin
                                writln( #9'LIA'#9'HB('+name+'-1)');
                                writln( #9'EXAM');
                                writln( #9'LP'#9'6'#9'; LB');
                                writln( #9'LIA'#9'LB('+name+'-1)');
                        end;
                        writln( #9'EXAM');
                        writln( #9'POP'); dec(pushcnt);
                        writln( #9'LIB'#9'0');
                        writln( #9'ADB');
                        writln( #9'POP'); dec(pushcnt);
                        writln( #9'EXAB');
                        writln( #9'POP'); dec(pushcnt);
                        writln( #9'IYS');
                        writln( #9'EXAB');
                        writln( #9'IYS');
                end;
            end else if (typ='float') then
            begin
                 Error ( 'Float array storing unsupported yet ');
            end ;
        end;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Load the Primary Register with a Constant }

procedure LoadConstant(n: string);
var i, c: integer;
var s, lb: string;
var f: float;
begin

    if optype = floatp then
    begin
        f := mathparse ( n, 0 );
        if not (f = 0) then
        begin
          s := SharpBCD ( f );
          lb := 'C_'+NewLabel;
          varfcode ( s, lb );
          writln( #9'LIDP'#9+lb+' ; Load floating-point constant: '+n );
          writln( #9'LP'#9'0x'+IntToHex(FloatXReg,2)+' ; temporary store point' );
          writln( #9'LII 07');
          writln( #9'MVWD' );
        end else
        begin
          writln( #9'LIA 00');
          writln( #9'LP'#9'0x'+IntToHex(FloatXReg,2)+' ; temporary store point' );
          writln( #9'LII 07');
          writln( #9'FILM' );
        end;
    end else
    if optype = word then
    begin
        writln( #9'LIA'#9'LB('+n+')'#9'; Load word constant LB');
        writln( #9'LIB'#9'HB('+n+')'#9'; Load word constant HB');
    end else
    begin
        val(n, i, c);
	{ if (c = 0) and (i = 0) then
                writln( #9'RA'#9#9'; Load 0')
        else      }
                writln( #9'LIA'#9+n+#9'; Load byte constant '+n);
    end;
end;


{--------------------------------------------------------------}
{ Load a Variable to the Primary Register }

procedure LoadVariable(Name: string);
var typ, lb: string;
    xr,arr,loc: boolean;
    adr: integer;
begin

        if not FindVar(Name) then
                error('Variable not defined: '+name);

        typ := varlist[varfound].typ;
        adr := varlist[varfound].address;
        loc := varlist[varfound].local;
        arr := varlist[varfound].arr;
        xr := varlist[varfound].xram;

        if not arr then
        begin
            if (typ='char') or (typ='byte') then
            begin
                if not xr then
                begin
                    if not loc then
                    begin
                        if adr < 64 then
                                writln( #9'LP'#9+inttostr(adr)+#9'; Load variable '+name)
                        else
                                writln( #9'LIP'#9+inttostr(adr)+#9'; Load variable '+name);
                        writln( #9'LDM');
                    end else
                    begin // Local char or byte
                        writln(#9'LDR');
                        writln(#9'ADIA'#9+inttostr(adr+2+pushcnt));
                        writln(#9'STP');
                        writln(#9'LDM'#9#9'; Load variable '+name);
                    end;
                end else
                begin
                    if loc then
                       Error ( 'Xram Local loading Unsupported' );
                    if adr <> -1 then
                            writln( #9'LIDP'#9+inttostr(adr)+#9'; Load variable '+name)
                    else
                            writln( #9'LIDP'#9+name+#9'; Load variable '+name);
                    writln( #9'LDD');
                end;
                if optype = floatp then
                   Error ( 'Unsupported load float to byte' );
                   // TO DO - casting ?
                if optype = word then
                   // cast byte to word
                   writln( #9'LIB'#9'0');
            end else if (typ='word') then
            begin
                if optype = floatp then
                   Error ( 'Unsupported load float to word' );
                   // TO DO - casting ?
                if not xr then
                begin
                    if not loc then
                    begin
                        if adr < 64 then
                                writln( #9'LP'#9+inttostr(adr+1)+#9'; Load 16bit variable '+name)
                        else
                                writln( #9'LIP'#9+inttostr(adr+1)+#9'; Load 16bit variable '+name);
                        writln(#9'LDM'#9#9'; HB');
                        writln(#9'EXAB');
                        writln(#9'DECP'#9#9'; LB');
                        writln(#9'LDM');
                    end else
                    begin // Local word
                        writln(#9'LDR');
                        writln(#9'ADIA'#9+inttostr(adr+1+pushcnt));
                        writln(#9'STP');
                        writln(#9'LDM'#9'; HB - Load variable '+name);
                        writln(#9'EXAB');
                        writln(#9'INCP');
                        writln(#9'LDM'#9'; LB');
                    end;
                end else
                begin
                    if loc then
                       Error ( 'Unsupported Xram local load' );
                    if adr <> -1 then
                            writln( #9'LIDP'#9+inttostr(adr+1)+#9'; Load 16bit variable '+name)
                    else
                            writln( #9'LIDP'#9+name+'+1'#9'; Load 16bit variable '+name); // FIXME - PASM doesn't parse "name+1"
                    writln( #9'LDD'#9#9'; HB');
                    writln( #9'EXAB');
                    if (adr <> -1) and ((adr + 1) div 256 = adr div 256) then
                            writln( #9'LIDL'#9'LB('+inttostr(adr)+')')
                    else if adr <> -1 then
                            writln( #9'LIDP'#9+inttostr(adr))
                    else
                            writln( #9'LIDP'#9+name);
                    writln( #9'LDD'#9#9'; LB');
                end;
            end else if (typ='float') then
            begin
                if not ( optype = floatp ) then
                   Error ( 'Unsupported load other types to float' );
                if not xr then
                begin
                    if not loc then
                    begin
                        writln(#9'LIQ 0x'+IntToHex(adr,2)+#9'; from here');
                        writln(#9'LP'#9'0x'+IntToHex(FloatXReg,2)+#9'; to temporary store' );
                        writln(#9'LII 7');
                        writln(#9'MVW ; (Q) -> (FloatXReg), 8 bytes');
                    end
                    else begin
                        // a local variable is reverse-ordered on stack
                        writln(#9'');
                        writln(#9'; Pop 8 bytes from local storage, to FloatXReg, reversed');
                        writln(#9'LDR'); // R -> A
                        writln(#9'EXAB'); // save R in B first
                        // from:
                        writln(#9'LDR'); // R -> A
                        writln(#9'ADIA'#9+inttostr(adr+pushcnt+2-7)+#9'; from: '+name+' offset');
                        writln(#9'STR'); // now R points to the local variable start addr
                        // to:
                        writln(#9'LIP 0x'+IntToHex(FloatXReg+7,2)+#9'; to: primary float reg end addr' );
                        // loop 8 times
                        writln(#9'LIJ 7'#9'; move 8 bytes');
                        lb := NewLabel;
                        PostLabel(lb);
                        // move using POP+EXAM
                        writln(#9'POP'); dec(pushcnt);
                        writln(#9'EXAM'); // A <-> (P), I times (1)
                        writln(#9'DECP');
                        writln(#9'DECJ');
                        writln(#9'JRNZM '+lb);
                        writln(#9'EXAB'); // restore R
                        writln(#9'STR'); // A -> R
                    end;
                end else begin
                    if loc then
                       Error ( 'Unsupported Xram Local loading' );
                    if adr <> -1 then
                       writln( #9'LIDP'#9+'0x'+inttohex(adr,4)+#9'; Load variable '+name)
                    else
                       writln( #9'LIDP'#9+name+'+1'#9'; Load variable '+name);
                    writln(#9'LP'#9'0x'+inttohex(FloatXReg,2)+' ; to temporary store' );
                    writln(#9'LII 07');
                    writln(#9'MVWD ; (DP) -> (P), I+1 times' );
                end;
            end;
        end else
        begin // arrays
            if (typ='char') or (typ='byte') then
            begin
                if not xr then
                begin
                        writln( #9'LIB'#9+inttostr(adr)+#9'; Load array element from '+name);
                        writln( #9'LP'#9'3');
                        writln( #9'ADM');
                        writln( #9'EXAB');
                        writln( #9'STP');
                        writln( #9'LDM');
                end else
                begin
                        writln( #9'PUSH'#9#9'; Load array element from '+name); inc(pushcnt);
                        writln( #9'LP'#9'5'#9'; HB of address');
                        if adr <> -1 then
                        begin
                                writln( #9'LIA'#9'HB('+inttostr(adr)+'-1)');
                                writln( #9'EXAM');
                                writln( #9'LP'#9'4'#9'; LB');
                                writln( #9'LIA'#9'LB('+inttostr(adr)+'-1)');
                        end else
                        begin
                                writln( #9'LIA'#9'HB('+name+'-1)');
                                writln( #9'EXAM');
                                writln( #9'LP'#9'4'#9'; LB');
                                writln( #9'LIA'#9'LB('+name+'-1)');
                        end;
                        writln( #9'EXAM');
                        writln( #9'POP'); dec(pushcnt);
                        writln( #9'LIB'#9'0');
                        writln( #9'ADB');
                        writln( #9'IXL');
                end;
            end else if (typ='float') then
            begin
                Error ( 'Float array loading not supported yet ' );
            end;
        end;
end;


{--------------------------------------------------------------}
{ Parse and Translate an Addition Operation }

procedure Add;
begin
  Rd(Look, tok); tok := trim(tok);
  Push;
  Term;
  PopAdd;
end;


{--------------------------------------------------------------}
{ Parse and Translate a Subtraction Operation }

procedure Subtract;
begin
  Rd(Look, tok); tok := trim(tok);
  Push;
  Term;
  PopSub;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Parse and Translate an Multiply Operation }

procedure Multiply;
begin
  Rd(Look, tok); tok := trim(tok);
  Push;
  Term;
  PopMul;
end;


{--------------------------------------------------------------}
{ Parse and Translate a Divide Operation }

procedure Divide;
begin
  Rd(Look, tok); tok := trim(tok);
  Push;
  Term;
  PopDiv;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Parse and Translate a Subtraction Operation }

procedure _Or;
begin
  Rd(Look, tok); tok := trim(tok);
  Push;
  Term;
  PopOr;
end;


{--------------------------------------------------------------}
{ Parse and Translate a Shift Operation }

procedure ShiftR;
begin
  Rd(Look, tok); tok := trim(tok);
  Push;
  Term;
  PopSr;
end;


{--------------------------------------------------------------}
{ Parse and Translate a Shift Operation }

procedure ShiftL;
begin
  Rd(Look, tok); tok := trim(tok);
  Push;
  Term;
  PopSl;
end;


{--------------------------------------------------------------}
{ Parse and Translate a Boolean Xor Operation }

procedure _Xor;
begin
  Rd(Look, tok); tok := trim(tok);
	Push;
	Term;
	PopXor;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Parse and Translate a Boolean And Operation }

procedure _And;
begin
  Rd(Look, tok); tok := trim(tok);
	Push;
	NotFactor;
	PopAnd;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Parse and Translate a Modulo Operation }

procedure _Mod;
begin
  Rd(Look, tok); tok := trim(tok);
	Push;
	Term;
	PopMod;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Parse and Translate a Factor }

procedure Factor;
var s{, temp}: string;
    //i, c: integer;
begin
  if Look ='(' then
  begin
    Rd(Look, tok); tok := trim(tok);
    Expression;
    Rd(Look, tok); tok := trim(tok);
  end
  else if IsDigit(Look) then
  begin
    if optype = floatp then
        LoadConstant(GetFloat)
    else
        LoadConstant(GetNumber);
  end
  else if IsAlpha(Look)then
  begin
                s := GetName;
                if Look = '[' then
                begin
                        Rd(Look, Tok); tok := trim(tok);
                        Expression;
                        //Push;
                end;
                if findvar(s) then
                begin
                        if pointer = REF then
                        begin
                                LoadVariable(s);
                                if not varlist[varfound].Pointer then
                                        error('This var ('+s+') is not a pointer!');
                                if varlist[varfound].xram then
                                begin
                                        writln(#9'LP'#9'4'#9'; XL');
                                        writln(#9'EXAM');
                                        writln(#9'LP'#9'5'#9'; XH');
                                        writln(#9'EXAB');
                                        writln(#9'EXAM');
                                        writln(#9'DX');
                                        if varlist[varfound].pnttyp <> 'word' then
                                        begin
                                                writln(#9'IXL'#9#9'; Load content *'+s);
                                        end else
                                        begin
                                                writln(#9'IXL'#9#9'; Load content LB *'+s);
                                                writln(#9'EXAB');
                                                writln(#9'IXL'#9#9'; Load content HB *'+s);
                                                writln(#9'EXAB');
                                        end;
                                end else
                                begin
                                        // LIP
                                        writln(#9'STP'#9#9'; Set P');
                                        if varlist[varfound].pnttyp <> 'word' then
                                        begin
                                                writln(#9'LDM'#9#9'; Load content *'+s);
                                        end else
                                        begin
                                                writln(#9'LDM'#9#9'; Load content LB *'+s);
                                                writln(#9'EXAB');
                                                writln(#9'INCP');
                                                writln(#9'LDM'#9#9'; Load content HB *'+s);
                                                writln(#9'EXAB');
                                        end;
                                end;
                        end else
                        if pointer = ADR then
                        begin
                                if varlist[varfound].xram then
                                begin
                                        if varlist[varfound].address = -1 then
                                        begin
                                                writln(#9'LIA'#9'LB('+s+')'#9'; &'+s);
                                                writln(#9'LIB'#9'HB('+s+')'#9'; &'+s);
                                        end else
                                        begin
                                                writln(#9'LIA'#9'LB('+inttostr(varlist[varfound].address)+')'#9'; &'+s);
                                                writln(#9'LIB'#9'HB('+inttostr(varlist[varfound].address)+')'#9'; &'+s);
                                        end;
                                end else
                                begin
                                        writln(#9'LIA'#9+inttostr(varlist[varfound].address)+#9'; &'+s);
                                end;
                        end else
                                LoadVariable(s);
                end else if findproc(s) then
                begin
                        tok := s + ' (' + trim(tok);
                        ProcCall;
                        tok := trim(tok);
                end;
{                begin
                        if ProcList[ProcFound].parcnt > 0 then
                        begin
                            temp := tok; delete(temp, length(temp), 1);
                            temp := trim(temp);
                            temp := temp + ',';
                            c := 0;
                            for i := 0 to ProcList[ProcFound].parcnt-1 do
                            begin
                                tok := extrlist(temp);
                                Rd(Look, Tok); tok := trim(tok);
                                Expression;
                                if findvar(ProcList[ProcFound].parname[i]) then
                                begin
                                    varlist[varfound].address := c;
                                end else
                                    error('Parameter error!');
                                if ProcList[ProcFound].partyp[i] <> 'word' then
                                begin
                                    isword := true; inc(c, 2);
                                end else
                                begin
                                    isword := false; inc(c);
                                end;
                                Push;
                            end;
                        end;
                        writln( #9'CALL'#9+s+#9'; Procedure call');
                        Rd(Look, Tok); tok := trim(tok);
                end;  }
	end else
		Error('Unrecognized character ' + Look);
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Parse and Translate a Factor with Optional "Not" }

procedure NotFactor;
begin
  if Look = '!' then
  begin
    Rd(Look, tok); tok := trim(tok);
    Factor;
    Notit;
  end else
  if Look = '*' then
  begin
    Rd(Look, tok); tok := trim(tok);
    pointer := REF;
    Factor;
  end else
  if Look = '&' then
  begin
    Rd(Look, tok); tok := trim(tok);
    pointer := ADR;
    Factor;
  end else
  begin
    pointer := 0;
    Factor;
  end;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Parse and Translate a Term }

procedure Term;
begin
	NotFactor;
	while IsMulop(Look) do
		case Look of
			'*': Multiply;
			'/': Divide;
			'&': _And;
			'%': _Mod;
		end;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Parse and Translate a Factor with Optional Sign }

procedure SignedTerm;
var Sign: char;
begin
	Sign := Look;
	if IsAddop(Look) then
           Rd(Look, tok); tok := trim(tok);
	Term;
	if Sign = '-' then Negate;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
procedure Expression;
var i: integer;
    c: char;
begin
        tok := look + tok;
        for i := 0 to varcount - 1 do
                if find_text(varlist[i].varname, tok) > 0 then
                        if (varlist[i].typ = 'word')
                        or ( ( varlist[i].pointer ) and (varlist[i].pnttyp = 'word') ) then
                           optype := word;
        i := 1;
        while i < length(Tok) do
        begin
                if copy(Tok,i,2) = '<<' then
                        begin writln ('; << ') ; delete(tok,i,1); tok[i]:=SL; end
                else if copy(Tok,i,2) = '>>' then
                        begin writln ('; >> ') ; delete(tok,i,1); tok[i]:=SR; end
                else if copy(Tok,i,2) = '++' then
                        begin delete(tok,i,1); tok[i]:=PP; end
                else if copy(Tok,i,2) = '--' then
                        begin delete(tok,i,1); tok[i]:=MM; end
                else if copy(Tok,i,1) = '''' then
                        begin c := copy(tok, i+1,1)[1]; delete(tok,i,3); insert(inttostr(ord(c)),tok,i); dec(i); end
                else
                        inc(i);
        end;
        rd(Look, tok);

        SignedTerm;
        while IsAddop(Look) do  begin
		case Look of
			'+': Add;
			'-': Subtract;
			'|': _Or;
                        '~': _Xor;
			SR:  ShiftR;
			SL:  ShiftL;
                end;
        end;
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Parse and Translate an Assignment Statement }

procedure Assignment;
var Name,temp,s: string;
    fv: boolean;
    forml: string;
    i, p, a: integer;
begin

        isword := false;
        isfloat := false;
        p := 0;
        if copy(tok, 1, 1) = '*' then
        begin
                p := REF;
                delete(tok, 1, 1); tok := trim(tok);
        end;
        Rd(Look, Tok); tok := trim(tok);
        Name := GetName;
        if findvar(name) then
        begin
            if p = REF then
            begin
                if ( not varlist[varfound].pointer and (varlist[varfound].typ = 'word') )
                or ( varlist[varfound].pointer and (varlist[varfound].pnttyp = 'word') ) then
                        optype := word;
            end else
            if varlist[varfound].typ = 'word' then optype := word
            else if varlist[varfound].typ = 'float' then optype := floatp
            else optype := byte;
        end else
            error('Var '+name+' not declared!');
        s := '';
        if Look = '[' then
        begin
                s := tok;
                delete(tok, 1, pos('=', tok)); tok := trim(tok);
        end;
        if Look in ['+','-','*','/','%','&','|','>','<'] then
        begin
                Temp := Name + Look;
                Rd(Look, tok); tok := trim(tok);
                if Look in ['<','>'] then
                begin
                        temp := temp + Look;
                        //Rd(Look, tok); tok := trim(tok);
                end else
                if Look in ['+','-'] then
                begin
                        if findvar(name)
                        and ((varlist[varfound].typ = 'char') or (varlist[varfound].typ = 'byte')) then
                        begin
                                if look = '+' then writln(#9'; '+name+'++') else writln(#9'; '+name+'--');
                                a := varlist[varfound].address;
                                if a = 0 then begin if Look='+' then writln(#9'INCI') else writln(#9'DECI'); end
                                else if a = 1 then begin if Look='+' then writln(#9'INCJ') else writln(#9'DECJ'); end
                                else if a = 2 then begin if Look='+' then writln(#9'INCA') else writln(#9'DECA'); end
                                else if a = 3 then begin if Look='+' then writln(#9'INCB') else writln(#9'DECB'); end
                                else if a = 8 then begin if Look='+' then writln(#9'INCK') else writln(#9'DECK'); end
                                else if a = 9 then begin if Look='+' then writln(#9'INCL') else writln(#9'DECL'); end
                                else if a = 10 then begin if Look='+' then writln(#9'INCM') else writln(#9'DECM'); end
                                else if a = 11 then begin if Look='+' then writln(#9'INCN') else writln(#9'DECN'); end
                                else
                                begin
                                        Loadvariable(name);
                                        if Look = '+' then writln(#9'INCA') else writln(#9'DECA');
                                        storevariable(name);
                                end;
                                exit;
                        end else
                        begin
                                temp := name + Look + '1';
                                tok := ' ';
                        end;
                end else
                if Look = '=' then tok := ' '+ tok;
                delete(tok,1,1);
                Tok := temp + tok;
        end;
        tok := trim(tok); forml := tok;
        if copy(forml,1,1) = '=' then delete(forml,1,1);
        Rd(Look, tok); tok := trim(tok);
        fv := false;
        for i := 0 to varcount - 1 do
                if find_text(varlist[i].varname, forml) > 0 then
                begin
                        if ( not varlist[i].pointer and (varlist[i].typ = 'word') )
                        or ( varlist[i].pointer and (varlist[i].typ = 'float') )
                        or ( varlist[i].pointer and (varlist[i].pnttyp = 'word') ) then
                                optype := word;
                        fv := true;
                end;

        if not fv then
                for i := 0 to proccount - 1 do
                        if find_text(proclist[i].procname, forml) > 0 then
                                fv := true;

        if fv then
	        Expression
        else
                LoadConstant(forml);

        if s <> '' then
        begin
                Push;
                tok := s;
                Rd(Look, Tok); tok := trim(tok);
                Expression;
        end;
	if p = 0 then
                StoreVariable(Name)
        else if p = REF then
        begin
                if findvar(Name) then
                begin
                        if varlist[varfound].pnttyp <> 'word' then
                        begin
                                writln(#9'PUSH'); inc(pushcnt);
                        end else
                        begin
                                writln(#9'PUSH'); inc(pushcnt);
                                writln(#9'EXAB');
                                writln(#9'PUSH'); inc(pushcnt);
                        end;
                        LoadVariable(name);
                        if not varlist[varfound].Pointer then
                                        error('This var ('+name+') is not a pointer!');
                        if varlist[varfound].xram then
                        begin
                                        writln(#9'LP'#9'6'#9'; YL');
                                        writln(#9'EXAM');
                                        writln(#9'LP'#9'7'#9'; YH');
                                        writln(#9'EXAB');
                                        writln(#9'EXAM');
                                        writln(#9'DY');
                                        if varlist[varfound].pnttyp <> 'word' then
                                        begin
                                                writln(#9'POP'); dec(pushcnt);
                                                writln(#9'IYS'#9#9'; Store content *'+s);
                                        end else
                                        begin
                                                writln(#9'POP'); dec(pushcnt);
                                                writln(#9'EXAB');
                                                writln(#9'POP'); dec(pushcnt);
                                                writln(#9'IYS'#9#9'; Store content LB *'+s);
                                                writln(#9'EXAB');
                                                writln(#9'IYS'#9#9'; Store content HB *'+s);
                                        end;
                        end else
                        begin
                                        // LIP
                                        writln(#9'STP'#9#9'; Set P');
                                        if varlist[varfound].pnttyp <> 'word' then
                                        begin
                                                writln(#9'POP'); dec(pushcnt);
                                                writln(#9'EXAM'#9#9'; Store content *'+s);
                                        end else
                                        begin
                                                writln(#9'POP'); dec(pushcnt);
                                                writln(#9'EXAB');
                                                writln(#9'POP'); dec(pushcnt);
                                                writln(#9'EXAM'#9#9'; Store content LB *'+s);
                                                writln(#9'EXAB');
                                                writln(#9'EXAM'#9#9'; Store content HB *'+s);
                                        end;
                        end;
                end;
        end;
end;
{--------------------------------------------------------------}


{---------------------------------------------------------------}
{ Parse and Translate a Comparison Term }
procedure NotCompTerm; Forward;
procedure BoolExpression; Forward;

procedure CompTerm;
var compOp: char;
begin
	if Look ='(' then
        begin
                //Rd(Look, tok); tok := trim(tok);
		BoolExpression;
                Rd(Look, tok); tok := trim(tok);
	end else
        begin
	        Expression;
	        Push;
                compOp := Look;
	        Rd(Look, Tok); tok := trim(tok);
	        Expression;
	        case compOp of
	          '>': CompGreater;
	          '<': CompSmaller;
	          EQ: CompEqual;
	          GE: CompGrOrEq;
	          SE: CompSmOrEq;
	          NE: CompNotEqual;
                end;
        end;
end;

procedure NotCompTerm;
var Sign: char;
begin
	Sign := Look;
	if Look = '!' then
        begin
                Rd(Look, tok); tok := trim(tok);
        end;
	CompTerm;
	if Sign = '!' then NotIt;
end;

{--------------------------------------------------------------}
{ Recognize and Translate a Boolean OR }

procedure BoolOr;
begin
   Rd(Look, tok); tok:=trim(tok);
   NotCompTerm;
   PopOr;
end;


{--------------------------------------------------------------}
{ Recognize and Translate a Boolean AND }

procedure BoolAnd;
begin
   Rd(Look, tok); tok:=trim(tok);
   NotCompTerm;
   PopAnd;
end;


{---------------------------------------------------------------}
{ Parse and Translate a Boolean Expression }

procedure BoolExpression;
var i: integer;
begin
        i := 1;
        while i < length(Tok) do
        begin
                if copy(Tok,i,2) = '||' then
                        begin delete(tok,i,1); tok[i]:=BO; end
                else if copy(Tok,i,2) = '&&' then
                        begin delete(tok,i,1); tok[i]:=BA; end
                else if copy(Tok,i,3) = '= =' then
                        begin delete(tok,i,2); tok[i]:=EQ; dec(i); end
                else if copy(Tok,i,3) = '> =' then
                        begin delete(tok,i,2); tok[i]:=GE; dec(i); end
                else if copy(Tok,i,3) = '< =' then
                        begin delete(tok,i,2); tok[i]:=SE; dec(i); end
                else if copy(Tok,i,3) = '! =' then
                        begin delete(tok,i,2); tok[i]:=NE; dec(i); end
                else
                        inc(i);
        end;
	Rd(Look, Tok); tok := trim(tok);
	NotCompTerm;
	while Look in [BO, BA] do
	begin
		Push;
		case Look of
		 BO: BoolOr;
		 BA: BoolAnd;
		end;
	end;
end;


procedure Block; Forward;


{-------------------------------------------------------------}
{ Switch Statement }

procedure DoSwitch;
var L1, temp: string;
    iselse: boolean;
begin
        delete(tok, 1, 7); tok := trim(tok);
        writln(#9'; Switch');
        Rd(Look, tok); tok:=trim(tok);
        Expression;
        writln(#9'CASE');
        iselse := false;
        repeat
                getToken(MODESTR, dummy);
                temp := extrcust(tok, ':'); tok:=trim(tok);
                if tok <> '' then
                begin
                        dummy := tok + ';}' + dummy;
                        inc(level);
                end;
                tok := temp;

                if pos('else', tok) > 0 then
                        iselse := true;
                L1 := NewLabel;
                writln(#9 + tok + #9 + L1);
                outfile := false;
                writln('  ' + L1 + ':');
                block;
                writln(#9 + 'RTN');
                writln('');
                outfile := true;
        until trim(dummy)[1] = '}';
        if not iselse then
                writln( #9'ELSE:'#9+'EOP');
        writln(#9'ENDCASE');
        writln(#9'; End switch');
end;


{-------------------------------------------------------------}
{ If Statement }

procedure DoIf;
var L1, L2: string;
begin
        writln( #9'; If block: Boolean expression');
        writln('');
        delete(Tok, 1, 4);
        BoolExpression;
        if tok <> '' then
        begin
                dummy := tok + ';}' + dummy;
                inc(level);
        end;
        L1 := NewLabel; L2 := L1;
        BranchFalse(L1);
        writln('');
        writln( #9'; If expression = true');
        Block;

        if copy(dummy, 1, 4) = 'else' then
        begin
                getToken(MODESTR, dummy); delete(tok, 1, 4); tok:=trim(tok);
                if tok <> '' then
                begin
                        dummy := tok + ';}' + dummy;
                        inc(level);
                end;
                L2 := NewLabel;
                Branch(L2);
                PostLabel(L1);
                writln( #9'; If expression = false');

                Block;
        end;
        writln( #9'; End of if');
        PostLabel(L2);
end;
{-------------------------------------------------------------}


{-------------------------------------------------------------}
{ Goto Statement }

procedure DoGoto;
begin
        delete(tok, 1, 5); tok := trim(tok);
        writln( #9'RJMP'#9+tok+#9'; Goto');
        writln('');
end;
{-------------------------------------------------------------}


{-------------------------------------------------------------}
{ Label Statement }

procedure DoLabel;
begin
        delete(tok, 1, 6); tok := trim(tok);
        if findvar(tok) or findproc(tok) then
                error(tok+': This label name is already used!');
        writln('');
        writln( '  '+tok+':'#9'; User label');
end;
{-------------------------------------------------------------}


{-------------------------------------------------------------}
{ Break Statement }

procedure DoBreak;
begin
        if InnerLoop = 'loop' then
                writln( #9'LEAVE'#9#9'; Break')
        else
                writln( #9'RJMP'#9+ExitLabel+#9'; Break');
        writln('');
end;
{-------------------------------------------------------------}


{-------------------------------------------------------------}
{ Exit Statement }

procedure DoReturn;
begin
        delete(tok, 1, 6); tok := trim(tok);
        if tok <> '' then
        begin
                Rd(Look, tok); tok := trim(tok);
                //isword := proclist[currproc].returnisword;
                if ( proclist[currproc].returntype = 'byte' )
                or ( proclist[currproc].returntype = 'char' ) then optype := byte
                else if proclist[currproc].returntype = 'word' then optype := word
                else if proclist[currproc].returntype = 'float' then optype := floatp;
                Expression;
        end;
        writln( #9'RTN'#9#9'; Return');
        writln('');
end;
{-------------------------------------------------------------}


{-------------------------------------------------------------}
{ Loop Statement }

procedure DoLoop;
var L1, L2: string;
begin
        InnerLoop := 'loop';
        L1 := NewLabel;
        L2 := NewLabel;
        ExitLabel := L2;
        writln( #9'; Loop');
        writln('');
        delete(tok, 1, 6); tok := trim(tok); //delete(tok, length(tok), 1);
	      Rd(Look, Tok); tok := trim(tok);
        Expression;
        isword := false;
        Push; dec(pushcnt);
        PostLabel(L1);
        if tok <> '' then
        begin
                dummy := tok + ';}' + dummy;
                inc(level);
        end;
        Block;
        writln( #9'LOOP'#9+L1);
        PostLabel(L2);
        writln( #9'; End of loop');
end;
{-------------------------------------------------------------}


{-------------------------------------------------------------}
{ While Statement }

procedure DoWhile;
var L1, L2: string;
begin
        InnerLoop := 'while';
        L1 := NewLabel;
        L2 := NewLabel;
        ExitLabel := L2;
        writln( #9'; While');
        writln('');
        PostLabel(L1);
        delete(Tok, 1, 7); //delete(Tok, length(Tok), 1);
        BoolExpression;
        BranchFalse(L2);
        writln( #9'; While expression = true');
        if tok <> '' then
        begin
                dummy := tok + ';}' + dummy;
                inc(level);
        end;
        Block;
        writln( #9'RJMP'#9+L1);
        PostLabel(L2);
        writln( #9'; End of while');
end;
{-------------------------------------------------------------}


{-------------------------------------------------------------}
{ For Statement }

procedure DoFor;
var L1, L2, temp: string;
begin
        InnerLoop := 'for';
        delete(tok, 1, 5);
        writln( #9'; For loop');
        Assignment;
        L1 := NewLabel;
        L2 := NewLabel;
        ExitLabel := L2;
        PostLabel(L1);
        getToken(MODESTR, dummy);
        BoolExpression;
        BranchFalse(L2);
        if trim(dummy)[1] <> ')' then
        begin
                getToken(MODESTR, dummy);
                if tok[length(tok)] = ')' then
                begin
                        delete(tok, length(tok), 1);
                        tok := trim(tok);
                        if tok <> '' then
                        begin
                                 dummy := tok +';'+ dummy;
                        end;
                end
                else begin
                        temp := extrcust(tok, ')');
                        dummy := temp + ';' + tok + ';}' + dummy;
                        inc(level);
                end;
        end else
        begin
                getToken(MODESTR, dummy);
                if tok <> ')' then
                begin
                        delete(tok, 1, 1); tok := trim(tok);
                        dummy := tok + ';}' + dummy;
                        inc(level);
                end;
        end;

        block;
        writln( #9'RJMP'#9+L1);
        PostLabel(L2);
        writln( #9'; End of for');
end;
{-------------------------------------------------------------}


procedure DoLoad;
begin
        delete(tok, 1, 5);
        rd(look, tok);
        expression;
end;


procedure DoSave;
var name: string;
begin
        delete(tok, 1, 5);
        name := getname;
        storevariable(name);
end;


{-------------------------------------------------------------}
{ Do..While Statement }

procedure DoDoWhile;
var L1, L2: string;
begin
        InnerLoop := 'do';
        L1 := NewLabel;
        L2 := NewLabel;
        ExitLabel := L2;
        writln( #9'; Do..while');
        writln('');
        PostLabel(L1);
//        GetToken(MODESTR, dummy);
        extrword(tok); tok := trim(tok);
        if tok <> '' then
        begin
                dummy := tok + ';}' + dummy;
                inc(level);
        end;
        Block;
        getToken(MODESTR, dummy);
        delete(Tok, 1, 7); delete(Tok, length(Tok), 1);
        BoolExpression;
        BranchFalse(L2);
        writln( #9'; While expression = true');
        writln( #9'RJMP'#9+L1);
        PostLabel(L2);
        writln( #9'; End of do..while');
end;
{-------------------------------------------------------------}


{-------------------------------------------------------------}
{ Procedure Call }

procedure ProcCall;
var i, c, a, aa: integer;
    name: string;
begin
        if tok = '' then exit;
        name := extrword(tok);
//      s := tok;          // Nur den Parameterblock der ersten Funktion extrahieren!!!
                           // Extract only the parameter block of the first function!!!
        a := 0;
        Rd(Look, Tok); tok := trim(tok);
        if findproc(name) then
        begin
                proclist[procfound].IsCalled := true;

                // calculating and pushing parameters on stack
                if proclist[procfound].parcnt > 0 then
                begin
                        //delete(s, 1, 1); s := trim(s);
                        writln( #9'; pushing parameters on stack...');
                        c := 0;
                        repeat
                                Rd(Look, Tok); tok := trim(tok);// + ',';
                                {if findvar(ProcList[ProcFound].parname[c]) then
                                begin
                                    varlist[varfound].address := a;
                                end else
                                    error('Parameter error!');}
                                if ( ProcList[ProcFound].partyp[c] = 'char' )
                                   or ( ProcList[ProcFound].partyp[c] = 'byte') then
                                begin
                                    isword := false; inc(a);
                                    optype := byte;
                                end else if ProcList[ProcFound].partyp[c] = 'word' then
                                begin
                                    isword := true; inc(a, 2);
                                    optype := word;
                                end else if ProcList[ProcFound].partyp[c] = 'float' then
                                begin
                                    isword := false; inc(a, 8);
                                    optype := floatp;
                                end;
                                Expression;
                                writln( #9'; '+ProcList[ProcFound].parname[c]+' ('+ProcList[ProcFound].partyp[c]+')'  );
                                Push;
                                inc(c);
                                if c > ProcList[ProcFound].ParCnt then
                                    error('Too many parameters for '+ProcList[ProcFound].ProcName);
                        until (Look <> ',');
                        if c <> ProcList[ProcFound].ParCnt then
                                error('Wrong number of parameters for '+ProcList[ProcFound].ProcName);
{
                        l := extrblock(s);
                        l := trim(l) + ',';
                        for c := 0 to i - 1 do
                        begin
                                tok := extrlist(l);
                                Rd(Look, Tok); tok := trim(tok) + ',';
                                Expression;
                                if ProcList[ProcFound].partyp[c] <> 'word' then
                                begin
                                    isword := false; inc(a);
                                end else
                                begin
                                    isword := true; inc(a, 2);
                                end;
                                Push;
                                if findvar(ProcList[ProcFound].parname[c]) then
                                begin
                                    varlist[varfound].address := a;
                                end else
                                    error('Parameter error!');
                        end;
}
                end;

                // allocating locals too on stack
                if proclist[procfound].loccnt > 0 then
                begin
                    writln( ' ' );
                    writln( #9'; reserving space on stack for local variables...');
                    aa := 0;
                    for c := 0 to proclist[procfound].loccnt - 1 do
                    begin
                            if ((ProcList[ProcFound].loctyp[c] = 'char') or
                                (ProcList[ProcFound].loctyp[c] = 'byte')) then
                            begin
                                isword := false;
                                optype := byte;
                                inc(a);
                                inc(aa);
                            end else if ProcList[ProcFound].loctyp[c] = 'word' then
                            begin
                                isword := true;
                                optype := word;
                                inc(a, 2);
                                inc(aa, 2);
                            end else if ProcList[ProcFound].loctyp[c] = 'float' then
                            begin
                                isword := false;
                                optype := floatp;
                                inc(a, 8);
                                inc(aa, 8);
                            end;
                            writln( #9'; '+ProcList[ProcFound].locname[c]+' ('+ProcList[ProcFound].loctyp[c]+')'  );
                            // Push         // see optimization below

                            {if findvar(ProcList[ProcFound].locname[c]) then
                            begin
                                varlist[varfound].address := a;
                            end else
                                error('Parameter error!'); }
                    end;
                    // optimization
                    if aa < 4 then
                       for c := 0 to proclist[procfound].loccnt - 1 do
                          Push
                    else
                        begin
                          writln( #9'LP'#9'0');
                          writln( #9'EXAM');
                          writln( #9'LDR');
                          writln( #9'SBIA'#9+inttostr(aa)); inc(pushcnt, aa);
                          writln( #9'STR');
                          writln( #9'EXAM');
                        end;
                end;

                // call the routine
                writln( ' ' );
                writln( #9'CALL'#9+name);

                if a > 0 then
                begin
                    writln( ' ' );
                    writln( #9'; restore stack pointer');
                    if ( proclist[procfound].returntype = 'float' ) then
                       Error ( 'Float return handling not implemented!');
                    if ( proclist[procfound].returnisword ) then
                    begin
                            writln( #9'LP'#9'0');
                            writln( #9'EXAM');
                            writln( #9'LDR');
                            writln( #9'ADIA'#9+inttostr(a)); dec(pushcnt, a);
                            writln( #9'STR');
                            writln( #9'EXAM');
                    end else
                    if proclist[procfound].hasreturn then
                    begin
                            writln( #9'EXAB');
                            writln( #9'LDR');
                            writln( #9'ADIA'#9+inttostr(a)); dec(pushcnt, a);
                            writln( #9'STR');
                            writln( #9'EXAB');
                    end else
                    begin  // no return value (we can overwrite A)
                        if a < 4 then  // optimize for size
                            for i := 1 to a do
                                begin writln( #9'POP'); dec(pushcnt); end
                        else
                        begin
                            writln( #9'LDR');
                            writln( #9'ADIA'#9+inttostr(a)); dec(pushcnt, a);
                            writln( #9'STR');
                        end;
                    end;
                end;
//              tok := s;
                rd(look, tok);
        end else
                Expected('procedure call');
end;


{-------------------------------------------------------------}
{ set offsets for local variables }

procedure repadr;
var i, lc, pc, m, a: integer;
    name: string;
begin
        lc := ProcList[currproc].loccnt;
        pc := ProcList[currproc].parcnt;
        if (lc = 0) and (pc = 0) then exit;
        if lc > 0 then
                name := ProcList[currproc].locname[lc - 1]
        else
                name := ProcList[currproc].parname[pc - 1];
        if not Findvar(name) then error('Var '+name+' not declared!');
        if not VarList[VarFound].local then error('Var '+name+' not local!');

        // sum up local space needed
        m := 0; // counting return address location
        if pc > 0 then for i := 0 to pc - 1 do
                if ProcList[currproc].partyp[i] = 'float' then inc(m, 8)
                else if ProcList[currproc].partyp[i] = 'word' then inc(m, 2)
                else if ((ProcList[currproc].partyp[i] = 'byte') or
                         (ProcList[currproc].partyp[i] = 'char')) then inc(m)
                else Error ('Invalid parameter type <' + ProcList[currproc].partyp[i] + '> in '
                      + ProcList[currproc].ProcName );
        if lc > 0 then for i := 0 to lc - 1 do
                if ProcList[currproc].loctyp[i] = 'float' then inc(m, 8)
                else if ProcList[currproc].loctyp[i] = 'word' then inc(m, 2)
                else if ((ProcList[currproc].loctyp[i] = 'byte') or
                         (ProcList[currproc].loctyp[i] = 'char')) then inc(m)
                else Error ('Invalid local var type <' + ProcList[currproc].partyp[i] + '> in '
                     + ProcList[currproc].ProcName );

        // calc each local relative address (offset), starting from the end
        a := 1;
        if pc > 0 then for i := 0 to pc - 1 do
        begin
                name := ProcList[currproc].parname[i];
                if not Findvar(name) then error('Var '+name+' not declared!');
                if not VarList[VarFound].local then error('Var '+name+' not local!');
                VarList[VarFound].address := m - a;
                writeln('LOCAL ',ProcList[currproc].procname,' VAR: ', name,
                               '(',ProcList[currproc].partyp[i],')',
                               ': ', VarList[VarFound].address );
                if ProcList[currproc].partyp[i] = 'float' then inc(a, 8)
                else if ProcList[currproc].partyp[i] = 'word' then inc(a, 2)
                else if ((ProcList[currproc].partyp[i] = 'byte') or
                         (ProcList[currproc].partyp[i] = 'char')) then inc(a);
        end;
        if lc > 0 then for i := 0 to lc - 1 do
        begin
                name := ProcList[currproc].locname[i];
                if not Findvar(name) then error('Var '+name+' not declared!');
                if not VarList[VarFound].local then error('Var '+name+' not local!');
                VarList[VarFound].address := m - a;
                writeln('LOCAL ',ProcList[currproc].procname,' PARAM: ', name,
                               '(',ProcList[currproc].loctyp[i],')',
                               ': ', VarList[VarFound].address );
                if ProcList[currproc].loctyp[i] = 'float' then inc(a, 8)
                else if ProcList[currproc].loctyp[i] = 'word' then inc(a, 2)
                else if ((ProcList[currproc].loctyp[i] = 'byte') or
                         (ProcList[currproc].loctyp[i] = 'char')) then inc(a);

        end;
end;

{--------------------------------------------------------------}
{ Parse and Translate a Block }

procedure Block;
var Name, name2: string;
begin
    repeat
        getToken(MODESTR, dummy);
        tok := trim(tok);
        // The following doesn't allow var names starting with a type name
        // e.g. 'byteX' is confused with 'byte' !
        // Try using GetName(), or ExtrWord() instead?
        name := copy(tok, 1, 5);
        if ((trim(name) = 'byte' )
             or (trim(name) = 'char')
             or (trim(name) = 'word')
             or (trim(name) = 'float')) then
                vardecl
        else if firstp then
                begin
                    firstp := false;
                    repadr; // recalculate local var and param offsets
                end;
        if tok <> '' then
        begin
          if copy(tok, 1, 3) = 'if ' then
                DoIf
          else if copy(tok, 1, 7) = 'load ' then
                DoLoad
          else if copy(tok, 1, 7) = 'save ' then
                DoSave
          else if copy(tok, 1, 7) = 'switch ' then
                DoSwitch
          else if copy(tok, 1, 5) = 'loop ' then
                DoLoop
          else if copy(tok, 1, 6) = 'while ' then
                DoWhile
          else if copy(tok, 1, 4) = 'for ' then
                DoFor
          else if copy(tok, 1, 5) = 'goto ' then
                DoGoto
          else if copy(tok, 1, 6) = 'label ' then
                DoLabel
          else if pos(':', tok) > 0 then
                DoLabel
          else if (copy(tok, 1, 2) = 'do') and not (upcase(tok[3]) in ['_','A'..'Z','0'..'9']) then
                DoDoWhile
          else if tok = 'break' then
                DoBreak
          else if copy(tok, 1, 6) = 'return' then
                DoReturn
          else if copy(tok, 1, 4) = '#asm' then
          begin
                tok := ExtrCust(dummy, #13);
                while copy(trim(tok), 1, 7) <> '#endasm' do
                begin
                        writln( #9+tok);
                        tok := ExtrCust(dummy, #13);
                end;
          end
          else if pos('=', tok) > 0 then
                Assignment
          else if pos('(', tok) > 0 then
                ProcCall
          else
                Assignment;
          writln('');
        end;
        dummy := trim(dummy);
    until (trim(dummy) = '') or (trim(dummy)[1] = '}');
    if dummy <> '' then
        Rd(Look, dummy);
    dummy := trim(dummy);
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Declare a var }

function vardecl: string;
var Name, Typ, t: string;
    xr, p, l: boolean;
begin
          Name := ExtrWord(Tok);
          Typ := Name;
          Tok := Tok + ',';
          xr := false;
          repeat
                  t := ExtrList(Tok);
                  Name := trim(ExtrWord(t));
                  p := false;
                  if pos('*', name) = 1 then
                  begin
                          p := true;
                          delete(name, 1, 1); name := trim(name);
                  end;
                  if Name = 'xram' then
                  begin
                          xr := true;
                          Name := ExtrWord(t);
                  end;
                  if t <> '' then
                          Name := Name + ' ' + t;
                  if Level = 0 then l := false else l := true;
                  if l then varlist[varcount].locproc := currproc;
                  result := Name;
                  AddVar(Name, Typ, xr, p, l);  // Global var definition
          until Tok = '';
end;
{--------------------------------------------------------------}


{--------------------------------------------------------------}
{ Do First Scan }

procedure FirstScan(filen: string);
var Name, name2, t, temp, s, rettyp: string;
    i: integer;
    hasret: boolean;
begin
        assignfile(f, filen);
        reset(f);
        GetToken(MODEFILE, dummy);
        while tok <> '' do
        begin
            // the following limits procedure and variable names
            // NOT to start with a type name, like e.g. 'byte byteX;'
                Name := copy(tok,1,5); //ExtrWord(Tok);
                if  (Level = 0)  and
                         ( (trim(Name) = 'byte')
                       or  (trim(Name) = 'char')
                       or  (trim(Name) = 'word')
                       or  (trim(Name) = 'float') )
                then
                begin
                        delete(tok,1,Length(trim(Name))); tok:=trim(tok);
                        Tok := Name + ' ' + Tok;
                        vardecl;
                end
                else if copy(tok,1,5) = '#org ' then //(Name = '#org') then
                        begin ExtrWord(Tok); org := trim(Tok); end
                else if copy(tok,1,4) = '#pc ' then //(Name = '#pc') then
                        begin ExtrWord(Tok); pc := trim(Tok); end
                else if copy(tok,1,7) = '#nosave' then
                        nosave := true
                else if pos('(', tok) > 0 then
                begin
                        name2 := ExtrWord(Tok);
                        isword := false;
                        hasret := false;
                        if name2 = 'float' then
                        begin
                                Error ( 'Float return value unsupported (yet)' );
                                rettyp := name2;
                                optype := floatp;
                                Name := ExtrWord(Tok);
                                hasret := true;
                        end else
                        if name2 = 'word' then
                        begin
                                rettyp := name2;
                                isword := true;
                                optype := word;
                                Name := ExtrWord(Tok);
                                hasret := true;
                        end else
                        if (name2 = 'char') or (name2 = 'byte') then
                        begin
                                rettyp := name2;
                                optype := byte;
                                Name := ExtrWord(Tok);
                                hasret := true;
                        end else
                                Name := name2;
                        tok := trim(tok); delete(tok, 1, 1); tok := trim(tok);
                        i := 0;
//                        p := 0;
                        temp := '';
                        if copy(tok, 1, 1) <> ')' then
                        begin
                            delete(tok, length(tok), 1);
                            temp := tok;
                            s := tok + ',';
                            currproc := proccount;
                            while s <> '' do
                            begin
                                    tok := ExtrList(s);
                                    //proclist[proccount].partyp[i] := copy(tok, 1, 4);
                                    proclist[proccount].partyp[i] := trim(copy(tok, 1, 5));
                                    procd := true;
                                    proclist[proccount].parname[i] := vardecl;
                                    procd := false;
                                    inc(i);
                            end;
                        end;
                        t := '';
                        repeat
                                Rd(Look, dummy);
                                t := t + Look;
                        until Level = 0;
                        delete(t, length(t), 1);
                        AddProc(Name, trim(t), temp, i, hasret, isword, rettyp);
                end;
	        GetToken(MODEFILE, dummy);
        end;

        printvarlist;
        printproclist;

        closefile(f);
        if not FindProc('main') then Error('main not found!');

end;
{--------------------------------------------------------------}



{--------------------------------------------------------------}
{ Do Second Scan }

procedure SecondScan(filen: string);
var name, typ, s, s2, s3: string;
    at, arr: boolean;
    i, adr, size, value: integer;
    fval: float;
    f2: textfile;
begin
        md := MODESTR;
        assign(f,'temp.asm');
        rewrite(f);

        { Write Intro }
        writln( '; pasm file - assemble with pasm!');
        writln( '; Compiled with lcc v1.1');
        writln('');
        writln( '.ORG'#9+org);
        writln('');

        { Registry save point }
        if not nosave then
        begin
          writln(#9'LP'#9'0');
          writln(#9'LIDP'#9'SREG');
          writln(#9'LII'#9'11');
          writln(#9'EXWD');
        end;

        { -mandatory- "main" entry point }
        writln('');
        writln(#9'CALL'#9'main');

        { Registry restore and return to BASIC }
        if not nosave then
        begin
          writln('');
          writln(#9'LP'#9'0');
          writln(#9'LIDP'#9'SREG');
          writln(#9'LII'#9'11');
          writln(#9'MVWD');
          writln(#9'RTN');
          writln('');
          writln('SREG:'#9'.DW 0, 0, 0, 0, 0, 0');
          writln('');
        end;

        { Variables' initializations }
        for i := 0 to VarCount - 1 do
        begin
                adr := VarList[i].address;
                size := VarList[i].size;
                name := VarList[i].VarName;
                value := VarList[i].initn;
                fval := VarList[i].initf;
                typ := VarList[i].typ;
                at := VarList[i].at;
                arr := VarList[i].arr;
                if VarList[i].xram then
                begin // xram variables
                        if at then
                        begin
                          if value <> -1 then
                              if not arr then
                                  varxram(value, adr, size, name)
                              else
                                  varxarr(VarList[i].inits, adr, size, name, typ);
                          end else
                          begin // with an init value
                                // for float, inits is allocated anyway
                              if not arr then
                                 if not (  typ = 'float' ) then varcode(value, adr, size, name)
                                 else varfcode(VarList[i].inits, name)
                              else
                                 if not (  typ = 'float' ) then varcarr(VarList[i].inits, adr, size, name, typ)
                                 else varfarr(VarList[i].inits, size, name);
                          end;
                end else
                begin // register variables
                        if value <> -1 then
                        begin
                            if not arr then
                                    varreg(value, adr, size, name)
                            else
                            begin
                                    varrarr(VarList[i].inits, adr, size, name, typ);
                            end;
                        end;
                end;
        end;

        { Process procedures }
        mainfound := false;
        {
        for i := 0 to proccount - 1 do
                if proclist[i].procname = 'main' then
                begin
                        mainfound := true;
                        writln('');
                        //writln(#9'CALL'#9'MAIN');
                        if not nosave then
                        begin
                          tok := 'main ()';
                          ProcCall;
                          writln(#9'LP'#9'0');
                          writln(#9'LIDP'#9'SREG');
                          writln(#9'LII'#9'11');
                          writln(#9'MVWD');
                          writln(#9'RTN');
                          writln('');
                          writln('SREG:'#9'.DW 0, 0, 0, 0, 0, 0');
                        end;
                        writln('');
                        writln( 'MAIN:');
                        dummy := proclist[i].proccode;
                        currproc := i;
                        Level := 1;
                        pushcnt := 0; firstp := true;
                        block;
                        if pushcnt <> 0 then
                                writeln(proclist[i].procname+': Possible Stack corruption!');
                        removelocvars('main');
                        writln( ' EOP:'#9'RTN');
                        writln('');
                        break;
                end;
        }

        for i := 0 to proccount - 1 do
            begin
               // if proclist[i].procname <> 'main' then
                   if true // proclist[i].iscalled
                   then
                   begin
                        writln('');
                        writln( proclist[i].procname+':'#9'; Procedure');
                        dummy := proclist[i].proccode;
                        Level := 1;
                        currproc := i;
                        pushcnt := 0; firstp := true;
                        block;
                        if pushcnt <> 0 then
                           writeln(proclist[i].procname+': Possible Stack corruption!');
                        removelocvars(proclist[i].procname);
                        //writln( #9'RTN');
                        writln('');
                   end else
                        writln('; Skipping procedure '+ proclist[i].procname +' (never used)');

                   if proclist[i].procname = 'main' then
                      mainfound := true;
            end;

        if not(mainfound) then
           Error ( '<main> procedure missing!' );

        if (asmcnt > 0) then
                for i := 0 to asmcnt - 1 do
                        writln( asmlist[i]);
        close(f);



        { ****************************************************************}
        { Third pass? Optimize Code }

        s2 := #9'INCA';
        s3 := #9'DECA';
        for i := 1 to 6 do
        begin
	     s := #9'LIA'#9+inttostr(i)+#9'; Load constant '+inttostr(i)+#13#10#9'EXAB'#13#10#9'LP'#9'3'#13#10#9'SBM'#9#9'; Subtraction'#13#10#9'EXAB';
             while pos(s, asmtext) > 0 do begin delete(asmtext, pos(s, asmtext), length(s)); insert(s2, asmtext, pos(s, asmtext)); s2 := s2 + #13#10#9'DECA'; end;
	     s := #9'LIA'#9+inttostr(i)+#9'; Load constant '+inttostr(i)+#13#10#9'LP'#9'3'#13#10#9'ADM'#9#9'; Addition'#13#10#9'EXAB';
	     while pos(s, asmtext) > 0 do begin delete(asmtext, pos(s, asmtext), length(s)); insert(s3, asmtext, pos(s, asmtext)); s3 := s3 + #13#10#9'INCA'; end;
        end;
        s := #9'EXAB'#13#10#9'EXAB'#13#10;
        while pos(s, asmtext) > 0 do delete(asmtext, pos(s, asmtext), length(s));

        assignfile(f, 'temp.asm');
        rewrite(f);
        writeln(f, asmtext);
        writeln(f, libtext);
        closefile(f);

        // Replace LIA... EXAB to LIB
        assignfile(f, 'temp.asm');
        reset(f);
        assignfile(f2, 'temp2.asm');
        rewrite(f2);

        while not eof(f) do
        begin
                readln(f, s);
                if copy(trim(s),1,3) = 'LIA' then
                begin
                        name := s;
                        readln(f, s);
                        if copy(trim(s),1,4) = 'EXAB' then
                        begin
                                s := #9'LIB' + copy(name,5,255);
                                writeln(f2, s);
                        end else
                        begin
                                writeln(f2, name);
                                writeln(f2, s);
                        end;
                end else
                        writeln(f2, s);
        end;
        closefile(f2);
        closefile(f);

        // Replace PUSH LIB... POP to LIB...
        assignfile(f, 'temp2.asm');
        reset(f);
        assignfile(f2, 'temp.asm');
        rewrite(f2);

        while not eof(f) do
        begin
                readln(f, s);
                if copy(trim(s),1,4) = 'PUSH' then
                begin
                        name := s;
                        readln(f, s);
                        if copy(trim(s),1,3) = 'LIB' then
                        begin
                                typ := s;
                                readln(f, s);
                                if copy(trim(s),1,3) = 'POP' then
                                begin
                                        writeln(f2, typ);
                                end else
                                begin
                                        writeln(f2, name);
                                        writeln(f2, typ);
                                        writeln(f2, s);
                                end;
                        end else
                        begin
                                writeln(f2, name);
                                writeln(f2, s);
                        end;
                end else
                begin
                        writeln(f2, s);
                end;
        end;
        closefile(f2);
        closefile(f);

        // Remove double EXAB
        assignfile(f, 'temp.asm');
        reset(f);
        assignfile(f2, 'temp2.asm');
        rewrite(f2);

        while not eof(f) do
        begin
                readln(f, s);
                if copy(trim(s),1,3) = 'EXAB' then
                begin
                        name := s;
                        readln(f, s);
                        if copy(trim(s),1,4) <> 'EXAB' then
                        begin
                                writeln(f2, name);
                                writeln(f2, s);
                        end;
                end else
                        writeln(f2, s);
        end;
        closefile(f2);
        closefile(f);

        // Replace n++ code to INCA
        assignfile(f, 'temp2.asm');
        reset(f);
        assignfile(f2, 'temp.asm');
        rewrite(f2);

        while not eof(f) do
        begin
                readln(f, s);
                if (copy(trim(s),1,6) = 'LIB'#9'1'#9) or (s = 'LIB'#9'1') then
                begin
                        name := s;
                        readln(f, s);
                        if copy(trim(s),1,4) = 'LP'#9'3' then
                        begin
                                typ := s;
                                readln(f, s);
                                if copy(trim(s),1,3) = 'ADM' then
                                begin
                                        s2 := s;
                                        readln(f, s);
                                        if copy(trim(s),1,4) = 'EXAB' then
                                        begin
                                                writeln(f2, #9'INCA');
                                        end else
                                        begin
                                                writeln(f2, name);
                                                writeln(f2, typ);
                                                writeln(f2, s2);
                                                writeln(f2, s);
                                        end;
                                end else
                                begin
                                        writeln(f2, name);
                                        writeln(f2, typ);
                                        writeln(f2, s);
                                end;
                        end else
                        begin
                                writeln(f2, name);
                                writeln(f2, s);
                        end;
                end else
                begin
                        writeln(f2, s);
                end;
        end;
        closefile(f2);
        closefile(f);

        // Replace n-- code to DECA
        assignfile(f, 'temp.asm');
        reset(f);
        assignfile(f2, filen);
        rewrite(f2);
        i := 0;

        while not eof(f) do
        begin
                readln(f, s);
                if (copy(trim(s),1,6) = 'LIB'#9'1'#9) or (s = 'LIB'#9'1') then
                begin
                        name := s;
                        readln(f, s);
                        if copy(trim(s),1,4) = 'LP'#9'3' then
                        begin
                                typ := s;
                                readln(f, s);
                                if copy(trim(s),1,4) = 'EXAB' then
                                begin
                                        s2 := s;
                                        readln(f, s);
                                        if copy(trim(s),1,3) = 'SBM' then
                                        begin
                                                s3 := s;
                                                readln(f, s);
                                                if copy(trim(s),1,4) = 'EXAB' then
                                                begin
                                                        writeln(f2, #9'DECA'); inc(i);
                                                end else
                                                begin
                                                        writeln(f2, name); if name<> '' then inc(i);
                                                        writeln(f2, typ); if typ<> '' then inc(i);
                                                        writeln(f2, s2); if s2<> '' then inc(i);
                                                        writeln(f2, s3); if s3<> '' then inc(i);
                                                        writeln(f2, s); if s<> '' then inc(i);
                                                end;
                                        end else
                                        begin
                                                writeln(f2, name); if name<> '' then inc(i);
                                                writeln(f2, typ); if typ<> '' then inc(i);
                                                writeln(f2, s2); if s2<> '' then inc(i);
                                                writeln(f2, s); if s<> '' then inc(i);
                                        end;
                                end else
                                begin
                                        writeln(f2, name); if name<> '' then inc(i);
                                        writeln(f2, typ); if typ<> '' then inc(i);
                                        writeln(f2, s); if s<> '' then inc(i);
                                end;
                        end else
                        begin
                                writeln(f2, name); if name<> '' then inc(i);
                                writeln(f2, s); if s<> '' then inc(i);
                        end;
                end else
                begin
                        writeln(f2, s);  if s<> '' then inc(i);
                end;
        end;
        closefile(f2);
        closefile(f);

        deletefile('temp.asm');
        deletefile('temp2.asm');

        writeln('Complete: ',i,' assembler lines were produced!');
end;
{--------------------------------------------------------------}



begin
//        for LCount := 0 to 95 do MemImg[LCount] := -1;
        LCount := 0;
        VarCount := 0;
        ProcCount := 0;
        VarPos := 8;   // initial variable allocation point
end.



