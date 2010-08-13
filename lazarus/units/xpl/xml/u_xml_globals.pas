unit u_xml_globals;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM;

type

{ TXMLglobalType }

TXMLglobalType = class(TDOMElement)
private
  function Get_Expires: AnsiString;
  function Get_LastUpdate: AnsiString;
  function Get_Name: AnsiString;
  function Get_Value: AnsiString;
     protected
     public
        property name : AnsiString read Get_Name;
        property Value : AnsiString read Get_Value;
        property LastUpdate : AnsiString read Get_LastUpdate;
        property Expires : AnsiString read Get_Expires;
     end;

     TXMLglobalsType = class(TDOMElementList)
     private
        function Get_global(Index: Integer): TXMLglobalType;
     public
        constructor Create(ANode: TDOMNode); overload;
        property global[Index: Integer]: TXMLglobalType read Get_global ; default;
     end;

var globalsfile : TXMLglobalsType;

implementation //=========================================================================
uses XMLRead;
var document : TXMLDocument;
//========================================================================================


{ TXMLglobalType }




{ TXMLglobalsType }

function TXMLglobalsType.Get_global(Index: Integer): TXMLglobalType;
begin
  Result := TXMLglobalType(Item[Index]);
end;



constructor TXMLglobalsType.Create(ANode: TDOMNode);
begin
   inherited Create(aNode,'global');
end;

// Unit initialization ===================================================================

{ TXMLglobalType }

function TXMLglobalType.Get_Expires: AnsiString;
begin Result := Attributes.GetNamedItem('expires').NodeValue; end;

function TXMLglobalType.Get_LastUpdate: AnsiString;
begin Result := Attributes.GetNamedItem('lastupdate').NodeValue; end;

function TXMLglobalType.Get_Name: AnsiString;
begin Result := Attributes.GetNamedItem('name').NodeValue; end;

function TXMLglobalType.Get_Value: AnsiString;
begin Result := Attributes.GetNamedItem('value').NodeValue; end;

initialization
   document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\Program Files\xPL\xPLHal 2.0 for Windows\data\object_cache.xml');
   globalsfile := TXMLglobalsType.Create(Document.FirstChild);

finalization
   globalsfile.destroy;
   document.destroy;

end.

