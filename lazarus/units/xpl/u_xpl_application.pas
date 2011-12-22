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
     , fpc_delphi_compat
     , lin_win_compat
     ;

type { TxPLApplication =======================================================}
     TxPLApplication = class(TComponent)
     private
        fSettings   : TxPLSettings;
        fFolders    : TxPLFolders;
        fAdresse    : TxPLAddress;
        fOnLogEvent : TStrParamEvent;
        fPluginList : TxPLVendorSeedFile;
        fLocaleDomains : TStringList;
        fVersion    : string;

     public
        constructor Create(const aOwner : TComponent); reintroduce;
        destructor  Destroy; override;

        function AppName     : string;
        function FullTitle   : string;

        procedure RegisterMe;
        Procedure Log (const EventType : TEventType; const Msg : String); overload;
        Procedure Log (const EventType : TEventType; const Fmt : String; const Args : Array of const); overload;

        function  RegisterLocaleDomain(Const aTarget : string; const aDomain : string) : boolean;
        function  Translate(Const aDomain : string; Const aString : string) : string;

        property Settings  : TxPLSettings       read fSettings;
        property Adresse   : TxPLAddress        read fAdresse;
        property Folders   : TxPLFolders        read fFolders;
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

   fFolders  := TxPLFolders.Create(fAdresse);

   Log(etInfo,FullTitle);

   fSettings   := TxPLSettings.Create(self);
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

initialization // =============================================================
   InstanceInitStyle  := iisHostName;

   LocalAddresses     := TStringList.Create;
   LocalAddresses.Assign(IPAddresses);

finalization // ===============================================================
   LocalAddresses.Free;

end.