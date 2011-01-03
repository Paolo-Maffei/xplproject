unit u_xml_plugins;

{$mode objfpc}{$H+}

interface

uses Classes,
     SysUtils,
     DOM,
     u_xml;

type TXMLPluginType = class(TDOMElement)
     private
        function Get_Vendor: AnsiString;
     protected
        function Get_Name: AnsiString;
        function Get_Type_: AnsiString;
        function Get_Description: AnsiString;
        function Get_Url: AnsiString;
     public
        property Name: AnsiString read Get_Name;
        property Vendor : AnsiString read Get_Vendor;
        property Type_: AnsiString read Get_Type_;
        property Description: AnsiString read Get_Description;
        property Url: AnsiString read Get_Url;
     end;

     TXMLLocationType = class(TDOMElement)
     protected
        function Get_Url: AnsiString;
     published
        property Url: AnsiString read Get_Url;
     end;

     TXMLLocationsType = specialize TXMLElementList<TXMLLocationType>;
     TXMLPluginsType = specialize TXMLElementList<TXMLPluginType>;
     TXMLPluginsFile = class(TXMLPluginsType)
     private
        fLocations : TXMLLocationsType;
        function Get_Version: AnsiString;
     public
        constructor Create(ANode: TDOMNode); overload;
     published
        property Version: AnsiString read Get_Version;
        property Locations: TXMLLocationsType read fLocations;
     end;

implementation //=========================================================================
uses XMLRead,
     StrUtils;

// TXMLLocationType ======================================================================
function TXMLLocationType.Get_Url: AnsiString;
begin Result := GetAttribute(K_XML_STR_Url);            end;

// TXMLPluginType ========================================================================
function TXMLPluginType.Get_Vendor: AnsiString;
begin Result := AnsiLowerCase(ExtractWord(1,Name,[' '])); end;

function TXMLPluginType.Get_Description: AnsiString;
begin Result := GetAttribute(K_XML_STR_Description);    end;

function TXMLPluginType.Get_Url: AnsiString;
begin Result := GetAttribute(K_XML_STR_Url);            end;

function TXMLPluginType.Get_Type_: AnsiString;
begin Result := GetAttribute(K_XML_STR_Type);           end;

function TXMLPluginType.Get_Name: AnsiString;
begin Result := GetAttribute(K_XML_STR_Name);           end;

// TXMLPluginsFile =======================================================================
function TXMLPluginsFile.Get_Version: AnsiString;
begin result := FNode.Attributes.GetNamedItem(K_XML_STR_Version).NodeValue; end;

constructor TXMLPluginsFile.Create(ANode: TDOMNode);
begin
   inherited Create(aNode, K_XML_STR_Plugin);
   fLocations := TXMLLocationsType.Create(aNode, K_XML_STR_Location);
end;

end.

