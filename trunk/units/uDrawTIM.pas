unit uDrawTIM;

interface

uses
  Vcl.Graphics, uTIM, System.Types;

type
  PCanvas = ^TCanvas;

procedure DrawTIM(TIM: PTIM; ACanvas: PCanvas; Rect: TRect);

implementation

uses
  Vcl.Imaging.pngimage, uCommon, Windows;

function ReadColor(ColorValue: Word): TCLUT_COLOR;
begin
  Result.R := (ColorValue and $1F);
  Result.G := (ColorValue and $3E0) shr 5;
  Result.B := (ColorValue and $7C00) shr 10;
  Result.STP := (ColorValue and $FFFF8000) shr 15;
end;

function PrepareCLUT(TIM: PTIM): PCLUT_COLORS;
var
  ColorValue: Word;
  I: Integer;
begin
  Result := nil;
  if (not isTIMHasCLUT(TIM^.HEAD)) and
     (not (TIM^.HEAD^.bBPP in [cTIM4NC, cTIM8NC]))
  then
    Exit;

  New(Result);

  if (TIM^.HEAD^.bBPP in [cTIM4NC, cTIM8NC]) then
  begin
    Randomize;
    for I := 1 to cRandomPaletteSize do
    begin
      Result^[I - 1].R := random($20) * 8;
      Result^[I - 1].G := random($20) * 8;
      Result^[I - 1].B := random($20) * 8;
      Result^[I - 1].STP := 1;
    end;
    Exit;
  end;

  for I := 1 to GetTIMCLUTSize(TIM^.HEAD, TIM^.CLUT) do
  begin
    Move(TIM^.DATA^[cTIMHeadSize + (I - 1) * 2], ColorValue, 2);
    Result^[I - 1] := ReadColor(ColorValue);
  end;
end;

function PrepareIMAGE(TIM: PTIM): PIMAGE_INDEXES;
var
  I, OFFSET: Integer;
  RW: Word;
begin
  New(Result);
  OFFSET := cTIMHeadSize + GetTIMCLUTSize(TIM^.HEAD, TIM^.CLUT);
  RW := IWidthToRWidth(TIM^.HEAD, TIM^.IMAGE);

  case TIM^.HEAD^.bBPP of
    cTIM4C, cTIM4NC:
    for I := 1 to TIM^.IMAGE^.wWidth * TIM^.IMAGE^.wHeight * 2 do
    begin
      Result^[(I - 1) * 2] := TIM^.DATA^[OFFSET + I - 1] and $F;
      Result^[(I - 1) * 2 + 1] := (TIM^.DATA^[OFFSET + I - 1] and $F0) shr 4;
    end;

    cTIM8C, cTIM8NC:
    for I := 1 to TIM^.IMAGE^.wWidth * TIM^.IMAGE^.wHeight * 2 do
      Result^[I - 1] := TIM^.DATA^[OFFSET + I - 1];

    cTIM16C, cTIM16NC:
    for I := 1 to TIM^.IMAGE^.wWidth * TIM^.IMAGE^.wHeight * 2 do
      Move(TIM^.DATA^[OFFSET + (I - 1) * 2], Result^[(I - 1) * 2], 2);

    cTIM24C, cTIM24NC:
    for I := 1 to TIM^.IMAGE^.wWidth * TIM^.IMAGE^.wHeight * 2 do
    begin
      if Odd(RW) and ((i mod RW) = 0) then Continue;

      Move(TIM^.DATA^[OFFSET + (I - 1) * 3], Result^[(I - 1) * 3], 3);
    end;
  end;
end;

procedure DrawTIM(TIM: PTIM; ACanvas: PCanvas; Rect: TRect);
var
  PNG: TPngImage;
  RW, RH: Word;
  CLUT_DATA: PCLUT_COLORS;
  IMAGE_DATA: PIMAGE_INDEXES;
  X, Y, INDEX: Integer;
  R, G, B: Byte;
begin
  CLUT_DATA := PrepareCLUT(TIM);
  IMAGE_DATA := PrepareIMAGE(TIM);

  RW := IWidthToRWidth(TIM^.HEAD, TIM^.IMAGE);
  RH := GetTimHeight(TIM^.IMAGE);

  PNG := TPngImage.CreateBlank(COLOR_RGBALPHA, 16, RW, RH);
  PNG.CompressionLevel := 9;
  PNG.Filters := [pfNone];

  for Y := 1 to RH do
    for X := 1 to RW do
    begin
      INDEX := IMAGE_DATA^[Y * RW + X];

     // if CLUT_DATA^[INDEX].STP = 0 then
     // begin
        R := CLUT_DATA^[INDEX].R * 8;
        G := CLUT_DATA^[INDEX].G * 8;
        B := CLUT_DATA^[INDEX].B * 8;
        pRGBLine(PNG.Scanline[Y - 1])^[X - 1].rgbtBlue := B;
        pRGBLine(PNG.Scanline[Y - 1])^[X - 1].rgbtGreen := G;
        pRGBLine(PNG.Scanline[Y - 1])^[X - 1].rgbtRed := R;
        PNG.AlphaScanline[y - 1]^[x - 1] := 255;
    //  end;
    end;

  PNG.Draw(ACanvas^, Rect);
  PNG.SaveToFile('test.png');
  PNG.Free;

  Dispose(CLUT_DATA);
  Dispose(IMAGE_DATA);

end;

end.
