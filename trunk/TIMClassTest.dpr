program TIMClassTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  System.SysUtils,
  System.Classes,
  uTIMClass;

const
  Tab = #$09;
  ROW = #13#10;

var
  TIM: TTIM;
  IsGoodTIM, Info, FileName: string;

begin
  FileName := '..\..\tims\mix.tim';
  if not FileExists(FileName) then Exit;

  TIM := TTIM.Create;
  if not TIM.LoadFromFile(FileName, 0) then
  begin
    TIM.Free;
    Exit;
  end;

  TIM.Position := $5550525;

      if TIM.GoodImage then
        IsGoodTIM := 'YES'
      else
        IsGoodTIM := 'NO';


      Info := Format(
                     'Position:' + Tab + '0x%x' + ROW +
                     'BitMode:' + Tab + '%s' + ROW +
                     'Good:' + Tab + '%s' + ROW + ROW +

                     'HEADER INFO' + ROW +
                     'Version:' + Tab + '%d' + ROW +
                     'BPP:' + Tab + '%x' + ROW + ROW,
                     [
                      TIM.Position,
                      TIM.BitmodeAsString,
                      IsGoodTIM,

                      TIM.Version,
                      TIM.BitmodeValue
                     ]);

      if TIM.HasClut then
        Info := Format(Info +
                       'CLUT INFO' + ROW +
                       'Size (Header):' + Tab + '%d' + ROW +
                       'Size (Real):' + Tab + '%d' + ROW +
                       'VRAM X Pos:' + Tab + '%d' + ROW +
                       'VRAM Y Pos:' + Tab + '%d' + ROW +
                       'CLUTs Count:' + Tab + '%d' + ROW +
                       'Colors in 1 CLUT:' + Tab + '%d' + ROW + ROW,
                       [
                        TIM.ClutSize,
                        TIM.ClutSizeRealWHeader,
                        TIM.ClutVRAMX,
                        TIM.ClutVRAMY,
                        TIM.ClutCount,
                        TIM.ClutColors
                       ]);

      Info := Format(Info +
                     'IMAGE INFO' + ROW +
                     'Size (Header):' + Tab + '%d' + ROW +
                     'Size (Real):' + Tab + '%d' + ROW +
                     'VRAM X Pos:' + Tab + '%d' + ROW +
                     'VRAM Y Pos:' + Tab + '%d' + ROW +
                     'Width (Header):' + Tab + '%d' + ROW +
                     'Width (Real):' + Tab + '%d' + ROW +
                     'Height (Real):' + Tab + '%d',
                     [
                      TIM.ImageSize,
                      TIM.ImageSizeRealWHeader,
                      TIM.ImageVRAMX,
                      TIM.ImageVRAMY,
                      TIM.Width,
                      TIM.WidthReal,
                      TIM.Height
                     ]);


  writeln(info);
  readln;

  TIM.Free;
end.
