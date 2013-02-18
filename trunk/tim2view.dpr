program tim2view;

uses
  FastMM4,
  Vcl.Forms,
  uMain in 'Units\uMain.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles,
  uTIM in 'units\uTIM.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Metropolis UI Blue');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
