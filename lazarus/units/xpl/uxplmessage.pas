unit uxplmessage;
{==============================================================================
  UnitName      = uxplmessage
  UnitVersion   = 0.91
  UnitDesc      = xPL Message management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Added XMLWrite and read methods
 0.95 : Modified to XML read/write com²patible with xml files from other vendors
        Name and Description fields added
 0.96 : Usage of uxPLConst
 0.97 : Removed user interface function to u_xpl_message_gui to enable console apps
        Introduced usage of u_xpl_udp_socket_client
 }
{$mode objfpc}{$H+}

interface

uses classes,uxPLHeader, uxPLAddress, uxPLMsgBody,u_xpl_udp_socket, uxPLSchema, DOM, uxPLConst;

type


{ TxPLMessage }

TxPLMessage = class(TComponent)
     private
        fHeader   : TxPLHeader;
        fBody     : TxPLMsgBody;
        fSocket   : TxPLUDPClient;
        fName     : string;
        fDescription : string;

        function GetRawXPL: string;

        procedure SetRawXPL(const AValue: string);
     public
        property Header   : TxPLHeader read fHeader;
        property Body     : TxPLMsgBody   read fBody;
        property RawXPL   : string read GetRawXPL write SetRawXPL;

        // Shortcut properties ==================================

        property MessageType : string            read fHeader.fMsgType write fHeader.fMsgType ;
        property Source      : TxPLAddress       read fHeader.fSource  write fHeader.fSource  ;
        property Target      : TxPLTargetAddress read fHeader.fTarget  write fHeader.fTarget  ;
        property Schema      : TxPLSchema        read fBody.fSchema    write fBody.fSchema;
        property Name        : string            read fName            write fName;
        property Description : string            read fDescription     write fDescription;
        // ======================================================

        procedure Send;
        procedure ResetValues;

        constructor create(const aRawxPL : string = ''); overload;
        destructor  Destroy; override;
        procedure   Assign(const aMessage : TxPLMessage); overload;
        function FilterTag : tsFilter; // Return a message like a filter string
        function IsValid : boolean;
        function ElementByName(const anItem : string) : string;

        function  LoadFromFile(aFileName : string) : boolean;
        procedure SaveToFile(aFileName : string);

        function  WriteToXML(aParent : TDOMNode; aDoc : TXMLDocument): TDOMNode;
        procedure ReadFromXML(const aCom : TDOMNode);
     end;

implementation { ==============================================================}
Uses SysUtils, FileUtil,XMLWrite, XMLRead, cStrings, uxPLSettings, uRegExpr;

constructor TxPLMessage.Create(const aRawxPL : string = '');
begin
     fHeader   := TxPLHeader.Create;
     fBody     := TxPLMsgBody.Create;
     if aRawxPL<>'' then RawXPL := aRawXPL;
end;

procedure TxPLMessage.ResetValues;
begin
     Header.ResetValues;
     Body.ResetValues;
end;

destructor TxPLMessage.Destroy;
begin
     if Assigned(fSocket) then fSocket.Destroy;
     Header.Destroy;
     Body.Destroy;
end;

procedure TxPLMessage.Assign(const aMessage: TxPLMessage);
begin
  Header.Assign(aMessage.Header);
  Body.Assign(aMessage.Body);
end;

function TxPLMessage.FilterTag: tsFilter;  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
begin
   result := Header.MessageType + '.' +
             Source.FilterTag + '.' +
             Schema.Tag;
end;

function TxPLMessage.GetRawXPL: string;
begin
   result := Header.RawxPL;
   result += Body.RawxPL;
//   if (Header.IsValid and Body.IsValid) then
//        result := Header.RawxPL + Body.RawxPL
//   else
//        Raise Exception.Create('Unable to build valid xPL from supplied fields : ' + Header.Rawxpl + Body.Rawxpl );
end;

function TxPLMessage.IsValid: boolean;
begin
   result := (Header.IsValid) and (Body.IsValid)
end;

function TxPLMessage.ElementByName(const anItem: string): string;
begin
   if anItem = 'Schema' then result := Schema.Tag;
   if anItem = 'Source' then result := Source.Tag;
   if anItem = 'Target' then result := Target.Tag;
   if anItem = 'Type'   then result := Header.MessageType;
end;

procedure TxPLMessage.Send;
var Settings : TxPLSettings;
begin
   if not Assigned(fSocket) then begin                           // The socket is created only
      Settings := TxPLSettings.Create(self);                     // if needed to avoid waste space
      fSocket   := TxPLUDPClient.Create(Settings.BroadCastAddress);
//      fSocket.BroadcastEnabled := True;                          // speed and time at runtime
//      fSocket.Host := ;
//      fSocket.Port := XPL_UDP_BASE_PORT;
      Settings.Free;
   end;
   fSocket.Send(RawXPL);
end;

procedure TxPLMessage.SetRawXPL(const AValue: string);
begin
  with TRegExpr.Create do try
     Expression := K_RE_MESSAGE;
     if Exec (StrRemoveChar(aValue,#13)) then begin
        Header.RawXPL := Match[1];
        Body.RawXPL   := Match[2];
     end;
     finally Free;
  end;
end;

function TxPLMessage.LoadFromFile(aFileName: string): boolean;
var xdoc : TXMLDocument;
    aCom : TDomNode;
begin
     ResetValues;
     xdoc :=  TXMLDocument.Create;
     ReadXMLFile(xDoc,aFileName);

     aCom := xDoc.FindNode('command');
     result := (aCom<>nil);

     if result then ReadFromXML(aCom);
     xdoc.Free;
end;

procedure TxPLMessage.SaveToFile(aFileName: string);
var xdoc : TXMLDocument;
begin
     xdoc :=  TXMLDocument.Create;
     WriteToXML(nil,xDoc);
     writeXMLFile(xdoc,aFileName);
     xdoc.Free;
end;

function TxPLMessage.WriteToXML(aParent : TDOMNode; aDoc : TXMLDocument): TDOMNode;
begin
     result := adoc.CreateElement('command');
     aDoc.AppendChild(result);
     TDOMElement(result).SetAttribute('name',Name);
     TDOMElement(result).SetAttribute('description',Description);

     Header.WriteToXML(result);
     Body.WriteToXML(result, aDoc);
end;

procedure TxPLMessage.ReadFromXML(const aCom : TDOMNode);
begin
     Description := TDOMElement(aCom).GetAttribute('description');
     Name := TDOMElement(aCom).GetAttribute('name');
     Header.ReadFromXML(aCom);
     Body.ReadFromXML(aCom);
end;

end.
