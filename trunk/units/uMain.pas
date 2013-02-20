unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.XPMan, Vcl.Grids, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls, NativeXml, uScanThread, uCommon,
  Vcl.CheckLst;

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
    pgcMain: TPageControl;
    tsInfo: TTabSheet;
    tbInfo: TStringGrid;
    tsImage: TTabSheet;
    tsClut: TTabSheet;
    pnlImage: TPaintBox;
    pnlList: TPanel;
    grdCLUT: TDrawGrid;
    lvList: TListView;
    mnConfig: TMenuItem;
    mnAutoExtract: TMenuItem;
    procedure mnScanFileClick(Sender: TObject);
    procedure stbMainDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure btnStopScanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure mnScanDirClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvListChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  private
    { Private declarations }
    pResult: PNativeXml;
    pScanThread: PScanThread;
    procedure ParseResult(Res: PNativeXML);
    function TimsInGroup(GroupID: Integer): DWORD;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uDrawTIM, uTIM;

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

  New(pResult);
  New(pScanThread);

  lvList.Groups.Items[0].Header := sTimsListGoodGroup;
  lvList.Groups.Items[1].Header := sTimsListBadGroup;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Dispose(pResult);
  Dispose(pScanThread);
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

procedure TfrmMain.lvListChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if Sender is TListView then
  begin
    (Sender as TListView).Groups.Items[0].Header :=
      Format('%s (%d)', [sTimsListGoodGroup, TimsInGroup(0)]);
    (Sender as TListView).Groups.Items[1].Header :=
      Format('%s (%d)', [sTimsListGoodGroup, TimsInGroup(1)]);
  end;
end;

procedure TfrmMain.mnScanDirClick(Sender: TObject);
var
  TIM: PTIM;
  P: Cardinal;
begin
  P := 0;
  TIM := LoadTimFromFile('test.tim', P);

  DrawTIM(TIM, @pnlImage.Canvas, pnlImage.ClientRect);

  FreeTIM(TIM);
end;

procedure TfrmMain.mnScanFileClick(Sender: TObject);
var
  fScanName, fResName: string;
begin
  if dlgOpenFile.InitialDir = '' then
    dlgOpenFile.InitialDir := GetStartDir;

  if not dlgOpenFile.Execute then
    Exit;

  btnStopScan.Enabled := True;

  fScanName := dlgOpenFile.FileName;
  CreateDir(GetStartDir + cResultsDir);

  pbProgress.Max := GetFileSZ(fScanName);
  pbProgress.Position := 0;

  fResName := ChangeFileExt(GetStartDir + cResultsDir +
    ExtractFileName(fScanName), cResultsExt);

  pResult^ := TNativeXML.CreateName(cResultsRootName);
  pScanThread^ := TScanThread.Create(fScanName, 0, pResult);
  pScanThread^.Start;

  repeat
    Application.ProcessMessages;
  until pScanThread^.Terminated;

  ParseResult(pResult);

  pResult^.SaveToFile(fResName);
  pResult^.Free;

  Application.MessageBox(sScanResultGood, 'Information', MB_OK +
    MB_ICONINFORMATION + MB_TOPMOST);

  pbProgress.Position := 0;

  stbMain.Panels[0].Text := '';
  btnStopScan.Enabled := False;
end;

procedure TfrmMain.ParseResult(Res: PNativeXML);
var
  COUNT: integer;
  I: Integer;
  Node, TIM_NODE: TXmlNode;
  TIM_BUF: PBytesArray;
  TIM: PTIM;
  OFFSET: Cardinal;
  fName, TIM_NAME: string;
  GROUP: Byte;
  TIM_ITEM: TListItem;
  RW, RH: Word;
  TIM_RES: PNativeXML;
  TIM_STREAM: TMemoryStream;
  BIT_MODE: Integer;
  GOOD_TIM: Boolean;
begin
  stbMain.Panels[0].Text := sStatusBarParsingResult;

  Node := Res^.Root.FindNode(cResultsInfoNode);
  COUNT := Node.ReadAttributeInteger(cResultsAttributeTimsCount);
  fName := Node.ReadAttributeString(cResultsAttributeFile);

  TIM_BUF := GetMemory(cTIMMaxSize);
  Node := Res^.Root.FindNode(cResultsTimsNode);

  New(TIM_RES);
  TIM := CreateTIM;

  for I := 1 to COUNT do
  begin
    TIM_NODE := Node.Elements[I - 1];
    OFFSET := cHex2Int(TIM_NODE.ReadAttributeString(cResultsTimAttributePos));

    BIT_MODE := TIM_NODE.ReadAttributeInteger(cResultsTimAttributeBitMode);
    GOOD_TIM := TIM_NODE.ReadAttributeBool(cResultsTimAttributeGood);
    RW := TIM_NODE.ReadAttributeInteger(cResultsTimAttributeWidth);
    RH := TIM_NODE.ReadAttributeInteger(cResultsTimAttributeHeight);

    TIM_NAME := Format(cAutoExtractionTimFormat,
                       [ExtractFileNameWOext(fName), BIT_MODE, I]);

    if mnAutoExtract.Checked then
    begin
      CreateDir(GetStartDir + cExtractedTimsDir);

      TIM_RES^ := TNativeXml.CreateName(cResultsRootName);
      pScanThread^ := TScanThread.Create(fName, OFFSET, TIM_RES, 1);
      pScanThread^.Start;

      repeat
        Application.ProcessMessages;
      until pScanThread^.Terminated;

      TIM_STREAM := TMemoryStream.Create;
      TIM_NODE.BufferRead(TIM_BUF^[0], TIM_NODE.BufferLength);
      TIM_STREAM.Write(TIM_BUF^[0], TIM_NODE.BufferLength);
      TIM_STREAM.SaveToFile(GetStartDir + cExtractedTimsDir + TIM_NAME);
      TIM_STREAM.Free;

      TIM_RES^.Free;
    end;

    if GOOD_TIM then
      GROUP := 0
    else
      GROUP := 1;

    TIM_ITEM := lvList.Items.Add;
    TIM_ITEM.GroupID := GROUP;
    TIM_ITEM.Caption := Format('%.6d', [i]);
    TIM_ITEM.SubItems.Add(Format('%dx%d', [RW, RH]));
    TIM_ITEM.SubItems.Add(Format('%d', [BIT_MODE]));

    Application.ProcessMessages;
  end;

  FreeTIM(TIM);
  Dispose(TIM_RES);
  FreeMemory(TIM_BUF);
  stbMain.Panels[0].Text := '';
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

function TfrmMain.TimsInGroup(GroupID: Integer): DWORD;
var
  i: Integer;
begin
  result := 0;
  assert((GroupID >= 0) and (GroupID <= lvList.Groups.Count - 1));
  for i := 0 to lvList.Items.Count - 1 do
    if lvList.Items.Item[i].GroupID = GroupID then
      inc(result);
end;

end.
