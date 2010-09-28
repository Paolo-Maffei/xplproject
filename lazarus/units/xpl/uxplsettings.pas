unit uxplsettings;
{==============================================================================
  UnitDesc      = xPL Registry and Global Settings management unit
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
 Rev 256 : Ripped RegisterMe function to xPLClient
           Cut inheritence from TComponent
           Small simplifications of the code
           Transfer of strictly confined string constant from uxPLConst here
 }
{$mode objfpc}{$H+}

interface

uses  Registry,Classes;

type  TxPLSettings = class
      private
        fRegistry : TRegistry;

        fHTTPProxPort, fHTTPProxSrvr,
        fRootxPLDir,   fBroadCastAddress,
        fListenOnAddress , fListenToAddresses : string;

        fUseProxy: boolean;

        function  GetListenOnAll     : boolean;
        function  GetListenToAny     : boolean;
        function  GetListenToLocal   : boolean;

        procedure SetBroadCastAddress (const AValue: string);
        procedure SetHTTPProxPort     (const AValue: string);
        procedure SetHTTPProxSrvr     (const AValue: string);
        procedure SetListenOnAddress  (const AValue: string);
        procedure SetListenToAddresses(const AValue: string);
        procedure SetListenOnAll      (const bValue : boolean); inline;
        procedure SetListenToLocal    (const bValue : boolean); inline;
        procedure SetListenToAny      (const bValue : boolean); inline;

        function  ReadKeyString (const aKeyName : string; const aDefault : string = '') : string;
        procedure SetRootxPLDir (const AValue: string);
        procedure SetUseProxy   (const AValue: boolean);
        procedure WriteKeyString(const aKeyName : string; const aValue : string);

        function  ComposeCorrectPath(const aPath : string; const uSub : string) : string;
     public
        constructor create;
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

        property SharedConfigDir  : string read fRootxPLDir write SetRootxPLDir;
        function PluginDirectory  : string;                                             // In the root, directory where plugin are stored
        function LoggingDirectory : string;                                             // In the root, where logs are stored
        function ConfigDirectory  : string;                                             // Directory to store device configuration files
        function IsValid          : Boolean;

        function GetxPLAppList : TStringList;

        procedure GetAppDetail(const aVendor : string; const aDevice : string; out aPath : string; out aVersion : string);
        procedure SetAppDetail(const aVendor : string; const aDevice : string; const aVersion: string);

        class procedure EnsureDirectoryExists(const aDirectoryName : string);
     end;

implementation // ======================================================================
uses SysUtils, StrUtils, cFileUtils, uxPLConst;

const // Registry Key and values constants =============================================
   K_XPL_ROOT_KEY               = '\Software\xPL\';
   K_XPL_FMT_APP_KEY            = K_XPL_ROOT_KEY + '%s\%s\';                        // \software\xpl\vendor\device\
   K_XPL_REG_VERSION_KEY        = 'version';
   K_XPL_REG_PATH_KEY           = 'path';
   K_XPL_SETTINGS_NETWORK_ANY   = 'ANY';
   K_XPL_SETTINGS_NETWORK_LOCAL = 'ANY_LOCAL';
   K_REGISTRY_BROADCAST         = 'BroadcastAddress';
   K_REGISTRY_LISTENON          = 'ListenOnAddress';
   K_REGISTRY_LISTENTO          = 'ListenToAddresses';
   K_REGISTRY_ROOT_XPL_DIR      = 'RootxPLDirectory';
   K_REGISTRY_PROXY             = 'UseProxy';
   K_REGISTRY_HTTP_PROX_SRVR    = 'ProxyHttpSrvr';
   K_REGISTRY_HTTP_PROX_PORT    = 'ProxyHttpPort';
   K_XPL_SETTINGS_SUBDIR_CONF   = 'Config';
   K_XPL_SETTINGS_SUBDIR_PLUG   = 'Plugins';
   K_XPL_SETTINGS_SUBDIR_LOGS   = 'Logging';

// =====================================================================================
function OnGetAppName : string;                                                         // This is used to fake the system when
begin                                                                                   // requesting common xPL applications shared
   result := 'xPL';                                                                     // directory - works in conjunction with
end;                                                                                    // OnGetApplicationName
// TxPLSettings ========================================================================
class procedure TxPLSettings.EnsureDirectoryExists(const aDirectoryName: string);
begin
   if not DirectoryExists(aDirectoryName) then CreateDir(aDirectoryName);
end;
{======================================================================================}
constructor TxPLSettings.Create;
begin
   OnGetApplicationName := @OnGetAppName;

   fRegistry := TRegistry.Create;

   fBroadCastAddress := ReadKeyString(K_REGISTRY_BROADCAST);
   fListenOnAddress  := ReadKeyString(K_REGISTRY_LISTENON);
   fListenToAddresses:= ReadKeyString(K_REGISTRY_LISTENTO);
   fRootxPLDir       := ReadKeyString(K_REGISTRY_ROOT_XPL_DIR,GetAppConfigDir(true));
   fUseProxy         := (ReadKeyString(K_REGISTRY_PROXY, K_STR_FALSE) = K_STR_TRUE);
   fHttpProxPort     := ReadKeyString(K_REGISTRY_HTTP_PROX_PORT);
   fHttpProxSrvr     := ReadKeyString(K_REGISTRY_HTTP_PROX_SRVR);

   EnsureDirectoryExists(SharedConfigDir );                                           // 1.1.1 Correction
   EnsureDirectoryExists(LoggingDirectory);                                           // 1.1.2 complement
   EnsureDirectoryExists(ConfigDirectory );                                           // 0.95 complement
   EnsureDirectoryExists(PluginDirectory );                                           // 1.1.1 Correction
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
   fHTTPProxPort:=AValue;
   WriteKeyString(K_REGISTRY_HTTP_PROX_PORT,fHTTPProxPort);
end;

procedure TxPLSettings.SetHTTPProxSrvr(const AValue: string);
begin
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

function TxPLSettings.IsValid: Boolean;                                                 // Just checks that all basic values
begin                                                                                   // have been initialized
     result := (length(BroadCastAddress) *
                length(ListenOnAddress ) *
                length(ListenToAddresses)) <>0;
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

procedure TxPLSettings.GetAppDetail(const aVendor : string; const aDevice : string; out aPath: string; out aVersion: string);
begin
   fRegistry.RootKey := HKEY_LOCAL_MACHINE;                                             // Redondant but mandatory for reg.xml compatibility
   fRegistry.OpenKey (K_XPL_ROOT_KEY, False);
   fRegistry.OpenKey (aVendor, True);                                                   // At the time, you can't read this
   fRegistry.OpenKey (aDevice, False);
   aVersion := fRegistry.ReadString(K_XPL_REG_VERSION_KEY);                             // if you don't have admin rights under Windows
   aPath    := fRegistry.ReadString(K_XPL_REG_PATH_KEY);
end;

procedure TxPLSettings.SetAppDetail(const aVendor : string; const aDevice : string; const aVersion: string);
begin
   fRegistry.RootKey := HKEY_LOCAL_MACHINE;                                             // Redondant but mandatory for reg.xml compatibility
   fRegistry.OpenKey(Format(K_XPL_FMT_APP_KEY,[aVendor,aDevice]),True);
   fRegistry.WriteString(K_XPL_REG_VERSION_KEY,aVersion);
   fRegistry.WriteString(K_XPL_REG_PATH_KEY,ParamStr(0))
end;

end.

