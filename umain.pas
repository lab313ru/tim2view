unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Dialogs, ActnList,
  Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, ExtDlgs,

  uscanresult, uscanthread, usettings, utim, udrawtim, types, Controls;

{$INCLUDE todos.inc}

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actAbout: TAction;
    actAssocTims: TAction;
    actChangeClutIdx: TAction;
    actCloseFile: TAction;
    actCloseFiles: TAction;
    actExit: TAction;
    actExtractPNGs: TAction;
    actExtractTim: TAction;
    actExtractTIMs: TAction;
    actChangeFile: TAction;
    actChangeBackColor: TAction;
    actPngImport: TAction;
    actStopScan: TAction;
    actOpenLab: TAction;
    actOpenRepo: TAction;
    actReplaceTim: TAction;
    actReturnFocus: TAction;
    actScanDir: TAction;
    actScanFile: TAction;
    actList: TActionList;
    actStretch: TAction;
    actPngExport: TAction;
    btnExtractAllTims: TButton;
    btnExtractPNGs: TButton;
    btnShowClut: TButton;
    btnStopScan: TButton;
    cbbBitMode: TComboBox;
    cbbCLUT: TComboBox;
    cbbFiles: TComboBox;
    cbbTranspMode: TComboBox;
    dlgColor: TColorDialog;
    dlgOpenFile: TOpenDialog;
    dlgSavePNG: TSavePictureDialog;
    dlgSaveTIM: TSaveDialog;
    ExtractTIM1: TMenuItem;
    grdClut: TDrawGrid;
    imgTim: TImage;
    lblClutHint: TLabel;
    lblStatus: TLabel;
    lvList: TListView;
    MenuItem1: TMenuItem;
    mnImportPng: TMenuItem;
    mnChangeBackColor2: TMenuItem;
    N8: TMenuItem;
    mnChangeBackColor: TMenuItem;
    mnSaveAsTim: TMenuItem;
    mnExtractAllPngs2: TMenuItem;
    mnExtractAllTims2: TMenuItem;
    N7: TMenuItem;
    mnStretchImage: TMenuItem;
    mnSaveAsPng: TMenuItem;
    mnAbout: TMenuItem;
    mnAssociate: TMenuItem;
    mnCloseAllFiles: TMenuItem;
    mnCloseFile: TMenuItem;
    mnExit: TMenuItem;
    mnFile: TMenuItem;
    mmMain: TMainMenu;
    mnHelp: TMenuItem;
    mnOptions: TMenuItem;
    mnReplaceIn: TMenuItem;
    mnSaveTIM: TMenuItem;
    mnSaveToPNG: TMenuItem;
    mnScanDir: TMenuItem;
    mnScanFile: TMenuItem;
    mnSite: TMenuItem;
    mnStretch: TMenuItem;
    mnSVN: TMenuItem;
    mnTIM: TMenuItem;
    N1: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    dlgOpenPNG: TOpenPictureDialog;
    pnlClut: TPanel;
    pbProgress: TProgressBar;
    pnlExtractAll: TPanel;
    pnlImage: TPanel;
    pnlImageOptions: TPanel;
    pnlList: TPanel;
    pnlStatus: TPanel;
    pnlMain: TPanel;
    pmImage: TPopupMenu;
    pmList: TPopupMenu;
    ReplaceTIM1: TMenuItem;
    SaveasPNG1: TMenuItem;
    dlgSelectDir: TSelectDirectoryDialog;
    splMain: TSplitter;
    sbMain: TStatusBar;
    procedure actAboutExecute(Sender: TObject);
    procedure actAssocTimsExecute(Sender: TObject);
    procedure actChangeBackColorExecute(Sender: TObject);
    procedure actChangeClutIdxExecute(Sender: TObject);
    procedure actChangeFileExecute(Sender: TObject);
    procedure actCloseFileExecute(Sender: TObject);
    procedure actCloseFilesExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actExtractPNGsExecute(Sender: TObject);
    procedure actExtractTimExecute(Sender: TObject);
    procedure actExtractTIMsExecute(Sender: TObject);
    procedure actOpenLabExecute(Sender: TObject);
    procedure actOpenRepoExecute(Sender: TObject);
    procedure actPngImportExecute(Sender: TObject);
    procedure actReplaceTimExecute(Sender: TObject);
    procedure actReturnFocusExecute(Sender: TObject);
    procedure actScanDirExecute(Sender: TObject);
    procedure actScanFileExecute(Sender: TObject);
    procedure actStopScanExecute(Sender: TObject);
    procedure actStretchExecute(Sender: TObject);
    procedure actPngExportExecute(Sender: TObject);
    procedure btnShowClutClick(Sender: TObject);
    procedure cbbBitModeChange(Sender: TObject);
    procedure cbbTranspModeChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure grdClutDblClick(Sender: TObject);
    procedure grdClutDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
    procedure grdClutKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure lvListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    { private declarations }
    StartedScans: Integer; //Count of currently started scans
    LastDir: string; //var to store last selected dir
    Settings: TSettings; //var to work with program settings
    Surf: PDrawSurf;

    function FGetSelectedScanResult: TScanResult;
    property SelectedScanResult: TScanResult read FGetSelectedScanResult; //Selected scan result

    function FGetSelectedTimIdx: Integer;
    property SelectedTimIdx: Integer read FGetSelectedTimIdx; //Index of tim, selected in list

    function FGetSelectedTimInfo: TTimInfo;
    property SelectedTimInfo: TTimInfo read FGetSelectedTimInfo; //Info about tim, selected in list

    function FGetTimInfoByIdx(Index: Integer): TTimInfo;
    property TimInfoByIdx[Index: Integer]: TTimInfo read FGetTimInfoByIdx; //Info about tim by index

    function FGetSelectedTim: PTIM;
    property SelectedTimInMode: PTIM read FGetSelectedTim; //Tim, selected in list

    procedure ScanPath(const Path: string);
    procedure ScanFile(const FileName: string);
    procedure ScanDirectory(const Directory: string);
    procedure CheckButtonsAndMainMenu;
    procedure ScanFinished(Sender: TObject);
    procedure SetTimsListCount(Count: Integer);
    procedure UpdateCLUTInfo;
    procedure DrawSelTim;
    procedure DrawSelClut;
    procedure SetCLUTListToNoCLUT;
    function FormatTimName(const FileName: string; ListIdx_, BitMode: Integer): string;
    function FormatPngName(const FileName: string; ListIdx_, BitMode, Clut: Integer): string;
    procedure ShowTim;
    procedure ShowTimInfo(ShowInfo: Boolean);
    procedure RemoveGridSelection;
    procedure UpdateTim(Tim, Clut, ClutInfo: Boolean);
  public
    { public declarations }
    ScanResults: TScanResultList; //List of finished scan results
    ScanThreads: TScanThreadList; //List of currently started scans
  end;

var
  frmMain: TfrmMain;

implementation

uses ucdimage, ucpucount, lcltype, ucommon, LCLIntf, uexportimport,
  FPimage

{$IFDEF windows}
,registry
{$IFEND}

{$IFDEF Linux}
,BaseUnix
{$IFEND}
;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.actScanFileExecute(Sender: TObject);
var
  I: Integer;
begin
  if not dlgOpenFile.Execute then Exit;

  for I := 1 to dlgOpenFile.Files.Count do
    ScanPath(dlgOpenFile.Files.Strings[I - 1]);
end;

procedure TfrmMain.actStopScanExecute(Sender: TObject);
var
  I: Integer;
begin
  if ScanThreads.Count = 0 then Exit;

  for I := 1 to ScanThreads.Count do
    ScanThreads[I - 1].StopScan := True;

  ScanThreads.Clear;
  StartedScans := 0;
  actStopScan.Tag := NativeInt(True);

  ScanFinished(nil);

  actReturnFocus.Execute;
end;

procedure TfrmMain.actStretchExecute(Sender: TObject);
begin
  Settings.StretchMode := actStretch.Checked;
  UpdateTim(True, False, False);
end;

procedure TfrmMain.actPngExportExecute(Sender: TObject);
var
  TIM: PTIM;
  Image: PDrawSurf;
begin
  TIM := SelectedTimInMode;
  if TIM = nil then Exit;

  dlgSavePNG.FileName := FormatPngName(SelectedScanResult.ScanFile, TIM^.dwTimNumber, SelectedTimInfo.BitMode, cbbCLUT.ItemIndex);
  if not dlgSavePNG.Execute then Exit;

  New(Image);
  Image^ := nil;
  Tim2Png(TIM, cbbCLUT.ItemIndex, Image, cbbTranspMode.ItemIndex, True);
  SaveImage(dlgSavePNG.FileName, Image, TIMisIndexed(TIM));
  FreeTIM(TIM);
  Image^.Free;
  Dispose(Image);
  {$IFDEF Linux}FpChmod(dlgSavePNG.FileName, &777);{$IFEND}
end;

procedure TfrmMain.btnShowClutClick(Sender: TObject);
begin
  pnlClut.Visible := not pnlClut.Visible;
  UpdateTim(False, True, False);
  actReturnFocus.Execute;
end;

procedure TfrmMain.cbbBitModeChange(Sender: TObject);
begin
  case cbbBitMode.ItemIndex of
    1: cbbBitMode.Tag := NativeInt(cTIM4C);
    2: cbbBitMode.Tag := NativeInt(cTIM4NC);
    3: cbbBitMode.Tag := NativeInt(cTIM8C);
    4: cbbBitMode.Tag := NativeInt(cTIM8NC);
    5: cbbBitMode.Tag := NativeInt(cTIM16NC);
    6: cbbBitMode.Tag := NativeInt(cTIM24NC);
    else
      cbbBitMode.Tag := NativeInt($FF);
  end;

  UpdateTim(True, False, False);
end;

procedure TfrmMain.cbbTranspModeChange(Sender: TObject);
begin
  Settings.TranspMode := cbbTranspMode.ItemIndex;
  UpdateTim(True, False, False);
end;

procedure TfrmMain.actChangeFileExecute(Sender: TObject);
begin
  SetTimsListCount(SelectedScanResult.Count);

  actReturnFocus.Execute;
  if lvList.Items.Count = 0 then Exit;

  //if lvList.Selected <> nil then
  //  lvList.Selected.Index := -1;
  lvList.ItemIndex:= -1;
  lvList.Update;
  lvList.ItemIndex := 0;

  lvList.Items[0].Focused := True;
  lvList.Items[0].Selected := True;
  lvList.Items[0].MakeVisible(False);
end;

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  Application.MessageBox(cProgramName + #13#10#13#10 + 'Some "about strings" should be here!:)', 'About', MB_OK + MB_ICONINFORMATION);
end;

procedure TfrmMain.actAssocTimsExecute(Sender: TObject);
{$IFDEF windows}
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;

  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('Software\Classes\.tim', True);
    reg.WriteString('', 'TimFile');
    reg.CloseKey;

    reg.OpenKey('Software\Classes\TimFile', True);
    reg.WriteString('', 'Tim File Format');
    reg.CloseKey;
    reg.OpenKey('Software\Classes\TimFile\DefaultIcon', True);
    reg.WriteString('', '"' + ParamStrUTF8(0) +'",0');
    reg.CloseKey;
    reg.OpenKey('Software\Classes\TimFile\shell\Open\Command', True);
    reg.WriteString('', '"' + ParamStrUTF8(0) + '" "%1"');
    reg.CloseKey;
  finally
    reg.Free;
  end;
{$ELSE}
begin
{$ENDIF}
end;

procedure TfrmMain.actChangeBackColorExecute(Sender: TObject);
begin
  if not dlgColor.Execute then Exit;

  pnlImage.Color := dlgColor.Color;
  Settings.BackColor := dlgColor.Color;
end;

procedure TfrmMain.actChangeClutIdxExecute(Sender: TObject);
begin
  UpdateTim(True, True, False);
end;

procedure TfrmMain.actCloseFileExecute(Sender: TObject);
begin
  SelectedScanResult.Free;
  ScanResults.Delete(cbbFiles.ItemIndex);

  lblStatus.Caption := '';
  ShowTimInfo(False);
  SetTimsListCount(0);

  UpdateTim(True, True, True);

  cbbFiles.Items.Delete(cbbFiles.ItemIndex);

  CheckButtonsAndMainMenu;

  if cbbFiles.Enabled then
  begin
    cbbFiles.ItemIndex := cbbFiles.Items.Count - 1;
    actChangeFile.Execute;
  end;
end;

procedure TfrmMain.actCloseFilesExecute(Sender: TObject);
begin
  cbbFiles.Items.BeginUpdate;
  while cbbFiles.Items.Count > 0 do
    actCloseFile.Execute;
  cbbFiles.Items.EndUpdate;
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.actExtractPNGsExecute(Sender: TObject);
var
  I, OFFSET, BIT_MODE, SIZE: Integer;
  FName, Path: string;
  IsImage: Boolean;
  ScanTim: TTimInfo;
  TIM: PTIM;
  Image: PDrawSurf;
begin
  lblStatus.Caption := sStatusBarPngsExtracting;

  FName := SelectedScanResult.ScanFile;
  IsImage := SelectedScanResult.IsImage;

  New(Image);
  Image^ := nil;

  pbProgress.Position := 0;
  pbProgress.Max := SelectedScanResult.Count;
  for I := 1 to SelectedScanResult.Count do
  begin
    ScanTim := TimInfoByIdx[I - 1];
    OFFSET := ScanTim.Position;
    SIZE := ScanTim.Size;
    BIT_MODE := ScanTim.BitMode;

    Path := SysToUTF8(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStrUTF8(0)) + cExtractedPngsDir));
    CreateDirUTF8(Path);
    Path := IncludeTrailingPathDelimiter(Path + ExtractFileName(FName));
    CreateDirUTF8(Path);

    TIM := LoadTimFromFile(FName, OFFSET, IsImage, SIZE);
    Tim2Png(TIM, cbbCLUT.ItemIndex, Image, cbbTranspMode.ItemIndex, False);

    Path := Path + FormatPngName(FName, I - 1, BIT_MODE, 0);
    SaveImage(Path, Image, False);
    {$IFDEF Linux}FpChmod(Path, &777);{$IFEND}
    Image^.Free;
    Image^ := nil;

    FreeTIM(TIM);

    pbProgress.Position := I;
    Application.ProcessMessages;
  end;
  Dispose(Image);
  lblStatus.Caption := sStatusBarExtracted;
  pbProgress.Position := 0;
end;

procedure TfrmMain.actExtractTimExecute(Sender: TObject);
var
  TIM: PTIM;
begin
  dlgSaveTIM.FileName := FormatTimName(SelectedScanResult.ScanFile, SelectedTimIdx, SelectedTimInfo.BitMode);

  if not dlgSaveTIM.Execute then Exit;

  TIM := SelectedTimInMode;
  SaveTimToFile(dlgSaveTIM.FileName, TIM);
  {$IFDEF Linux}FpChmod(dlgSaveTIM.FileName, &777);{$IFEND}
  FreeTIM(TIM);
end;

procedure TfrmMain.actExtractTIMsExecute(Sender: TObject);
var
  I, OFFSET, BIT_MODE, SIZE: Integer;
  FName, Path: string;
  IsImage: Boolean;
  TIM: PTIM;
  ScanTim: TTimInfo;
begin
  lblStatus.Caption := sStatusBarTimsExtracting;

  FName := SelectedScanResult.ScanFile;
  IsImage := SelectedScanResult.IsImage;

  pbProgress.Position := 0;
  pbProgress.Max := SelectedScanResult.Count;
  for I := 1 to SelectedScanResult.Count do
  begin
    ScanTim := TimInfoByIdx[I - 1];
    OFFSET := ScanTim.Position;
    SIZE := ScanTim.Size;
    BIT_MODE := ScanTim.BitMode;

    Path := SysToUTF8(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStrUTF8(0)) + cExtractedTimsDir));
    CreateDirUTF8(Path);
    Path := IncludeTrailingPathDelimiter(Path + ExtractFileName(FName));
    CreateDirUTF8(Path);

    TIM := LoadTimFromFile(FName, OFFSET, IsImage, SIZE);
    Path := Path + FormatTimName(FName, I - 1, BIT_MODE);
    SaveTimToFile(Path, TIM);
    {$IFDEF Linux}FpChmod(Path, &777);{$IFEND}
    FreeTIM(TIM);

    pbProgress.Position := I;
    Application.ProcessMessages;
  end;
  lblStatus.Caption := sStatusBarExtracted;
  pbProgress.Position := 0;
end;

procedure TfrmMain.actOpenLabExecute(Sender: TObject);
begin
  OpenUrl('http://lab313.ru');
end;

procedure TfrmMain.actOpenRepoExecute(Sender: TObject);
begin
  OpenUrl('http://tim2view.googlecode.com');
end;

procedure TfrmMain.actPngImportExecute(Sender: TObject);
var
  Image: PDrawSurf;
  TIM: PTIM;
  ScanRes: TScanResult;
begin
  if not dlgOpenPNG.Execute then Exit;

  TIM := SelectedTimInMode;
  if TIM = nil then Exit;

  Image := LoadImage(dlgOpenPNG.FileName);
  Png2Tim(Image, TIM);
  ScanRes := SelectedScanResult;
  ReplaceTimInFileFromMemory(ScanRes.ScanFile, TIM, SelectedTimInfo.Position, ScanRes.IsImage);
  ShowTim;
  FreeTIM(TIM);
  Image^.Free;
  Dispose(Image);
end;

procedure TfrmMain.actReplaceTimExecute(Sender: TObject);
var
  ScanRes: TScanResult;
begin
  if not dlgOpenFile.Execute then Exit;
  if FileSize(dlgOpenFile.FileName) > cTIMMaxSize then Exit;

  ScanRes := SelectedScanResult;
  ReplaceTimInFile(ScanRes.ScanFile, dlgOpenFile.FileName, SelectedTimInfo.Position, ScanRes.IsImage);
  ShowTim;
end;

procedure TfrmMain.actReturnFocusExecute(Sender: TObject);
begin
  if pnlList.Enabled then lvList.SetFocus;
end;

procedure TfrmMain.actScanDirExecute(Sender: TObject);
var
  SelectedDir: string;
begin
  dlgSelectDir.Title := sSelectDirCaption;
  dlgSelectDir.FileName := LastDir;

  if not dlgSelectDir.Execute then Exit;

  SelectedDir := dlgSelectDir.FileName;
  if DirectoryExistsUTF8(SelectedDir) then
  begin
    ScanPath(SelectedDir);
    LastDir := SelectedDir;
    Settings.LastDir := LastDir;
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  actCloseFiles.Execute;
  ScanThreads.Free;
  ScanResults.Free;

  Surf^.Free;
  Dispose(Surf);
  Settings.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Settings := TSettings.Create(ExtractFilePath(ParamStrUTF8(0)));

  cbbBitMode.Tag := NativeInt($FF);

  actStretch.Checked := Settings.StretchMode;
  cbbTranspMode.ItemIndex := Settings.TranspMode;
  LastDir := Settings.LastDir;
  cbbBitMode.ItemIndex := Settings.BitMode;
  pnlImage.Color := Settings.BackColor;

  ScanThreads := TScanThreadList.Create(False); //False - to able scan thread remove itself from this list
  ScanResults := TScanResultList.Create(False);
  StartedScans := 0;

  New(Surf);
  Surf^ := nil;

  SetCLUTListToNoCLUT;
  Caption := cProgramName;

  CheckButtonsAndMainMenu;

  if ParamCount > 0 then ScanPath(ParamStrUTF8(1));
end;

procedure TfrmMain.FormDropFiles(Sender: TObject;
  const FileNames: array of string);
var
  i: Integer;
begin
  for i := 1 to Length(FileNames) do
    ScanPath(FileNames[i - 1]);
end;

procedure TfrmMain.grdClutDblClick(Sender: TObject);
var
  TIM: PTIM;
  I, SELECTED_CELL, W, DIALOG_COLOR, CLUT_NUM: Integer;
  R, G, B: Byte;
  CLUT_COLOR: TCLUT_COLOR;
begin
  TIM := SelectedTimInMode;
  if TIM = nil then Exit;

  SELECTED_CELL := grdClut.Row * grdClut.ColCount + grdClut.Col;
  W := GetTimColorsCount(TIM);

  if SELECTED_CELL >= W then
  begin
    FreeTIM(TIM);
    Exit;
  end;

  CLUT_NUM := cbbCLUT.ItemIndex;
  dlgColor.CustomColors.Clear;

  for I := 1 to 16 do
  begin
    CLUT_COLOR := GetCLUTColor(TIM, CLUT_NUM, I - 1);
    R := CLUT_COLOR.R;
    G := CLUT_COLOR.G;
    B := CLUT_COLOR.B;
    dlgColor.CustomColors.Add(Format('Color%s=%.2x%.2x%.2x', [Chr(Ord('A') + (I - 1)), R, G, B]));
  end;

  CLUT_COLOR := GetCLUTColor(TIM, CLUT_NUM, SELECTED_CELL);
  R := CLUT_COLOR.R;
  G := CLUT_COLOR.G;
  B := CLUT_COLOR.B;
  dlgColor.Color := RGB(R, G, B);

  if not dlgColor.Execute then
  begin
    FreeTIM(TIM);
    Exit;
  end;

  DIALOG_COLOR := dlgColor.Color;

  CLUT_COLOR.R := ((GetRValue(DIALOG_COLOR) div 8) and $1F) * 8;
  CLUT_COLOR.G := ((GetGValue(DIALOG_COLOR) div 8) and $1F) * 8;
  CLUT_COLOR.B := ((GetBValue(DIALOG_COLOR) div 8) and $1F) * 8;

  WriteCLUTColor(TIM, CLUT_NUM, SELECTED_CELL, CLUT_COLOR);

  ReplaceTimInFileFromMemory(SelectedScanResult.ScanFile, TIM, SelectedTimInfo.Position, SelectedScanResult.IsImage);

  FreeTIM(TIM);

  UpdateTim(True, True, False);
end;

procedure TfrmMain.grdClutDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  TIM: PTIM;
begin
  TIM := SelectedTimInMode;
  if TIM = nil then Exit;

  if not TIMHasCLUT(TIM) then
  begin
    FreeTIM(TIM);
    Exit;
  end;

  DrawClutCell(TIM, cbbCLUT.ItemIndex, @grdClut, ACol, ARow);

  FreeTIM(TIM);
end;

procedure TfrmMain.grdClutKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  TIM: PTIM;
  SELECTED_CELL, CLUT_NUM: Integer;
  CLUT_COLOR: TCLUT_COLOR;
begin
  if Key <> VK_SPACE then Exit;

  TIM := SelectedTimInMode;
  if TIM = nil then Exit;

  SELECTED_CELL := grdClut.Row * grdClut.ColCount + grdClut.Col;

  if SELECTED_CELL >= GetTimColorsCount(TIM) then
  begin
    FreeTIM(TIM);
    Exit;
  end;

  CLUT_NUM := cbbCLUT.ItemIndex;
  CLUT_COLOR := GetCLUTColor(TIM, CLUT_NUM, SELECTED_CELL);
  CLUT_COLOR.STP := CLUT_COLOR.STP xor 1;

  WriteCLUTColor(TIM, CLUT_NUM, SELECTED_CELL, CLUT_COLOR);

  ReplaceTimInFileFromMemory(SelectedScanResult.ScanFile, TIM, SelectedTimInfo.Position, SelectedScanResult.IsImage);

  FreeTIM(TIM);

  UpdateTim(True, True, False);
end;

procedure TfrmMain.lvListData(Sender: TObject; Item: TListItem);
var
  W, H: Word;
begin
  if cbbFiles.ItemIndex = -1 then Exit;

  W := TimInfoByIdx[Item.Index].Width;
  H := TimInfoByIdx[Item.Index].Height;

  Item.Caption := Format('%.6d', [Item.Index + 1]);
  Item.SubItems.Add(Format('%.2d', [TimInfoByIdx[Item.Index].BitMode]));
  Item.SubItems.Add(Format('%.2d', [TimInfoByIdx[Item.Index].Cluts]));
  Item.SubItems.Add(Format('%.3dx%.3d', [W, H]));
end;

procedure TfrmMain.lvListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if (Item = nil) then Exit;

  if Selected then ShowTim;
end;

function TfrmMain.FGetSelectedScanResult: TScanResult;
begin
  if cbbFiles.ItemIndex = -1 then Exit;
  Result := ScanResults[cbbFiles.ItemIndex];
end;

function TfrmMain.FGetSelectedTimIdx: Integer;
begin
  Result := lvList.ItemIndex;
end;

function TfrmMain.FGetSelectedTimInfo: TTimInfo;
begin
  Result := SelectedScanResult.ScanTim[SelectedTimIdx];
end;

function TfrmMain.FGetTimInfoByIdx(Index: Integer): TTimInfo;
begin
  Result := SelectedScanResult.ScanTim[Index];
end;

function TfrmMain.FGetSelectedTim: PTIM;
var
  P: Integer;
begin
  Result := nil;

  if lvList.Selected = nil then Exit;

  P := SelectedTimInfo.Position;
  Result := LoadTimFromFile(SelectedScanResult.ScanFile, P, SelectedScanResult.IsImage, SelectedTimInfo.Size);

  if Integer(cbbBitMode.Tag) = $FF then Exit;
  Result^.HEAD^.bBPP := Integer(cbbBitMode.Tag);
end;

procedure TfrmMain.ScanPath(const Path: string);
begin
  if Path = '' then Exit;

  actStopScan.Enabled := True;
  actStopScan.Tag := NativeInt(False);

  if FileExistsUTF8(Path) then
    ScanFile(Path)
  else
    ScanDirectory(Path);
end;

procedure TfrmMain.ScanFile(const FileName: string);
begin
  LastDir := ExtractFilePath(FileName);
  Settings.LastDir := LastDir;

  if CheckForFileOpened(@ScanResults, FileName) then
  begin
    cbbFiles.ItemIndex := cbbFiles.Items.IndexOf(FileName);
    actChangeFile.Execute;
    actStopScan.Enabled := False;
    actStopScan.Tag := NativeInt(True);
    CheckButtonsAndMainMenu;
    Exit;
  end;

  if not Boolean(actStopScan.Tag) then
  begin
    ScanThreads.Add(TScanThread.Create(FileName, GetImageScan(FileName), @ScanResults));
    ScanThreads.Last.FreeOnTerminate := True;
    ScanThreads.Last.Priority := tpNormal;
    ScanThreads.Last.OnTerminate := @ScanFinished;

    if StartedScans < GetLogicalCpuCount then
    begin
      ScanThreads.Last.Start;
      Inc(StartedScans);
    end;
  end;
end;

procedure TfrmMain.ScanDirectory(const Directory: string);
var
  sRec: TSearchRec;
  isFound: boolean;
  Dir: string;
begin
  Dir := IncludeTrailingPathDelimiter(Directory);
  isFound := FindFirst(UTF8ToSys(Dir + '*'), faAnyFile, sRec) = 0;
  while isFound do
  begin
    if (sRec.Name <> '.') and (sRec.Name <> '..') then
    begin
      if (sRec.Attr and faDirectory) = faDirectory then
        ScanDirectory(Dir + SysToUTF8(sRec.Name))
      else
        ScanFile(Dir + SysToUTF8(sRec.Name));
    end;
    Application.ProcessMessages;
    isFound := FindNext(sRec) = 0;
  end;
  FindClose(sRec);
end;

procedure TfrmMain.CheckButtonsAndMainMenu;
begin
  RemoveGridSelection;

  cbbFiles.Enabled := (cbbFiles.Items.Count <> 0);

  pnlList.Enabled := cbbFiles.Enabled;
  actCloseFile.Enabled := cbbFiles.Enabled;
  actCloseFiles.Enabled := cbbFiles.Enabled;
  actReplaceTim.Enabled := (lvList.Selected <> nil) and (lvList.Selected.Index <> -1);

  actPngExport.Enabled := (Surf^ <> nil) and actReplaceTim.Enabled;
  actPngImport.Enabled := actReplaceTim.Enabled;
  actExtractTim.Enabled := actReplaceTim.Enabled;

  pnlImageOptions.Enabled := actReplaceTim.Enabled;
end;

procedure TfrmMain.ScanFinished(Sender: TObject);
var
  I: Integer;
begin
  ScanThreads.Remove(Sender as TScanThread);

  Dec(StartedScans);

  if ScanThreads.Count <> 0 then
  begin
    for I := 1 to ScanThreads.Count do
      if ScanThreads[I - 1].Suspended and (not ScanThreads[I - 1].StopScan) then
      begin
        ScanThreads[I - 1].Start;
        Inc(StartedScans);
        Exit;
      end;
    Exit;
  end;

  if ScanResults.Count <> 0 then SetTimsListCount(ScanResults.Last.Count);

  CheckButtonsAndMainMenu;

  if cbbFiles.Enabled then
  begin
    cbbFiles.ItemIndex := cbbFiles.Items.Count - 1;
    actChangeFile.Execute;
  end;

  actStopScan.Enabled := False;
  actStopScan.Tag := NativeInt(True);
end;

procedure TfrmMain.SetTimsListCount(Count: Integer);
begin
  lvList.Items.BeginUpdate;
  lvList.Items.Count := Count;
  lvList.Column[0].Caption := Format('# / %d', [Count]);
  lvList.Items.EndUpdate;
end;

procedure TfrmMain.UpdateCLUTInfo;
var
  TIM: PTIM;
  I, CLUTS: Word;
begin
  TIM := SelectedTimInMode;
  if TIM = nil then Exit;

  CLUTS := GetTIMClutsCount(TIM);
  cbbCLUT.Items.Clear;

  cbbCLUT.Items.BeginUpdate;
  for I := 1 to CLUTS do
    cbbCLUT.Items.Add(Format('CLUT [%.2d/%.2d]', [I, CLUTS]));
  cbbCLUT.Items.EndUpdate;

  if CLUTS = 0 then SetCLUTListToNoCLUT;

  cbbCLUT.ItemIndex := 0;

  FreeTIM(TIM);
end;

procedure TfrmMain.DrawSelTim;
var
  TIM: PTIM;
begin
  imgTim.Picture.Bitmap.FreeImage;
  imgTim.Picture.Bitmap := nil;

  TIM := SelectedTimInMode;
  if TIM = nil then Exit;

  Tim2Png(TIM, cbbCLUT.ItemIndex, Surf, cbbTranspMode.ItemIndex, False);
  imgTim.Picture.Bitmap.Assign(Surf^.Bitmap);
  FreeTIM(TIM);

  imgTim.Stretch := actStretch.Checked;
end;

procedure TfrmMain.DrawSelClut;
var
  TIM: PTIM;
begin
  if not pnlClut.Visible then Exit;

  ClearGrid(@grdClut);

  TIM := SelectedTimInMode;
  if TIM = nil then
  begin
    grdClut.ColCount := 1;
    grdClut.RowCount := 1;
    Exit;
  end;

  grdClut.Enabled := TIMHasCLUT(TIM);

  if TIMHasCLUT(TIM) then
    DrawCLUT(TIM, cbbCLUT.ItemIndex, @grdClut)
  else
  begin
    grdClut.ColCount := 1;
    grdClut.RowCount := 1;
  end;

  FreeTIM(TIM);
end;

procedure TfrmMain.SetCLUTListToNoCLUT;
begin
  cbbCLUT.Items.Clear;
  cbbCLUT.Items.Add(sThisTimHasNoClut);
  cbbCLUT.ItemIndex := 0;
end;

function TfrmMain.FormatTimName(const FileName: string; ListIdx_,
  BitMode: Integer): string;
begin
  Result := Format(cAutoExtractionTimFormat, [ExtractJustName(FileName), ListIdx_ + 1, BitMode]);
end;

function TfrmMain.FormatPngName(const FileName: string; ListIdx_, BitMode,
  Clut: Integer): string;
begin
  Result := Format(cAutoExtractionPngFormat, [ExtractJustName(FileName), ListIdx_ + 1, BitMode, Clut + 1]);
end;

procedure TfrmMain.ShowTim;
begin
  if (lvList.Selected = nil) then Exit;
  if (lvList.Items.Count = 0) then Exit;

  { TODO : Reset bitmode or not? }
  //cbbBitMode.ItemIndex := 0;

  UpdateTim(True, True, True);

  ShowTimInfo(True);

  CheckButtonsAndMainMenu;
end;

procedure TfrmMain.ShowTimInfo(ShowInfo: Boolean);
var
  I: Integer;
  TIM: PTIM;
  TimInfo: TTimInfo;
begin
  for I := 1 to sbMain.Panels.Count do
    sbMain.Panels[I - 1].Text := '';

  if not ShowInfo then Exit;

  TimInfo := SelectedTimInfo;
  TIM := SelectedTimInMode;

  I := 0;

  sbMain.Panels[I].Text := Format('Pos: 0x%x', [TimInfo.Position]);
  sbMain.Panels[I].Width := Canvas.GetTextWidth(sbMain.Panels[I].Text) + 8; Inc(I);
  sbMain.Panels[I].Text := Format('Ver: %d', [GetTimVersion(TIM)]);
  sbMain.Panels[I].Width := Canvas.GetTextWidth(sbMain.Panels[I].Text) + 8; Inc(I);
  sbMain.Panels[I].Text := Format('Good: %s', [TIMIsGoodStr(TIM)]);
  sbMain.Panels[I].Width := Canvas.GetTextWidth(sbMain.Panels[I].Text) + 8; Inc(I);

  if TIMHasCLUT(TIM) then
  begin
    sbMain.Panels[I].Alignment := taRightJustify;
    sbMain.Panels[I].Text := 'CLUT:';
    sbMain.Panels[I].Width := Canvas.GetTextWidth(sbMain.Panels[I].Text) + 20; Inc(I);
    sbMain.Panels[I].Text := Format('X/Y: %dx%d', [GetTimClutVRAMX(TIM), GetTimClutVRAMY(TIM)]);
    sbMain.Panels[I].Width := Canvas.GetTextWidth(sbMain.Panels[I].Text) + 8; Inc(I);
    sbMain.Panels[I].Text := Format('Colors: %d', [GetTimColorsCount(TIM)]);
    sbMain.Panels[I].Width := Canvas.GetTextWidth(sbMain.Panels[I].Text) + 8; Inc(I);
  end;

  sbMain.Panels[I].Alignment := taRightJustify;
  sbMain.Panels[I].Text := 'IMAGE:';
  sbMain.Panels[I].Width := Canvas.GetTextWidth(sbMain.Panels[I].Text) + 20; Inc(I);
  sbMain.Panels[I].Text := Format('X/Y: %dx%d', [GetTimImageVRAMX(TIM), GetTimImageVRAMY(TIM)]);
  sbMain.Panels[I].Width := Canvas.GetTextWidth(sbMain.Panels[I].Text) + 8; Inc(I);

  FreeTIM(TIM);
end;

procedure TfrmMain.RemoveGridSelection;
var
  hGrid: TGridRect;
begin
  hGrid.Top := -1;
  hGrid.Left := -1;
  hGrid.Right := -1;
  hGrid.Bottom := -1;
  grdClut.Selection := hGrid;
end;

procedure TfrmMain.UpdateTim(Tim, Clut, ClutInfo: Boolean);
begin
  if ClutInfo then UpdateCLUTInfo;
  if Tim then DrawSelTim;
  if Clut then DrawSelClut;
end;

end.
