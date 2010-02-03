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
}

{$mode objfpc}{$H+}

interface

uses  Classes, SysUtils,  TLoggerUnit, ExtCtrls, IdGlobal,  TConfiguratorUnit,
      uXPLSettings, uxPLPluginFile, uxPLMsgHeader;

type  TxPLClientLogUpdate = procedure(const aLogList : TStringList) of object;

      TxPLClient = class(TComponent)
      protected
        fAppName    : string;
        fAppVersion : string;
        fEventLog   : TLogger;
        fLogList    : TStringList;
        fSetting    : TxPLSettings;
        fPluginList : TxPLPluginList;
      private

      public
        constructor Create(const aOwner : TComponent; const aAppName : string; const aAppVersion : string);
        procedure   LogInfo(aMessage : string);
        procedure   LogError(aMessage : string);
        function    LogFileName : string;
        destructor  Destroy; override;

        property    PluginList : TxPLPluginList      read fPluginList;
        property    Setting    : TxPLSettings        read fSetting;
        property    AppName    : string              read fAppName;
        property    AppVersion : string              read fAppVersion;

        OnLogUpdate: TxPLClientLogUpdate;
      end;

implementation //===============================================================
uses IdStack,uxplcfgitem, uIPutils, TPatternLayoutUnit, uxPLConst, TLevelUnit, TFileAppenderUnit;

constructor TxPLClient.Create(const aOwner : TComponent; const aAppName : string; const aAppVersion : string);
begin
  inherited Create(aOwner);
   fAppName    := aAppName;
   fAppVersion := aAppVersion;
   fLogList    := TStringList.Create;
   fSetting := TxPLSettings.create(self);

   TConfiguratorUnit.doPropertiesConfiguration(LogFileName);

   fEventLog := TLogger.getInstance;
   fEventLog.SetLevel(TLevelUnit.INFO);
   fEventLog.AddAppender(TFileAppender.Create( LogFileName,
                                               TPatternLayout.Create('%d{dd/mm/yy hh:nn:ss} [%5p] %m%n'),
                                               true));
   fEventLog.info(Format(K_MSG_APP_STARTED,[fAppName]));

   fPluginList := TxPLPluginList.Create(self);
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
begin result := fSetting.LoggingDirectory + fAppName + K_FEXT_LOG; end;

destructor TxPLClient.Destroy;
begin
     fPluginList.Destroy;
     fEventLog.info(Format(K_MSG_APP_STOPPED,[fAppName]));
     TLogger.freeInstances;
     fSetting.Destroy;
     fLogList.Destroy;
     inherited Destroy;
end;

end.

