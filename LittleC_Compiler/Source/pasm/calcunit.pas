//{$MODE DELPHI}
unit calcunit;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

// global

//uses
//  Classes;
//TYPE  Real=Extended;

interface
  procedure Evaluate(var Formula: String; wid: integer; var Value: integer;var ErrPosf: Integer);   { Posfition of error }
  function converthex(s: string): integer;


implementation

  function converthex(s: string): integer;
  var i, c: longint;
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
//    converthex := result;
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
//    convertbin := result;
  end;

procedure Evaluate(var Formula: String;    { Fomula to evaluate}
                   wid      : integer;      { Place for x in formula }
                   var Value: integer;      { Result of formula }
                   var ErrPosf: Integer);   { Posfition of error }
const
  HexNumbers: set of Char = ['0'..'9','A'..'F'];
  BinNumbers: set of Char = ['0','1'];
  Numbers: set of Char = ['0'..'9'];
  EofLine  = ^M;

var
  Posf, i, c: Integer;    { Current Posfition in formula                     }
  Ch: Char;           { Current character being scanned                 }
  dummy : String;
  SumR, SumL  : Integer;

{ Procedure NextCh returns the next character in the formula         }
{ The variable Posf contains the Posfition ann Ch the character        }

  procedure NextCh;
  begin
    repeat
      Posf:=Posf+1;
      if Posf<=Length(Formula) then
      Ch:=Formula[Posf] else Ch:=eofline;
    until Ch<>' ';
  end  { NextCh };


  function Fakult(I: Integer): Real;  { Fakultaet }
  var  dummy   : double;
  begin
    IF i=1 THEN BEGIN  result:=1;  Exit;  END;
    dummy:=1;
    FOR i:=1 TO I DO Dummy:=dummy*i;
    result:=dummy;
  end  { Fact };

  function notbin(s: integer): integer;
  var i, c: integer;
  begin
    result := 0;
    c := 1;
//    writeln(s);

    for i := 0 to wid-1 do
    begin
      if (s and c) = 0 then result := result or c;
      c := c shl 1;
    end;
//    notbin := result;
  end;

  function Expression: Real;
  var
    E: Real;
    Opr: Char;

    function SimpleExpression: Real;
    var
      S: Real;
      Opr: Char;

      function Term: Real;
      var
        T: Real;

        function SignedFactor: Real;

          function Factor: Real;
          type
            StandardFunction = (fabs,fsqrt,fsqr,fsin,fcos,
            farctan,fln,flog,fexp,ffact,fPi,fE,fnot,flb,fhb);
            StandardFunctionList = array[StandardFunction] of string[7];

          const
            StandardFunctionNames: StandardFunctionList =('ABS','SQRT','SQR','SIN','COS',
                                                          'ARCTAN','LN','LOG','EXP','FAK','PI','E','NOT','LB','HB');
          var
            L:  Integer;       { intermidiate variables }
            hex,bin,Found:Boolean;
            F: Real;
            Sf:StandardFunction;
            Start:Integer;
            s:string;

          begin { Function Factor }
            F:=0;
            if Ch in Numbers then
            begin
              Start:=Posf; hex:=false; bin:=false;
              repeat NextCh until not (Ch in Numbers);
              if Ch='.' then repeat NextCh until not (upcase(Ch) in Numbers);
              if Ch='E' then
              begin
                NextCh;
                repeat NextCh until not (Ch in Numbers);
              end;
              if Ch='X' then
              begin
                NextCh;
                repeat NextCh until not (Ch in HexNumbers);
                hex:=true;
              end;
              if Ch='B' then
              begin
                NextCh;
                repeat NextCh until not (Ch in BinNumbers);
                bin:=true;
              end;

              s:=Copy(Formula,Start,Posf-Start);
              if hex then F:=converthex(copy(s,3,255))
              else if bin then F:=convertbin(copy(s,3,255))
              else Val(s,F,ErrPosf);
{              if upcase(Ch)='H' then
              begin
                F:=converthex(s)
              end else
              begin
                if pos('B',s) > 0 then F:=convertbin(s)
                else Val(s,F,ErrPosf);
              end;}
            end else
            if Ch='(' then
            begin
              NextCh;
              F:=Expression;
              if Ch=')' then NextCh else ErrPosf:=Posf;
            end else
            begin
              found:=false;
              for sf:=fabs to fhb do
              if not found then
              begin
                l:=Length(StandardFunctionNames[sf]);
                if copy(Formula,Posf,l)=StandardFunctionNames[sf] then
                begin
                  Posf:=Posf+l-1; NextCh;
                  F:=Factor;
//                  writeln(StandardFunctionNames[sf]);
                  case sf of
                    fabs:     f:=abs(f);
                    fsqrt:    f:=sqrt(f);
                    fsqr:     f:=sqr(f);
                    fsin:     f:=sin(f);
                    fcos:     f:=cos(f);
                    farctan:  f:=arctan(f);
                    fln :     f:=ln(f);
                    flog:     f:=ln(f)/ln(10);
                    fexp:     f:=exp(f);
                    ffact:    f:=fakult(trunc(f));
                    fPi:      f:=Pi;
                    fE:       f:=Exp(1);
//                    fX:       f:=X;
                    fnot:     f:=notbin(trunc(f));
                    flb:      f:=trunc(f) and $FF;
                    fhb:      f:=(trunc(f) shr 8) and $FF;
                  end;
                  Found:=true;
                end;
              end;
              if not Found then ErrPosf:=Posf;
            end;
            result:=F;
          end { function Factor};

        begin { SignedFactor }
         if Ch='-' then
          begin
            NextCh; result:=-Factor;
          end
          else if Ch='~' then
          begin
            NextCh; result:=notbin(trunc(Factor));
          end else result:=Factor;
        end { SignedFactor };

      begin { Term }
        T:=SignedFactor;
        while Ch='^' do
        begin
          NextCh; t:=exp(ln(t)*SignedFactor);
        end;
        result:=t;
      end { Term };

    begin { SimpleExpression }
      s:=term;
      while Ch in ['*','/','<','>','%'] do
      begin
        Opr:=Ch;  NextCh;
        case Opr of
          '*': s:=s*term;
          '/': s:=s/term;
          '<': s:=trunc(s) shl trunc(term);
          '>': s:=trunc(s) shr trunc(term);
          '%': s:=trunc(s) mod trunc(term);
        end;
      end;
      result:=s;
    end { SimpleExpression };

  begin { Expression }
    E:=SimpleExpression;
    while Ch in ['+','-','|','&'] do
    begin
      Opr:=Ch; NextCh;
      case Opr of
        '+': e:=e+SimpleExpression;
        '-': e:=e-SimpleExpression;
        '|': e:=trunc(e) or trunc(SimpleExpression);
        '&': e:=trunc(e) and trunc(SimpleExpression);
      end;
    end;
    result:=E;
  end { Expression };


begin { procedure Evaluate }
  {--first make the formula a little easier --}
  if Formula='' then begin Value := 0; ErrPosf := -1; exit; end;

  dummy:='';     { remove all blanks }
  FOR i:=1 TO Length(Formula) DO
    IF Formula[i]<>' ' THEN Dummy:=dummy+Formula[i];

  sumr:=0;  suml:=0;
  FOR i:=1 TO Length(dummy) DO      { brackets ok ? }
     CASE dummy[i] OF
       ',' : dummy[i]:='.';
       '(' : Inc(SumR);
       ')' : Inc(SumL);
        ELSE dummy[i]:=UpCase(dummy[i]);
     END;

{  i:=1;
  repeat
    Inc(i);
    IF (dummy[i]='.') AND NOT (dummy[i-1] IN numbers) THEN
      BEGIN
        Insert('0',dummy,i);  Inc(i);
      END;
  until i>=Length(dummy);
}
  if dummy[1]='.' then Insert('0',dummy,1);
  if dummy[1]='+' then delete(dummy,1,1);

  IF dummy='' THEN
   BEGIN Value:=0;  ErrPosf:=-1;  Exit;  END;
  IF sumR<>sumL THEN
   BEGIN Value:=0;  ErrPosf:=-2;  Exit;  END;

  if (Pos('<<',dummy) > 0) then delete(dummy, Pos('<<',dummy), 1);
  if (Pos('>>',dummy) > 0) then delete(dummy, Pos('>>',dummy), 1);
  Formula:=Dummy;
  Posf:=0; NextCh;
  c := 0;
  for i := 0 to wid-1 do c:=c or (1 shl i);
  Value:=trunc(Expression) and c;
  if Ch=EofLine then ErrPosf:=0 else ErrPosf:=Posf;
end { Evaluate };


begin
end.

