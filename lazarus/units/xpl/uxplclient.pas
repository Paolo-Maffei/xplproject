unit uxPLClient;
{==============================================================================
  UnitName      = uxPLClient
  UnitDesc      = xPL Listener object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Seperation of basic xPL Client (listener and sender) from pure listener
 0.92 : Suppression of self owned message to avoid conflicts between threads
 0.93 : String constant moved to uxPLConst
        Registering of the app moved to xPLSetting
        Added LogList object and procedures
 0.94 : AppName disappeared, Vendor and Device moved from Listener to here
 0.95 : Little change in LogError/LogInfo to integrate standard formatting
 0.96 : Added localisation capabilities
 0.97 : Added Logwarn
}

{$mode objfpc}{$H+}

interface

uses  Classes, SysUtils,  TLoggerUnit, ExtCtrls, IdGlobal,  TConfiguratorUnit,
      uXPLSettings, uxPLVendorFile, uxPLConst;

type  TxPLClientLogUpdate = procedure(const aLogList : TStringList) of object;

      { TxPLClient }

      TxPLClient = class(TComponent)
      protected
        fAppVersion : string;
        fVendor     : string;
        fDevice     : string;
        fEventLog   : TLogger;
        fLogList    : TStringList;
        fSetting    : TxPLSettings;
        fPluginList : TxPLVendorSeedFile;
        fLocaleDomains : TStringList;
      private
        function RecordLog(Const Formatting  : string; Const Data  : array of const ) : string;
      public
        constructor Create(const aOwner : TComponent; const aVendor : string; aDevice : string; const aAppVersion : string); overload;
        procedure   LogInfo(Const Formatting  : string; Const Data  : array of const );             // Info are only stored in log file
        procedure   LogError(Const Formatting  : string; Const Data  : array of const );            // Error are stored as error in log, displayed and stop the app
        procedure   LogWarn(Const Formatting  : string; Const Data  : array of const );             // Warn are stored in log, displayed but doesn't stop the app
        function    RegisterLocaleDomain(Const aTarget : string; const aDomain : string) : boolean;
        function    Translate(Const aDomain : string; Const aString : string) : string;
        function    LogFileName : string;
        destructor  Destroy; override;

        property    PluginList : TxPLVendorSeedFile  read fPluginList;
        property    Setting    : TxPLSettings        read fSetting;
        property    AppVersion : string              read fAppVersion;
        property    LogList    : TStringList         read fLogList;
        property    Vendor     : string              read fVendor;
        property    Device     : string              read fDevice;

        function AppName : string;

        OnLogUpdate: TxPLClientLogUpdate;
      end;

implementation //===============================================================
uses IdStack, uIPutils, TPatternLayoutUnit, TLevelUnit, TFileAppenderUnit, Dialogs;

constructor TxPLClient.Create(const aOwner : TComponent; const aVendor : string; aDevice : string; const aAppVersion : string);
begin
   inherited Create(aOwner);
   fVendor     := aVendor;
   fDevice     := aDevice;
   fAppVersion := aAppVersion;
   fLogList    := TStringList.Create;
   fSetting    := TxPLSettings.create(self);
   fLocaleDomains := TStringList.Create;
   TConfiguratorUnit.doPropertiesConfiguration(LogFileName);

   fEventLog := TLogger.getInstance;
   fEventLog.SetLevel(TLevelUnit.INFO);
   fEventLog.AddAppender(TFileAppender.Create( LogFileName,
                                               TPatternLayout.Create('%d{dd/mm/yy hh:nn:ss} [%5p] %m%n'),
                                               true));
   fEventLog.info(Format(K_MSG_APP_STARTED,[AppName]));

   fPluginList := TxPLVendorSeedFile.Create(fSetting);
   if not fPluginList.Status then LogWarn('Error while reading vendor xml file (%s)',[fPluginList.Name]);
end;

function TxPLClient.RecordLog(const Formatting: string; const Data: array of const): string;
begin
   Result := Format(Formatting,Data);
   fLogList.Add(Result);
   if Assigned(OnLogUpdate) then OnLogUpdate(fLogList);
end;


procedure TxPLClient.LogInfo(Const Formatting  : string; Const Data  : array of const);
begin
   fEventLog.info(RecordLog(Formatting,Data));
end;

procedure TxPLClient.LogWarn(Const Formatting  : string; Const Data  : array of const);
var s : string;
begin
   s := RecordLog(Formatting,Data);
   fEventLog.error(s);
   ShowMessage(s);
end;

procedure TxPLClient.LogError(Const Formatting  : string; Const Data  : array of const);
var s : string;
begin
   s := RecordLog(Formatting,Data);
   fEventLog.error(s);
   Raise Exception.Create(s);
end;

function TxPLClient.RegisterLocaleDomain(const aTarget: string; const aDomain: string) : boolean;
var i : integer;
    f : string;
begin
   result := true;
   if aTarget = 'us' then exit;                                                           // Right now, we assume base language is english

   f := GetCurrentDir + '\loc_' + aDomain + '_' + aTarget + '.txt';
   result := FileExists(f);
   if not result then exit;

   i := fLocaleDomains.AddObject(aDomain,TStringList.Create);
   TStringList(fLocaleDomains.Objects[i]).LoadFromFile(f);
   TStringList(fLocaleDomains.Objects[i]).Sort;
   LogInfo('%s localisation file loaded',[aDomain]);
end;

function TxPLClient.Translate(const aDomain: string; const aString : string): string;
var i : integer;
begin
   result := '';
   i := fLocaleDomains.IndexOf(aDomain);
   if i<>-1 then result := TStringList(fLocaleDomains.Objects[i]).Values[aString];
   if length(result)=0 then result := aString;
end;

function TxPLClient.LogFileName: string;
begin result := fSetting.LoggingDirectory + AppName + K_FEXT_LOG; end;

destructor TxPLClient.Destroy;
begin
     fPluginList.Destroy;
     fEventLog.info(Format(K_MSG_APP_STOPPED,[AppName]));
     TLogger.freeInstances;
     fSetting.Destroy;
     fLogList.Destroy;
     fLocaleDomains.Destroy;
     inherited Destroy;
end;

function TxPLClient.AppName: string;                                                      // Todo : capitalize first char of Device
begin result := 'xPL ' + Device; end;

end.

