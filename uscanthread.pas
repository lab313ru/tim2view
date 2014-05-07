unit uscanthread;

interface

uses
  ucommon, utim, uscanresult, classes, fgl;

type
  TScanThread = class(TThread)
  private
    { Private declarations }
    pScanResult: TScanResult;
    pResults: PScanResultList;
    pFileSize: Integer;
    pFilePos: Integer;
    pStatusText: string;
    pClearBufferPosition: Integer;
    pClearBufferSize: Integer;
    pSectorBufferSize: Integer;
    pSrcFileStream: TFileStream;
    pStopScan: boolean;
    procedure SetStatusText;
    procedure FinishScan;
    procedure UpdateProgressBar;
    procedure AddResult(TIM: PTIM);
    procedure ClearSectorBuffer(SectorBuffer, ClearBuffer: PBytesArray);
  protected
    procedure Execute; override;
  public
    constructor Create(const FileToScan: string; ImageScan: boolean; Results: PScanResultList);
    //property Started: boolean read pStarted write pStarted;
    property StopScan: boolean read pStopScan write pStopScan;
    property FileLength: Integer read pFileSize;
  end;
  TScanThreadList = specialize TFPGObjectList<TScanThread>;

implementation

uses
  umain, ucdimage, sysutils, FileUtil;

const
  cClearBufferSize = ((cTIMMaxSize div cSectorDataSize) + 1) * cSectorDataSize * 2;
  cSectorBufferSize = (cClearBufferSize div cSectorDataSize) * cSectorSize;

  { TScanThread }

constructor TScanThread.Create(const FileToScan: string; ImageScan: boolean; Results: PScanResultList);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  pClearBufferPosition := 0;
  pFilePos := 0;
  pFileSize := FileSize(FileToScan);
  pStatusText := '';
  pStopScan := False;

  pScanResult := TScanResult.Create;
  pScanResult.ScanFile := FileToScan;
  pScanResult.IsImage := ImageScan;
  pResults := Results;
end;

procedure TScanThread.AddResult(TIM: PTIM);
var
  ScanTim: TTimInfo;
begin
  ScanTim.Position := TIM^.dwTimPosition;
  ScanTim.Size := TIM^.dwSIZE;
  ScanTim.Width := GetTimRealWidth(TIM);
  ScanTim.Height := GetTimHeight(TIM);
  ScanTim.Bitmode := BppToBitMode(TIM);

  if TIMHasCLUT(TIM) then
    ScanTim.Cluts := GetTimClutsCount(TIM)
  else
    ScanTim.Cluts := 0;

  ScanTim.Good := TIMIsGood(TIM);

  pScanResult.Count := TIM^.dwTimNumber;
  pScanResult.ScanTim[pScanResult.Count - 1] := ScanTim;
end;

procedure TScanThread.Execute;
var
  SectorBuffer, ClearBuffer: PBytesArray;
  TIM: PTIM;
  pScanFinished: boolean;
  pRealBufSize, pTimPosition, pTIMNumber: Integer;
begin
  if pScanResult.IsImage then
    pSectorBufferSize := cSectorBufferSize
  else
    pSectorBufferSize := cClearBufferSize;

    pClearBufferSize := cClearBufferSize;

    SectorBuffer := GetMemory(pSectorBufferSize);
    ClearBuffer := GetMemory(pClearBufferSize);

    pSrcFileStream := TFileStream.Create(UTF8ToSys(pScanResult.ScanFile), fmOpenRead or fmShareDenyWrite);

    pSrcFileStream.Position := 0;

    TIM := CreateTIM;

    pStatusText := sStatusBarScanningFile;
    Synchronize(@SetStatusText);

    pRealBufSize := pSrcFileStream.Read(SectorBuffer^[0], pSectorBufferSize);
    Inc(pFilePos, pRealBufSize);
    ClearSectorBuffer(SectorBuffer, ClearBuffer);

    pScanFinished := False;
    pTIMNumber := 0;

    while (not pStopScan) and (not Terminated) do
    begin
      if LoadTimFromBuf(ClearBuffer, TIM, pClearBufferPosition) then
      begin
        if pScanResult.IsImage then
          pTimPosition := pFilePos - pRealBufSize +
          ((pClearBufferPosition - 1) div cSectorDataSize) * cSectorSize +
          ((pClearBufferPosition - 1) mod cSectorDataSize) + cSectorInfoSize
        else
          pTimPosition := pFilePos - pRealBufSize + (pClearBufferPosition - 1);

        if pTimPosition >= pFileSize then Break;

        TIM^.dwTimPosition := pTimPosition;
        Inc(pTIMNumber);
        TIM^.dwTimNumber := pTIMNumber;
        AddResult(TIM);
      end;

      if pClearBufferPosition = (pClearBufferSize div 2) then
      begin
        if pScanFinished then Break;

        pScanFinished := (pFilePos = pFileSize);
        pClearBufferPosition := 0;
        Move(SectorBuffer^[pSectorBufferSize div 2], SectorBuffer^[0], pSectorBufferSize div 2);

        if pScanFinished then
        begin
          if pRealBufSize >= (pSectorBufferSize div 2) then
          // Need to check file size
          pRealBufSize := pRealBufSize - (pSectorBufferSize div 2);
        end
        else
        begin
          pRealBufSize := pSrcFileStream.Read(SectorBuffer^[pSectorBufferSize div 2], pSectorBufferSize div 2);
          Inc(pFilePos, pRealBufSize);
          pRealBufSize := pRealBufSize + (pSectorBufferSize div 2);
        end;

        Synchronize(@UpdateProgressBar);

        ClearSectorBuffer(SectorBuffer, ClearBuffer);
      end;
    end;

  FreeTIM(TIM);
  FreeMemory(SectorBuffer);
  FreeMemory(ClearBuffer);

  pSrcFileStream.Free;
  pStopScan := True;
  pFilePos := 0;
  pStatusText := '';

  FinishScan;
end;

procedure TScanThread.FinishScan;
begin
  UpdateProgressBar;
  SetStatusText;

  if pScanResult.Count = 0 then
  begin
    pScanResult.Free;
    Exit;
  end;

  if not CheckForFileOpened(pResults, pScanResult.ScanFile) then
  begin
    pResults^.Add(pScanResult);
    frmMain.cbbFiles.Items.Add(pScanResult.ScanFile);
  end
  else
    pScanResult.Free;
end;

procedure TScanThread.SetStatusText;
begin
  frmMain.lblStatus.Caption := pStatusText;
end;

procedure TScanThread.UpdateProgressBar;
begin
  frmMain.pbProgress.Position := pFilePos;
  frmMain.lvList.Column[0].Caption := Format('# / %d', [pScanResult.Count]);
end;

procedure TScanThread.ClearSectorBuffer(SectorBuffer, ClearBuffer: PBytesArray);
var
  i: Integer;
begin
  FillChar(ClearBuffer^[0], pClearBufferSize, 0);
  if not pScanResult.IsImage then
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