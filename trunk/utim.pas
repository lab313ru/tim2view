unit utim;

interface

uses
  ucommon;

const
  cTIMMagic = $10;
  cTIM4C = $08;
  cTIM4NC = $00;
  cTIM4 = [cTIM4C, cTIM4NC];
  cTIM8C = $09;
  cTIM8NC = $01;
  cTIM8 = [cTIM8C, cTIM8NC];
  cTIM16C = $0A;
  cTIM16NC = $02;
  cTIM16 = [cTIM16C, cTIM16NC];
  cTIM24C = $0B;
  cTIM24NC = $03;
  cTIM24 = [cTIM24C, cTIM24NC];
  cTIMMix = $04;
  cTIMVersions = [$00, $01];
  cTIMWrongBads = [cTIM4NC, cTIM8NC, cTIMMix];
  cTIMCLUT = [cTIM4C, cTIM8C, cTIM16C, cTIM24C];
  cTIMNOCLUT = [cTIM4NC, cTIM8NC, cTIM16NC, cTIM24NC, cTIMMix];
  cTIMBpp = [cTIM4C, cTIM8C, cTIM16C, cTIM24C, cTIM4NC, cTIM8NC, cTIM16NC,
    cTIM24NC, cTIMMix];

  cCLUTColorsMax = 1024;
  cCLUTCountMax = 512;
  cIMAGEWidthMax = 1024;
  cIMAGEHeightMax = 1024;
  cCLUTHeadSize = $0C;
  cIMAGEHeadSize = $0C;
  cTIMHeadSize = 8;
  cRandomPaletteSize = $100;
  cTIMMaxSize = cTIMHeadSize + cCLUTColorsMax * cCLUTCountMax * 2 +
    cCLUTHeadSize + cIMAGEWidthMax * cIMAGEHeightMax * 2 + cIMAGEHeadSize;

type
  TTIMHeader = packed record // TIM Header (8 bytes)
    bMagic: byte; // $10 (1 byte)
    bVersion: byte; // Any? (1 byte)
    bReserved1: byte; // Reserved byte 1 (1 byte)
    bReserved2: byte; // Reserved byte 2 (1 byte)
    bBPP: Integer; // Bit per Pixel  (4 bytes)
    // variants:
    // [$08, $09, $0A, $0B, $02, $03, $00, $01]
  end;

  PTIMHeader = ^TTIMHeader;

type
  TCLUTHeader = packed record // CLUT header (12+ bytes)
    dwSize: Integer; // Length of CLUT (4 bytes)
    wVRAMX: word; // Palette coordinates in VRAM (by X) (2 bytes)
    wVRAMY: word; // Palette coordinates in VRAM (by Y) (2 bytes)
    wColorsCount: word; // Number of CLUT Colors (2 bytes)
    wClutsCount: word; // Count of Palettes (2 bytes)
  end;

  PCLUTHeader = ^TCLUTHeader;

type
  TIMAGEHeader = packed record // IMAGE Block Header (12+ bytes)
    dwSize: Integer; // Length of Image Block (4 bytes)
    wVRAMX: word; // Image Block Coordinates in VRAM (by X) (2 bytes)
    wVRAMY: word; // Image Block Coordinates in VRAM (by Y) (2 bytes)
    wWidth: word; // Image Width (not Real) (2 bytes)
    wHeight: word; // Image Height (Real) (2 bytes)
  end;

  PIMAGEHeader = ^TIMAGEHeader;

type
  TTIMDataArray = array [0 .. cTIMMaxSize - 1] of byte;
  PTIMDataArray = ^TTIMDataArray;

type
  TCLUT_COLOR = record
    // stp (special transparency processing) D=[0,1]
    STP: byte;
    // r,g,b  D=[0,31]
    R: byte;
    G: byte;
    B: byte;
  end;

  PCLUT_COLOR = ^TCLUT_COLOR;
  TCLUT_COLORS = array [0 .. cCLUTColorsMax * cCLUTCountMax - 1] of TCLUT_COLOR;
  PCLUT_COLORS = ^TCLUT_COLORS;

type
  TIMAGE_INDEXES = array [0 .. cIMAGEWidthMax * cIMAGEHeightMax * 4 -
    1] of Integer;
  PIMAGE_INDEXES = ^TIMAGE_INDEXES;

type
  TTIM = record
    dwTimNumber: Integer;
    dwTimPosition: Integer;
    HEAD: PTIMHeader;
    CLUT: PCLUTHeader;
    IMAGE: PIMAGEHeader;
    dwSize: Integer;
    DATA: PTIMDataArray;
    bGOOD: Boolean;
  end;

  PTIM = ^TTIM;

function TIMHasCLUT(TIM: PTIM): Boolean;
function GetTIMCLUTSize(TIM: PTIM): Integer;
function GetTIMSize(TIM: PTIM): Integer;
function GetTimWidth(TIM: PTIM): word;
function GetTimRealWidth(TIM: PTIM): word;
function GetTimHeight(TIM: PTIM): word;
function TIMIsGood(TIM: PTIM): Boolean;
function LoadTimFromBuf(BUFFER: pointer; var TIM: PTIM;
  var Position: Integer): Boolean;
function LoadTimFromFile(const FileName: string; var Position: Integer;
  ImageScan: Boolean; dwSize: Integer): PTIM;
procedure SaveTimToFile(const FileName: string; TIM: PTIM);
function CreateTIM: PTIM;
procedure FreeTIM(TIM: PTIM);
function BppToBitMode(TIM: PTIM): byte;
function GetTimColorsCount(TIM: PTIM): word;
function GetTimClutsCount(TIM: PTIM): word;
function GetTimVersion(TIM: PTIM): byte;
function GetTimBPP(TIM: PTIM): Integer;
function GetTimClutSizeHeader(TIM: PTIM): Integer;
function GetTimClutVRAMX(TIM: PTIM): word;
function GetTimClutVRAMY(TIM: PTIM): word;
function GetTimImageSizeHeader(TIM: PTIM): Integer;
function GetTimImageVRAMX(TIM: PTIM): word;
function GetTimImageVRAMY(TIM: PTIM): word;
function GetTIMIMAGESize(TIM: PTIM): Integer;
function GetCLUTColor(TIM: PTIM; CLUT_NUM, COLOR_NUM: Integer): TCLUT_COLOR;
procedure WriteCLUTColor(TIM: PTIM; CLUT_NUM, COLOR_NUM: Integer;
  COLOR: TCLUT_COLOR);
function ConvertTIMColor(COLOR: word): TCLUT_COLOR;
function ConvertCLUTColor(COLOR: TCLUT_COLOR): word;

implementation

uses
  ucdimage, classes, sysutils, FileUtil;

function ConvertTIMColor(COLOR: word): TCLUT_COLOR;
begin
  Result.R := (COLOR and $1F) * 8;
  Result.G := ((COLOR and $3E0) shr 5) * 8;
  Result.B := ((COLOR and $7C00) shr 10) * 8;
  Result.STP := ((COLOR and $8000) shr 15);
end;

function ConvertCLUTColor(COLOR: TCLUT_COLOR): word;
begin
  Result := (COLOR.STP shl 15) or ((COLOR.B div 8) shl 10) or ((COLOR.G div 8) shl 5) or (COLOR.R div 8);
end;

function GetCLUTColor(TIM: PTIM; CLUT_NUM, COLOR_NUM: Integer): TCLUT_COLOR;
var
  CLUT_OFFSET: Integer;
  COLOR: word;
begin
  if (TIM^.HEAD^.bBPP in [cTIM4NC, cTIM8NC]) then
  begin
    Result.R := random($20) * 8;
    Result.G := random($20) * 8;
    Result.B := random($20) * 8;
    Result.STP := 1;
    Exit;
  end;

  CLUT_OFFSET := CLUT_NUM * GetTimColorsCount(TIM) * 2;

  Move(TIM^.DATA^[cTIMHeadSize + cCLUTHeadSize + COLOR_NUM * 2 + CLUT_OFFSET], COLOR, 2);

  Result := ConvertTIMColor(COLOR);
end;

procedure WriteCLUTColor(TIM: PTIM; CLUT_NUM, COLOR_NUM: Integer;
  COLOR: TCLUT_COLOR);
var
  CLUT_OFFSET: Integer;
  COLOR_TO_WRITE: word;
begin
  CLUT_OFFSET := CLUT_NUM * GetTimColorsCount(TIM) * 2;

  COLOR_TO_WRITE := ConvertCLUTColor(COLOR);
  Move(COLOR_TO_WRITE, TIM^.DATA^[cTIMHeadSize + cCLUTHeadSize + COLOR_NUM * 2 +
    CLUT_OFFSET], 2);
end;

function GetTimHeight(TIM: PTIM): word;
begin
  Result := TIM^.IMAGE^.wHeight;
end;

function GetTIMCLUTSize(TIM: PTIM): Integer;
begin
  Result := 0;

  if not TIMHasCLUT(TIM) then
    Exit;
  Result := TIM^.CLUT^.wColorsCount * TIM^.CLUT^.wClutsCount * 2 +
    cCLUTHeadSize;
end;

function GetTIMIMAGESize(TIM: PTIM): Integer;
begin
  Result := TIM^.IMAGE^.wWidth * TIM^.IMAGE^.wHeight * 2 + cIMAGEHeadSize;
end;

function GetTIMSize(TIM: PTIM): Integer;
begin
  Result := GetTIMCLUTSize(TIM) + GetTIMIMAGESize(TIM) + cTIMHeadSize;
end;

function CheckVersion(TIM: PTIM): Boolean;
begin
  Result := (TIM^.HEAD^.bVersion in cTIMVersions);
end;

function CheckMagic(TIM: PTIM): Boolean;
begin
  Result := (TIM^.HEAD^.bMagic = cTIMMagic);
end;

function CheckBpp(TIM: PTIM): Boolean;
begin
  Result := (TIM^.HEAD^.bBPP in cTIMBpp);
end;

function CheckReserved(TIM: PTIM): Boolean;
begin
  Result := (TIM^.HEAD^.bReserved1 = 0) and (TIM^.HEAD^.bReserved2 = 0);
end;

function TIMHasCLUT(TIM: PTIM): Boolean;
begin
  Result := (TIM^.HEAD^.bBPP in cTIMCLUT);
end;

function CheckCLUTColors(TIM: PTIM): Boolean;
begin
  Result := (TIM^.CLUT^.wColorsCount >= 1) and
    (TIM^.CLUT^.wColorsCount <= cCLUTColorsMax);
end;

function CheckCLUTCount(TIM: PTIM): Boolean;
begin
  Result := (TIM^.CLUT^.wClutsCount >= 1) and
    (TIM^.CLUT^.wClutsCount <= cCLUTCountMax);
end;

function IWidthToRWidth(TIM: PTIM): word;
begin
  case TIM^.HEAD^.bBPP of
    cTIM4C, cTIM4NC:
      Result := (TIM^.IMAGE^.wWidth * 4) and $FFFF;
    cTIM8C, cTIM8NC:
      Result := (TIM^.IMAGE^.wWidth * 2) and $FFFF;
    cTIM16C, cTIM16NC, cTIMMix:
      Result := TIM^.IMAGE^.wWidth;
    cTIM24C, cTIM24NC:
      Result := (Round(TIM^.IMAGE^.wWidth * 2 / 3)) and $FFFF;
  else
    Result := 0;
  end;
end;

function CheckHEAD(TIM: PTIM): Boolean;
begin
  Result := (CheckMagic(TIM) and CheckVersion(TIM) and CheckBpp(TIM) and
    CheckReserved(TIM))
end;

function CheckCLUT(TIM: PTIM): Boolean;
begin
  Result := (CheckCLUTColors(TIM) and CheckCLUTCount(TIM)
    // Need to Check CLUT^.dwSize
    );
end;

function CheckTIMSize(TIM: PTIM): Boolean;
begin
  Result := (GetTIMSize(TIM) <= cTIMMaxSize);
end;

function TIMIsGood(TIM: PTIM): Boolean;
begin
  Result := (TIM^.IMAGE^.dwSize = GetTIMIMAGESize(TIM));
end;

function CheckIMAGE(TIM: PTIM): Boolean;
begin
  Result := False;

  if (TIM^.IMAGE^.wWidth = 0) or (TIM^.IMAGE^.wHeight = 0) then
    Exit;

  if (TIM^.IMAGE^.wWidth > cIMAGEWidthMax) or
    (TIM^.IMAGE^.wHeight > cIMAGEHeightMax) then
    Exit;

  Result := (not(TIM^.HEAD^.bBPP in cTIMWrongBads)) or TIMIsGood(TIM);
end;

procedure ClearTIM(TIM: PTIM);
begin
  FillChar(TIM^.HEAD^, cTIMHeadSize, 0);
  FillChar(TIM^.CLUT^, cCLUTHeadSize, 0);
  FillChar(TIM^.IMAGE^, cIMAGEHeadSize, 0);
  FillChar(TIM^.DATA^, cTIMMaxSize, 0);
end;

function LoadTimFromBuf(BUFFER: pointer; var TIM: PTIM;
  var Position: Integer): Boolean;
var
  P: Integer;
  TIM_POS: Integer;
begin
  Result := False;

  P := Position;
  Inc(Position);
  TIM_POS := P;

  if TIM = nil then
    TIM := CreateTIM;

  Move(PBytesArray(BUFFER)^[P], TIM^.HEAD^, cTIMHeadSize);
  if not CheckHEAD(TIM) then
    Exit;
  Inc(P, cTIMHeadSize);

  if TIMHasCLUT(TIM) then
  begin
    Move(PBytesArray(BUFFER)^[P], TIM^.CLUT^, cCLUTHeadSize);
    if not CheckCLUT(TIM) then
      Exit;
    Inc(P, GetTIMCLUTSize(TIM));
  end;

  Move(PBytesArray(BUFFER)^[P], TIM^.IMAGE^, cIMAGEHeadSize);

  if not CheckIMAGE(TIM) then
    Exit;
  if not CheckTIMSize(TIM) then
    Exit;

  TIM^.dwSize := GetTIMSize(TIM);
  TIM^.bGOOD := TIMIsGood(TIM);

  Move(PBytesArray(BUFFER)^[TIM_POS], TIM^.DATA^[0], TIM^.dwSize);

  Result := True;
end;

function LoadTimFromCDFile(const FileName: string; var Position: Integer;
  SIZE: Integer): PTIM;
var
  TimOffsetInSector, FirstPartSize, LastPartSize: Integer;
  TimSectorNumber, TimStartSectorPos: Integer;
  TIM_BUF: PTIMDataArray;
  sImageStream: TFileStream;
  Sector: TCDSector;
  P, TIM_FULL_SECTORS: Integer;
begin
  try
    sImageStream := TFileStream.Create(UTF8ToSys(FileName), fmOpenRead or fmShareDenyWrite);

    TimSectorNumber := Position div cSectorSize + 1;
    TimOffsetInSector := Position mod cSectorSize - cSectorInfoSize;
    TimStartSectorPos := (TimSectorNumber - 1) * cSectorSize;
    FirstPartSize := cSectorDataSize - TimOffsetInSector;

    New(TIM_BUF);
    P := 0;

    if SIZE < FirstPartSize then
      FirstPartSize := SIZE;

    sImageStream.Seek(TimStartSectorPos, soBeginning);
    sImageStream.Read(Sector, cSectorSize);

    Move(Sector.dwData[TimOffsetInSector], TIM_BUF^[P], FirstPartSize);
    Inc(P, FirstPartSize);

    Inc(TimStartSectorPos, cSectorSize);
    sImageStream.Seek(TimStartSectorPos, soBeginning);

    TIM_FULL_SECTORS := (SIZE - P) div cSectorDataSize;

    while TIM_FULL_SECTORS > 0 do
    begin
      sImageStream.Read(Sector, cSectorSize);

      Move(Sector.dwData[0], TIM_BUF^[P], cSectorDataSize);
      Inc(P, cSectorDataSize);

      Inc(TimStartSectorPos, cSectorSize);
      sImageStream.Seek(TimStartSectorPos, soBeginning);

      Dec(TIM_FULL_SECTORS);
    end;

    sImageStream.Read(Sector, cSectorSize);

    if SIZE > P then
    begin
      LastPartSize := SIZE - P;
      Move(Sector.dwData[0], TIM_BUF^[P], LastPartSize);
    end;
  finally
    P := 0;
    Result := nil;
    LoadTimFromBuf(TIM_BUF, Result, P);
    sImageStream.Free;
    Dispose(TIM_BUF);
  end;
end;

function LoadTimFromStream(Stream: TStream; var Position: Integer;
  dwSize: Integer): PTIM;
var
  BUF: PTIMDataArray;
  P: Integer;
begin
  Result := nil;

  if dwSize > cTIMMaxSize then
    Exit;

  New(BUF);
  Result := CreateTIM;

  Stream.Seek(Position, soBeginning);
  Stream.Read(BUF^[0], dwSize);

  P := 0;
  if not LoadTimFromBuf(BUF, Result, P) then
    FreeTIM(Result);

  Dispose(BUF);
end;

function LoadTimFromFile(const FileName: string; var Position: Integer;
  ImageScan: Boolean; dwSize: Integer): PTIM;
var
  sTIM: TFileStream;
begin
  if not ImageScan then
  begin
    try
      sTIM := TFileStream.Create(UTF8ToSys(FileName), fmOpenRead or fmShareDenyWrite);
      Result := LoadTimFromStream(sTIM, Position, dwSize);
    finally
      sTIM.Free;
    end;
    Exit;
  end;

  Result := LoadTimFromCDFile(FileName, Position, dwSize);
end;

procedure SaveTimToFile(const FileName: string; TIM: PTIM);
var
  tmp: TFileStream;
begin
  if TIM = nil then Exit;

  tmp := TFileStream.Create(UTF8ToSys(FileName), fmOpenWrite or fmCreate, fmShareDenyRead);
  tmp.Write(TIM^.DATA^[0], TIM^.dwSize);
  tmp.Free;
end;

function CreateTIM: PTIM;
begin
  New(Result);

  New(Result^.HEAD);
  New(Result^.CLUT);
  New(Result^.IMAGE);
  Result^.dwSize := 0;
  Result^.dwTimPosition := 0;
  Result^.dwTimNumber := 0;
  Result^.bGOOD := False;
  New(Result^.DATA);
  ClearTIM(Result);
end;

procedure FreeTIM(TIM: PTIM);
begin
  Dispose(TIM^.HEAD);
  TIM^.HEAD := nil;
  Dispose(TIM^.CLUT);
  TIM^.CLUT := nil;
  Dispose(TIM^.IMAGE);
  TIM^.IMAGE := nil;
  Dispose(TIM^.DATA);
  TIM^.DATA := nil;
  Dispose(TIM);
end;

function BppToBitMode(TIM: PTIM): byte;
begin
  Result := 4;
  if (TIM^.HEAD^.bBPP in cTIM4) then
  begin
    Result := 4;
    Exit;
  end;
  if (TIM^.HEAD^.bBPP in cTIM8) then
  begin
    Result := 8;
    Exit;
  end;
  if (TIM^.HEAD^.bBPP in cTIM16) then
  begin
    Result := 16;
    Exit;
  end;
  if (TIM^.HEAD^.bBPP in cTIM24) then
  begin
    Result := 24;
    Exit;
  end;
  if (TIM^.HEAD^.bBPP = cTIMMix) then
  begin
    Result := 16;
    Exit;
  end;
end;

function GetTimVersion(TIM: PTIM): byte;
begin
  Result := TIM^.HEAD^.bVersion;
end;

function GetTimWidth(TIM: PTIM): word;
begin
  Result := TIM^.IMAGE^.wWidth;
end;

function GetTimRealWidth(TIM: PTIM): word;
begin
  Result := IWidthToRWidth(TIM);
end;

function GetTimColorsCount(TIM: PTIM): word;
begin
  Result := TIM^.CLUT^.wColorsCount;
end;

function GetTimClutsCount(TIM: PTIM): word;
begin
  Result := TIM^.CLUT^.wClutsCount;
end;

function GetTimBPP(TIM: PTIM): Integer;
begin
  Result := TIM^.HEAD^.bBPP;
end;

function GetTimClutSizeHeader(TIM: PTIM): Integer;
begin
  Result := TIM^.CLUT^.dwSize;
end;

function GetTimClutVRAMX(TIM: PTIM): word;
begin
  Result := TIM^.CLUT^.wVRAMX;
end;

function GetTimClutVRAMY(TIM: PTIM): word;
begin
  Result := TIM^.CLUT^.wVRAMY;
end;

function GetTimImageSizeHeader(TIM: PTIM): Integer;
begin
  Result := TIM^.IMAGE^.dwSize;
end;

function GetTimImageVRAMX(TIM: PTIM): word;
begin
  Result := TIM^.IMAGE^.wVRAMX;
end;

function GetTimImageVRAMY(TIM: PTIM): word;
begin
  Result := TIM^.IMAGE^.wVRAMY;
end;

end.
