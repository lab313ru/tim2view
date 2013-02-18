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
    constructor Create(const FileToScan: string; fResult: pointer);
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

constructor TScanThread.Create(const FileToScan: string; fResult: pointer);
var
  Node: TXmlNode;
begin
  inherited Create(True);
  pClearBufferPosition := 0;
  pFileToScan := FileToScan;
  pFileSize := GetFileSZ(pFileToScan);
  pStatusText := '';
  pStopScan := False;

  pResult := fResult;
  pResult^.XmlFormat := xfCompact;

  pResult^.Root.Name := cResultsRootName;
  pResult^.Root.WriteAttributeString(cResultsAttributeVersion,
    cProgramVersion);
  Node := pResult^.Root.NodeNew(cResultsInfoNode);
  Node.WriteAttributeString(cResultsAttributeFile,
    ExtractFileName(pFileToScan));
  pImageScan := GetImageScan(pFileToScan);
  Node.WriteAttributeBool(cResultsAttributeImageFile, pImageScan);
  Node.WriteAttributeInteger(cResultsAttributeTimsCount, 0);
end;

procedure TScanThread.AddResult(TIM: PTIM);
var
  Node, AddedNode: TXmlNode;
  RWidth: WORD;
begin
  Node := pResult^.Root.NodeFindOrCreate(cResultsInfoNode);
  Node.WriteAttributeInteger(cResultsAttributeTimsCount, TIM^.dwTimNumber);

  Node := pResult^.Root.NodeFindOrCreate(cResultsTimsNode);

  AddedNode := Node.NodeNew(cResultsTimNode);
  AddedNode.WriteAttributeInteger(cResultsTimAttributeBitMode, TIM^.HEAD^.bBPP);
  RWidth := IWidthToRWidth(TIM^.HEAD, TIM^.IMAGE);
  AddedNode.WriteAttributeInteger(cResultsTimAttributeWidth, RWidth);
  AddedNode.WriteAttributeInteger(cResultsTimAttributeHeight,
    TIM^.IMAGE^.wHeight);
  AddedNode.WriteAttributeBool(cResultsTimAttributeGood, TIM^.bGOOD);
  AddedNode.WriteAttributeInteger(cResultsTimAttributeCLUTSize,
    GetTIMCLUTSize(TIM^.HEAD, TIM^.CLUT));
  AddedNode.WriteAttributeInteger(cResultsTimAttributeIMAGESize,
    GetTIMIMAGESize(TIM^.HEAD, TIM^.IMAGE));
  AddedNode.WriteAttributeString(cResultsTimAttributeFilePos,
                                 IntToHex(TIM^.dwTimPosition, 8));

  AddedNode.BufferWrite(TIM^.DATA^, TIM^.dwSIZE);
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
  ClearSectorBuffer(SectorBuffer, ClearBuffer);

  pScanFinished := False;
  pTIMNumber := 0;

  while not pStopScan do
  begin
    if TIMisHERE(ClearBuffer, TIM, pClearBufferPosition) then
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

      Synchronize(UpdateProgressBar);
      ClearSectorBuffer(SectorBuffer, ClearBuffer);
    end;
  end;
  FreeTIM(TIM);
  FreeMemory(SectorBuffer);
  FreeMemory(ClearBuffer);

  Synchronize(UpdateProgressBar);
  pSrcFileStream.Free;

  pStatusText := sStatusBarCalculatingCRC;
  Synchronize(SetStatusText);

  Node := pResult^.Root.NodeFindOrCreate(cResultsInfoNode);
  Node.WriteAttributeString(cResultsAttributeCRC32, FileCRC32(pFileToScan));
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

