unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.XPMan, Vcl.Grids, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls, NativeXml, uScanThread, uCommon,
  Vcl.CheckLst;

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
    procedure mnScanFileClick(Sender: TObject);
    procedure btnStopScanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure mnScanDirClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure mnCloseFileClick(Sender: TObject);
    procedure lvListClick(Sender: TObject);
  private
    { Private declarations }
    //pResult: PNativeXml;
    Results: array[0..cMaxFilesToOpen - 1] of PNativeXML;
    pScanThread: PScanThread;
    procedure ParseResult(Res: PNativeXML);
    procedure ScanFinished(Sender: TObject);
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
begin
  New(pScanThread);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
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

procedure TfrmMain.lvListClick(Sender: TObject);
begin
  if lvList.Items.Count = 0 then Exit;

  lvList.Column[0].Caption := Format('# (%d)', [lvList.Selected.Index + 1]);
end;

procedure TfrmMain.lvListData(Sender: TObject; Item: TListItem);
var
  Node, TIM_NODE: TXmlNode;
  RW, RH: Word;
  BIT_MODE: Integer;
  CurrentResult: PNativeXML;
begin
  if tbcMain.TabIndex = -1 then Exit;
  if Results[tbcMain.TabIndex] = nil then Exit;

  CurrentResult := Results[tbcMain.TabIndex];
  Node := CurrentResult^.Root.FindNode(cResultsTimsNode);

  TIM_NODE := Node.Elements[Item.Index];
  BIT_MODE := TIM_NODE.ReadAttributeInteger(cResultsTimAttributeBitMode);
  RW := TIM_NODE.ReadAttributeInteger(cResultsTimAttributeWidth);
  RH := TIM_NODE.ReadAttributeInteger(cResultsTimAttributeHeight);

  lvList.Items.BeginUpdate;
  Item.Caption := Format('%.6d', [Item.Index]);
  Item.SubItems.Add(Format('%dx%d', [RW, RH]));
  Item.SubItems.Add(Format('%d', [BIT_MODE]));
  lvList.Items.EndUpdate;
end;

procedure TfrmMain.mnCloseFileClick(Sender: TObject);
begin
  Results[tbcMain.TabIndex]^.Free;
  Dispose(Results[tbcMain.TabIndex]);
  lvList.Items.BeginUpdate;
  lvList.Items.Count := 0;
  lvList.Items.EndUpdate;
  lvList.Column[0].Caption := '#';
  tbcMain.Tabs.Delete(tbcMain.TabIndex);
  mnCloseFile.Enabled := (tbcMain.Tabs.Count <> 0);
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
  CurrentResult: PNativeXML;
begin
  if dlgOpenFile.InitialDir = '' then
    dlgOpenFile.InitialDir := GetStartDir;

  if not dlgOpenFile.Execute then
    Exit;

  btnStopScan.Enabled := True;

  fScanName := dlgOpenFile.FileName;
  tbcMain.Tabs.Add(ExtractFileName(fScanName));
  CreateDir(GetStartDir + cResultsDir);

  pbProgress.Max := GetFileSZ(fScanName);
  pbProgress.Position := 0;

  fResName := ChangeFileExt(GetStartDir + cResultsDir +
    ExtractFileName(fScanName), cResultsExt);

  New(Results[tbcMain.Tabs.Count - 1]);
  CurrentResult := Results[tbcMain.Tabs.Count - 1];
  CurrentResult^ := TNativeXML.CreateName(cResultsRootName);
  pScanThread^ := TScanThread.Create(fScanName, 0, CurrentResult);
  pScanThread^.FreeOnTerminate := True;
  pScanThread^.Priority := tpNormal;
  pScanThread^.OnTerminate := ScanFinished;
  pScanThread^.Start;

  repeat
    Application.ProcessMessages;
  until pScanThread^.Terminated;

  ParseResult(CurrentResult);

  CurrentResult^.SaveToFile(fResName);
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
  TIM_RES: PNativeXML;
  TIM_STREAM: TMemoryStream;
  BIT_MODE: Integer;
begin
  Node := Res^.Root.FindNode(cResultsInfoNode);
  COUNT := Node.ReadAttributeInteger(cResultsAttributeTimsCount);
  lvList.Items.Count := COUNT;

  if not mnAutoExtract.Checked then Exit;

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

    TIM_NAME := Format(cAutoExtractionTimFormat,
                       [ExtractFileNameWOext(fName), BIT_MODE, I]);

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

    Application.ProcessMessages;
  end;

  FreeTIM(TIM);
  Dispose(TIM_RES);
  FreeMemory(TIM_BUF);
end;

procedure TfrmMain.ScanFinished(Sender: TObject);
begin
  MessageBeep(MB_ICONASTERISK);
  btnStopScan.Enabled := False;
  mnCloseFile.Enabled := (tbcMain.Tabs.Count <> 0);
end;

end.
