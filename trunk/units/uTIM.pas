unit uTIM;

interface

uses
  Windows, uCommon, System.Classes;

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
  cRandomPaletteSize = $200;
  cTIMMaxSize = cTIMHeadSize + cCLUTColorsMax * cCLUTCountMax * 2 +
                cCLUTHeadSize + cIMAGEWidthMax * cIMAGEHeightMax * 2 + cIMAGEHeadSize;

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

type
  TCLUTHeader = packed record //CLUT header (12+ bytes)
    dwSize: DWORD; //Length of CLUT (4 bytes)
    wVRAMX: word; //Palette coordinates in VRAM (by X) (2 bytes)
    wVRAMY: word; //Palette coordinates in VRAM (by Y) (2 bytes)
    wColorsCount: word; //Number of CLUT Colors (2 bytes)
    wClutsCount: word; //Count of Palettes (2 bytes)
  end;
  PCLUTHeader = ^TCLUTHeader;

type
  TIMAGEHeader = packed record //IMAGE Block Header (12+ bytes)
    dwSize: DWORD; //Length of Image Block (4 bytes)
    wVRAMX: word; //Image Block Coordinates in VRAM (by X) (2 bytes)
    wVRAMY: word; //Image Block Coordinates in VRAM (by Y) (2 bytes)
    wWidth: word; //Image Width (not Real) (2 bytes)
    wHeight: word; //Image Height (Real) (2 bytes)
  end;
  PIMAGEHeader = ^TIMAGEHeader;

type
  TTIMDataArray = array[0..cTIMMaxSize-1] of byte;
  PTIMDataArray = ^TTIMDataArray;

type
  TCLUT_COLOR = record
    //stp (special transparency processing) D=[0,1]
    STP: byte;
    //r,g,b  D=[0,31]
    R: byte;
    G: byte;
    B: byte;
  end;
  TCLUT_COLORS = array[0..cCLUTColorsMax * cCLUTCountMax - 1] of TCLUT_COLOR;
  PCLUT_COLORS = ^TCLUT_COLORS;

type
  TIMAGE_INDEXES = array[0..cIMAGEWidthMax * cIMAGEHeightMax * 4 - 1] of DWORD;
  PIMAGE_INDEXES = ^TIMAGE_INDEXES;

type
  TTIM = record
    dwTimNumber: DWORD;
    dwTimPosition: DWORD;
    HEAD: PTIMHeader;
    CLUT: PCLUTHeader;
    IMAGE: PIMAGEHeader;
    dwSIZE: DWORD;
    DATA: PTIMDataArray;
  {  CLUT_DATA: PCLUT_COLORS;
    IMAGE_DATA: PIMAGE_INDEXES;  }
    bGOOD: Boolean;
  end;
  PTIM = ^TTIM;

function isTIMHasCLUT(TIM: PTIM): boolean;
function GetTIMCLUTSize(TIM: PTIM): DWORD;
function GetTIMSize(TIM: PTIM): DWORD;
//function GetTimWidth(TIM: PTIM): Word;
function GetTimRealWidth(TIM: PTIM): Word;
function GetTimHeight(TIM: PTIM): Word;
function TIMIsGood(TIM: PTIM): boolean;
function LoadTimFromBuf(BUFFER: PBytesArray; var TIM: PTIM;
                        var Position: DWORD): boolean;
function LoadTimFromFile(const FileName: string; var Position: DWORD): PTIM;
function LoadTimFromStream(Stream: TStream; var Position: DWORD): PTIM;
function CreateTIM: PTIM;
procedure FreeTIM(TIM: PTIM);
function BppToBitMode(TIM: PTIM): byte;

implementation

uses
  System.SysUtils;

function GetTimHeight(TIM: PTIM): Word;
begin
  Result := TIM^.IMAGE^.wHeight;
end;

function GetTIMCLUTSize(TIM: PTIM): DWORD;
begin
  Result := 0;

  if not isTIMHasCLUT(TIM) then Exit;
  Result := TIM^.CLUT^.wColorsCount * TIM^.CLUT^.wClutsCount * 2 + cCLUTHeadSize;
end;

function GetTIMIMAGESize(TIM: PTIM): DWORD;
begin
  result := TIM^.IMAGE^.wWidth * TIM^.IMAGE^.wHeight * 2 + cIMAGEHeadSize;
end;

function GetTIMSize(TIM: PTIM): DWORD;
begin
  Result := GetTIMCLUTSize(TIM) + GetTIMIMAGESize(TIM) + cTIMHeadSize;
end;

function CheckVersion(TIM: PTIM): boolean;
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

function CheckReserved(TIM: PTIM): boolean;
begin
  Result := (TIM^.HEAD^.bReserved1 = 0) and (TIM^.HEAD^.bReserved2 = 0);
end;

function isTIMHasCLUT(TIM: PTIM): boolean;
begin
  Result := (TIM^.HEAD^.bBPP in cTIMCLUT);
end;

function CheckCLUTColors(TIM: PTIM): boolean;
begin
  Result := (TIM^.CLUT^.wColorsCount >= 1) and
    (TIM^.CLUT^.wColorsCount <= cCLUTColorsMax);
end;

function CheckCLUTCount(TIM: PTIM): boolean;
begin
  Result := (TIM^.CLUT^.wClutsCount >= 1) and
    (TIM^.CLUT^.wClutsCount <= cCLUTCountMax);
end;

function IWidthToRWidth(TIM: PTIM): Word;
begin
  case TIM^.HEAD^.bBPP of
    cTIM4C, cTIM4NC: Result := (TIM^.IMAGE^.wWidth * 4) and $FFFF;
    cTIM8C, cTIM8NC: Result := (TIM^.IMAGE^.wWidth * 2) and $FFFF;
    cTIM16C, cTIM16NC, cTIMMix: Result := TIM^.IMAGE^.wWidth;
    cTIM24C, cTIM24NC: Result := (Round(TIM^.IMAGE^.wWidth * 2 / 3)) and $FFFF;
  else
    Result := 0;
  end;
end;

function CheckHEAD(TIM: PTIM): boolean;
begin
  Result := (
    CheckMagic(TIM) and
    CheckVersion(TIM) and
    CheckBpp(TIM) and
    CheckReserved(TIM)
    )
end;

function CheckCLUT(TIM: PTIM): boolean;
begin
  Result := (
    CheckCLUTColors(TIM) and
    CheckCLUTCount(TIM)
    // Need to Check CLUT^.dwSize
    );
end;

function CheckTIMSize(TIM: PTIM): Boolean;
begin
  Result := (GetTIMSize(TIM) <= cTIMMaxSize);
end;

function TIMIsGood(TIM: PTIM): boolean;
begin
  Result := (TIM^.IMAGE^.dwSize = GetTIMIMAGESize(TIM));
end;

function CheckIMAGE(TIM: PTIM): boolean;
begin
  Result := False;

  if (TIM^.IMAGE^.wWidth = 0) or (TIM^.IMAGE^.wHeight = 0) then Exit;

  if (TIM^.IMAGE^.wWidth > cIMAGEWidthMax) or
     (TIM^.IMAGE^.wHeight > cIMAGEHeightMax)
  then
    Exit;

  Result := (not(TIM^.HEAD^.bBPP in cTIMWrongBads)) or TIMIsGood(TIM);
end;

function LoadTimFromBuf(BUFFER: PBytesArray; var TIM: PTIM;
                        var Position: DWORD): boolean;
var
  P: DWORD;
  TIM_POS: DWORD;
begin
  Result := False;

  P := Position;
  Inc(Position);
  TIM_POS := P;

  if TIM = nil then
  TIM := CreateTIM;

  Move(BUFFER^[P], TIM^.HEAD^, cTIMHeadSize);
  if not CheckHEAD(TIM) then Exit;
  inc(P, cTIMHeadSize);

  if isTIMHasCLUT(TIM) then
  begin
    Move(BUFFER^[P], TIM^.CLUT^, cCLUTHeadSize);
    if not CheckCLUT(TIM) then Exit;
    Inc(P, GetTIMCLUTSize(TIM));
  end;

  Move(BUFFER^[P], TIM^.IMAGE^, cIMAGEHeadSize);

  if not CheckIMAGE(TIM) then Exit;
  if not CheckTIMSize(TIM) then Exit;

  TIM^.dwSIZE := GetTIMSize(TIM);
  TIM^.bGOOD := TIMIsGood(TIM);

  Move(BUFFER^[TIM_POS], TIM^.DATA^[0], TIM^.dwSIZE);

  Result := True;
end;

function LoadTimFromFile(const FileName: string; var Position: DWORD): PTIM;
var
  sTIM: TFileStream;
  SIZE: DWORD;
begin
  Result := nil;

  if not CheckFileExists(FileName) then Exit;

  SIZE := GetFileSZ(FileName);
  if SIZE > cTIMMaxSize then Exit;

  sTIM := TFileStream.Create(FileName, fmOpenRead);
  Result := LoadTimFromStream(sTIM, Position);
  sTIM.Free;
end;

function LoadTimFromStream(Stream: TStream; var Position: DWORD): PTIM;
var
  BUF: PBytesArray;
  SIZE: DWORD;
begin
  Result := nil;

  SIZE := Stream.Size;
  if SIZE > cTIMMaxSize then Exit;

  BUF := GetMemory(SIZE);
  Result := CreateTIM;

  Stream.Seek(Position, soBeginning);
  Stream.Read(BUF^[Position], SIZE);

  if not LoadTimFromBuf(BUF, Result, Position) then
  FreeTIM(Result);

  FreeMemory(BUF);
end;

function CreateTIM: PTIM;
begin
  New(Result);

  New(Result^.HEAD);
  New(Result^.CLUT);
  New(Result^.IMAGE);
  Result^.dwSIZE := 0;
  Result^.dwTimPosition := 0;
  Result^.dwTIMNumber := 0;
  Result^.bGOOD := False;
  New(Result^.DATA);
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

function GetTimWidth(TIM: PTIM): Word;
begin
  Result := TIM^.IMAGE^.wWidth;
end;

function GetTimRealWidth(TIM: PTIM): Word;
begin
  Result := IWidthToRWidth(TIM);
end;

end.

