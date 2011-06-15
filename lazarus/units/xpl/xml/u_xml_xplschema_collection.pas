unit u_xml_xplschema_collection;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, u_xml, DOM;

type

{ TXMLxplSchema_Collection }

     TXMLxplSchema_Collection = class(T_clinique_DOMElement)
     private
       function Get_Name: AnsiString;
       procedure Set_Name(const AValue: AnsiString);
     published
        property name : AnsiString read Get_Name write Set_Name;
     end;

     TXMLxplSchemas_Collection = specialize TXMLElementList<TXMLxplSchema_Collection>;

var xplSchema_collection : TXMLxplSchemas_Collection;

implementation //=========================================================================
uses XMLRead, XMLWrite;
var document : TXMLDocument;
aNode : TDOMNode;
//========================================================================================

{ TXMLSchema }

function TXMLxplSchema_Collection.Get_Name: AnsiString;
begin result := SafeFindNode(K_XML_STR_Name); end;

procedure TXMLxplSchema_Collection.Set_Name(const AValue: AnsiString);
begin
   if FindNode(K_XML_STR_Name) = nil then SafeAddNode(K_XML_STR_Name,aValue)
                                     else SafeChangeNode(K_XML_STR_Name,aValue);
end;

initialization
   document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\ProgramData\xPL\Plugins\xpl-schema-collection.xml');

   aNode := Document.FirstChild;
   while aNode.NodeName <> K_XML_STR_XplSchemaCol do begin
         aNode := Document.FirstChild.NextSibling;
   end;
   xplSchema_collection := TXMLxplSchemas_Collection.Create(aNode,K_XML_STR_XplSchema,'key');


finalization
   WriteXMLFile(document,'C:\ProgramData\xPL\Plugins\xpl-schema-collection.xml');
(*   xplSchema_collection.free;

   document.free;*)

end.

