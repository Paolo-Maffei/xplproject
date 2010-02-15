unit uxPLVendorFile;
{==============================================================================
  UnitName      = uxPLVendorFile
  UnitDesc      = XML Vendor Seed File Management Unit
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 Version 0.9  : usage of uxPLConst
         0.91 : integrated method of RIP TxPLVendorPlugin / redondant with it
 }
{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM, XMLRead, uxPLSettings, uxPLConst, uxPLPluginFile;

type TxPLVendorSeedFile = class(TXMLDocument)
     private
        fPlugins   : TStringList;
        fLocations : TStringList;

        procedure  GetElements;
        function   GetPluginValue(const aPlugIn : string; const aProperty : string) : string;
        function    VendorFile(aVendor : tsVendor) : TXMLDocument;
        function    GetDevices(aDocument : TXMLDocument) : TStringList;
        function    VendorTag(aDocument : TXMLDocument) : tsVendor;
     public
        constructor create(const aSettings : TxPLSettings);
        destructor  destroy; override;
        function    Name : string;                                                        // File name of the current vendor plugin file

        function Updated  : TDateTime;
        function Update(const sLocation : string = K_XPL_VENDOR_SEED_LOCATION) : boolean; // Reloads the seed file from website
        function UpdatePlugin(const aPluginName : string) : boolean;

        function PluginType       (const aPlugIn : string) : string;
        function PluginDescription(const aPlugIn : string) : string;
        function PluginURL        (const aPlugin : string) : string;
        function GetDevice(aVendor : tsVendor; aDevice : tsDevice) : TxPLDevice;

        property Plugins   : TStringList read fPlugins;
        property Locations : TStringList read fLocations;
     end;

implementation //========================================================================
uses uGetHTTP, cStrings, IdHTTP, StrUtils, RegExpr;

type TVendorPluginFile = class
        Node : TDomNode;
        PluginFile : TXMLDocument;
        Description : string;
        FileName    : string;
     end;

resourcestring // XML Plugin file entry and field variable names ========================
   K_PF_PLUGIN   = 'plugin';
   K_PF_LOCATION = 'locations';
   K_PF_NAME     = 'name';
   K_PF_URL      = 'url';
   K_PF_DESC     = 'description';
   K_PF_TYPE     = 'type';

   K_VF_Description = 'description';
   K_VF_Info_url    = 'info_url';
   K_VF_NAME        = 'name';
   K_VF_Device      = 'device';
   K_VF_Id          = 'id';
   K_VF_Vendor      = 'vendor';
   K_VF_Version     = 'version';

// This var is global outside class because in the constructor of TxPLVendorSeedFile,
// we call ReadXMLFile on self, wich reinits the object - ugly but by design of XMLRead
// no clean workaround found - workaround could be to change ancestor VendorSeedFile to
// a different object than TXMLDocument, having XMLDocument as a property
Var fPlugDirectory : string;

{ TxPLVendorSeedFile ====================================================================}
constructor TxPLVendorSeedFile.create(const aSettings: TxPLSettings);
begin
   inherited Create;
   fPlugDirectory := aSettings.PluginDirectory;

   if not FileExists(Name) then Update;

   ReadXMLFile(self,Name);                                                                // /!\ this recreates the object
                                                                                          // be done after call to this
   fPlugins  := TStringList.Create;
   fLocations := TStringList.Create;
   GetElements;
end;

destructor TxPLVendorSeedFile.destroy;
begin
   fPlugins.Destroy;
   fLocations.Destroy;
   inherited;
end;

function TxPLVendorSeedFile.Name: string;
begin
   result := fPlugDirectory + K_XPL_VENDOR_SEED_FILE;
end;

procedure TxPLVendorSeedFile.GetElements;
var Child,Location : TDomNode;
    aRecord : TVendorPluginFile;
    plugdesc,vendor,fname : string;
begin
   fPlugins.Clear;
   fLocations.Clear;
   Child := DocumentElement.FirstChild;
   while Assigned(Child) do begin
      if Child.NodeName = K_PF_PLUGIN then begin
            plugdesc := Child.Attributes.GetNamedItem(K_PF_NAME).NodeValue;               // like 'cdp1802 Plug-in'
            vendor    := AnsiLeftStr(plugdesc,AnsiPos(' ',plugdesc)-1);                   // like  cdp1802
            fname     := fPlugDirectory + vendor + K_FEXT_XML;                            // like c:\cxmxclkxc\cdp1802.xml
            aRecord := TVendorPluginFile.Create;
            aRecord.Node := Child;
            aRecord.PluginFile := nil;
            aRecord.Description := plugDesc;
            aRecord.FileName := fPlugDirectory + vendor + K_FEXT_XML;
            fPlugins.AddObject(vendor,aRecord);
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
end;

function TxPLVendorSeedFile.Updated: TDateTime;
var fileDate : Integer;
begin
   fileDate := FileAge(Name);
   if fileDate > -1 then Result := FileDateToDateTime(fileDate);
end;

function TxPLVendorSeedFile.Update(const sLocation : string) : boolean;
begin
   result := GetHTTPFile(sLocation + K_FEXT_PHP, Name);
end;

function TxPLVendorSeedFile.UpdatePlugin(const aPluginName: string) : boolean;
var plugin_url : string;
begin
   plugin_url := PlugInURL(aPluginName);
   result := GetHTTPFile( plugin_url + K_FEXT_XML,
                          fPlugDirectory + copyright(plugin_url, length(plugin_url)-LastDelimiter('/',plugin_url))+ K_FEXT_XML);
end;

function TxPLVendorSeedFile.GetPluginValue(const aPlugIn : string; const aProperty : string) : string;
var i : integer;
begin
    result := '';
    i := Plugins.IndexOf(aPlugin);
    Result := IfThen(i<>-1,(TVendorPluginFile(Plugins.Objects[i]).Node).Attributes.GetNamedItem(aProperty).NodeValue,'');
end;

function TxPLVendorSeedFile.VendorFile(aVendor: tsVendor): TXMLDocument;
var i : integer;
    vpf : TVendorPluginFile;
    aPluginFile : TXMLDocument;
begin
   result := nil;
   i := fPlugins.IndexOf(aVendor);
   if i = -1 then exit;

   vpf := TVendorPluginFile(fPlugins.Objects[i]);
   if not assigned(vpf.PluginFile) then
      if fileexists(vpf.FileName) then begin
         ReadXMLFile(aPluginFile, vpf.FileName);
         vpf.PluginFile := aPluginFile;
      end;
   result := TXMLDocument(vpf.PluginFile);
end;

function TxPLVendorSeedFile.GetDevices(aDocument: TXMLDocument): TStringList;
var Child : TDomNode;
begin
   result := TStringList.Create;
   Child := aDocument.FirstChild;
   with TRegExpr.Create do begin
      while Assigned(Child) do begin
         Expression := K_REGEXPR_DEVICE_ID;
         if Child.NodeName = K_VF_DEVICE then
           if Exec(Child.Attributes.GetNamedItem(K_VF_ID).NodeValue) then result.AddObject(Match[2],Child);
         Child := Child.NextSibling;
      end;
      Destroy;                                // Release the RegExpr
   end;
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
function TxPLVendorSeedFile.PluginType(const aPlugIn: string): string;
begin result := GetPluginValue(aPlugIn,K_PF_TYPE); end;

function TxPLVendorSeedFile.PluginDescription(const aPlugIn: string): string;
begin result := GetPluginValue(aPlugIn,K_PF_DESC); end;

function TxPLVendorSeedFile.PluginURL(const aPlugin: string): string;
begin result := GetPluginValue(aPlugIn,K_PF_URL); end;

function TxPLVendorSeedFile.GetDevice(aVendor: tsVendor; aDevice: tsDevice  ): TxPLDevice;
var vf : TXMLDocument;
    Child : TDomNode;
begin
   result := nil;
   vf := VendorFile(aVendor);
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

end;

end.

