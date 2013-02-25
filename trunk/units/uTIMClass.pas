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
    bBPP: DWORD; //Bit per Pixel  (4 bytes)
    //variants:
    //[$08, $09, $0A, $0B, $02, $03, $00, $01]
  end;
  PTIMHeader = ^TTIMHeader;

  TCLUTHeader = packed record //CLUT header (12+ bytes)
    dwSize: DWORD; //Length of CLUT (4 bytes)
    wVRAMX: word; //Palette coordinates in VRAM (by X) (2 bytes)
    wVRAMY: word; //Palette coordinates in VRAM (by Y) (2 bytes)
    wColorsCount: word; //Number of CLUT Colors (2 bytes)
    wClutsCount: word; //Count of Palettes (2 bytes)
  end;
  PCLUTHeader = ^TCLUTHeader;

  TIMAGEHeader = packed record //IMAGE Block Header (12+ bytes)
    dwSize: DWORD; //Length of Image Block (4 bytes)
    wVRAMX: word; //Image Block Coordinates in VRAM (by X) (2 bytes)
    wVRAMY: word; //Image Block Coordinates in VRAM (by Y) (2 bytes)
    wWidth: word; //Image Width (not Real) (2 bytes)
    wHeight: word; //Image Height (Real) (2 bytes)
  end;
  PIMAGEHeader = ^TIMAGEHeader;

const
  cCLUTHeadSize = SizeOf(TCLUTHeader);
  cIMAGEHeadSize = SizeOf(TIMAGEHeader);
  cTIMHeaderSize = SizeOf(TTIMHeader);

  cCLUTColorsMax = 1024;
  cCLUTCountMax = 512;
  cIMAGEWidthMax = 1024;
  cIMAGEHeightMax = 1024;
  cCLUTSizeMax = cCLUTColorsMax * cCLUTCountMax * 2 + cCLUTHeadSize;
  cIMAGESizeMax = cIMAGEWidthMax * cIMAGEHeightMax * 2 + cIMAGEHeadSize;
  cTIMMaxSize = cTIMHeaderSize + cCLUTSizeMax + cIMAGESizeMax;
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

  TIMAGE_INDEXES = array[0..cIMAGEWidthMax * cIMAGEHeightMax * 4 - 1] of DWORD;
  PIMAGE_INDEXES = ^TIMAGE_INDEXES;

  PTIM = ^TTIM;
  TTIM = class(TObject)
  protected
    fNumber: DWORD;
    fPosition: DWORD;
    fHEADER: PTIMHeader;
    fCLUT_HEADER: PCLUTHeader;
    fIMAGE_HEADER: PIMAGEHeader;
    fDATA: PTIMDataArray;
    function fGetSize: DWORD;
    function fGetClutMemory: PTIMDataArray;
    function fGetImageMemory: PTIMDataArray;
    function fGetHeaderSize: Byte;
    function fGetClutHeaderSize: Byte;
    function fGetImageHeaderSize: Byte;
    function fGetWidth: Word;
    function fGetRealWidth: Word;
    procedure fSetWidth(Width: Word);
    procedure fSetRealWidth(Width: Word);
    function fGetHeight: Word;
    procedure fSetHeight(Height: Word);
    function fGetGood: Boolean;
    procedure fSetGood(Good: Boolean);
    function fGetVersion: Byte;
    procedure fSetVersion(Version: Byte);
    function fGetBPP: DWORD;
    procedure fSetBPP(BPP: DWORD);
    function fGetMagic: Byte;
    procedure fSetMagic(Magic: Byte);
    function fGetReserved: Word;
    procedure fSetReserved(Reserved: Word);
  public
    property Size: DWORD read fGetSize;
    property Number: DWORD read fNumber write fNumber;
    property Position: DWORD read fPosition write fPosition;
    property Good: boolean read fGetGood write fSetGood;

    property Data: PTIMDataArray read fDATA;
    property CLUTMemory: PTIMDataArray read fGetClutMemory;
    property IMAGEMemory: PTIMDataArray read fGetImageMemory;

    property Header: PTIMHeader read fHEADER;
    property HeaderSize: Byte read fGetHeaderSize;
    property Magic: Byte read fGetMagic write fSetMagic;
    property Version: Byte read fGetVersion write fSetVersion;
   // property Reserved1:
    property BPP: DWORD read fGetBPP write fSetBPP;

    property ClutHeader: PCLUTHeader read fCLUT_HEADER;
    property ClutHeaderSize: Byte read fGetClutHeaderSize;
    property ImageHeader: PIMAGEHeader read fIMAGE_HEADER;
    property ImageHeaderSize: Byte read fGetImageHeaderSize;
    property Width: Word read fGetWidth write fSetWidth;
    property RealWidth: Word read fGetRealWidth write fSetRealWidth;
    property Height: Word read fGetHeight write fSetHeight;
  end;



implementation

end.
