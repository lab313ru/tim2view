unit uTIM;

interface

uses
  Windows, uCommon;

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
  cTIMCLUT = [cTIM4C, cTIM8C, cTIM16C, cTIM24C, cTIMMix];
  cTIMNOCLUT = [cTIM4NC, cTIM8NC, cTIM16NC, cTIM24NC, cTIMMix];
  cTIMBpp = [cTIM4C, cTIM8C, cTIM16C, cTIM24C, cTIMMix,
    cTIM4NC, cTIM8NC, cTIM16NC, cTIM24NC, cTIMMix];

  cCLUTColorsMax = 1024;
  cCLUTCountMax = 512;
  cIMAGEWidthMax = 1024;
  cIMAGEHeightMax = 1024;
  cCLUTHeadSize = $0C;
  cIMAGEHeadSize = $0C;
  cTIMHeadSize = 8;
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
  PCLUT_COLOR = ^TCLUT_COLOR;
  TCLUT_COLORS = array[0..cCLUTColorsMax * cCLUTCountMax - 1] of PCLUT_COLOR;
  PCLUT_COLORS = ^TCLUT_COLORS;

type
  TIMAGE_INDEXES = array[0..cIMAGEWidthMax * cIMAGEHeightMax * 2 - 1] of byte;
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

function CheckHEAD(HEAD: PTIMHeader): boolean;
function CheckCLUT(CLUT: PCLUTHeader): boolean;
function CheckIMAGE(HEAD: PTIMHeader; IMAGE: PIMAGEHeader): boolean;
function CheckTIMSize(HEAD: PTIMHeader; CLUT: PCLUTHeader; IMAGE: PIMAGEHeader): Boolean;
function isTIMHasCLUT(HEAD: PTIMHeader): boolean;
function GetTIMCLUTSize(HEAD: PTIMHeader; CLUT: PCLUTHeader): DWORD;
function GetTIMIMAGESize(HEAD: PTIMHeader; IMAGE: PIMAGEHeader): DWORD;
function GetTIMSize(HEAD: PTIMHeader; CLUT: PCLUTHeader; IMAGE: PIMAGEHeader):
  DWORD;
function IWidthToRWidth(HEAD: PTIMHeader; IMAGE: PIMAGEHeader): Word;
function TIMIsGood(HEAD: PTIMHeader; IMAGE: PIMAGEHeader): boolean;
function TIMisHERE(BUFFER: PBytesArray; TIM: PTIM; var Position: DWORD): boolean;
function LoadTimFromFile(const FileName: string; var Position: DWORD): PTIM;
function CreateTIM: PTIM;
procedure FreeTIM(TIM: PTIM);

implementation

uses
  System.SysUtils, System.Classes;

function GetTIMSize(HEAD: PTIMHeader; CLUT: PCLUTHeader; IMAGE: PIMAGEHeader):
  DWORD;
begin
  Result := GetTIMCLUTSize(HEAD, CLUT) + GetTIMIMAGESize(HEAD, IMAGE) +
            cTIMHeadSize;
end;

function CheckVersion(HEAD: PTIMHeader): boolean;
begin
  Result := (HEAD^.bVersion in cTIMVersions);
end;

function CheckMagic(HEAD: PTIMHeader): Boolean;
begin
  Result := (HEAD^.bMagic = cTIMMagic);
end;

function CheckBpp(HEAD: PTIMHeader): Boolean;
begin
  Result := (HEAD^.bBPP in cTIMBpp);
end;

function CheckReserved(HEAD: PTIMHeader): boolean;
begin
  Result := (HEAD^.bReserved1 = 0) and (HEAD^.bReserved2 = 0);
end;

function isTIMHasCLUT(HEAD: PTIMHeader): boolean;
begin
  Result := (HEAD^.bBPP in cTIMCLUT);
end;

function CheckCLUTColors(CLUT: PCLUTHeader): boolean;
begin
  Result := (CLUT^.wColorsCount >= 1) and
    (CLUT^.wColorsCount <= cCLUTColorsMax);
end;

function CheckCLUTCount(CLUT: PCLUTHeader): boolean;
begin
  Result := (CLUT^.wClutsCount >= 1) and
    (CLUT^.wClutsCount <= cCLUTCountMax);
end;

function GetTIMCLUTSize(HEAD: PTIMHeader; CLUT: PCLUTHeader): DWORD;
begin
  Result := 0;

  if not isTIMHasCLUT(HEAD) then Exit;
  Result := CLUT^.wColorsCount * CLUT^.wClutsCount * 2 + cCLUTHeadSize;
end;

function GetTIMIMAGESize(HEAD: PTIMHeader; IMAGE: PIMAGEHeader): DWORD;
begin
  result := IMAGE^.wWidth * IMAGE^.wHeight * 2 + cIMAGEHeadSize;
end;

function IWidthToRWidth(HEAD: PTIMHeader; IMAGE: PIMAGEHeader): Word;
begin
  case HEAD^.bBPP of
    cTIM4C, cTIM4NC: Result := (IMAGE^.wWidth * 4) and $FFFF;
    cTIM8C, cTIM8NC: Result := (IMAGE^.wWidth * 2) and $FFFF;
    cTIM16C, cTIM16NC, cTIMMix: Result := IMAGE^.wWidth;
    cTIM24C, cTIM24NC: Result := (Round(IMAGE^.wWidth * 2 / 3)) and $FFFF;
  else
    Result := 0;
  end;
end;

function CheckHEAD(HEAD: PTIMHeader): boolean;
begin
  Result := (
    CheckMagic(HEAD) and
    CheckVersion(HEAD) and
    CheckBpp(HEAD) and
    CheckReserved(HEAD)
    )
end;

function CheckCLUT(CLUT: PCLUTHeader): boolean;
begin
  Result := (
    CheckCLUTColors(CLUT) and
    CheckCLUTCount(CLUT)
    // Need to Check CLUT^.dwSize
    );
end;

function CheckTIMSize(HEAD: PTIMHeader; CLUT: PCLUTHeader;
                      IMAGE: PIMAGEHeader): Boolean;
begin
  Result := (GetTIMSize(HEAD, CLUT, IMAGE) <= cTIMMaxSize);
end;

function TIMIsGood(HEAD: PTIMHeader; IMAGE: PIMAGEHeader): boolean;
begin
  Result := (IMAGE^.dwSize = GetTIMIMAGESize(HEAD, IMAGE));
end;

function CheckIMAGE(HEAD: PTIMHeader; IMAGE: PIMAGEHeader): boolean;
begin
  Result := False;

  if (IMAGE^.wWidth = 0) or (IMAGE^.wHeight = 0) then Exit;

  if (IMAGE^.wWidth > cIMAGEWidthMax) or (IMAGE^.wHeight > cIMAGEHeightMax) then
    Exit;

  Result := (not(HEAD^.bBPP in cTIMWrongBads)) or TIMIsGood(HEAD, IMAGE);
end;

function TIMisHERE(BUFFER: PBytesArray; TIM: PTIM; var Position: DWORD): boolean;
var
  P: DWORD;
  TIM_POS: DWORD;
begin
  Result := False;

  P := Position;
  Inc(Position);

  TIM_POS := P;
  Move(BUFFER^[P], TIM^.HEAD^, cTIMHeadSize);
  if not CheckHEAD(TIM^.HEAD) then Exit;
  inc(P, cTIMHeadSize);

  if isTIMHasCLUT(TIM^.HEAD) then
  begin
    Move(BUFFER^[P], TIM^.CLUT^, cCLUTHeadSize);
    if not CheckCLUT(TIM^.CLUT) then Exit;
    Inc(P, GetTIMCLUTSize(TIM^.HEAD, TIM^.CLUT));
  end;

  Move(BUFFER^[P], TIM^.IMAGE^, cIMAGEHeadSize);

  if not CheckIMAGE(TIM^.HEAD, TIM^.IMAGE) then Exit;
  if not CheckTIMSize(TIM^.HEAD, TIM^.CLUT, TIM^.IMAGE) then Exit;

  TIM^.dwSIZE := GetTIMSize(TIM^.HEAD, TIM^.CLUT, TIM^.IMAGE);
  TIM^.bGOOD := TIMIsGood(TIM^.HEAD, TIM^.IMAGE);

  Move(BUFFER^[TIM_POS], TIM^.DATA^[0], TIM^.dwSIZE);

  Result := True;
end;

function LoadTimFromFile(const FileName: string; var Position: DWORD): PTIM;
var
  sTIM: TFileStream;
  BUF: PBytesArray;
  SIZE: DWORD;
begin
  Result := nil;

  if not CheckFileExists(FileName) then Exit;

  SIZE := GetFileSZ(FileName);

  if SIZE > cTIMMaxSize then Exit;

  BUF := GetMemory(cTIMMaxSize);

  sTIM := TFileStream.Create(FileName, fmOpenRead);
  Result := CreateTIM;

  sTIM.Read(BUF^[Position], SIZE);

  if not TIMisHERE(BUF, Result, Position) then
  FreeTIM(Result);

  FreeMemory(BUF);
  sTIM.Free;
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
 { New(Result^.CLUT_DATA);
  New(Result^.IMAGE_DATA); }
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
 { Dispose(TIM^.CLUT_DATA);
  TIM^.CLUT_DATA := nil;
  Dispose(TIM^.IMAGE_DATA);
  TIM^.IMAGE_DATA := nil; }
  Dispose(TIM);
end;

end.

