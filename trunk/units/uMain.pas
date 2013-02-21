unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.XPMan, Vcl.Grids, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls, NativeXml, uScanThread, uCommon,
  Vcl.CheckLst, Winapi.ShellAPI, uDrawTIM, Vcl.ExtDlgs, uTIM;

type
  TfrmMain = class(TForm)
    dlgOpenFile: TOpenDialog;
    mmMain: TMainMenu;
    mnFile: TMenuItem;
    mnScanFile: TMenuItem;
    mnScanDir: TMenuItem;
    N1: TMenuItem;
    mnCloseFile: TMenuItem;
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
    mnConfig: TMenuItem;
    mnAutoExtract: TMenuItem;
    tbcMain: TTabControl;
    pnlMain: TPanel;
    splMain: TSplitter;
    pgcMain: TPageControl;
    tsInfo: TTabSheet;
    tbInfo: TStringGrid;
    tsImage: TTabSheet;
    pnlImage: TPaintBox;
    tsClut: TTabSheet;
    grdCLUT: TDrawGrid;
    pnlList: TPanel;
    lvList: TListView;
    xpMain: TXPManifest;
    pnlStatus: TPanel;
    lblStatus: TLabel;
    btnStopScan: TButton;
    mnCloseAllFiles: TMenuItem;
    mnSaveToPNG: TMenuItem;
    dlgSavePNG: TSavePictureDialog;
    mnSaveTIM: TMenuItem;
    dlgSaveTIM: TSaveDialog;
    procedure mnScanFileClick(Sender: TObject);
    procedure btnStopScanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure mnCloseFileClick(Sender: TObject);
    procedure lvListClick(Sender: TObject);
    procedure lvListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tbcMainChange(Sender: TObject);
    procedure mnCloseAllFilesClick(Sender: TObject);
    procedure mnScanDirClick(Sender: TObject);
    procedure mnSaveToPNGClick(Sender: TObject);
    procedure mnReplaceInClick(Sender: TObject);
    procedure mnSaveTIMClick(Sender: TObject);
  private
    { Private declarations }
    //pResult: PNativeXml;
    Results: array[0..cMaxFilesToOpen - 1] of PNativeXML;
    pScanThread: PScanThread;
    pCurrentPNG: PPNGImage;
    procedure ParseResult(Res: PNativeXML);
    procedure ScanFinished(Sender: TObject);
    function CheckForFileOpened(const FileName: string): boolean;
    procedure CheckMainMenu;
    procedure ScanPath(const Path: string);
    procedure ScanFile(const FileName: string);
    procedure ScanDirectory(const Directory: string);
    function CurrentFileName: string;
    function CurrentTimPos(Index: Integer): DWORD;
    function CurrentTimSize(Index: Integer): DWORD;
    function CurrentTimBitMode(Index: Integer): Byte;
    function CurrentTimWidth(Index: Integer): Word;
    function CurrentTimHeight(Index: Integer): Word;
    function CurrentFileIsImage: Boolean;
    function CurrentTIM: PTIM;
    function CurrentTIMName(Index: Integer): string;
  protected
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uCDIMAGE, Vcl.FileCtrl;

{$R *.dfm}

procedure TfrmMain.btnStopScanClick(Sender: TObject);
begin
  if pScanThread = nil then Exit;

  pScanThread^.StopScan := True;
end;

function TfrmMain.CheckForFileOpened(const FileName: string): boolean;
begin
  Result := (tbcMain.Tabs.IndexOf(ExtractFileName(FileName)) <> -1);
end;

procedure TfrmMain.CheckMainMenu;
begin
  mnCloseFile.Enabled := (tbcMain.Tabs.Count <> 0);
  mnCloseAllFiles.Enabled := (tbcMain.Tabs.Count <> 0);
  mnSaveToPNG.Enabled := (pCurrentPNG^ <> nil);
  mnReplaceIn.Enabled := (lvList.SelCount = 1);
  mnSaveTIM.Enabled := (lvList.SelCount = 1);
end;

function TfrmMain.CurrentTIM: PTIM;
var
  OFFSET, SIZE: DWORD;
begin
  OFFSET := CurrentTimPos(lvList.Selected.Index);
  SIZE := CurrentTimSize(lvList.Selected.Index);
  Result := LoadTimFromFile(CurrentFileName, OFFSET, CurrentFileIsImage, SIZE);
end;

function TfrmMain.CurrentTimBitMode(Index: Integer): Byte;
var
  Node: TXmlNode;
begin
  Node := Results[tbcMain.TabIndex]^.Root.FindNode(cResultsTimsNode);
  Node := Node.Elements[Index];
  result := Node.ReadAttributeInteger(cResultsTimAttributeBitMode);
end;

function TfrmMain.CurrentTimHeight(Index: Integer): Word;
var
  Node: TXmlNode;
begin
  Node := Results[tbcMain.TabIndex]^.Root.FindNode(cResultsTimsNode);
  Node := Node.Elements[Index];
  result := cHex2Int(Node.ReadAttributeString(cResultsTimAttributeHeight));
end;


function TfrmMain.CurrentTIMName(Index: Integer): string;
begin
  Result := Format(cAutoExtractionTimFormat,
                   [ExtractFileNameWOext(CurrentFileName),
                    CurrentTimBitMode(Index), Index + 1]);
end;

function TfrmMain.CurrentTimWidth(Index: Integer): Word;
var
  Node: TXmlNode;
begin
  Node := Results[tbcMain.TabIndex]^.Root.FindNode(cResultsTimsNode);
  Node := Node.Elements[Index];
  result := cHex2Int(Node.ReadAttributeString(cResultsTimAttributeWidth));
end;

function TfrmMain.CurrentFileIsImage: boolean;
var
  Node: TXmlNode;
begin
  Node := Results[tbcMain.TabIndex]^.Root.FindNode(cResultsInfoNode);
  Result := Node.ReadAttributeBool(cResultsAttributeImageFile);
end;

function TfrmMain.CurrentFileName: string;
var
  Node: TXmlNode;
begin
  Node := Results[tbcMain.TabIndex]^.Root.FindNode(cResultsInfoNode);
  Result := Node.ReadAttributeString(cResultsAttributeFile);
end;

function TfrmMain.CurrentTimPos(Index: Integer): DWORD;
var
  Node: TXmlNode;
begin
  Node := Results[tbcMain.TabIndex]^.Root.FindNode(cResultsTimsNode);
  Node := Node.Elements[Index];
  result := cHex2Int(Node.ReadAttributeString(cResultsTimAttributePos));
end;

function TfrmMain.CurrentTimSize(Index: Integer): DWORD;
var
  Node: TXmlNode;
begin
  Node := Results[tbcMain.TabIndex]^.Root.FindNode(cResultsTimsNode);
  Node := Node.Elements[Index];
  result := cHex2Int(Node.ReadAttributeString(cResultsTimAttributeSize));
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  New(pScanThread);
  New(pCurrentPNG);
  pCurrentPNG^ := nil;
  Caption := cProgramName;
  DragAcceptFiles(Handle, True);
  CheckMainMenu;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  mnCloseAllFilesClick(Self);
  Dispose(pScanThread);
  if pCurrentPNG^ <> nil then
    pCurrentPNG^.Free;
  Dispose(pCurrentPNG);
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

  lvListClick(Self);
end;

procedure TfrmMain.ScanDirectory(const Directory: string);
var
  sRec: TSearchRec;
  isFound: boolean;
  Dir: string;
begin
  Dir := IncludeTrailingPathDelimiter(Directory);
  isFound := FindFirst( Dir + '*.*', faAnyFile, sRec ) = 0;
  while isFound do
  begin
    if ( sRec.Name <> '.' ) and ( sRec.Name <> '..' ) then
    begin
      if ( sRec.Attr and faDirectory ) = faDirectory then
      ScanDirectory(Dir + sRec.Name);

      ScanFile(Dir + sRec.Name);
    end;
    Application.ProcessMessages;
    isFound := FindNext( sRec ) = 0;
  end;
  FindClose( sRec );
end;

procedure TfrmMain.lvListClick(Sender: TObject);
var
  OFFSET: DWORD;
  TIM: PTIM;
begin
  if lvList.Items.Count = 0 then Exit;

  if pCurrentPNG^ <> nil then
  begin
    pCurrentPNG^.Free;
    pCurrentPNG^ := nil;
  end;

  lvList.Column[0].Caption := Format('# (%d)', [lvList.Selected.Index + 1]);

  OFFSET := CurrentTimPos(lvList.Selected.Index);
  TIM := CurrentTIM;
  DrawTIM(TIM, @pnlImage.Canvas, pnlImage.ClientRect, pCurrentPNG);
  FreeTIM(TIM);
  lblStatus.Caption := IntToHex(OFFSET, 8);
  CheckMainMenu;
end;

procedure TfrmMain.lvListData(Sender: TObject; Item: TListItem);
begin
  if tbcMain.TabIndex = -1 then Exit;
  if Results[tbcMain.TabIndex] = nil then Exit;

  Item.Caption := Format('%.6d', [Item.Index + 1]);
  Item.SubItems.Add(Format('%dx%d',
                           [CurrentTimWidth(Item.Index),
                            CurrentTimHeight(Item.Index)]));
  Item.SubItems.Add(Format('%d', [CurrentTimBitMode(Item.Index)]));
end;

procedure TfrmMain.lvListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (lvList.Items.Count = 0) or (lvList.Selected.Index = -1) then Exit;


  if (Key = VK_DOWN) and ((lvList.Selected.Index + 1)<>lvList.Items.Count) then
  begin
    lvList.Items[lvList.Selected.Index + 1].Selected := True;
    lvListClick(Self);
    Exit;
  end;

  if (Key = VK_UP) and (lvList.Selected.Index <> 0) then
  begin
    lvList.Items[lvList.Selected.Index - 1].Selected := True;
    lvListClick(Self);
  end;
end;

procedure TfrmMain.mnCloseAllFilesClick(Sender: TObject);
begin
  while tbcMain.Tabs.Count > 0 do
  begin
    tbcMain.TabIndex := tbcMain.Tabs.Count - 1;
    mnCloseFileClick(Self);
  end;
end;

procedure TfrmMain.mnCloseFileClick(Sender: TObject);
begin
  Results[tbcMain.TabIndex]^.Free;
  Dispose(Results[tbcMain.TabIndex]);
  lvList.Items.BeginUpdate;
  lvList.Items.Count := 0;
  lvList.Items.EndUpdate;
  lvList.Column[0].Caption := '#';
  lblStatus.Caption := '';
  tbcMain.Tabs.Delete(tbcMain.TabIndex);
  CheckMainMenu;
end;

procedure TfrmMain.mnReplaceInClick(Sender: TObject);
begin
  if not dlgOpenFile.Execute then Exit;

  if GetFileSizeAPI(dlgOpenFile.FileName) > cTIMMaxSize then Exit;

  ReplaceTimInFile(CurrentFileName, dlgOpenFile.FileName,
                   CurrentTimPos(lvList.Selected.Index), CurrentFileIsImage);
  MessageBeep(MB_ICONASTERISK);
  lvListClick(Self);
end;

procedure TfrmMain.mnSaveTIMClick(Sender: TObject);
var
  TIM: PTIM;
begin
  dlgSaveTIM.FileName := CurrentTIMName(lvList.Selected.Index);

  if not dlgSaveTIM.Execute then Exit;

  TIM := CurrentTIM;
  SaveTimToFile(dlgSaveTIM.FileName, TIM);
  FreeTIM(TIM);
  MessageBeep(MB_ICONASTERISK);
end;

procedure TfrmMain.mnSaveToPNGClick(Sender: TObject);
var
  FName: string;
begin
  FName := CurrentTIMName(lvList.Selected.Index);
  FName := ChangeFileExt(FName, '.png');
  dlgSavePNG.FileName := FName;

  if not dlgSavePNG.Execute then Exit;

  pCurrentPNG^.SaveToFile(dlgSavePNG.FileName);
end;

procedure TfrmMain.mnScanDirClick(Sender: TObject);
var
  SelectedDir: string;
begin
  if SelectDirectory('Please, select directory for scan...', '\', SelectedDir,
                     [], frmMain)
  then
    ScanPath(SelectedDir);
end;

procedure TfrmMain.mnScanFileClick(Sender: TObject);
begin
  if not dlgOpenFile.Execute then
    Exit;

  ScanPath(dlgOpenFile.FileName);
  MessageBeep(MB_ICONASTERISK);
end;

procedure TfrmMain.ParseResult(Res: PNativeXML);
var
  COUNT: integer;
  I: Integer;
  Node, TIM_NODE: TXmlNode;
  TIM: PTIM;
  OFFSET, SIZE: DWORD;
  fName, TIM_NAME: string;
  BIT_MODE: Byte;
  IMAGE_SCAN: Boolean;
begin
  Node := Res^.Root.FindNode(cResultsInfoNode);
  COUNT := Node.ReadAttributeInteger(cResultsAttributeTimsCount);
  lvList.Items.Count := COUNT;

  if not mnAutoExtract.Checked then Exit;

  lblStatus.Caption := sStatusBarTimsExtracting;
  pbProgress.Max := COUNT;
  pbProgress.Position := 0;

  fName := Node.ReadAttributeString(cResultsAttributeFile);
  IMAGE_SCAN := Node.ReadAttributeBool(cResultsAttributeImageFile);
  Node := Res^.Root.FindNode(cResultsTimsNode);

  for I := 1 to COUNT do
  begin
    TIM_NODE := Node.Elements[I - 1];
    OFFSET := cHex2Int(TIM_NODE.ReadAttributeString(cResultsTimAttributePos));
    SIZE := cHex2Int(TIM_NODE.ReadAttributeString(cResultsTimAttributeSize));
    BIT_MODE := TIM_NODE.ReadAttributeInteger(cResultsTimAttributeBitMode);

    TIM_NAME := Format(cAutoExtractionTimFormat,
                       [ExtractFileNameWOext(fName), BIT_MODE, I]);

    CreateDir(GetStartDir + cExtractedTimsDir);

    TIM := LoadTimFromFile(fName, OFFSET, IMAGE_SCAN, SIZE);
    SaveTimToFile(GetStartDir + cExtractedTimsDir + TIM_NAME, TIM);
    FreeTIM(TIM);

    pbProgress.Position := I - 1;
    Application.ProcessMessages;
  end;

  pbProgress.Position := 0;
end;

procedure TfrmMain.ScanFile(const FileName: string);
var
  CurrentResult: PNativeXML;
begin
  btnStopScan.Enabled := True;
  tbcMain.Enabled := False;

  if CheckForFileOpened(FileName) then
  begin
    tbcMain.TabIndex := tbcMain.Tabs.IndexOf(ExtractFileName(FileName));
    btnStopScan.Enabled := False;
    tbcMain.Enabled := True;
    Exit;
  end;

  tbcMain.Tabs.Add(ExtractFileName(FileName));
  tbcMain.TabIndex := tbcMain.Tabs.Count - 1;

  pbProgress.Max := GetFileSizeAPI(FileName);
  pbProgress.Position := 0;

  New(Results[tbcMain.Tabs.Count - 1]);
  CurrentResult := Results[tbcMain.Tabs.Count - 1];
  CurrentResult^ := TNativeXML.CreateName(cResultsRootName);
  pScanThread^ := TScanThread.Create(FileName, 0, CurrentResult,
                                     GetImageScan(FileName));
  pScanThread^.FreeOnTerminate := True;
  pScanThread^.Priority := tpNormal;
  pScanThread^.OnTerminate := ScanFinished;
  pScanThread^.Start;

  repeat
    Application.ProcessMessages;
  until pScanThread^.Terminated;

  ParseResult(CurrentResult);

  lblStatus.Caption := '';
  tbcMain.Enabled := True;
end;


procedure TfrmMain.ScanFinished(Sender: TObject);
begin
  btnStopScan.Enabled := False;
  CheckMainMenu;
end;

procedure TfrmMain.ScanPath(const Path: string);
begin
  if CheckFileExists(Path) then
    ScanFile(Path)
  else
    ScanDirectory(Path);
end;

procedure TfrmMain.tbcMainChange(Sender: TObject);
var
  Node: TXmlNode;
begin
  Node := Results[tbcMain.TabIndex]^.Root.FindNode(cResultsInfoNode);
  lvList.Items.Count := Node.ReadAttributeInteger(cResultsAttributeTimsCount);
  lvList.Invalidate;
end;

procedure TfrmMain.WMDropFiles(var Msg: TWMDropFiles);
var
  i: integer;
  CountFile: integer;
  size: integer;
  Filename: PChar;
begin
  Filename := nil;
  try
    CountFile := DragQueryFile(Msg.Drop, $FFFFFFFF, Filename, 1024);

    for i := 0 to (CountFile - 1) do
    begin
      size := DragQueryFile(Msg.Drop, i, nil, 0) + 1;
      Filename:= StrAlloc(size);
      DragQueryFile(Msg.Drop, i, Filename, size);
      ScanPath(StrPas(Filename));
      StrDispose(Filename);
    end;
    MessageBeep(MB_ICONASTERISK);
  finally
    DragFinish(Msg.Drop);
  end;

end;

end.
