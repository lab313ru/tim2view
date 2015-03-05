unit uscanresult;

interface

uses fgl;

type
  TTimInfo = record
    Magic: Byte;
    Position: Integer;
    Size: Integer;
    Width: Integer;
    Height: Integer;
    BitMode: Byte;
    Cluts: Integer;
    Good: Boolean;
  end;

type
  TScanResult = class(TObject)
    private
      pScanFile: string;
      pIsImage: Boolean;
      pCount: Integer;
      pTims: array of TTimInfo;

      procedure fSetCount(Value: Integer);

      function fGetTim(Index: Integer): TTimInfo;
      procedure fSetTim(Index: Integer; Value: TTimInfo);

    public
      constructor Create;
      destructor Destroy; override;

      property ScanFile: string read pScanFile write pScanFile;
      property IsImage: Boolean read pIsImage write pIsImage;
      property Count: Integer read pCount write fSetCount;

      property ScanTim[index: Integer]: TTimInfo read fGetTim write fSetTim;
  end;
  TScanResultList = specialize TFPGObjectList<TScanResult>;
  PScanResultList = ^TScanResultList;

  function CheckForFileOpened(ScanResults: PScanResultList; const FileName: string): boolean;

implementation

{ TScanResult }

constructor TScanResult.Create;
begin
  inherited;

  pScanFile := '';
  pIsImage := False;
  pCount := 0;
  pTims := nil;
end;

destructor TScanResult.Destroy;
begin
  SetLength(pTims, 0);
  pTims := nil;
  inherited;
end;

function TScanResult.fGetTim(Index: Integer): TTimInfo;
begin
  Result := pTims[Index];
end;

procedure TScanResult.fSetCount(Value: Integer);
begin
  pCount := Value;
  SetLength(pTims, Value);
end;

procedure TScanResult.fSetTim(Index: Integer; Value: TTimInfo);
begin
  pTims[Index] := Value;
end;

function CheckForFileOpened(ScanResults: PScanResultList; const FileName: string): boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 1 to ScanResults^.Count do
    if ScanResults^[I - 1].ScanFile = FileName then
    begin
      Result := True;
      Exit;
    end;
end;

end.
