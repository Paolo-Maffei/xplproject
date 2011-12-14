unit u_xpl_application;

{$ifdef fpc}
   {$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses SysUtils
     , Classes
     {$ifdef unix}
     , IdSysLog
     , IdSysLogMessage
     {$else}
     , EventLog
     {$endif}
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
        {$ifdef unix}
           fIdSysLog: TIdSysLog;
           fIdSysLogMessage : TIdSysLogMessage;
        {$else}
           fEventLog : TEventLog;
        {$endif}

     public
        constructor Create(const aOwner : TComponent); reintroduce;
        destructor  Destroy; override;

        function AppName     : string;
        function FullTitle   : string;

        procedure RegisterMe;
        Procedure Log (EventType : TEventType; Msg : String); overload;
        Procedure Log (EventType : TEventType; Fmt : String; Args : Array of const); overload;

        function  RegisterLocaleDomain(Const aTarget : string; const aDomain : string) : boolean;
        function  Translate(Const aDomain : string; Const aString : string) : string;

        property Settings  : TxPLCustomSettings read fSettings;
        property Adresse   : TxPLAddress        read fAdresse;
        property Folders   : TxPLCustomFolders  read fFolders;
        property Version   : string             read fVersion;
        property OnLogEvent: TStrParamEvent     read fOnLogEvent write fOnLogEvent;
        property VendorFile: TxPLVendorSeedFile read fPluginList;
     end;

var xPLApplication : TxPLApplication;

implementation // =============================================================
uses IdStack
     ;

// ============================================================================
const
     K_MSG_LOCALISATION    = 'Localisation file loaded for : %s';
     K_FULL_TITLE          = '%s v%s by %s (build %s)';

// TxPLAppFramework ===========================================================
constructor TxPLApplication.Create(const aOwner : TComponent);
begin
   inherited Create(aOwner);
   include(fComponentStyle,csSubComponent);

   fAdresse := TxPLAddress.Create(GetVendor,GetDevice);
   fVersion := GetVersion;

   {$ifdef unix}
      fIdSysLog := nil;
      fIdSysLog := TIdSysLog.Create(self);
      fIdSysLog.Port := 514;
      fIdSysLog.Host := '127.0.0.1';
      fIdSysLog.Active := True;
      fIdSysLogMessage := TIdSysLogMessage.Create(self);
   {$else}
      fEventLog := TEventLog.Create(self);
      fEventLog.DefaultEventType:=etInfo;
      fEventLog.LogType:=ltSystem;
      fEventLog.Identification := AppName;
      fEventLog.Active:=true;
      fEventlog.RegisterMessageFile('');
   {$endif}


   fFolders  := TxPLCustomFolders.Create(fAdresse);

   Log(etInfo,FullTitle);

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
   {$ifdef unix}
      fIdSysLogMessage.Msg.Text := GetDevice + ':' + Msg;
      Case EventType of
           etInfo    : fIdSysLogMessage.Severity := slInformational;
           etWarning : fIdSysLogMessage.Severity := slWarning;
           etError   : fIdSysLogMessage.Severity := slError;
      end;
      fIdSysLog.SendLogMessage(fIdSysLogMessage);
   {$else}
   //Case EventType of
   //     etInfo    : Logger.Send(Msg);                                          // Info are only stored in log file
   //     etWarning : Logger.SendWarning(Msg);                                   // Warn are stored in log, displayed but doesn't stop the app
   //     etError   : begin                                                      // Error are stored as error in log, displayed and stop the app
   //                    Logger.SendError(Msg);
   //                    Raise Exception.Create(Msg);
   //                 end;
   //end;
      fEventLog.Log(EventType,Msg);
   {$endif}
   if IsConsole then writeln(FormatDateTime('dd/mm hh:mm:ss',now),' ',EventTypeToxPLLevel(EventType),' ',Msg);
   if EventType = etError then Raise Exception.Create(Msg);
   if Assigned(fOnLogEvent) then OnLogEvent(Msg);
end;

Procedure TxPLApplication.Log(EventType : TEventType; Fmt : String; Args : Array of const);
begin
   Log(EventType,Format(Fmt,Args));
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

{$ifdef mswindows}
{$R C:/pp/packages/fcl-base/src/win/fclel.res}                                 // Load resource strings for windows event log
{$endif}

initialization // =============================================================
   InstanceInitStyle  := iisHostName;
   LocalAddresses     := TStringList.Create;
   {$ifdef fpc}
      OnGetVendorName      := @GetVendorNameEvent;                             // These functions are not known of Delphi and
      OnGetApplicationName := @GetApplicationEvent;                            // are present here for linux behaviour consistency
      VersionInfo          := TxPLVersionInfo.Create;
   {$else}
      VersionInfo          := TxPLVersionInfo.Create(ParamStr(0));
   {$endif}

   TIdStack.IncUsage;
   LocalAddresses.Assign(GStack.LocalAddresses);

finalization // ===============================================================
   LocalAddresses.Free;
   VersionInfo.Free;

end.