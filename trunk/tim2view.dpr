program tim2view;

uses
  FastMM4,
  Vcl.Forms,
  uMain in 'Units\uMain.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Metro Blue');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
