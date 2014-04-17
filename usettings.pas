unit usettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, Graphics;

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
    public
      constructor Create(const DirPath: string);
      destructor Destroy; override;
      property TranspMode: Integer read FTranspModeRead write FTranspModeWrite;
      property StretchMode: Boolean read FStretchModeRead write FStretchModeWrite;
      property LastDir: string read FLastDirRead write FLastDirWrite;
      property BackColor: TColor read FBackColorRead write FBackColorWrite;
  end;

implementation

uses FileUtil;

const sMain = 'main';

{ TSettings }

procedure TSettings.FTranspModeWrite(Value: Integer);
begin
  FIniFile.WriteInteger(sMain, 'TranspMode', Value);
end;

function TSettings.FTranspModeRead: Integer;
begin
  Result := FIniFile.ReadInteger(sMain, 'TranspMode', 0);
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

