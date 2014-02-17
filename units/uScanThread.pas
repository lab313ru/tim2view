unit uScanThread;

interface

uses
  Classes, Windows, uCommon, uTIM;

type
  PScanThread = ^TScanThread;

  TScanThread = class(Classes.TThread)
  private
    { Private declarations }
    pTims: Integer;
    pFileToScan: string;
    pImageScan: boolean;
    pResult: PNativeXml;
    pFileSize: DWORD;
    pFilePos: DWORD;
    pStatusText: string;
    pClearBufferPosition: DWORD;
    pClearBufferSize: DWORD;
    pSectorBufferSize: DWORD;
    pSrcFileStream: TFileStream;
    pStopScan: boolean;
    procedure SetStatusText;
    procedure UpdateProgressBar;
    procedure AddResult(TIM: PTIM);
    procedure ClearSectorBuffer(SectorBuffer, ClearBuffer: PBytesArray);
  protected
    procedure Execute; override;
  public
    constructor Create(const FileToScan: string; fResult: pointer;
      ImageScan: boolean);
    property Terminated;
    property StopScan: boolean write pStopScan;
  end;

implementation

uses
  uMain, uCDIMAGE, System.SysUtils, NativeXml;

const
  cClearBufferSize = ((cTIMMaxSize div cSectorDataSize) + 1) *
    cSectorDataSize * 2;
  cSectorBufferSize = (cClearBufferSize div cSectorDataSize) * cSectorSize;

  { TScanThread }

constructor TScanThread.Create(const FileToScan: string; fResult: pointer;
  ImageScan: boolean);
var
  Node: TXmlNode;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  pClearBufferPosition := 0;
  pFilePos := 0;
  pTims := 0;
  pFileToScan := FileToScan;
  pFileSize := GetFileSizeAPI(pFileToScan);
  pStatusText := '';
  pStopScan := False;
  pImageScan := ImageScan;

  pResult := fResult;
  Node := pResult^.Root.NodeNew(cResInfoNode);
  Node.WriteAttributeUnicodeString(cResAttrFile, pFileToScan);
  Node.WriteAttributeBool(cResAttrImageFile, ImageScan);
  Node.WriteAttributeInteger(cResAttrTimsCount, 0);
end;

procedure TScanThread.AddResult(TIM: PTIM);
var
  Node, AddedNode: TXmlNode;
begin
  Node := pResult^.Root.NodeFindOrCreate(cResInfoNode);
  Node.WriteAttributeInteger(cResAttrTimsCount, TIM^.dwTimNumber);

  Node := pResult^.Root.NodeFindOrCreate(cResTimsNode);

  AddedNode := Node.NodeNew(cResTimNode);
  AddedNode.WriteAttributeInteger(cResTimAttrPos, TIM^.dwTimPosition);
  AddedNode.WriteAttributeInteger(cResTimAttrSize, TIM^.dwSIZE);
  AddedNode.WriteAttributeInteger(cResTimAttrWidth, GetTimRealWidth(TIM));
  AddedNode.WriteAttributeInteger(cResTimAttrHeight, GetTimHeight(TIM));
  AddedNode.WriteAttributeInteger(cResTimAttrBitMode, BppToBitMode(TIM));
  AddedNode.WriteAttributeBool(cResTimAttrGood, TIMIsGood(TIM));

  Inc(pTims);
end;

procedure TScanThread.Execute;
var
  SectorBuffer, ClearBuffer: PBytesArray;
  TIM: PTIM;
  pScanFinished: boolean;
  pRealBufSize, pTimPosition, pTIMNumber: DWORD;
begin
  pSrcFileStream := TFileStream.Create(pFileToScan, fmOpenRead or
    fmShareDenyWrite);
  pSrcFileStream.Position := 0;

  if pImageScan then
    pSectorBufferSize := cSectorBufferSize
  else
    pSectorBufferSize := cClearBufferSize;

  pClearBufferSize := cClearBufferSize;

  SectorBuffer := GetMemory(pSectorBufferSize);
  ClearBuffer := GetMemory(pClearBufferSize);

  TIM := CreateTIM;

  pStatusText := sStatusBarScanningFile;
  Synchronize(SetStatusText);

  pRealBufSize := pSrcFileStream.Read(SectorBuffer^[0], pSectorBufferSize);
  Inc(pFilePos, pRealBufSize);
  ClearSectorBuffer(SectorBuffer, ClearBuffer);

  pScanFinished := False;
  pTIMNumber := 0;

  repeat
    if LoadTimFromBuf(ClearBuffer, TIM, pClearBufferPosition) then
    begin
      if pImageScan then
        pTimPosition := pFilePos - pRealBufSize +
          ((pClearBufferPosition - 1) div cSectorDataSize) * cSectorSize +
          ((pClearBufferPosition - 1) mod cSectorDataSize) + cSectorInfoSize
      else
        pTimPosition := pFilePos - pRealBufSize + (pClearBufferPosition - 1);

      if pTimPosition >= pFileSize then
        Break;

      TIM^.dwTimPosition := pTimPosition;
      Inc(pTIMNumber);
      TIM^.dwTimNumber := pTIMNumber;
      AddResult(TIM);
    end;

    if pClearBufferPosition = (pClearBufferSize div 2) then
    begin
      if pScanFinished then
        Break;

      pScanFinished := (pFilePos = pFileSize);
      pClearBufferPosition := 0;
      Move(SectorBuffer^[pSectorBufferSize div 2], SectorBuffer^[0],
        pSectorBufferSize div 2);

      if pScanFinished then
      begin
        if pRealBufSize >= (pSectorBufferSize div 2) then
        // Need to check file size
          pRealBufSize := pRealBufSize - (pSectorBufferSize div 2);
      end
      else
      begin
        pRealBufSize := pSrcFileStream.
          Read(SectorBuffer^[pSectorBufferSize div 2], pSectorBufferSize div 2);
        Inc(pFilePos, pRealBufSize);
        pRealBufSize := pRealBufSize + (pSectorBufferSize div 2);
      end;

      Synchronize(UpdateProgressBar);

      ClearSectorBuffer(SectorBuffer, ClearBuffer);
    end;
  until pStopScan;
  FreeTIM(TIM);
  FreeMemory(SectorBuffer);
  FreeMemory(ClearBuffer);

  Synchronize(UpdateProgressBar);

  pSrcFileStream.Free;
  pFilePos := 0;

  Synchronize(UpdateProgressBar);
  pStatusText := '';
  Synchronize(SetStatusText);
end;

procedure TScanThread.SetStatusText;
begin
  frmMain.lblStatus.Caption := pStatusText;
end;

procedure TScanThread.UpdateProgressBar;
begin
  frmMain.pbProgress.Position := pFilePos;
  frmMain.lvList.Column[0].Caption := Format('# / %d', [pTims]);
end;

procedure TScanThread.ClearSectorBuffer(SectorBuffer, ClearBuffer: PBytesArray);
var
  i: DWORD;
begin
  FillChar(ClearBuffer^[0], pClearBufferSize, 0);
  if not pImageScan then
  begin
    Move(SectorBuffer^[0], ClearBuffer^[0], pClearBufferSize);
    Exit;
  end;
  for i := 1 to (pSectorBufferSize div cSectorSize) do
  begin
    Move(SectorBuffer^[(i - 1) * cSectorSize + cSectorInfoSize],
      ClearBuffer^[(i - 1) * cSectorDataSize], cSectorDataSize);
  end;
end;

end.
