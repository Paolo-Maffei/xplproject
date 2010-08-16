unit u_xml_globals;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM,u_xml;

type TXMLglobalType = class(TDOMElement)
     private
        function Get_Expires: AnsiString;
        function Get_LastUpdate: AnsiString;
        function Get_Name: AnsiString;
        function Get_Value: AnsiString;
     public
        property Name : AnsiString read Get_Name;
        property Value : AnsiString read Get_Value;
        property LastUpdate : AnsiString read Get_LastUpdate;
        property Expires : AnsiString read Get_Expires;
     end;

     TXMLGlobalsType = specialize TXMLElementList<TXMLglobalType>;

var globalsfile : TXMLglobalsType;

implementation //=========================================================================
uses XMLRead;
var document : TXMLDocument;
// TXMLglobalType ========================================================================
function TXMLglobalType.Get_Expires: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Expires).NodeValue; end;

function TXMLglobalType.Get_LastUpdate: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Lastupdate).NodeValue; end;

function TXMLglobalType.Get_Name: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

function TXMLglobalType.Get_Value: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Value).NodeValue; end;

// Unit initialization ===================================================================
initialization
   document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\Program Files\xPL\xPLHal 2.0 for Windows\data\object_cache.xml');
   globalsfile := TXMLglobalsType.Create(Document.FirstChild, K_XML_STR_Global);

finalization
   globalsfile.destroy;
   document.destroy;

end.

