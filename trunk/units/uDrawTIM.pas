unit uDrawTIM;

interface

uses
  Vcl.Graphics, uTIM, System.Types, Vcl.Imaging.pngimage, Vcl.Grids;

type
  PCanvas = ^TCanvas;
  PPNGImage = ^TPngImage;
  PDrawGrid = ^TDrawGrid;

procedure DrawTIM(TIM: PTIM; ACanvas: PCanvas; Rect: TRect; var PNG: PPNGImage);
procedure TimToPNG(TIM: PTIM; var PNG: PPngImage);
procedure DrawPNG(PNG: PPNGImage; ACanvas: PCanvas; Rect: TRect);
procedure DrawCLUT(TIM: PTIM; Grid: PDrawGrid);

implementation

uses
  Windows;

function ReadColor(ColorValue: Word): TCLUT_COLOR;
begin
  Result.R := (ColorValue and $1F) * 8;
  Result.G := ((ColorValue and $3E0) shr 5) * 8;
  Result.B := ((ColorValue and $7C00) shr 10) * 8;
  Result.STP := ((ColorValue and $8000) shr 15);
end;

function PrepareCLUT(TIM: PTIM): PCLUT_COLORS;
var
  ColorValue: Word;
  I: Integer;
begin
  Result := nil;
  if (not isTIMHasCLUT(TIM)) and
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

  for I := 1 to GetTIMCLUTSize(TIM) do
  begin
    Move(TIM^.DATA^[cTIMHeadSize + cCLUTHeadSize + (I - 1) * 2], ColorValue, 2);
    Result^[I - 1] := ReadColor(ColorValue);
  end;
end;

function PrepareIMAGE(TIM: PTIM): PIMAGE_INDEXES;
var
  I, OFFSET: Integer;
  RW: Word;
  P24: DWORD;
begin
  New(Result);
  OFFSET := cTIMHeadSize + GetTIMCLUTSize(TIM) + cIMAGEHeadSize;
  RW := GetTimRealWidth(TIM);

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
    for I := 1 to TIM^.IMAGE^.wWidth * TIM^.IMAGE^.wHeight do
      Move(TIM^.DATA^[OFFSET + (I - 1) * 2], Result^[I - 1], 2);

    cTIM24C, cTIM24NC:
    begin
      I := 1;
      P24 := 0;

      while I <= (TIM^.IMAGE^.wWidth * TIM^.IMAGE^.wHeight * 2) do
      begin
        Result^[P24] := 0;
        Move(TIM^.DATA^[OFFSET + (I - 1)], Result^[P24], 3);
        Inc(I, 3);

        if Odd(RW) and (((P24 + 1) mod RW) = 0) then
        Inc(OFFSET);

        Inc(P24);
      end;
    end;
  end;
end;

procedure TimToPNG(TIM: PTIM; var PNG: PPngImage);
var
  RW, RH, CW: Word;
  CLUT_DATA: PCLUT_COLORS;
  IMAGE_DATA: PIMAGE_INDEXES;
  X, Y, INDEX, IMAGE_DATA_POS: Integer;
  R, G, B, STP, ALPHA: Byte;
  COLOR: TCLUT_COLOR;
  CL: DWORD;
begin
  RW := GetTimRealWidth(TIM);
  RH := GetTimHeight(TIM);

  PNG^ := TPngImage.CreateBlank(COLOR_RGBALPHA, 16, RW, RH);
  PNG^.CompressionLevel := 9;
  PNG^.Filters := [];

  CLUT_DATA := PrepareCLUT(TIM);
  IMAGE_DATA := PrepareIMAGE(TIM);

  IMAGE_DATA_POS := 0;

  R := 0;
  G := 0;
  B := 0;
  STP := 0;

  for Y := 1 to RH do
    for X := 1 to RW do
    begin
      case TIM^.HEAD^.bBPP of
        cTIM4C, cTIM4NC, cTIM8C, cTIM8NC:
        begin
          INDEX := IMAGE_DATA^[IMAGE_DATA_POS];

          R := CLUT_DATA^[INDEX].R;
          G := CLUT_DATA^[INDEX].G;
          B := CLUT_DATA^[INDEX].B;
          STP := CLUT_DATA^[INDEX].STP;
        end;
        cTIM16C, cTIM16NC, cTIMMix:
        begin
          Move(IMAGE_DATA^[IMAGE_DATA_POS], CW, 2);
          COLOR := ReadColor(CW);

          R := COLOR.R;
          G := COLOR.G;
          B := COLOR.B;
          STP := COLOR.STP;
        end;
        cTIM24C, cTIM24NC:
        begin
          CL := IMAGE_DATA^[IMAGE_DATA_POS];

          R := (CL and $FF);
          G := ((CL and $FF00) shr 8);
          B := ((CL and $FF0000) shr 16);
          STP := 0;
        end;
      else
        Break;
      end;

      if (TIM^.HEAD^.bBPP in cTIM24) then
        ALPHA := 255
      else
      begin
        if (R + G + B) = 0 then
          ALPHA := STP * 255
        else
        begin
          if STP = 0 then
            ALPHA := 255
          else
            ALPHA := 128;
        end;
      end;

      PNG^.AlphaScanline[Y - 1]^[X - 1] := ALPHA;

      if ALPHA = 0 then
      begin
        B := 0;
        G := 0;
        R := 0;
      end;

      pRGBLine(PNG^.Scanline[Y - 1])^[X - 1].rgbtBlue := B;
      pRGBLine(PNG^.Scanline[Y - 1])^[X - 1].rgbtGreen := G;
      pRGBLine(PNG^.Scanline[Y - 1])^[X - 1].rgbtRed := R;

      Inc(IMAGE_DATA_POS);
    end;

  Dispose(CLUT_DATA);
  Dispose(IMAGE_DATA);
end;

procedure DrawTIM(TIM: PTIM; ACanvas: PCanvas; Rect: TRect; var PNG: PPNGImage);
begin
  TimToPNG(TIM, PNG);
  DrawPNG(PNG, ACanvas, Rect);
end;

procedure DrawPNG(PNG: PPNGImage; ACanvas: PCanvas; Rect: TRect);
begin
  if PNG^ = nil then Exit;

  PatBlt(ACanvas^.Handle, 0, 0, Rect.Width, Rect.Height, WHITENESS);

  Rect.Width := PNG^.Width;
  Rect.Height := PNG^.Height;

  PNG^.Draw(ACanvas^, Rect);
end;

procedure DrawCLUT(TIM: PTIM; Grid: PDrawGrid);
var
  X, Y, W, H: Word;
  CLUT_DATA: PCLUT_COLORS;
  R, G, B, STP, ALPHA: Byte;
  Rect: TRect;
begin
  W := TIM^.CLUT^.wColorsCount;
  H := TIM^.CLUT^.wClutsCount;
  Grid^.ColCount := W;
  Grid^.RowCount := H;

  CLUT_DATA := PrepareCLUT(TIM);

  for Y := 1 to H do
    for X := 1 to W do
    begin
      Grid^.ColWidths[X - 1] := (Grid^.Width div W) * W;
      Grid^.RowHeights[Y - 1] := Grid^.ColWidths[X - 1];
      R := CLUT_DATA^[(Y - 1) * W + (X - 1)].R;
      G := CLUT_DATA^[(Y - 1) * W + (X - 1)].G;
      B := CLUT_DATA^[(Y - 1) * W + (X - 1)].B;
      STP := CLUT_DATA^[(Y - 1) * W + (X - 1)].STP;
      Grid^.Canvas.Brush.Color := RGB(R, G, B);
      Rect := Grid^.CellRect(X - 1, Y - 1);
      Grid^.Canvas.FillRect(Rect);

      if (R + G + B) = 0 then
        ALPHA := STP * 255
      else
      begin
        if STP = 0 then
          ALPHA := 255
        else
          ALPHA := 128;
      end;

      if ALPHA in [0, 128] then
      begin
        Grid^.Canvas.Brush.Color := clWhite;
        Rect.Top := Rect.Height div 2;
        Grid^.Canvas.FillRect(Rect);
      end;

    end;

  Dispose(CLUT_DATA);
  Grid^.Invalidate;

end;

end.
