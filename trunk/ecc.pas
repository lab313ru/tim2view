unit ecc;

interface

uses
  ucommon;

const
  L1_RAW = 24;
  L1_Q = 4;
  L1_P = 4;

  L2_RAW = (1024 * 2);
  L2_Q = (26 * 2 * 2);
  L2_P = (43 * 2 * 2);

Procedure encode_L2_Q(Data: PBytesArray);
Procedure encode_L2_P(Data: PBytesArray);

implementation

{$INCLUDE l2sq_table.inc}

Procedure encode_L2_Q(Data: PBytesArray);
var
  i, j, PQ, PD, PD_S, PD_P: Integer;
  a, b: Word;
begin
  // unsigned char inout[4 + L2_RAW + 4 + 8 + L2_P + L2_Q];

  PD := 0;
  PQ := PD + 4 + L2_RAW + 4 + 8 + L2_P;
  // Q := Pointer(LongWord(Data) + 4 + L2_RAW + 4 + 8 + L2_P);
  PD_S := PD;
  For j := 0 To 26 - 1 do
  begin
    a := 0;
    b := 0;
    PD_P := PD_S;
    For i := 0 To 43 - 1 do
    begin
      (* LSB *)
      a := a XOR L2sq[i][Data^[PD_P]];
      Inc(PD_P);

      (* MSB *)
      b := b XOR L2sq[i][Data^[PD_P]];

      Inc(PD_P, 2 * 44 - 1);
      if PD_P >= PD + (4 + L2_RAW + 4 + 8 + L2_P) Then
        Dec(PD_P, (4 + L2_RAW + 4 + 8 + L2_P));
    end;
    Data^[PQ + 0] := a SHR 8;
    Move(a, Data^[PQ + 26 * 2], 1);
    // Q^[26*2]   := a;
    Data^[PQ + 1] := b SHR 8;
    Move(b, Data^[PQ + 26 * 2 + 1], 1);
    // Q^[26*2+1] := b;

    Inc(PQ, 2);
    Inc(PD_S, 2 * 43);
  end;
end;

Procedure encode_L2_P(Data: PBytesArray);
// unsigned char inout[4 + L2_RAW + 4 + 8 + L2_P];
var
  i, j, PD, PD_PP, PD_P: Integer;
  a, b: Word;
begin

  PD := 0;
  PD_PP := PD + 4 + L2_RAW + 4 + 8;
  // LongWord(P) := PD + 4 + L2_RAW + 4 + 8;

  For j := 0 To 43 - 1 do
  begin
    a := 0;
    b := 0;
    PD_P := PD;
    For i := 19 to 43 - 1 do
    begin
      (* LSB *)
      a := a xor L2sq[i][Data^[PD_P]];
      Inc(PD_P);

      (* MSB *)
      b := b xor L2sq[i][Data^[PD_P]];

      Inc(PD_P, 2 * 43 - 1);
    end;
    Data^[PD_PP + 0] := a SHR 8;
    Move(a, Data^[PD_PP + 43 * 2], SizeOf(a));
    // P^[43*2]   := a;
    Data^[PD_PP + 1] := b SHR 8;
    Move(b, Data^[PD_PP + 43 * 2 + 1], SizeOf(b));
    // P^[43*2+1] := b;

    Inc(PD_PP, 2);
    Inc(PD, 2);
  end;
end;

end.
