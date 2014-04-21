unit udrawtim;

interface

uses
  utim, Grids, Graphics, types, BGRABitmap;

type
  PCanvas = ^TCanvas;
  PDrawSurf = ^TBGRABitmap;
  PDrawGrid = ^TDrawGrid;

procedure TimToPNG(TIM: PTIM; CLUT_NUM: Integer; var Surf: PDrawSurf; TranspMode: Byte);
procedure DrawClutCell(TIM: PTIM; CLUT_NUM: Integer; Grid: PDrawGrid; X, Y: Integer);
procedure DrawCLUT(TIM: PTIM; CLUT_NUM: Integer; Grid: PDrawGrid);
procedure ClearCanvas(ACanvas: PCanvas; Rect: TRect);
procedure ClearGrid(Grid: PDrawGrid);

implementation

uses
  ucommon, BGRABitmapTypes, Math;

function PrepareCLUT(TIM: PTIM; CLUT_NUM: Integer): PCLUT_COLORS;
var
  I: Integer;
begin
  Result := nil;
  if (not TIMHasCLUT(TIM)) and (not(TIM^.HEAD^.bBPP in [cTIM4NC, cTIM8NC])) then
    Exit;

  New(Result);

  if (TIM^.HEAD^.bBPP in [cTIM4NC, cTIM8NC]) then
  begin
    Randomize;
    for I := 1 to $100 do
      Result^[I - 1] := GetCLUTColor(TIM, CLUT_NUM, I - 1);

    Exit;
  end;

  for I := 1 to GetTimColorsCount(TIM) do
    Result^[I - 1] := GetCLUTColor(TIM, CLUT_NUM, I - 1);
end;

function PrepareIMAGE(TIM: PTIM): PIMAGE_INDEXES;
var
  I, OFFSET: Integer;
  RW: Word;
  P24: Integer;
begin
  New(Result);
  OFFSET := SizeOf(TTIMHeader) + GetTIMCLUTSize(TIM) + SizeOf(TIMAGEHeader);
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

procedure ClearCanvas(ACanvas: PCanvas; Rect: TRect);
begin
  ACanvas^.FillRect(Rect);
end;

procedure ClearGrid(Grid: PDrawGrid);
var
  X, Y, W, H: Word;
begin
  W := Grid^.ColCount;
  H := Grid^.RowCount;

  for Y := 1 to H do
    for X := 1 to W do
      ClearCanvas(@Grid^.Canvas, Grid^.CellRect(X - 1, Y - 1));
end;

procedure TimToPNG(TIM: PTIM; CLUT_NUM: Integer; var Surf: PDrawSurf; TranspMode: Byte);
var
  RW, RH, CW: Word;
  CLUT_DATA: PCLUT_COLORS;
  IMAGE_DATA: PIMAGE_INDEXES;
  X, Y, INDEX, IMAGE_DATA_POS: Integer;
  R, G, B, STP, ALPHA: Byte;
  COLOR: TCLUT_COLOR;
  CL: Integer;
  P: PBGRAPixel;
  Transparent, SemiTransparent: boolean;
begin
  RW := GetTimRealWidth(TIM);
  RH := GetTimHeight(TIM);

  if (Surf^ <> nil) then Surf^.Free;

  Surf^ := TBGRABitmap.Create(RW, RH);

  CLUT_DATA := PrepareCLUT(TIM, CLUT_NUM);
  IMAGE_DATA := PrepareIMAGE(TIM);

  IMAGE_DATA_POS := 0;

  Transparent := TranspMode in [0, 1];
  SemiTransparent := TranspMode in [0, 2];

  R := 0;
  G := 0;
  B := 0;
  STP := 0;

  for Y := 1 to RH do
  begin
    P := Surf^.ScanLine[Y - 1];
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
            COLOR := ConvertTIMColor(CW);

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

      if (TIM^.HEAD^.bBPP in cTIM24) or (not(Transparent or SemiTransparent))
      then
        ALPHA := 255
      else
      begin
        if (R + G + B) = 0 then
          ALPHA := 0
        else
        begin
          if (STP = 0) then
            ALPHA := 255
          else
            ALPHA := 128;

          if (not SemiTransparent) and (ALPHA = 128) then
            ALPHA := 255;
        end;
      end;

      if ALPHA = 0 then
      begin
        B := 0;
        G := 0;
        R := 0;
      end;

      P^.alpha:=ALPHA;
      P^.blue := B;
      P^.green := G;
      P^.red := R;

      Inc(P);
      Inc(IMAGE_DATA_POS);
    end;
  end;

  Surf^.InvalidateBitmap;
  Dispose(CLUT_DATA);
  Dispose(IMAGE_DATA);
end;

procedure DrawClutCell(TIM: PTIM; CLUT_NUM: Integer; Grid: PDrawGrid;
  X, Y: Integer);
var
  CLUT_COLOR: PCLUT_COLOR;
  R, G, B, STP, ALPHA: Byte;
  Rect: TRect;
  COLS, Colors: Integer;
begin
  Colors := GetTimColorsCount(TIM);
  COLS := Min(Colors, 32);
  Rect := Grid^.CellRect(X, Y);

  if (Y * COLS + X) >= Colors then
  begin
    ClearCanvas(@Grid^.Canvas, Rect);
    Exit;
  end;

  New(CLUT_COLOR);

  CLUT_COLOR^ := GetCLUTColor(TIM, CLUT_NUM, Y * COLS + X);
  R := CLUT_COLOR^.R;
  G := CLUT_COLOR^.G;
  B := CLUT_COLOR^.B;
  STP := CLUT_COLOR^.STP;

  Grid^.Canvas.Brush.COLOR := RGBToColor(R, G, B);

  Grid^.Canvas.FillRect(Rect);

  if (R + G + B) = 0 then
    ALPHA := 0
  else
  begin
    if STP = 0 then
      ALPHA := 255
    else
      ALPHA := 128;
  end;

  if ALPHA in [0, 128] then
  begin
    Grid^.Canvas.Brush.COLOR := clWhite;
    if ALPHA = 0 then
      Rect.Bottom := Rect.Top + ((Rect.Bottom - Rect.Top) div 2)
    else
      Rect.Right := Rect.Left + ((Rect.Right - Rect.Left) div 2);

    Grid^.Canvas.FillRect(Rect);
  end;

  Dispose(CLUT_COLOR);
end;

procedure DrawCLUT(TIM: PTIM; CLUT_NUM: Integer; Grid: PDrawGrid);
var
  X, Y, ROWS, COLS, COLORS: Integer;
begin
  COLORS := GetTimColorsCount(TIM);
  COLS := Min(COLORS, 32);
  Grid^.ColCount := COLS;
  ROWS := Ceil(COLORS / COLS);

  Grid^.RowCount := ROWS;

  for Y := 1 to ROWS do
    for X := 1 to COLS do
    begin
      ClearCanvas(@Grid^.Canvas, Grid^.CellRect(X - 1, Y - 1));
      DrawClutCell(TIM, CLUT_NUM, Grid, X - 1, Y - 1);
    end;
end;

end.
