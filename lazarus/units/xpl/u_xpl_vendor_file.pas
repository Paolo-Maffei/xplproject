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
 }
{$mode objfpc}{$H+}

interface

uses Classes,
     SysUtils,
     DOM,
     XMLRead,
     uxPLConst,
     u_xpl_address,
     u_xml_plugins,
     u_xml_xplplugin,
     u_xpl_folders;

type

{ TxPLVendorSeedFile }

TxPLVendorSeedFile = class(TComponent)
     private
        fDoc         : TXMLDocument;
        fPluginsFile : TXMLPluginsFile;
        fFolders  : TxPLCustomFolders;
        fStatus   : boolean;

     public
        constructor create(const aOwner : TComponent ;const aFolders : TxPLCustomFolders);
        destructor  destroy; override;
        procedure   Load;
        function    FileName : string; inline;                                                // File name of the current vendor plugin file

        function Updated  : TDateTime;
        function Update(const sLocation : string = K_XPL_VENDOR_SEED_LOCATION) : boolean; // Reloads the seed file from website
        function UpdatePlugin(const aPluginName : string) : boolean;

        function  VendorFile(const aVendor : tsVendor) : TXMLxplpluginType;
        function GetDevice(const aAddress : TxPLAddress) : TXMLDeviceType;
        function GetPluginFilePath(const aPluginName : string) : string;

        property IsValid   : boolean           read fStatus;
        function Plugins   : TXMLPluginsType   ; inline;
        function Locations : TXMLLocationsType ; inline;                      // Places where Seed file can be downloaded
     end;

implementation //========================================================================
uses cStrings
     , StrUtils
     , uRegExpr
     , u_downloader_Indy
     , u_xpl_application
     , u_xpl_common
     ;

{ TxPLVendorSeedFile ====================================================================}
constructor TxPLVendorSeedFile.create(const aOwner : TComponent; const aFolders: TxPLCustomFolders);
begin
   inherited Create(aOwner);
   fStatus := false;
   fFolders := aFolders;
   fDoc := TXMLDocument.Create;
   Load;
end;

destructor TxPLVendorSeedFile.destroy;
begin
   fDoc.destroy;
   inherited;
end;

function TxPLVendorSeedFile.FileName: string;
begin
   result := fFolders.PluginDir + K_XPL_VENDOR_SEED_FILE;
end;

procedure TxPLVendorSeedFile.Load;
var aNode : TDomNode;
begin
   if not FileExists(FileName) then
      TxPLApplication(Owner).Log(etWarning,'Vendor file absent, please consider updating it')
   else
   try
      ReadXMLFile(fDoc,FileName);
      aNode := fDoc.FirstChild;
      fPluginsFile := TXMLPluginsFile.Create(aNode);
      fStatus := True;                                                                    // Settings correctly initialised and loaded
   except
      on E : EXMLReadError do fStatus := false;
   end;
end;

function TxPLVendorSeedFile.Locations : TXMLLocationsType;
begin
   result := fPluginsFile.Locations
end;

function TxPLVendorSeedFile.Plugins    : TXMLPluginsType;
begin
   result := fPluginsFile;
end;

function TxPLVendorSeedFile.Updated: TDateTime;
var fileDate : Integer;
begin
   fileDate := FileAge(FileName);
   if fileDate > -1 then Result := FileDateToDateTime(fileDate);
end;

function TxPLVendorSeedFile.GetPluginFilePath(const aPluginName : string) : string;
var i : LongWord;
begin
   result := '';
   i := 0;
   repeat
      if fPluginsFile[i].Name = aPluginName then begin
         result := fFolders.PluginDir +
                   copyright(fPluginsFile[i].URL, length(fPluginsFile[i].URL)-LastDelimiter('/',fPluginsFile[i].URL))+ K_FEXT_XML;
         break;
      end;
      inc(i);
   until (i > fPluginsFile.Count);
end;

function TxPLVendorSeedFile.Update(const sLocation : string) : boolean;
begin
   Result := HTTPDownload(sLocation + '.xml', FileName);
end;

function TxPLVendorSeedFile.UpdatePlugin(const aPluginName: string) : boolean;
var i : LongWord;
    url : string;
begin
   i := 0;
   while (i<fPluginsFile.Count) do begin
      if fPluginsFile[i].Name = aPluginName then begin
         url := fPluginsFile[i].URL;
         if not AnsiEndsStr(K_FEXT_XML, url) then url += K_FEXT_XML;
            Result := HTTPDownload(url,GetPluginFilePath(aPluginName));
            break;
      end;
      inc(i);
   end;
end;

function TxPLVendorSeedFile.VendorFile(const aVendor: tsVendor): TXMLxplpluginType;
var i : LongWord;
    fn : string;
begin
   result := nil;
   if fPluginsFile<>nil then begin
      i := 0;
      while (i< fPluginsFile.Count) and (result=nil) do begin
         if fPluginsFile[i].Vendor = aVendor then begin
            fn := fFolders.PluginDir + AnsilowerCase(aVendor) + K_FEXT_XML;
            if fileexists(fn) then begin
               result := TXMLxplpluginType.Create(fn);
               if not result.valid then FreeAndNil(result);
            end;
         end;
         inc(i);
      end;
   end;
end;

function TxPLVendorSeedFile.GetDevice(const aAddress : TxPLAddress): TXMLDeviceType;
var vf : TXMLxplpluginType;
    i : integer;
begin
   result := nil;
   vf := VendorFile(aAddress.Vendor);
   if not assigned(vf) then exit;

   for i:=0 to vf.Count-1 do
       if vf[i].Id = (aAddress.VD) then result := vf[i];
end;

end.

