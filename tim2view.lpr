program tim2view;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads, cmem,
  {$ENDIF}
  Forms, umain, Interfaces,
  Windows;

{$R *.res}

begin
  AllocConsole;      // in Windows unit
  IsConsole := True; // in System unit
  SysInitStdIO;      // in System unit
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

