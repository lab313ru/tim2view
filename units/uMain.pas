unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls, NativeXml, uScanThread, uCommon,
  Winapi.ShellAPI, uDrawTIM, Vcl.ExtDlgs, uTIM, System.Actions,
  Vcl.ActnList;

const
  WM_COMMANDARRIVED = WM_USER + 1;

type
  TfrmMainT2V = class(TForm)
    dlgOpenFile: TOpenDialog;
    mmMain: TMainMenu;
    mnFile: TMenuItem;
    mnScanFile: TMenuItem;
    mnScanDir: TMenuItem;
    N1: TMenuItem;
    mnCloseFile: TMenuItem;
    mnExit: TMenuItem;
    mnTIM: TMenuItem;
    mnReplaceIn: TMenuItem;
    mnHelp: TMenuItem;
    mnSVN: TMenuItem;
    mnSite: TMenuItem;
    N3: TMenuItem;
    mnAbout: TMenuItem;
    pbProgress: TProgressBar;
    mnConfig: TMenuItem;
    mnAutoExtract: TMenuItem;
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
    pnlImage: TPanel;
    splImageClut: TSplitter;
    mnViewMode: TMenuItem;
    mnSimpleMode: TMenuItem;
    mnAdvancedMode: TMenuItem;
    imgTIM: TImage;
    dlgColor: TColorDialog;
    actList: TActionList;
    actScanFile: TAction;
    actScanDir: TAction;
    actCloseFile: TAction;
    actCloseFiles: TAction;
    actExit: TAction;
    N4: TMenuItem;
    actExtractTim: TAction;
    actReplaceTim: TAction;
    actTim2Png: TAction;
    actOpenRepo: TAction;
    actOpenLab: TAction;
    actAbout: TAction;
    pmList: TPopupMenu;
    ExtractTIM1: TMenuItem;
    ReplaceTIM1: TMenuItem;
    N2: TMenuItem;
    SaveasPNG1: TMenuItem;
    cbbBitMode: TComboBox;
    chkStretch: TCheckBox;
    actStretch: TAction;
    Stretch1: TMenuItem;
    actTimInfo: TAction;
    mnTIMInfo: TMenuItem;
    IMInfo1: TMenuItem;
    actAssocTims: TAction;
    N5: TMenuItem;
    mnAssociate: TMenuItem;
    procedure btnStopScanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure lvListClick(Sender: TObject);
    procedure lvListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbbFilesChange(Sender: TObject);
    procedure pbImagePaint(Sender: TObject);
    procedure cbbCLUTChange(Sender: TObject);
    procedure chkTransparenceClick(Sender: TObject);
    procedure cbbTransparenceModeClick(Sender: TObject);
    procedure grdCurrCLUTDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure grdCurrCLUTDblClick(Sender: TObject);
    procedure mnSimpleModeClick(Sender: TObject);
    procedure mnAdvancedModeClick(Sender: TObject);
    procedure actScanFileExecute(Sender: TObject);
    procedure actScanDirExecute(Sender: TObject);
    procedure actCloseFileExecute(Sender: TObject);
    procedure actCloseFilesExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actExtractTimExecute(Sender: TObject);
    procedure actReplaceTimExecute(Sender: TObject);
    procedure actTim2PngExecute(Sender: TObject);
    procedure actOpenRepoExecute(Sender: TObject);
    procedure actOpenLabExecute(Sender: TObject);
    procedure cbbBitModeChange(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actStretchExecute(Sender: TObject);
    procedure actTimInfoExecute(Sender: TObject);
    procedure actAssocTimsExecute(Sender: TObject);
  private
    { Private declarations }
    // pResult: PNativeXml;
    Results: array of PNativeXML;
    pScanThread: pScanThread;
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
    function CurrentFileIsImage: boolean;
    function CurrentTIM(NewBitMode: DWORD = $FF): PTIM;
    function CurrentTIMName(Index: Integer): string;
    procedure DrawCurrentTIM;
    procedure DrawCurrentCLUT;
    procedure UpdateCLUTInfo;
    procedure SetCLUTListToNoCLUT;
    procedure GotoNextFile;
    procedure GotoPreviousFile;
  protected
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure WMCommandArrived(var Message: TMessage); message WM_COMMANDARRIVED;
    function ReadPathFromMailslot: string;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMainT2V;
  ServerMailSlot: THandle;

implementation

uses
  uCDIMAGE, uBrowseForFolder, System.Win.Registry, uEventWaitThread;

{$R *.dfm}

function ForceForegroundWindow(hwnd: THandle): Boolean;
const
  SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
  SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
  ForegroundThreadID: DWORD;
  ThisThreadID: DWORD;
  timeout: DWORD;
begin
  if IsIconic(hwnd) then ShowWindow(hwnd, SW_RESTORE);

  if GetForegroundWindow = hwnd then Result := True
  else
  begin
    // Windows 98/2000 doesn't want to foreground a window when some other
    // window has keyboard focus

    if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion > 4)) or
      ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and
      ((Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and
      (Win32MinorVersion > 0)))) then
    begin
      Result := False;
      ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow, nil);
      ThisThreadID := GetWindowThreadPRocessId(hwnd, nil);
      if AttachThreadInput(ThisThreadID, ForegroundThreadID, True) then
      begin
        BringWindowToTop(hwnd); // IE 5.5 related hack
        SetForegroundWindow(hwnd);
        AttachThreadInput(ThisThreadID, ForegroundThreadID, False);
        Result := (GetForegroundWindow = hwnd);
      end;
      if not Result then
      begin
        // Code by Daniel P. Stasinski
        SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(0),
          SPIF_SENDCHANGE);
        BringWindowToTop(hwnd); // IE 5.5 related hack
        SetForegroundWindow(hWnd);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(timeout), SPIF_SENDCHANGE);
      end;
    end
    else
    begin
      BringWindowToTop(hwnd); // IE 5.5 related hack
      SetForegroundWindow(hwnd);
    end;

    Result := (GetForegroundWindow = hwnd);
  end;
end;

function TfrmMainT2V.ReadPathFromMailslot: string;
var
  MessageSize: DWORD;
begin
  GetMailslotInfo(ServerMailSlot, nil, MessageSize, nil, nil);

  if MessageSize = MAILSLOT_NO_MESSAGE then
  begin
    Result := '';
    Exit;
  end;

  SetLength(Result, MessageSize div SizeOf(Char));
  ReadFile(ServerMailSlot, Result[1], MessageSize * SizeOf(Char), MessageSize, nil);
  Result := Trim(Result);
end;

procedure TfrmMainT2V.WMCommandArrived(var Message: TMessage);
var
  path: string;
begin
  ForceForegroundWindow(Self.Handle);
  path := ReadPathFromMailslot;
  ScanPath(path);
end;

procedure TfrmMainT2V.actAboutExecute(Sender: TObject);
begin
  MessageBox(Handle, 'Test version!', 'About', MB_OK + MB_ICONINFORMATION);
end;

procedure TfrmMainT2V.actAssocTimsExecute(Sender: TObject);
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
    reg.WriteString('', '"' + ParamStr(0) +'",0');
    reg.CloseKey;
    reg.OpenKey('Software\Classes\TimFile\shell\Open\Command', True);
    reg.WriteString('', '"' + ParamStr(0) + '" "%1"');
    reg.CloseKey;
  finally
    reg.Free;
  end;
end;

procedure TfrmMainT2V.actCloseFileExecute(Sender: TObject);
begin
  Results[cbbFiles.ItemIndex]^.Free;
  Dispose(Results[cbbFiles.ItemIndex]);
  SetLength(Results, Length(Results) - 1);
  lvList.Items.BeginUpdate;
  lvList.Items.Count := 0;
  lvList.Items.EndUpdate;
  lblStatus.Caption := '';
  actTimInfo.Enabled := False;
  actTimInfo.Caption := 'TIM Info';
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

procedure TfrmMainT2V.actCloseFilesExecute(Sender: TObject);
begin
  while cbbFiles.Items.Count > 0 do
  begin
    cbbFiles.ItemIndex := cbbFiles.Items.Count - 1;
    actCloseFile.Execute;
  end;
end;

procedure TfrmMainT2V.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMainT2V.actExtractTimExecute(Sender: TObject);
var
  TIM: PTIM;
begin
  dlgSaveTIM.FileName := CurrentTIMName(lvList.Selected.Index);

  if not dlgSaveTIM.Execute then
    Exit;

  TIM := CurrentTIM;
  SaveTimToFile(dlgSaveTIM.FileName, TIM);
  FreeTIM(TIM);
end;

procedure TfrmMainT2V.actOpenLabExecute(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'tim2view.googlecode.com', nil, nil, SW_SHOW);
end;

procedure TfrmMainT2V.actOpenRepoExecute(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'tim2view.googlecode.com', nil, nil, SW_SHOW);
end;

procedure TfrmMainT2V.actReplaceTimExecute(Sender: TObject);
begin
  if not dlgOpenFile.Execute then
    Exit;

  if GetFileSizeAPI(dlgOpenFile.FileName) > cTIMMaxSize then
    Exit;

  ReplaceTimInFile(CurrentFileName, dlgOpenFile.FileName,
    CurrentTimPos(lvList.Selected.Index), CurrentFileIsImage);
  lvListClick(Self);
  MessageBeep(MB_ICONINFORMATION);
end;

procedure TfrmMainT2V.actScanDirExecute(Sender: TObject);
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

procedure TfrmMainT2V.actScanFileExecute(Sender: TObject);
var
  I: Integer;
begin
  if not dlgOpenFile.Execute then
    Exit;

  for I := 1 to dlgOpenFile.Files.Count do
    ScanPath(dlgOpenFile.Files.Strings[I - 1]);
end;

procedure TfrmMainT2V.actStretchExecute(Sender: TObject);
begin
  DrawCurrentTIM;
end;

procedure TfrmMainT2V.actTim2PngExecute(Sender: TObject);
var
  FName: string;
begin
  FName := CurrentTIMName(lvList.Selected.Index);
  FName := ChangeFileExt(FName, '.png');
  dlgSavePNG.FileName := FName;

  if not dlgSavePNG.Execute then
    Exit;

  pCurrentPNG^.SaveToFile(dlgSavePNG.FileName);
end;

procedure TfrmMainT2V.actTimInfoExecute(Sender: TObject);
const
  Tab = #$09;
  Row = #13#10;
var
  Info, IsGoodTIM: string;
  Index: Integer;
  TIM: PTIM;
begin
  if actTimInfo.Enabled then
  begin
    Index := lvList.Selected.Index;
    TIM := CurrentTIM;

    if TIMIsGood(TIM) then
      IsGoodTIM := 'YES'
    else
      IsGoodTIM := 'NO';

    Info := Format('"%s" Information' + Row + 'Number:' + Tab + '%d' + Row +
      'Position:' + Tab + '0x%x' + Row + 'BitMode:' + Tab + '%d' + Row + 'Good:'
      + Tab + '%s' + Row + Row +

      'HEADER INFO' + Row + 'Version:' + Tab + '%d' + Row + 'BPP:' + Tab + '%d'
      + Row + Row, [CurrentTIMName(Index), Index + 1, CurrentTimPos(Index),
      BppToBitMode(TIM), IsGoodTIM,

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

    case MessageBox(Handle,
      PWideChar(Info + Row + Row +
      'If you want to copy this info to clipboard press "YES" button.'),
      'Information', MB_OKCANCEL + MB_ICONINFORMATION + MB_TOPMOST) of
      IDOK:
        Text2Clipboard(Info);
    end;

    FreeTIM(TIM);
  end;
end;

procedure TfrmMainT2V.btnStopScanClick(Sender: TObject);
begin
  if pScanThread = nil then
    Exit;

  pScanThread^.StopScan := True;
end;

procedure TfrmMainT2V.cbbFilesChange(Sender: TObject);
var
  Node: TXmlNode;
begin
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResInfoNode);
  if Node = nil then
    Exit;

  lvList.Items.Count := Node.ReadAttributeInteger(cResAttrTimsCount);
  lvList.Invalidate;

  lvListClick(Self);
end;

procedure TfrmMainT2V.cbbBitModeChange(Sender: TObject);
begin
  DrawCurrentTIM;
end;

procedure TfrmMainT2V.cbbCLUTChange(Sender: TObject);
begin
  DrawCurrentTIM;
  DrawCurrentCLUT;
end;

procedure TfrmMainT2V.cbbTransparenceModeClick(Sender: TObject);
begin
  DrawCurrentTIM;
end;

function TfrmMainT2V.CheckForFileOpened(const FileName: string): boolean;
begin
  Result := (cbbFiles.Items.IndexOf(ExtractFileName(FileName)) <> -1);
end;

procedure TfrmMainT2V.CheckButtonsAndMainMenu;
begin
  actCloseFile.Enabled := (cbbFiles.Items.Count <> 0);
  actCloseFiles.Enabled := (cbbFiles.Items.Count <> 0);
  actTim2Png.Enabled := (pCurrentPNG^ <> nil);
  actReplaceTim.Enabled := (lvList.SelCount = 1);
  actExtractTim.Enabled := (lvList.SelCount = 1);
  actScanDir.Enabled := (not mnSimpleMode.Checked);

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

procedure TfrmMainT2V.chkTransparenceClick(Sender: TObject);
begin
  DrawCurrentTIM;
end;

function TfrmMainT2V.CurrentTIM(NewBitMode: DWORD = $FF): PTIM;
var
  OFFSET, SIZE: DWORD;
begin
  Result := nil;

  if lvList.Selected = nil then
    Exit;

  OFFSET := CurrentTimPos(lvList.Selected.Index);
  SIZE := CurrentTimSize(lvList.Selected.Index);
  Result := LoadTimFromFile(CurrentFileName, OFFSET, CurrentFileIsImage, SIZE);

  if NewBitMode = $FF then Exit;
  Result^.HEAD^.bBPP := NewBitMode;
end;

function TfrmMainT2V.CurrentTimBitMode(Index: Integer): Byte;
var
  Node: TXmlNode;
begin
  Result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then
    Exit;

  Node := Node.Elements[Index];
  Result := Node.ReadAttributeInteger(cResTimAttrBitMode);
end;

function TfrmMainT2V.CurrentTimHeight(Index: Integer): Word;
var
  Node: TXmlNode;
begin
  Result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then
    Exit;

  Node := Node.Elements[Index];
  Result := Node.ReadAttributeInteger(cResTimAttrHeight);
end;

function TfrmMainT2V.CurrentTIMName(Index: Integer): string;
begin
  Result := Format(cAutoExtractionTimFormat,
    [ExtractFileNameWOext(CurrentFileName), Index + 1,
    CurrentTimBitMode(Index)]);
end;

function TfrmMainT2V.CurrentTimWidth(Index: Integer): Word;
var
  Node: TXmlNode;
begin
  Result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then
    Exit;

  Node := Node.Elements[Index];
  Result := Node.ReadAttributeInteger(cResTimAttrWidth);
end;

procedure TfrmMainT2V.DrawCurrentCLUT;
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

procedure TfrmMainT2V.DrawCurrentTIM;
var
  TIM: PTIM;
  Index: Integer;
  mode: Byte;
begin
  imgTIM.Picture := nil;

  case cbbBitMode.ItemIndex of
    1: mode := cTIM4C;
    2: mode := cTIM8NC;
    3: mode := cTIM16NC;
    4: mode := cTIM24NC;
  else
    mode := $FF;
  end;

  TIM := CurrentTIM(mode);
  if TIM = nil then
    Exit;

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
  FreeTIM(TIM);

  imgTIM.Stretch := chkStretch.Checked;

  imgTIM.Invalidate;
end;

function TfrmMainT2V.CurrentFileIsImage: boolean;
var
  Node: TXmlNode;
begin
  Result := False;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResInfoNode);
  if Node = nil then
    Exit;

  Result := Node.ReadAttributeBool(cResAttrImageFile);
end;

function TfrmMainT2V.CurrentFileName: string;
var
  Node: TXmlNode;
begin
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResInfoNode);
  if Node = nil then
    Exit;

  Result := Node.ReadAttributeUnicodeString(cResAttrFile);
end;

function TfrmMainT2V.CurrentTimPos(Index: Integer): DWORD;
var
  Node: TXmlNode;
begin
  Result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then
    Exit;

  Node := Node.Elements[Index];
  Result := Node.ReadAttributeInteger(cResTimAttrPos);
end;

function TfrmMainT2V.CurrentTimSize(Index: Integer): DWORD;
var
  Node: TXmlNode;
begin
  Result := 0;
  Node := Results[cbbFiles.ItemIndex]^.Root.FindNode(cResTimsNode);
  if Node = nil then
    Exit;

  Node := Node.Elements[Index];
  Result := Node.ReadAttributeInteger(cResTimAttrSize);
end;

procedure TfrmMainT2V.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  actCloseFiles.Execute;
  Dispose(pScanThread);
  if pCurrentPNG^ <> nil then
    pCurrentPNG^.Free;
  Dispose(pCurrentPNG);
end;

procedure TfrmMainT2V.FormCreate(Sender: TObject);
begin
  New(pScanThread);
  New(pCurrentPNG);
  pCurrentPNG^ := nil;
  pLastDir := GetStartDir;
  SetCLUTListToNoCLUT;
  Caption := Format('%s v%s', [cProgramName, cProgramVersion]);
  DragAcceptFiles(Handle, True);
  CheckButtonsAndMainMenu;

  if ParamCount > 0 then
    ScanPath(ParamStr(1));

  TEventWaitThread.Create(False);
end;

procedure TfrmMainT2V.GotoNextFile;
begin
  if (cbbFiles.ItemIndex + 1) <> cbbFiles.Items.Count then
    cbbFiles.ItemIndex := cbbFiles.ItemIndex + 1
  else
    cbbFiles.ItemIndex := 0;

  cbbFilesChange(Self);
end;

procedure TfrmMainT2V.GotoPreviousFile;
begin
  if cbbFiles.ItemIndex > 0 then
    cbbFiles.ItemIndex := cbbFiles.ItemIndex - 1
  else
    cbbFiles.ItemIndex := cbbFiles.Items.Count - 1;

  cbbFilesChange(Self);
end;

procedure TfrmMainT2V.grdCurrCLUTDblClick(Sender: TObject);
var
  TIM: PTIM;
  I, SELECTED_CELL, W, DIALOG_COLOR, CLUT_NUM: Integer;
  R, G, B: Byte;
  CLUT_COLOR: TCLUT_COLOR;
begin
  TIM := CurrentTIM;
  if TIM = nil then
    Exit;

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
    CurrentTimPos(lvList.Selected.Index), CurrentFileIsImage);

  FreeTIM(TIM);

  DrawCurrentTIM;
  DrawCurrentCLUT;
end;

procedure TfrmMainT2V.grdCurrCLUTDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  TIM: PTIM;
begin
  TIM := CurrentTIM;
  if TIM = nil then
    Exit;

  if not TIMHasCLUT(TIM) then
  begin
    FreeTIM(TIM);
    Exit;
  end;

  DrawClutCell(TIM, cbbCLUT.ItemIndex, @grdCurrCLUT, ACol, ARow);

  FreeTIM(TIM);
end;

procedure TfrmMainT2V.ScanDirectory(const Directory: string);
var
  sRec: TSearchRec;
  isFound: boolean;
  Dir: string;
begin
  Dir := IncludeTrailingPathDelimiter(Directory);
  isFound := FindFirst(Dir + '*.*', faAnyFile, sRec) = 0;
  while isFound do
  begin
    if (sRec.Name <> '.') and (sRec.Name <> '..') then
    begin
      if (sRec.Attr and faDirectory) = faDirectory then
        ScanDirectory(Dir + sRec.Name);
      ScanPath(Dir + sRec.Name);
    end;
    Application.ProcessMessages;
    isFound := FindNext(sRec) = 0;
  end;
  FindClose(sRec);
end;

procedure TfrmMainT2V.lvListClick(Sender: TObject);
var
  OFFSET, SIZE: DWORD;
begin
  if (lvList.Selected = nil) then
    Exit;

  cbbBitMode.ItemIndex := 0;

  OFFSET := CurrentTimPos(lvList.Selected.Index);
  SIZE := CurrentTimSize(lvList.Selected.Index);
  UpdateCLUTInfo;
  DrawCurrentTIM;
  if not mnSimpleMode.Checked then
    DrawCurrentCLUT;
  actTimInfo.Caption := Format('[OFFSET: 0x%x | SIZE: 0x%x]',
    [OFFSET, SIZE]);
  actTimInfo.Enabled := True;
  CheckButtonsAndMainMenu;
end;

procedure TfrmMainT2V.lvListData(Sender: TObject; Item: TListItem);
begin
  if cbbFiles.ItemIndex = -1 then
    Exit;
  if Results[cbbFiles.ItemIndex] = nil then
    Exit;

  Item.Caption := Format('%.6d', [Item.Index + 1]);
  Item.SubItems.Add(Format('%dx%d', [CurrentTimWidth(Item.Index),
    CurrentTimHeight(Item.Index)]));
  Item.SubItems.Add(Format('%d', [CurrentTimBitMode(Item.Index)]));
end;

procedure TfrmMainT2V.lvListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (lvList.Selected = nil) then
    Exit;

  if mnSimpleMode.Checked then
  begin
    if Key = VK_RIGHT then
      Key := VK_DOWN
    else if Key = VK_LEFT then
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
  else if (Key = VK_UP) then
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

procedure TfrmMainT2V.mnAdvancedModeClick(Sender: TObject);
begin
  CheckButtonsAndMainMenu;
end;

procedure TfrmMainT2V.mnSimpleModeClick(Sender: TObject);
begin
  CheckButtonsAndMainMenu;
end;

procedure TfrmMainT2V.ParseResult(Res: PNativeXML);
var
  Count: Integer;
  I: Integer;
  Node, TIM_NODE: TXmlNode;
  TIM: PTIM;
  OFFSET, SIZE: DWORD;
  FName, TIM_NAME, Path: string;
  BIT_MODE: Byte;
  IMAGE_SCAN: boolean;
begin
  Node := Res^.Root.FindNode(cResInfoNode);
  if Node = nil then
    Exit;

  Count := Node.ReadAttributeInteger(cResAttrTimsCount);
  lvList.Items.Count := Count;
  lvList.Column[0].Caption := Format('# / %d', [Count]);

  if not mnAutoExtract.Checked then
    Exit;

  lblStatus.Caption := sStatusBarTimsExtracting;
  pbProgress.Max := Count;
  pbProgress.Position := 0;

  FName := Node.ReadAttributeUnicodeString(cResAttrFile);
  IMAGE_SCAN := Node.ReadAttributeBool(cResAttrImageFile);
  Node := Res^.Root.FindNode(cResTimsNode);

  for I := 1 to Count do
  begin
    TIM_NODE := Node.Elements[I - 1];
    OFFSET := TIM_NODE.ReadAttributeInteger(cResTimAttrPos);
    SIZE := TIM_NODE.ReadAttributeInteger(cResTimAttrSize);
    BIT_MODE := TIM_NODE.ReadAttributeInteger(cResTimAttrBitMode);

    TIM_NAME := Format(cAutoExtractionTimFormat, [ExtractFileNameWOext(FName),
      I, BIT_MODE]);

    Path := IncludeTrailingPathDelimiter(GetStartDir + cExtractedTimsDir);
    CreateDir(Path);
    Path := IncludeTrailingPathDelimiter(Path + ExtractFileName(FName));
    CreateDir(Path);

    TIM := LoadTimFromFile(FName, OFFSET, IMAGE_SCAN, SIZE);
    SaveTimToFile(Path + TIM_NAME, TIM);
    FreeTIM(TIM);

    pbProgress.Position := I - 1;
    Application.ProcessMessages;
  end;

  pbProgress.Position := 0;
end;

procedure TfrmMainT2V.pbImagePaint(Sender: TObject);
begin
  DrawCurrentTIM;
end;

procedure TfrmMainT2V.ScanFile(const FileName: string);
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

procedure TfrmMainT2V.ScanFinished(Sender: TObject);
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

procedure TfrmMainT2V.ScanPath(const Path: string);
begin
  if Path = '' then Exit;

  if CheckFileExists(Path) then
    ScanFile(Path)
  else
    ScanDirectory(Path);
end;

procedure TfrmMainT2V.SetCLUTListToNoCLUT;
begin
  cbbCLUT.Items.BeginUpdate;
  cbbCLUT.Items.Clear;
  cbbCLUT.Items.Add(sThisTimHasNoClut);
  cbbCLUT.Items.EndUpdate;
  cbbCLUT.ItemIndex := 0;
end;

procedure TfrmMainT2V.UpdateCLUTInfo;
var
  TIM: PTIM;
  I, CLUTS: Word;
begin
  TIM := CurrentTIM;
  if TIM = nil then
    Exit;

  CLUTS := GetTIMClutsCount(TIM);
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

procedure TfrmMainT2V.WMDropFiles(var Msg: TWMDropFiles);
var
  I: Integer;
  CountFile: Integer;
  SIZE: Integer;
  FileName: PChar;
begin
  FileName := nil;
  try
    CountFile := DragQueryFile(Msg.Drop, $FFFFFFFF, FileName, 1024);

    for I := 0 to (CountFile - 1) do
    begin
      SIZE := DragQueryFile(Msg.Drop, I, nil, 0) + 1;
      FileName := StrAlloc(SIZE);
      DragQueryFile(Msg.Drop, I, FileName, SIZE);
      ScanPath(StrPas(FileName));
      StrDispose(FileName);
    end;
  finally
    DragFinish(Msg.Drop);
  end;

end;

end.
