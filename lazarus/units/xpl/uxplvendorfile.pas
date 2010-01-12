unit uxPLVendorFile;
{==============================================================================
  UnitName      = uxPLVendorFile
  UnitDesc      = xPL Vendor File Management Unit
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 }
{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM, XMLRead, uxPLSettings;

type

{ TxPLVendorSeedFile }

TxPLVendorSeedFile = class(TXMLDocument)
     private
        fSettings  : TxPLSettings;
        fPlugins   : TStringList;
        fLocations : TStringList;

        procedure GetElements;
     public
        constructor create(const aSettings : TxPLSettings);
        destructor  destroy; override;
        function    Name : string;
        function    Updated  : TDateTime;
        procedure  Update(const sLocation : string = 'http://xplproject.org.uk/plugins');     // Reloads the seed file from website
        function   UpdatePlugin(const aPluginName : string) : boolean;

        function GetPluginValue(const aPlugIn : string; const aProperty : string) : string;
        property Plugins   : TStringList read fPlugins;
        property Locations : TStringList read fLocations;
     end;

implementation //========================================================================
uses uGetHTTP, cStrings, IdHTTP;

{ TxPLVendorSeedFile ====================================================================}
procedure TxPLVendorSeedFile.GetElements;
var Child,Location : TDomNode;
begin
  fPlugins.Clear;
  fLocations.Clear;
  Child := DocumentElement.FirstChild;
  while Assigned(Child) do begin
     if Child.NodeName = 'plugin' then
        fPlugins.AddObject(Child.Attributes.GetNamedItem('name').NodeValue,Child);
     if Child.NodeName = 'locations' then begin
        Location := Child.FirstChild;
        while Assigned(Location) do begin
              Locations.Add(Location.Attributes.GetNamedItem('url').NodeValue) ;
              Location := Location.NextSibling;
        end;
     end;
     Child := Child.NextSibling;
  end;
end;

function TxPLVendorSeedFile.GetPluginValue(const aPlugIn : string; const aProperty : string) : string;
var i : integer;
begin
     result := '';
     i := Plugins.IndexOf(aPlugin);
     if i<>-1 then
        result := TDOMNode(Plugins.Objects[i]).Attributes.GetNamedItem(aProperty).NodeValue;
end;

constructor TxPLVendorSeedFile.create(const aSettings: TxPLSettings);
begin
   inherited Create;

   ReadXMLFile(self,Name);     // this creates the object

   fSettings := aSettings;
   fPlugins  := TStringList.Create;
   fLocations := TStringList.Create;
   GetElements;
end;

destructor TxPLVendorSeedFile.destroy;
begin
     fPlugins.Destroy;
     fLocations.Destroy;
end;

function TxPLVendorSeedFile.Name: string;
begin result := fSettings.PluginDirectory + 'plugins.xml'; end;

function TxPLVendorSeedFile.Updated: TDateTime;
var fileDate : Integer;
begin
   fileDate := FileAge(Name);
   if fileDate > -1 then Result := FileDateToDateTime(fileDate);
end;

procedure TxPLVendorSeedFile.Update(const sLocation : string = 'http://xplproject.org.uk/plugins');
begin
   WGetHTTPFile(sLocation + '.php', Name);
end;

function TxPLVendorSeedFile.UpdatePlugin(const aPluginName: string) : boolean;
var plugin_url : string;
    target_file: string;
begin
   result := true;
   plugin_url := GetPluginValue(aPluginName,'url');
   target_file:= fSettings.PluginDirectory + copyright(plugin_url, length(plugin_url)-LastDelimiter('/',plugin_url))+'.xml';
   try
      WGetHTTPFile(plugin_url + '.xml', target_file);
   except  // I really don't understand why exceptions here are not catched...maybe fpc bug ?
      on E : EIdHTTPProtocolException do result := false ;
   end;
end;

end.

