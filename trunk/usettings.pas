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

      {$IFDEF windows}
      function FGetSendtoShortcutPath: WideString;
      procedure FCreateSendtoShortcut;
      function FSendtoShortcutExists: Boolean;
      {$IFEND}
    public
      constructor Create(const DirPath: string);
      destructor Destroy; override;

      {$IFDEF windows}
      procedure AddToSendTo(Delete: Boolean);
      property SendToShortcutExists: Boolean read FSendtoShortcutExists;
      {$IFEND}

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
,windows, shlobj {for special folders}, ActiveX, ComObj
{$ENDIF}
;

const
  sMain = 'main';
  sSendtoShortcut : string = 'Open in Tim2View';

{ TSettings }

procedure TSettings.AddToSendTo(Delete: Boolean);
{$IFDEF windows}
var
  path: string;
begin
  if Delete then
  begin
    path := UTF8Encode(FGetSendtoShortcutPath);
    DeleteFile(PChar(Utf8ToSys(path)));
  end
  else
    FCreateSendtoShortcut;
{$ELSE}
begin
{$ENDIF}
end;

{$IFDEF windows}
function TSettings.FGetSendtoShortcutPath: WideString;
var
  PIDL: PItemIDList;
  InFolder: array[0..MAX_PATH] of Char;
begin
  SHGetSpecialFolderLocation(0, CSIDL_SENDTO, PIDL);
  SHGetPathFromIDList(PIDL, InFolder);
  Result := InFolder + PathDelim + UTF8ToSys(sSendtoShortcut)+'.lnk';
end;

procedure TSettings.FCreateSendtoShortcut;
var
  IObject: IUnknown;
  ISLink: IShellLink;
  IPFile: IPersistFile;
  TargetPath: string;
begin
  { Creates an instance of IShellLink }
  IObject := CreateComObject(CLSID_ShellLink);
  ISLink := IObject as IShellLink;
  IPFile := IObject as IPersistFile;

  TargetPath := ParamStr(0);
  ISLink.SetPath(pChar(TargetPath));
  ISLink.SetArguments(pChar(''));
  ISLink.SetWorkingDirectory(pChar(ExtractFilePath(TargetPath)));

  { Create the link }
  IPFile.Save(PWChar(FGetSendtoShortcutPath), false);
end;

function TSettings.FSendtoShortcutExists: Boolean;
begin
  Result := FileExists(FGetSendtoShortcutPath);
end;
{$ENDIF}

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

