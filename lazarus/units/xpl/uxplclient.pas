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
}

{$mode objfpc}{$H+}

interface

uses  Classes, SysUtils,  TLoggerUnit, ExtCtrls, IdGlobal,  TConfiguratorUnit,
      uXPLSettings, uxPLMsgHeader, uxPLVendorFile, uxPLConst;

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
      private

      public
        constructor Create(const aOwner : TComponent; const aVendor : string; aDevice : string; const aAppVersion : string); overload;
        procedure   LogInfo(aMessage : string);
        procedure   LogError(aMessage : string);
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
uses IdStack, uIPutils, TPatternLayoutUnit, TLevelUnit, TFileAppenderUnit;

constructor TxPLClient.Create(const aOwner : TComponent; const aVendor : string; aDevice : string; const aAppVersion : string);
begin
  inherited Create(aOwner);
   //fAppName    := aAppName;
   fVendor     := aVendor;
   fDevice     := aDevice;
   fAppVersion := aAppVersion;
   fLogList    := TStringList.Create;
   fSetting := TxPLSettings.create(self);

   TConfiguratorUnit.doPropertiesConfiguration(LogFileName);

   fEventLog := TLogger.getInstance;
   fEventLog.SetLevel(TLevelUnit.INFO);
   fEventLog.AddAppender(TFileAppender.Create( LogFileName,
                                               TPatternLayout.Create('%d{dd/mm/yy hh:nn:ss} [%5p] %m%n'),
                                               true));
   fEventLog.info(Format(K_MSG_APP_STARTED,[AppName]));

   fPluginList := TxPLVendorSeedFile.Create(fSetting);
end;

procedure TxPLClient.LogInfo(aMessage: string);
begin
   fLogList.Add(aMessage);
   fEventLog.info(aMessage);
   if Assigned(OnLogUpdate) then OnLogUpdate(fLogList);
end;

procedure TxPLClient.LogError(aMessage: string);
begin
   fLogList.Add(aMessage);
   fEventLog.error(aMessage);
   Raise Exception.Create(aMessage);
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
     inherited Destroy;
end;

function TxPLClient.AppName: string;
begin result := 'xPL ' + Device; end;

end.

