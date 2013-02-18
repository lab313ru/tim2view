program timview2;

uses
  FastMM4,
  Forms,
  uMain in 'units\uMain.pas' {frmMain},
  uTIM in 'units\uTIM.pas',
  uCommon in 'units\uCommon.pas',
  uScanThread in 'units\uScanThread.pas',
  uCDIMAGE in 'units\uCDIMAGE.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
