unit u_xpl_application;

{$mode objfpc}{$H+}{$M+}

interface

uses SysUtils
     , Classes
     {$ifdef fpc}
     , UniqueInstanceRaw
     {$endif}
     , VersionChecker
     , u_xpl_address
     , u_xpl_folders
     , u_xpl_settings
     , u_xpl_common
     , u_xpl_vendor_file
     , u_xml_xplplugin
     , vinfo
     ;

type { TxPLApplication =======================================================}
     TxPLApplication = class(TComponent)
     private
        fSettings   : TxPLCustomSettings;
        fFolders    : TxPLCustomFolders;
        fAdresse    : TxPLAddress;
        fOnLogEvent : TStrParamEvent;
        fPluginList : TxPLVendorSeedFile;
        fLocaleDomains : TStringList;
        fVChecker   : TVersionChecker;
        Info        : TVersionInfo;
     public
        constructor Create(const aOwner : TComponent); overload;
        destructor  Destroy; override;

        function BuildDate : string; inline;
        function AppName   : string; inline;
        function FullTitle : string; inline;
        function LogFileName : TFilename; inline;

        function DeviceInVendorFile : TXMLDeviceType;

        procedure RegisterMe;
        procedure CheckVersion;
        Procedure Log (EventType : TEventType; Msg : String);
        Procedure Log (EventType : TEventType; Fmt : String; Args : Array of const);
        Procedure ResetLog;
        function  RegisterLocaleDomain(Const aTarget : string; const aDomain : string) : boolean;
        function  Translate(Const aDomain : string; Const aString : string) : string;

        property Settings  : TxPLCustomSettings read fSettings;
        property Adresse   : TxPLAddress        read fAdresse;
        property Folders   : TxPLCustomFolders  read fFolders;
        property Version   : string             read fvChecker.fCurrentVersion;
        property OnLogEvent: TStrParamEvent     read fOnLogEvent write fOnLogEvent;
        property VendorFile: TxPLVendorSeedFile read fPluginList;
        property VChecker  : TVersionChecker    read fVChecker;
     end;

var xPLApplication : TxPLApplication;

implementation // =============================================================
uses FPCAdds
     , filechannel
     , sharedlogger
     , consolechannel
     , versiontypes
     ;

// ============================================================================
const K_MSG_LOCALISATION    = 'Localisation file loaded for : %s';
      K_MSG_LOGGING         = 'Logging in %s';
      K_MSG_ALREADY_STARTED = 'Another instance is alreay started';
      K_FULL_TITLE          = '%s version %s by %s (build %s)';
      K_XPATH = '/xpl-plugin[@vendor="%s"]/device[@id="%s-%s"]/attribute::%s';

// ============================================================================
function OnGetAppName : string; inline;                                        // This is used to fake the system when
begin                                                                          // requesting common xPL AppFrameworks shared
   result := 'xPL';                                                            // directory - works in conjunction with
end;                                                                           // OnGetAppFrameworkName

// TxPLAppFramework ===========================================================
constructor TxPLApplication.Create(const aOwner : TComponent);
var s : TVersionStringTable;
    i,j : integer;
    aDevice, aVendor, aVersion : string;
begin
   inherited Create(aOwner);
   include(fComponentStyle,csSubComponent);

   Info := TVersionInfo.Create;
   Info.Load(HINSTANCE);

   for i:=0 to Info.StringFileInfo.Count-1 do begin
       s := Info.StringFileInfo.Items[i];
       for j:=0 to s.Count-1 do
           if s.Keys[j] = 'CompanyName' then aVendor := s.Values[j] else
           if s.Keys[j] = 'InternalName' then aDevice := s.Values[j] else
           if s.Keys[j] = 'FileVersion' then aVersion := s.Values[j];
   end;

   OnGetApplicationName := @OnGetAppName;
   fAdresse := TxPLAddress.Create(aVendor,aDevice);

   {$ifdef fpc}
   if InstanceRunning(AppName) then Log(etError,K_MSG_ALREADY_STARTED);
   {$endif}

   fFolders  := TxPLCustomFolders.Create(fAdresse);

   fVChecker := TVersionChecker.Create(self);
   fvChecker.ServerLocation := K_DEFAULT_ONLINESTORE;
   fvChecker.CurrentVersion := aVersion;
   fvChecker.VersionNode    := Format(K_XPATH,[Adresse.Vendor, Adresse.Vendor, Adresse.Device, 'version']);
   fvChecker.DownloadNode   := Format(K_XPATH,[Adresse.Vendor, Adresse.Vendor, Adresse.Device, 'download']);

   if IsConsole then Logger.Channels.Add(TConsoleChannel.Create);
   Logger.Channels.Add(TFileChannel.Create(LogFileName));
   Log(etInfo,FullTitle);
   Log(etInfo,K_MSG_LOGGING,[LogFileName]);

   fSettings   := TxPLCustomSettings.Create(self);
   fPluginList := TxPLVendorSeedFile.Create(self,Folders);

   fLocaleDomains := TStringList.Create;
   RegisterMe;
end;

destructor TxPLApplication.Destroy;
begin
   fLocaleDomains.Free;
   fFolders.Free;
   fAdresse.Free;
   Info.Free;
   inherited;
end;

function TxPLApplication.LogFileName: string;
begin
   result := fFolders.DeviceDir + AppName + '.log';
end;

procedure TxPLApplication.CheckVersion;
begin
   fvChecker.CheckVersion;
end;

procedure TxPLApplication.RegisterMe;
var aPath, aVersion : string;
begin
   Settings.GetAppDetail(Adresse.Vendor, Adresse.Device,aPath,aVersion);
   if aVersion < Version then Settings.SetAppDetail(Adresse.Vendor,Adresse.Device,Version)
end;

function TxPLApplication.BuildDate: string;                                    // This code piece comes from Lazarus AboutFrm source
var SlashPos1, SlashPos2: integer;                                             // The compiler generated date string is always of the form y/m/d.
    Date: TDateTime;
begin                                                                          // This function gives it a string respresentation according to the
   result := {$I %date%};                                                      // shortdateformat
   SlashPos1 := Pos('/',result);
   SlashPos2 := SlashPos1 + Pos('/', Copy(result, SlashPos1+1, Length(result)-SlashPos1));
   Date := EncodeDate(StrToWord(Copy(result,1,SlashPos1-1)),
   StrToWord(Copy(result,SlashPos1+1,SlashPos2-SlashPos1-1)),
   StrToWord(Copy(result,SlashPos2+1,Length(BuildDate)-SlashPos2)));
   Result := FormatDateTime('yyyy-mm-dd', Date);
end;

function TxPLApplication.AppName : string;
begin
   Result := Format('xPL %s',[Adresse.Device]);
end;

function TxPLApplication.FullTitle : string;
begin
   Result := Format(K_FULL_TITLE,[AppName,fvChecker.CurrentVersion,Adresse.Vendor,BuildDate]);
end;

function TxPLApplication.DeviceInVendorFile: TXMLDeviceType;
begin
   result := VendorFile.GetDevice(Adresse);
end;

Procedure TxPLApplication.Log(EventType : TEventType; Msg : String);
begin
   Case EventType of
        etInfo    : Logger.Send(Msg);                                          // Info are only stored in log file
        etWarning : Logger.SendWarning(Msg);                                   // Warn are stored in log, displayed but doesn't stop the app
        etError   : begin                                                      // Error are stored as error in log, displayed and stop the app
                       Logger.SendError(Msg);
                       Raise Exception.Create(Msg);
                    end;
   end;
   if Assigned(fOnLogEvent) then OnLogEvent(Msg);
end;

Procedure TxPLApplication.Log(EventType : TEventType; Fmt : String; Args : Array of const);
begin
   Log(EventType,Format(Fmt,Args));
end;

procedure TxPLApplication.ResetLog;
var f : textfile;
begin
   System.Assign(f,LogFileName);
   ReWrite(f);
   Writeln(f,'');
   Close(f);
end;


function TxPLApplication.RegisterLocaleDomain(const aTarget: string; const aDomain: string) : boolean;
var i : integer;
    f : string;
begin
   result := true;
   if aTarget <> 'us' then begin;                                                           // Right now, we assume base language is english
      f := GetCurrentDir + '\loc_' + aDomain + '_' + aTarget + '.txt';
      result := FileExists(f);
      if result then begin
         i := fLocaleDomains.AddObject(aDomain,TStringList.Create);
         TStringList(fLocaleDomains.Objects[i]).LoadFromFile(f);
         TStringList(fLocaleDomains.Objects[i]).Sort;
         Log(etInfo,K_MSG_LOCALISATION,[aDomain]);
      end;
   end;
end;

function TxPLApplication.Translate(const aDomain: string; const aString : string): string;
var i : integer;
begin
   i := fLocaleDomains.IndexOf(aDomain);
   if i<>-1 then result := TStringList(fLocaleDomains.Objects[i]).Values[aString]
            else result := aString;
end;



end.

