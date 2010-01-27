unit uxPLClient;
{==============================================================================
  UnitName      = uxPLClient
  UnitDesc      = xPL Listener object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Seperation of basic xPL Client (listener and sender) from pure listener
 0.92 : Suppression of self owned message to avoid conflicts between threads
 0.93 : String constant moved to uxPLConst
}

{$mode objfpc}{$H+}

interface

uses  Classes, SysUtils,  TLoggerUnit, ExtCtrls, IdGlobal,  TConfiguratorUnit,
      uXPLSettings, uxPLPluginFile, uxPLMsgHeader;

type  TxPLClient = class(TComponent)
      protected
        fAppName    : string;
        fAppVersion : string;
        fEventLog   : TLogger;
        fSetting    : TxPLSettings;
        fPluginList : TxPLPluginList;
      public
        constructor Create(const aOwner : TComponent; const aAppName : string; const aAppVersion : string);
        procedure   LogInfo(aMessage : string);
        procedure   LogError(aMessage : string);
        function    LogFileName : string;
        destructor  Destroy; override;

        property    PluginList : TxPLPluginList read fPluginList;
        property    Setting    : TxPLSettings   read fSetting;
        property    AppName    : string         read fAppName;
        property    AppVersion : string         read fAppVersion;
      end;

implementation //===============================================================
uses IdStack,uxplcfgitem, cRandom, uIPutils, TPatternLayoutUnit, uxPLConst,
     TLevelUnit, TFileAppenderUnit;


constructor TxPLClient.Create(const aOwner : TComponent; const aAppName : string; const aAppVersion : string);
begin
  inherited Create(aOwner);

   TConfiguratorUnit.doPropertiesConfiguration(LogFileName);
   fAppName    := aAppName;
   fAppVersion := aAppVersion;

   fSetting := TxPLSettings.create;
      fSetting.RegisterMe(fAppName,fAppVersion);

   fEventLog := TLogger.getInstance;
   fEventLog.SetLevel(TLevelUnit.INFO);
   fEventLog.AddAppender(TFileAppender.Create( LogFileName,
                                               TPatternLayout.Create('%d{dd/mm/yy hh:nn:ss} [%5p] %m%n'),
                                               true));
   fEventLog.info(Format(K_MSG_APP_STARTED,[fAppName]));

   fPluginList := TxPLPluginList.Create;
end;

procedure TxPLClient.LogInfo(aMessage: string);
begin fEventLog.info(aMessage);  end;

procedure TxPLClient.LogError(aMessage: string);
begin fEventLog.error(aMessage); end;

function TxPLClient.LogFileName: string;
begin result := fSetting.LoggingDirectory + fAppName + K_FEXT_LOG; end;

destructor TxPLClient.Destroy;
begin
     fPluginList.Destroy;
     fEventLog.info(Format(K_MSG_APP_STOPPED,[fAppName]));
     TLogger.freeInstances;
     fSetting.Destroy;
     inherited Destroy;
end;

end.

