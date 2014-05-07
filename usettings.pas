unit usettings;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, IniFiles, Graphics;

type

  { TSettings }

  TSettings = class
    private
      FIniFile: TIniFile;
      procedure FTranspModeWrite(Value: Integer);
      function  FTranspModeRead(): Integer;
      procedure FStretchModeWrite(Value: Boolean);
      function  FStretchModeRead(): Boolean;
      procedure FLastDirWrite(const Value: string);
      function  FLastDirRead(): string;
      procedure FBackColorWrite(Color: TColor);
      function  FBackColorRead(): TColor;
      procedure FBitModeWrite(Mode: Integer);
      function  FBitModeRead(): Integer;
      procedure FInfoVisibleWrite(Value: Boolean);
      function  FInfoVisibleRead(): Boolean;
    public
      constructor Create(const DirPath: string);
      destructor Destroy; override;

      procedure AssociateWithTims;

      property TranspMode: Integer read FTranspModeRead write FTranspModeWrite;
      property StretchMode: Boolean read FStretchModeRead write FStretchModeWrite;
      property LastDir: string read FLastDirRead write FLastDirWrite;
      property BackColor: TColor read FBackColorRead write FBackColorWrite;
      property BitMode: Integer read FBitModeRead write FBitModeWrite;
      property InfoVisible: Boolean read FInfoVisibleRead write FInfoVisibleWrite;
  end;

implementation

uses FileUtil

{$IFDEF windows}
,registry
{$IFEND}
;

const sMain = 'main';

{ TSettings }

procedure TSettings.AssociateWithTims;
{$IFDEF windows}
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;

  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('Software\Classes\.tim', True);
    reg.WriteString('', 'TimFile');
    reg.CloseKey;

    reg.OpenKey('Software\Classes\TimFile', True);
    reg.WriteString('', 'Tim File Format');
    reg.CloseKey;
    reg.OpenKey('Software\Classes\TimFile\DefaultIcon', True);
    reg.WriteString('', '"' + ParamStr(0) +'",0');
    reg.CloseKey;
    reg.OpenKey('Software\Classes\TimFile\shell\Open\Command', True);
    reg.WriteString('', '"' + ParamStr(0) + '" "%1"');
    reg.CloseKey;
  finally
    reg.Free;
  end;
{$ELSE}
begin
{$ENDIF}
end;

procedure TSettings.FTranspModeWrite(Value: Integer);
begin
  FIniFile.WriteInteger(sMain, 'TranspMode', Value);
end;

function TSettings.FTranspModeRead: Integer;
begin
  Result := FIniFile.ReadInteger(sMain, 'TranspMode', 1);
end;

procedure TSettings.FStretchModeWrite(Value: Boolean);
begin
  FIniFile.WriteBool(sMain, 'StretchMode', Value);
end;

function TSettings.FStretchModeRead: Boolean;
begin
  Result := FIniFile.ReadBool(sMain, 'StretchMode', False);
end;

procedure TSettings.FLastDirWrite(const Value: string);
begin
  FIniFile.WriteString(sMain, 'LastDir', UTF8ToSys(Value));
end;

function TSettings.FLastDirRead: string;
begin
  Result := SysToUtf8(FIniFile.ReadString(sMain, 'LastDir', ''));
end;

procedure TSettings.FBackColorWrite(Color: TColor);
begin
  FIniFile.WriteInteger(sMain, 'BackColor', Color);
end;

function TSettings.FBackColorRead: TColor;
begin
  Result := FIniFile.ReadInteger(sMain, 'BackColor', clBtnFace);
end;

procedure TSettings.FBitModeWrite(Mode: Integer);
begin
  FIniFile.WriteInteger(sMain, 'BitMode', Mode);
end;

function TSettings.FBitModeRead: Integer;
begin
  Result := FIniFile.ReadInteger(sMain, 'BitMode', 0);
end;

procedure TSettings.FInfoVisibleWrite(Value: Boolean);
begin
  FIniFile.WriteBool(sMain, 'InfoVisible', Value);
end;

function TSettings.FInfoVisibleRead: Boolean;
begin
  Result := FIniFile.ReadBool(sMain, 'InfoVisible', True);
end;

constructor TSettings.Create(const DirPath: string);
begin
  inherited Create;

  FIniFile := TIniFile.Create(IncludeTrailingPathDelimiter(DirPath) + 'settings.t2v');
end;

destructor TSettings.Destroy;
begin
  FIniFile.Free;

  inherited Destroy;
end;

end.

