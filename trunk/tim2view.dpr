program tim2view;

uses
  Windows,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  ecc in 'units\ecc.pas',
  edc in 'units\edc.pas',
  uCDIMAGE in 'units\uCDIMAGE.pas',
  uCommon in 'Units\uCommon.pas',
  uMain in 'Units\uMain.pas' {frmMain},
  uScanThread in 'Units\uScanThread.pas',
  uTIM in 'units\uTIM.pas',
  uDrawTIM in 'units\uDrawTIM.pas',
  uEventWaitThread in 'units\uEventWaitThread.pas',
  uBrowseForFolder in 'units\uBrowseForFolder.pas',
  uScanResult in 'units\uScanResult.pas';

{$R *.res}

const
  cMailslot = '\\.\mailslot\t2v_slot';
  cEventNname = 't2v_open_event';

var
  ClientMailSlot: THandle;
  path: string;
  BytesWritten: DWORD;

begin
  ServerMailSlot := CreateMailslot(cMailslot, 0, MAILSLOT_WAIT_FOREVER, nil);

  if ServerMailSlot = INVALID_HANDLE_VALUE then
  begin
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      ClientMailSlot := CreateFile(cMailslot, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

      if ParamCount > 0 then
        path := ParamStr(1)
      else
        path := '';

      if path <> '' then
        WriteFile(ClientMailSlot, path[1], Length(path) * SizeOf(Char), BytesWritten, nil);

      CommandEvent := OpenEvent(EVENT_MODIFY_STATE, False, cEventNname);
      SetEvent(CommandEvent);

      CloseHandle(CommandEvent);
      CloseHandle(ClientMailSlot);
    end;
  end
  else
  begin
    CommandEvent := CreateEvent(nil, False, False, cEventNname);

    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TfrmMain, frmMain);
  Application.Run;

    CloseHandle(ServerMailSlot);
    CloseHandle(CommandEvent);
  end;
end.
