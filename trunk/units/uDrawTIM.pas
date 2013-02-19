unit uDrawTIM;

interface

uses
  Vcl.Graphics, uTIM, System.Types;

type
  PCanvas = ^TCanvas;

procedure DrawTIM(TIM: PTIM; ACanvas: PCanvas; Rect: TRect);

implementation

uses
  Vcl.Imaging.pngimage, Windows;

function ReadColor(ColorValue: Word): TCLUT_COLOR;
begin
  Result.R := (ColorValue and $1F);
  Result.G := (ColorValue and $3E0) shr 5;
  Result.B := (ColorValue and $7C00) shr 10;
  Result.STP := (ColorValue and $8000) shr 15;
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
  OFFSET := cTIMHeadSize + GetTIMCLUTSize(TIM^.HEAD, TIM^.CLUT) +
            cIMAGEHeadSize;
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

procedure DrawTIM(TIM: PTIM; ACanvas: PCanvas; Rect: TRect);
var
  PNG: TPngImage;
  RW, RH, CW: Word;
  CLUT_DATA: PCLUT_COLORS;
  IMAGE_DATA: PIMAGE_INDEXES;
  X, Y, INDEX, IMAGE_DATA_POS: Integer;
  R, G, B, STP, ALPHA: Byte;
  COLOR: TCLUT_COLOR;
  CL: DWORD;
begin
  CLUT_DATA := PrepareCLUT(TIM);
  IMAGE_DATA := PrepareIMAGE(TIM);

  RW := IWidthToRWidth(TIM^.HEAD, TIM^.IMAGE);
  RH := GetTimHeight(TIM^.IMAGE);

  PNG := TPngImage.CreateBlank(COLOR_RGBALPHA, 16, RW, RH);
  PNG.CompressionLevel := 9;
  PNG.Filters := [];

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

          R := CLUT_DATA^[INDEX].R * 8;
          G := CLUT_DATA^[INDEX].G * 8;
          B := CLUT_DATA^[INDEX].B * 8;
          STP := CLUT_DATA^[INDEX].STP;
        end;
        cTIM16C, cTIM16NC, cTIMMix:
        begin
          Move(IMAGE_DATA^[IMAGE_DATA_POS], CW, 2);
          COLOR := ReadColor(CW);

          R := COLOR.R * 8;
          G := COLOR.G * 8;
          B := COLOR.B * 8;
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

      PNG.AlphaScanline[Y - 1]^[X - 1] := ALPHA;

      if ALPHA = 0 then
      begin
        B := 0;
        G := 0;
        R := 0;
      end;

      pRGBLine(PNG.Scanline[Y - 1])^[X - 1].rgbtBlue := B;
      pRGBLine(PNG.Scanline[Y - 1])^[X - 1].rgbtGreen := G;
      pRGBLine(PNG.Scanline[Y - 1])^[X - 1].rgbtRed := R;

      Inc(IMAGE_DATA_POS);
    end;

  Rect.Width := RW;
  Rect.Height := RH;
  PNG.Draw(ACanvas^, Rect);
  PNG.SaveToFile('test.png');
  PNG.Free;

  Dispose(CLUT_DATA);
  Dispose(IMAGE_DATA);

end;

end.
