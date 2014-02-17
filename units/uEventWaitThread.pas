unit uEventWaitThread;

interface

uses
  Windows, Classes;

type
  TEventWaitThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

var
  CommandEvent: THandle;

implementation

uses
  uMain;

{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TEventWaitThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TEventWaitThread }

procedure TEventWaitThread.Execute;
begin
  while True do
  begin
    if WaitForSingleObject(CommandEvent, INFINITE) <> WAIT_OBJECT_0 then
      Exit;
    PostMessage(frmMain.Handle, WM_COMMANDARRIVED, 0, 0);
  end;
end;

end.
