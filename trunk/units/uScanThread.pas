unit uScanThread;

interface

uses
  Classes, Windows, crc32, uCommon, uTIM;

type
  PScanThread = ^TScanThread;
  TScanThread = class(Classes.TThread)
  private
    { Private declarations }
    pFileToScan: string;
    pStartPos: DWORD;
    pTimsLimit: DWORD;
    pImageScan: boolean;
    pResult: PNativeXml;
    pFileSize: DWORD;
    pStatusText: string;
    pClearBufferPosition: DWORD;
    pClearBufferSize: DWORD;
    pSectorBufferSize: DWORD;
    pSrcFileStream: TFileStream;
    pStopScan: Boolean;
    procedure SetStatusText;
    procedure UpdateProgressBar;
    procedure AddResult(TIM: PTIM);
    procedure ClearSectorBuffer(SectorBuffer, ClearBuffer: PBytesArray);
  protected
    procedure Execute; override;
  public
    constructor Create(const FileToScan: string; FromPosition: DWORD;
                       fResult: pointer; Limit: DWORD = 0);
    destructor Destroy; override;
    property Terminated;
    property StopScan: boolean write pStopScan;
  end;

implementation

uses
  uMain, uCDIMAGE, System.SysUtils, NativeXml;

const  
  cClearBufferSize = ((cTIMMaxSize div cSectorDataSize) + 1) * cSectorDataSize * 2;
  cSectorBufferSize = (cClearBufferSize div cSectorDataSize) * cSectorSize;

{ TScanThread }

constructor TScanThread.Create(const FileToScan: string; FromPosition: DWORD;
                               fResult: pointer; Limit: DWORD = 0);
var
  Node: TXmlNode;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  Priority := tpHigher;
  pStartPos := FromPosition;
  pTimsLimit := Limit;
  pClearBufferPosition := 0;
  pFileToScan := FileToScan;
  pFileSize := GetFileSZ(pFileToScan);
  pStatusText := '';
  pStopScan := False;

  pResult := fResult;
  pResult^.Root.WriteAttributeString(cResultsAttributeVersion,
    cProgramVersion);
  Node := pResult^.Root.NodeNew(cResultsInfoNode);
  Node.WriteAttributeString(cResultsAttributeFile, pFileToScan);
  pImageScan := GetImageScan(pFileToScan);
  Node.WriteAttributeBool(cResultsAttributeImageFile, pImageScan);
  Node.WriteAttributeInteger(cResultsAttributeTimsCount, 0);
end;

procedure TScanThread.AddResult(TIM: PTIM);
var
  Node, AddedNode: TXmlNode;
begin
  Node := pResult^.Root.NodeFindOrCreate(cResultsInfoNode);
  Node.WriteAttributeInteger(cResultsAttributeTimsCount, TIM^.dwTimNumber);

  Node := pResult^.Root.NodeFindOrCreate(cResultsTimsNode);

  AddedNode := Node.NodeNew(cResultsTimNode);
  AddedNode.WriteAttributeString(cResultsTimAttributePos,
                                 IntToHex(TIM^.dwTimPosition, 8));
  AddedNode.WriteAttributeString(cResultsTimAttributeSize,
                                 IntToHex(TIM^.dwSIZE, 6));
  AddedNode.WriteAttributeInteger(cResultsTimAttributeWidth,
                                  GetTimRealWidth(TIM));
  AddedNode.WriteAttributeInteger(cResultsTimAttributeHeight,
                                  GetTimHeight(TIM));
  AddedNode.WriteAttributeInteger(cResultsTimAttributeBitMode,
                                  BppToBitMode(TIM));
  AddedNode.WriteAttributeBool(cResultsTimAttributeGood, TIMIsGood(TIM));

  if pTimsLimit = 1 then
  AddedNode.BufferWrite(TIM^.DATA^[0], TIM^.dwSIZE);
end;

procedure TScanThread.Execute;
var
  Node: TXmlNode;
  SectorBuffer, ClearBuffer: PBytesArray;
  TIM: PTIM;
  pScanFinished: Boolean;
  pRealBufSize, pTimPosition, pTIMNumber: DWORD;
begin
  if not CheckFileExists(pFileToScan) then Terminate;

  pSrcFileStream := TFileStream.Create(pFileToScan, fmOpenRead);
  pSrcFileStream.Seek(pStartPos, soBeginning);

  if pImageScan then
    pSectorBufferSize := cSectorBufferSize
  else
    pSectorBufferSize := cClearBufferSize;

  pClearBufferSize := cClearBufferSize;

  SectorBuffer := GetMemory(pSectorBufferSize);
  ClearBuffer := GetMemory(pClearBufferSize);

  TIM := CreateTIM;

  if pTimsLimit <> 1 then
  begin
    pStatusText := sStatusBarScanningFile;
    Synchronize(SetStatusText);
  end;

  pRealBufSize := pSrcFileStream.Read(SectorBuffer^[0], pSectorBufferSize);
  ClearSectorBuffer(SectorBuffer, ClearBuffer);

  pScanFinished := False;
  pTIMNumber := 0;

  repeat
    if LoadTimFromBuf(ClearBuffer, TIM, pClearBufferPosition) then
    begin
      if pImageScan then
        pTimPosition := pSrcFileStream.Position - pRealBufSize +
                        ((pClearBufferPosition - 1) div cSectorDataSize) *
                        cSectorSize +
                        ((pClearBufferPosition - 1) mod cSectorDataSize) +
                        cSectorInfoSize
      else
        pTimPosition := pSrcFileStream.Position - pRealBufSize +
                        (pClearBufferPosition - 1);

      TIM^.dwTimPosition := pTimPosition;
      inc(pTIMNumber);
      TIM^.dwTimNumber := pTIMNumber;
      AddResult(TIM);
    end;

    if pClearBufferPosition = (pClearBufferSize div 2) then
    begin
      if pScanFinished then Break;
      pScanFinished := (pSrcFileStream.Position = pFileSize);
      pClearBufferPosition := 0;
      Move(SectorBuffer^[pSectorBufferSize div 2], SectorBuffer^[0], pSectorBufferSize div 2);

      if pScanFinished then
      begin
        if pRealBufSize >= (pSectorBufferSize div 2) then   //Need to check file size
        pRealBufSize := pRealBufSize - (pSectorBufferSize div 2) ;
      end
      else
      begin
        pRealBufSize := pSrcFileStream.Read(SectorBuffer^[pSectorBufferSize div 2], pSectorBufferSize div 2);
        pRealBufSize := pRealBufSize + (pSectorBufferSize div 2);
      end;

      if pTimsLimit <> 1 then
      Synchronize(UpdateProgressBar);

      ClearSectorBuffer(SectorBuffer, ClearBuffer);
    end;
  until pStopScan or ((pTimsLimit = pTIMNumber) and (pTimsLimit <> 0));
  FreeTIM(TIM);
  FreeMemory(SectorBuffer);
  FreeMemory(ClearBuffer);

  if pTimsLimit <> 1 then
  Synchronize(UpdateProgressBar);

  pSrcFileStream.Free;

  if pTimsLimit = 1 then Exit;

  pStatusText := sStatusBarCalculatingCRC;
  Synchronize(SetStatusText);

  Node := pResult^.Root.NodeFindOrCreate(cResultsInfoNode);
  Node.WriteAttributeString(cResultsAttributeCRC32, FileCRC32(pFileToScan));
  Terminate;
end;

destructor TScanThread.Destroy;
begin
  pStatusText := '';
  Synchronize(SetStatusText);
  inherited;
end;

procedure TScanThread.SetStatusText;
begin
  frmMain.stbMain.Panels[0].Text := pStatusText;
end;

procedure TScanThread.UpdateProgressBar;
begin
  frmMain.pbProgress.Position := pSrcFileStream.Position;
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

