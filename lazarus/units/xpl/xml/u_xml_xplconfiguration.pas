unit u_xml_xplconfiguration;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, u_xml, DOM;

type

     { TXMLConfItemType }

     TXMLConfItemType = class(T_clinique_DOMElement)
     private
       function Get_Value: AnsiString;
       function Get_Key: AnsiString;
     published
        property key : AnsiString read Get_Key;
        property value : AnsiString read Get_Value;
     end;
     TXMLConfItemsType = specialize TXMLElementList<TXMLConfItemType>;

     TXMLxplConfigurationType = specialize TXMLElementList<TXMLConfItemType>;

var xplconfigurationfile : TXMLxplConfigurationType;

implementation //=========================================================================
uses XMLRead;
var document : TXMLDocument;
aNode : TDOMNode;
//========================================================================================
function TXMLConfItemType.Get_Value: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Value).NodeValue; end;

function TXMLConfItemType.Get_Key: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Key).NodeValue; end;

initialization
   document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\Program Files\xPL\xPLHal 2.0 for Windows\xpl_xpl-xplhal2.instance.4.4.xml');

   aNode := Document.FirstChild;
   while aNode.NodeName <> K_XML_STR_XplConfigura do begin
         aNode := Document.FirstChild.NextSibling;
   end;
   xplConfigurationFile := TXMLxplConfigurationType.Create(aNode,K_XML_STR_ConfigItem);

finalization
   xplconfigurationfile.destroy;
   document.destroy;

end.

