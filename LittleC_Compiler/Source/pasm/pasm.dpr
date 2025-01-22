program pasm;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$APPTYPE CONSOLE}
{%File 'ModelSupport\default.txvpck'}

uses
  sysutils,
  calcunit;

var
	tok, op, param1, param2, params: string;
	code: Array [0..100000] of byte;
	codpos: integer = 0;
	sym: Array [0..1000] of string;
	symval: Array [0..1000] of string;
	symcnt: integer = 0;
	lab: Array [0..1000] of string;
	labpos: Array [0..1000] of integer;
	labcnt: integer = 0;
        labp: integer = 0;
        nlab: Array [0..1000] of string;
	nlabpos: Array [0..1000] of integer;
	nlabasm: Array [0..1000] of string;
	nlabcnt: integer = 0;
        nlabp: integer = 0;
	startadr: integer = 0;
	blcnt: integer;
	opp: integer = 0;
        mcase: boolean = false;
        ccase: integer = 0;
        casecnt: integer;
        cline, i: integer;

//	f: textfile;
//	f2: file of byte;
//        wr: integer;
        s, cf: string;

const
        NOP = 77;
        JRNZP = 40;
        JRNZM = 41;
        JRNCP = 42;
        JRNCM = 43;
        JRP = 44;
        JRM = 45;
        LOOP = 47;
        JRZP = 56;
        JRZM = 57;
        JRCP = 58;
        JRCM = 59;
        JRPLUS = [JRNZP,JRNCP,JRP,JRZP,JRCP];
        JRMINUS = [JRNZM,JRNCM,JRM,LOOP,JRZM,JRCM];
        JR = [JRNZP,JRNCP,JRP,JRZP,JRCP,JRNZM,JRNCM,JRM,LOOP,JRZM,JRCM];

        OPCODE : array[0..255] of string[5] =
             ('LII','LIJ','LIA','LIB','IX',
              'DX','IY','DY','MVW','EXW',
              'MVB','EXB','ADN','SBN','ADW',
              'SBW','LIDP','LIDL','LIP','LIQ',
              'ADB','SBB','?022?','?023?','MVWD',
              'EXWD','MVBD','EXBD','SRW','SLW',
              'FILM','FILD','LDP','LDQ','LDR',
              'RA','IXL','DXL','IYS','DYS',
              'JRNZP','JRNZM','JRNCP','JRNCM','JRP',
              'JRM','?046?','LOOP','STP','STQ',
              'STR','?051?','PUSH','DATA','?054?',
              'RTN','JRZP','JRZM','JRCP','JRCM',
              '?060?','?061?','?062?','?063?','INCI',
              'DECI','INCA','DECA','ADM','SBM',
              'ANMA','ORMA','INCK','DECK','INCM',
              'DECM','INA','NOPW','WAIT','WAITI',
              'INCP','DECP','STD','MVDM','READM',
              'MVMD','READ','LDD','SWP','LDM',
              'SL','POP','?092?','OUTA','?094?',
              'OUTF','ANIM','ORIM','TSIM','CPIM',
              'ANIA','ORIA','TSIA','CPIA','?104?',
              'DTJ','?106?','TEST','?108?','?109?',
              '?110?','?111?','ADIM','SBIM','?114?',
              '?115?','ADIA','SBIA','?118?','?119?',
              'CALL','JP','PTJ','?123?','JPNZ',
              'JPNC','JPZ','JPC','LP00','LP01',
              'LP02','LP03','LP04','LP05','LP06',
              'LP07','LP08','LP09','LP10','LP11',
              'LP12','LP13','LP14','LP15','LP16',
              'LP17','LP18','LP19','LP20','LP21',
              'LP22','LP23','LP24','LP25','LP26',
              'LP27','LP28','LP29','LP30','LP31',
              'LP32','LP33','LP34','LP35','LP36',
              'LP37','LP38','LP39','LP40','LP41',
              'LP42','LP43','LP44','LP45','LP46',
              'LP47','LP48','LP49','LP50','LP51',
              'LP52','LP53','LP54','LP55','LP56',
              'LP57','LP58','LP59','LP60','LP61',
              'LP62','LP63','INCJ','DECJ','INCB',
              'DECB','ADCM','SBCM','TSMA','CPMA',
              'INCL','DECL','INCN','DECN','INB',
              '?205?','NOPT','?207?','SC','RC',
              'SR','?211?','ANID','ORID','TSID',
              '?215?','LEAVE','?217?','EXAB','EXAM',
              '?220?','OUTB','?222?','OUTC','CAL00',
              'CAL01','CAL02','CAL03','CAL04','CAL05',
              'CAL06','CAL07','CAL08','CAL09','CAL10',
              'CAL11','CAL12','CAL13','CAL14','CAL15',
              'CAL16','CAL17','CAL18','CAL19','CAL20',
              'CAL21','CAL22','CAL23','CAL24','CAL25',
              'CAL26','CAL27','CAL28','CAL29','CAL30',
              'CAL31');

        NBARGU : array[0..255] of byte =
             (2,2,2,2,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,3,2,2,2,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              2,2,2,2,2,
              2,1,2,1,1,
              1,1,1,1,1,
              1,2,2,2,2,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,2,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,2,2,2,2,
              2,2,2,2,1,
              1,1,2,1,1,
              1,1,2,2,1,
              1,2,2,1,1,
              3,3,1,1,3,
              3,3,3,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,1,1,1,
              1,1,2,2,2,
              1,1,1,1,1,
              1,1,1,1,2,
              2,2,2,2,2,
              2,2,2,2,2,
              2,2,2,2,2,
              2,2,2,2,2,
              2,2,2,2,2,
              2,2,2,2,2,
              2);


{function trim(s: string): string;
begin
        while (length(s) > 0) and ((s[1] = ' ') or (s[1] = #9)) do
                delete(s, 1, 1);
        while (length(s) > 0) and (s[length(s)] in [' ', #9]) do
                delete(s, length(s), 1);
        result := s;
end;
}


function replace_text(text, such, ers: string): string;
var i: integer;
begin
	result := text;
        if (such = '') or (text = '') then
                 exit;
  such := lowercase(such);
//  text := lowercase(text);
	text := ' ' + text + ' ';
        i := 2;
	while (i < length(text)) do
	begin
            if (copy(lowercase(text), i, length(such)) = such)
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


procedure abort(t: string);
var s: string;
begin
	str(cline + 1, s);
	writeln('Line ' + s + ': ' + t + ' in file ' + cf);
	halt (1);
end;


function findnlabel(l: string): boolean;
var i: integer;
begin
	result := false;
        l := uppercase(l);
        nlabp := -1;
	for i := 0 to nlabcnt - 1 do
	    if nlab[i] = l then
	    begin
		result := true;
                nlabp := i;
		break;
            end;
end;


procedure addnlabel(l: string);
begin
//	if findnlabel(l) then
//          abort('Label ' + l + ' already defined!');
        //writeln ( ' *DEBUG* addnlabel ' + l + ' @ ' + IntToStr(codpos) + ', ' + op + ' ' + params) ;
        l := uppercase(l);
	nlab[nlabcnt] := l;
	nlabpos[nlabcnt] := codpos;
        nlabasm[nlabcnt] := op + ' ' + params;
        if mcase then nlabasm[nlabcnt] := '#' + op + ' ' + params;
	inc(nlabcnt);
end;


procedure delnlabel(l: integer);
var i: integer;
begin
        for i := l to nlabcnt - 1 do
        begin
                nlab[i] := nlab[i + 1];
                nlabpos[i] := nlabpos[i + 1];
                nlabasm[i] := nlabasm[i + 1];
        end;
        dec(nlabcnt);
end;


function findlabel(l: string): boolean;
var i: integer;
begin
	result := false;
        l := uppercase(l);
        labp := -1;
	for i := 0 to labcnt - 1 do
	    if lab[i] = l then
	    begin
		result := true;
                labp := i;
		break;
            end;
end;


{forward}
procedure doasm; forward;
procedure extractop(s: string); forward;



procedure addlabel(l: string);
var tpos: integer;
    bup: boolean;
begin
        //writeln(' *DEBUG* addlabel: '+l);
        l := uppercase(l);
	if findlabel(l) then abort('Label ' + l + ' already defined!');
        writeln('SYMBOL: ' + l + ' - ' + inttostr(codpos + startadr));
	lab[labcnt] := l;
	labpos[labcnt] := codpos;
	inc(labcnt);
	while findnlabel(l) do
        begin
                tpos := codpos;
                bup := mcase;
                codpos := nlabpos[nlabp];
                tok := nlabasm[nlabp];
                if tok[1] = '#' then begin mcase := true; delete(tok, 1, 1); end;
                extractop(tok);
                doasm;
                codpos := tpos;
                delnlabel(nlabp);
                mcase := bup;
        end;
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
	if findsymbol(s1) then abort('Symbol ' + s1 + ' already defined!');
	sym[symcnt] := s1;
	symval[symcnt] := s2;
        writeln('SYMBOL: ' + s1 + ' - ' + s2);
        inc(symcnt);
end;


function findop(l: string): boolean;
var i: integer;
begin
	result := false;
        opp := -1;
	for i := 0 to 255 do
	if OPCODE[i] = l then
	begin
		result := true;
                opp := i;
		break;
	end;
end;


procedure addcode(b: byte);
begin
	code[codpos] := b;
        inc(codpos);
        if codpos + startadr >= 65536 then
                 abort('Code exceeds maximum memory!');
end;


function mathparse(s: string; w: integer): integer;
var i, p: integer;
    c, s2, s3: string;
    lf: boolean;
begin
        if labcnt > 0 then for i := 0 to labcnt - 1 do
                s := replace_text(s, lab[i], inttostr(labpos[i] + startadr));
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
                if (s[i] = '0') and ((i < length(s)-2) and (upcase(s[i+1]) = 'X')) then
                begin
                    inc(i, 2);
                    while upcase(s[i]) in ['0'..'9', 'A'..'F'] do inc(i);
                end;
                if (s[i] = '0') and ((i < length(s)-2) and (upcase(s[i+1]) = 'B')) then
                begin
                    inc(i, 2);
                    while upcase(s[i]) in ['0'..'1'] do inc(i);
                end;
                if upcase(s[i]) in ['_','A'..'Z'] then
                begin
                    if (i > 1) and (s[i - 1] = '0') then inc(i)
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
                            if not findlabel(s2) then
                            begin
                                dec(codpos);
                                addnlabel(s2);
                                inc(codpos);
                                lf := true;
                            end else
                            begin
                                s3 := inttostr(startadr + labpos[labp]);
                                s := replace_text(s, s2, s3);
                                i := i - length(s2) + length(s3);
                            end;
                        end;
                    end;
                end;
                inc(i);
        end;
        if lf then begin result := 0; exit; end;

	Evaluate(s, w, i, p);
	result := i;
        if p <> 0 then
        begin
                writeln('Erroneous formula: ' + s);
                abort('Formula error!');
        end;
end;


procedure extractop(s: string);
var
	i: integer;
begin
        if s = '' then exit;
        s := s + ' ';

	i := 1;
	while s[i] in [' ', #9] do inc(i);
	delete(s, 1, i - 1);

	i := 1;
	while not (s[i] in [' ', #9]) do inc(i);
	op := uppercase(trim(copy(s, 1, i - 1)));
	delete(s, 1, i); s := trim(s);
        params := s;

        if pos(',', s) > 0 then s[pos(',', s)] := ' ';

        i := 1; s := s + '  ';
	while (i < length(s)) and (not (s[i] in [' ', #9])) do inc(i);
	param1 := trim(copy(s, 1, i - 1));
        delete(s, 1, i); s := trim(s);

        if s <> '' then param2 := s else param2 := '';
end;


function calcadr: integer;
var i: integer;
    s, s2: string;
    lf: boolean;
begin
        i := 1;
        lf := false;
        //writeln ( ' DEBUG calcadr ', params  );
        while i <= length(params) do
        begin
                if (params[i] = '0') and ((i < length(params)-2) and (upcase(params[i+1]) = 'X')) then
                begin
                    inc(i, 2);
                    while upcase(params[i]) in ['0'..'9', 'A'..'F'] do inc(i);
                end;
                if (params[i] = '0') and ((i < length(params)-2) and (upcase(params[i+1]) = 'B')) then
                begin
                    inc(i, 2);
                    while upcase(params[i]) in ['0'..'1'] do inc(i);
                end;
                if upcase(params[i]) in ['_','A'..'Z'] then
                begin
                        s := '';
                        while (i <= length(params)) and (upcase(params[i]) in ['0'..'9','_','A'..'Z']) do
                        begin
                                s := s + params[i];
                                inc(i);
                        end;
                        if not findlabel(s) then
                        begin
                                addnlabel(s);
                                lf := true;
                        end else
                        begin

                                s2 := inttostr(startadr + labpos[labp]);
                                params := replace_text(params, s, s2);
                                param1 := params;
                                param2 := '';
                                i := i - length(s) + length(s2);
                        end;
                end;
                inc(i);
        end;


        if lf then result := 0
        else if param2 = '' then result := mathparse(param1, 16)
        else result := mathparse(param1, 8) * 256 + mathparse(param2, 8);
        //writeln ( ' DEBUG calcadr ', result );
end;


procedure doasm;
var adr: integer;
begin
        param1 := trim(param1);
        if param1 <> '' then
           if param1[length(param1)] = ',' then
              delete(param1, length(param1), 1);
        param2 := trim(param2);

        if findop(op) then
        begin
           if opp in [120, 121, 16, 124..127] then      // abolut
           begin
              adr := calcadr;
              if adr > 0 then
              begin
                   addcode(opp); addcode(adr div 256); addcode(adr mod 256);
              end else
              begin
                   addcode(NOP); addcode(NOP); addcode(NOP);
              end;
           end else
           if opp in JR then              // relativ
           begin
              adr := calcadr;
              if adr >= 8192 then
              begin
                   addcode(opp);
//                   if opp in JRPLUS then addcode(adr - codpos - startadr)
//                   else
                   addcode(abs(codpos + startadr - adr));
              end else
              if adr > 0 then
              begin
                   addcode(opp); addcode(adr);
              end else
              begin
                   addcode(NOP); addcode(NOP);
              end;
           end else
           begin
              addcode(opp);
              if NBARGU[opp] = 2 then
                 addcode(mathparse(param1, 8))
              else if NBARGU[opp] = 3 then
              begin
                 if param2 = '' then
                 begin
                    addcode((mathparse(param1, 16) shr 8) and $FF);
                    addcode((mathparse(param1, 16)) and $FF);
                 end else
                 begin
                    addcode(mathparse(param1, 8));
                    addcode(mathparse(param2, 8));
                 end;
              end;
           end;
        end else
        begin

        if op = 'LP' then
        begin
           if mathparse(param1, 8) > 63 then
              abort('LP command exceeds range!');
           addcode(128 + mathparse(param1, 8));
        end else
        if op = 'RTN' then
           addcode(55)
        else if op = 'SUBW' then
           addcode($15)
        else if op = 'SUBC' then
           addcode($C5)
        else if op = 'ADDW' then
           addcode($14)
        else if op = 'ADDC' then
           addcode($C4)
        else if (op = 'ADD') then
        begin
           if (param1 = '[P]') and (param2 = 'A') then addcode($44)
           else if (param1 = '[P]') then begin addcode($70); addcode(mathparse(param2, 8)); end
           else if (param1 = 'A') then begin addcode($74); addcode(mathparse(param2, 8)); end;
        end
        else if (op = 'ADDB') then
        begin
           if (param1 = '[P]') and (param2 = 'A') then addcode($0C)
           else if (param1 = '[P]') and (param2 = '[Q]') then addcode($0E);
        end
        else if (op = 'SUB') then
        begin
           if (param1 = '[P]') and (param2 = 'A') then addcode($45)
           else if (param1 = '[P]') then begin addcode($71); addcode(mathparse(param2, 8)); end
           else if (param1 = 'A') then begin addcode($74); addcode(mathparse(param2, 8)); end;
        end
        else if (op = 'SUBB') then
        begin
           if (param1 = '[P]') and (param2 = 'A') then addcode($0D)
           else if (param1 = '[P]') and (param2 = '[Q]') then addcode($0F);
        end
        else if op = 'ROL' then
           addcode($5A)
        else if op = 'SLB' then
           addcode($1D)
        else if op = 'ROR' then
           addcode(210)
        else if op = 'SRB' then
           addcode(28)
        else if op = 'SWAP' then
           addcode(88)
        else if op = 'RC' then
           addcode(209)
        else if op = 'SC' then
           addcode(208)
        else if (op = 'OR') then
        begin
           if (param1 = '[P]') and (param2 = 'A') then addcode($47)
           else if (param1 = '[P]') then begin addcode($61); addcode(mathparse(param2, 8)); end
           else if (param1 = '[DP]') then begin addcode($D5); addcode(mathparse(param2, 8)); end
           else if (param1 = 'A') then begin addcode($65); addcode(mathparse(param2, 8)); end;
        end
        else if (op = 'AND') then
        begin
           if (param1 = '[P]') and (param2 = 'A') then addcode($46)
           else if (param1 = '[P]') then begin addcode($60); addcode(mathparse(param2, 8)); end
           else if (param1 = '[DP]') then begin addcode($D4); addcode(mathparse(param2, 8)); end
           else if (param1 = 'A') then begin addcode($64); addcode(mathparse(param2, 8)); end;
        end
        else if (op = 'OUT') then
        begin
           if (param1 = 'A') then addcode(93)
           else if (param1 = 'B') then addcode(221)
           else if (param1 = 'C') then addcode(223)
           else if (param1 = 'F') then addcode(95);
        end
        else if (op = 'IN') then
        begin
           if (param1 = 'A') then addcode(76)
           else if (param1 = 'B') then addcode(204);
        end
        else if (op = 'INC') then
        begin
           if (param1 = 'A') or (mathparse(param1, 8) = 2) then addcode(66)
           else if (param1 = 'B') or (mathparse(param1, 8) = 3) then addcode(194)
           else if (param1 = 'J') or (mathparse(param1, 8) = 1) then addcode(192)
           else if (param1 = 'K') or (mathparse(param1, 8) = 8) then addcode(72)
           else if (param1 = 'L') or (mathparse(param1, 8) = 9) then addcode(200)
           else if (param1 = 'M') or (mathparse(param1, 8) = 10) then addcode(74)
           else if (param1 = 'N') or (mathparse(param1, 8) = 11) then addcode(202)
           else if (param1 = 'P') then addcode(80)
           else if (param1 = 'X') or (mathparse(param1, 8) = 4) then addcode(4)
           else if (param1 = 'Y') or (mathparse(param1, 8) = 6) then addcode(6)
           else if (param1 = 'I') or (mathparse(param1, 8) = 0) then addcode(64);
        end
        else if (op = 'DEC') then
        begin
           if (param1 = 'A') or (mathparse(param1, 8) = 2) then addcode(67)
           else if (param1 = 'B') or (mathparse(param1, 8) = 3) then addcode(195)
           else if (param1 = 'J') or (mathparse(param1, 8) = 1) then addcode(193)
           else if (param1 = 'K') or (mathparse(param1, 8) = 8) then addcode(73)
           else if (param1 = 'L') or (mathparse(param1, 8) = 9) then addcode(201)
           else if (param1 = 'M') or (mathparse(param1, 8) = 10) then addcode(75)
           else if (param1 = 'N') or (mathparse(param1, 8) = 11) then addcode(203)
           else if (param1 = 'P') then addcode(81)
           else if (param1 = 'X') or (mathparse(param1, 8) = 4) then addcode(5)
           else if (param1 = 'Y') or (mathparse(param1, 8) = 6) then addcode(7)
           else if (param1 = 'I') or (mathparse(param1, 8) = 0) then addcode(65);
        end
        else if op = 'CALL' then
        begin
           adr := calcadr;
           if adr > 0 then
           begin
                   if adr < 8192 then begin addcode($E0 + adr div 256); addcode(adr mod 256); end
                   else begin addcode($78); addcode(adr div 256); addcode(adr mod 256); end;
           end else
           begin
                   addcode(NOP); addcode(NOP); addcode(NOP);
           end;
        end
        else if op = 'JMP' then
        begin
           adr := calcadr;
           if adr > 0 then
           begin
                   addcode(121); addcode(adr div 256); addcode(adr mod 256);
           end else
           begin
                   addcode(NOP); addcode(NOP); addcode(NOP);
           end;
        end
        else if op = 'JPLO' then
        begin
           adr := calcadr;
           if adr > 0 then
           begin
                   addcode(127); addcode(adr div 256); addcode(adr mod 256);
           end else
           begin
                   addcode(NOP); addcode(NOP); addcode(NOP);
           end;
        end
        else if op = 'JPSH' then
        begin
           adr := calcadr;
           if adr > 0 then
           begin
                   addcode(125); addcode(adr div 256); addcode(adr mod 256);
           end else
           begin
                   addcode(NOP); addcode(NOP); addcode(NOP);
           end;
        end
        else if op = 'JPNE' then
        begin
           adr := calcadr;
           if adr > 0 then
           begin
                   addcode(124); addcode(adr div 256); addcode(adr mod 256);
           end else
           begin
                   addcode(NOP); addcode(NOP); addcode(NOP);
           end;
        end
        else if op = 'JPEQ' then
        begin
           adr := calcadr;
           if adr > 0 then
           begin
                   addcode(126); addcode(adr div 256); addcode(adr mod 256);
           end else
           begin
                   addcode(NOP); addcode(NOP); addcode(NOP);
           end;
        end
        else if op = 'RJMP' then
        begin
           adr := calcadr;
           if adr >= 8192 then
           begin
               if abs(adr - startadr - codpos) <= 255 then
               begin
                   if adr > startadr + codpos then addcode(44)
                   else addcode(45);
                   addcode(abs(adr - startadr - codpos));
               end else
               begin
                   addcode(121); addcode(adr div 256); addcode(adr mod 256);   // Do absolute jump then
               end;
           end else
           if (adr >= 1) and (adr <= 255) then
           begin
                   addcode(44); addcode(adr);
           end else
           if (adr <= -1) and (adr >= -255) then
           begin
                   addcode(45); addcode(adr);
           end else
           begin
                   addcode(NOP); addcode(NOP);
           end;
        end
        else if op = 'BRLO' then
        begin
           adr := calcadr;
           if adr >= 8192 then
           begin
               if abs(adr - startadr - codpos) <= 255 then
               begin
                   if adr > startadr + codpos then addcode(58)
                   else addcode(59);
                   addcode(abs(adr - startadr - codpos));
               end else abort('Relative jump exceeds 255 bytes!');
           end else
           if (adr >= 1) and (adr <= 255) then
           begin
                   addcode(58); addcode(adr);
           end else
           if (adr <= -1) and (adr >= -255) then
           begin
                   addcode(59); addcode(adr);
           end else
           if (abs(adr) >= 256) and (abs(adr) < 8192) then
           begin
                   adr := startadr + codpos + adr;
                   addcode(127); addcode(adr div 256); addcode(adr mod 256);
           end else
           begin
                   addcode(NOP); addcode(NOP);
           end;
        end
        else if op = 'BRSH' then
        begin
           adr := calcadr;
           if adr >= 8192 then
           begin
               if abs(adr - startadr - codpos) <= 255 then
               begin
                   if adr > startadr + codpos then addcode(42)
                   else addcode(43);
                   addcode(abs(adr - startadr - codpos));
               end else abort('Relative jump exceeds 255 bytes!');
           end else
           if (adr >= 1) and (adr <= 255) then
           begin
                   addcode(42); addcode(adr);
           end else
           if (adr <= -1) and (adr >= -255) then
           begin
                   addcode(43); addcode(adr);
           end else
           if (abs(adr) >= 256) and (abs(adr) < 8192) then
           begin
                   adr := startadr + codpos + adr;
                   addcode(125); addcode(adr div 256); addcode(adr mod 256);
           end else
           begin
                   addcode(NOP); addcode(NOP);
           end;
        end
        else if op = 'BRNE' then
        begin
           adr := calcadr;
           if adr >= 8192 then
           begin
               if abs(adr - startadr - codpos) <= 255 then
               begin
                   if adr > startadr + codpos then addcode(40)
                   else addcode(40);
                   addcode(abs(adr - startadr - codpos));
               end else abort('Relative jump exceeds 255 bytes!');
           end else
           if (adr >= 1) and (adr <= 255) then
           begin
                   addcode(40); addcode(adr);
           end else
           if (adr <= -1) and (adr >= -255) then
           begin
                   addcode(41); addcode(adr);
           end else
           if (abs(adr) >= 256) and (abs(adr) < 8192) then
           begin
                   adr := startadr + codpos + adr;
                   addcode(124); addcode(adr div 256); addcode(adr mod 256);
           end else
           begin
                   addcode(NOP); addcode(NOP);
           end;
        end
        else if op = 'BREQ' then
        begin
           adr := calcadr;
           if adr >= 8192 then
           begin
               if abs(adr - startadr - codpos) <= 255 then
               begin
                   if adr > startadr + codpos then addcode(56)
                   else addcode(57);
                   addcode(abs(adr - startadr - codpos));
               end else abort('Relative jump exceeds 255 bytes!');
           end else
           if (adr >= 1) and (adr <= 255) then
           begin
                   addcode(56); addcode(adr);
           end else
           if (adr <= -1) and (adr >= -255) then
           begin
                   addcode(57); addcode(adr);
           end else
           if (abs(adr) >= 256) and (abs(adr) < 8192) then
           begin
                   adr := startadr + codpos + adr;
                   addcode(126); addcode(adr div 256); addcode(adr mod 256);
           end else
           begin
                   addcode(NOP); addcode(NOP);
           end;
        end
        else if (op = 'CASE') then
        begin
           addcode(122);
           mcase := true;
           ccase := codpos;
           casecnt := 0;
           addcode(NOP); addcode(NOP); addcode(NOP);
           addcode(105);
        end
        else if mcase then
        begin
           if (op = 'ENDCASE') then
           begin
              mcase := false;
              adr := codpos;
              codpos := ccase;
              addcode(casecnt);
              addcode((adr+startadr) div 256); addcode((adr+startadr) mod 256);
              codpos := adr;
           end else
           begin
              if op <> 'ELSE' then
                 begin addcode(mathparse(op, 8)); inc(casecnt); end;
              dec(codpos);
              adr := calcadr;
              inc(codpos);
              if adr > 0 then
                 begin addcode(adr div 256); addcode(adr mod 256); end
              else
                 begin addcode(NOP); addcode(NOP); end;
           end;
        end
        else if op = 'MOV' then
        begin
           if (param1 = 'A') and (param2 = '[+X]') then addcode(36)
           else if (param1 = 'A') and (param2 = '[-X]') then addcode(37)
           else if (param1 = '[+Y]') and (param2 = 'A') then addcode(38)
           else if (param1 = '[-Y]') and (param2 = 'A') then addcode(39)
           else if (param1 = 'A') and (param2 = 'R') then addcode(34)
           else if (param1 = 'R') and (param2 = 'A') then addcode(50)
           else if (param1 = 'A') and (param2 = 'Q') then addcode(33)
           else if (param1 = 'Q') and (param2 = 'A') then addcode(49)
           else if (param1 = 'A') and (param2 = 'P') then addcode(32)
           else if (param1 = 'P') and (param2 = 'A') then addcode(48)
           else if (param1 = '[P]') and (param2 = '[DP]') then addcode(85)
           else if (param1 = '[DP]') and (param2 = '[P]') then addcode(83)
           else if (param1 = 'A') and (param2 = '[DP]') then addcode(87)
           else if (param1 = '[DP]') and (param2 = 'A') then addcode(82)
           else if (param1 = 'A') and (param2 = '[P]') then addcode(89)
           else if (param1 = '[P]') and (param2 = 'A') then begin addcode(219); addcode(89); end
           else if (param1 = 'A') then begin addcode(2); addcode(mathparse(param2, 8)); end
           else if (param1 = 'B') then begin addcode(3); addcode(mathparse(param2, 8)); end
           else if (param1 = 'I') then begin addcode(0); addcode(mathparse(param2, 8)); end
           else if (param1 = 'J') then begin addcode(1); addcode(mathparse(param2, 8)); end
           else if (param1 = 'P') then begin addcode(18); addcode(mathparse(param2, 8)); end
           else if (param1 = 'Q') then begin addcode(19); addcode(mathparse(param2, 8)); end
           else if (param1 = 'DPL') then begin addcode(17); addcode(mathparse(param2, 8)); end
           else if (param1 = 'DP') then begin addcode(16); adr := mathparse(param2, 16); addcode(adr div 256); addcode(adr mod 256); end;
        end
        else if op = 'NOP' then
        begin
           if param1 = '' then addcode(NOP) else begin addcode(78); addcode(mathparse(param1, 8)); end;
        end
        else
           abort('Unknown OP-code: '+op);
        end;
end;


procedure parsefile(fname: string);
var datei: textfile;
    lcnt: integer;

function readline: string;
var
	i: integer;
	c: boolean;
begin
    repeat
	repeat
		readln(datei, result);
                inc(lcnt);
                cline := lcnt;
                result := trim(result);
	until eof(datei) or (result <> '');
	if eof(datei) and (result = '') then exit;

	c := false;
	for i := 1 to length(result) do
	begin
		if (result[i] = '''') or (result[i] = '"') then c := not c;
		if (not c) and (result[i] in [';','#']) then
		begin
			delete(result, i, length(result));
			break;
		end;
	end;
        if result <> '' then
        begin
	    i := pos(':', result);
	    if i > 0 then
	    begin
		addlabel(trim(copy(result, 1, i - 1)));
		delete(result, 1, i);
                result := trim(result);
            end;
        end;
        if result <> '' then
        begin
            if pos('ifdef', lowercase(result)) = 0 then
            begin
                if symcnt > 0 then for i := 0 to symcnt - 1 do
                        result := replace_text(result, sym[i], symval[i]);
                if labcnt > 0 then for i := 0 to labcnt - 1 do
                        result := replace_text(result, lab[i], inttostr(labpos[i] + startadr));
            end;
        end;
     until eof(datei) or (result <> '');
end;

begin
  if not fileexists(fname) then
  begin
    writeln('File '+fname+' not found!');
    halt (1);
  end;
	assignfile(datei, fname);
	reset(datei);
        cf := fname;
        lcnt := 0;

	tok := readline; // Überspringt Leerzeilen und entfernt Kommentare
	while (not eof(datei)) or (tok <> '') do
	begin
            if pos('.endif', tok) = 0 then
            begin

		extractop(tok);
		if op = '.ORG' then
                begin
                        startadr := mathparse(param1, 16);
                end
		else if op = '.EQU' then
                begin
                        addsymbol(param1, param2);
                end
                else if op = '.DB' then
                begin
                        while pos(',', params) > 0 do
                        begin
                                s := copy(params, 1, pos(',', params) - 1);
                                //if s[1] = '''' then addcode(ord(s[2])) else
                                addcode(mathparse(s, 8));
                                delete(params, 1, pos(',', params));
                        end;
                        params := trim(params);
                        //if params[1] = '''' then addcode(ord(params[2])) else
                        addcode(mathparse(params, 8));
                end
                else if op = '.DW' then
                begin
                        while pos(',', params) > 0 do
                        begin
                                s := copy(params, 1, pos(',', params) - 1);
                                addcode((mathparse(s, 16) shr 8) and $FF);
                                addcode(mathparse(s, 16) and $FF);
                                delete(params, 1, pos(',', params));
                        end;
                        addcode((mathparse(params, 16) shr 8) and $FF);
                        addcode(mathparse(params, 16) and $FF);
                end
                else if op = '.DS' then
                begin
                        delete(params, 1, pos('"', params));
                        while (params <> '') and (params[1] <> '"') do
                        begin
                                if params[1] = '\' then
                                begin
                                   if params[2] = '\' then addcode(ord('\'))
                                   else
                                   begin
                                      addcode(converthex(uppercase(copy(params, 3, 2))));
                                      delete(params, 1, 4);
                                   end;
                                end else
                                begin
                                   addcode(ord(params[1]));
                                   delete(params, 1, 1);
                                end;
                        end;
                end
                else if op = '.IFDEF' then
                begin
                        if not findsymbol(param1) then
                        while not eof(datei) and (op <> '.ENDIF') do
                        begin
                                tok := readline;
                                //extractop(tok);
                                if pos('.endif', lowercase(tok)) > 0 then
                                   op := '.ENDIF';
                        end;
                end
                else if op = '.INCLUDE' then
                begin
                        if fileexists(params) then
                        begin
                                parsefile(params);
                        end else
                        begin
                                abort('Include file ' + params + ' not found!');
                        end;
                end
                else
                        doasm;
            end;
            tok := readline; // Überspringt Leerzeilen und entfernt Kommentare
	end;

	closefile(datei);
end;


procedure savefile(fname: string);
var f: textfile;
    f2: file of byte;
    i, wr: integer;
    s: string;
    b: byte;

begin
        if uppercase(paramstr(3)) = 'DEC' then
        begin
	        assignfile(f, fname);
                rewrite(f);

                for wr := 0 to codpos - 1 do
                begin
                        b := code[wr];
                        writeln(f, inttostr(b));
                end;

	        closefile(f);
        end else
        if uppercase(paramstr(3)) = 'BAS' then
        begin
	        assignfile(f, paramstr(2));
                rewrite(f);
                blcnt := 10;
                s := '';
                i := 0;

                for wr := 0 to codpos - 1 do
                begin
                        b := code[wr];
                        s := s + ',' + inttostr(b);
                        if length(s) >= 60 then
                        begin
                                writeln(f, inttostr(blcnt) + ' POKE ' + inttostr(startadr) + s);
                                s := '';
                                blcnt := blcnt + 10;
                                startadr := startadr + i + 1;
                                i := -1;
                        end;
                        inc(i);
                end;
                if s <> '' then
                        writeln(f, inttostr(blcnt) + ' POKE ' + inttostr(startadr) + s);

	        closefile(f);
        end else
        begin
	        assignfile(f2, paramstr(2));
                rewrite(f2);

                for wr := 0 to codpos - 1 do
                begin
                        b := code[wr];
                        write(f2, b);
                end;

	        closefile(f2);
        end;
end;



begin
        ExitCode := 0;
        writeln('pasm v1.1 - Assembler for Pocket Computers with SC61860 CPU');
        writeln('(c) Simon Lehmayr 2004');
	if paramcount < 2 then
        begin
          writeln('Usage: pasm asmfile outputfile [mode]');
          writeln('       mode: bin = binary file output (default)');
          writeln('             dec = decimal file output');
          writeln('             bas = basic file output');
          exit;
        end;

        parsefile(paramstr(1));

        if nlabcnt > 0 then
        begin
          for i := 0 to nlabcnt - 1 do
            writeln('In line "' + nlabasm[i] + '": ' + nlab[i]);
          abort('Labels were not available!');
        end;

        writeln;
        writeln('Start address:'#9,startadr);
        writeln('End address:'#9,startadr+codpos-1);
        writeln('(',codpos,' bytes)');

        if codpos = 0 then
        begin
                addcode(55);
                writeln('An empty program was produced!');
                exit;
        end;

        savefile(paramstr(2));
end.

