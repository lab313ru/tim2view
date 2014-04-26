unit uexportimport;

interface

uses
  FPWritePNG, zstream, udrawtim;

procedure SaveImage(Surf: PDrawSurf; Indexed: Boolean; const FileName: string; PngWriter: TFPWriterPNG);
function LoadImage(const FileName: string; var Surf: PDrawSurf): Boolean;
function CreatePngWriter(ForExport: Boolean): TFPWriterPNG;

implementation

uses
  FPReadPNG, Classes, BGRABitmap, FileUtil, sysutils;

function CreatePngWriter(ForExport: Boolean): TFPWriterPNG;
begin
  Result := TFPWriterPNG.Create;
  Result.CompressionLevel := clnone;
  Result.WordSized := False;
  Result.UseAlpha := (not ForExport);
end;

procedure SaveImage(Surf: PDrawSurf; Indexed: Boolean; const FileName: string; PngWriter: TFPWriterPNG);
begin
  PngWriter.Indexed := Indexed;
  Surf^.SaveToFileUTF8(FileName, PngWriter);
end;

function LoadImage(const FileName: string; var Surf: PDrawSurf): Boolean;
var
  Reader: TFPReaderPNG;
  Image: TFileStream;
begin
  Result := False;

  try
  Reader := TFPReaderPNG.Create;
  Image := TFileStream.Create(UTF8ToSys(FileName), fmOpenRead or fmShareDenyWrite);
  Result := Reader.CheckContents(Image);

  if Result then
  begin
    New(Surf);
    Surf^ := TBGRABitmap.Create;
    Image.Position := 0;
    Surf^.LoadFromStream(Image);
  end;

  finally
    Image.Free;
    Reader.Free;
  end;
end;

end.

