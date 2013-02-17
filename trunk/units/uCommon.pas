unit uCommon;

interface

uses
  NativeXML, Windows;

const
  cProgramVersion = '2.0';
  cMaxFileSize = $2EAEED80;
  cResultsDir = 'results\';
  cResultsRootName = 'TVSCANRESULT';
  cResultsInfoNode = 'INFO';
  cResultsAttributeFile = 'FILENAME';
  cResultsAttributeCRC32 = 'CRC32';
  cResultsAttributeVersion = 'VERSION';
  cResultsAttributeImageFile = 'CDIMAGE';
  cResultsAttributeTimsCount = 'TIMSCOUNT';
  cResultsTimsNode = 'TIMS';
  cResultsTimNode = 'TIM';
  cResultsTimAttributeBitMode = 'BITMODE';
  cResultsTimAttributeWidth = 'WIDTH';
  cResultsTimAttributeHeight = 'HEIGHT';
  cResultsTimAttributeGood = 'GOODTIM';
  cResultsTimAttributeCLUTSize = 'CLUTSIZE';
  cResultsTimAttributeIMAGESize = 'IMAGESIZE';
  cResultsTimAttributeFilePos = 'POSITION';

  sStatusBarCalculatingCRC = 'Calculating CRC32';
  sStatusBarScanningFile = 'Scanning File...';
  sStatusBarSavingResults = 'Saving Results...';
  sScanResultGood = 'Scan completed!';

type
  PNativeXML = ^TNativeXML;
                                                                           
type
  TBytesArray = array[0..cMaxFileSize-1] of byte;
  PBytesArray = ^TBytesArray;

function GetStartDir: string;
function GetFileSZ(const FileName: string): DWORD;
function CheckFileExists(const FileName: string): boolean;

implementation

uses
  uCDIMAGE, SysUtils, Classes;

function CheckFileExists(const FileName: string): boolean;
begin
  result := FileExists(FileName);
end;

function GetFileSZ(const FileName: string): DWORD;
var
  tmp: TFileStream;
begin
  result := 0;

  if not CheckFileExists(FileName) then Exit;

  tmp := TFileStream.Create(FileName, fmOpenRead);

  result := tmp.Size;
  tmp.Free;
end;

function GetStartDir: string;
const
  MAX_PATH = 260;
var
  Buffer: array[0..MAX_PATH] of Char;
  I: Integer;
begin
  I := GetModuleFileName(0, Buffer, MAX_PATH);
  for I := I downto 0 do
    if Buffer[I] = '\' then
    begin
      Buffer[I + 1] := #0;
      break;
    end;
  Result := Buffer;
end;

end.
 
