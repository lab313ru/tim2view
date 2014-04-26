unit udrawtim;

interface

uses
  utim, Grids, Graphics, types, BGRABitmap;

type
  PCanvas = ^TCanvas;
  PDrawSurf = ^TBGRABitmap;
  PDrawGrid = ^TDrawGrid;


procedure Tim2Png(TIM: PTIM; CLUT_NUM: Integer; Surf: PDrawSurf; TranspMode: Byte);
procedure Png2Tim(Image: PDrawSurf; Dest: PTIM);
procedure DrawClutCell(TIM: PTIM; CLUT_NUM: Integer; Grid: PDrawGrid; X, Y: Integer);
procedure DrawClut(TIM: PTIM; CLUT_NUM: Integer; Grid: PDrawGrid);
procedure ClearCanvas(ACanvas: PCanvas; Rect: TRect);
procedure ClearGrid(Grid: PDrawGrid);

implementation

uses
  BGRABitmapTypes, Math, FPimage;

type
  PFPPalette = ^TFPPalette;

procedure AlphaForMode(C: PFPColor; TranspMode: Integer);
var
  BT, CT: Boolean;
begin
  BT := TranspMode in [0, 1];
  CT := TranspMode in [0, 2];

  if not (BT or CT) then
    C^.alpha := $FFFF
  else
  begin
    if (C^.red + C^.green + C^.blue) = 0 then
    case (C^.alpha and 1) of
      0: C^.alpha := Word(ifthen(BT, 0, $FFFF));
      1: C^.alpha := $FFFF;
    end
    else
      if CT then
      case (C^.alpha and 1) of
        0: C^.alpha := $FFFF;
        1: C^.alpha := Word(ifthen(CT, $8080, $FFFF));
      end
      else
        C^.alpha := $FFFF;
  end;
end;

function StpFromAlpha(C: PFPColor): Byte;
begin
  Result := 0;

  if (C^.red + C^.green + C^.blue) = 0 then
  case C^.alpha of
    $0000: Result := 0;
    $FFFF: Result := 1;
  end
  else
  case C^.alpha of
    $FFFF: Result := 0;
    $8080: Result := 1;
  end
end;

procedure PrepareClut(TIM: PTIM; CLUT_NUM: Integer; Pal: PFPPalette; TranspMode: Integer);
var
  I, COUNT: Integer;
  CC: TCLUT_COLOR;
  R, G, B, A: Byte;
  FC: TFPColor;
begin
  if (TIM^.HEAD^.bBPP in [cTIM16NC, cTIM24NC]) then Exit;

  if (TIM^.HEAD^.bBPP in [cTIM4NC, cTIM8NC]) then
  begin
    Randomize;
    COUNT := 256;
  end
  else
    COUNT := GetTimColorsCount(TIM);

  Pal^.Clear;
  for I := 1 to 256 do
  begin
    CC := GetCLUTColor(TIM, CLUT_NUM, I - 1);
    if I <= COUNT then
    begin
      R := CC.R;
      G := CC.G;
      B := CC.B;
      A := CC.STP;
    end
    else
    begin
      R := 0;
      G := 0;
      B := 0;
      A := 1;
    end;

    FC := BGRAToFPColor(BGRA(R, G, B, A));
    AlphaForMode(@FC, TranspMode);
    Pal^.Add(FC);
  end;
end;

function PrepareImage(TIM: PTIM): PIMAGE_INDEXES;
var
  I, OFFSET: Integer;
  RW: Word;
  P24: Integer;
  WH: Integer;
begin
  New(Result);
  OFFSET := SizeOf(TTIMHeader) + GetTIMCLUTSize(TIM) + SizeOf(TIMAGEHeader);
  RW := GetTimRealWidth(TIM);

  WH := TIM^.IMAGE^.wWidth * TIM^.IMAGE^.wHeight;
  case TIM^.HEAD^.bBPP of
    cTIM4C, cTIM4NC:
      for I := 1 to WH * 2 do
      begin
        Result^[(I - 1) * 2] := TIM^.DATA^[OFFSET + I - 1] and $F;
        Result^[(I - 1) * 2 + 1] := (TIM^.DATA^[OFFSET + I - 1] and $F0) shr 4;
      end;

    cTIM8C, cTIM8NC:
      for I := 1 to WH * 2 do
        Result^[I - 1] := TIM^.DATA^[OFFSET + I - 1];

    cTIM16C, cTIM16NC:
      for I := 1 to WH do
        Move(TIM^.DATA^[OFFSET + (I - 1) * 2], Result^[I - 1], 2);

    cTIM24C, cTIM24NC:
      begin
        I := 1;
        P24 := 0;

        while I <= (WH * 2) do
        begin
          Result^[P24] := 0;
          Move(TIM^.DATA^[OFFSET + (I - 1)], Result^[P24], 3);
          Inc(I, 3);

          if Odd(RW) and (((P24 + 1) mod RW) = 0) then Inc(OFFSET);

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

procedure Tim2Png(TIM: PTIM; CLUT_NUM: Integer; Surf: PDrawSurf; TranspMode: Byte);
var
  RW, RH, CW: Word;
  INDEXES: PIMAGE_INDEXES;
  X, Y, INDEX, IDX, COLORS: Integer;
  R, G, B: Byte;
  CC: TCLUT_COLOR;
  PAL: PFPPalette;
  FC: TFPColor;
begin
  RW := GetTimRealWidth(TIM);
  RH := GetTimHeight(TIM);

  if (Surf^ <> nil) then Surf^.Free;

  Surf^ := TBGRABitmap.Create(RW, RH);
  Surf^.UsePalette := not(TIM^.HEAD^.bBPP in [cTIM16NC, cTIM24NC]);

  PAL := @(Surf^.Palette);

  PrepareClut(TIM, CLUT_NUM, PAL, TranspMode);
  INDEXES := PrepareIMAGE(TIM);

  COLORS := GetTimColorsCount(TIM);
  IDX := 0;

  R := 0;
  G := 0;
  B := 0;

  for Y := 1 to RH do
    for X := 1 to RW do
    begin
      case TIM^.HEAD^.bBPP of
        cTIM4C, cTIM4NC, cTIM8C, cTIM8NC: Surf^.Pixels[X - 1, Y - 1] := INDEXES^[IDX] mod COLORS;
        cTIM16C, cTIM16NC, cTIMMix:
          begin
            CW := 0;
            Move(INDEXES^[IDX], CW, 2);
            CC := ConvertTIMColor(CW);

            FC := BGRAToFPColor(BGRA(CC.R, CC.G, CC.B, CC.STP));
            AlphaForMode(@FC, TranspMode);

            Surf^.Colors[X - 1, Y - 1] := FC;
          end;
        cTIM24C, cTIM24NC:
          begin
            INDEX := INDEXES^[IDX];

            R := (INDEX and $FF);
            G := ((INDEX and $FF00) shr 8);
            B := ((INDEX and $FF0000) shr 16);
            Surf^.Colors[X - 1, Y - 1] := BGRAToFPColor(BGRA(R, G, B, 255));
          end;
      else
        Break;
      end;
      Inc(IDX);
    end;

  Dispose(INDEXES);
end;

procedure Png2Tim(Image: PDrawSurf; Dest: PTIM);
var
  IW, IH, X, Y, CW: Word;
  TData: PTIMDataArray;
  IDX, POS, C: Integer;
  CC: TCLUT_COLOR;
  PC: TBGRAPixel;
  FC: TFPColor;
  CD: DWord;
begin
  IW := Image^.Width;
  IH := Image^.Height;

  TData := @Dest^.DATA^[SizeOf(TTIMHeader) + GetTIMCLUTSize(Dest) + SizeOf(TIMAGEHeader)];
  { TODO : Fix colors finding. }

  POS := 0;
  for Y := 1 to IH do
    case Dest^.HEAD^.bBPP of
      cTIM4C, cTIM4NC:
        for X := 1 to (IW div 2) do
        begin
          IDX := Image^.Pixels[X - 1, Y - 1];
          TData^[POS] := (IDX and $F);
          IDX := Image^.Pixels[X, Y - 1];
          TData^[POS] := TData^[0] + (IDX and $F0);
          Inc(POS);
        end;

      cTIM8C, cTIM8NC:
        for X := 1 to IW do
        begin
          C := Image^.Pixels[X - 1, Y - 1];
          TData^[POS] := Byte(C);
          Inc(POS);
        end;

      cTIM16C, cTIM16NC:
        for X := 1 to IW do
        begin
          FC := Image^.Colors[X - 1, Y - 1];
          CC.STP := StpFromAlpha(@FC);
          PC := FPColorToBGRA(FC);
          CC.R := PC.red;
          CC.G := PC.green;
          CC.B := PC.blue;

          CW := ConvertCLUTColor(CC);

          Move(CW, TData^[POS], 2);
          Inc(POS, 2);
        end;

      cTIM24C, cTIM24NC:
        for X := 1 to IW do
        begin
          FC := Image^.Colors[X - 1, Y - 1];
          PC := FPColorToBGRA(FC);
          CD := (PC.blue shl 16) + (PC.green shl 8) + PC.red;

          Move(CD, TData^[POS], 3);
          Inc(POS, 3);

          if Odd(IW) and ((IW - X) = 0) then
          begin
            TData^[POS] := 0;
            Inc(POS);
          end;
        end;
  end;
end;

procedure DrawClutCell(TIM: PTIM; CLUT_NUM: Integer; Grid: PDrawGrid; X, Y: Integer);
var
  CLUT_COLOR: PCLUT_COLOR;
  R, G, B, STP: Byte;
  Rect: TRect;
  COLS, Colors: Integer;
  FC: TFPColor;
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

  FC := BGRAToFPColor(BGRA(R, G, B, STP));
  AlphaForMode(@FC, 0);

  if (FC.alpha = 0) or (FC.alpha = $8080) then
  begin
    Grid^.Canvas.Brush.COLOR := clWhite;
    if FC.ALPHA = 0 then
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
