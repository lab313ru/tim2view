unit uSettings;

 interface

 uses Classes;
 {$M+}

 type
   TCustomSettings = class
   private
     procedure LoadFromStream(const Stream: TStream) ;
     procedure SaveToStream(const Stream: TStream) ;
   public
     procedure LoadFromFile() ;
     procedure SaveToFile() ;
   end;

   TSettings = class(TCustomSettings)
   private
     FTranspMode: Integer;
     FStretchMode: Boolean;
     FLastDir: string;
   public
     constructor Create;
   published
     property TranspMode: Integer read FTranspMode write FTranspMode;
     property StretchMode: Boolean read FStretchMode write FStretchMode;
     property LastDir: string read FLastDir write FLastDir;
   end;

 var
   Settings: TSettings;

 implementation

 uses TypInfo, Sysutils;

  const FileName = 'settings.t2v';

 { TSettings }

 procedure TCustomSettings.LoadFromFile() ;
 var
   Stream: TStream;
 begin
   if not FileExists(FileName) then Exit;

   Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite) ;
   try
     LoadFromStream(Stream) ;
   finally
     Stream.Free;
   end;
 end;

 procedure TCustomSettings.LoadFromStream(const Stream: TStream) ;
 var
   Reader: TReader;
   PropName, PropValue: string;
 begin
   Reader := TReader.Create(Stream, $FFF) ;
   Stream.Position := 0;
   Reader.ReadListBegin;

   while not Reader.EndOfList do
   begin
     PropName := Reader.ReadString;
     PropValue := Reader.ReadString;
     SetPropValue(Self, PropName, PropValue) ;
   end;

   FreeAndNil(Reader) ;
 end;

 procedure TCustomSettings.SaveToFile() ;
 var
   Stream: TStream;
 begin
   Stream := TFileStream.Create(FileName, fmCreate) ;
   try
     SaveToStream(Stream) ;
   finally
     Stream.Free;
   end;
 end;

 procedure TCustomSettings.SaveToStream(const Stream: TStream) ;
 var
   PropName, PropValue: string;
   cnt: Integer;
   lPropInfo: PPropInfo;
   lPropCount: Integer;
   lPropList: PPropList;
   lPropType: PPTypeInfo;
   Writer: TWriter;
 begin
   lPropCount := GetPropList(PTypeInfo(ClassInfo), lPropList) ;
   Writer := TWriter.Create(Stream, $FFF) ;
   Stream.Size := 0;
   Writer.WriteListBegin;
   for cnt := 0 to lPropCount - 1 do
   begin
     lPropInfo := lPropList^[cnt];
     lPropType := lPropInfo^.PropType;
     if lPropType^.Kind = tkMethod then Continue;

     PropName := lPropInfo.Name;
     PropValue := GetPropValue(Self, lPropInfo) ;
     Writer.WriteString(PropName) ;
     Writer.WriteString(PropValue) ;
   end;

   Writer.WriteListEnd;
   FreeAndNil(Writer) ;
 end;

 { TSettings }

constructor TSettings.Create;
begin
  FTranspMode := 0;
  FStretchMode := False;
end;

initialization
   Settings := TSettings.Create;
 finalization
   FreeAndNil(Settings) ;
 end.
