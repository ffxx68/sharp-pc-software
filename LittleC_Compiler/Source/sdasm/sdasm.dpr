program sdasm;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
 
{$APPTYPE CONSOLE}
 
uses
  SysUtils, StrUtils;
 
const
        CONDJUMP = [124..127, 56..59, 40..43];
        OP_JUMP = [ {44, 45,} 120, 121];
        A_JUMP = [121];
        R_JUMP = [44, 45];
        A_CJUMP = [124..127];
        R_CJUMP = [56..59, 40..43];
        JUMP_P = [40, 42, 44, 56, 58];
        JUMP_M = [41, 43, 45, 57, 59];
        SPECIAL = [16, 17, 105, 122];
        ROM_OFFSET = $4000;
        
        OPCODE : array[0..255] of string[5] =   // list of opcodes
{0..4}       ('LII','LIJ','LIA','LIB','IX',
{5..9}        'DX','IY','DY','MVW','EXW',
{10..14}      'MVB','EXB','ADN','SBN','ADW',
{15..19}      'SBW','LIDP','LIDL','LIP','LIQ',
{20..24}      'ADB','SBB','?022?','?023?','MVWD',
{25..29}      'EXWD','MVBD','EXBD','SRW','SLW',
{30..34}      'FILM','FILD','LDP','LDQ','LDR',
{35..39}      'RA'{CLRA},'IXL','DXL','IYS','DYS',
{40..44}      'JRNZP','JRNZM','JRNCP','JRNCM','JRP',
{45..49}      'JRM','?046?','LOOP','STP','STQ',
{50..54}      'STR','NOPT','PUSH','MVWP'{MVWP},'?054?',
{55..59}      'RTN','JRZP','JRZM','JRCP','JRCM',
{60..64}      '?060?','?061?','?062?','?063?','INCI',
{65..69}      'DECI','INCA','DECA','ADM','SBM',
{70..74}      'ANMA','ORMA','INCK','DECK','INCM',
{75..79}      'DECM','INA','NOPW','WAIT','IPXL'{IPXL},
{80..84}      'INCP','DECP','STD','MVDM','MVMP'{MVMP},
{85..89}      'MVMD','LDPC'{LDPC},'LDD','SWP','LDM',
{90..94}      'SL','POP','?092?','OUTA','?094?',
{95..99}      'OUTF','ANIM','ORIM','TSIM','CPIM',
{100..104}    'ANIA','ORIA','TSIA','CPIA','NOPT',
{105..109}    'DTJ','NOPT','TEST','?108?','?109?',
{110..114}    '?110?','IPXH','ADIM','SBIM','RZ',
{115..119}    'RZ','ADIA','SBIA','RZ','RZ',
{120..124}    'CALL','JP','PTJ','?123?','JPNZ',
{125..129}    'JPNC','JPZ','JPC','LP00','LP01',
{130..134}    'LP02','LP03','LP04','LP05','LP06',
{135..139}    'LP07','LP08','LP09','LP10','LP11',
{140..144}    'LP12','LP13','LP14','LP15','LP16',
{145..149}    'LP17','LP18','LP19','LP20','LP21',
{150..154}    'LP22','LP23','LP24','LP25','LP26',
{155..159}    'LP27','LP28','LP29','LP30','LP31',
{160..164}    'LP32','LP33','LP34','LP35','LP36',
{165..169}    'LP37','LP38','LP39','LP40','LP41',
{170..174}    'LP42','LP43','LP44','LP45','LP46',
{175..179}    'LP47','LP48','LP49','LP50','LP51',
{180..184}    'LP52','LP53','LP54','LP55','LP56',
{185..189}    'LP57','LP58','LP59','LP60','LP61',
{190..194}    'LP62','LP63','INCJ','DECJ','INCB',
{195..199}    'DECB','ADCM','SBCM','TSMA','CPMA',
{200..204}    'INCL','DECL','INCN','DECN','INB',
{205..209}    'NOPW','NOPT','?207?','SC','RC',
{210..214}    'SR','NOPW','ANID','ORID','TSID',
{215..219}    'SZ','LEAVE','NOPW','EXAB','EXAM',
{220..224}    '?220?','OUTB','?222?','OUTC','CAL00',
{225..229}    'CAL01','CAL02','CAL03','CAL04','CAL05',
{230..234}    'CAL06','CAL07','CAL08','CAL09','CAL10',
{235..239}    'CAL11','CAL12','CAL13','CAL14','CAL15',
{240..244}    'CAL16','CAL17','CAL18','CAL19','CAL20',
{245..249}    'CAL21','CAL22','CAL23','CAL24','CAL25',
{250..254}    'CAL26','CAL27','CAL28','CAL29','CAL30',
{255}         'CAL31');
 
        NBARGU : array[0..255] of byte =      // list of argument count
{0..4}       (2,2,2,2,1,
{5..9}        1,1,1,1,1,
{10..14}      1,1,1,1,1,
{15..19}      1,3,2,2,2,
{20..24}      1,1,1,1,1,
{25..29}      1,1,1,1,1,
{30..34}      1,1,1,1,1,
{35..39}      1,1,1,1,1,
{40..44}      2,2,2,2,2,
{45..49}      2,1,2,1,1,
{50..54}      1,1,1,1,1,
{55..59}      1,2,2,2,2,
{60..64}      1,1,1,1,1,
{65..69}      1,1,1,1,1,
{70..74}      1,1,1,1,1,
{75..79}      1,1,1,2,1,
{80..84}      1,1,1,1,1,
{85..89}      1,1,1,1,1,
{90..94}      1,1,1,1,1,
{95..99}      1,2,2,2,2,
{100..104}    2,2,2,2,1,
{105..109}    1,1,2,1,1,
{110..114}    1,1,2,2,2,
{115..119}    2,2,2,2,2,
{120..124}    3,3,3,1,3,
{125..129}    3,3,3,1,1,
{130..134}    1,1,1,1,1,
{135..139}    1,1,1,1,1,
{140..144}    1,1,1,1,1,
{145..149}    1,1,1,1,1,
{150..154}    1,1,1,1,1,
{155..159}    1,1,1,1,1,
{160..164}    1,1,1,1,1,
{165..169}    1,1,1,1,1,
{170..174}    1,1,1,1,1,
{175..179}    1,1,1,1,1,
{180..184}    1,1,1,1,1,
{185..189}    1,1,1,1,1,
{190..194}    1,1,1,1,1,
{195..199}    1,1,1,1,1,
{200..204}    1,1,1,1,1,
{205..209}    1,1,1,1,1,
{210..214}    1,1,2,2,2,
{215..219}    2,1,1,1,1,
{220..224}    1,1,1,1,2,
{225..229}    2,2,2,2,2,
{230..234}    2,2,2,2,2,
{235..239}    2,2,2,2,2,
{240..244}    2,2,2,2,2,
{245..249}    2,2,2,2,2,
{250..254}    2,2,2,2,2,
{255}         2);
 
type
  oprec = record
    v: byte;            // actual stored rom value
    op: boolean;        // is this a cpu op
    par: boolean;       // is this a parameter of an op
    lab: integer;       // is a label pointing to this op (only if it's an op), label index
    nolab: boolean;     // destination is out of range and address will be encoded as number not as label
    dstadr: integer;    // is this a jump and where does it go
    dstlab: integer;    // what index has the destination label
    tl: byte;           // is this a table call and how many entries has it
  end;
 
  slrec = record
    pc, cb, rtnadr: integer;
  end;
 
var
  cbank: integer = 0;   // current bank 0=intern 1..8=extern
  pc: integer = 0;      // current pc 0..8191=intern, $4000..$7FFF=extern
  lpc: integer = 0;     // last address of a jump
  dp: integer = 0;      // dp address & state
  ptc: integer = 0;     // else address of TC
  H: integer = 0;       // number of entries in TC
  R: integer = -1;      // return address for table call
  p_rom: boolean;       // if the rom should be parsed
  c_len: integer;       // length of the program
  labn: integer = 0;    // increasing label number
  stack: array [0..44] of integer;  // last return address on stack
  s_ptr: integer = 0;
  startadr: integer = 0;// the start address of a user prg
  slist: array [0..65535] of slrec; // a list of mem position to scan
  sl_cnt: integer = 0;  // number of entries in this list
  pushcnt: integer = 0; // counts push/pop operations
 
  code: Array [0..7, 0..65535] of oprec;    // holds the rom code and analysis data
 

procedure error(s: string);
begin
  writeln('Error: ', s, ' , BANK=', cbank, ', ADDR=', pc);
  halt;
end;
 

procedure addscanlist(sl, ra: integer);
var i: integer;
begin
  for i := 0 to sl_cnt - 1 do
    if slist[i].pc = sl then
      exit;
  slist[sl_cnt].pc := sl;
  slist[sl_cnt].cb := cbank;
  slist[sl_cnt].rtnadr := ra;
  inc(sl_cnt);
end;
 

procedure push(p: integer);
begin
  stack[s_ptr] := p;
  inc(s_ptr);
end;
 

function pop: integer;
begin
  dec(s_ptr);
  result := stack[s_ptr];
end;
 

procedure parse;
var i: integer;
 
function parsecode: boolean;
var c_op: byte;
    jp_adr, i: integer;
 
  function makelab(ladr: integer): boolean;
  begin
    result := false;
    if not p_rom then
      if (jp_adr < startadr) or (jp_adr >= startadr + c_len) then
      begin
        code[cbank, ladr].nolab := true;
        exit;
      end;
    if code[cbank, jp_adr].lab = -1 then
    begin
      code[cbank, jp_adr].lab := labn;
      code[cbank, ladr].dstlab := labn;
      inc(labn);
      result := true;
    end else
      code[cbank, ladr].dstlab := code[cbank, jp_adr].lab;
  end;
 
begin
  result := false;
  c_op := code[cbank, pc].v;
  if code[cbank, pc].op then
  begin
    result := true;
    exit;
  end;
  code[cbank, pc].op := true;
  if c_op in A_JUMP then
  begin
    inc(pc);
    jp_adr := code[cbank, pc].v * 256 + code[cbank, pc+1].v;
    code[cbank, pc].par := true;
    inc(pc);
    code[cbank, pc].par := true;
    code[cbank, pc-2].dstadr := jp_adr;
    makelab(pc-2);
    pc := jp_adr;
    exit;
  end else
  if c_op in R_JUMP then
  begin
    inc(pc);
    if c_op in JUMP_P then jp_adr := pc + code[cbank, pc].v;
    if c_op in JUMP_M then jp_adr := pc - code[cbank, pc].v;
    code[cbank, pc].par := true;
    code[cbank, pc-1].dstadr := jp_adr;
    makelab(pc-1);
    pc := jp_adr;
    exit;
  end else
  if c_op in [224..255] then
  begin
    inc(pc);
    jp_adr := (c_op-224) * 256 + code[cbank, pc].v;
    code[cbank, pc].par := true;
    code[cbank, pc-1].dstadr := jp_adr;
    if makelab(pc-1) then
    begin
      push(pc+1);
      pc := jp_adr;
      exit;
    end;
  end else
  if c_op = 120 then
  begin
    inc(pc);
    jp_adr := code[cbank, pc].v * 256 + code[cbank, pc+1].v;
    code[cbank, pc].par := true;
    inc(pc);
    code[cbank, pc].par := true;
    code[cbank, pc-2].dstadr := jp_adr;
    if makelab(pc-2) then
    begin
      push(pc+1);
      pc := jp_adr;
      exit;
    end;
  end else
  if c_op in R_CJUMP then
  begin
    inc(pc);
    if c_op in JUMP_P then jp_adr := pc + code[cbank, pc].v;
    if c_op in JUMP_M then jp_adr := pc - code[cbank, pc].v;
    code[cbank, pc].par := true;
    code[cbank, pc-1].dstadr := jp_adr;
    if makelab(pc-1) then
    begin
      addscanlist(pc+1, -1);
      pc := jp_adr;
      exit;
    end;
  end else
  if c_op in A_CJUMP then
  begin
    inc(pc);
    jp_adr := code[cbank, pc].v * 256 + code[cbank, pc+1].v;
    code[cbank, pc].par := true;
    inc(pc);
    code[cbank, pc].par := true;
    code[cbank, pc-2].dstadr := jp_adr;
    if makelab(pc-2) then
    begin
      addscanlist(pc+1, -1);
      pc := jp_adr;
      exit;
    end;
  end else
  if c_op in SPECIAL then
  begin
    inc(pc);
    if c_op = 105 then
    begin
      code[cbank, pc-1].tl := H;
      while H > 0 do
      begin
        code[cbank, pc].par := true;
        inc(pc);
        jp_adr := code[cbank, pc].v * 256 + code[cbank, pc+1].v;
        code[cbank, pc].par := true;
        inc(pc);
        code[cbank, pc].par := true;
        inc(pc);
        code[cbank, pc-2].dstadr := jp_adr;
        if makelab(pc-2) then
          addscanlist(jp_adr, R);
        dec(H);
      end;
      jp_adr := code[cbank, pc].v * 256 + code[cbank, pc+1].v;
      code[cbank, pc].par := true;
      inc(pc);
      code[cbank, pc].par := true;
      code[cbank, pc-1].dstadr := jp_adr;
      if makelab(pc-1) then
      begin
        pc := jp_adr;
        push(R);
        exit;
      end;
    end;
    if c_op = 122 then
    begin
      H := code[cbank, pc].v;
      code[cbank, pc].par := true;
      inc(pc);
 
      jp_adr := code[cbank, pc].v * 256 + code[cbank, pc+1].v;
      R := jp_adr;
      code[cbank, pc].par := true;
      inc(pc);
      code[cbank, pc].par := true;
      code[cbank, pc-1].dstadr := jp_adr;
      makelab(pc-1);
{      if makelab(pc-1) then
      begin
        addscanlist(pc+1);
        pc := jp_adr;
        exit;
      end;
}
    end;
    if c_op = 16 then
    begin
      dp := code[cbank, pc].v * 256 + code[cbank, pc+1].v;
      code[cbank, pc].par := true;
      inc(pc);
      code[cbank, pc].par := true;
      jp_adr := dp;
      makelab(pc-2);
    end;
    if c_op = 17 then
    begin
      dp := (dp and $FF00) + code[cbank, pc+1].v;
      code[cbank, pc].par := true;
    end;
  end else
  if c_op = 55 then
  begin
    if s_ptr = 0 then
    begin
      result := true;
      exit;
    end;
    pc := pop;
    exit;
  end else
  if NBARGU[c_op] = 2 then
  begin
    inc(pc);
    code[cbank, pc].par := true;
  end else
  if NBARGU[c_op] = 3 then
  begin
    inc(pc);
    code[cbank, pc].par := true;
    inc(pc);
    code[cbank, pc].par := true;
  end;
  inc(pc);
  if (dp >= $3400) and (dp <= $34FF) then
  begin
        writeln('A bank change is probably coming!');
        writeln('Current bank = ', cbank);
        writeln('Current DP = ', dp);
        writeln('Current PC = ', pc);
        writeln('Please look at this code and enter the bank number!');
        for i := pc to pc + 80 do
        begin
          write(' ', code[cbank, i].v);
          if (i-pc) mod 8 = 0 then writeln;
        end;
        write('Bank 0..7? ');
        readln(cbank);
  end;
end;
 
begin
  pc := startadr;
  while not parsecode do;
  i := 0;
  while i < sl_cnt do
  begin
    if slist[i].cb <> -1 then push(slist[i].cb);
    pc := slist[i].pc;
    cbank := slist[i].cb;
    while not parsecode do;
    inc(i);
  end;
end;
 

procedure savecode(fnam: string);
var f: textfile;
    c, t: integer;
 
  procedure genoutp(bnk, start, len: integer);
  var i, th, j: integer;
  begin
    i := start;
    if p_rom then c_len := start + len;
    while i - start < c_len do
    begin

      write(f, IntToHex ( i, 4 ));  { current address }
      if code[bnk, i].op then
      begin

        if code[bnk, i].lab <> -1 then
        begin
          { writeln(f); }
          write(f, #9, 'LB', code[bnk, i].lab, ':', #9);
        end else
            write(f, #9, #9, #9);
        for j := 0 to NBARGU[code[bnk, i].v]-1 do
            write(f, IntToHex ( code[bnk, i+j].v ))   ;
        if NBARGU[code[bnk, i].v] = 1 then
          write(f, #9 );
        write(f, #9, #9);
        if not (code[bnk, i].v in [128..191, 224..255]) then
        begin
          write(f, #9, OPCODE[code[bnk, i].v]);
          if Length(OPCODE[code[bnk, i].v]) < 4 then write(f, #9);
        end;
        if code[bnk, i].v = 55 then
          writeln(f);
        if code[bnk, i].v in { OP_JUMP } ( A_JUMP + A_CJUMP ) then
        begin
          t := code[bnk, i+1].v * 256; t := t + code[bnk, i+2].v;
          if code[bnk, i].nolab then writeln(f, #9, IntToHex(t, 4) )
          else writeln(f, #9, 'LB', code[bnk, i].dstlab);
          inc(i, 2);
        end else
        if code[bnk, i].v in ( R_JUMP + R_CJUMP ) then
        begin
          if code[bnk, i].nolab then writeln(f, #9, IntToHex(code[bnk, i+2].v, 4) )
          else writeln(f, #9, 'LB', code[bnk, i].dstlab);
          inc(i);
        end else
        if code[bnk, i].v = 16 then
        begin
          t := code[bnk, i+1].v * 256 + code[bnk, i+2].v;
          { if code[bnk, i].nolab then } writeln(f, #9, IntToHex( t, 4))
          {else writeln(f, #9, 'LB', code[bnk, i].dstlab) } ;
          inc(i, 2);
        end else
        if code[bnk, i].v in [224..255] then
        begin
          write(f, #9'CAL'#9);
          t := code[bnk, i].v - 224 + code[bnk, i+1].v;
          {if code[bnk, i].nolab then }writeln(f, #9, IntToHex( code[bnk, i].dstadr, 4) )
          {else writeln(f, #9, 'LB', code[bnk, i].dstlab)} ;
          inc(i);
        end else
        if code[bnk, i].v in [128..191] then
        begin
          writeln(f, #9, 'LP'#9#9, IntToHex( code[bnk, i].v-128, 2 ));
        end else
        if code[bnk, i].v in R_CJUMP then
        begin
          if code[bnk, i].nolab then writeln(f, #9, IntToHex(code[bnk, i+1].v))
            else writeln(f, #9, 'LB', code[bnk, i].dstlab);
          inc(i);
        end else
        if code[bnk, i].v in A_CJUMP then
        begin
          if code[bnk, i].nolab then
            writeln(f, #9, IntToHex(code[bnk, i+1].v*256+code[bnk, i+2].v, 4))
          else
            writeln(f, #9, 'LB', code[bnk, i].dstlab);
          inc(i, 2);
        end else
        if code[bnk, i].v = 105 then
        begin
          th := code[bnk, i].tl;
          writeln(f, #9'; ', th, ' entries');
          while th > 0 do
          begin
            inc(i, 3);
            writeln(f, #9'.DB'#9, code[bnk, i-2].v);
            t := code[bnk, i-1].v * 256; t := t + code[bnk, i].v;
            if code[bnk, i-1].nolab then writeln(f, #9, '.DW'#9, IntToHex(t, 4))
            else writeln(f, #9'.DW'#9'LB', code[bnk, i-1].dstlab);
            dec(th);
          end;
          inc(i, 2);
          t := code[bnk, i-1].v * 256; t := t + code[bnk, i].v;
          if code[bnk, i-1].nolab then writeln(f, #9, '.DW'#9, IntToHex(t, 4))
          else writeln(f, #9'.DW'#9'LB', code[bnk, i-1].dstlab);
        end else
        if code[bnk, i].v = 122 then
        begin
          inc(i, 3);
          t := code[bnk, i-1].v * 256; t := t + code[bnk, i].v;
          writeln(f);
          writeln(f, #9'.DB'#9,  IntToHex ( code[bnk, i-2].v ));
          if code[bnk, i-3].nolab then writeln(f, #9'.DW'#9, IntToHex(t, 4))
          else writeln(f, #9'.DW'#9'LB', code[bnk, i-1].dstlab);
        end else
        if NBARGU[code[bnk, i].v] = 2 then
        begin
          inc(i);
          writeln(f, #9,  IntToHex ( code[bnk, i].v ) );
        end else
        if NBARGU[code[bnk, i].v] = 3 then
        begin
          inc(i, 2);
          t := code[bnk, i-1].v * 256;
          writeln(f, #9,  IntToHex (  t + code[bnk, i].v ));
        end else
          writeln(f);
      end else
      begin
        if code[bnk, i].lab <> -1 then write(f, 'LB',code[bnk, i].lab,':');
        writeln(f, #9, #9, #9, IntToHex ( code[bnk, i].v ), #9, #9, '??')   ;
        {writeln(f, #9'.DB'#9, code[bnk, i].v);    }
      end;
      inc(i);
    end;
  end;
 
begin
  assignfile(f, fnam);
  rewrite(f);
  if p_rom then
  begin
    writeln(f, '######## CPU internal ROM ');
    genoutp(0, 0, 8192);
    for c := 0 to 7 do
    begin
      writeln(f);
      writeln(f, '######## ROM Bank ', c);
      genoutp(c, ROM_OFFSET, 16384);
    end;
  end else
  begin
    writeln(f, '.ORG'#9, startadr);
    writeln(f);
    genoutp(0, startadr, c_len);
  end;
  closefile(f);
end;
 

procedure loadroms(fnam: string);
var c, d: integer;
var startadrhex: string;

 procedure loadrom(rnam: string; bnk, offset: integer);
 var f: file of byte;
     b: byte;
     i: integer;
 begin
  if not fileexists(rnam) then
    error(rnam + ' not found!');
  assignfile(f, rnam);
  reset(f);
  i := 0;
  while ( (not eof(f)) and (i < offset) ) do
  begin
    read(f, b);
    inc(i);
  end;
  { i := offset;  }
  writeln ( 'addr: &' + IntToHex(i) );
  while not eof(f) do
  begin
    read(f, b);
    code[bnk, i].v := b;
    inc(i);
  end;
  c_len := i - startadr;
  closefile(f);
 end;
 
begin
  for c := 0 to 7 do


    for d := 0 to 65535 do
    begin
      code[c, d].v := 255;
      code[c, d].lab := -1;
      code[c, d].dstadr := -1;
      code[c, d].dstlab := -1;
      code[c, d].tl := 0;
    end;
 
    if p_rom then
    begin
      for c := 0 to 7 do
      begin
        loadrom('cpu-1360.rom', c, 0);
        loadrom('B' + inttostr(c-1) + '-1360.rom', c, ROM_OFFSET);
      end;
    end else
    begin

      write('Please enter the offset address (hex 0xNNNN):');
      readln(startadrhex);
      startadr := StrToInt(startadrhex);
      loadrom(fnam, 0, startadr);
    end;
end;
 

begin
  writeln('dpasm v1.0 - Smart Disassembler for Pocket Computers');
  writeln('(c) Simon Lehmayr 2004');
  if paramcount = 1 then
  begin
    p_rom := true;
    loadroms('');
    writeln('Disassembly of PC-1360 ROM...');
    parse;
    savecode(paramstr(1));
  end else if paramcount = 2 then
  begin
    p_rom := false;
    loadroms(paramstr(1)); // this loads the user file now!
    parse;
    savecode(paramstr(2));
  end else
  begin
    writeln('Usage: dpasm [inputfile] outputfile');
    writeln('    dpasm will disassemble the PC-1360 ROM if the inputfile is not given!');
  end;
end.
