unit u_xpl_application;

{$ifdef fpc}
   {$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses SysUtils
     , Classes
     {$ifdef fpc}
     , UniqueInstanceRaw
     {$endif}
     //, VersionChecker
     , u_xpl_address
     , u_xpl_folders
     , u_xpl_settings
     , u_xpl_common
     , u_xpl_vendor_file
     , fpc_delphi_compat
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
        fVersion    : string;
        //fVChecker   : TVersionChecker;
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        destructor  Destroy; override;

        function AppName     : string;
        function FullTitle   : string;
        function LogFileName : TFilename;
        //function DeviceInVendorFile : TXMLDeviceType;

        procedure RegisterMe;
        //procedure CheckVersion;
        Procedure Log (EventType : TEventType; Msg : String); overload;
        Procedure Log (EventType : TEventType; Fmt : String; Args : Array of const); overload;
        Procedure ResetLog;
        function  RegisterLocaleDomain(Const aTarget : string; const aDomain : string) : boolean;
        function  Translate(Const aDomain : string; Const aString : string) : string;

        property Settings  : TxPLCustomSettings read fSettings;
        property Adresse   : TxPLAddress        read fAdresse;
        property Folders   : TxPLCustomFolders  read fFolders;
        property Version   : string             read fVersion;
        property OnLogEvent: TStrParamEvent     read fOnLogEvent write fOnLogEvent;
        property VendorFile: TxPLVendorSeedFile read fPluginList;
        //property VChecker  : TVersionChecker    read fVChecker;
     end;

var xPLApplication : TxPLApplication;

implementation // =============================================================
uses filechannel
     , sharedlogger
     , consolechannel
     ;

// ============================================================================
const
     K_MSG_LOCALISATION    = 'Localisation file loaded for : %s';
     K_MSG_LOGGING         = 'Logging in %s';
     K_MSG_ALREADY_STARTED = 'Another instance is alreay started';
     K_FULL_TITLE          = '%s version %s by %s (build %s)';
     //K_XPATH               = '/xpl-plugin[@vendor="%s"]/device[@id="%s-%s"]/attribute::%s';

// TxPLAppFramework ===========================================================
constructor TxPLApplication.Create(const aOwner : TComponent);
begin
   inherited Create(aOwner);
   include(fComponentStyle,csSubComponent);

   fAdresse := TxPLAddress.Create(GetVendor,GetDevice);
   fVersion        := GetVersion;

   if not AllowMultiInstance then begin
   {$ifdef fpc}
      {$ifdef mswindows}
         if InstanceRunning(GetProductName) then Log(etError,K_MSG_ALREADY_STARTED);
      {$else}
         { TODO : Activate Unique Instance under linux }
      {$endif}
   {$endif}
   end;

   fFolders  := TxPLCustomFolders.Create(fAdresse);

   {fVChecker := TVersionChecker.Create(self);
   fvChecker.ServerLocation := K_DEFAULT_ONLINESTORE;
   fvChecker.CurrentVersion := aVersion;
   fvChecker.VersionNode    := Format(K_XPATH,[Adresse.Vendor, Adresse.Vendor, Adresse.Device, 'version']);
   fvChecker.DownloadNode   := Format(K_XPATH,[Adresse.Vendor, Adresse.Vendor, Adresse.Device, 'download']);}

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
   if Assigned(fLocaleDomains) then fLocaleDomains.Free;
   if Assigned(fFolders)       then fFolders.Free;
   fAdresse.Free;
   inherited;
end;

function TxPLApplication.LogFileName: TFileName;
begin
   result := Format('%s%s.log',[fFolders.DeviceDir, Adresse.device]);
end;

procedure TxPLApplication.RegisterMe;
var aPath, aVersion, aNiceName : string;
begin
   Settings.GetAppDetail(Adresse.Vendor, Adresse.Device,aPath,aVersion, aNiceName);
   if aVersion < Version then Settings.SetAppDetail(Adresse.Vendor,Adresse.Device,Version)
end;

function TxPLApplication.AppName : string;
begin
   Result := GetProductName;
end;

function TxPLApplication.FullTitle : string;
begin
   Result := Format(K_FULL_TITLE,[AppName,fVersion,Adresse.Vendor,BuildDate]);
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