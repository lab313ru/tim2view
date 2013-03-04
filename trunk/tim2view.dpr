program tim2view;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  ecc in 'units\ecc.pas',
  edc in 'units\edc.pas',
  uCDIMAGE in 'units\uCDIMAGE.pas',
  uCommon in 'Units\uCommon.pas',
  uMain in 'Units\uMain.pas' {frmMain},
  uScanThread in 'Units\uScanThread.pas',
  uTIM in 'units\uTIM.pas',
  uDrawTIM in 'units\uDrawTIM.pas',
  BrowseForFolderU in 'units\BrowseForFolderU.pas' {,
  uTIMClass in 'units\uTIMClass.pas'},
  uTIMClass in 'units\uTIMClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
