unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.XPMan, Vcl.Grids, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls, NativeXml, uScanThread, uCommon;

type
  TfrmMain = class(TForm)
    btnStopScan: TButton;
    dlgOpenFile: TOpenDialog;
    mmMain: TMainMenu;
    mnFile: TMenuItem;
    mnScanFile: TMenuItem;
    mnScanDir: TMenuItem;
    N1: TMenuItem;
    mnCloseFile: TMenuItem;
    mnCloseAllFiles: TMenuItem;
    mnExit: TMenuItem;
    mnImage: TMenuItem;
    mnTIM: TMenuItem;
    mnReplaceIn: TMenuItem;
    mnHelp: TMenuItem;
    mnHelpFile: TMenuItem;
    N2: TMenuItem;
    mnSVN: TMenuItem;
    mnSite: TMenuItem;
    N3: TMenuItem;
    mnAbout: TMenuItem;
    pbProgress: TProgressBar;
    stbMain: TStatusBar;
    tbcFiles: TTabControl;
    pnlMain: TPanel;
    splMain: TSplitter;
    tvList: TTreeView;
    pgcMain: TPageControl;
    tsInfo: TTabSheet;
    tbInfo: TStringGrid;
    tsImage: TTabSheet;
    pnlImage: TPanel;
    tsClut: TTabSheet;
    xpMain: TXPManifest;
    procedure mnScanFileClick(Sender: TObject);
    procedure stbMainDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure btnStopScanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    pResult: PNativeXml;
    pScanThread: PScanThread;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

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

  pScanThread^.FreeOnTerminate := True;
  pScanThread^.Priority := tpHighest;
  pScanThread^.Start;

  repeat
    Application.ProcessMessages;
  until pScanThread^.Terminated;

  pbProgress.Position := 0;

  stbMain.Panels[0].Text := sStatusBarSavingResults;
  Application.ProcessMessages;

  pResult^.SaveToFile(fResName);
  pResult^.Free;

  Application.MessageBox(sScanResultGood, 'Information', MB_OK +
    MB_ICONINFORMATION + MB_TOPMOST);

  stbMain.Panels[0].Text := '';
  Application.ProcessMessages;

  Dispose(pResult);
  Dispose(pScanThread);
end;

procedure TfrmMain.stbMainDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
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

end.
