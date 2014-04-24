unit uexportimport;

interface

uses FPWritePNG, zstream, udrawtim;

procedure SaveImage(Surf: PDrawSurf; Indexed: Boolean; const FileName: string; PngWriter: TFPWriterPNG);
function CreatePngWriter(ForExport: Boolean): TFPWriterPNG;

implementation

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

end.

