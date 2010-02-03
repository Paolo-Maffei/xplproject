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
 }
{$mode objfpc}{$H+}

interface

uses classes,uxPLMsgHeader, uxPLAddress, uxPLMsgBody,IdUDPClient, uxPLSchema, DOM, uxPLConst;

type

  TButtonOption = (
                boLoad,
                boSave,
                boCopy,
                boSend);
  TButtonOptions = set of TButtonOption;

{ TxPLMessage }

TxPLMessage = class(TComponent)
     private
        fHeader   : TxPLMsgHeader;
        fBody     : TxPLMsgBody;
        fSocket   : TIdUDPClient;
        fName     : string;
        fDescription : string;

        function GetRawXPL: string;
        procedure SetMessageType(const AValue: TxPLMessageType);
        procedure SetRawXPL(const AValue: string);
     public
        property Header   : TxPLMsgHeader read fHeader;
        property Body     : TxPLMsgBody   read fBody;
        property RawXPL   : string read GetRawXPL write SetRawXPL;

        // Shortcut properties ==================================

        property MessageType : TxPLMessageType   read fHeader.fMsgType write SetMessageType ;
        property Source      : TxPLAddress       read fHeader.fSource  write fHeader.fSource  ;
        property Target      : TxPLTargetAddress read fHeader.fTarget  write fHeader.fTarget  ;
        property Schema      : TxPLSchema        read fBody.fSchema    write fBody.fSchema;
        property Name        : string            read fName            write fName;
        property Description : string            read fDescription     write fDescription;
        // ======================================================

        procedure Send;
        procedure ResetValues;

        constructor create(const aRawxPL : string = '');
        destructor  Destroy; override;
        procedure   Assign(const aMessage : TxPLMessage); overload;
        function    Edit : boolean;     dynamic;
        procedure   Show(options : TButtonOptions);
        procedure   ShowForEdit(options : TButtonOptions);

        function    SelectFile : boolean;

        function FilterTag : string; // Return a message like a filter string
        function IsValid : boolean;
        function ElementByName(const anItem : string) : string;

        function  LoadFromFile(aFileName : string) : boolean;
        procedure SaveToFile(aFileName : string);

        function  WriteToXML(aParent : TDOMNode; aDoc : TXMLDocument): TDOMNode;
        procedure ReadFromXML(const aCom : TDOMNode);
     end;

implementation { ==============================================================}
Uses SysUtils, XMLWrite, XMLRead, Regexpr, cStrings, uxPLSettings, frm_xPLMessage, Controls, v_xplmsg_opendialog;

constructor TxPLMessage.Create(const aRawxPL : string = '');
begin
     fHeader   := TxPLMsgHeader.Create;
     fBody     := TxPLMsgBody.Create;
     ResetValues;
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

procedure TxPLMessage.ShowForEdit(options : TButtonOptions);
var aForm : TfrmxPLMessage;
begin
     aForm := TfrmxPLMessage.Create(self);
     aForm.buttonOptions := options;
     aForm.mmoMessage.ReadOnly := false;
     aForm.Show;
end;

function TxPLMessage.Edit : boolean;
var aForm : TfrmxPLMessage;
begin
    aForm := TfrmxPLMessage.Create(self);
    result := (aForm.ShowModal = mrOk);
    aForm.Destroy;
end;

procedure TxPLMessage.Show(options : TButtonOptions);
var aForm : TfrmxPLMessage;
begin
    aForm := TfrmxPLMessage.Create(self);
    aForm.buttonOptions := options;
    aForm.Show;
end;

function TxPLMessage.SelectFile: boolean;
var OpenDialog: TxPLMsgOpenDialog;
begin
     OpenDialog:=TxPLMsgOpenDialog.create(self);
     result := OpenDialog.Execute;
     if result then LoadFromFile(OpenDialog.FileName);
     OpenDialog.Destroy;
end;

function TxPLMessage.FilterTag: string;  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
begin
     result := Header.MessageTypeAsString + '.' +
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

procedure TxPLMessage.SetMessageType(const AValue: TxPLMessageType);
begin
  if fHeader.MessageType = aValue then exit;
  if aValue = xpl_mtStat then Target.Tag := '*';                   // Rule of XPL : xpl-stat are always broadcast
  fHeader.MessageType := aValue;
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
   if anItem = 'Type'   then result := Header.MessageTypeAsString;
end;

procedure TxPLMessage.Send;
var Settings : TxPLSettings;
begin
   if not Assigned(fSocket) then begin                           // The socket is created only
      Settings := TxPLSettings.Create(self);
      fSocket   := TIdUDPClient.Create;                          // if needed to avoid waste space
      fSocket.BroadcastEnabled := True;                          // speed and time at runtime
      fSocket.Host := Settings.BroadCastAddress;
      fSocket.Port := XPL_UDP_BASE_PORT;
      Settings.Free;
   end;
   fSocket.Send(RawXPL);
end;

procedure TxPLMessage.SetRawXPL(const AValue: string);
begin
  with TRegExpr.Create do try
     Expression := '\A(.+})(.+})';
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
