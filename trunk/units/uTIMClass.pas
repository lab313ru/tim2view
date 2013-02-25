unit uTIMClass;

interface

uses
  Windows;

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

type
  TTIMHeader = packed record //TIM Header (8 bytes)
    bMagic: byte; //$10 (1 byte)
    bVersion: Byte; //Any? (1 byte)
    bReserved1: byte; //Reserved byte 1 (1 byte)
    bReserved2: byte; //Reserved byte 2 (1 byte)
    bBPP: LongInt; //Bit per Pixel  (4 bytes)
    //variants:
    //[$08, $09, $0A, $0B, $02, $03, $00, $01]
  end;
  PTIMHeader = ^TTIMHeader;

  TCLUTHeader = packed record //CLUT header (12+ bytes)
    dwSize: LongInt; //Length of CLUT (4 bytes)
    wVRAMX: word; //Palette coordinates in VRAM (by X) (2 bytes)
    wVRAMY: word; //Palette coordinates in VRAM (by Y) (2 bytes)
    wColorsCount: word; //Number of CLUT Colors (2 bytes)
    wClutsCount: word; //Count of Palettes (2 bytes)
  end;
  PCLUTHeader = ^TCLUTHeader;

  TIMAGEHeader = packed record //IMAGE Block Header (12+ bytes)
    dwSize: LongInt; //Length of Image Block (4 bytes)
    wVRAMX: word; //Image Block Coordinates in VRAM (by X) (2 bytes)
    wVRAMY: word; //Image Block Coordinates in VRAM (by Y) (2 bytes)
    wWidth: word; //Image Width (not Real) (2 bytes)
    wHeight: word; //Image Height (Real) (2 bytes)
  end;
  PIMAGEHeader = ^TIMAGEHeader;

const
  cCLUTHeaderSize = SizeOf(TCLUTHeader);
  cIMAGEHeaderSize = SizeOf(TIMAGEHeader);
  cTIMHeadererSize = SizeOf(TTIMHeader);

  cCLUTColorsMax = 1024;
  cCLUTCountMax = 512;
  cIMAGEWidthMax = 1024;
  cIMAGEHeightMax = 1024;
  cCLUTSizeMax = cCLUTColorsMax * cCLUTCountMax * 2 + cCLUTHeaderSize;
  cIMAGESizeMax = cIMAGEWidthMax * cIMAGEHeightMax * 2 + cIMAGEHeaderSize;
  cTIMMaxSize = cTIMHeadererSize + cCLUTSizeMax + cIMAGESizeMax;
  cRandomPaletteSize = $100;

type
  TTIMDataArray = array[0..cTIMMaxSize-1] of byte;
  PTIMDataArray = ^TTIMDataArray;

  TCLUT_COLOR = record
    //stp (special transparency processing) D=[0,1]
    STP: byte;
    //r,g,b  D=[0,31]
    R: byte;
    G: byte;
    B: byte;
  end;
  PCLUT_COLOR = ^TCLUT_COLOR;
  TCLUT_COLORS = array[0..cCLUTColorsMax * cCLUTCountMax - 1] of TCLUT_COLOR;
  PCLUT_COLORS = ^TCLUT_COLORS;

  TIMAGE_INDEXES = array[0..cIMAGESizeMax * 2 - 1] of LongInt;
  PIMAGE_INDEXES = ^TIMAGE_INDEXES;

  PTIM = ^TTIM;
  TTIM = class(TObject)
  protected
    fNumber: LongInt;
    fPosition: LongInt;
    fHEADER: PTIMHeader;
    fCLUT_HEADER: PCLUTHeader;
    fIMAGE_HEADER: PIMAGEHeader;
    fDATA: PTIMDataArray;
    function fConvertClutColor(COLOR: TCLUT_COLOR): Word;
    function fConvertWidthToReal: Word;
    function fGenerateRandomClutColor: TCLUT_COLOR;
    function fGetClutColorOffset(CLUT, COLOR: Word): LongInt;
    function fGetClutOffset(CLUT: Word): LongInt;
    function fConvertTIMColor(COLOR: Word): TCLUT_COLOR;
    function fGetSize: LongInt;
    function fGetClutMemory: PTIMDataArray;
    function fGetImageMemory: PTIMDataArray;
    function fGetHeaderSize: Byte;
    function fGetClutHeaderSize: Byte;
    function fGetImageHeaderSize: Byte;
    function fGetWidth: Word;
    function fGetRealWidth: Word;
    procedure fSetWidth(Value: Word);
    procedure fSetRealWidth(Value: Word);
    function fGetHeight: Word;
    procedure fSetHeight(Value: Word);
    function fGetGood: Boolean;
    function fGetVersion: Byte;
    procedure fSetVersion(Value: Byte);
    function fGetBPP: LongInt;
    procedure fSetBPP(Value: LongInt);
    function fGetMagic: Byte;
    procedure fSetMagic(Value: Byte);
    function fGetReserved(Index: Byte): Byte;
    procedure fSetReserved(Index: Byte; Value: Byte);
    function fGetClutSize: LongInt;
    function fGetClutRealSize: LongInt;
    procedure fSetClutSize(Value: LongInt);
    function fGetClutVRAMX: Word;
    procedure fSetClutVRAMX(Value: Word);
    function fGetClutVRAMY: Word;
    procedure fSetClutVRAMY(Value: Word);
    function fGetColorsCount: Word;
    procedure fSetColorsCount(Value: Word);
    function fGetClutsCount: Word;
    procedure fSetClutsCount(Value: Word);
    function fGetImageSize: LongInt;
    function fGetImageRealSize: LongInt;
    procedure fSetImageSize(Value: LongInt);
    function fGetImageVRAMX: Word;
    procedure fSetImageVRAMX(Value: Word);
    function fGetImageVRAMY: Word;
    procedure fSetImageVRAMY(Value: Word);
    function fGetClutColor(CLUT, COLOR: Word): TCLUT_COLOR;
    procedure fSetClutColor(CLUT, COLOR: Word; CLUT_COLOR: TCLUT_COLOR);
    function fGetImageIndex(Index: LongInt): LongInt;
    procedure fSetImageIndex(Index, Value: LongInt);
  public
    property Size: LongInt read fGetSize;
    property Number: LongInt read fNumber write fNumber;
    property Position: LongInt read fPosition write fPosition;
    property Good: boolean read fGetGood;

    property Data: PTIMDataArray read fDATA;
    property CLUTMemory: PTIMDataArray read fGetClutMemory;
    property IMAGEMemory: PTIMDataArray read fGetImageMemory;

    property Header: PTIMHeader read fHEADER;
    property HeaderSize: Byte read fGetHeaderSize;
    property Magic: Byte read fGetMagic write fSetMagic;
    property Version: Byte read fGetVersion write fSetVersion;
    property Reserved[Index: Byte]: Byte read fGetReserved write fSetReserved;
    property BPP: LongInt read fGetBPP write fSetBPP;

    property ClutHeader: PCLUTHeader read fCLUT_HEADER;
    property ClutHeaderSize: Byte read fGetClutHeaderSize;
    property ClutSize: LongInt read fGetClutSize write fSetClutSize;
    property ClutRealSize: LongInt read fGetClutRealSize;
    property ClutVRAMX: Word read fGetClutVRAMX write fSetClutVRAMX;
    property ClutVRAMY: Word read fGetClutVRAMY write fSetClutVRAMY;
    property ColorsCount: Word read fGetColorsCount write fSetColorsCount;
    property ClutsCount: Word read fGetClutsCount write fSetClutsCount;

    property ImageHeader: PIMAGEHeader read fIMAGE_HEADER;
    property ImageHeaderSize: Byte read fGetImageHeaderSize;
    property ImageSize: LongInt read fGetImageSize write fSetImageSize;
    property ImageRealSize: LongInt read fGetImageRealSize;
    property ImageVRAMX: Word read fGetImageVRAMX write fSetImageVRAMX;
    property ImageVRAMY: Word read fGetImageVRAMY write fSetImageVRAMY;
    property Width: Word read fGetWidth write fSetWidth;
    property RealWidth: Word read fGetRealWidth write fSetRealWidth;
    property Height: Word read fGetHeight write fSetHeight;

    property Colors[CLUT, COLOR: Word]: TCLUT_COLOR read fGetClutColor
                                                    write fSetClutColor;
    property Indexes[Index: LongInt]: LongInt read fGetImageIndex
                                              write fSetImageIndex;
  end;


implementation

{ TTIM }

function TTIM.fConvertClutColor(COLOR: TCLUT_COLOR): Word;
begin
  Result := (COLOR.STP shl 15) or ((COLOR.B div 8) shl 10) or
            ((COLOR.G div 8) shl 5) or (COLOR.R div 8);
end;

function TTIM.fConvertTIMColor(COLOR: Word): TCLUT_COLOR;
begin
  Result.R := (COLOR and $1F) * 8;
  Result.G := ((COLOR and $3E0) shr 5) * 8;
  Result.B := ((COLOR and $7C00) shr 10) * 8;
  Result.STP := ((COLOR and $8000) shr 15);
end;

function TTIM.fConvertWidthToReal: Word;
begin
  case fGetBPP of
    cTIM4C, cTIM4NC: Result := (fGetWidth * 4) and $FFFF;
    cTIM8C, cTIM8NC: Result := (fGetWidth * 2) and $FFFF;
    cTIM16C, cTIM16NC, cTIMMix: Result := fGetWidth;
    cTIM24C, cTIM24NC: Result := (Round(fGetWidth * 2 / 3)) and $FFFF;
  else
    Result := 0;
  end;
end;

function TTIM.fGenerateRandomClutColor: TCLUT_COLOR;
begin
  Result.R := random($20) * 8;
  Result.G := random($20) * 8;
  Result.B := random($20) * 8;
  Result.STP := 1;
end;

function TTIM.fGetBPP: LongInt;
begin
  Result := fHEADER^.bBPP;
end;

function TTIM.fGetClutColor(CLUT, COLOR: Word): TCLUT_COLOR;
var
  GET_COLOR: Word;
begin
  if (fGetBPP in [cTIM4NC, cTIM8NC]) then
  begin
    Result := fGenerateRandomClutColor;
    Exit;
  end;

  Move(fDATA^[fGetClutColorOffset(CLUT, COLOR)], GET_COLOR, 2);
  Result := fConvertTIMColor(GET_COLOR);
end;

function TTIM.fGetClutColorOffset(CLUT, COLOR: Word): LongInt;
begin
  Result := fGetHeaderSize + fGetClutHeaderSize + COLOR * 2 +
            fGetClutOffset(CLUT);
end;

function TTIM.fGetClutHeaderSize: Byte;
begin
  Result := cCLUTHeaderSize;
end;

function TTIM.fGetClutMemory: PTIMDataArray;
begin
  Result := PTIMDataArray(fDATA^[fGetHeaderSize]);
end;

function TTIM.fGetClutOffset(CLUT: Word): LongInt;
begin
  Result := CLUT * fGetColorsCount * 2;
end;

function TTIM.fGetClutRealSize: LongInt;
begin
  Result := fGetColorsCount * fGetClutsCount * 2 + fGetClutHeaderSize;
end;

function TTIM.fGetClutsCount: Word;
begin
  Result := fCLUT_HEADER^.wClutsCount;
end;

function TTIM.fGetClutSize: LongInt;
begin
  Result := fCLUT_HEADER^.dwSize;
end;

function TTIM.fGetClutVRAMX: Word;
begin
  Result := fCLUT_HEADER^.wVRAMX;
end;

function TTIM.fGetClutVRAMY: Word;
begin
  Result := fCLUT_HEADER^.wVRAMY;
end;

function TTIM.fGetColorsCount: Word;
begin
  Result := fCLUT_HEADER^.wColorsCount;
end;

function TTIM.fGetGood: Boolean;
begin
  Result := (fIMAGE_HEADER^.dwSize = fGetImageRealSize);
end;

function TTIM.fGetHeaderSize: Byte;
begin
  Result := cTIMHeadererSize;
end;

function TTIM.fGetHeight: Word;
begin
  Result := fIMAGE_HEADER^.wHeight;
end;

function TTIM.fGetImageHeaderSize: Byte;
begin
  Result := cIMAGEHeaderSize;
end;

function TTIM.fGetImageIndex(Index: LongInt): LongInt;
begin
  Result := -1;
  if not (fGetBPP in [cTIM4C, cTIM4NC, cTIM8C, cTIM8NC]) then Exit;
    Result := fGetImageMemory^[fGetImageHeaderSize + Index];
end;

function TTIM.fGetImageMemory: PTIMDataArray;
begin
  Result := PTIMDataArray(fDATA^[fGetHeaderSize + fGetClutRealSize]);
end;

function TTIM.fGetImageRealSize: LongInt;
begin
  Result := fGetWidth * fGetHeight * 2 + fGetHeaderSize;
end;

function TTIM.fGetImageSize: LongInt;
begin
  Result := fIMAGE_HEADER^.dwSize;
end;

function TTIM.fGetImageVRAMX: Word;
begin
  Result := fIMAGE_HEADER^.wVRAMX;
end;

function TTIM.fGetImageVRAMY: Word;
begin
  Result := fIMAGE_HEADER^.wVRAMY;
end;

function TTIM.fGetMagic: Byte;
begin
  Result := fHEADER^.bMagic;
end;

function TTIM.fGetRealWidth: Word;
begin
  Result := fConvertWidthToReal;
end;

function TTIM.fGetReserved(Index: Byte): Byte;
begin
  if Index = 0 then
    Result := fHEADER^.bReserved1
  else
    Result := fHEADER^.bReserved2;
end;

function TTIM.fGetSize: LongInt;
begin
  Result := fGetHeaderSize + fGetClutRealSize + fGetImageRealSize;
end;

function TTIM.fGetVersion: Byte;
begin
  Result := fHEADER^.bVersion;
end;

function TTIM.fGetWidth: Word;
begin
  Result := fIMAGE_HEADER^.wWidth;
end;

procedure TTIM.fSetBPP(Value: LongInt);
begin
  fHEADER^.bBPP := Value;
end;

procedure TTIM.fSetClutColor(CLUT, COLOR: Word; CLUT_COLOR: TCLUT_COLOR);
begin
  Move(fConvertCLUTColor(COLOR), fDATA^[fGetClutColorOffset(CLUT, COLOR)], 2);
end;

procedure TTIM.fSetClutsCount(Value: Word);
begin
  fCLUT_HEADER^.wClutsCount := Value;
end;

procedure TTIM.fSetClutSize(Value: LongInt);
begin
  fCLUT_HEADER^.dwSize := Value;
end;

procedure TTIM.fSetClutVRAMX(Value: Word);
begin
  fCLUT_HEADER^.wVRAMX := Value;
end;

procedure TTIM.fSetClutVRAMY(Value: Word);
begin
  fCLUT_HEADER^.wVRAMY := Value;
end;

procedure TTIM.fSetColorsCount(Value: Word);
begin
  fCLUT_HEADER^.wColorsCount := Value;
end;

procedure TTIM.fSetHeight(Value: Word);
begin
  fIMAGE_HEADER^.wHeight := Value;
end;

procedure TTIM.fSetImageIndex(Index, Value: LongInt);
begin
  //
end;

procedure TTIM.fSetImageSize(Value: LongInt);
begin
  fIMAGE_HEADER^.dwSize := Value;
end;

procedure TTIM.fSetImageVRAMX(Value: Word);
begin
  fIMAGE_HEADER^.wVRAMX := Value;
end;

procedure TTIM.fSetImageVRAMY(Value: Word);
begin
  fIMAGE_HEADER^.wVRAMY := Value;
end;

procedure TTIM.fSetMagic(Value: Byte);
begin
  fHEADER^.bMagic := Value;
end;

procedure TTIM.fSetRealWidth(Value: Word);
begin
  //
end;

procedure TTIM.fSetReserved(Index, Value: Byte);
begin
  if Index = 0 then
    fHEADER^.bReserved1 := Value
  else
    fHEADER^.bReserved2 := Value;
end;

procedure TTIM.fSetVersion(Value: Byte);
begin
  fHEADER^.bVersion := Value;
end;

procedure TTIM.fSetWidth(Value: Word);
begin
  fIMAGE_HEADER^.wWidth := Value;
end;

end.
