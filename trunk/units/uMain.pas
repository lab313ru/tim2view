unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, ComCtrls, XPMan, Grids, ecc, edc, dglOpenGL,
  uScanThread, uCommon, Vcl.StdCtrls, NativeXml;

type
  TfrmMain = class(TForm)
    mmMain: TMainMenu;
    mnFile: TMenuItem;
    mnImage: TMenuItem;
    mnTIM: TMenuItem;
    mnHelp: TMenuItem;
    pnlMain: TPanel;
    tvList: TTreeView;
    splMain: TSplitter;
    pgcMain: TPageControl;
    tsInfo: TTabSheet;
    tsImage: TTabSheet;
    tsClut: TTabSheet;
    xpMain: TXPManifest;
    tbInfo: TStringGrid;
    mnScanFile: TMenuItem;
    mnScanDir: TMenuItem;
    N1: TMenuItem;
    tbcFiles: TTabControl;
    mnCloseFile: TMenuItem;
    mnExit: TMenuItem;
    mnCloseAllFiles: TMenuItem;
    dlgOpenFile: TOpenDialog;
    stbMain: TStatusBar;
    pbProgress: TProgressBar;
    btnStopScan: TButton;
    procedure FormResize(Sender: TObject);
    procedure mnScanFileClick(Sender: TObject);
    procedure stbMainDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure FormCreate(Sender: TObject);
    procedure btnStopScanClick(Sender: TObject);
  private
    { Private declarations }
    pResult: ^TNativeXml;
    pScanThread: ^TScanThread;
    procedure ScanTerminated(Sender: TObject);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormResize(Sender: TObject);
var
  w, i, x: integer;
begin
  x := 0;
  if (GetWindowlong(tbInfo.Handle, GWL_STYLE) and WS_VSCROLL) <> 0 then
    x := GetSystemMetrics(SM_CXVSCROLL);

  w := (tbInfo.Width - X - 5) div tbInfo.ColCount;

  for i := 1 to tbInfo.ColCount do
    tbInfo.ColWidths[i - 1] := w;
end;

procedure TfrmMain.mnScanFileClick(Sender: TObject);
var
  //ScanThread: TScanThread;
  fScanName, fResName: string;
begin
  if dlgOpenFile.InitialDir = '' then
    dlgOpenFile.InitialDir := GetStartDir;

  if not dlgOpenFile.Execute then
    Exit;

  fScanName := dlgOpenFile.FileName;

  if not DirectoryExists(GetStartDir + cResultsDir) then
    CreateDir(GetStartDir + cResultsDir);

  pbProgress.Max := GetFileSZ(fScanName);
  pbProgress.Position := 0;

  fResName := ChangeFileExt(GetStartDir + cResultsDir +
    ExtractFileName(fScanName), '.tsr');

  New(pResult);
  New(pScanThread);

  pResult^ := TNativeXML.Create(nil);
  pScanThread^ := TScanThread.Create(fScanName, pResult);

  //ScanThread := TScanThread.Create(fScanName, pResult);
  pScanThread^.FreeOnTerminate := True;
  pScanThread^.OnTerminate := ScanTerminated;
  pScanThread^.Priority := tpHighest;
  pScanThread^.Resume;

  repeat
    Application.ProcessMessages;
  until pScanThread^.Terminated;

  stbMain.Panels[0].Text := sStatusBarSavingResults;
  Application.ProcessMessages;

  pResult^.SaveToFile(fResName);
  pResult^.Free;

  stbMain.Panels[0].Text := '';
  Application.ProcessMessages;

  Dispose(pResult);
  Dispose(pScanThread);
end;

procedure TfrmMain.ScanTerminated(Sender: TObject);
begin
  Application.MessageBox(sScanResultGood, 'Information', MB_OK +
    MB_ICONINFORMATION + MB_TOPMOST);
  pbProgress.Position := 0;
end;

procedure TfrmMain.stbMainDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  if Panel = stbMain.Panels[1] then
  begin
    pbProgress.Top := Rect.Top;
    pbProgress.Left := Rect.Left;
    pbProgress.Width := Rect.Right - Rect.Left - btnStopScan.Width - 15;
    pbProgress.Height := Rect.Bottom - Rect.Top;

    btnStopScan.Top := Rect.Top;
    btnStopScan.Left := Rect.Left + pbProgress.Width;
    btnStopScan.Height := Rect.Bottom - Rect.Top;
  end;
end;

procedure TfrmMain.btnStopScanClick(Sender: TObject);
begin
  if pScanThread = nil then Exit;

  pScanThread^.StopScan := True;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  Style: integer;
begin
  pbProgress.Parent := stbMain;
  Style := GetWindowLong(pbProgress.Handle, GWL_EXSTYLE) - WS_EX_STATICEDGE;
  SetWindowLong(pbProgress.Handle, GWL_EXSTYLE, Style);

  btnStopScan.Parent := stbMain;
  Style := GetWindowLong(btnStopScan.Handle, GWL_EXSTYLE) - WS_EX_STATICEDGE;
  SetWindowLong(btnStopScan.Handle, GWL_EXSTYLE, Style);
end;

end.

