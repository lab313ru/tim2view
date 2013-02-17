unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, ComCtrls, XPMan, Grids, ecc, edc, dglOpenGL,
  uScanThread, uCommon, NativeXml;

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
    procedure FormResize(Sender: TObject);
    procedure mnScanFileClick(Sender: TObject);
    procedure stbMainDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    pResult: PNativeXML;
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
  ScanThread: TScanThread;
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

  pResult^ := TNativeXML.Create(nil);

  ScanThread := TScanThread.Create(fScanName, pResult);
  ScanThread.FreeOnTerminate := True;
  ScanThread.Priority := tpHighest;
  ScanThread.Resume;

  repeat
    Application.ProcessMessages;
  until ScanThread.Terminated;

  stbMain.Panels[0].Text := sStatusBarSavingResults;
  Application.ProcessMessages;

  pResult^.SaveToFile(fResName);
  pResult^.Free;

  stbMain.Panels[0].Text := '';
  Application.ProcessMessages;

  
end;

procedure TfrmMain.stbMainDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  if Panel = stbMain.Panels[1] then
    with pbProgress do
    begin
      Top := Rect.Top;
      Left := Rect.Left;
      Width := Rect.Right - Rect.Left - 15;
      Height := Rect.Bottom - Rect.Top;
    end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  pbProgressStyle: integer;
begin
  pbProgress.Parent := stbMain;
  pbProgressStyle := GetWindowLong(pbProgress.Handle, GWL_EXSTYLE) -
    WS_EX_STATICEDGE;
  SetWindowLong(pbProgress.Handle, GWL_EXSTYLE, pbProgressStyle);

  New(pResult);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Dispose(pResult);
end;

end.

