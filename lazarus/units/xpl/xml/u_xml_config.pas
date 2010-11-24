unit u_xml_config;

{$mode objfpc}{$H+}

interface

uses Classes,
     SysUtils,
     DOM,
     u_xml,
     u_xml_xplplugin;

type

{ TXMLxplconfigFile }
     TXMLLocalsType = specialize TXMLElementList<TDOMElement>;

     TXMLxplconfigFile = class(TXMLConfigItemsType)
     private
       function Get_LocalData: TXMLLocalsType;
     protected
        fFileName    : AnsiString;
        fDoc         : TXMLDocument;
     public
        constructor Create(const aFileName : string); overload;
        destructor  Destroy; override;
        procedure   Save;
     published
        property LocalData : TXMLLocalsType read Get_LocalData;
        property Document  : TXMLDocument   read fDoc;
     end;

implementation { TXMLxplconfigType }
uses XMLRead,
     XMLWrite;

function TXMLxplconfigFile.Get_LocalData: TXMLLocalsType;
begin
   result := TXMLLocalsType.Create(fDoc.DocumentElement.FindNode('appdata'), 'localdata','id');
end;

constructor TXMLxplconfigFile.Create(const aFileName: string);
var aNode : TDOMNode;
begin
   fFileName := aFileName;
   fDoc := TXMLDocument.Create;
   if not FileExists(fFileName) then begin
      aNode := fDoc.AppendChild(fDoc.CreateElement('config'));
      aNode.AppendChild(fDoc.CreateElement('appdata'));
      aNode.AppendChild(fDoc.CreateElement('configdata'));
      WriteXMLFile(fDoc,fFileName);
   end;
   ReadXMLFile(fDoc,fFileName);
   inherited Create(fdoc.DocumentElement.FindNode('configdata'), K_XML_STR_ConfigItem, K_XML_STR_NAME);
end;

destructor TXMLxplconfigFile.Destroy;
begin
   Save;
   if Assigned(fDoc) then fDoc.Destroy;
   inherited Destroy;
end;

procedure TXMLxplconfigFile.Save;
begin
   WriteXML(Document,fFileName);
end;

end.

