unit uxplsettings;
{==============================================================================
  UnitName      = uxplsettings
  UnitDesc      = xPL Registry Settings management unit
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : added GetSharedConfigDir function
 0.92 : simplification of this unit (ripped string array);
 0.93 : modification on common xPL directory function for windows/linux compatibility
        Added vendor seed file manipulation functions
 0.94 : modified to rip off message directory, wrong good idea
 0.95 : added configuration store directory
 0.96 : usage of uxPLConst
        Added self registering of the app if owner is xPLClient
 0.97 : Application creates a registry key "HKLM\Software\xPL\[vendorid]\[deviceid]" and a
        string value "Version" within that key. Because the software is non-device, you'll have
        to come up with a 'virtual' unique device ID.
 0.98 : Added proxy information recording capability
 0.99 : Modification to Registry reading behaviour to allow lazarus reg.xml compatibility
 }
{$mode objfpc}{$H+}

interface

uses  Registry,Classes;

type

{ TxPLSettings }

TxPLSettings = class(TComponent)
     private
       fHTTPProxPort: string;
       fHTTPProxSrvr: string;
        fRegistry : TRegistry;
        fRootxPLDir,
        fBroadCastAddress,
        fListenOnAddress ,
        fListenToAddresses : string;
        fUseProxy: boolean;

        function  GetListenOnAll     : boolean;
        function  GetListenToAny     : boolean;
        function  GetListenToLocal   : boolean;

        procedure SetBroadCastAddress (const AValue: string);
        procedure SetHTTPProxPort(const AValue: string);
        procedure SetHTTPProxSrvr(const AValue: string);
        procedure SetListenOnAddress  (const AValue: string);
        procedure SetListenToAddresses(const AValue: string);
        procedure SetListenOnAll      (const bValue : boolean);
        procedure SetListenToLocal    (const bValue : boolean);
        procedure SetListenToAny      (const bValue : boolean);

        function  ReadKeyString(const aKeyName : string; const aDefault : string = '') : string;
        procedure SetRootxPLDir(const AValue: string);
        procedure SetUseProxy(const AValue: boolean);
        procedure WriteKeyString(const aKeyName : string; const aValue : string);

        function  ComposeCorrectPath(const aPath : string; const uSub : string) : string;
     public
        constructor create(aOwner : TComponent); override;
        destructor  destroy; override;

        property ListenToAny   : boolean read GetListenToAny   write SetListenToAny;
        property ListenToLocal : boolean read GetListenToLocal write SetListenToLocal;
        property ListenOnAll   : boolean read GetListenOnAll   write SetListenOnAll;
        property UseProxy      : boolean read fUseProxy        write SetUseProxy;
        property BroadCastAddress  : string read fBroadCastAddress  write SetBroadCastAddress;
        property ListenOnAddress   : string read fListenOnAddress   write SetListenOnAddress;
        property ListenToAddresses : string read fListenToAddresses write SetListenToAddresses;
        property HTTPProxSrvr : string read fHTTPProxSrvr write SetHTTPProxSrvr;
        property HTTPProxPort : string read fHTTPProxPort write SetHTTPProxPort;

        property SharedConfigDir   : string read fRootxPLDir write SetRootxPLDir;
        function PluginDirectory  : string;                                             // In the root, directory where plugin are stored
        function LoggingDirectory : string;                                             // In the root, where logs are stored
        function ConfigDirectory  : string;                                             // Directory to store device configuration files
        function IsValid          : Boolean;
        procedure RegisterMe(const aVendor : string; const aDevice : string; const aAppVersion : string);
        function GetxPLAppList : TStringList;
        procedure GetxPLAppDetail(const aVendor : string; const aDevice : string; out aPath : string; out aVersion : string);
     end;

implementation { ======================================================================}
uses SysUtils, StrUtils, uxPLConst, uxPLClient, cFileUtils, Dialogs;

function OnGetAppName : string;                                                         // This is used to fake the system when
begin                                                                                   // requesting common xPL applications shared
  result := 'xPL';                                                                      // directory - works in conjunction with
end;                                                                                    // OnGetApplicationName
{ TxPLSettings ========================================================================}
constructor TxPLSettings.create(aOwner : TComponent);
begin
     inherited Create(aOwner);
     OnGetApplicationName := @OnGetAppName;

     fRegistry := TRegistry.Create;

     fBroadCastAddress := ReadKeyString(K_REGISTRY_BROADCAST);
     fListenOnAddress  := ReadKeyString(K_REGISTRY_LISTENON);
     fListenToAddresses:= ReadKeyString(K_REGISTRY_LISTENTO);
     fRootxPLDir       := ReadKeyString(K_REGISTRY_ROOT_XPL_DIR,GetAppConfigDir(true));
     fUseProxy         := (ReadKeyString(K_REGISTRY_PROXY, K_STR_FALSE) = K_STR_TRUE);
     fHttpProxPort     := ReadKeyString(K_REGISTRY_HTTP_PROX_PORT,'');
     fHttpProxSrvr     := ReadKeyString(K_REGISTRY_HTTP_PROX_SRVR,'');

     if not DirectoryExists(SharedConfigDir ) then CreateDir(SharedConfigDir );         // 1.1.1 Correction
     if not DirectoryExists(PluginDirectory ) then CreateDir(PluginDirectory );         // 1.1.1 Correction
     if not DirectoryExists(LoggingDirectory) then CreateDir(LoggingDirectory);         // 1.1.2 complement
     if not DirectoryExists(ConfigDirectory ) then CreateDir(ConfigDirectory );         // 0.95 complement

     if aOwner is TxPLClient then begin
        RegisterMe(TxPLClient(aOwner).Vendor,TxPLClient(aOwner).Device,TxPLClient(aOwner).AppVersion);
        if not IsValid then ShowMessage(K_MSG_NETWORK_SETTINGS);                        // Can not use xPLClient logging system because not initialized at the moment
     end;
end;

destructor TxPLSettings.destroy;
begin
     fRegistry.CloseKey;
     fRegistry.Destroy;
     inherited destroy;
end;

function TxPLSettings.GetListenToAny : boolean;
begin result := (ListenToAddresses = K_XPL_SETTINGS_NETWORK_ANY)   end;

function TxPLSettings.GetListenToLocal : boolean;
begin result := (ListenToAddresses = K_XPL_SETTINGS_NETWORK_LOCAL) end;

function TxPLSettings.ReadKeyString(const aKeyName : string; const aDefault : string = '') : string;
begin
   fRegistry.RootKey := HKEY_LOCAL_MACHINE;
   fRegistry.OpenKey(K_XPL_ROOT_KEY,True);
   result := fRegistry.ReadString(aKeyName);
   if result = '' then result := aDefault;
end;

procedure TxPLSettings.SetRootxPLDir(const AValue: string);
begin
   fRootxPLDir := ComposeCorrectPath(aValue,'');
   WriteKeyString(K_REGISTRY_ROOT_XPL_DIR,aValue);
end;

procedure TxPLSettings.SetUseProxy(const AValue: boolean);
begin
  if fUseProxy=AValue then exit;
  fUseProxy:=AValue;
  WriteKeyString(K_REGISTRY_PROXY, IfThen(fUseProxy,K_STR_TRUE,K_STR_FALSE));
end;

procedure TxPLSettings.WriteKeyString(const aKeyName : string; const aValue : string);
begin
   fRegistry.RootKey := HKEY_LOCAL_MACHINE;                                             // Redondant but mandatory for reg.xml compatibility
   fRegistry.OpenKey(K_XPL_ROOT_KEY,True);
   fRegistry.WriteString(aKeyName,aValue);
end;

procedure TxPLSettings.SetBroadCastAddress(const AValue: string);
begin
   fBroadCastAddress := aValue;
   WriteKeyString(K_REGISTRY_BROADCAST,aValue);
end;

procedure TxPLSettings.SetHTTPProxPort(const AValue: string);
begin
  if fHTTPProxPort=AValue then exit;
  fHTTPProxPort:=AValue;
  WriteKeyString(K_REGISTRY_HTTP_PROX_PORT,fHTTPProxPort);
end;

procedure TxPLSettings.SetHTTPProxSrvr(const AValue: string);
begin
  if fHTTPProxSrvr=AValue then exit;
  fHTTPProxSrvr:=AValue;
  WriteKeyString(K_REGISTRY_HTTP_PROX_SRVR,fHTTPProxSrvr);
end;

procedure TxPLSettings.SetListenOnAddress(const AValue: string);
begin
   fListenOnAddress := aValue;
   WriteKeyString(K_REGISTRY_LISTENON,aValue);
end;

procedure TxPLSettings.SetListenToAddresses(const AValue: string);
begin
   fListenToAddresses := aValue;
   WriteKeyString(K_REGISTRY_LISTENTO,aValue);
end;

function TxPLSettings.GetListenOnAll : boolean;
begin
   result := ((ListenOnAddress = K_XPL_SETTINGS_NETWORK_ANY)
           or (ListenOnAddress = K_XPL_SETTINGS_NETWORK_LOCAL));
end;

procedure TxPLSettings.SetListenOnAll(const bValue : boolean);
begin ListenOnAddress := IfThen(bValue,K_XPL_SETTINGS_NETWORK_LOCAL); end;

procedure TxPLSettings.SetListenToLocal(const bValue : boolean);
begin ListenToAddresses := IfThen(bValue,K_XPL_SETTINGS_NETWORK_LOCAL); end;

procedure TxPLSettings.SetListenToAny(const bValue : boolean);
begin ListenToAddresses := IfThen(bValue,K_XPL_SETTINGS_NETWORK_ANY) ; end;

function TxPLSettings.ComposeCorrectPath(const aPath: string; const uSub: string ): string;
begin
     result := aPath;
     PathEnsureSuffix(result);
     result += uSub;
     PathEnsureSuffix(result);
end;

function TxPLSettings.PluginDirectory: string;
begin result := ComposeCorrectPath(SharedConfigDir,K_XPL_SETTINGS_SUBDIR_PLUG); end;

function TxPLSettings.LoggingDirectory: string;
begin result := ComposeCorrectPath(SharedConfigDir,K_XPL_SETTINGS_SUBDIR_LOGS); end;

function TxPLSettings.ConfigDirectory: string;
begin result := ComposeCorrectPath(SharedConfigDir,K_XPL_SETTINGS_SUBDIR_CONF); end;

function TxPLSettings.IsValid: Boolean;                                                 // Just verifies that all basic values
begin                                                                                   // have been initialized
     result := (length(BroadCastAddress) *
                length(ListenOnAddress ) *
                length(ListenToAddresses)) <>0;
end;

procedure TxPLSettings.RegisterMe(const aVendor : string; const aDevice : string; const aAppVersion : string);
var aPath, aVersion : string;
begin
   GetxPLAppDetail(aVendor, aDevice,aPath,aVersion);
   if aVersion < aAppVersion then begin                                                 // Empty or older version information
      fRegistry.RootKey := HKEY_LOCAL_MACHINE;                                          // Redondant but mandatory for reg.xml compatibility
      fRegistry.OpenKey(Format(K_XPL_FMT_APP_KEY,[aVendor,aDevice]),True);
      fRegistry.WriteString(K_XPL_REG_VERSION_KEY,aAppVersion);
      fRegistry.WriteString(K_XPL_REG_PATH_KEY,ParamStr(0))
   end;
end;

function TxPLSettings.GetxPLAppList : TStringList;
var aVendorListe, aAppListe : TStringList;
    i,j : integer;
begin
   aVendorListe := TStringList.Create;
   aAppListe    := TStringList.Create;
   result := TStringList.Create;
   fRegistry.RootKey := HKEY_LOCAL_MACHINE;                                             // Redondant but mandatory for reg.xml compatibility
   fRegistry.OpenKey(K_XPL_ROOT_KEY ,True);
   fRegistry.GetKeyNames(aVendorListe);
   for i:= 0 to aVendorListe.Count-1 do begin
       fRegistry.OpenKey(K_XPL_ROOT_KEY,False);
       fRegistry.OpenKey(aVendorListe[i],False);
       fRegistry.GetKeyNames(aAppListe);
       for j:=0 to aAppListe.Count -1 do aAppListe[j] := aVendorListe[i] + '-' + aAppListe[j];
       Result.AddStrings(aAppListe);
   end;
   aVendorListe.Destroy;
   aAppListe.Destroy;
end;

procedure TxPLSettings.GetxPLAppDetail(const aVendor : string; const aDevice : string; out   aPath: string; out aVersion: string);
begin
   fRegistry.RootKey := HKEY_LOCAL_MACHINE;                                             // Redondant but mandatory for reg.xml compatibility
   fRegistry.OpenKey (K_XPL_ROOT_KEY, False);
   fRegistry.OpenKey (aVendor, True);                                                   // At the time, you can't read this
   fRegistry.OpenKey (aDevice, False);
   aVersion := fRegistry.ReadString(K_XPL_REG_VERSION_KEY);                             // if you don't have admin rights under Windows
   aPath    := fRegistry.ReadString(K_XPL_REG_PATH_KEY);
end;

end.

