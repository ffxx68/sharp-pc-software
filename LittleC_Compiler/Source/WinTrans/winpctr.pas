unit winpctr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, CPort, ComCtrls;

type
  TForm1 = class(TForm)
    cp: TComPort;
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    pb: TProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cpTxEmpty(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;
  s: string;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  s := memo1.text;
  cp.open;
  pb.Max := length(memo1.text);
  if s <> '' then
     cp.WriteStr(s[1]);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if paramcount >= 2 then
  begin
    if not fileexists(paramstr(2)) then exit;
    Button1.Visible := false;
    height := 40;
    memo1.Lines.LoadFromFile(paramstr(2));
    cp.Port := paramstr(1);
    Button1Click(Form1);
  end;
end;

procedure TForm1.cpTxEmpty(Sender: TObject);
begin
  if s <> '' then
  begin
    while (s <> '') and (s[1] = #10) do
      delete(s, 1, 1);
    if s = '' then
    begin
      if paramcount >= 2 then close;
      exit;
    end;
    cp.WriteStr(s[1]);
    delete(s, 1, 1);
    pb.Position := pb.position + 1;
    application.Title := inttostr(100 * pb.position div pb.max) + '% - WinTrans';
    caption := application.Title;
  end else
  begin
    if paramcount >= 2 then close;
  end;
end;

end.
