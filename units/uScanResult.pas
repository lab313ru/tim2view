unit uScanResult;

interface

type
  TScanTim = record
    Position: Integer;
    Size: Integer;
    Width: Integer;
    Height: Integer;
    BitMode: Byte;
    Good: Boolean;
  end;

type
  TScanResult = class(TObject)
    private
      pScanFile: string;
      pIsImage: Boolean;
      pCount: Integer;
      pTims: array of TScanTim;

      procedure fSetCount(Value: Integer);

      function fGetTim(Index: Integer): TScanTim;
      procedure fSetTim(Index: Integer; Value: TScanTim);

    public
      constructor Create;
      destructor Destroy; override;

      property ScanFile: string read pScanFile write pScanFile;
      property IsImage: Boolean read pIsImage write pIsImage;
      property Count: Integer read pCount write fSetCount;

      property ScanTim[index: Integer]: TScanTim read fGetTim write fSetTim;
  end;

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

function TScanResult.fGetTim(Index: Integer): TScanTim;
begin
  Result := pTims[Index];
end;

procedure TScanResult.fSetCount(Value: Integer);
begin
  pCount := Value;
  SetLength(pTims, Value);
end;

procedure TScanResult.fSetTim(Index: Integer; Value: TScanTim);
begin
  pTims[Index] := Value;
end;

end.
