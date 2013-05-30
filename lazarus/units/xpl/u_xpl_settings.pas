unit u_xpl_settings;
{==============================================================================
  UnitDesc      = xPL Registry and Global Settings management unit
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.97 : Application creates a registry key "HKLM\Software\xPL\[vendorid]\[deviceid]"
        and a string value "Version" within that key. Because the software is
        non-device, you'll have to come up with a 'virtual' unique device ID.
 0.98 : Added proxy information detecting capability
 0.99 : Modification to Registry reading behaviour to allow lazarus reg.xml
        compatibility
 1.10  : Added elements to limitate needed access rights and detect errors
        if we don't have enough rights
 }

{$i xpl.inc}

interface

uses Registry
     , Classes
     , u_xpl_collection
     ;

type // TxPLSettings ==========================================================
     TxPLSettings = class(TComponent)
     private
        fProxyEnable : boolean;
        fProxyServer,
        fBroadCastAddress,
        fListenOnAddress ,
        fListenToAddresses : string;

        function  GetListenOnAll     : boolean;
        function  GetListenToAny     : boolean;
        function  GetListenToLocal   : boolean;

     public
        constructor Create(AOwner: TComponent); override;
        //destructor  Destroy; override;
        procedure InitComponent; virtual; abstract;
        function    IsValid : boolean;

     published
        property ListenToAny       : boolean read GetListenToAny;
        property ListenToLocal     : boolean read GetListenToLocal;
        property ListenOnAll       : boolean read GetListenOnAll;
        property ListenOnAddress   : string  read fListenOnAddress;
        property ListenToAddresses : string  read fListenToAddresses;
        property BroadCastAddress  : string  read fBroadCastAddress;
        property ProxyEnable       : boolean read fProxyEnable;
        property ProxyServer       : string  read fProxyServer;
     end;

     // TxPLCommandLineSettings ==============================================
     TxPLCommandLineSettings = class(TxPLSettings)
     public
        procedure InitComponent; override;
     end;

     // TxPLRegistrySettings ==================================================
     TxPLRegistrySettings = class(TxPLSettings)
     private
        fRegistry : TRegistry;

        function  ReadKeyString (const aKeyName : string; const aDefault : string = '') : string;
        procedure WriteKeyString(const aKeyName : string; const aValue : string);

        procedure SetListenOnAll      (const bValue : boolean);
        procedure SetListenToLocal    (const bValue : boolean);
        procedure SetListenToAny      (const bValue : boolean);
        procedure SetListenOnAddress  (const AValue: string);
        procedure SetListenToAddresses(const AValue: string);
        procedure SetBroadCastAddress (const AValue: string);
     public
        procedure InitComponent; override;
        destructor Destroy; override;

        function GetxPLAppList : TxPLCustomCollection;

        procedure GetAppDetail(const aVendor, aDevice : string; out aPath, aVersion, aProdName : string);
        procedure SetAppDetail(const aVendor, aDevice, aVersion: string);
        function Registry : TRegistry;
     published
        property ListenToAny       : boolean read GetListenToAny     write SetListenToAny;
        property ListenToLocal     : boolean read GetListenToLocal   write SetListenToLocal;
        property ListenOnAll       : boolean read GetListenOnAll     write SetListenOnAll;
        property ListenOnAddress   : string  read fListenOnAddress    write SetListenOnAddress;
        property ListenToAddresses : string  read fListenToAddresses  write SetListenToAddresses;
        property BroadCastAddress  : string  read fBroadCastAddress   write SetBroadCastAddress;
     end;

implementation // =============================================================
uses SysUtils
     , StrUtils
     , u_xpl_application
     , uxPLConst
     , uIP
     , fpc_delphi_compat
     , lin_win_compat
     , CustApp
     {$ifndef fpc}
     , windows                                                                 // Needed on delphi to define KEY_READ
     {$endif}
     ;

const // Registry Key and values constants ====================================
     K_XPL_ROOT_KEY               = '\Software\xPL\';
     K_XPL_FMT_APP_KEY            = K_XPL_ROOT_KEY + '%s\%s\';                 // \software\xpl\vendor\device\
     K_LOG_INFO                   = 'xPL settings loaded : %s,%s,%s';
     K_XPL_REG_VERSION_KEY        = 'version';
     K_XPL_REG_PRODUCT_NAME       = 'productname';
     K_XPL_REG_PATH_KEY           = 'path';
     K_XPL_SETTINGS_NETWORK_ANY   = 'ANY';
     K_XPL_SETTINGS_NETWORK_LOCAL = 'ANY_LOCAL';
     K_REGISTRY_BROADCAST         = 'BroadcastAddress';
     K_REGISTRY_LISTENON          = 'ListenOnAddress';
     K_REGISTRY_LISTENTO          = 'ListenToAddresses';

// TxPLSettings =================================================================
constructor TxPLSettings.Create(aOwner : TComponent);
begin
  inherited;

  InitComponent;

  TxPLApplication(Owner).Log(etInfo,K_LOG_INFO, [fBroadCastAddress,fListenOnAddress,fListenToAddresses]);
  GetProxySettings(fProxyEnable,fProxyServer);                                // Stub to load informations depending upon the OS
end;

function TxPLSettings.GetListenToLocal : boolean;
begin
  result := (ListenToAddresses = K_XPL_SETTINGS_NETWORK_LOCAL)
end;

function TxPLSettings.GetListenToAny : boolean;
begin
  result := (ListenToAddresses = K_XPL_SETTINGS_NETWORK_ANY)
end;

function TxPLSettings.GetListenOnAll : boolean;
begin
  result := AnsiIndexStr( ListenOnAddress,
                          [K_XPL_SETTINGS_NETWORK_ANY,K_XPL_SETTINGS_NETWORK_LOCAL] )
                          <> -1 ;
end;

function TxPLSettings.IsValid: Boolean;                                        // Just checks that all basic values
begin                                                                          // have been initialized
  result := (length(BroadCastAddress ) *
             length(ListenOnAddress  ) *
             length(ListenToAddresses)) <>0;
end;

// TxPLCommandLineSettings ====================================================
procedure TxPLCommandLineSettings.InitComponent;
var AddrObj : TIPAddress = nil;
    OptionValue : string;
begin
   OptionValue := TxPLApplication(Owner).Application.GetOptionValue('i');
   AddrObj := LocalIPAddresses.GetByIntName(OptionValue);
   if Assigned(AddrObj) and AddrObj.IsValid then begin
      fBroadCastAddress := AddrObj.BroadCast;
      fListenOnAddress := AddrObj.Address;
      fListenToAddresses := K_XPL_SETTINGS_NETWORK_ANY;
   end else
      TxPLApplication(Owner).Log(etError,'Invalid interface name specified (%s)',[OptionValue]);
end;

// TxPLRegistrySettings =======================================================
function TxPLRegistrySettings.Registry: TRegistry;
begin
   if not Assigned(fRegistry) then
      fRegistry := TRegistry.Create(KEY_READ);
   Result := fRegistry;
end;

procedure TxPLRegistrySettings.InitComponent;
begin
   fBroadCastAddress := ReadKeyString(K_REGISTRY_BROADCAST,'255.255.255.255');
   fListenOnAddress  := ReadKeyString(K_REGISTRY_LISTENON,K_XPL_SETTINGS_NETWORK_ANY);
   fListenToAddresses:= ReadKeyString(K_REGISTRY_LISTENTO,K_XPL_SETTINGS_NETWORK_ANY);
end;

destructor TxPLRegistrySettings.Destroy;
begin
   if Assigned(Registry) then begin
      Registry.CloseKey;
      Registry.Free;
   end;
   inherited;
end;

function TxPLRegistrySettings.ReadKeyString(const aKeyName : string; const aDefault : string = '') : string;
begin
   Registry.RootKey := HKEY_LOCAL_MACHINE;
   Registry.OpenKey(K_XPL_ROOT_KEY,True);
   Result := Registry.ReadString(aKeyName);
   if Result = '' then Result := aDefault;
end;

procedure TxPLRegistrySettings.WriteKeyString(const aKeyName : string; const aValue : string);
begin
   Registry.Access := KEY_WRITE;
   with Registry do try
      RootKey := HKEY_LOCAL_MACHINE;
      OpenKey(K_XPL_ROOT_KEY,True);
      try
         WriteString(aKeyName,aValue);                                // Try to write the value
      except
      end;
   finally
      Access := KEY_READ;
   end;
end;

procedure TxPLRegistrySettings.SetListenToLocal(const bValue : boolean);
begin
   ListenToAddresses := IfThen(bValue,K_XPL_SETTINGS_NETWORK_LOCAL);
end;

procedure TxPLRegistrySettings.SetListenToAny(const bValue : boolean);
begin
   ListenToAddresses := IfThen(bValue,K_XPL_SETTINGS_NETWORK_ANY) ;
end;

procedure TxPLRegistrySettings.SetListenOnAll(const bValue : boolean);
begin
   ListenOnAddress := IfThen(bValue,K_XPL_SETTINGS_NETWORK_LOCAL);
end;

procedure TxPLRegistrySettings.SetListenToAddresses(const AValue: string);
begin
   fListenToAddresses := aValue;
   WriteKeyString(K_REGISTRY_LISTENTO,aValue);
end;

procedure TxPLRegistrySettings.SetListenOnAddress(const AValue: string);
begin
   fListenOnAddress := aValue;
   WriteKeyString(K_REGISTRY_LISTENON,aValue);
end;

procedure TxPLRegistrySettings.SetBroadCastAddress(const AValue: string);
begin
   fBroadCastAddress := aValue;
   WriteKeyString(K_REGISTRY_BROADCAST,aValue);
end;

function TxPLRegistrySettings.GetxPLAppList : TxPLCustomCollection;
var aVendorListe, aAppListe : TStringList;
    vendor, app : string;
    item : TxPLCollectionItem;
begin
   aVendorListe := TStringList.Create;
   aAppListe    := TStringList.Create;
   result := TxPLCustomCollection.Create(nil);
   Registry.RootKey := HKEY_LOCAL_MACHINE;
   Registry.OpenKey(K_XPL_ROOT_KEY ,True);
   Registry.GetKeyNames(aVendorListe);
   for vendor in aVendorListe do begin
       Registry.OpenKey(K_XPL_ROOT_KEY,False);
       Registry.OpenKey(vendor,False);
       Registry.GetKeyNames(aAppListe);
       for app in aAppListe do begin
          item := Result.Add(app);
          item.Value := vendor;
       end;
   end;
   aVendorListe.Free;
   aAppListe.Free;
end;

procedure TxPLRegistrySettings.GetAppDetail(const aVendor, aDevice : string; out aPath, aVersion, aProdName: string);
begin
   with Registry do begin
      RootKey := HKEY_LOCAL_MACHINE;
      OpenKey (K_XPL_ROOT_KEY, False);
      OpenKey (aVendor, True);                                                 // At the time, you can't read this
      OpenKey (aDevice, False);
      aVersion := ReadString(K_XPL_REG_VERSION_KEY);                           // if you don't have admin rights under Windows
      aPath    := ReadString(K_XPL_REG_PATH_KEY);
      aProdName:= ReadString(K_XPL_REG_PRODUCT_NAME);
   end;
end;

procedure TxPLRegistrySettings.SetAppDetail(const aVendor, aDevice, aVersion: string);
begin
   Registry.Access := KEY_WRITE;
   with Registry do try
      RootKey := HKEY_LOCAL_MACHINE;
      OpenKey(Format(K_XPL_FMT_APP_KEY,[aVendor,aDevice]),True);
      try
         WriteString(K_XPL_REG_VERSION_KEY,aVersion);
         WriteString(K_XPL_REG_PATH_KEY,ParamStr(0));
         WriteString(K_XPL_REG_PRODUCT_NAME,GetProductName);
      except
      end;
   finally
      Access := KEY_READ;
   end;
end;

end.