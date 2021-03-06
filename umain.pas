unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazUTF8, LazFileUtils, Forms, Dialogs, ActnList,
  Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, ExtDlgs,

  uscanresult, uscanthread, usettings, utim, udrawtim, types, Controls;

{$INCLUDE todos.inc}

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actAbout: TAction;
    actAddToSendto: TAction;
    actChangeClutIdx: TAction;
    actCloseFile: TAction;
    actCloseFiles: TAction;
    actExit: TAction;
    actExtractPngs: TAction;
    actExtractTim: TAction;
    actExtractTims: TAction;
    actChangeFile: TAction;
    actChangeBackColor: TAction;
    actExtractTimsAll: TAction;
    actExtractPngsAll: TAction;
    actShowFileInfo: TAction;
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
    btnShowClut: TButton;
    btnStopScan: TButton;
    cbbBitMode: TComboBox;
    cbbCLUT: TComboBox;
    cbbFiles: TComboBox;
    cbbTranspMode: TComboBox;
    dlgColor: TColorDialog;
    dlgOpenFile: TOpenDialog;
    dlgSavePNG: TSavePictureDialog;
    dlgSaveFile: TSaveDialog;
    mnExport: TMenuItem;
    mnExtractAllTimsAll: TMenuItem;
    mnExtractAllPngsAll: TMenuItem;
    N22: TMenuItem;
    mnExtractAllPngs3: TMenuItem;
    mnExtractAllTims3: TMenuItem;
    N20: TMenuItem;
    mnSaveTIM1: TMenuItem;
    grdClut: TDrawGrid;
    imgTim: TImage;
    lblClutHint: TLabel;
    lblStatus: TLabel;
    MenuItem1: TMenuItem;
    mnImportPng1: TMenuItem;
    mnShowTimInfo: TMenuItem;
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
    mnImage: TMenuItem;
    N1: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    dlgOpenPNG: TOpenPictureDialog;
    pnlClut: TPanel;
    pbProgress: TProgressBar;
    pnlImage: TPanel;
    pnlImageOptions: TPanel;
    pnlList: TPanel;
    pnlStatus: TPanel;
    pnlMain: TPanel;
    pmImage: TPopupMenu;
    pmList: TPopupMenu;
    mnReplaceIn1: TMenuItem;
    mnSaveToPNG1: TMenuItem;
    dlgSelectDir: TSelectDirectoryDialog;
    splMain: TSplitter;
    grdTimsList: TStringGrid;
    tblTimInfo: TStringGrid;
    procedure actAboutExecute(Sender: TObject);
    procedure actAddToSendtoExecute(Sender: TObject);
    procedure actChangeBackColorExecute(Sender: TObject);
    procedure actChangeClutIdxExecute(Sender: TObject);
    procedure actChangeFileExecute(Sender: TObject);
    procedure actCloseFileExecute(Sender: TObject);
    procedure actCloseFilesExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actExtractPngsAllExecute(Sender: TObject);
    procedure actExtractPngsExecute(Sender: TObject);
    procedure actExtractTimExecute(Sender: TObject);
    procedure actExtractTimsAllExecute(Sender: TObject);
    procedure actExtractTimsExecute(Sender: TObject);
    procedure actOpenLabExecute(Sender: TObject);
    procedure actOpenRepoExecute(Sender: TObject);
    procedure actPngImportExecute(Sender: TObject);
    procedure actReplaceTimExecute(Sender: TObject);
    procedure actReturnFocusExecute(Sender: TObject);
    procedure actScanDirExecute(Sender: TObject);
    procedure actScanFileExecute(Sender: TObject);
    procedure actShowFileInfoExecute(Sender: TObject);
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
    procedure grdTimsListCompareCells(Sender: TObject; ACol, ARow, BCol,
      BRow: Integer; var Result: integer);
    procedure grdTimsListHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    procedure grdTimsListResize(Sender: TObject);
    procedure grdTimsListSelection(Sender: TObject; aCol, aRow: Integer);
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

    procedure GetFilesList(const FileList: TStringList; const Directory: string);
    procedure ScanList(const FileList: TStringList);
    procedure ScanPath(const Path: string);
    procedure ScanFile(const FileName: string);
    procedure CheckButtonsAndMainMenu;
    procedure ScanFinished(Sender: TObject);
    procedure BeforeScan(MaxProgress: Integer);
    procedure SetTimsListCount(Count: Integer);
    procedure UpdateCLUTInfo;
    procedure DrawSelTim;
    procedure SetupSelClut;
    procedure SetCLUTListToNoCLUT;
    function FormatFileName(const FileName: string; ListIdx_, BitMode: Integer; Magic: Byte): string;
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

{$IFDEF Linux}
,BaseUnix
{$IFEND}
;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.actScanFileExecute(Sender: TObject);
var
  I: Integer;
  List: TStringList;
begin
  if not dlgOpenFile.Execute then Exit;

  List := TStringList.Create;

  for I := 1 to dlgOpenFile.Files.Count do
    List.Add(dlgOpenFile.Files.Strings[I - 1]);

  ScanList(List);
  List.Free;
end;

procedure TfrmMain.actShowFileInfoExecute(Sender: TObject);
begin
  Settings.InfoVisible := (Sender as TAction).Checked;
  tblTimInfo.Visible := (Sender as TAction).Checked;
end;

procedure TfrmMain.actStopScanExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to ScanThreads.Count do
    ScanThreads[I - 1].StopScan := True;

  while (StartedScans > 0) do
    Application.ProcessMessages;

  ScanThreads.Clear;
  actStopScan.Tag := NativeInt(True);

  actReturnFocus.Execute;
end;

procedure TfrmMain.actStretchExecute(Sender: TObject);
begin
  Settings.StretchMode := (Sender as TAction).Checked;
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
  Tim2Png(TIM, cbbCLUT.ItemIndex, Image, cbbTranspMode.ItemIndex);
  SaveImage(dlgSavePNG.FileName, Image, TIMisIndexed(TIM));
  FreeTIM(TIM);
  Image^.Free;
  Dispose(Image);
  {$IFDEF Linux}FpChmod(dlgSavePNG.FileName, &664);{$IFEND}
end;

procedure TfrmMain.btnShowClutClick(Sender: TObject);
begin
  pnlClut.Visible := not pnlClut.Visible;
  SetupSelClut;
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
      cbbBitMode.Tag := NativeInt(-1);
  end;

  UpdateTim(True, False, False);
end;

procedure TfrmMain.cbbTranspModeChange(Sender: TObject);
begin
  Settings.TranspMode := cbbTranspMode.ItemIndex;
  UpdateTim(True, False, False);
end;

procedure TfrmMain.actChangeFileExecute(Sender: TObject);
var
  I: Integer;
  W, H: Word;
begin
  SetTimsListCount(SelectedScanResult.Count);

  actReturnFocus.Execute;
  if grdTimsList.RowCount = 1 then Exit;

  grdTimsList.BeginUpdate;
  for I := 1 to SelectedScanResult.Count do
  begin
    W := TimInfoByIdx[I - 1].Width;
    H := TimInfoByIdx[I - 1].Height;

    grdTimsList.Cells[0, I] := Format('%.6d', [I]);
    grdTimsList.Cells[1, I] := Format('%.2d', [TimInfoByIdx[I - 1].BitMode]);
    grdTimsList.Cells[2, I] := Format('%.2d', [TimInfoByIdx[I - 1].Cluts]);
    grdTimsList.Cells[3, I] := Format('%.2d', [TimInfoByIdx[I - 1].Colors]);
    grdTimsList.Cells[4, I] := AnsiUpperCase(TIMTypeStr(TimInfoByIdx[I - 1].Magic));
    grdTimsList.Cells[5, I] := Format('%.3dx%.3d', [W, H]);
  end;
  grdTimsList.EndUpdate;

  grdTimsList.Row := 1;
  grdTimsListSelection(Self, 0, 1);
  grdTimsList.SetFocus;

  CheckButtonsAndMainMenu;
end;

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  Application.MessageBox(cProgramName + #13#10#13#10 + 'Some "about strings" should be here!:)', 'About', MB_OK + MB_ICONINFORMATION);
end;

procedure TfrmMain.actAddToSendtoExecute(Sender: TObject);
begin
  {$IFDEF windows}
  Settings.AddToSendTo(not (Sender as TAction).Checked);
  {$IFEND}
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

procedure TfrmMain.actExtractPngsAllExecute(Sender: TObject);
var
  I, J, OFFSET, BIT_MODE, SIZE: Integer;
  FName, Path: string;
  IsImage: Boolean;
  ScanTim: TTimInfo;
  TIM: PTIM;
  Image: PDrawSurf;
begin
  lblStatus.Caption := sStatusBarPngsExtracting;

  for J := 1 to ScanResults.Count do begin
    cbbFiles.ItemIndex := J - 1;
    actChangeFile.Execute;

    FName := ScanResults[J - 1].ScanFile;
    IsImage := ScanResults[J - 1].IsImage;

    New(Image);
    Image^ := nil;

    pbProgress.Position := 0;
    pbProgress.Max := ScanResults[J - 1].Count;
    for I := 1 to ScanResults[J - 1].Count do
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
      Tim2Png(TIM, cbbCLUT.ItemIndex, Image, cbbTranspMode.ItemIndex);

      Path := Path + FormatPngName(FName, I - 1, BIT_MODE, 0);
      SaveImage(Path, Image, TIMisIndexed(TIM));
      {$IFDEF Linux}FpChmod(Path, &664);{$IFEND}
      Image^.Free;
      Image^ := nil;

      FreeTIM(TIM);

      pbProgress.Position := I;
      Application.ProcessMessages;
    end;
    Dispose(Image);
    pbProgress.Position := 0;
  end;
  lblStatus.Caption := sStatusBarExtracted;
end;

procedure TfrmMain.actExtractPngsExecute(Sender: TObject);
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
    Tim2Png(TIM, cbbCLUT.ItemIndex, Image, cbbTranspMode.ItemIndex);

    Path := Path + FormatPngName(FName, I - 1, BIT_MODE, 0);
    SaveImage(Path, Image, TIMisIndexed(TIM));
    {$IFDEF Linux}FpChmod(Path, &664);{$IFEND}
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
  dlgSaveFile.FileName := FormatFileName(SelectedScanResult.ScanFile, SelectedTimIdx, SelectedTimInfo.BitMode, SelectedTimInfo.Magic);
  dlgSaveFile.FilterIndex := SelectedTimInfo.Magic - cTIMMagic + 1;

  if not dlgSaveFile.Execute then Exit;

  TIM := SelectedTimInMode;
  SaveTimToFile(dlgSaveFile.FileName, TIM);
  {$IFDEF Linux}FpChmod(dlgSaveFile.FileName, &664);{$IFEND}
  FreeTIM(TIM);
end;

procedure TfrmMain.actExtractTimsAllExecute(Sender: TObject);
var
  I, J, OFFSET, BIT_MODE, SIZE, MAGIC: Integer;
  FName, Path: string;
  IsImage: Boolean;
  TIM: PTIM;
  ScanTim: TTimInfo;
begin
  lblStatus.Caption := sStatusBarFilesExtracting;

  for J := 1 to ScanResults.Count do begin
    cbbFiles.ItemIndex := J - 1;
    actChangeFile.Execute;

    FName := ScanResults[J - 1].ScanFile;
    IsImage := ScanResults[J - 1].IsImage;

    pbProgress.Position := 0;
    pbProgress.Max := ScanResults[J - 1].Count;
    for I := 1 to ScanResults[J - 1].Count do
    begin
      ScanTim := TimInfoByIdx[I - 1];
      OFFSET := ScanTim.Position;
      SIZE := ScanTim.Size;
      BIT_MODE := ScanTim.BitMode;
      MAGIC := ScanTim.Magic;

      Path := SysToUTF8(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStrUTF8(0)) + cExtractedFilesDir));
      CreateDirUTF8(Path);
      Path := IncludeTrailingPathDelimiter(Path + ExtractFileName(FName));
      CreateDirUTF8(Path);

      TIM := LoadTimFromFile(FName, OFFSET, IsImage, SIZE);
      Path := Path + FormatFileName(FName, I - 1, BIT_MODE, MAGIC);
      SaveTimToFile(Path, TIM);
      {$IFDEF Linux}FpChmod(Path, &664);{$IFEND}
      FreeTIM(TIM);

      pbProgress.Position := I;
      Application.ProcessMessages;
    end;
    pbProgress.Position := 0;
  end;
  lblStatus.Caption := sStatusBarExtracted;
end;

procedure TfrmMain.actExtractTimsExecute(Sender: TObject);
var
  I, OFFSET, BIT_MODE, SIZE, MAGIC: Integer;
  FName, Path: string;
  IsImage: Boolean;
  TIM: PTIM;
  ScanTim: TTimInfo;
begin
  lblStatus.Caption := sStatusBarFilesExtracting;

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
    MAGIC := ScanTim.Magic;

    Path := SysToUTF8(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStrUTF8(0)) + cExtractedFilesDir));
    CreateDirUTF8(Path);
    Path := IncludeTrailingPathDelimiter(Path + ExtractFileName(FName));
    CreateDirUTF8(Path);

    TIM := LoadTimFromFile(FName, OFFSET, IsImage, SIZE);
    Path := Path + FormatFileName(FName, I - 1, BIT_MODE, MAGIC);
    SaveTimToFile(Path, TIM);
    {$IFDEF Linux}FpChmod(Path, &664);{$IFEND}
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
  OpenUrl('https://github.com/DrMefistO/tim2view/');
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
  if FileSizeUtf8(dlgOpenFile.FileName) > cTIMMaxSize then Exit;

  ScanRes := SelectedScanResult;
  ReplaceTimInFile(ScanRes.ScanFile, dlgOpenFile.FileName, SelectedTimInfo.Position, ScanRes.IsImage);
  ShowTim;
end;

procedure TfrmMain.actReturnFocusExecute(Sender: TObject);
begin
  if pnlList.Enabled then grdTimsList.SetFocus;
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
  Settings := TSettings.Create(ExtractFilePath(ParamStr(0)));

  cbbBitMode.Tag := NativeInt(-1);

  {$IFDEF windows}actAddToSendto.Checked := Settings.SendToShortcutExists;{$ENDIF}
  actStretch.Checked := Settings.StretchMode;
  cbbTranspMode.ItemIndex := Settings.TranspMode;
  LastDir := Settings.LastDir;
  cbbBitMode.ItemIndex := Settings.BitMode;
  pnlImage.Color := Settings.BackColor;
  actShowFileInfo.Checked := Settings.InfoVisible;

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
  I: Integer;
begin
  for I := 1 to Length(FileNames) do
    ScanPath(FileNames[I - 1]);
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

procedure TfrmMain.grdTimsListCompareCells(Sender: TObject; ACol, ARow, BCol,
  BRow: Integer; var Result: integer);
var
  AIdx, BIdx: Integer;
  AW, AH, BW, BH, AP, BP: Integer;
  AWxH, BWxH: string;
begin
  case ACol of
  0, 1, 2, 3:
    begin
      AIdx := StrToIntDef(grdTimsList.Cells[ACol, ARow], 0);
      BIdx := StrToIntDef(grdTimsList.Cells[BCol, BRow], 0);

      // Result will be either <0, =0, or >0 for normal order.
      Result := AIdx - BIdx;
    end;
  5:
    begin
      AWxH := grdTimsList.Cells[ACol, ARow];
      BWxH := grdTimsList.Cells[BCol, BRow];

      AP := Pos('x', AWxH);
      BP := Pos('x', BWxH);

      AW := StrToIntDef(Copy(AWxH, 1, AP - 1), 0);
      BW := StrToIntDef(Copy(BWxH, 1, BP - 1), 0);

      AH := StrToIntDef(Copy(AWxH, AP + 1, Length(AWxH) - AP), 0);
      BH := StrToIntDef(Copy(BWxH, BP + 1, Length(BWxH) - BP), 0);

      if (AW = BW) then
        Result := BH - AH
      else
        Result := BW - AW;
    end;
  else
    begin
      Result := AnsiCompareStr(grdTimsList.Cells[ACol, ARow], grdTimsList.Cells[BCol, BRow]);
    end;
  end;

  // For inverse order, just negate the result (eg. based on grid's SortOrder).
  if grdTimsList.SortOrder = soAscending then
    Result := -Result;
end;

procedure TfrmMain.grdTimsListHeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
begin
  if (grdTimsList.Row < grdTimsList.VisibleRowCount) then
    grdTimsList.TopRow := 1
  else
    grdTimsList.TopRow := grdTimsList.Row - grdTimsList.VisibleRowCount + 1;
end;

procedure TfrmMain.grdTimsListResize(Sender: TObject);
begin
  grdTimsList.Columns[5].Width := grdTimsList.ClientWidth -
    grdTimsList.Columns[4].Width -
    grdTimsList.Columns[3].Width -
    grdTimsList.Columns[2].Width -
    grdTimsList.Columns[1].Width -
    grdTimsList.Columns[0].Width;
end;

procedure TfrmMain.grdTimsListSelection(Sender: TObject; aCol, aRow: Integer);
begin
  if (aRow < 1) then Exit;
  ShowTim;
end;

function TfrmMain.FGetSelectedScanResult: TScanResult;
begin
  Result := ScanResults[cbbFiles.ItemIndex];
end;

function TfrmMain.FGetSelectedTimIdx: Integer;
begin
  Result := StrToIntDef(grdTimsList.Cells[0, grdTimsList.Row], 1) - 1;
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

  if (grdTimsList.RowCount = 1) then Exit;

  P := SelectedTimInfo.Position;
  Result := LoadTimFromFile(SelectedScanResult.ScanFile, P, SelectedScanResult.IsImage, SelectedTimInfo.Size);

  if Integer(cbbBitMode.Tag) = -1 then
    Result^.OverBpp := Result^.HEAD^.bBPP
  else
    Result^.OverBpp := Integer(cbbBitMode.Tag);
end;

procedure TfrmMain.GetFilesList(const FileList: TStringList; const Directory: string);
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
        GetFilesList(FileList, Dir + SysToUTF8(sRec.Name))
      else
        FileList.Add(Dir + SysToUTF8(sRec.Name));
    end;
    Application.ProcessMessages;
    isFound := FindNext(sRec) = 0;
  end;
  FindClose(sRec);
end;

procedure TfrmMain.ScanList(const FileList: TStringList);
var
  I: Integer;
begin
  actStopScan.Enabled := True;
  actStopScan.Tag := NativeInt(False);

  for I := 1 to FileList.Count do
    ScanFile(FileList[I - 1]);

  while (StartedScans > 0) do
    Application.ProcessMessages;

  actStopScan.Enabled := False;
  actStopScan.Tag := NativeInt(True);

  CheckButtonsAndMainMenu;

  if cbbFiles.Enabled then
  begin
    cbbFiles.ItemIndex := cbbFiles.Items.Count - 1;
    actChangeFile.Execute;
  end;
end;

procedure TfrmMain.ScanPath(const Path: string);
var
  FileList: TStringList;
begin
  if Path = '' then Exit;

  FileList := TStringList.Create;
  if FileExistsUTF8(Path) then
    FileList.Add(Path)
  else
    GetFilesList(FileList, Path);

  ScanList(FileList);
  FileList.Free;
end;

procedure TfrmMain.ScanFile(const FileName: string);
begin
  LastDir := ExtractFilePath(FileName);
  Settings.LastDir := LastDir;

  if CheckForFileOpened(@ScanResults, FileName) then
  begin
    cbbFiles.ItemIndex := cbbFiles.Items.IndexOf(FileName);
    actChangeFile.Execute;
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
      BeforeScan(ScanThreads.Last.FileLength);
      ScanThreads.Last.Start;
      Inc(StartedScans);
    end
    else
      while (StartedScans > 0) do
        Application.ProcessMessages;
  end;
end;

procedure TfrmMain.CheckButtonsAndMainMenu;
var
  Enable: Boolean;
begin
  RemoveGridSelection;

  Enable := (cbbFiles.Items.Count <> 0);
  cbbFiles.Enabled := Enable;
  actExtractTimsAll.Enabled := Enable;
  actExtractPngsAll.Enabled := Enable;

  pnlList.Enabled := Enable;
  actCloseFile.Enabled := Enable;
  actCloseFiles.Enabled := Enable;

  Enable := (StartedScans = 0);
  actScanFile.Enabled := Enable;
  actScanDir.Enabled := Enable;

  Enable := not (grdTimsList.Row < 1);
  actReplaceTim.Enabled := Enable;

  actPngExport.Enabled := (Surf^ <> nil) and Enable;
  actPngImport.Enabled := Enable;
  actExtractTim.Enabled := Enable;
  actExtractTims.Enabled := Enable;
  actExtractPngs.Enabled := Enable;

  pnlImageOptions.Enabled := Enable;
end;

procedure TfrmMain.ScanFinished(Sender: TObject);
var
  I: Integer;
begin
  ScanThreads.Remove(Sender as TScanThread);
  Dec(StartedScans);

  for I := 1 to ScanThreads.Count do
    if ScanThreads[I - 1].Suspended and (not ScanThreads[I - 1].StopScan) then
    begin
      BeforeScan(ScanThreads[I - 1].FileLength);
      ScanThreads[I - 1].Start;
      Inc(StartedScans);
      Exit;
    end;
end;

procedure TfrmMain.BeforeScan(MaxProgress: Integer);
begin
  cbbFiles.Enabled := False;
  pnlList.Enabled := False;

  actScanFile.Enabled := False;
  actScanDir.Enabled := False;

  pbProgress.Max := MaxProgress;
  pbProgress.Position := 0;
end;

procedure TfrmMain.SetTimsListCount(Count: Integer);
begin
  grdTimsList.BeginUpdate;
  grdTimsList.RowCount := Count + 1;
  grdTimsList.Columns[0].Title.Caption := Format('# / %d', [Count]);
  grdTimsList.EndUpdate;
end;

procedure TfrmMain.UpdateCLUTInfo;
var
  TIM: PTIM;
  I, CLUTS: Word;
begin
  TIM := SelectedTimInMode;
  if TIM = nil then Exit;

  CLUTS := GetTIMClutsCount(TIM);

  cbbCLUT.Items.BeginUpdate;
  cbbCLUT.Items.Clear;
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

  Tim2Png(TIM, cbbCLUT.ItemIndex, Surf, cbbTranspMode.ItemIndex);
  imgTim.Picture.Bitmap.Assign(Surf^.Bitmap);
  FreeTIM(TIM);

  imgTim.Stretch := actStretch.Checked;
end;

procedure TfrmMain.SetupSelClut;
var
  TIM: PTIM;
begin
  if not pnlClut.Visible then Exit;

  //ClearGrid(@grdClut);

  TIM := SelectedTimInMode;
  if TIM = nil then
  begin
    grdClut.ColCount := 1;
    grdClut.RowCount := 1;
    Exit;
  end;

  grdClut.Enabled := TIMHasCLUT(TIM);

  if TIMHasCLUT(TIM) then
    SetupCLUT(TIM, @grdClut)
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
  cbbCLUT.Items.Add(sThisFileHasNoClut);
  cbbCLUT.ItemIndex := 0;
end;

function TfrmMain.FormatFileName(const FileName: string; ListIdx_,
  BitMode: Integer; Magic: Byte): string;
begin
  Result := Format(cAutoExtractionFileFormat, [ExtractJustName(FileName), ListIdx_ + 1, BitMode, TIMTypeStr(Magic)]);
end;

function TfrmMain.FormatPngName(const FileName: string; ListIdx_, BitMode,
  Clut: Integer): string;
begin
  Result := Format(cAutoExtractionPngFormat, [ExtractJustName(FileName), ListIdx_ + 1, BitMode, Clut + 1]);
end;

procedure TfrmMain.ShowTim;
begin
  if (grdTimsList.Row < 1) then Exit;

  { TODO : Reset bitmode or not? }
  //cbbBitMode.ItemIndex := 0;

  UpdateTim(True, True, True);

  ShowTimInfo(True);

  CheckButtonsAndMainMenu;
end;

procedure TfrmMain.ShowTimInfo(ShowInfo: Boolean);
var
  TIM: PTIM;
  TimInfo: TTimInfo;
begin
  tblTimInfo.Cells[1, 1] := '';
  tblTimInfo.Cells[1, 2] := '';
  tblTimInfo.Cells[1, 3] := '';
  tblTimInfo.Cells[1, 5] := '';
  tblTimInfo.Cells[1, 6] := '';
  tblTimInfo.Cells[1, 8] := '';

  if not ShowInfo then Exit;

  TimInfo := SelectedTimInfo;
  TIM := SelectedTimInMode;

  tblTimInfo.Cells[1, 1] := Format('0x%x', [TimInfo.Position]);

  tblTimInfo.Cells[1, 2] := Format('0x%.2x', [GetTimVersion(TIM)]);
  tblTimInfo.Cells[1, 3] := Format('%s', [TIMIsGoodStr(TIM)]);

  if TIMHasCLUT(TIM) then
  begin
    tblTimInfo.Cells[1, 5] := Format('%dx%d', [GetTimClutVRAMX(TIM), GetTimClutVRAMY(TIM)]);
    tblTimInfo.Cells[1, 6] := Format('%d', [GetTimColorsCount(TIM)]);
  end;

  tblTimInfo.Cells[1, 8] := Format('%dx%d', [GetTimImageVRAMX(TIM), GetTimImageVRAMY(TIM)]);

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
  if Clut then
  begin
    SetupSelClut;
    grdClut.Repaint;
  end;
end;

end.

