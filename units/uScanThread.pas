unit uScanThread;

interface

uses
  Classes, Windows, uCommon, uTIM, uScanResult;

type
  TScanThread = class(Classes.TThread)
  private
    { Private declarations }
    pScanResult: TScanResult;
    pFileSize: Integer;
    pFilePos: Integer;
    pStatusText: string;
    pClearBufferPosition: Integer;
    pClearBufferSize: Integer;
    pSectorBufferSize: Integer;
    pSrcFileStream: TFileStream;
    pStopScan: boolean;
    procedure SetStatusText;
    procedure StartScan;
    procedure FinishScan;
    procedure UpdateProgressBar;
    procedure AddResult(TIM: PTIM);
    procedure ClearSectorBuffer(SectorBuffer, ClearBuffer: PBytesArray);
  protected
    procedure Execute; override;
  public
    constructor Create(const FileToScan: string; ImageScan: boolean);
    //property Started: boolean read pStarted write pStarted;
    property StopScan: boolean write pStopScan;
  end;

implementation

uses
  uMain, uCDIMAGE, System.SysUtils;

const
  cClearBufferSize = ((cTIMMaxSize div cSectorDataSize) + 1) *
    cSectorDataSize * 2;
  cSectorBufferSize = (cClearBufferSize div cSectorDataSize) * cSectorSize;

  { TScanThread }

constructor TScanThread.Create(const FileToScan: string; ImageScan: boolean);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  pClearBufferPosition := 0;
  pFilePos := 0;
  pFileSize := GetFileSizeAPI(FileToScan);
  pStatusText := '';
  pStopScan := False;

  pScanResult := TScanResult.Create;
  pScanResult.ScanFile := FileToScan;
  pScanResult.IsImage := ImageScan;
end;

procedure TScanThread.AddResult(TIM: PTIM);
var
  ScanTim: TScanTim;
begin
  ScanTim.Position := TIM^.dwTimPosition;
  ScanTim.Size := TIM^.dwSIZE;
  ScanTim.Width := GetTimRealWidth(TIM);
  ScanTim.Height := GetTimHeight(TIM);
  ScanTim.Bitmode := BppToBitMode(TIM);
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
  Synchronize(StartScan);

  pSrcFileStream := TFileStream.Create(pScanResult.ScanFile, fmOpenRead or
    fmShareDenyWrite);
  pSrcFileStream.Position := 0;

  if pScanResult.IsImage then
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

      Synchronize(UpdateProgressBar);

      ClearSectorBuffer(SectorBuffer, ClearBuffer);
    end;
  until pStopScan;
  FreeTIM(TIM);
  FreeMemory(SectorBuffer);
  FreeMemory(ClearBuffer);

  pSrcFileStream.Free;
  pFilePos := 0;
  pStatusText := '';

  Synchronize(FinishScan);
end;

procedure TScanThread.FinishScan;
begin
  UpdateProgressBar;
  SetStatusText;

  if pScanResult.Count = 0 then Exit;
  frmMain.ScanResult.Add(pScanResult);
  frmMain.cbbFiles.Items.Add(pScanResult.ScanFile);
end;

procedure TScanThread.SetStatusText;
begin
  frmMain.lblStatus.Caption := pStatusText;
end;

procedure TScanThread.StartScan;
begin
  frmMain.btnStopScan.Enabled := True;
  frmMain.cbbFiles.Enabled := False;
  frmMain.lvList.Enabled := False;
  frmMain.actExtractList.Enabled := False;

  frmMain.pbProgress.Max := GetFileSizeAPI(pScanResult.ScanFile);
  frmMain.pbProgress.Position := 0;
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
