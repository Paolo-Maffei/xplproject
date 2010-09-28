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

uses Classes, SysUtils, DOM, XMLRead, uxPLSettings, uxPLConst, uxPLPluginFile,
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
        function Get_Locations: TXMLLocationsType;
        function Get_Plugins: TXMLPluginsType;
        function  VendorTag(aDocument : TXMLDocument) : tsVendor;
        function  GetDistantFile(const sLocation : string; const sDestination : string) : boolean;
     public
        constructor create(const aSettings : TxPLSettings);
        destructor  destroy; override;
        procedure   Load;
        function    Name : string;                                                        // File name of the current vendor plugin file

        function Updated  : TDateTime;
        function Update(const sLocation : string = K_XPL_VENDOR_SEED_LOCATION) : boolean; // Reloads the seed file from website
        function UpdatePlugin(const aPluginName : string) : boolean;

        function GetDevices(aVendor : tsVendor) : TStringList;
        function  VendorFile(const aVendor : tsVendor) : TXMLxplpluginType;
//        function PluginType       (const aPlugIn : string) : string;
//        function PluginDescription(const aPlugIn : string) : string;
        //function PluginURL        (const aPlugin : string) : string;
        function GetDevice(aVendor : tsVendor; aDevice : tsDevice) : TxPLDevice;
        function GetPluginFilePath(const aPluginName : string) : string;

//        property Plugins   : TStringList read fPlugins;
//        property Locations : TStringList read fLocations;                       // Places where Seed file can be downloaded
        property Locations  : TXMLLocationsType read Get_Locations;
        property Plugins    : TXMLPluginsType   read Get_Plugins;
        property IsValid   : boolean     read fStatus;
     end;

implementation //========================================================================
uses uGetHTTP,
     cStrings,
     IdHTTP,
     StrUtils,
     uRegExpr,
     Dialogs,
     u_xml;

type TVendorPluginFile = class
        Node : TDomNode;
        PluginFile : TXMLDocument;
        Description : string;
        FileName    : string;
     end;

resourcestring // XML Plugin file entry and field variable names ========================
//   K_PF_PLUGIN   = 'plugin';
//   K_PF_LOCATION = 'locations';
//   K_PF_NAME     = 'name';
//   K_PF_URL      = 'url';
//   K_PF_DESC     = 'description';
//   K_PF_TYPE     = 'type';

//   K_VF_Description = 'description';
//   K_VF_Info_url    = 'info_url';
//   K_VF_NAME        = 'name';
   K_VF_Device      = 'device';
   K_VF_Id          = 'id';
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

procedure TxPLVendorSeedFile.Load;
begin
   if not FileExists(Name) then exit;
   try
      ReadXMLFile(fDoc,Name);
      fPluginsFile := TXMLPluginsFile.Create(fDoc.FirstChild);
      fStatus := True;                                                                    // Settings correctly initialised and loaded
   except
      on E : EXMLReadError do fStatus := false;
   end;
end;

function TxPLVendorSeedFile.Name: string;
begin result := fSettings.PluginDirectory + K_XPL_VENDOR_SEED_FILE; end;

function TxPLVendorSeedFile.Updated: TDateTime;
var fileDate : Integer;
begin
   fileDate := FileAge(Name);
   if fileDate > -1 then Result := FileDateToDateTime(fileDate);
end;

function TxPLVendorSeedFile.GetDistantFile(const sLocation : string; const sDestination : string) : boolean;
begin
   result := GetHTTPFile( sLocation, sDestination,
                          ifThen(fSettings.UseProxy,fSettings.HTTPProxSrvr,''),
                          ifThen(fSettings.UseProxy,fSettings.HTTPProxPort,''));
end;

function TxPLVendorSeedFile.Update(const sLocation : string) : boolean;
begin
   result := GetDistantFile(sLocation + K_FEXT_XML, Name);
end;

function TxPLVendorSeedFile.Get_Locations: TXMLLocationsType;
begin
  result := fPluginsFile.Locations;
end;

function TxPLVendorSeedFile.Get_Plugins: TXMLPluginsType;
begin
  result := fPluginsFile;
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

function TxPLVendorSeedFile.GetPluginFilePath(const aPluginName : string) : string;
var //plugin_url : string;
    i : integer;
begin
   for i := 0 to fPluginsFile.Count-1 do begin
      if fPluginsFile[i].Name = aPluginName then
         result := fSettings.PluginDirectory +
                   copyright(fPluginsFile[i].URL, length(fPluginsFile[i].URL)-LastDelimiter('/',fPluginsFile[i].URL))+ K_FEXT_XML
   end;
//   plugin_url := PlugInURL(aPluginName);
//   result := fSettings.PluginDirectory + copyright(plugin_url, length(plugin_url)-LastDelimiter('/',plugin_url))+ K_FEXT_XML
end;

function TxPLVendorSeedFile.UpdatePlugin(const aPluginName: string) : boolean;
var i : integer;
begin
   i := 0;
   result := false;
   while ((result=false) and (i<fPluginsFile.Count)) do begin
      if fPluginsFile[i].Name = aPluginName then begin
         result := GetDistantFile( fPluginsFile[i].URL + K_FEXT_XML, GetPluginFilePath(aPluginName));
      end;
      inc(i);
   end;
//   result := GetDistantFile( PlugInURL(aPluginName) + K_FEXT_XML, GetPluginFilePath(aPluginName));
end;

//function TxPLVendorSeedFile.GetPluginValue(const aPlugIn : string; const aProperty : string) : string;
//var i : integer;
//begin
//    result := '';
//    i := Plugins.IndexOf(aPlugin);
//    Result := IfThen(i<>-1,(TVendorPluginFile(Plugins.Objects[i]).Node).Attributes.GetNamedItem(aProperty).NodeValue,'');
//end;

function TxPLVendorSeedFile.VendorFile(const aVendor: tsVendor): TXMLxplpluginType;
var i : integer;
    vpf : TVendorPluginFile;
    fn : string;
    document : TXMLDocument;
    aNode : TDOMNode;
begin
   result := nil;
   i := 0;
   while (i< fPluginsFile.Count) and (result=nil) do begin
      if fPluginsFile[i].Vendor = aVendor then begin
         fn := fSettings.PluginDirectory + AnsilowerCase(aVendor) + K_FEXT_XML;
         if fileexists(fn) then begin
            document := TXMLDocument.Create;
            ReadXMLFile(document,fn);
            aNode := Document.FirstChild;
            while (aNode.NodeName <> K_XML_STR_XplPlugin) and
                  (aNode.NodeName<>K_XML_STR_XplhalmgrPlugin) do
                  aNode := Document.FirstChild.NextSibling;

            result := TXMLxplpluginType.Create(aNode);
         end;
      end;
      inc(i);
   end;
{   i := fPlugins.IndexOf(aVendor);
   if i = -1 then exit;

   vpf := TVendorPluginFile(fPlugins.Objects[i]);

   if not assigned(vpf.PluginFile) then
      if fileexists(vpf.FileName) then begin
         ReadXMLFile(vpf.PluginFile, vpf.FileName);
      end;
   result := vpf.PluginFile;}
end;

function TxPLVendorSeedFile.GetDevices(aVendor : tsVendor): TStringList;
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
end;

function TxPLVendorSeedFile.VendorTag(aDocument: TXMLDocument): tsVendor;
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
end;

// Shortcuts ====================================================================================
//function TxPLVendorSeedFile.PluginType(const aPlugIn: string): string;
//begin result := GetPluginValue(aPlugIn,K_PF_TYPE); end;

//function TxPLVendorSeedFile.PluginDescription(const aPlugIn: string): string;
//begin result := GetPluginValue(aPlugIn,K_PF_DESC); end;

//function TxPLVendorSeedFile.PluginURL(const aPlugin: string): string;
//begin result := GetPluginValue(aPlugIn,K_PF_URL); end;

function TxPLVendorSeedFile.GetDevice(aVendor: tsVendor; aDevice: tsDevice  ): TxPLDevice;
var vf : TXMLDocument;
    Child : TDomNode;
begin
   result := nil;
 {  vf := VendorFile(aVendor);
   if not assigned(vf) then exit;

   Child := vf.FirstChild;                                                                // The first level is the plugin description
   Child := Child.FirstChild;                                                             // at second level are the devices
   with TRegExpr.Create do begin
      while Assigned(Child) and (result=nil) do begin
         Expression := K_REGEXPR_DEVICE_ID;
         if Child.NodeName = K_VF_DEVICE then
           if Exec(Child.Attributes.GetNamedItem(K_VF_ID).NodeValue) then begin
              if Match[2] = aDevice then result := TxPLDevice.Create(Child);
           end;
         Child := Child.NextSibling;
      end;
      Destroy;
   end;
  }
end;

end.

