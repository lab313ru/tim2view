unit uTIMClass;

interface

uses
  Windows, System.Classes, System.SysUtils;

const
  cMaxFileSize = $2EAEED80;

type
  TBytesArray = array[0..cMaxFileSize-1] of byte;
  PBytesArray = ^TBytesArray;

const
  cTIMMagic = $10;
  cTIM4C    = $08;
  cTIM4NC   = $00;
  cTIM8C    = $09;
  cTIM8NC   = $01;
  cTIM16C   = $0A;
  cTIM16NC  = $02;
  cTIM24C   = $0B;
  cTIM24NC  = $03;
  cTIMMix   = $04;
  cCLUTColorsMax     = $400;
  cCLUTCountMax      = $200;
  cIMAGEWidthMax     = $400;
  cIMAGEHeightMax    = $400;
  cRandomPaletteSize = $100;

  TIMVersions  = [$00, $01];
  TIM4         = [cTIM4C, cTIM4NC];
  TIM8         = [cTIM8C, cTIM8NC];
  TIM16        = [cTIM16C, cTIM16NC];
  TIM24        = [cTIM24C, cTIM24NC];
  TIMMix       = [cTIMMix];
  TIMWrongBads = [cTIM4NC, cTIM8NC, cTIMMix];
  TIMCLUT      = [cTIM4C, cTIM8C, cTIM16C, cTIM24C];
  TIMNOCLUT    = [cTIM4NC, cTIM8NC, cTIM16NC, cTIM24NC, cTIMMix];

type
  TBitmode   = (bm4C = cTIM4C, bm4NC = cTIM4NC, bm8C = cTIM8C,
                bm8NC = cTIM8NC, bm16C = cTIM16C, bm16NC = cTIM16NC,
                bm24C = cTIM24C, bm24NC = cTIM24NC, bmMix = cTIMMix);


{ HEADER }
type
  TTimHeader = packed record
    bMagic: byte;
    bVersion: Byte;
    bReserved1: byte;
    bReserved2: byte;
    bBPP: DWORD;
  end;
  PTimHeader = ^TTimHeader;
const
  cHeaderSize = SizeOf(TTimHeader);
{ HEADER }


{ CLUT }
{ CLUTHEADER }
type
  TTimClutHeader = packed record
    dwSize: DWORD;
    wVRAMX: word;
    wVRAMY: word;
    wColorsCount: word;
    wClutsCount: word;
  end;
  PTimClutHeader = ^TTimClutHeader;
const
  cClutHeaderSize = SizeOf(TTimClutHeader);
{ CLUTHEADER }

{ CLUTCOLOR }
type
  TCLUT_COLOR = record
    STP: byte;
    R: byte;
    G: byte;
    B: byte;
  end;
  TCLUT_COLORS = array[0..cCLUTColorsMax * cCLUTCountMax - 1] of TCLUT_COLOR;
  PCLUT_COLORS = ^TCLUT_COLORS;
{ CLUTCOLOR }
{ CLUT }


{ IMAGE }
{ IMAGEHEADER }
type
  TTimImageHeader = packed record
    dwSize: DWORD;
    wVRAMX: word;
    wVRAMY: word;
    wWidth: word;
    wHeight: word;
  end;
  PTimImageHeader = ^TTimImageHeader;
const
  cImageHeaderSize = SizeOf(TTimImageHeader);
{ IMAGEHEADER }

{ IMAGEINDEX }
type
  TIMAGE_INDEXES = array[0..cIMAGEWidthMax * cIMAGEHeightMax * 4 - 1] of DWORD;
  PIMAGE_INDEXES = ^TIMAGE_INDEXES;
{ IMAGEINDEX }
{ IMAGE }


{ MAXCONSTS }
const
  cCLUTSizeMax  = cCLUTColorsMax * cCLUTCountMax * 2 + cClutHeaderSize;
  cIMAGESizeMax = cIMAGEWidthMax * cIMAGEHeightMax * 2 + cImageHeaderSize;
  cTIMMaxSize   = cHeaderSize + cCLUTSizeMax + cIMAGESizeMax;
{ MAXCONSTS }


{ TIMCLASS }
type
  TTIMDataArray = array[0..cTIMMaxSize-1] of byte;
  PTIMDataArray = ^TTIMDataArray;

  PTIM = ^TTIM;
  TTIM = class(TObject)
  protected
    fNumber: LongInt;
    fPosition: DWORD;
    fData: PTimDataArray;
    fHeader: PTimHeader;
    fClutHeader: PTimClutHeader;
    fClutData: PTimDataArray;
    fImageHeader: PTimImageHeader;
    fImageData: PTimDataArray;

    { MAIN }
    function AssignData(Data: pointer; Size: DWORD): boolean;
    function fGetTimSize: DWORD;

    { CHECKS }
    function  fCheckTim: boolean;
    function  fCheckTimSize: boolean;

    function  fCheckHeader: boolean;
    function  fCheckMagic: boolean;
    function  fCheckVersion: boolean;
    function  fCheckBitmode: boolean;
    function  fCheckReserved: boolean;

    function  fCheckClut: boolean;
    function  fCheckClutColors: boolean;
    function  fCheckClutCount: boolean;
    function  fCheckClutSize: boolean;

    function  fCheckImage: boolean;
    function  fCheckImageWidth: boolean;
    function  fCheckImageHeight: boolean;
    function  fCheckImageIsGood: boolean;

    { HEADER }
    function  fGetHeaderSize: Byte;
    function  fGetMagicByte: Byte;
    procedure fSetVersion(Version: byte);
    function  fGetVersion: byte;
    procedure fSetReserved(Index: byte; Reserved: byte);
    function  fGetReserved(Index: byte): byte;
    procedure fSetBitMode(Bitmode: TBitmode);
    function  fGetBitMode: TBitmode;
    function  fGetBitModeValue: DWORD;
    function  fGetBitModeAsString: string;

    { CLUT }
    function  fTimHasClut: boolean;
    function  fGetClutHeaderSize: Byte;
    procedure fSetClutSizeToHeader(Size: DWORD);
    function  fGetClutSizeFromHeader: DWORD;
    function  fGetClutSizeWHeader: DWORD;
    function  fGetClutSizeWOHeader: DWORD;
    procedure fSetClutVRAMX(X: Word);
    function  fGetClutVRAMX: Word;
    procedure fSetClutVRAMY(Y: Word);
    function  fGetClutVRAMY: Word;
    procedure fSetClutColors(Colors: Word);
    function  fGetClutColors: Word;
    procedure fSetClutCount(Count: Word);
    function  fGetClutCount: Word;

    { IMAGE }
    function  fGetImageHeaderSize: Byte;
    procedure fSetImageSizeToHeader(Size: DWORD);
    function  fGetImageSizeFromHeader: DWORD;
    function  fGetImageSizeWHeader: DWORD;
    function  fGetImageSizeWOHeader: DWORD;
    procedure fSetImageVRAMX(X: Word);
    function  fGetImageVRAMX: Word;
    procedure fSetImageVRAMY(Y: Word);
    function  fGetImageVRAMY: Word;
    procedure fSetWidth(Width: Word);
    function  fGetWidth: Word;
    procedure fSetRealWidth(Width: Word);
    function  fGetRealWidth: Word;
    procedure fSetHeight(Height: Word);
    function  fGetHeight: Word;
  public
    destructor Destroy; override;

    { MAIN }
    property Number: LongInt read fNumber write fNumber;
    property Position: DWORD read fPosition write fPosition;
    property Size: DWORD read fGetTimSize;

    { MAINCHECK }
    property GoodImage: Boolean read fCheckImageIsGood;

    { HEADER }
    property MagicByte: byte read fGetMagicByte;
    property Version: byte read fGetVersion write fSetVersion;
    property Reserved[Index: byte]: byte read fGetReserved write fSetReserved;
    property Bitmode: TBitmode read fGetBitMode write fSetBitMode;
    property BitmodeValue: DWORD read fGetBitModeValue;
    property BitmodeAsString: string read fGetBitModeAsString;

    { CLUT }
    property HasClut: boolean read fTimHasClut;
    property ClutSize: DWORD read fGetClutSizeFromHeader write fSetClutSizeToHeader;
    property ClutSizeRealWHeader: DWORD read fGetClutSizeWHeader;
    property ClutSizeRealWOHeader: DWORD read fGetClutSizeWOHeader;
    property ClutVRAMX: Word read fGetClutVRAMX write fSetClutVRAMX;
    property ClutVRAMY: Word read fGetClutVRAMY write fSetClutVRAMY;
    property ClutColors: Word read fGetClutColors write fSetClutColors;
    property ClutCount: Word read fGetClutCount write fSetClutCount;

    { IMAGE }
    property ImageSize: DWORD read fGetImageSizeFromHeader write fSetImageSizeToHeader;
    property ImageSizeRealWHeader: DWORD read fGetImageSizeWHeader;
    property ImageSizeRealWOHeader: DWORD read fGetImageSizeWOHeader;
    property ImageVRAMX: Word read fGetImageVRAMX write fSetImageVRAMX;
    property ImageVRAMY: Word read fGetImageVRAMY write fSetImageVRAMY;
    property Width: Word read fGetWidth write fSetWidth;
    property WidthReal: Word read fGetRealWidth write fSetRealWidth;
    property Height: Word read fGetHeight write fSetHeight;

    { FUNCTIONS }
    function LoadFromFile(const FileName: string; P: DWORD): boolean;
    function LoadFromCDImage(const FileName: string; P, SIZE: DWORD): boolean;
    function LoadFromStream(Stream: TStream; P: DWORD): boolean;
    function LoadFromBuffer(Buffer: PBytesArray; P: DWORD): boolean;
  end;
{ TIMCLASS }

implementation

uses
  Math;

{ TTIM }

function TTIM.AssignData(Data: pointer; Size: DWORD): boolean;
begin
  New(fData);
  fHeader := PTimHeader(fData);
  Move(Data^, fData^, Size);

  if fTimHasClut then
  begin
    fClutHeader := @fData^[fGetHeaderSize];
    fClutData := @fData^[fGetHeaderSize + fGetClutHeaderSize];
    fImageHeader := @fClutData^[fGetClutSizeWOHeader];
  end
  else
  begin
    fClutHeader := nil;
    fClutData := nil;
    fImageHeader := @fData^[fGetHeaderSize];
  end;

  fImageData := PTimDataArray(fData^[fGetHeaderSize + fGetClutSizeWHeader +
                                     fGetImageHeaderSize]);

  Result := fCheckTim;
end;

destructor TTIM.Destroy;
begin
  Dispose(fData);
  inherited;
end;

function TTIM.fCheckBitmode: boolean;
begin
  Result := TBitmode(fHeader.bBPP) in [Low(TBitmode)..High(TBitmode)];
end;

function TTIM.fCheckClut: boolean;
begin
  Result := fCheckClutCount and fCheckClutColors and fCheckClutSize;
end;

function TTIM.fCheckClutColors: boolean;
begin
  Result := (fGetClutColors >= 1) and (fGetClutColors <= cCLUTColorsMax);
end;

function TTIM.fCheckClutCount: boolean;
begin
  Result := (fGetClutCount >= 1) and (fGetClutCount <= cCLUTCountMax);
end;

function TTIM.fCheckClutSize: boolean;
begin
  Result := True; //Needs to be afterchecked;
end;

function TTIM.fCheckHeader: boolean;
begin
  Result := fCheckMagic and fCheckVersion and fCheckBitmode and fCheckReserved;
end;

function TTIM.fCheckImage: boolean;
begin
  Result := fCheckImageWidth and fCheckImageHeight and
            ((not(fGetBitModeValue in TIMWrongBads)) or fCheckImageIsGood);
end;

function TTIM.fCheckImageHeight: boolean;
begin
  Result := (fGetHeight <> 0) and (fGetHeight <= cIMAGEHeightMax);
end;

function TTIM.fCheckImageIsGood: boolean;
begin
  Result := (fImageHeader^.dwSize = fGetImageSizeWHeader);
end;

function TTIM.fCheckImageWidth: boolean;
begin
  Result := (fGetWidth <> 0) and (fGetWidth <= cIMAGEWidthMax);
end;

function TTIM.fCheckMagic: boolean;
begin
  Result := (fHeader^.bMagic = cTIMMagic);
end;

function TTIM.fCheckReserved: boolean;
begin
  Result := (fGetReserved(0) = 0) and (fGetReserved(1) = 0);
end;

function TTIM.fCheckTim: boolean;
var
  HEAD, CLUT, IMAGE: Boolean;
begin
  HEAD  := fCheckHeader;

  if fTimHasClut then
    CLUT := fCheckClut
  else
    CLUT := True;

  IMAGE := fCheckImage;

  Result := HEAD and CLUT and IMAGE;
end;

function TTIM.fCheckTimSize: boolean;
begin
  Result := (fGetTimSize <= cTimMaxSize);
end;

function TTIM.fCheckVersion: boolean;
begin
  Result := (fHeader^.bVersion in TIMVersions);
end;

function TTIM.fGetBitMode: TBitmode;
begin
  Result := TBitmode(fHeader^.bBPP);
end;

function TTIM.fGetBitModeAsString: string;
begin
  case fGetBitMode of
    bm4C, bm4NC   : Result := '4';
    bm8C, bm8NC   : Result := '8';
    bm16C, bm16NC : Result := '16';
    bm24C, bm24NC : Result := '24';
    bmMix         : Result := 'Mix';
  else
    Result := '4';
  end;
end;

function TTIM.fGetBitModeValue: DWORD;
begin
  Result := fHeader^.bBPP;
end;

function TTIM.fGetHeight: Word;
begin
  Result := fImageHeader^.wHeight;
end;

function TTIM.fGetMagicByte: Byte;
begin
  Result := fData^[0];
end;

function TTIM.fGetReserved(Index: byte): byte;
begin
  if Index = 0 then
    Result := fHeader^.bReserved1
  else
    Result := fHeader^.bReserved2;
end;

function TTIM.fGetTimSize: DWORD;
begin
  Result := fGetHeaderSize + fGetClutSizeWHeader + fGetImageSizeWHeader;
end;

function TTIM.fGetClutColors: Word;
begin
  Result := fClutHeader^.wColorsCount;
end;

function TTIM.fGetClutCount: Word;
begin
  Result := fClutHeader^.wClutsCount;
end;

function TTIM.fGetClutHeaderSize: Byte;
begin
  Result := 0;
  if not fTimHasClut then Exit;

  Result := cClutHeaderSize;
end;

function TTIM.fGetClutSizeFromHeader: DWORD;
begin
  Result := fClutHeader^.dwSize;
end;

function TTIM.fGetClutSizeWHeader: DWORD;
begin
  Result := fGetClutSizeWOHeader + fGetClutHeaderSize;
end;

function TTIM.fGetClutSizeWOHeader: DWORD;
begin
  Result := 0;
  if not fTimHasClut then Exit;

  Result := fGetClutColors * fGetClutCount * 2;
end;

function TTIM.fGetClutVRAMX: Word;
begin
  Result := fClutHeader^.wVRAMX;
end;

function TTIM.fGetClutVRAMY: Word;
begin
  Result := fClutHeader^.wVRAMY
end;

function TTIM.fGetHeaderSize: Byte;
begin
  Result := cHeaderSize;
end;

function TTIM.fGetImageHeaderSize: Byte;
begin
  Result := cImageHeaderSize;
end;

function TTIM.fGetImageSizeFromHeader: DWORD;
begin
  Result := fImageHeader^.dwSize;
end;

function TTIM.fGetImageSizeWHeader: DWORD;
begin
  Result := fGetImageSizeWOHeader + fGetImageHeaderSize;
end;

function TTIM.fGetImageSizeWOHeader: DWORD;
begin
  Result := fGetWidth * fGetHeight * 2;
end;

function TTIM.fGetImageVRAMX: Word;
begin
  Result := fImageHeader^.wVRAMX;
end;

function TTIM.fGetImageVRAMY: Word;
begin
  Result := fImageHeader^.wVRAMY;
end;

function TTIM.fGetRealWidth: Word;
begin
  case fGetBitmode of
    bm4C, bm4NC: Result := (fGetWidth * 4) and $FFFF;
    bm8C, bm8NC: Result := (fGetWidth * 2) and $FFFF;
    bm16C, bm16NC, bmMix: Result := fGetWidth;
    bm24C, bm24NC: Result := (Round(fGetWidth * 2 / 3)) and $FFFF;
  else
    Result := 0;
  end;
end;

function TTIM.fGetVersion: byte;
begin
  Result := fHeader^.bVersion;
end;

function TTIM.fGetWidth: Word;
begin
  Result := fImageHeader^.wWidth;
end;

procedure TTIM.fSetBitMode(Bitmode: TBitmode);
begin
  fHeader^.bBPP := DWORD(Bitmode);
end;

procedure TTIM.fSetHeight(Height: Word);
begin
  fImageHeader^.wHeight := Height;
end;

procedure TTIM.fSetImageSizeToHeader(Size: DWORD);
begin
  fImageHeader^.dwSize := Size;
end;

procedure TTIM.fSetImageVRAMX(X: Word);
begin
  fImageHeader^.wVRAMX := X;
end;

procedure TTIM.fSetImageVRAMY(Y: Word);
begin
  fImageHeader^.wVRAMY := Y;
end;

procedure TTIM.fSetRealWidth(Width: Word);
begin
  case fGetBitmode of
    bm4C, bm4NC: fSetWidth(Width div 4);
    bm8C, bm8NC: fSetWidth(Width div 2);
    bm16C, bm16NC, bmMix: fSetWidth(Width);
    bm24C, bm24NC: fSetWidth(Ceil(Width * 3 / 2));
  else
    fSetWidth(0);
  end;
end;

procedure TTIM.fSetReserved(Index, Reserved: byte);
begin
  if Index = 0 then
    fHeader^.bReserved1 := Reserved
  else
    fHeader^.bReserved2 := Reserved;
end;

procedure TTIM.fSetClutColors(Colors: Word);
begin
  fClutHeader^.wColorsCount := Colors;
end;

procedure TTIM.fSetClutCount(Count: Word);
begin
  fClutHeader^.wClutsCount := Count;
end;

procedure TTIM.fSetClutSizeToHeader(Size: DWORD);
begin
  fClutHeader^.dwSize := Size;
end;

procedure TTIM.fSetClutVRAMX(X: Word);
begin
  fClutHeader^.wVRAMX := X;
end;

procedure TTIM.fSetClutVRAMY(Y: Word);
begin
  fClutHeader^.wVRAMY := Y;
end;

procedure TTIM.fSetVersion(Version: byte);
begin
  fHeader^.bVersion := Version;
end;

procedure TTIM.fSetWidth(Width: Word);
begin
  fImageHeader^.wWidth := Width;
end;

function TTIM.fTimHasClut: boolean;
begin
  Result := fGetBitMode in [bm4C, bm8C, bm16C, bm24C];
end;

function TTIM.LoadFromFile(const FileName: string; P: DWORD): boolean;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Result := LoadFromStream(Stream, P);
  Stream.Free;
end;

function TTIM.LoadFromStream(Stream: TStream; P: DWORD): boolean;
var
  BUF: PTimDataArray;
  SIZE: DWORD;
begin
  Stream.Seek(P, soBeginning);
  New(BUF);
  SIZE := SizeOf(BUF^);
  Stream.Read(BUF^[0], SIZE);
  Result := LoadFromBuffer(PBytesArray(BUF), P);
  Dispose(BUF);
end;

function TTIM.LoadFromBuffer(Buffer: PBytesArray; P: DWORD): boolean;
var
  SIZE: DWORD;
begin
  Result := False;
  New(fHeader);
  New(fClutHeader);
  New(fImageHeader);

  Move(PBytesArray(Buffer)^[P], fHeader^, cHeaderSize);
  if not fCheckHeader then Exit;
  inc(P, cHeaderSize);

  if fTimHasClut then
  begin
    Move(PBytesArray(Buffer)^[P], fClutHeader^, cClutHeaderSize);
    if not fCheckClut then Exit;
    Inc(P, fGetClutSizeWHeader);
  end;

  Move(PBytesArray(Buffer)^[P], fImageHeader^, cImageHeaderSize);

  if not fCheckImage then Exit;
  if not fCheckTimSize then Exit;

  Dispose(fHeader);
  Dispose(fClutHeader);
  Dispose(fImageHeader);

  SIZE := fGetTimSize;
  Result := AssignData(Buffer, SIZE);
end;

function TTIM.LoadFromCDImage(const FileName: string; P, SIZE: DWORD): boolean;
begin
var
  TimOffsetInSector, FirstPartSize, LastPartSize: DWORD;
  TimSectorNumber, TimStartSectorPos: DWORD;
  TIM_BUF: PTIMDataArray;
  sImageStream: TFileStream;
  Sector: TCDSector;
  P, TIM_FULL_SECTORS: DWORD;
begin
  sImageStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);

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

  P := 0;
  Result := nil;
  LoadTimFromBuf(TIM_BUF, Result, P);
  sImageStream.Free;
  Dispose(TIM_BUF);
end;

end.
