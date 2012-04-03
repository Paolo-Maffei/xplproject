unit u_xpl_application;

{$ifdef fpc}
   {$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses SysUtils
     , Classes
     , u_xpl_address
     , u_xpl_folders
     , u_xpl_settings
     , u_xpl_common
     , u_xpl_vendor_file
     , u_timer_pool
     ;

type // TxPLApplication =======================================================
     TxPLApplication = class(TComponent)
     private
        fSettings   : TxPLSettings;
        fFolders    : TxPLFolders;
        fAdresse    : TxPLAddress;
        fOnLogEvent : TStrParamEvent;
        fPluginList : TxPLVendorSeedFile;
        fVersion    : string;
        fTimerPool  : TTimerPool;
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        destructor  Destroy; override;

        function AppName     : string;
        function FullTitle   : string;

        procedure RegisterMe;
        Procedure Log (const EventType : TEventType; const Msg : String); overload; dynamic;
        Procedure Log (const EventType : TEventType; const Fmt : String; const Args : Array of const); overload;

        property Settings  : TxPLSettings       read fSettings;
        property Adresse   : TxPLAddress        read fAdresse;
        property Folders   : TxPLFolders        read fFolders;
        property Version   : string             read fVersion;
        property OnLogEvent: TStrParamEvent     read fOnLogEvent write fOnLogEvent;
        property VendorFile: TxPLVendorSeedFile read fPluginList;
        property TimerPool : TTimerPool read fTimerPool;
     end;

var xPLApplication : TxPLApplication;
    InstanceInitStyle : TInstanceInitStyle;

implementation // =============================================================
uses IdStack
     , lin_win_compat
     , fpc_delphi_compat
     ;

// ============================================================================
const K_FULL_TITLE          = '%s v%s by %s (build %s)';

// TxPLAppFramework ===========================================================
constructor TxPLApplication.Create(const aOwner : TComponent);
begin
   inherited Create(aOwner);
   include(fComponentStyle,csSubComponent);

   fAdresse := TxPLAddress.Create(GetVendor,GetDevice);
   fVersion := GetVersion;

   fFolders  := TxPLFolders.Create(fAdresse);

   Log(etInfo,FullTitle);

   fSettings   := TxPLSettings.Create(self);
   fPluginList := TxPLVendorSeedFile.Create(self,Folders);
   fTimerPool  := TTimerPool.Create(self);
   RegisterMe;
end;

destructor TxPLApplication.Destroy;
begin
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

Procedure TxPLApplication.Log(const EventType : TEventType; const Msg : String);
begin
   SystemLog(EventType,Msg);
   if IsConsole then writeln(FormatDateTime('dd/mm hh:mm:ss',now),' ',EventTypeToxPLLevel(EventType),' ',Msg);
   if EventType = etError then Raise Exception.Create(Msg);
   if Assigned(fOnLogEvent) then OnLogEvent(Msg);
end;

Procedure TxPLApplication.Log(const EventType : TEventType; const Fmt : String; const Args : Array of const);
begin
   Log(EventType,Format(Fmt,Args));
end;

initialization // =============================================================
   InstanceInitStyle := iisHostName;                                           // Will use hostname as instance default name


end.
