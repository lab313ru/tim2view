unit uDrawTIM;

interface

uses
  Vcl.Graphics, uTIM, System.Types;

type
  PCanvas = ^TCanvas;

procedure DrawTIM(TIM: PTIM; ACanvas: PCanvas; Rect: TRect);

implementation

uses
  Vcl.Imaging.pngimage;

procedure ReadColor(ColorValue: Word; var Color: PCLUT_COLOR);
begin
  New(Color);
  Color^.R := (ColorValue and $1F);
  Color^.G := (ColorValue and $3E0) shr 5;
  Color^.B := (ColorValue and $7C00) shr 10;
  Color^.STP := (ColorValue and $FFFF8000) shr 15;
end;

function PrepareCLUT(TIM: PTIM): PCLUT_COLORS;
var
  CLUT_COLOR: PCLUT_COLOR;
  ColorValue: Word;
  I: Integer;
begin
  Result := nil;
  if not isTIMHasCLUT(TIM^.HEAD) then Exit;

  New(Result);

  for I := 1 to GetTIMCLUTSize(TIM^.HEAD, TIM^.CLUT) do
  begin
    Move(TIM^.DATA^[cTIMHeadSize + (I - 1) * 2], ColorValue, 2);
    ReadColor(ColorValue, Result^[I - 1]);
  end;
end;

procedure DrawTIM(TIM: PTIM; ACanvas: PCanvas; Rect: TRect);
var
  PNG: TPngImage;
  RW, RH: Word;
  CLUT_DATA: PCLUT_COLORS;
  IMAGE_DATA: PIMAGE_INDEXES;
begin
  RW := IWidthToRWidth(TIM^.HEAD, TIM^.IMAGE);
  RH := GetTimHeight(TIM^.IMAGE);

  PNG := TPngImage.CreateBlank(COLOR_RGBALPHA, 16, RW, RH);
  PNG.CompressionLevel := 9;
  PNG.Filters := [pfNone];

  CLUT_DATA := PrepareCLUT(TIM);
end;

end.
