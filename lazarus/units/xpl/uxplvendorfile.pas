unit uxPLVendorFile;
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

uses Classes, SysUtils, DOM, XMLRead, u_xpl_settings_reg, uxPLConst,
u_xml_plugins, u_xml_xplplugin;

type

{ TxPLVendorSeedFile }

TxPLVendorSeedFile = class
     private
        fDoc         : TXMLDocument;
        fPluginsFile : TXMLPluginsFile;
//        fPlugins   : TStringList;
//        fLocations : TStringList;
        fSettings  : TxPLSettings;
//        fDocument : TXMLDocument;
        fStatus   : boolean;

//        procedure GetElements;
//        function  GetPluginValue(const aPlugIn : string; const aProperty : string) : string;

//        function VendorTag(aDocument : TXMLDocument) : tsVendor;
        function  GetDistantFile(const sLocation : string; const sDestination : string) : boolean;
     public
        constructor create(const aSettings : TxPLSettings);
        destructor  destroy; override;
        procedure   Load;
        function    Name : string; inline;                                                // File name of the current vendor plugin file

        function Updated  : TDateTime;
        function Update(const sLocation : string = K_XPL_VENDOR_SEED_LOCATION) : boolean; // Reloads the seed file from website
        function UpdatePlugin(const aPluginName : string) : boolean;

//        function GetDevices(aVendor : tsVendor) : TStringList;
        function  VendorFile(const aVendor : tsVendor) : TXMLxplpluginType;
//        function PluginType       (const aPlugIn : string) : string;
//        function PluginDescription(const aPlugIn : string) : string;
        //function PluginURL        (const aPlugin : string) : string;
        function GetDevice(aVendor : tsVendor; aDevice : tsDevice) : TXMLDeviceType;
        function GetPluginFilePath(const aPluginName : string) : string;

//        property Plugins   : TStringList read fPlugins;
        function Locations : TXMLLocationsType;                       // Places where Seed file can be downloaded
//        property Locations  : TXMLLocationsType read Get_Locations;
//        property Plugins    : TXMLPluginsType   read Get_Plugins;
        property IsValid    : boolean           read fStatus;
        function Plugins    : TXMLPluginsType;
     end;

implementation //========================================================================
uses uGetHTTP,
     cStrings,
     IdHTTP,
     StrUtils,
     uRegExpr;

{type TVendorPluginFile = class
        Node : TDomNode;
        PluginFile : TXMLDocument;
        Description : string;
        FileName    : string;
     end;}

//resourcestring // XML Plugin file entry and field variable names ========================
//   K_PF_PLUGIN   = 'plugin';
//   K_PF_LOCATION = 'locations';
//   K_PF_NAME     = 'name';
//   K_PF_URL      = 'url';
//   K_PF_DESC     = 'description';
//   K_PF_TYPE     = 'type';

//   K_VF_Description = 'description';
//   K_VF_Info_url    = 'info_url';
//   K_VF_NAME        = 'name';
//   K_VF_Device      = 'device';
//   K_VF_Id          = 'id';
//   K_VF_Vendor      = 'vendor';
//   K_VF_Version     = 'version';

{ TxPLVendorSeedFile ====================================================================}
constructor TxPLVendorSeedFile.create(const aSettings: TxPLSettings);
begin
   inherited Create;
   fStatus := false;
   fSettings := aSettings;
   fDoc := TXMLDocument.Create;
   if fSettings.IsValid then Load;
end;

destructor TxPLVendorSeedFile.destroy;
begin
   fPluginsFile.destroy;
   fDoc.destroy;
   inherited;
end;

function TxPLVendorSeedFile.Name: string;
begin result := fSettings.PluginDirectory + K_XPL_VENDOR_SEED_FILE; end;

procedure TxPLVendorSeedFile.Load;
var aNode : TDomNode;
begin
   if not FileExists(Name) then exit;
   try
      ReadXMLFile(fDoc,Name);
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
   fileDate := FileAge(Name);
   if fileDate > -1 then Result := FileDateToDateTime(fileDate);
end;

function TxPLVendorSeedFile.GetDistantFile(const sLocation : string; const sDestination : string) : boolean;
var s : string;
begin
   result := GetHTTPFile( sLocation, sDestination,
                          ifThen(fSettings.UseProxy,fSettings.HTTPProxSrvr,''),
                          ifThen(fSettings.UseProxy,fSettings.HTTPProxPort,''), s);
end;

function TxPLVendorSeedFile.GetPluginFilePath(const aPluginName : string) : string;
var i : LongWord;
begin
   result := '';
   i := 0;
   repeat
      if fPluginsFile[i].Name = aPluginName then
         result := fSettings.PluginDirectory +
                   copyright(fPluginsFile[i].URL, length(fPluginsFile[i].URL)-LastDelimiter('/',fPluginsFile[i].URL))+ K_FEXT_XML;
      inc(i);
   until (i > fPluginsFile.Count) or (result <> '')
end;


function TxPLVendorSeedFile.Update(const sLocation : string) : boolean;
begin
   result := GetDistantFile(sLocation + K_FEXT_XML, Name);
end;

{procedure TxPLVendorSeedFile.GetElements;
var Child,Location : TDomNode;
    aRecord : TVendorPluginFile;
    vendor : tsVendor;
begin
   fPlugins.Clear;
   fLocations.Clear;
   Child := fDocument.DocumentElement.FirstChild;
   while Assigned(Child) do begin
      if Child.NodeName = K_PF_PLUGIN then begin
            aRecord  := TVendorPluginFile.Create;
            aRecord.Description := Child.Attributes.GetNamedItem(K_PF_NAME).NodeValue;               // like 'cdp1802 Plug-in'
            Vendor  := AnsiLowerCase(AnsiLeftStr(aRecord.Description,AnsiPos(' ',aRecord.Description)-1));     // like  cdp1802 - converted to lower for linux compatibility needs
            aRecord.Node        := Child;
            aRecord.PluginFile  := nil;                                                              // By default, the file isn't loaded
            aRecord.FileName    := fSettings.PluginDirectory + Vendor + K_FEXT_XML;                  // like c:\cxmxclkxc\cdp1802.xml
            fPlugins.AddObject(Vendor,aRecord);
      end;
      if Child.NodeName = K_PF_LOCATION then begin
         Location := Child.FirstChild;
         while Assigned(Location) do begin
               Locations.Add(Location.Attributes.GetNamedItem(K_PF_URL).NodeValue) ;
               Location := Location.NextSibling;
         end;
      end;
      Child := Child.NextSibling;
   end;
end;}


function TxPLVendorSeedFile.UpdatePlugin(const aPluginName: string) : boolean;
var i : LongWord;
    url : string;
begin
   i := 0;
   result := false;
   while ((result=false) and (i<fPluginsFile.Count)) do begin
      if fPluginsFile[i].Name = aPluginName then begin
         url := fPluginsFile[i].URL;
         if not AnsiEndsStr(K_FEXT_XML, url) then url += K_FEXT_XML;
         result := GetDistantFile( url, GetPluginFilePath(aPluginName));
      end;
      inc(i);
   end;
end;

//function TxPLVendorSeedFile.GetPluginValue(const aPlugIn : string; const aProperty : string) : string;
//var i : integer;
//begin
//    result := '';
//    i := Plugins.IndexOf(aPlugin);
//    Result := IfThen(i<>-1,(TVendorPluginFile(Plugins.Objects[i]).Node).Attributes.GetNamedItem(aProperty).NodeValue,'');
//end;

function TxPLVendorSeedFile.VendorFile(const aVendor: tsVendor): TXMLxplpluginType;
var i : LongWord;
    fn : string;
begin
   result := nil;
   i := 0;
   while (i< fPluginsFile.Count) and (result=nil) do begin
      if fPluginsFile[i].Vendor = aVendor then begin
         fn := fSettings.PluginDirectory + AnsilowerCase(aVendor) + K_FEXT_XML;
         if fileexists(fn) then begin
            result := TXMLxplpluginType.Create(fn);
            if not result.valid then begin
               result.Destroy;
               result := nil;
            end;
         end;
      end;
      inc(i);
   end;
end;

(*function TxPLVendorSeedFile.GetDevices(aVendor : tsVendor): TStringList;
var Child : TDomNode;
    aDocument : TXMLDocument;
begin
  {  result := TStringList.Create;
   aDocument := VendorFile(aVendor);
   if aDocument = nil then exit;

   Child := aDocument.FirstChild;
   Child := Child.FirstChild;
   with TRegExpr.Create do begin
      while Assigned(Child) do begin
         Expression := K_REGEXPR_DEVICE_ID;
         if Child.NodeName = K_VF_DEVICE then
           if Exec(Child.Attributes.GetNamedItem(K_VF_ID).NodeValue) then result.AddObject(Match[2],Child);
         Child := Child.NextSibling;
      end;
      Destroy;                                                                            // Release the RegExpr
   end;}
end;*)

{function TxPLVendorSeedFile.VendorTag(aDocument: TXMLDocument): tsVendor;
var Child : TDomNode;
begin
  Child := aDocument.FirstChild;
  if not Assigned(Child) then exit;

  if Child.NodeName = K_VF_Device then
     with TRegExpr.Create do begin
          Expression := K_REGEXPR_DEVICE_ID;
          if Exec(Child.Attributes.GetNamedItem(K_VF_Id).NodeValue) then result := Match[1];
          Destroy;
     end;
end;}

function TxPLVendorSeedFile.GetDevice(aVendor: tsVendor; aDevice: tsDevice  ): TXMLDeviceType;
var vf : TXMLxplpluginType;
    i : integer;
begin
   result := nil;
   vf := VendorFile(aVendor);
   if not assigned(vf) then exit;

   for i:=0 to vf.Count-1 do
       if vf[i].Id = (aVendor + '-' + aDevice) then result := vf[i];
end;

end.

