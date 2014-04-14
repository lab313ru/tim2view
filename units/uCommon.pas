unit ucommon;

interface

const
  cProgramName = 'Tim2View r55 by [Lab 313]';
  cExtractedTimsDir = 'TIMS';
  cExtractedPngsDir = 'PNGS';
  cMaxFileSize = $2EAEED80;

  cAutoExtractionTimFormat = '%s_%.6d_%.2db' + '.tim';
  cAutoExtractionPngFormat = '%s_%.6d_%.2db_%.2dc' + '.png';
  cCLUTGridColsCount = 32;

  sStatusBarScanningFile = 'Scanning File...';
  sStatusBarTimsExtracting = 'TIMs Extracting...';
  sStatusBarPngsExtracting = 'PNGs Extracting...';
  sStatusBarExtracted = 'Exctracted Successfully!';
  sStatusBarParsingResult = 'Parsing Result...';
  sScanResultGood = 'Scan completed!';
  sSelectDirCaption = 'Please, select directory for scan...';
  sThisTimHasNoCLUT = 'No CLUT';

type
  TBytesArray = array [0 .. cMaxFileSize - 1] of byte;
  PBytesArray = ^TBytesArray;

procedure Text2Clipboard(const S: string);
function ExtractJustName(const Path: string): string;
function Min(A, B: Integer): Integer;
function Max(A, B: Integer): Integer;
function GetCoreCount: Integer;
function FileSize(const FileName: string): Integer;

implementation

uses sysutils, windows, clipbrd;

function GetCoreCount: Integer;
var
  SystemInfo: SYSTEM_INFO;
begin
  GetSystemInfo(&SystemInfo);
  Result := SystemInfo.dwNumberOfProcessors;
end;

procedure Text2Clipboard(const S: string);
begin
  Clipboard.AsText := S;
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

function ExtractJustName(const Path: string): string;
begin
  Result := ExtractFileName(Path);
  Result := Copy(Result, 1, Length(Result) - Length(ExtractFileExt(Result)));
end;

function FileSize(const FileName: string): Integer;
var
  FindData: TWin32FindData;
  hFind: THandle;
begin
  Result := 0;
  hFind := FindFirstFile(PChar(FileName), FindData);

  if hFind <> INVALID_HANDLE_VALUE then
  begin

    Windows.FindClose(hFind);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      Result := Integer(FindData.nFileSizeLow);
  end;

end;

end.
