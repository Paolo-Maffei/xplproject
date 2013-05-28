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
     ;

type { TxPLVendorSeedFile ====================================================}
     TxPLVendorSeedFile = class(TComponent)
     private
        fFolders    : TxPLFolders;
        fLocations  : TLocationsType;
        fPlugins    : TPluginsType;
        fSchemas    : TSchemaCollection;
        function GetLocations: TLocationsType;
        function GetPlugins: TPluginsType;
        function GetSchemas: TSchemaCollection;
     public
        constructor Create(const aOwner : TComponent ;const aFolders : TxPLFolders); reintroduce;
        destructor  Destroy; override;
        function    FileName : string; inline;                                 // File name of the current vendor plugin file
        function    SchemaFile : string; inline;

        function UpdatedTS : TDateTime;                                        // Renamed to avoid conflict with ancestors
        function Update(const sLocation : string = K_XPL_VENDOR_SEED_LOCATION) : boolean; // Reloads the seed file from website
        function FindDevice(const aAddress : TxPLAddress) : TDeviceType;

        function IsValid   : boolean;
     published
        property Locations : TLocationsType read GetLocations;
        property Plugins   : TPluginsType   read GetPlugins;
        property Schemas   : TSchemaCollection read GetSchemas;
     end;

implementation //==============================================================
uses RegExpr
     , u_downloader_Indy
     , u_xpl_application
     ;

// TxPLVendorSeedFile =========================================================
constructor TxPLVendorSeedFile.Create(const aOwner : TComponent; const aFolders: TxPLFolders);
begin
   inherited Create(aOwner);
   fFolders := aFolders;
end;

destructor TxPLVendorSeedFile.Destroy;
begin
   if assigned(fLocations) then fLocations.Free;
   if assigned(fPlugins) then fPlugins.Free;
   if assigned(fSchemas) then fSchemas.Free;
   inherited;
end;

function TxPLVendorSeedFile.IsValid : boolean;
begin
   Result := Assigned(Locations) and Assigned(Plugins);
end;

function TxPLVendorSeedFile.FileName: string;
begin
   result := fFolders.PluginDir + K_XPL_VENDOR_SEED_FILE;
end;

function TxPLVendorSeedFile.SchemaFile : string;
begin
   result := fFolders.PluginDir + K_XPL_SCHEMA_COLL_FILE;
end;

function TxPLVendorSeedFile.GetSchemas: TSchemaCollection;
var SO : ISuperObject;
begin
   if not Assigned(fSchemas) then begin
      if not FileExists(SchemaFile) then
         TxPLApplication(Owner).Log(etWarning,'Schema collection file absent, please consider downloading it')
      else begin
         SO := XMLParseFile(SchemaFile,true);
         fSchemas := TSchemaCollection.Create(so, TxPLApplication(Owner).Folders.PluginDir);
      end;
   end;
   Result := fSchemas;
end;

function TxPLVendorSeedFile.GetLocations: TLocationsType;
var SO : ISuperObject;
begin
   if not Assigned(fLocations) then begin
      if not FileExists(FileName) then
         TxPLApplication(Owner).Log(etWarning,'Vendor file absent, please consider updating it')
      else begin
         SO := XMLParseFile(FileName,true);
         fLocations := TLocationsType.Create(so);
      end;
   end;
   Result := fLocations;
end;

function TxPLVendorSeedFile.GetPlugins: TPluginsType;
var SO : ISuperObject;
begin
   if not Assigned(fPlugins) then begin
      if not FileExists(FileName) then
         TxPLApplication(Owner).Log(etWarning,'Vendor file absent, please consider updating it')
      else begin
         SO := XMLParseFile(FileName,true);
         fPlugins := TPluginsType.Create(so, TxPLApplication(Owner).Folders.PluginDir);
      end;
   end;
   Result := fPlugins;
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

end.
