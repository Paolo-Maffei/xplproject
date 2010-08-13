unit u_xml_plugins;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM;

type TXMLPluginType = class(TDOMElement)
     protected
        function Get_Name: AnsiString;
        function Get_Type_: AnsiString;
        function Get_Description: AnsiString;
        function Get_Url: AnsiString;
        procedure Set_Name(Value: AnsiString);
        procedure Set_Type_(Value: AnsiString);
        procedure Set_Description(Value: AnsiString);
        procedure Set_Url(Value: AnsiString);
     public
        property Name: AnsiString read Get_Name write Set_Name;
        property Type_: AnsiString read Get_Type_ write Set_Type_;
        property Description: AnsiString read Get_Description write Set_Description;
        property Url: AnsiString read Get_Url write Set_Url;
     end;

     TXMLLocationType = class(TDOMElement)
     protected
        function Get_Url: AnsiString;
        procedure Set_Url(Value: AnsiString);
     published
        property Url: AnsiString read Get_Url write Set_Url;
     end;

     TXMLLocationsType = class(TDOMElementList)
     protected
        function Get_Location(Index: Integer): TXMLLocationType;
     public
        constructor Create(ANode: TDOMNode); overload;
        property Location[Index: Integer]: TXMLLocationType read Get_Location; default;
     end;

     TXMLPluginsType = class(TDOMElementList)
     private
        fLocations : TXMLLocationsType;
        function Get_Plugin(Index: Integer): TXMLPluginType;
     protected
        function Get_Version: AnsiString;
        //    function Get_Locations: TXMLLocationsType;
        procedure Set_Version(Value: AnsiString);
     public
        constructor Create(ANode: TDOMNode); overload;
        property Plugin[Index: Integer]: TXMLPluginType read Get_Plugin ; default;
     published
        property Version: AnsiString read Get_Version write Set_Version;
        property Locations: TXMLLocationsType read fLocations;
     end;

var pluginsfile : TXMLPluginsType;

implementation //=========================================================================
uses XMLRead;
var document : TXMLDocument;
//========================================================================================

function TXMLLocationsType.Get_Location(Index: Integer): TXMLLocationType;
begin
  Result := TXMLLocationType(Item[Index]);
end;

constructor TXMLLocationsType.Create(ANode: TDOMNode);
begin
   inherited Create(aNode,'location');
end;

function TXMLLocationType.Get_Url: AnsiString;
begin
  Result := Attributes.GetNamedItem('url').NodeValue;
end;

procedure TXMLLocationType.Set_Url(Value: AnsiString);
begin
  //SetAttribute('url', Value);
  TDOMElement(self).SetAttribute('url',Value);
end;

{ TXMLPluginType }

function TXMLPluginType.Get_Name: AnsiString;
begin
   Result := Attributes.GetNamedItem('name').NodeValue;
end;

function TXMLPluginType.Get_Type_: AnsiString;
begin
   Result := Attributes.GetNamedItem('type').NodeValue;
end;

function TXMLPluginType.Get_Description: AnsiString;
begin
   Result := Attributes.GetNamedItem('description').NodeValue;
end;

function TXMLPluginType.Get_Url: AnsiString;
begin
   Result := Attributes.GetNamedItem('url').NodeValue;
end;

procedure TXMLPluginType.Set_Name(Value: AnsiString);
begin
   TDOMElement(self).SetAttribute('name',Value);
end;

procedure TXMLPluginType.Set_Type_(Value: AnsiString);
begin
   TDOMElement(self).SetAttribute('type',Value);
end;

procedure TXMLPluginType.Set_Description(Value: AnsiString);
begin
   TDOMElement(self).SetAttribute('description',Value);
end;

procedure TXMLPluginType.Set_Url(Value: AnsiString);
begin
  TDOMElement(self).SetAttribute('url',Value);
end;

{ TXMLPluginsType }

function TXMLPluginsType.Get_Plugin(Index: Integer): TXMLPluginType;
begin
  Result := TXMLPluginType(Item[Index]);
end;

function TXMLPluginsType.Get_Version: AnsiString;
begin
     result := FNode.Attributes.GetNamedItem('version').NodeValue;
end;

procedure TXMLPluginsType.Set_Version(Value: AnsiString);
begin

end;

constructor TXMLPluginsType.Create(ANode: TDOMNode);
begin
   inherited Create(aNode,'plugin');
   fLocations := TXMLLocationsType.Create(aNode);
end;

// Unit initialization ===================================================================
initialization
   document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\ProgramData\xPL\Plugins\plugins.xml');
   pluginsfile := TXMLPluginsType.Create(Document.FirstChild);

finalization
   pluginsfile.destroy;
   document.destroy;

end.

