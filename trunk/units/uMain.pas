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
    xpMain: TXPManifest;
    pnlStatus: TPanel;
    lblStatus: TLabel;
    btnStopScan: TButton;
    mnCloseAllFiles: TMenuItem;
    mnSaveToPNG: TMenuItem;
    dlgSavePNG: TSavePictureDialog;
    mnSaveTIM: TMenuItem;
    dlgSaveTIM: TSaveDialog;
    cbbFiles: TComboBox;
    pnlMain: TPanel;
    splMain: TSplitter;
    pgcMain: TPageControl;
    tsInfo: TTabSheet;
    tblInfo: TStringGrid;
    tsImage: TTabSheet;
    pbImage: TPaintBox;
    pnlList: TPanel;
    lvList: TListView;
    pnlTimInfo: TPanel;
    pnlImageOptions: TPanel;
    cbbCLUT: TComboBox;
    cbbTransparenceMode: TComboBox;
    grdCurrCLUT: TDrawGrid;
    splImageClut: TSplitter;
    procedure mnScanFileClick(Sender: TObject);
    procedure btnStopScanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure mnCloseFileClick(Sender: TObject);
    procedure lvListClick(Sender: TObject);
    procedure lvListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mnCloseAllFilesClick(Sender: TObject);
    procedure mnScanDirClick(Sender: TObject);
    procedure mnSaveToPNGClick(Sender: TObject);
    procedure mnReplaceInClick(Sender: TObject);
    procedure mnSaveTIMClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lblStatusClick(Sender: TObject);
    procedure lblStatusMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure mnExitClick(Sender: TObject);
    procedure cbbFilesChange(Sender: TObject);
    procedure pbImagePaint(Sender: TObject);
    procedure cbbCLUTChange(Sender: TObject);
    procedure chkTransparenceClick(Sender: TObject);
    procedure cbbTransparenceModeClick(Sender: TObject);
    procedure grdCurrCLUTDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
    //pResult: PNativeXml;
    Results: array of PNativeXML;
    pScanThread: PScanThread;
    pCurrentPNG: PPNGImage;
    pLastDir: string;
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
    procedure DrawCurrentTIM;
    procedure DrawCurrentCLUT;
    procedure UpdateCLUTList;
  protected
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uCDIMAGE, BrowseForFolderU;

{$R *.dfm}

procedure TfrmMain.btnStopScanClick(Sender: TObject);
begin
  if pScanThread = nil then Exit;

  pScanThread^.StopScan := True;
end;

procedure TfrmMain.cbbFilesChange(Sender: TObject);
var
  Node: TXmlNode;
begin
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResInfoNode);
  if Node = nil then Exit;

  lvList.Items.Count := Node.ReadAttributeInteger(cResAttrTimsCount);
  lvList.Invalidate;
end;

procedure TfrmMain.cbbCLUTChange(Sender: TObject);
begin
  DrawCurrentTIM;
  DrawCurrentCLUT;
end;

procedure TfrmMain.cbbTransparenceModeClick(Sender: TObject);
begin
  DrawCurrentTIM;
end;

function TfrmMain.CheckForFileOpened(const FileName: string): boolean;
begin
  Result := (cbbFiles.Items.IndexOf(ExtractFileName(FileName)) <> -1);
end;

procedure TfrmMain.CheckMainMenu;
begin
  mnCloseFile.Enabled := (cbbFiles.Items.Count <> 0);
  mnCloseAllFiles.Enabled := (cbbFiles.Items.Count <> 0);
  mnSaveToPNG.Enabled := (pCurrentPNG^ <> nil);
  mnReplaceIn.Enabled := (lvList.SelCount = 1);
  mnSaveTIM.Enabled := (lvList.SelCount = 1);
end;

procedure TfrmMain.chkTransparenceClick(Sender: TObject);
begin
  DrawCurrentTIM;
end;

function TfrmMain.CurrentTIM: PTIM;
var
  OFFSET, SIZE: DWORD;
begin
  Result := nil;

  if lvList.Selected = nil then Exit;

  OFFSET := CurrentTimPos(lvList.Selected.Index);
  SIZE := CurrentTimSize(lvList.Selected.Index);
  Result := LoadTimFromFile(CurrentFileName, OFFSET, CurrentFileIsImage, SIZE);
end;

function TfrmMain.CurrentTimBitMode(Index: Integer): Byte;
var
  Node: TXmlNode;
begin
  result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then Exit;

  Node := Node.Elements[Index];
  result := Node.ReadAttributeInteger(cResTimAttrBitMode);
end;

function TfrmMain.CurrentTimHeight(Index: Integer): Word;
var
  Node: TXmlNode;
begin
  result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then Exit;

  Node := Node.Elements[Index];
  result := cHex2Int(Node.ReadAttributeUnicodeString(cResTimAttrHeight));
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
  result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then Exit;

  Node := Node.Elements[Index];
  result := cHex2Int(Node.ReadAttributeUnicodeString(cResTimAttrWidth));
end;

procedure TfrmMain.DrawCurrentCLUT;
var
  TIM: PTIM;
begin
  ClearGrid(@grdCurrCLUT);

  TIM := CurrentTIM;
  if TIM = nil then Exit;

  if isTIMHasCLUT(TIM) then
    DrawCLUT(TIM, cbbCLUT.ItemIndex, @grdCurrCLUT);

  FreeTIM(TIM);
end;

procedure TfrmMain.DrawCurrentTIM;
var
  TIM: PTIM;
begin
  ClearCanvas(pbImage.Canvas.Handle, pbImage.ClientRect);
  TIM := CurrentTIM;
  if TIM = nil then Exit;

  if pCurrentPNG^ <> nil then
  begin
    pCurrentPNG^.Free;
    pCurrentPNG^ := nil;
  end;

  DrawTIM(TIM, cbbCLUT.ItemIndex, @pbImage.Canvas, pbImage.ClientRect,
          pCurrentPNG, cbbTransparenceMode.ItemIndex);

  FreeTIM(TIM);
end;

function TfrmMain.CurrentFileIsImage: boolean;
var
  Node: TXmlNode;
begin
  result := False;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResInfoNode);
  if Node = nil then Exit;

  Result := Node.ReadAttributeBool(cResAttrImageFile);
end;

function TfrmMain.CurrentFileName: string;
var
  Node: TXmlNode;
begin
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResInfoNode);
  if Node = nil then Exit;

  Result := Node.ReadAttributeUnicodeString(cResAttrFile);
end;

function TfrmMain.CurrentTimPos(Index: Integer): DWORD;
var
  Node: TXmlNode;
begin
  result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then Exit;

  Node := Node.Elements[Index];
  result := cHex2Int(Node.ReadAttributeUnicodeString(cResTimAttrPos));
end;

function TfrmMain.CurrentTimSize(Index: Integer): DWORD;
var
  Node: TXmlNode;
begin
  result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then Exit;

  Node := Node.Elements[Index];
  result := cHex2Int(Node.ReadAttributeUnicodeString(cResTimAttrSize));
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  mnCloseAllFilesClick(Self);
  Dispose(pScanThread);
  if pCurrentPNG^ <> nil then
    pCurrentPNG^.Free;
  Dispose(pCurrentPNG);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  New(pScanThread);
  New(pCurrentPNG);
  pCurrentPNG^ := nil;
  pLastDir := GetStartDir;
  Caption := Format('%s v%s', [cProgramName, cProgramVersion]);
  DragAcceptFiles(Handle, True);
  CheckMainMenu;
end;

procedure TfrmMain.FormResize(Sender: TObject);
var
  w, i, x: integer;
begin
  x := 0;
  if (GetWindowlong(tblInfo.Handle, GWL_STYLE) and WS_VSCROLL) <> 0 then
    x := GetSystemMetrics(SM_CXVSCROLL);

  w := (tblInfo.Width - X - 5) div tblInfo.ColCount;

  for i := 1 to tblInfo.ColCount do
    tblInfo.ColWidths[i - 1] := w;

  w := (grdCurrCLUT.Width - 20) div grdCurrCLUT.ColCount;

  for i := 1 to grdCurrCLUT.ColCount do
    grdCurrCLUT.ColWidths[i - 1] := w;
end;

procedure TfrmMain.grdCurrCLUTDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  TIM: PTIM;
  ROWS, COLS: Integer;
  COLORS: Word;
begin
  TIM := CurrentTIM;
  if TIM = nil then Exit;

  COLS := grdCurrCLUT.ColCount;
  ROWS := GetTimColorsCount(TIM) div COLS + 1;
  COLORS := GetTimColorsCount(TIM);

  if ((ARow * COLS + ACol + 1) > COLORS) or ((ARow + 1) > ROWS) then
  begin
    FreeTIM(TIM);
    Exit;
  end;

  DrawClutCell(TIM, cbbCLUT.ItemIndex, @grdCurrCLUT, ACol, ARow);

  FreeTIM(TIM);
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
      ScanPath(Dir + sRec.Name);
    end;
    Application.ProcessMessages;
    isFound := FindNext( sRec ) = 0;
  end;
  FindClose( sRec );
end;

procedure TfrmMain.lblStatusClick(Sender: TObject);
begin
  if lblStatus.Caption <> '' then
    Text2Clipboard(lblStatus.Caption);
end;

procedure TfrmMain.lblStatusMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if lblStatus.Caption <> '' then
    lblStatus.Cursor := crHandPoint
  else
    lblStatus.Cursor := crDefault;
end;

procedure TfrmMain.lvListClick(Sender: TObject);
var
  OFFSET, SIZE: DWORD;
begin
  if (lvList.Selected = nil) then Exit;

  OFFSET := CurrentTimPos(lvList.Selected.Index);
  SIZE := CurrentTimSize(lvList.Selected.Index);
  UpdateCLUTList;
  DrawCurrentTIM;
  DrawCurrentCLUT;
  pnlTimInfo.Caption := Format('Position: %8.x; Size: %d', [OFFSET, SIZE]);
  CheckMainMenu;
end;

procedure TfrmMain.lvListData(Sender: TObject; Item: TListItem);
begin
  if cbbFiles.ItemIndex = -1 then Exit;
  if Results[cbbFiles.ItemIndex] = nil then Exit;

  Item.Caption := Format('%.6d', [Item.Index + 1]);
  Item.SubItems.Add(Format('%dx%d',
                           [CurrentTimWidth(Item.Index),
                            CurrentTimHeight(Item.Index)]));
  Item.SubItems.Add(Format('%d', [CurrentTimBitMode(Item.Index)]));
end;

procedure TfrmMain.lvListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (lvList.Selected = nil) then Exit;


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
  while cbbFiles.Items.Count > 0 do
  begin
    cbbFiles.ItemIndex := cbbFiles.Items.Count - 1;
    mnCloseFileClick(Self);
  end;
end;

procedure TfrmMain.mnCloseFileClick(Sender: TObject);
begin
  Results[cbbFiles.ItemIndex]^.Free;
  Dispose(Results[cbbFiles.ItemIndex]);
  SetLength(Results, Length(Results) - 1);
  lvList.Items.BeginUpdate;
  lvList.Items.Count := 0;
  lvList.Items.EndUpdate;
  lblStatus.Caption := '';
  pnlTimInfo.Caption := '';
  DrawCurrentTIM;
  DrawCurrentCLUT;

  cbbCLUT.Items.BeginUpdate;
  if cbbCLUT.Items.Count > 0 then
  cbbCLUT.Items.Delete(cbbCLUT.ItemIndex);
  cbbCLUT.Items.EndUpdate;

  cbbFiles.Items.BeginUpdate;
  cbbFiles.Items.Delete(cbbFiles.ItemIndex);
  cbbFiles.Items.EndUpdate;

  CheckMainMenu;
end;

procedure TfrmMain.mnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.mnReplaceInClick(Sender: TObject);
begin
  if not dlgOpenFile.Execute then Exit;

  if GetFileSizeAPI(dlgOpenFile.FileName) > cTIMMaxSize then Exit;

  ReplaceTimInFile(CurrentFileName, dlgOpenFile.FileName,
                   CurrentTimPos(lvList.Selected.Index), CurrentFileIsImage);
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
  SelectedDir := BrowseForFolder(Handle, sSelectDirCaption, pLastDir);
  if DirectoryExists(SelectedDir) then
  begin
    ScanPath(SelectedDir);
    pLastDir := SelectedDir;
  end;
end;

procedure TfrmMain.mnScanFileClick(Sender: TObject);
var
  i: integer;
begin
  if not dlgOpenFile.Execute then
    Exit;

  for I := 1 to dlgOpenFile.Files.Count do
  ScanPath(dlgOpenFile.Files.Strings[I - 1]);
end;

procedure TfrmMain.ParseResult(Res: PNativeXML);
var
  COUNT: integer;
  I: Integer;
  Node, TIM_NODE: TXmlNode;
  TIM: PTIM;
  OFFSET, SIZE: DWORD;
  fName, TIM_NAME, Path: string;
  BIT_MODE: Byte;
  IMAGE_SCAN: Boolean;
begin
  Node := Res^.Root.FindNode(cResInfoNode);
  if Node = nil then Exit;

  COUNT := Node.ReadAttributeInteger(cResAttrTimsCount);
  lvList.Items.Count := COUNT;

  if not mnAutoExtract.Checked then Exit;

  lblStatus.Caption := sStatusBarTimsExtracting;
  pbProgress.Max := COUNT;
  pbProgress.Position := 0;

  fName := Node.ReadAttributeUnicodeString(cResAttrFile);
  IMAGE_SCAN := Node.ReadAttributeBool(cResAttrImageFile);
  Node := Res^.Root.FindNode(cResTimsNode);

  for I := 1 to COUNT do
  begin
    TIM_NODE := Node.Elements[I - 1];
    OFFSET := cHex2Int(TIM_NODE.ReadAttributeUnicodeString(cResTimAttrPos));
    SIZE := cHex2Int(TIM_NODE.ReadAttributeUnicodeString(cResTimAttrSize));
    BIT_MODE := TIM_NODE.ReadAttributeInteger(cResTimAttrBitMode);

    TIM_NAME := Format(cAutoExtractionTimFormat,
                       [ExtractFileNameWOext(fName), I, BIT_MODE]);

    Path := IncludeTrailingPathDelimiter(GetStartDir + cExtractedTimsDir);
    CreateDir(Path);
    Path := IncludeTrailingPathDelimiter(Path + ExtractFileName(fName));
    CreateDir(Path);

    TIM := LoadTimFromFile(fName, OFFSET, IMAGE_SCAN, SIZE);
    SaveTimToFile(Path + TIM_NAME, TIM);
    FreeTIM(TIM);

    pbProgress.Position := I - 1;
    Application.ProcessMessages;
  end;

  pbProgress.Position := 0;
end;

procedure TfrmMain.pbImagePaint(Sender: TObject);
begin
  DrawCurrentTIM;
end;

procedure TfrmMain.ScanFile(const FileName: string);
var
  CurrentResult: PNativeXML;
begin
  btnStopScan.Enabled := True;
  cbbFiles.Enabled := False;
  lvList.Enabled := False;

  if CheckForFileOpened(FileName) then
  begin
    cbbFiles.ItemIndex := cbbFiles.Items.IndexOf(ExtractFileName(FileName));
    btnStopScan.Enabled := False;
    cbbFiles.Enabled := True;
    Exit;
  end;

  SetLength(Results, Length(Results) + 1);
  cbbFiles.Items.Add(ExtractFileName(FileName));

  pbProgress.Max := GetFileSizeAPI(FileName);
  pbProgress.Position := 0;

  New(Results[cbbFiles.Items.Count - 1]);
  CurrentResult := Results[cbbFiles.Items.Count - 1];
  CurrentResult^ := TNativeXML.CreateName(cResRootName);
  pScanThread^ := TScanThread.Create(FileName, CurrentResult,
                                     GetImageScan(FileName));
  pScanThread^.FreeOnTerminate := True;
  pScanThread^.Priority := tpNormal;
  pScanThread^.OnTerminate := ScanFinished;
  pScanThread^.Start;
end;


procedure TfrmMain.ScanFinished(Sender: TObject);
begin
  cbbFiles.ItemIndex := cbbFiles.Items.Count - 1;
  ParseResult(Results[cbbFiles.Items.Count - 1]);

  lblStatus.Caption := '';
  cbbFiles.Enabled := True;
  lvList.Enabled := True;
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

procedure TfrmMain.UpdateCLUTList;
var
  TIM: PTIM;
  I, CLUTS: Word;
begin
  TIM := CurrentTIM;
  if TIM = nil then Exit;

  CLUTS := GetTimClutsCount(TIM);

  cbbCLUT.Items.BeginUpdate;
  cbbCLUT.Clear;

  for I := 1 to CLUTS do
    cbbCLUT.Items.Add(Format('CLUT [%d/%d]', [I, CLUTS]));


  cbbCLUT.ItemIndex := 0;
  cbbCLUT.Items.EndUpdate;
  FreeTIM(TIM);
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
  finally
    DragFinish(Msg.Drop);
  end;

end;

end.
