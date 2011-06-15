unit u_xpl_AppFramework;

{$mode objfpc}{$H+}

interface

uses SysUtils,
     Classes,
     EventLog,
     VersionChecker,
     synamisc,
     u_xpl_address,
     u_xpl_folders,
     u_xpl_vendor_file,
     u_xpl_settings,
     u_xpl_common,
     u_xml_xplplugin;

type

{ TxPLAppFramework }

TxPLAppFramework = class
     private
        fSettings   : TxPLCustomSettings;
        fFolders    : TxPLCustomFolders;
        fAdresse    : TxPLAddress;
        fEventLog   : TEventLog;
        fOnLogEvent : TStrParamEvent;
        fPluginList : TxPLVendorSeedFile;
        fLocaleDomains : TStringList;
     protected
        fVChecker   : TVersionChecker;
     public
        HTTPProxy : TProxySetting;

        constructor Create;
        destructor  Destroy; override;

        function BuildDate : string; inline;
        function AppName   : string; inline;
        function FullTitle : string; inline;
        function DeviceInVendorFile : TXMLDeviceType;

        procedure CheckVersion;
        Procedure Log (EventType : TEventType; Msg : String);
        Procedure Log (EventType : TEventType; Fmt : String; Args : Array of const);
        function  RegisterLocaleDomain(Const aTarget : string; const aDomain : string) : boolean;
        function  Translate(Const aDomain : string; Const aString : string) : string;

        property Settings  : TxPLCustomSettings read fSettings;
        property Adresse   : TxPLAddress        read fAdresse;
        property Folders   : TxPLCustomFolders  read fFolders;
        property Vendor    : string             read fAdresse.fVendor;
        property Device    : string             read fAdresse.fDevice;
        property Version   : string             read fvChecker.fCurrentVersion;
        property EventLog  : TEventLog          read fEventLog;
        property OnLogEvent: TStrParamEvent     read fOnLogEvent write fOnLogEvent;
        property VendorFile: TxPLVendorSeedFile read fPluginList;
     end;

//var xPLAppFramework : TxPLAppFramework;

implementation // =============================================================
uses FPCAdds,
     app_main;

const K_MSG_LOCALISATION    = 'Localisation file loaded for : %s';

// ============================================================================
function OnGetAppName : string; inline;                                        // This is used to fake the system when
begin                                                                          // requesting common xPL AppFrameworks shared
   result := 'xPL';                                                            // directory - works in conjunction with
end;                                                                           // OnGetAppFrameworkName

// TxPLAppFramework ===========================================================
constructor TxPLAppFramework.Create;
begin
   inherited;

(*   OnGetApplicationName := @OnGetAppName;
   fAdresse    := TxPLAddress.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE);
   fSettings   := TxPLCustomSettings.Create;
   fFolders    := TxPLCustomFolders.Create;

   fEventLog := TEventLog.Create(nil);
   fEventLog.LogType  := ltFile;
   fEventLog.Filename := GetTempFileName(fFolders.DeviceDir(Vendor,Device),'log');
   fEventLog.RaiseExceptionOnError := true;

   fVChecker := TVersionChecker.Create(nil);
   fvChecker.ServerLocation := K_DEFAULT_ONLINESTORE;
   fvChecker.CurrentVersion := K_DEFAULT_VERSION;
   fvChecker.VersionNode    := Format('/xpl-plugin[@vendor="%s"]/device[@id="%s-%s"]/attribute::version',[Vendor, Vendor, Device]);
   fvChecker.DownloadNode   := Format('/xpl-plugin[@vendor="%s"]/device[@id="%s-%s"]/attribute::download_url',[Vendor, Vendor, Device]);

   fPluginList := TxPLVendorSeedFile.Create(Folders);

   fLocaleDomains := TStringList.Create;
   HTTPProxy      := GetIEProxy('http');     *)
end;

destructor TxPLAppFramework.Destroy;
begin
   fEventLog.Free;
   fPluginList.Free;
   fLocaleDomains.Free;
   fSettings.Free;
   fvChecker.Free;
   fFolders.Free;
   fAdresse.Free;
   inherited;
end;

procedure TxPLAppFrameWork.CheckVersion;
begin
//   fvChecker.CheckVersion;
end;

function TxPLAppFramework.BuildDate: string;                                   // This code piece comes from Lazarus AboutFrm source
var SlashPos1, SlashPos2: integer;                                             // The compiler generated date string is always of the form y/m/d.
    Date: TDateTime;
begin                                                                          // This function gives it a string respresentation according to the
   result := {$I %date%};                                                      // shortdateformat
   SlashPos1 := Pos('/',result);
   SlashPos2 := SlashPos1 + Pos('/', Copy(result, SlashPos1+1, Length(result)-SlashPos1));
   Date := EncodeDate(StrToWord(Copy(result,1,SlashPos1-1)),
   StrToWord(Copy(result,SlashPos1+1,SlashPos2-SlashPos1-1)),
   StrToWord(Copy(result,SlashPos2+1,Length(BuildDate)-SlashPos2)));
   Result := FormatDateTime('yyyy-mm-dd', Date);
end;

function TxPLAppFramework.AppName : string;
begin
   Result := Format('xPL %s',[Adresse.Device]);
end;

function TxPLAppFramework.FullTitle : string;
begin
(*   Result := Format('%s version %s by %s (build %s)',[AppName,K_DEFAULT_VERSION,Adresse.Vendor,BuildDate]);*)
end;

function TxPLAppFramework.DeviceInVendorFile: TXMLDeviceType;
begin
   result := VendorFile.GetDevice(Vendor,Device);
end;

Procedure TxPLAppFramework.Log(EventType : TEventType; Msg : String);
begin
   fEventLog.Log(EventType,Msg);
   if Assigned(fOnLogEvent) then OnLogEvent(Msg);
end;

Procedure TxPLAppFramework.Log(EventType : TEventType; Fmt : String; Args : Array of const);
begin
   fEventLog.Log(EventType,Fmt,Args);
   if Assigned(fOnLogEvent) then OnLogEvent(Format(Fmt,Args));
end;

function TxPLAppFramework.RegisterLocaleDomain(const aTarget: string; const aDomain: string) : boolean;
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

function TxPLAppFramework.Translate(const aDomain: string; const aString : string): string;
var i : integer;
begin
   i := fLocaleDomains.IndexOf(aDomain);
   if i<>-1 then result := TStringList(fLocaleDomains.Objects[i]).Values[aString]
            else result := aString;
end;

end.

