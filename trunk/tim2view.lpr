program tim2view;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads, cmem,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, umain, edc, ucommon, ecc, ucdimage, utim, usettings, uscanresult,
  uscanthread, ucpucount, udrawtim, BGRABitmap;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

