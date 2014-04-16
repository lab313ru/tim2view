unit ucdimage;

interface

uses
  utim;

const
  cSectorHeaderSize = 12;
  cSectorAddressSize = 3;
  cSectorModeSize = 1;
  cSectorSubHeaderSize = 8;
  cSectorInfoSize = cSectorHeaderSize + cSectorAddressSize + cSectorModeSize +
    cSectorSubHeaderSize;
  cSectorDataSize = 2048;
  cSectorECCSize = 4;
  cSectorEDCSize = 276;
  cSectorECCEDCSize = cSectorECCSize + cSectorEDCSize;
  cSectorSize = cSectorInfoSize + cSectorDataSize + cSectorECCEDCSize;

type
  TCDSector = packed record
    dwHeader: array [0 .. cSectorHeaderSize - 1] of byte;
    dwAddress: array [0 .. cSectorAddressSize - 1] of byte;
    bMode: byte;
    dwSubHeader: array [0 .. cSectorSubHeaderSize - 1] of byte;
    dwData: array [0 .. cSectorDataSize - 1] of byte;
    dwECC: array [0 .. cSectorECCSize - 1] of byte;
    dwEDC: array [0 .. cSectorEDCSize - 1] of byte;
  end;

  PCDSector = ^TCDSector;

function GetImageScan(const FileName: string): Boolean;
function ReplaceTimInFile(const FileName, TimToInsert: string; InsertTo: Integer;
  ImageScan: Boolean): Boolean;
procedure ReplaceTimInFileFromMemory(const FileName: string; TIM: PTIM;
  InsertTo: Integer; ImageScan: Boolean);

implementation

uses
  ucommon, ecc, edc, classes, FileUtil, sysutils, lazutf8classes;

function bin2bcd(P: Integer): byte;
begin
  Result := ((P div 10) shl 4) or (P mod 10);
end;

procedure BuildAdress(LBA: Integer; var Dest);
var
  P: PByte;
begin
  Inc(LBA, 75 * 2); // 2 seconds
  P := @Dest;
  P^ := bin2bcd(LBA div (60 * 75));
  Inc(P);
  P^ := bin2bcd((LBA div 75) mod 60);
  Inc(P);
  P^ := bin2bcd(LBA mod 75);
  Inc(P);
  P^ := 2;
end;

function GetImageScan(const FileName: string): Boolean;
const
  cSectorHeader: array [0 .. cSectorHeaderSize - 1] of byte = ($00, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00);
var
  Sz: cardinal;
  pFile: PBytesArray;
  tmp: TFileStreamUTF8;
begin
  Result := False;
  Sz := FileSize(FileName);

  if (Sz > cMaxFileSize) or (Sz = 0) then
    Exit;

  pFile := GetMemory(cSectorHeaderSize);

  try
    tmp := TFileStreamUTF8.Create(FileName, fmOpenRead or fmShareDenyWrite);
    tmp.Read(pFile^[0], cSectorHeaderSize);
    Result := ((Sz mod cSectorSize) = 0) and (CompareMem(@cSectorHeader, pFile, cSectorHeaderSize));
  finally
    tmp.free;
    FreeMemory(pFile);
  end;
end;

procedure ReplaceTimInFileFromMemory(const FileName: string; TIM: PTIM;
  InsertTo: Integer; ImageScan: Boolean);
type
  TSecAddrAndMode = array [0 .. cSectorAddressSize + cSectorModeSize - 1] of byte;
var
  sImageStream: TFileStreamUTF8;
  TimOffsetInSector, FirstPartSize, LastPartSize: Integer;
  TimSectorNumber, TimStartSectorPos: Integer;
  Sector: TCDSector;
  ecc: DWORD;
  P, TIM_FULL_SECTORS: Integer;
  SecAddrAndMode: TSecAddrAndMode;
begin
  sImageStream := TFileStreamUTF8.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);

  if not ImageScan then
  begin
    sImageStream.Seek(InsertTo, soBeginning);
    sImageStream.Write(TIM^.DATA^[0], TIM^.dwSIZE);
  end
  else
  begin
    P := 0;

    TimSectorNumber := InsertTo div cSectorSize + 1;
    TimOffsetInSector := InsertTo mod cSectorSize - cSectorInfoSize;
    TimStartSectorPos := (TimSectorNumber - 1) * cSectorSize;
    FirstPartSize := cSectorDataSize - TimOffsetInSector;

    if TIM^.dwSIZE < FirstPartSize then
      FirstPartSize := TIM^.dwSIZE;

    sImageStream.Seek(TimStartSectorPos, soBeginning);
    FillChar(Sector, cSectorSize, 0);

    sImageStream.Read(Sector, cSectorSize);
    sImageStream.Seek(TimStartSectorPos + cSectorHeaderSize, soBeginning);

    Move(Sector.dwAddress[0], SecAddrAndMode[0], cSectorAddressSize + cSectorModeSize);
    FillChar(Sector.dwAddress[0], cSectorAddressSize + cSectorModeSize, 0);

    Move(TIM^.DATA^[P], Sector.dwData[TimOffsetInSector], FirstPartSize);
    Inc(P, FirstPartSize);

    ecc := build_edc(@(Sector.dwSubHeader[0]), cSectorSubHeaderSize + cSectorDataSize);
    Move(ecc, Sector.dwECC, cSectorECCSize);
    encode_L2_P(@(Sector.dwAddress[0]));
    encode_L2_Q(@(Sector.dwAddress[0]));
    BuildAdress(TimSectorNumber, Sector.dwAddress[0]);

    sImageStream.Seek(TimStartSectorPos, soBeginning);
    sImageStream.Write(Sector, cSectorSize);
    sImageStream.Seek(TimStartSectorPos + cSectorHeaderSize, soBeginning);
    sImageStream.Write(SecAddrAndMode[0], cSectorAddressSize + cSectorModeSize);

    Inc(TimStartSectorPos, cSectorSize);
    sImageStream.Seek(TimStartSectorPos, soBeginning);

    TIM_FULL_SECTORS := (TIM^.dwSIZE - P) div cSectorDataSize;

    while TIM_FULL_SECTORS > 0 do
    begin
      Inc(TimSectorNumber);

      sImageStream.Read(Sector, cSectorSize);
      Move(Sector.dwAddress[0], SecAddrAndMode[0], cSectorAddressSize + cSectorModeSize);
      FillChar(Sector.dwAddress[0], cSectorAddressSize + cSectorModeSize, 0);

      Move(TIM^.DATA^[P], Sector.dwData[0], cSectorDataSize);
      Inc(P, cSectorDataSize);

      ecc := build_edc(@(Sector.dwSubHeader[0]), cSectorSubHeaderSize + cSectorDataSize);
      Move(ecc, Sector.dwECC, cSectorECCSize);
      encode_L2_P(@(Sector.dwAddress[0]));
      encode_L2_Q(@(Sector.dwAddress[0]));
      BuildAdress(TimSectorNumber, Sector.dwAddress[0]);

      sImageStream.Seek(TimStartSectorPos, soBeginning);
      sImageStream.Write(Sector, cSectorSize);
      sImageStream.Seek(TimStartSectorPos + cSectorHeaderSize, soBeginning);
      sImageStream.Write(SecAddrAndMode[0], cSectorAddressSize + cSectorModeSize);

      Inc(TimStartSectorPos, cSectorSize);
      sImageStream.Seek(TimStartSectorPos, soBeginning);

      Dec(TIM_FULL_SECTORS);
    end;

    Inc(TimSectorNumber);

    sImageStream.Read(Sector, cSectorSize);
    Move(Sector.dwAddress[0], SecAddrAndMode[0], cSectorAddressSize + cSectorModeSize);
    FillChar(Sector.dwAddress[0], cSectorAddressSize + cSectorModeSize, 0);

    if TIM^.dwSIZE > P then
    begin
      LastPartSize := TIM^.dwSIZE - P;
      Move(TIM^.DATA^[P], Sector.dwData[0], LastPartSize);

      ecc := build_edc(@(Sector.dwSubHeader[0]), cSectorSubHeaderSize + cSectorDataSize);
      Move(ecc, Sector.dwECC, cSectorECCSize);
      encode_L2_P(@(Sector.dwAddress[0]));
      encode_L2_Q(@(Sector.dwAddress[0]));
      BuildAdress(TimSectorNumber, Sector.dwAddress[0]);

      sImageStream.Seek(TimStartSectorPos, soBeginning);
      sImageStream.Write(Sector, cSectorSize);
      sImageStream.Seek(TimStartSectorPos + cSectorHeaderSize, soBeginning);
      sImageStream.Write(SecAddrAndMode[0], cSectorAddressSize + cSectorModeSize);
    end;
  end;

  sImageStream.free;
end;

function ReplaceTimInFile(const FileName, TimToInsert: string; InsertTo: Integer;
  ImageScan: Boolean): Boolean;

var
  SIZE, P: Integer;
  TIM: PTIM;
begin
  Result := False;

  SIZE := FileSize(TimToInsert);
  P := 0;
  TIM := LoadTimFromFile(TimToInsert, P, False, SIZE);
  // SaveTimToFile('test.tim', TIM);
  if TIM = nil then
    Exit;

  ReplaceTimInFileFromMemory(FileName, TIM, InsertTo, ImageScan);

  FreeTIM(TIM);
  Result := True;
end;

end.
