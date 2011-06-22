unit u_xpl_settings;
{==============================================================================
  UnitDesc      = xPL Registry and Global Settings management unit
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.96 : usage of uxPLConst
 0.97 : Application creates a registry key "HKLM\Software\xPL\[vendorid]\[deviceid]"
        and a string value "Version" within that key. Because the software is
        non-device, you'll have to come up with a 'virtual' unique device ID.
 0.98 : Added proxy information detecting capability
 0.99 : Modification to Registry reading behaviour to allow lazarus reg.xml
        compatibility
 Rev 256 : Cut inheritence from TComponent
            Transfer of strictly confined string constant from uxPLConst here
 1.10  : Added elements to limitate needed access rights and detect errors
        if we don't have enough rights
 }

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Registry
     , Classes
     , u_xpl_address
     , u_xpl_collection
     ;

type // TxPLCustomSettings ====================================================
     TxPLCustomSettings = class(TComponent)
     private
        fRegistry : TRegistry;
        fRightsError : boolean;
        fProxyEnable : integer;
        fProxyServer,
        fBroadCastAddress,
        fListenOnAddress ,
        fListenToAddresses : string;

        function  Get_ListenOnAll     : boolean;
        function  Get_ListenToAny     : boolean;
        function  Get_ListenToLocal   : boolean;
        function  Get_ProxyEnable: boolean;
        procedure Set_ListenOnAll      (const bValue : boolean); inline;
        procedure Set_ListenToLocal    (const bValue : boolean); inline;
        procedure Set_ListenToAny      (const bValue : boolean); inline;
        procedure Set_ListenOnAddress  (const AValue: string);
        procedure Set_ListenToAddresses(const AValue: string);
        procedure Set_BroadCastAddress (const AValue: string);

        function  ReadKeyString (const aKeyName : string; const aDefault : string = '') : string;
        procedure WriteKeyString(const aKeyName : string; const aValue : string);
     public
        constructor Create(AOwner: TComponent); override;
        destructor  Destroy; override;

        function    IsValid : boolean;

        function GetxPLAppList : TxPLCustomCollection;

        procedure GetAppDetail(const aVendor, aDevice : string; out aPath, aVersion : string);
        procedure SetAppDetail(const aVendor, aDevice, aVersion: string);

     published
        property ListenToAny       : boolean read Get_ListenToAny     write Set_ListenToAny;
        property ListenToLocal     : boolean read Get_ListenToLocal   write Set_ListenToLocal;
        property ListenOnAll       : boolean read Get_ListenOnAll     write Set_ListenOnAll;
        property ListenOnAddress   : string  read fListenOnAddress    write Set_ListenOnAddress;
        property ListenToAddresses : string  read fListenToAddresses  write Set_ListenToAddresses;
        property BroadCastAddress  : string  read fBroadCastAddress   write Set_BroadCastAddress;
        property RightsError       : boolean read fRightsError;
        property ProxyEnable       : boolean read Get_ProxyEnable;
        property ProxyServer       : string  read fProxyServer;
     end;

implementation // ======================================================================
uses SysUtils
     , StrUtils
     , u_xpl_application
     , uxPLConst
     , u_xpl_common
     ;

const // Registry Key and values constants =============================================
   K_XPL_ROOT_KEY               = '\Software\xPL\';
   K_XPL_FMT_APP_KEY            = K_XPL_ROOT_KEY + '%s\%s\';                            // \software\xpl\vendor\device\
   K_LOG_INFO                   = 'xPL settings loaded : %s,%s,%s';
   K_XPL_REG_VERSION_KEY        = 'version';
   K_XPL_REG_PATH_KEY           = 'path';
   K_XPL_SETTINGS_NETWORK_ANY   = 'ANY';
   K_XPL_SETTINGS_NETWORK_LOCAL = 'ANY_LOCAL';
   K_REGISTRY_BROADCAST         = 'BroadcastAddress';
   K_REGISTRY_LISTENON          = 'ListenOnAddress';
   K_REGISTRY_LISTENTO          = 'ListenToAddresses';

// TxPLCustomSettings =================================================================
constructor TxPLCustomSettings.Create(aOwner : TComponent);
begin
   inherited;

   fRegistry := TRegistry.Create(KEY_READ);
   fRightsError := false;

   fBroadCastAddress := ReadKeyString(K_REGISTRY_BROADCAST,'255.255.255.255');
   fListenOnAddress  := ReadKeyString(K_REGISTRY_LISTENON,K_XPL_SETTINGS_NETWORK_ANY);
   fListenToAddresses:= ReadKeyString(K_REGISTRY_LISTENTO,K_XPL_SETTINGS_NETWORK_ANY);

   TxPLApplication(aOwner).Log(etInfo,K_LOG_INFO, [fBroadCastAddress,fListenOnAddress,fListenToAddresses]);

   {$ifdef windows}
     fRegistry.RootKey := HKEY_CURRENT_USER;
     fRegistry.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Internet Settings',True);
     fProxyEnable := fRegistry.ReadInteger('ProxyEnable');
     fProxyServer := fRegistry.ReadString('ProxyServer');
   {$else}
     // to be written for linux support
   {$endif}
end;

destructor TxPLCustomSettings.Destroy;
begin
   fRegistry.CloseKey;
   fRegistry.Free;
   inherited;
end;

function TxPLCustomSettings.ReadKeyString(const aKeyName : string; const aDefault : string = '') : string;
begin
   fRegistry.RootKey := HKEY_LOCAL_MACHINE;
   fRegistry.OpenKey(K_XPL_ROOT_KEY,True);
   result := fRegistry.ReadString(aKeyName);
   if result = '' then result := aDefault;
end;

procedure TxPLCustomSettings.WriteKeyString(const aKeyName : string; const aValue : string);
begin
   fRegistry.Access :=KEY_WRITE;
   try
      fRegistry.RootKey := HKEY_LOCAL_MACHINE;
      fRegistry.OpenKey(K_XPL_ROOT_KEY,True);
      try
         fRegistry.WriteString(aKeyName,aValue);                                // Try to write the value
      except
         fRightsError := true;                                                  // We may have an error if we don't have access rights
      end;
   finally
      fRegistry.Access:=KEY_READ;
   end;
end;

function TxPLCustomSettings.Get_ListenToLocal : boolean;
begin
   result := (ListenToAddresses = K_XPL_SETTINGS_NETWORK_LOCAL)
end;

function TxPLCustomSettings.Get_ProxyEnable: boolean;
begin
   result := (fProxyEnable = 1);
end;

procedure TxPLCustomSettings.Set_ListenToLocal(const bValue : boolean);
begin
   ListenToAddresses := IfThen(bValue,K_XPL_SETTINGS_NETWORK_LOCAL);
end;

function TxPLCustomSettings.Get_ListenToAny : boolean;
begin
   result := (ListenToAddresses = K_XPL_SETTINGS_NETWORK_ANY)
end;

procedure TxPLCustomSettings.Set_ListenToAny(const bValue : boolean);
begin
   ListenToAddresses := IfThen(bValue,K_XPL_SETTINGS_NETWORK_ANY) ;
end;

function TxPLCustomSettings.Get_ListenOnAll : boolean;
begin
   result := AnsiIndexStr( ListenOnAddress,
                           [K_XPL_SETTINGS_NETWORK_ANY,K_XPL_SETTINGS_NETWORK_LOCAL] )
                           <> -1 ;
end;

procedure TxPLCustomSettings.Set_ListenOnAll(const bValue : boolean);
begin
   ListenOnAddress := IfThen(bValue,K_XPL_SETTINGS_NETWORK_LOCAL);
end;

procedure TxPLCustomSettings.Set_ListenToAddresses(const AValue: string);
begin
   fListenToAddresses := aValue;
   WriteKeyString(K_REGISTRY_LISTENTO,aValue);
end;

procedure TxPLCustomSettings.Set_ListenOnAddress(const AValue: string);
begin
   fListenOnAddress := aValue;
   WriteKeyString(K_REGISTRY_LISTENON,aValue);
end;

procedure TxPLCustomSettings.Set_BroadCastAddress(const AValue: string);
begin
   fBroadCastAddress := aValue;
   WriteKeyString(K_REGISTRY_BROADCAST,aValue);
end;

function TxPLCustomSettings.IsValid: Boolean;                                           // Just checks that all basic values
begin                                                                                   // have been initialized
   result := (length(BroadCastAddress ) *
              length(ListenOnAddress  ) *
              length(ListenToAddresses)) <>0;
end;

function TxPLCustomSettings.GetxPLAppList : TxPLCustomCollection;
var aVendorListe, aAppListe : TStringList;
    j : integer;
    vendor : string;
    item : TxPLCollectionItem;
begin
   aVendorListe := TStringList.Create;
   aAppListe    := TStringList.Create;
   result := TxPLCustomCollection.Create(nil);
   fRegistry.RootKey := HKEY_LOCAL_MACHINE;
   fRegistry.OpenKey(K_XPL_ROOT_KEY ,True);
   fRegistry.GetKeyNames(aVendorListe);
   for vendor in aVendorListe do begin
       fRegistry.OpenKey(K_XPL_ROOT_KEY,False);
       fRegistry.OpenKey(vendor,False);
       fRegistry.GetKeyNames(aAppListe);
       for j:=0 to aAppListe.Count -1 do begin
          item := Result.Add(aAppListe[j]);
          item.Value := vendor;
       end;
   end;
   aVendorListe.Free;
   aAppListe.Free;
end;

procedure TxPLCustomSettings.GetAppDetail(const aVendor, aDevice : string; out aPath, aVersion: string);
begin
   with fRegistry do begin
      RootKey := HKEY_LOCAL_MACHINE;
      OpenKey (K_XPL_ROOT_KEY, False);
      OpenKey (aVendor, True);                                                   // At the time, you can't read this
      OpenKey (aDevice, False);
      aVersion := ReadString(K_XPL_REG_VERSION_KEY);                             // if you don't have admin rights under Windows
      aPath    := ReadString(K_XPL_REG_PATH_KEY);
   end;
end;

procedure TxPLCustomSettings.SetAppDetail(const aVendor, aDevice, aVersion: string);
begin
   fRegistry.Access  := KEY_WRITE;
   try
      fRegistry.RootKey := HKEY_LOCAL_MACHINE;
      fRegistry.OpenKey(Format(K_XPL_FMT_APP_KEY,[aVendor,aDevice]),True);
      try
         fRegistry.WriteString(K_XPL_REG_VERSION_KEY,aVersion);
         fRegistry.WriteString(K_XPL_REG_PATH_KEY,ParamStr(0))
      except
         fRightsError := True;
      end;
   finally
      fRegistry.Access := KEY_READ;
   end;
end;

end.

