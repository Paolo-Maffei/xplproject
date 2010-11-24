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
 1.00 : Suppressed fDevice, fVendor fields, replaced by fAdresse that was present
        in uxPLListener
        Cutted inheritence from TComponent
 1.01 : Corrected previously inoperant ResetLog
}

{$mode objfpc}{$H+}

interface

uses  Classes,
      SysUtils,
      uXPLSettings,
      uxPLVendorFile,
      sharedlogger,
      multilog,
      uxPLConst,
      uxPLAddress;

type  TxPLLogUpdate = procedure(const aString : string) of object;

      { TxPLClient }

      TxPLClient = class
      protected
        fAppVersion    : string;
        fSettings      : TxPLSettings;
        fPluginList    : TxPLVendorSeedFile;
        fLocaleDomains : TStringList;
      private
        fAdresse       : TxPLAddress;
        procedure RegisterMe;
      public
        OnLogUpdate : TxPLLogUpdate;

        constructor Create(const aVendor : string; aDevice : string; const aAppVersion : string);
        destructor  Destroy; override;
        procedure   Log     (Const Formatting : string; Const Data : array of const; Const LogType : integer = ltInfo); dynamic;
        function    RegisterLocaleDomain(Const aTarget : string; const aDomain : string) : boolean;
        function    Translate(Const aDomain : string; Const aString : string) : string;
        procedure   ResetLog;
        function    LogFileName : string; inline;
        function    AppName     : string; inline;

        property    PluginList : TxPLVendorSeedFile read fPluginList;
        property    Settings   : TxPLSettings       read fSettings;
        property    AppVersion : string             read fAppVersion;
        property    Vendor     : string             read fAdresse.fVendor;
        property    Device     : string             read fAdresse.fDevice;
        property    Adresse    : TxPLAddress        read fAdresse;
      end;

implementation //===============================================================
uses IdStack,
     filechannel,
     StrUtils,
     consolechannel;

// TxPLClient ==================================================================
function TxPLClient.LogFileName: string;
begin result := fSettings.LoggingDirectory + AppName + K_FEXT_LOG; end;

function TxPLClient.AppName: string;
begin result := 'xPL ' + Device; end;

constructor TxPLClient.Create(const aVendor : string; aDevice : string; const aAppVersion : string);
begin
   fAppVersion    := aAppVersion;
   fLocaleDomains := TStringList.Create;
   fAdresse       := TxPLAddress.Create(aVendor,aDevice);
   fSettings      := TxPLSettings.create;

   RegisterMe;

   if IsConsole then Logger.Channels.Add(TConsoleChannel.Create);
   Logger.Channels.Add(TFileChannel.Create(LogFileName));
   Log(K_MSG_LOGGING,[LogFileName]);

   fPluginList := TxPLVendorSeedFile.Create(fSettings);
   if not fPluginList.IsValid then Log(K_MSG_ERROR_VENDOR,[fPluginList.Name], ltWarning);
   if not fSettings.IsValid   then Log(K_MSG_NETWORK_SETTINGS,[], ltWarning);
end;

procedure TxPLClient.Log(const Formatting: string; const Data: array of const; const LogType: integer);
var s : string;
begin
   s := Format(Formatting,Data);
   if Assigned(OnLogUpdate) then OnLogUpdate(s);
   Case LogType of
        ltInfo    : Logger.Send(s);                                             // Info are only stored in log file
        ltWarning : Logger.SendWarning(s);                                      // Warn are stored in log, displayed but doesn't stop the app
        ltError   : begin                                                       // Error are stored as error in log, displayed and stop the app
                       Logger.SendError(s);
                       Raise Exception.Create(s);
                    end;
   end;
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
   Log(K_MSG_LOCALISATION,[aDomain]);
end;

function TxPLClient.Translate(const aDomain: string; const aString : string): string;
var i : integer;
begin
   i := fLocaleDomains.IndexOf(aDomain);
   Result := IfThen( i<>-1, TStringList(fLocaleDomains.Objects[i]).Values[aString], aString);
end;

procedure TxPLClient.ResetLog;
var f : textfile;
begin
   Assign(f,LogFileName);
   ReWrite(f);
   Writeln(f,'');
   Close(f);
end;

destructor TxPLClient.Destroy;
begin
   Log(K_MSG_APP_STOPPED,[AppName]);
   fPluginList.Destroy;
   fSettings.Destroy;
   fLocaleDomains.Destroy;
   fAdresse.Destroy;
end;

procedure TxPLClient.RegisterMe;
var aPath, aVersion : string;
begin
   Settings.GetAppDetail(Vendor, Device,aPath,aVersion);
   if aVersion < AppVersion then Settings.SetAppDetail(Vendor,Device,AppVersion)
end;



end.

