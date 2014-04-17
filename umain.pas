unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ActnList,
  Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, ExtDlgs,

  uscanresult, uscanthread, usettings, utim, udrawtim;

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
    actStopScan: TAction;
    actOpenLab: TAction;
    actOpenRepo: TAction;
    actReplaceTim: TAction;
    actReturnFocus: TAction;
    actScanDir: TAction;
    actScanFile: TAction;
    actList: TActionList;
    actStretch: TAction;
    actTim2Png: TAction;
    actTimInfo: TAction;
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
    grdCurrClut: TDrawGrid;
    imgTim: TImage;
    lblStatus: TLabel;
    lvList: TListView;
    mnChangeBackColor2: TMenuItem;
    N8: TMenuItem;
    mnChangeBackColor: TMenuItem;
    mnSaveAsTim: TMenuItem;
    mnExtractAllPngs2: TMenuItem;
    mnExtractAllTims2: TMenuItem;
    N7: TMenuItem;
    mnStretchImage: TMenuItem;
    mnExtractAllPngs: TMenuItem;
    mnExtractAllTims: TMenuItem;
    N6: TMenuItem;
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
    mnTIMInfo: TMenuItem;
    mnTimInfoMain: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
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
    splImageClut: TSplitter;
    splMain: TSplitter;
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
    procedure actReplaceTimExecute(Sender: TObject);
    procedure actReturnFocusExecute(Sender: TObject);
    procedure actScanDirExecute(Sender: TObject);
    procedure actScanFileExecute(Sender: TObject);
    procedure actStopScanExecute(Sender: TObject);
    procedure actStretchExecute(Sender: TObject);
    procedure actTim2PngExecute(Sender: TObject);
    procedure actTimInfoExecute(Sender: TObject);
    procedure btnShowClutClick(Sender: TObject);
    procedure cbbBitModeChange(Sender: TObject);
    procedure cbbTranspModeChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure grdCurrClutDblClick(Sender: TObject);
    procedure grdCurrClutDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure lvListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
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

    function FGetSelectedTim(NewBitMode: Integer): PTIM;
    property SelectedTim: PTIM Index $FF read FGetSelectedTim; //Tim, selected in list
    property SelectedTimInMode[NewBitMode: Integer]: PTIM read FGetSelectedTim; //Tim, selected in list

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
  public
    { public declarations }
    ScanResults: TScanResultList; //List of finished scan results
    ScanThreads: TScanThreadList; //List of currently started scans
    function CheckForFileOpened(const FileName: string): boolean;
  end;

var
  frmMain: TfrmMain;

implementation

uses ucdimage, ucpucount, lcltype, ucommon, LCLIntf, Clipbrd

{$IFDEF windows}
,registry
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
  DrawSelTim;
end;

procedure TfrmMain.actTim2PngExecute(Sender: TObject);
begin
  dlgSavePNG.FileName := FormatPngName(SelectedScanResult.ScanFile, SelectedTimIdx, SelectedTimInfo.BitMode, cbbCLUT.ItemIndex);

  if not dlgSavePNG.Execute then Exit;

  Surf^.SaveToFile(UTF8ToSys(dlgSavePNG.FileName));
end;

procedure TfrmMain.actTimInfoExecute(Sender: TObject);
const
  Tab = #$09;
  Row = #10;
var
  Info, IsGoodTIM: string;
  Index: Integer;
  TIM: PTIM;
begin
  if actTimInfo.Enabled then
  begin
    Index := SelectedTimIdx;
    TIM := SelectedTim;

    if TIMIsGood(TIM) then
      IsGoodTIM := 'YES'
    else
      IsGoodTIM := 'NO';

    Info := Format('"%s" Information' + Row + 'Number:' + Tab + '%d' + Row +
      'Position:' + Tab + '0x%x' + Row + 'BitMode:' + Tab + '%d' + Row + 'Good:'
      + Tab + '%s' + Row + Row +

      'HEADER INFO' + Row + 'Version:' + Tab + '%d' + Row + 'BPP:' + Tab + '%d'
      + Row + Row, [FormatTimName(SelectedScanResult.ScanFile, Index, SelectedTimInfo.BitMode),
      Index + 1, SelectedTimInfo.Position, BppToBitMode(TIM), IsGoodTIM,

      GetTimVersion(TIM), GetTimBPP(TIM)]);

    if TIMHasCLUT(TIM) then
      Info := Format(Info + 'CLUT INFO' + Row + 'Size (Header):' + Tab + '%d' +
        Row + 'Size (Real):' + Tab + '%d' + Row + 'VRAM X Pos:' + Tab + '%d' +
        Row + 'VRAM Y Pos:' + Tab + '%d' + Row + 'CLUTs Count:' + Tab + '%d' +
        Row + 'Colors in 1 CLUT:' + Tab + '%d' + Row + Row,
        [GetTimClutSizeHeader(TIM), GetTimClutSize(TIM), GetTimClutVRAMX(TIM),
        GetTimClutVRAMY(TIM), GetTIMClutsCount(TIM), GetTimColorsCount(TIM)]);

    Info := Format(Info + 'IMAGE INFO' + Row + 'Size (Header):' + Tab + '%d' +
      Row + 'Size (Real):' + Tab + '%d' + Row + 'VRAM X Pos:' + Tab + '%d' + Row
      + 'VRAM Y Pos:' + Tab + '%d' + Row + 'Width (Header):' + Tab + '%d' + Row
      + 'Width (Real):' + Tab + '%d' + Row + 'Height (Real):' + Tab + '%d',
      [GetTimImageSizeHeader(TIM), GetTimImageSize(TIM), GetTimImageVRAMX(TIM),
      GetTimImageVRAMY(TIM), GetTimWidth(TIM), GetTimRealWidth(TIM),
      GetTimHeight(TIM)]);

    case Application.MessageBox(
      PChar(Info + Row + Row +
      'If you want to copy this info to clipboard press "YES" button.'),
      'Information', MB_OKCANCEL + MB_ICONINFORMATION) of
      IDOK:
        Clipboard.AsText := Info;
    end;

    FreeTIM(TIM);
  end;
end;

procedure TfrmMain.btnShowClutClick(Sender: TObject);
begin
  grdCurrClut.Visible := not grdCurrClut.Visible;
  DrawSelClut;
  actReturnFocus.Execute;
end;

procedure TfrmMain.cbbBitModeChange(Sender: TObject);
begin
  DrawSelTim;
end;

procedure TfrmMain.cbbTranspModeChange(Sender: TObject);
begin
  Settings.TranspMode := cbbTranspMode.ItemIndex;
  DrawSelTim;
end;

procedure TfrmMain.actChangeFileExecute(Sender: TObject);
begin
  SetTimsListCount(SelectedScanResult.Count);

  actReturnFocus.Execute;
  lvList.ItemIndex := 0;
  lvList.Items[0].Focused := True;
  lvList.Items[0].Selected := True;
end;

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  Application.MessageBox('Some "about strings" should be here!:)', 'About', MB_OK + MB_ICONINFORMATION);
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
  DrawSelTim;
  DrawSelClut;
end;

procedure TfrmMain.actCloseFileExecute(Sender: TObject);
begin
  SelectedScanResult.Free;
  ScanResults.Delete(cbbFiles.ItemIndex);

  lblStatus.Caption := '';
  actTimInfo.Enabled := False;
  SetTimsListCount(0);

  UpdateCLUTInfo;
  DrawSelTim;
  DrawSelClut;

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
  Surf_: PDrawSurf;
begin
  lblStatus.Caption := sStatusBarPngsExtracting;

  FName := SelectedScanResult.ScanFile;
  IsImage := SelectedScanResult.IsImage;

  New(Surf_);
  Surf_^ := nil;

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
    TimToPNG(TIM, cbbCLUT.ItemIndex, Surf_, cbbTranspMode.ItemIndex);

    Surf_^.SaveToFile(UTF8ToSys(Path + FormatPngName(FName, I - 1, BIT_MODE, 0)));
    Surf_^.Free;
    Surf_^ := nil;

    FreeTIM(TIM);

    pbProgress.Position := I;
    Application.ProcessMessages;
  end;
  Dispose(Surf_);
  lblStatus.Caption := sStatusBarExtracted;
  pbProgress.Position := 0;
end;

procedure TfrmMain.actExtractTimExecute(Sender: TObject);
var
  TIM: PTIM;
begin
  dlgSaveTIM.FileName := FormatTimName(SelectedScanResult.ScanFile, SelectedTimIdx, SelectedTimInfo.BitMode);

  if not dlgSaveTIM.Execute then Exit;

  TIM := SelectedTim;
  SaveTimToFile(dlgSaveTIM.FileName, TIM);
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
    SaveTimToFile(Path + FormatTimName(FName, I - 1, BIT_MODE), TIM);
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

procedure TfrmMain.actReplaceTimExecute(Sender: TObject);
begin
  if not dlgOpenFile.Execute then Exit;

  if FileSize(dlgOpenFile.FileName) > cTIMMaxSize then Exit;

  ReplaceTimInFile(SelectedScanResult.ScanFile, dlgOpenFile.FileName, SelectedTimInfo.Position, SelectedScanResult.IsImage);
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
var
  hGridRect: TGridRect;
begin
  {$IFnDEF Windows}mnOptions.Enabled := False;{$IFEND}

  Settings := TSettings.Create(ExtractFilePath(ParamStrUTF8(0)));

  actStretch.Checked := Settings.StretchMode;
  cbbTranspMode.ItemIndex := Settings.TranspMode;
  LastDir := Settings.LastDir;
  pnlImage.Color := Settings.BackColor;

  hGridRect.Top := -1;
  hGridRect.Left := -1;
  hGridRect.Right := -1;
  hGridRect.Bottom := -1;
  grdCurrClut.Selection := hGridRect;

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

procedure TfrmMain.grdCurrClutDblClick(Sender: TObject);
var
  TIM: PTIM;
  I, SELECTED_CELL, W, DIALOG_COLOR, CLUT_NUM: Integer;
  R, G, B: Byte;
  CLUT_COLOR: TCLUT_COLOR;
begin
  TIM := SelectedTim;
  if TIM = nil then Exit;

  SELECTED_CELL := grdCurrCLUT.Row * grdCurrCLUT.ColCount + grdCurrCLUT.Col;
  W := GetTimColorsCount(TIM);

  if (SELECTED_CELL + 1) > W then
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

  DrawSelTim;
  DrawSelClut;

end;

procedure TfrmMain.grdCurrClutDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  TIM: PTIM;
begin
  TIM := SelectedTim;
  if TIM = nil then Exit;

  if not TIMHasCLUT(TIM) then
  begin
    FreeTIM(TIM);
    Exit;
  end;

  DrawClutCell(TIM, cbbCLUT.ItemIndex, @grdCurrCLUT, ACol, ARow);

  FreeTIM(TIM);
end;

procedure TfrmMain.lvListData(Sender: TObject; Item: TListItem);
var
  W, H: Word;
begin
  if cbbFiles.ItemIndex = -1 then Exit;

  W := TimInfoByIdx[Item.Index].Width;
  H := TimInfoByIdx[Item.Index].Height;

  Item.Caption := Format('%.6d', [Item.Index + 1]);
  Item.SubItems.Add(Format('%.3dx%.3d', [W, H]));
  Item.SubItems.Add(Format('%.2d', [TimInfoByIdx[Item.Index].BitMode]));
  Item.SubItems.Add(Format('%.2d', [TimInfoByIdx[Item.Index].Cluts]));
end;

procedure TfrmMain.lvListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if (Item = nil) then Exit;

  if Selected then ShowTim;
end;

function TfrmMain.FGetSelectedScanResult: TScanResult;
begin
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

function TfrmMain.FGetSelectedTim(NewBitMode: Integer): PTIM;
var
  P: Integer;
begin
  Result := nil;

  if lvList.Selected = nil then Exit;

  P := SelectedTimInfo.Position;
  Result := LoadTimFromFile(SelectedScanResult.ScanFile, P, SelectedScanResult.IsImage, SelectedTimInfo.Size);

  if NewBitMode = $FF then Exit;
  Result^.HEAD^.bBPP := NewBitMode;
end;

function TfrmMain.CheckForFileOpened(const FileName: string): boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 1 to ScanResults.Count do
    if ScanResults[I - 1].ScanFile = FileName then
    begin
      Result := True;
      Exit;
    end;
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

  if CheckForFileOpened(FileName) then
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
    ScanThreads.Add(TScanThread.Create(FileName, GetImageScan(FileName)));
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
  isFound := FindFirstUTF8(Dir + '*', faAnyFile, sRec) = 0;
  while isFound do
  begin
    if (sRec.Name <> '.') and (sRec.Name <> '..') then
    begin
      if (sRec.Attr and faDirectory) = faDirectory then
        ScanDirectory(Dir + sRec.Name)
      else
        ScanFile(Dir + sRec.Name);
    end;
    Application.ProcessMessages;
    isFound := FindNextUTF8(sRec) = 0;
  end;
  FindCloseUTF8(sRec);
end;

procedure TfrmMain.CheckButtonsAndMainMenu;
begin
  cbbFiles.Enabled := (cbbFiles.Items.Count <> 0);

  pnlList.Enabled := cbbFiles.Enabled;
  actCloseFile.Enabled := cbbFiles.Enabled;
  actCloseFiles.Enabled := cbbFiles.Enabled;
  actReplaceTim.Enabled := (lvList.Selected <> nil) and (lvList.Selected.Index <> -1);

  actTim2Png.Enabled := (Surf^ <> nil) and actReplaceTim.Enabled;
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
  TIM := SelectedTim;
  if TIM = nil then Exit;

  CLUTS := GetTIMClutsCount(TIM);
  //cbbCLUT.Items.Clear;

  cbbCLUT.Items.BeginUpdate;
  for I := 0 to cbbCLUT.Items.Count -1 do
    cbbCLUT.Items[i] := Format('CLUT [%.2d/%.2d]', [I + 1, CLUTS]);

  for I := cbbCLUT.Items.Count + 1 to CLUTS do
    cbbCLUT.Items.Add(Format('CLUT [%.2d/%.2d]', [I, CLUTS]));
  cbbCLUT.Items.EndUpdate;

  if CLUTS = 0 then SetCLUTListToNoCLUT;

  cbbCLUT.ItemIndex := 0;

  FreeTIM(TIM);
end;

procedure TfrmMain.DrawSelTim;
var
  TIM: PTIM;
  Index: Integer;
  mode: Byte;
begin
  imgTim.Picture.Bitmap := nil;

  case cbbBitMode.ItemIndex of
    1: mode := cTIM4C;
    2: mode := cTIM8C;
    3: mode := cTIM16NC;
    4: mode := cTIM24NC;
  else
    mode := $FF;
  end;

  TIM := SelectedTimInMode[mode];
  if TIM = nil then Exit;

  Index := cbbCLUT.ItemIndex;

  TimToPNG(TIM, Index, Surf, cbbTranspMode.ItemIndex);
  imgTim.Picture.Bitmap := TBitmap.Create;
  imgTim.Picture.Bitmap := Surf^.Bitmap;
  FreeTIM(TIM);

  imgTim.Stretch := actStretch.Checked;
end;

procedure TfrmMain.DrawSelClut;
var
  TIM: PTIM;
begin
  if not grdCurrClut.Visible then Exit;

  ClearGrid(@grdCurrCLUT);

  TIM := SelectedTim;
  if TIM = nil then
  begin
    grdCurrCLUT.ColCount := 1;
    grdCurrCLUT.RowCount := 1;
    Exit;
  end;

  grdCurrCLUT.Enabled := TIMHasCLUT(TIM);

  if TIMHasCLUT(TIM) then
    DrawCLUT(TIM, cbbCLUT.ItemIndex, @grdCurrCLUT)
  else
  begin
    grdCurrCLUT.ColCount := 1;
    grdCurrCLUT.RowCount := 1;
  end;

  FreeTIM(TIM);
end;

procedure TfrmMain.SetCLUTListToNoCLUT;
var
  I: Integer;
begin
  if cbbCLUT.Items.Count > 0 then
  begin
    cbbCLUT.Items.BeginUpdate;

    for I := 0 to cbbCLUT.Items.Count - 2 do
      cbbCLUT.Items.Delete(I);

    cbbCLUT.Items[0] := sThisTimHasNoClut;

    cbbCLUT.Items.EndUpdate;
  end
  else
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

  cbbBitMode.ItemIndex := 0;

  UpdateCLUTInfo;
  DrawSelTim;
  DrawSelClut;

  actTimInfo.Enabled := True;

  CheckButtonsAndMainMenu;
end;

end.

