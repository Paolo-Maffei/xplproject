unit u_xml_iso_3166;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM, u_xml;

type TXMLISO3166Type = class(TDOMElement)
        function Get_alpha_2_code: AnsiString;
        function Get_alpha_3_code: AnsiString;
        function Get_name: AnsiString;
        function Get_numeric_code: AnsiString;
        function Get_official_name: ansistring;
     public
        property alpha_2_code : AnsiString read Get_alpha_2_code;
        property alpha_3_code : AnsiString read Get_alpha_3_code;
        property numeric_code : AnsiString read Get_numeric_code;
        property name : AnsiString read Get_name;
        property official_name : ansistring read Get_official_name;
     end;
     TXMLISO3166sType = specialize TXMLElementList<TXMLISO3166Type>;

var ISO3166File : TXMLISO3166sType;

implementation //=========================================================================
uses XMLRead,
     uxPLConst;

var  document : TXMLDocument;
     aNode    : TDOMNode;

const K_Alpha_2_code  = 'alpha_2_code';
      K_Alpha_3_code  = 'alpha_3_code';
      K_Name          = 'name';
      K_Numeric_code  = 'numeric_code';
      K_Official_nam  = 'official_name';
      K_ISO_FileName  = 'iso_3166' + K_FEXT_XML;                                // Choosen at the time to locate the file in the EXE's directory
      K_Iso_3166_ent  = 'iso_3166_entries';
      K_Iso_3166_ent2 = 'iso_3166_entry';

//========================================================================================
function TXMLISO3166Type.Get_alpha_2_code: AnsiString;
begin
   Result := Attributes.GetNamedItem(K_Alpha_2_code).NodeValue;
end;

function TXMLISO3166Type.Get_alpha_3_code: AnsiString;
begin
   Result := Attributes.GetNamedItem(K_Alpha_3_code).NodeValue;
end;

function TXMLISO3166Type.Get_name: AnsiString;
begin
   Result := Attributes.GetNamedItem(K_Name).NodeValue;
end;

function TXMLISO3166Type.Get_numeric_code: AnsiString;
begin
   Result := Attributes.GetNamedItem(K_Numeric_code).NodeValue;
end;

function TXMLISO3166Type.Get_official_name: ansistring;
begin
   Result := Attributes.GetNamedItem(K_Official_nam).NodeValue;
end;

initialization
   document := TXMLDocument.Create;
   ReadXMLFile(document, K_ISO_FileName);

   aNode := Document.FirstChild;
   while aNode.NodeName <> K_Iso_3166_ent do begin
         aNode := Document.FirstChild.NextSibling;
   end;
   ISO3166File := TXMLISO3166sType.Create(aNode, K_Iso_3166_ent2,K_Alpha_2_code);

finalization
   aNode.Destroy;
   ISO3166File.destroy;
   document.destroy;

end.

