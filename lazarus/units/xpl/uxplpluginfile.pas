unit uxPLPluginFile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DOM, uxPLSettings;

type

{ txPLPluginFile }

{ txPLPluginList }

     txPLPluginList = class
     private
           fPluginDir : string;
           fPlugins   : tstringlist;
     public
           constructor Create;
           destructor  destroy; override;

           function    Count : integer;
           property    Plugin : tstringlist read fPlugins;
     end;


     txPLPluginFile = class(TXMLDocument)
     private
           fDeviceList : TStringList;

           function    GetDevices   : TStringList;
           function    GetVendorTag : string;
           function    GetElementList(const aDevice : string; const aEltName : string): TStringList;
           function    GetElement(const aDevice: string; const aElement : string;  const aEltName : string): TDomNode;
     public
           destructor  Destroy; override;

           function    VendorName : string;
           function    Device(const aDevice : string) : TDomNode;
           function    Commands(const aDevice : string) : TStringList;
           function    Command(const aDevice : string; const aCommand : string) : TDomNode;
           function    ConfigItems(const aDevice : string) : TStringList;
           function    ConfigItem(const aDevice : string; const aConfigItem : string) : TDomNode;
           property    DeviceList : TStringList read fDeviceList;
           property    VendorTag  : string      read GetVendorTag;
     end;

implementation
uses XMLRead, cStrings;
{ txPLPluginList }

constructor txPLPluginList.Create;
var aPluginFile : TxPLPluginFile;
    searchResult : TSearchRec;
    Settings     : TxPLSettings;
begin
     inherited Create;
     fplugins := tstringlist.create;
     Settings := TxPLSettings.Create;
     fPluginDir := Settings.PluginDirectory;
     Settings.Free;
     if FindFirst(fPluginDir+'*.xml', faAnyFile, SearchResult)=0 then begin
        repeat
              ReadXMLFile(aPluginFile,fPluginDir + searchResult.Name);     // this creates the object
              aPluginFile.fDeviceList := aPluginFile.GetDevices;
              fPlugins.AddObject(aPluginFile.VendorTag,aPluginFile);
        until FindNext(SearchResult)<>0;
     end;
end;

destructor txPLPluginList.destroy;
begin
     fplugins.destroy;
     inherited;
end;

function txPLPluginList.Count: integer;
begin
  result := fplugins.count;
end;

{ txPLPluginFile }
destructor txPLPluginFile.Destroy;
begin
     if Assigned(fDeviceList) then fDeviceList.Free;
     inherited;
end;

function txPLPluginFile.VendorName: string;
var aNode : TDOMNode;
begin
     aNode := DocumentElement.Attributes.GetNamedItem('vendor');
     if assigned(aNode) then result := aNode.NodeValue;
end;

function txPLPluginFile.GetVendorTag : string;
var Child : TDomNode;
    left,right : string;
begin
  left := '';
  Child := DocumentElement.FirstChild;
  if Assigned(Child) then begin
     if Child.NodeName = 'device' then begin
        right := Child.Attributes.GetNamedItem('id').NodeValue;
        StrSplitAtChar(right,'-',left,right);
        result := left;
     end;
   end;
end;

function txPLPluginFile.GetDevices: TStringList;
var aList : TStringList;
    Child : TDomNode;
    left,right : string;
begin
  left := '';
  aList := TStringList.Create;
  Child := DocumentElement.FirstChild;
  while Assigned(Child) do begin
     if Child.NodeName = 'device' then begin
        right := Child.Attributes.GetNamedItem('id').NodeValue;
        StrSplitAtChar(right,'-',left,right);
        aList.AddObject(right,Child);
     end;
     Child := Child.NextSibling;
   end;
   result := aList;
end;

function txPLPluginFile.Device(const aDevice : string) : TDomNode;
var i : integer;
begin
     result := nil;
     i := fDeviceList.IndexOf(aDevice);
     if i<>-1 then result := TDomNode(fDeviceList.Objects[i]);
end;

function txPLPluginFile.GetElementList(const aDevice : string; const aEltName : string ): TStringList;
var FoundDevice,Child : TDomNode;
begin
     result := TStringList.Create;
     FoundDevice := Device(aDevice);

     if FoundDevice = nil then exit;

     Child := FoundDevice.FirstChild;
     while Assigned(Child) do begin
           if Child.NodeName = aEltName then begin
              Result.Add(Child.Attributes.GetNamedItem('name').NodeValue);
           end;
           Child := Child.NextSibling;
     end;
end;


function txPLPluginFile.Commands(const aDevice : string): TStringList;
begin Result := GetElementList(aDevice,'command'); end;

function txPLPluginFile.ConfigItems(const aDevice: string): TStringList;
begin Result := GetElementList(aDevice,'configItem'); end;

function txPLPluginFile.GetElement(const aDevice: string; const aElement : string;  const aEltName : string): TDomNode;
var FoundDevice,Child : TDomNode;
    CommandName : string;
begin
     result:= nil;
     FoundDevice := Device(aDevice);
     if FoundDevice = nil then exit;

     Child := FoundDevice.FirstChild;
     while Assigned(Child) do begin
           if Child.NodeName = aEltName then begin
              CommandName := Child.Attributes.GetNamedItem('name').NodeValue;
              if (CommandName = aElement) then result := Child;
           end;
           Child := Child.NextSibling;
     end;
end;

function txPLPluginFile.Command(const aDevice: string; const aCommand : string): TDomNode;
begin
     Result := GetElement(aDevice, aCommand,'command');
end;

function txPLPluginFile.ConfigItem(const aDevice: string; const aConfigItem: string): TDomNode;
begin
     Result := GetElement(aDevice, aConfigItem,'configItem');
end;

end.

