unit u_xpl_vendor_file;
{==============================================================================
  UnitName      = uxPLVendorFile
  UnitDesc      = XML Vendor Seed File Management Unit
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 Version 0.9  : usage of uxPLConst
         0.91 : integrated method of RIP TxPLVendorPlugin / redondant with it
         0.92 : small fix on the vendor seed file extension when html downloading
         0.93 : Changed ancestor of the class from TXMLDocument to nothing to avoid bug
                Added error handling when loading the vendor seed file
                Added proxy awareness capability
         0.94 : Modifications to use u_xml_plugins
         1.00 : Dropped usage of DOM and XMLRead, replaced by superobject
 }

{$ifdef fpc}
   {$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , uxPLConst
     , u_xpl_address
     , u_xml_plugins
     , u_xpl_folders
     , superobject
     , superxmlparser
     , fpc_delphi_compat
     ;

type { TxPLVendorSeedFile ====================================================}
     TxPLVendorSeedFile = class(TComponent)
     private
        fFolders    : TxPLCustomFolders;
        fStatus     : boolean;
        fLocations  : TLocationsType;
        fPlugins    : TPluginsType;
     public
        constructor create(const aOwner : TComponent ;const aFolders : TxPLCustomFolders); reintroduce;
        destructor  Destroy; override;
        procedure   Load;
        function    FileName : string; inline;                                 // File name of the current vendor plugin file

        function UpdatedTS : TDateTime;                                        // Renamed to avoid conflict with ancestors
        function Update(const sLocation : string = K_XPL_VENDOR_SEED_LOCATION) : boolean; // Reloads the seed file from website
        function FindDevice(const aAddress : TxPLAddress) : TDeviceType;

        property IsValid   : boolean           read fStatus;
     published
        property Locations : TLocationsType read fLocations;
        property Plugins   : TPluginsType   read fPlugins;
     end;

implementation //==============================================================
uses uRegExpr
     , u_downloader_Indy
     , u_xpl_application
     , u_xpl_common
     ;

// TxPLVendorSeedFile =========================================================
constructor TxPLVendorSeedFile.create(const aOwner : TComponent; const aFolders: TxPLCustomFolders);
begin
   inherited Create(aOwner);
   fStatus  := false;
   fFolders := aFolders;
   Load;
end;

destructor TxPLVendorSeedFile.destroy;
begin
   if assigned(fLocations) then fLocations.Free;
   if assigned(fPlugins)   then fPlugins.Free;
   inherited;
end;

function TxPLVendorSeedFile.FileName: string;
begin
   result := fFolders.PluginDir + K_XPL_VENDOR_SEED_FILE;
end;

procedure TxPLVendorSeedFile.Load;
var SO : ISuperObject;
begin
   if not FileExists(FileName) then
      TxPLApplication(Owner).Log(etWarning,'Vendor file absent, please consider updating it')
   else
   try
      fStatus := True;                                                         // Settings correctly initialised and loaded

      SO := XMLParseFile(FileName,true);

      fPlugins := TPluginsType.Create(so, TxPLApplication(Owner).Folders.PluginDir);
      fLocations := TLocationsType.Create(so);
   except
   end;
end;

function TxPLVendorSeedFile.UpdatedTS: TDateTime;
var fileDate : integer;
begin
   fileDate := FileAge(FileName);
   if fileDate > -1 then Result := FileDateToDateTime(filedate)
                    else Result := 0;
end;

function TxPLVendorSeedFile.Update(const sLocation : string) : boolean;
begin
   Result := HTTPDownload(sLocation + '.xml', FileName, xPLApplication.Settings.ProxyServer);
end;

function TxPLVendorSeedFile.FindDevice(const aAddress: TxPLAddress): TDeviceType;
var plug, dev : TCollectionItem;
begin
   result := nil;
   if not Assigned(Plugins) then exit;                                         // Bug #FS57,#FS72,#FS73
   for plug in Plugins do
         if TPluginType(plug).Vendor = aAddress.Vendor then
            for dev in TPluginType(plug).Devices do
                if TDeviceType(dev).Device = aAddress.Device then
                   result := TDeviceType(dev);
end;

//function TxPLVendorSeedFile.UpdatePlugin(const aPluginName: string) : boolean;
//var i : LongWord;
//    url : string;
//begin
//   i := 0;
//   while (i<Plugins.Count) do begin
//      if Plugins[i].Name = aPluginName then begin
//         url := Plugins[i].URL;
//         if not AnsiEndsStr(K_FEXT_XML, url) then url += K_FEXT_XML;
////            Result := HTTPDownload(url,GetPluginFilePath(aPluginName));
//            Result := HTTPDownload(url, Plugins[i].FileName);
//            break;
//      end;
//      inc(i);
//   end;
//end;

//function TxPLVendorSeedFile.VendorFile(const aVendor: tsVendor): TXMLpluginType;
//var i : LongWord;
//    fn : string;
//begin
//   result := nil;
//   if Plugins<>nil then begin
//      i := 0;
//   while (i< Plugins.Count) and (result=nil) do begin
//         if Plugins[i].Vendor = aVendor then begin
//            fn := fFolders.PluginDir + AnsilowerCase(aVendor) + K_FEXT_XML;
//            if fileexists(fn) then begin
//               result := TXMLPluginType.Create(fn);
//               if not result.valid then FreeAndNil(result);
//            end;
//         end;
//         inc(i);
//      end;
//   end;
//end;

//function TxPLVendorSeedFile.GetDevice(const aAddress : TxPLAddress): TXMLDeviceType;
//var vf : TXMLPluginType;
//    i : integer;
//begin
//   result := nil;
//   vf := VendorFile(aAddress.Vendor);
//   if not assigned(vf) then exit;
//
//   for i:=0 to vf.Count-1 do
//       if vf[i].Id = (aAddress.VD) then result := vf[i];
//end;

//function TxPLVendorSeedFile.GetPluginFilePath(const aPluginName : string) : string;
//var item : TCollectionItem;
//begin
//   result := '';
//   for item in Plugins do begin
//       if TPluginType(item).Name = aPluginName then begin
//          result := fFolders.PluginDir +
//                    AnsiRightStr( TPluginType(item).URL,
//                                  length(TPluginType(item).Url)-LastDelimiter('/',TPluginType(item).URL)
//                    ) + K_FEXT_XML;
//          break;
//       end;
//   end;
//end;


end.

