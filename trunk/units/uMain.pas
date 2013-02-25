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
    pnlList: TPanel;
    lvList: TListView;
    pnlImageOptions: TPanel;
    cbbCLUT: TComboBox;
    cbbTransparenceMode: TComboBox;
    grdCurrCLUT: TDrawGrid;
    lblTimInformation: TLabel;
    pnlImage: TPanel;
    splImageClut: TSplitter;
    dlgColor: TColorDialog;
    pnlCLUTColor: TPanel;
    mnViewMode: TMenuItem;
    mnSimpleMode: TMenuItem;
    mnAdvancedMode: TMenuItem;
    imgTIM: TImage;
    procedure mnScanFileClick(Sender: TObject);
    procedure btnStopScanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
    procedure mnExitClick(Sender: TObject);
    procedure cbbFilesChange(Sender: TObject);
    procedure pbImagePaint(Sender: TObject);
    procedure cbbCLUTChange(Sender: TObject);
    procedure chkTransparenceClick(Sender: TObject);
    procedure cbbTransparenceModeClick(Sender: TObject);
    procedure grdCurrCLUTDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure lblTimInformationMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblTimInformationClick(Sender: TObject);
    procedure grdCurrCLUTDblClick(Sender: TObject);
    procedure lblTimInformationMouseEnter(Sender: TObject);
    procedure lblTimInformationMouseLeave(Sender: TObject);
    procedure mnSimpleModeClick(Sender: TObject);
    procedure mnAdvancedModeClick(Sender: TObject);
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
    procedure CheckButtonsAndMainMenu;
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
    procedure UpdateCLUTInfo;
    procedure SetCLUTListToNoCLUT;
    procedure GotoNextFile;
    procedure GotoPreviousFile;
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

procedure TfrmMain.CheckButtonsAndMainMenu;
begin
  mnCloseFile.Enabled := (cbbFiles.Items.Count <> 0);
  mnCloseAllFiles.Enabled := (cbbFiles.Items.Count <> 0);
  mnSaveToPNG.Enabled := (pCurrentPNG^ <> nil);
  mnReplaceIn.Enabled := (lvList.SelCount = 1);
  mnSaveTIM.Enabled := (lvList.SelCount = 1);
  mnScanDir.Enabled := (not mnSimpleMode.Checked);

  if mnSimpleMode.Checked then
  begin
    pnlList.Width := 0;
    grdCurrCLUT.Height := 0;
    pnlImageOptions.Height := 0;
    pnlStatus.Height := 0;
    cbbFiles.Height := 0;
  end
  else
  begin
    pnlList.Width := 233;
    grdCurrCLUT.Height := 150;
    pnlImageOptions.Height := 30;
    pnlStatus.Height := 30;
    cbbFiles.Height := 21;
  end;
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
  result := Node.ReadAttributeInteger(cResTimAttrHeight);
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
  result := Node.ReadAttributeInteger(cResTimAttrWidth);
end;

procedure TfrmMain.DrawCurrentCLUT;
var
  TIM: PTIM;
begin
  ClearGrid(@grdCurrCLUT);

  TIM := CurrentTIM;
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

procedure TfrmMain.DrawCurrentTIM;
var
  TIM: PTIM;
  Index: Integer;
begin
  imgTIM.Picture := nil;

  TIM := CurrentTIM;
  if TIM = nil then Exit;

  if pCurrentPNG^ <> nil then
  begin
    pCurrentPNG^.Free;
    pCurrentPNG^ := nil;
  end;

  if cbbCLUT.Text = sThisTimHasNoClut then
    Index := -1
  else
    Index := cbbCLUT.ItemIndex;

  TimToPNG(TIM, Index, pCurrentPNG, cbbTransparenceMode.ItemIndex);
  pCurrentPNG.AssignTo(imgTIM.Picture.Bitmap);
  //DrawPNG(pCurrentPNG, C, imgTIM.ClientRect);

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
  result := Node.ReadAttributeInteger(cResTimAttrPos);
end;

function TfrmMain.CurrentTimSize(Index: Integer): DWORD;
var
  Node: TXmlNode;
begin
  result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then Exit;

  Node := Node.Elements[Index];
  result := Node.ReadAttributeInteger(cResTimAttrSize);
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
  SetCLUTListToNoCLUT;
  Caption := Format('%s v%s', [cProgramName, cProgramVersion]);
  DragAcceptFiles(Handle, True);
  CheckButtonsAndMainMenu;
end;

procedure TfrmMain.GotoNextFile;
begin
  if (cbbFiles.ItemIndex + 1) <> cbbFiles.Items.Count then
    cbbFiles.ItemIndex := cbbFiles.ItemIndex + 1
  else
    cbbFiles.ItemIndex := 0;

  cbbFilesChange(Self);
end;

procedure TfrmMain.GotoPreviousFile;
begin
  if cbbFiles.ItemIndex > 0 then
    cbbFiles.ItemIndex := cbbFiles.ItemIndex - 1
  else
    cbbFiles.ItemIndex := cbbFiles.Items.Count - 1;

  cbbFilesChange(Self);
end;

procedure TfrmMain.grdCurrCLUTDblClick(Sender: TObject);
var
  TIM: PTIM;
  I, SELECTED_CELL, W, DIALOG_COLOR, CLUT_NUM: Integer;
  R, G, B: Byte;
  CLUT_COLOR: TCLUT_COLOR;
begin
  TIM := CurrentTIM;
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
    dlgColor.CustomColors.Add(Format('Color%s=%.2x%.2x%.2x',
                                     [Chr(Ord('A') + (I - 1)), R, G, B]));
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

  ReplaceTimInFileFromMemory(CurrentFileName, TIM,
                             CurrentTimPos(lvList.Selected.Index),
                             CurrentFileIsImage);

  FreeTIM(TIM);

  DrawCurrentTIM;
  DrawCurrentCLUT;
end;

procedure TfrmMain.grdCurrCLUTDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  TIM: PTIM;
begin
  TIM := CurrentTIM;
  if TIM = nil then Exit;

  if not TIMHasCLUT(TIM) then
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

procedure TfrmMain.lblTimInformationClick(Sender: TObject);
const
  Tab = #$09;
  ROW = #13#10;
var
  Info, IsGoodTIM: string;
  Index: Integer;
  TIM: PTIM;
begin
  if lblTimInformation.Caption <> '' then
    begin
      Index := lvList.Selected.Index;
      TIM := CurrentTIM;

      if TIMIsGood(TIM) then
        IsGoodTIM := 'YES'
      else
        IsGoodTIM := 'NO';


      Info := Format(
                     '"%s" Information' + ROW +
                     'Number:' + Tab + '%d' + ROW +
                     'Position:' + Tab + '0x%x' + ROW +
                     'BitMode:' + Tab + '%d' + ROW +
                     'Good:' + Tab + '%s' + ROW + ROW +

                     'HEADER INFO' + ROW +
                     'Version:' + Tab + '%d' + ROW +
                     'BPP:' + Tab + '%d' + ROW + ROW,
                     [
                      CurrentTIMName(Index),
                      Index,
                      CurrentTimPos(Index),
                      BppToBitMode(TIM),
                      IsGoodTIM,

                      GetTimVersion(TIM),
                      GetTimBPP(TIM)
                     ]);

      if TIMHasCLUT(TIM) then
        Info := Format(Info +
                       'CLUT INFO' + ROW +
                       'Size (Header):' + Tab + '%d' + ROW +
                       'Size (Real):' + Tab + '%d' + ROW +
                       'VRAM X Pos:' + Tab + '%d' + ROW +
                       'VRAM Y Pos:' + Tab + '%d' + ROW +
                       'CLUTs Count:' + Tab + '%d' + ROW +
                       'Colors in 1 CLUT:' + Tab + '%d' + ROW + ROW,
                       [
                        GetTimClutSizeHeader(TIM),
                        GetTimClutSize(TIM),
                        GetTimClutVRAMX(TIM),
                        GetTimClutVRAMY(TIM),
                        GetTIMClutsCount(TIM),
                        GetTimColorsCount(TIM)
                       ]);

      Info := Format(Info +
                     'IMAGE INFO' + ROW +
                     'Size (Header):' + Tab + '%d' + ROW +
                     'Size (Real):' + Tab + '%d' + ROW +
                     'VRAM X Pos:' + Tab + '%d' + ROW +
                     'VRAM Y Pos:' + Tab + '%d' + ROW +
                     'Width (Header):' + Tab + '%d' + ROW +
                     'Width (Real):' + Tab + '%d' + ROW +
                     'Height (Real):' + Tab + '%d',
                     [
                      GetTimImageSizeHeader(TIM),
                      GetTimImageSize(TIM),
                      GetTimImageVRAMX(TIM),
                      GetTimImageVRAMY(TIM),
                      GetTimWidth(TIM),
                      GetTimRealWidth(TIM),
                      GetTimHeight(TIM)
                     ]);

      case MessageBox(Handle, PWideChar(Info + ROW + ROW +
           'If you want to copy this info to clipboard press "YES" button.'),
           'Information', MB_OKCANCEL + MB_ICONINFORMATION + MB_TOPMOST) of
        IDOK: Text2Clipboard(Info);
      end;

      FreeTIM(TIM);
    end;
end;

procedure TfrmMain.lblTimInformationMouseEnter(Sender: TObject);
begin
  lblTimInformation.Font.Style := [fsUnderline];
end;

procedure TfrmMain.lblTimInformationMouseLeave(Sender: TObject);
begin
  lblTimInformation.Font.Style := [];
end;

procedure TfrmMain.lblTimInformationMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if lblTimInformation.Caption <> '' then
    lblTimInformation.Cursor := crHandPoint
  else
    lblTimInformation.Cursor := crDefault;
end;

procedure TfrmMain.lvListClick(Sender: TObject);
var
  OFFSET, SIZE: DWORD;
begin
  if (lvList.Selected = nil) then Exit;

  OFFSET := CurrentTimPos(lvList.Selected.Index);
  SIZE := CurrentTimSize(lvList.Selected.Index);
  UpdateCLUTInfo;
  DrawCurrentTIM;
  if not mnSimpleMode.Checked then
    DrawCurrentCLUT;
  lblTimInformation.Caption := Format(
                                      'Position: 0x%x;' + #9 + 'Size: %db',
                                      [OFFSET, SIZE]);
  CheckButtonsAndMainMenu;
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

  if mnSimpleMode.Checked then
  begin
    if Key = VK_RIGHT then
      Key := VK_DOWN
    else
    if Key = VK_LEFT then
      Key := VK_UP;
  end;

  if (Key = VK_DOWN) then
  begin
    if ((lvList.Selected.Index + 1) <> lvList.Items.Count) then
      lvList.Items[lvList.Selected.Index + 1].Selected := True
    else
    begin
      GotoNextFile;
      lvList.Items[0].Selected := True;
    end;
  end
  else
  if (Key = VK_UP) then
  begin
    if (lvList.Selected.Index > 0) then
      lvList.Items[lvList.Selected.Index - 1].Selected := True
    else
    begin
      GotoPreviousFile;
      lvList.Items[lvList.Items.Count - 1].Selected := True;
    end;
  end;

  lvListClick(Self);
end;

procedure TfrmMain.mnAdvancedModeClick(Sender: TObject);
begin
  CheckButtonsAndMainMenu;
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
  lblTimInformation.Caption := '';
  DrawCurrentTIM;
  DrawCurrentCLUT;

  cbbCLUT.Items.BeginUpdate;
  if (cbbCLUT.Items.Count > 0) then
  cbbCLUT.Items.Delete(cbbCLUT.ItemIndex);
  cbbCLUT.Items.EndUpdate;

  SetCLUTListToNoCLUT;

  cbbFiles.Items.BeginUpdate;
  cbbFiles.Items.Delete(cbbFiles.ItemIndex);
  cbbFiles.Items.EndUpdate;

  CheckButtonsAndMainMenu;
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

procedure TfrmMain.mnSimpleModeClick(Sender: TObject);
begin
  CheckButtonsAndMainMenu;
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
    OFFSET := TIM_NODE.ReadAttributeInteger(cResTimAttrPos);
    SIZE := TIM_NODE.ReadAttributeInteger(cResTimAttrSize);
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
  pnlList.Enabled := False;

  if mnSimpleMode.Checked then
    pnlStatus.Height := 30;

  if CheckForFileOpened(FileName) then
  begin
    cbbFiles.ItemIndex := cbbFiles.Items.IndexOf(ExtractFileName(FileName));
    btnStopScan.Enabled := False;
    cbbFiles.Enabled := True;
    CheckButtonsAndMainMenu;
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
  ParseResult(Results[cbbFiles.ItemIndex]);

  lblStatus.Caption := '';
  cbbFiles.Enabled := True;
  pnlList.Enabled := True;
  btnStopScan.Enabled := False;
  CheckButtonsAndMainMenu;

  lvList.Items[0].Selected := True;
  lvList.Items[0].Focused := True;
  lvList.SetFocus;
  lvListClick(Self);
end;

procedure TfrmMain.ScanPath(const Path: string);
begin
  if CheckFileExists(Path) then
    ScanFile(Path)
  else
    ScanDirectory(Path);
end;

procedure TfrmMain.SetCLUTListToNoCLUT;
begin
  cbbCLUT.Items.BeginUpdate;
  cbbCLUT.Items.Clear;
  cbbCLUT.Items.Add(sThisTimHasNoCLUT);
  cbbCLUT.Items.EndUpdate;
  cbbCLUT.ItemIndex := 0;
end;

procedure TfrmMain.UpdateCLUTInfo;
var
  TIM: PTIM;
  I, CLUTS: Word;
begin
  TIM := CurrentTIM;
  if TIM = nil then Exit;

  CLUTS := GetTimClutsCount(TIM);
  cbbCLUT.Clear;

  for I := 1 to CLUTS do
  begin
    cbbCLUT.Items.BeginUpdate;
    cbbCLUT.Items.Add(Format('CLUT [%d/%d]', [I, CLUTS]));
    cbbCLUT.Items.EndUpdate;
  end;

  cbbCLUT.ItemIndex := 0;

  if CLUTS = 0 then
  SetCLUTListToNoCLUT;

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
