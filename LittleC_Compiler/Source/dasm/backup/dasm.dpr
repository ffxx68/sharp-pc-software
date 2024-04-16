program dasm;
{$APPTYPE CONSOLE}
{%File 'ModelSupport\default.txvpck'}
uses sysutils;

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
              'RA'{CLRA},'IXL','DXL','IYS','DYS',
              'JRNZP','JRNZM','JRNCP','JRNCM','JRP',
              'JRM','?046?','LOOP','STP','STQ',
              'STR','NOPT','PUSH','MVWP'{MVWP},'?054?',
              'RTN','JRZP','JRZM','JRCP','JRCM',
              '?060?','?061?','?062?','?063?','INCI',
              'DECI','INCA','DECA','ADM','SBM',
              'ANMA','ORMA','INCK','DECK','INCM',
              'DECM','INA','NOPW','WAIT','IPXL'{IPXL},
              'INCP','DECP','STD','MVDM','MVMP'{MVMP},
              'MVMD','LDPC'{LDPC},'LDD','SWP','LDM',
              'SL','POP','?092?','OUTA','?094?',
              'OUTF','ANIM','ORIM','TSIM','CPIM',
              'ANIA','ORIA','TSIA','CPIA','NOPT',
              'DTJ','NOPT','TEST','?108?','?109?',
              '?110?','IPXH','ADIM','SBIM','RZ',
              'RZ','ADIA','SBIA','RZ','RZ',
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
              'NOPW','NOPT','?207?','SC','RC',
              'SR','NOPW','ANID','ORID','TSID',
              'SZ','LEAVE','NOPW','EXAB','EXAM',
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
              1,1,2,2,2,
              2,2,2,2,2,
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
              2,1,1,1,1,
              1,1,1,1,2,
              2,2,2,2,2,
              2,2,2,2,2,
              2,2,2,2,2,
              2,2,2,2,2,
              2,2,2,2,2,
              2,2,2,2,2,
              2);



procedure parsefile(fname, fname2: string);
var datei, fb, f: textfile;
    s: string;
    i, i2, lc: integer;
    b: byte;

begin
  if not fileexists(fname) then
  begin
    writeln('File '+fname+' not found!');
    halt;
  end;
  assignfile(f, fname2);
  rewrite(f);
  lc := 0;

  if lowercase(paramstr(3)) = 'dec' then
  begin
	  assignfile(datei, fname);
	  reset(datei);

    while not eof(datei) do
    begin
      readln(datei, s); i := strtoint(s);
      if i in [128..191] then
        write(f, 'LP'#9, i - 128)
      else
      if i in [224..255] then
      begin
        readln(datei, s); i2 := strtoint(s);
        write(f, 'CAL'#9, (i - 224) * 256 + i2);
      end else
        write(f, OPCODE[i]);
      if (NBARGU[i] = 2) and (i < 224) then
      begin
        readln(datei, s); i := strtoint(s);
        writeln(f, #9,i);
      end else
      if NBARGU[i] = 3 then
      begin
        readln(datei, s); i := strtoint(s);
        readln(datei, s); i2 := strtoint(s);
        writeln(f, #9,i*256+i2);
      end else writeln(f);
      inc(lc);
    end;
    closefile(datei);
  end else
  begin
	  assignfile(fb, fname);
	  reset(fb);

    while not eof(fb) do
    begin
      read(fb, b); i := b;
      if i in [128..191] then
        write(f, 'LP'#9, i - 128)
      else
      if i in [224..255] then
      begin
        read(fb, b); i2 := b;
        write(f, 'CAL'#9, (i - 224) * 256 + i2);
      end else
        write(f, OPCODE[i]);
      if NBARGU[i] = 2 then
      begin
        read(fb, b); i := b;
        writeln(f, #9,i);
      end else
      if NBARGU[i] = 3 then
      begin
        read(fb, b); i := b;
        read(fb, b); i2 := b;
        writeln(f, #9,i*256+i2);
      end else writeln(f);
      inc(lc);
    end;
    closefile(fb);
  end;

  closefile(f);
  writeln('Extracted ',lc,' assembler lines!');
end;



begin
        writeln('dasm v1.0 - Disassembler for Pocket Computers with SC61860 CPU');
        writeln('(c) Simon Lehmayr 2004');
	      if paramcount < 2 then
        begin
          writeln('Usage: dasm inputfile outputfile [mode]');
          writeln('       mode: bin = binary file input');
          writeln('             dec = decimal file input');
          exit;
        end;

        parsefile(paramstr(1), paramstr(2));

end.

