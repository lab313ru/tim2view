unit ucommon;

interface

const
  cProgramName = 'Tim2View SVN.r62 by [Lab 313] (for ' +
  {$IFDEF Linux}'Linux' + {$IFEND}
  {$IFDEF Darwin}'Mac OS X' + {$IFEND}
  {$IFDEF Windows}'Windows' + {$IFEND}
  ')';
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

function Min(A, B: Integer): Integer;
function Max(A, B: Integer): Integer;

implementation

uses sysutils;

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

end.
