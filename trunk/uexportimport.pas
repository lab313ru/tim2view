unit uexportimport;

interface

uses
  udrawtim;

procedure SaveImage(const FileName: string; Surf: PDrawSurf; Indexed: Boolean);
function LoadImage(const FileName: string): PDrawSurf;

implementation

uses
  FPReadPNG, Classes, BGRABitmap, FileUtil, sysutils, zstream, FPWritePNG;

procedure SaveImage(const FileName: string; Surf: PDrawSurf; Indexed: Boolean);
var
  Writer: TFPWriterPNG;
begin
  Writer := TFPWriterPNG.Create;
  Writer.CompressionLevel := clnone;
  Writer.UseAlpha := True;

  Writer.Indexed := Indexed;
  Surf^.SaveToFileUTF8(FileName, Writer);
  Writer.Free;
end;

function LoadImage(const FileName: string): PDrawSurf;
var
  Reader: TFPReaderPNG;
  Stream: TFileStream;
begin
  Reader := TFPReaderPNG.Create;
  Stream := TFileStream.Create(UTF8ToSys(FileName), fmOpenRead or fmShareDenyWrite);
  Stream.Position := 0;

  New(Result);
  Result^ := TBGRABitmap.Create;
  Result^.UsePalette := True;
  Reader.ImageRead(Stream, Result^);
  Stream.Free;
  Reader.Free;
end;

end.

