unit uCommon;

interface

uses
  Windows;

const
  cProgramName = 'Tim2View by [Lab 313]';
  cProgramVersion = '2.0 Stable';
  cExtractedTimsDir = 'TIMS';
  cMaxFileSize = $2EAEED80;

  cAutoExtractionTimFormat = '%s_%.6d_%.2db' + '.tim';
  cCLUTGridColsCount = 32;

  sStatusBarScanningFile = 'Scanning File...';
  sStatusBarTimsExtracting = 'TIMs Extracting...';
  sStatusBarTimsExtracted = 'Exctracted Successfully!';
  sStatusBarParsingResult = 'Parsing Result...';
  sScanResultGood = 'Scan completed!';
  sSelectDirCaption = 'Please, select directory for scan...';
  sThisTimHasNoCLUT = 'No CLUT';

type
  TBytesArray = array [0 .. cMaxFileSize - 1] of byte;
  PBytesArray = ^TBytesArray;

function GetStartDir: string;
function GetFileSizeAPI(const FileName: string): Int64;
function CheckFileExists(const FileName: string): boolean;
// function cHex2Int( const Value : string) : Integer;
function ExtractJustName(const Path: string): string;
procedure Text2Clipboard(const S: string);
function Min(A, B: Integer): Integer;
function Max(A, B: Integer): Integer;
function GetCoreCount: Integer;

implementation

uses
  System.SysUtils, Clipbrd;

function GetCoreCount: Integer;
var
  SystemInfo: SYSTEM_INFO;
begin
  GetSystemInfo(&SystemInfo);
  Result := SystemInfo.dwNumberOfProcessors;
end;

function Min(A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function Max(A, B: Integer): Integer;
begin
  if A >= B then
    Result := A
  else
    Result := B;
end;

procedure Text2Clipboard(const S: string);
begin
  Clipboard.AsText := S;
end;

function ExtractJustName(const Path: string): string;
begin
  Result := ExtractFileName(Path);
  Result := Copy(Result, 1, Length(Result) - Length(ExtractFileExt(Result)));
end;

function Hex2Int(const Value: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  I := 1;
  if Value = '' then
    Exit; { >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> }
  if Value[1] = '$' then
    Inc(I);
  while I <= Length(Value) do
  begin
    if (Value[I] >= '0') and (Value[I] <= '9') then
      Result := (Result shl 4) or (Ord(Value[I]) - Ord('0'))
    else if (Value[I] >= 'A') and (Value[I] <= 'F') then
      Result := (Result shl 4) or (Ord(Value[I]) - Ord('A') + 10)
    else if (Value[I] >= 'a') and (Value[I] <= 'f') then
      Result := (Result shl 4) or (Ord(Value[I]) - Ord('a') + 10)
    else
      break;
    Inc(I);
  end;
end;

function CopyEnd(const S: string; Idx: Integer): string;
begin
  Result := Copy(S, Idx, MaxInt);
end;

function cHex2Int(const Value: string): Integer;
begin
  if (Length(Value) > 2) and (Value[1] = '0') and
    ((Value[2] = 'x') or (Value[2] = 'X')) then
    Result := Hex2Int(CopyEnd(Value, 3))
  else
    Result := Hex2Int(Value);
end;

function CheckFileExists(const FileName: string): boolean;
begin
  Result := FileExists(FileName);
end;

function GetFileSizeAPI(const FileName: string): Int64;
var
  FindData: TWin32FindData;
  hFind: THandle;
begin
  Result := -1;
  hFind := FindFirstFile(PChar(FileName), FindData);

  if hFind <> INVALID_HANDLE_VALUE then
  begin

    Windows.FindClose(hFind);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      Result := FindData.nFileSizeLow;
  end;

end;

function GetStartDir: string;
const
  MAX_PATH = 260;
var
  Buffer: array [0 .. MAX_PATH] of Char;
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
