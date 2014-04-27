unit ucommon;

interface

const
  cProgramName = 'Tim2View SVN.r74 by [Lab 313] (for ' +
  {$IFDEF Linux}'Linux' + {$IFEND}
  {$IFDEF Darwin}'Mac OS X' + {$IFEND}
  {$IFDEF Windows}'Windows' + {$IFEND}
  ')';
  cExtractedTimsDir = 'TIMS';
  cExtractedPngsDir = 'PNGS';
  cMaxFileSize = $2EAEED80;

  cAutoExtractionTimFormat = '%s_%.6d_%.2db' + '.tim';
  cAutoExtractionPngFormat = '%s_%.6d_%.2db_%.2dc' + '.png';

  sStatusBarScanningFile = 'Scanning File...';
  sStatusBarTimsExtracting = 'TIMs Extracting...';
  sStatusBarPngsExtracting = 'PNGs Extracting...';
  sStatusBarExtracted = 'Extracted Successfully!';
  sStatusBarParsingResult = 'Parsing Result...';
  sScanResultGood = 'Scan completed!';
  sSelectDirCaption = 'Please, select directory for scan...';
  sThisTimHasNoCLUT = 'No CLUT';

type
  TBytesArray = array [0 .. cMaxFileSize - 1] of byte;
  PBytesArray = ^TBytesArray;

function ExtractJustName(const Path: string): string;

implementation

uses sysutils;

function ExtractJustName(const Path: string): string;
begin
  Result := ExtractFileName(Path);
  Result := Copy(Result, 1, Length(Result) - Length(ExtractFileExt(Result)));
end;

end.
