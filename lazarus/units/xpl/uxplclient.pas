unit uxPLClient;
{===============================================================================
  UnitName      = uxPLClient
  UnitDesc      = xPL Listener object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ===============================================================================
 0.91 : Seperation of basic xPL Client (listener and sender) from pure listener
 0.92 : Suppression of self owned message to avoid conflicts between threads
 0.93 : String constant moved to uxPLConst
        Registering of the app moved to xPLSetting
        Added LogList object and procedures
 0.94 : AppName disappeared, Vendor and Device moved from Listener to here
 0.95 : Little change in LogError/LogInfo to integrate standard formatting
 0.96 : Added localisation capabilities
 0.97 : Added Logwarn
 0.98 : Modified to use WEBSERVER clause for console application, logging to
        console instead of list
 Rev 256 : Rename Setting to Settings
 0.99 : Removed usage of TLog4Delphi that used to lock the log file, creating
        usage constaint (not having multi apps in the same directory). Replaced
        by Multilog
        This also removed the need to have a OnLogUpdate notification message
}

{$mode objfpc}{$H+}

interface

uses  Classes, SysUtils,
      uXPLSettings, uxPLVendorFile, sharedlogger, uxPLConst;

type  TxPLClient = class(TComponent)
      protected
        fAppVersion    : string;
        fVendor        : string;
        fDevice        : string;
        fSettings      : TxPLSettings;
        fPluginList    : TxPLVendorSeedFile;
        fLocaleDomains : TStringList;
      private
        procedure RegisterMe(const aVendor : string; const aDevice : string; const aAppVersion : string);
      public
        constructor Create(const aOwner : TComponent; const aVendor : string; aDevice : string; const aAppVersion : string); overload;
        destructor  Destroy; override;
        procedure   LogInfo (Const Formatting : string; Const Data : array of const );            // Info are only stored in log file
        procedure   LogError(Const Formatting : string; Const Data : array of const );            // Error are stored as error in log, displayed and stop the app
        procedure   LogWarn (Const Formatting : string; Const Data : array of const );            // Warn are stored in log, displayed but doesn't stop the app
        function    RegisterLocaleDomain(Const aTarget : string; const aDomain : string) : boolean;
        function    Translate(Const aDomain : string; Const aString : string) : string;
        function    LogFileName : string; inline;
        function    AppName     : string; inline;

        property    PluginList : TxPLVendorSeedFile  read fPluginList;
        property    Settings   : TxPLSettings        read fSettings;
        property    AppVersion : string              read fAppVersion;
        property    Vendor     : string              read fVendor;
        property    Device     : string              read fDevice;
      end;

implementation //===============================================================
uses IdStack,
     uIPutils,
     filechannel,
     consolechannel;

// TxPLClient ==================================================================
function TxPLClient.LogFileName: string;
begin result := fSettings.LoggingDirectory + AppName + K_FEXT_LOG; end;

function TxPLClient.AppName: string;
begin result := 'xPL ' + Device; end;

constructor TxPLClient.Create(const aOwner : TComponent; const aVendor : string; aDevice : string; const aAppVersion : string);
begin
   inherited Create(aOwner);
   fVendor        := aVendor;
   fDevice        := aDevice;
   fAppVersion    := aAppVersion;
   fSettings      := TxPLSettings.create;
   fLocaleDomains := TStringList.Create;

   RegisterMe(Vendor,Device,AppVersion);

   if IsConsole then Logger.Channels.Add(TConsoleChannel.Create);
   Logger.Channels.Add(TFileChannel.Create(LogFileName));
   LogInfo('Logging to file : %s',[LogFileName]);

   fPluginList := TxPLVendorSeedFile.Create(fSettings);
   if not fPluginList.IsValid then LogWarn(K_MSG_ERROR_VENDOR,[fPluginList.Name]);
   if not fSettings.IsValid   then LogWarn(K_MSG_NETWORK_SETTINGS,[]);
end;

procedure TxPLClient.LogInfo(Const Formatting  : string; Const Data  : array of const);
begin
   Logger.Send(Format(Formatting,Data));
end;

procedure TxPLClient.LogWarn(Const Formatting  : string; Const Data  : array of const);
var s : string;
begin
   s := Format(Formatting,Data);
   Logger.SendWarning(s);
   Raise Exception.Create(s);
end;

procedure TxPLClient.LogError(Const Formatting  : string; Const Data  : array of const);
var s : string;
begin
   s := Format(Formatting,Data);
   Logger.SendError(s);
   Raise Exception.Create(s);
end;

function TxPLClient.RegisterLocaleDomain(const aTarget: string; const aDomain: string) : boolean;
var i : integer;
    f : string;
begin
   result := true;
   if aTarget = 'us' then exit;                                                           // Right now, we assume base language is english

   f := GetCurrentDir + '\loc_' + aDomain + '_' + aTarget + K_FEXT_TXT;
   result := FileExists(f);
   if not result then exit;

   i := fLocaleDomains.AddObject(aDomain,TStringList.Create);
   TStringList(fLocaleDomains.Objects[i]).LoadFromFile(f);
   TStringList(fLocaleDomains.Objects[i]).Sort;
   LogInfo('Localisation file loaded for : %s',[aDomain]);
end;

function TxPLClient.Translate(const aDomain: string; const aString : string): string;
var i : integer;
begin
   result := '';
   i := fLocaleDomains.IndexOf(aDomain);
   if i<>-1 then result := TStringList(fLocaleDomains.Objects[i]).Values[aString];
   if length(result)=0 then result := aString;
end;

destructor TxPLClient.Destroy;
begin
   LogInfo(K_MSG_APP_STOPPED,[AppName]);
   fPluginList.Destroy;
   fSettings.Destroy;
   fLocaleDomains.Destroy;
   inherited Destroy;
end;

procedure TxPLClient.RegisterMe(const aVendor : string; const aDevice : string; const aAppVersion : string);
var aPath, aVersion : string;
begin
   fSettings.GetAppDetail(Vendor, Device,aPath,aVersion);
   if aVersion < AppVersion then fSettings.SetAppDetail(Vendor,Device,AppVersion)
end;



end.

