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
 }
{$mode objfpc}{$H+}

interface

uses  Registry,Classes;

type

    { TxPLSettings }

    TxPLSettings = class
     private
        fRegistry : TRegistry;
        fBroadCastAddress  : string;
        fListenOnAddress   : string;
        fListenToAddresses : string;

        function GetListenOnAll     : boolean;
        function GetListenToAny     : boolean;
        function GetListenToLocal   : boolean;
        procedure SetBroadCastAddress (const AValue: string);
        procedure SetListenOnAddress  (const AValue: string);
        procedure SetListenToAddresses(const AValue: string);
        procedure SetListenOnAll      (const bValue : boolean);
        procedure SetListenToLocal    (const bValue : boolean);
        procedure SetListenToAny      (const bValue : boolean);

        function  ReadKeyString(const aKeyName : string; const aDefault : string = '') : string;
        procedure WriteKeyString(const aKeyName : string; const aValue : string);
     public
        constructor create;
        destructor  destroy; override;

        property ListenToAny   : boolean read GetListenToAny   write SetListenToAny;
        property ListenToLocal : boolean read GetListenToLocal write SetListenToLocal;
        property ListenOnAll   : boolean read GetListenOnAll   write SetListenOnAll;
        property BroadCastAddress  : string read fBroadCastAddress  write SetBroadCastAddress;
        property ListenOnAddress   : string read fListenOnAddress   write SetListenOnAddress;
        property ListenToAddresses : string read fListenToAddresses write SetListenToAddresses;

        function SharedConfigDir  : string;   // Root of common to all xPL application setting directory
        function PluginDirectory  : string;   // In the root, directory where plugin are stored
        function LoggingDirectory : string;
        function ConfigDirectory  : string;   // Directory to store device configuration files
        procedure RegisterMe(const aAppName : string; const aAppVersion : string);
        function GetxPLAppList : TStringList;
        procedure GetxPLAppDetail(const aAppName : string; out aPath : string; out aVersion : string);
     end;

implementation { ======================================================================}
uses SysUtils, StrUtils;

ResourceString K_XPL_ROOT_KEY               = '\Software\xPL\';
               K_XPL_APPS_KEY               = '\Software\xPL\apps\';
               K_XPL_SETTINGS_NETWORK_ANY   = 'ANY';
               K_XPL_SETTINGS_NETWORK_LOCAL = 'ANY_LOCAL';
               K_REGISTRY_BROADCAST         = 'BroadcastAddress';
               K_REGISTRY_LISTENON          = 'ListenOnAddress';
               K_REGISTRY_LISTENTO          = 'ListenToAddresses';

function OnGetAppName : string;                   // This is used to fake the system when
begin                                             // requesting common xPL applications shared
  result := 'xPL';                                // directory - works in conjunction with
end;                                              // OnGetApplicationName
{ TxPLSettings ========================================================================}
constructor TxPLSettings.create;
begin
     OnGetApplicationName := @OnGetAppName;

     fRegistry :=TRegistry.Create;
     fRegistry.RootKey:=HKEY_LOCAL_MACHINE;

     fBroadCastAddress := ReadKeyString(K_REGISTRY_BROADCAST);
     fListenOnAddress  := ReadKeyString(K_REGISTRY_LISTENON);
     fListenToAddresses:= ReadKeyString(K_REGISTRY_LISTENTO);

     if not DirectoryExists(SharedConfigDir) then CreateDir(SharedConfigDir);   // 1.1.1 Correction
     if not DirectoryExists(PluginDirectory) then CreateDir(PluginDirectory);   // 1.1.1 Correction
     if not DirectoryExists(LoggingDirectory) then CreateDir(LoggingDirectory); // 1.1.2 complement
end;

destructor TxPLSettings.destroy;
begin
     fRegistry.CloseKey;
     fRegistry.Destroy;
end;

function TxPLSettings.GetListenToAny : boolean;
begin result := (ListenToAddresses = K_XPL_SETTINGS_NETWORK_ANY) end;

function TxPLSettings.GetListenToLocal : boolean;
begin result := (ListenToAddresses = K_XPL_SETTINGS_NETWORK_LOCAL) end;

function TxPLSettings.ReadKeyString(const aKeyName : string; const aDefault : string = '') : string;
begin
   fRegistry.OpenKey(K_XPL_ROOT_KEY,True);
   result := fRegistry.ReadString(aKeyName);
   if result = '' then result := aDefault;
end;

procedure TxPLSettings.WriteKeyString(const aKeyName : string; const aValue : string);
begin
   fRegistry.OpenKey(K_XPL_ROOT_KEY,True);
   fRegistry.WriteString(aKeyName,aValue);
end;

procedure TxPLSettings.SetBroadCastAddress(const AValue: string);
begin
     fBroadCastAddress := aValue;
     WriteKeyString(K_REGISTRY_BROADCAST,aValue);
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

function TxPLSettings.SharedConfigDir : string;
begin
     result := GetAppConfigDir(true);
     if result[length(result)]<>'\' then result += '\';                         // 1.1.1 bug correction
end;

function TxPLSettings.PluginDirectory: string;
begin result := SharedConfigDir + 'Plugins\'; end;

function TxPLSettings.LoggingDirectory: string;
begin result := SharedConfigDir + 'Logging\'; end;

function TxPLSettings.ConfigDirectory: string;
begin result := SharedConfigDir + 'Config\'; end;

procedure TxPLSettings.RegisterMe(const aAppName : string; const aAppVersion : string);
var aPath, aVersion : string;
begin
     GetxPLAppDetail(aAppName,aPath,aVersion);
     if aVersion < aAppVersion then begin                                       // Empty or older version information
        fRegistry.OpenKey(K_XPL_APPS_KEY + aAppName,True);
        fRegistry.WriteString('version',aAppVersion);
        fRegistry.WriteString('path',ParamStr(0))
     end;
end;

function TxPLSettings.GetxPLAppList : TStringList;
begin
     result := TStringList.Create;
     fRegistry.OpenKey(K_XPL_APPS_KEY ,True);
     fRegistry.GetKeyNames(result);
end;

procedure TxPLSettings.GetxPLAppDetail(const aAppName: string; out   aPath: string; out aVersion: string);
begin
     fRegistry.OpenKey(K_XPL_APPS_KEY + aAppName ,True);                        // At the time, you can't read this
     aVersion := fRegistry.ReadString('version');                               // if you don't have admin rights !
     aPath := fRegistry.ReadString('path');
end;

end.

