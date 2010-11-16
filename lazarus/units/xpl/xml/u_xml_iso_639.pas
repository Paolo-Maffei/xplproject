unit u_xml_iso_639;

{$mode objfpc}{$H+}

interface

uses Classes,
     SysUtils,
     DOM,
     u_xml;

type TXMLISO639Type = class(TDOMElement)
     private
        function Get_iso_639_2B_code: AnsiString;
        function Get_iso_639_2T_code: AnsiString;
        function Get_name: AnsiString;
        function Get_iso_639_1_code: AnsiString;
     public
        property iso_639_2B_code : AnsiString read Get_iso_639_2B_code;
        property iso_639_2T_code : AnsiString read Get_iso_639_2T_code;
        property iso_639_1_code  : AnsiString read Get_iso_639_1_code;
        property name : AnsiString read Get_name;
     end;
     TXMLISO639sType = specialize TXMLElementList<TXMLISO639Type>;

var ISO639File : TXMLISO639sType;

implementation //=========================================================================
uses XMLRead,
     uxPLConst;

var  document : TXMLDocument;
     aNode    : TDOMNode;

const K_Iso_639_2B_c    = 'iso_639_2B_code';
      K_Iso_639_2T_c    = 'iso_639_2T_code';
      K_Iso_639_1_co    = 'iso_639_1_code';
      K_Name            = 'name';
      K_ISO_FileName    = 'iso_639' + K_FEXT_XML;                               // Choosen at the time to locate the file in the EXE's directory
      K_Iso_639_entries = 'iso_639_entries';
      K_Iso_639_entry   = 'iso_639_entry';

//========================================================================================
function TXMLISO639Type.Get_iso_639_2B_code: AnsiString;
begin
   Result := Attributes.GetNamedItem(K_Iso_639_2B_c).NodeValue;
end;

function TXMLISO639Type.Get_iso_639_2T_code: AnsiString;
begin
   Result := Attributes.GetNamedItem(K_Iso_639_2T_c).NodeValue;
end;

function TXMLISO639Type.Get_name: AnsiString;
begin
   Result := Attributes.GetNamedItem(K_Name).NodeValue;
end;

function TXMLISO639Type.Get_iso_639_1_code: AnsiString;
begin
   Result := Attributes.GetNamedItem(K_Iso_639_1_co).NodeValue;
end;

initialization
   document := TXMLDocument.Create;
   ReadXMLFile(document, K_ISO_FileName);

   aNode := Document.FirstChild;
   while aNode.NodeName <> K_Iso_639_entries do begin
         aNode := Document.FirstChild.NextSibling;
   end;
   ISO639File := TXMLISO639sType.Create(aNode, K_Iso_639_entry, K_Iso_639_1_co);

finalization
   aNode.Destroy;
   ISO639File.destroy;
   document.destroy;

end.

