program tim2view;

uses
  FastMM4,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  crc32 in 'units\crc32.pas',
  ecc in 'units\ecc.pas',
  edc in 'units\edc.pas',
  uCDIMAGE in 'units\uCDIMAGE.pas',
  uCommon in 'Units\uCommon.pas',
  uMain in 'Units\uMain.pas' {frmMain},
  uScanThread in 'Units\uScanThread.pas',
  uTIM in 'units\uTIM.pas',
  uDrawTIM in 'units\uDrawTIM.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
