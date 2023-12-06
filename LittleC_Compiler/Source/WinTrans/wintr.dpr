program wintr;

uses
  Forms,
  winpctr in 'winpctr.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'WinTrans';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
