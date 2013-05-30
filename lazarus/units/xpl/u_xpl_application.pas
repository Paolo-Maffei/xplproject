unit u_xpl_application;

{$i xpl.inc}
{$M+}

interface

uses SysUtils
     , Classes
     , CustApp
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
        function GetApplication: TCustomApplication;
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        destructor  Destroy; override;

        function AppName     : string;
        function FullTitle   : string;
        function SettingsFile : string;

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
        property Application : TCustomApplication read GetApplication;
     end;

var xPLApplication : TxPLApplication;
    InstanceInitStyle : TInstanceInitStyle;

implementation // =============================================================
uses lin_win_compat
     , fpc_delphi_compat
     ;

// ============================================================================
const AppTitle = '%s v%s by %s (build %s)'{$IFDEF DEBUG} + ' - DEBUG' {$ENDIF};

// TxPLAppFramework ===========================================================
constructor TxPLApplication.Create(const aOwner : TComponent);
begin
   inherited Create(aOwner);
   Assert(aOwner is TCustomApplication,'Owner must be TCustomApplication type');

   include(fComponentStyle,csSubComponent);

   fAdresse := TxPLAddress.Create(GetVendor,GetDevice);
   fVersion := GetVersion;
   fFolders  := TxPLFolders.Create(fAdresse);

   Log(etInfo,FullTitle);
   if TCustomApplication(Owner).HasOption('i') then
      fSettings := TxPLCommandLineSettings.Create(self)
   else
      fSettings := TxPLRegistrySettings.Create(self);

   fPluginList := TxPLVendorSeedFile.Create(self,Folders);
   fTimerPool  := TTimerPool.Create(self);
   RegisterMe;
end;

destructor TxPLApplication.Destroy;
begin
   if Assigned(fFolders) then fFolders.Free;
   fAdresse.Free;
   inherited;
end;

function TxPLApplication.GetApplication: TCustomApplication;
begin
   Result := Owner as TCustomApplication;
end;

procedure TxPLApplication.RegisterMe;
var aPath, aVersion, aNiceName : string;
begin
   if Settings is TxPLRegistrySettings then with TxPLRegistrySettings(Settings) do begin
      GetAppDetail(Adresse.Vendor, Adresse.Device,aPath,aVersion, aNiceName);
      if aVersion < Version
         then SetAppDetail(Adresse.Vendor,Adresse.Device,Version)
   end;
end;

function TxPLApplication.AppName : string;
begin
   Result := GetProductName;
end;

function TxPLApplication.FullTitle : string;
begin
   Result := Format(AppTitle,[AppName,fVersion ,Adresse.Vendor,BuildDate]);
end;

function TxPLApplication.SettingsFile: string;
begin
   Result := Folders.DeviceDir + 'settings.xml';
end;

procedure TxPLApplication.Log(const EventType: TEventType; const Msg: String);
begin
   LogInSystem(EventType,Msg);
   if IsConsole then writeln(FormatDateTime('dd/mm hh:mm:ss',now),' ',EventTypeToxPLLevel(EventType),' ',Msg);
   if EventType = etError then Halt;
   if Assigned(fOnLogEvent) then OnLogEvent(Msg);
end;

procedure TxPLApplication.Log(const EventType: TEventType; const Fmt: String; const Args: array of const);
begin
   Log(EventType,Format(Fmt,Args));
end;

initialization // =============================================================
   InstanceInitStyle := iisHostName;                                           // Will use hostname as instance default name

end.