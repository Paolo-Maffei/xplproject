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
 0.97 : Usage of u_xml_xpldeterminator for read/write to xml format
 0.98 : Removed user interface function to u_xpl_message_gui to enable console apps
        Introduced usage of u_xpl_udp_socket_client
 0.99 : Modified due to schema move from Body to Header
 1.00 : Added system variable handling
        Ripped off fSocket and sending capabilities from TxPLMessage object, moved
        to dedicated TxPLSender object
 }
{$mode objfpc}{$H+}

interface

uses classes,
     DOM,
     uxPLHeader,
     uxPLAddress,
     uxPLMsgBody,
     uxPLSchema,
     uxPLConst,
     u_xml_xpldeterminator,
     u_xml_xplplugin;

type

     { TxPLMessage }

     TxPLMessage = class(TComponent)
     private
        fHeader   : TxPLHeader;
        fBody     : TxPLMsgBody;
        fName     : string;
        fDescription : string;

        function GetRawXPL: string;
        procedure SetRawXPL(const AValue: string);

     public
        property Header      : TxPLHeader        read fHeader;
        property Body        : TxPLMsgBody       read fBody;
        property RawXPL      : string            read GetRawXPL        write SetRawXPL        ;
        property MessageType : string            read fHeader.fMsgType write fHeader.fMsgType ;
        property Source      : TxPLAddress       read fHeader.fSource  write fHeader.fSource  ;
        property Target      : TxPLTargetAddress read fHeader.fTarget  write fHeader.fTarget  ;
        property Schema      : TxPLSchema        read fHeader.fSchema  write fHeader.fSchema  ;
        property Name        : string            read fName            write fName            ;
        property Description : string            read fDescription     write fDescription     ;

        procedure ResetValues;

        constructor create(const aRawxPL : string = ''); overload;
        destructor  Destroy; override;
        procedure   Assign(const aMessage : TxPLMessage); overload;

        function SourceFilterTag : tsFilter; // Return a message like a filter string
        function TargetFilterTag : tsFilter;
        function IsValid : boolean;
        function ElementByName(const anItem : string) : string;
        function ProcessedxPL : string;

        function  LoadFromFile(aFileName : string) : boolean;
        procedure SaveToFile(aFileName : string);

        function  WriteToXML(aParent : TDOMNode; aDoc : TXMLDocument): TXMLxplActionType;
        procedure ReadFromXML(const aCom : TXMLActionsType); overload;
        procedure ReadFromXML(const aCom : TXMLCommandType); overload;

        procedure Format_HbeatApp   (const aInterval : string; const aPort : string; const aIP : string);
        procedure Format_SensorBasic(const aDevice : string; const aType : string; const aCurrent : string);
     end;

implementation { ==============================================================}
Uses SysUtils,
     uRegExpr,
     cStrings,
     XMLRead,
     XMLWrite;

// TxPLMessage =================================================================
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
   Header.Destroy;
   Body.Destroy;
end;

procedure TxPLMessage.Assign(const aMessage: TxPLMessage);
begin
  Header.Assign(aMessage.Header);
  Body.Assign(aMessage.Body);
end;


function TxPLMessage.SourceFilterTag: tsFilter;  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
begin
   result := Format(K_FMT_FILTER,[Header.MessageType,Source.FilterTag,Schema.Tag]);
end;

function TxPLMessage.TargetFilterTag: tsFilter;  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
begin
   result := Format(K_FMT_FILTER,[Header.MessageType,Target.FilterTag,Schema.Tag]);
end;


function TxPLMessage.GetRawXPL: string;
begin
   result := Header.RawxPL;
   result += Body.RawxPL;
//   if IsValid then
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

function TxPLMessage.ProcessedxPL: string;
begin
   result := RawxPL;
   if AnsiPos('{SYS::', result) = 0 then exit;                                  // Avoid to search the needle if no one present

   result := StrReplace('{SYS::TIMESTAMP}', FormatDateTime('yyyymmddhhnnss', now), result);
   result := StrReplace('{SYS::DATE_YMD}' , FormatDateTime('yyyy/mm/dd'    , now), result);
   result := StrReplace('{SYS::DATE_UK}'  , FormatDateTime('dd/mm/yyyy'    , now), result);
   result := StrReplace('{SYS::DATE_US}'  , FormatDateTime('mm/dd/yyyy'    , now), result);
   result := StrReplace('{SYS::DATE}'     , FormatDateTime('dd/mm/yyyy'    , now), result);
   result := StrReplace('{SYS::DAY}'      , FormatDateTime('dd'            , now), result);
   result := StrReplace('{SYS::MONTH}'    , FormatDateTime('m'             , now), result);
   result := StrReplace('{SYS::YEAR}'     , FormatDateTime('yyyy'          , now), result);
   result := StrReplace('{SYS::TIME}'     , FormatDateTime('hh:nn:ss'      , now), result);
   result := StrReplace('{SYS::HOUR}'     , FormatDateTime('hh'            , now), result);
   result := StrReplace('{SYS::MINUTE}'   , FormatDateTime('nn'            , now), result);
   result := StrReplace('{SYS::SECOND}'   , FormatDateTime('ss'            , now), result);
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
    aCom : TXMLActionsType;
begin
   ResetValues;
   xdoc :=  TXMLDocument.Create;
   ReadXMLFile(xDoc,aFileName);

   aCom := TXMLActionsType.Create(xDoc);
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

function TxPLMessage.WriteToXML(aParent : TDOMNode; aDoc : TXMLDocument): TXMLxplActionType;
begin
   result := TXMLxplActionType(aDoc.AppendChild(TXMLOutput.Create(aDoc).xplactions.AddElement(Name)));
   result.Display_Name:=Description;
   result.ExecuteOrder:=Name;
   Header.WriteToXML(result);
   Body.WriteToXML(result);
end;

procedure TxPLMessage.ReadFromXML(const aCom : TXMLActionsType);
var action :TXMLxplActionType;
begin
   if aCom.Count<=0 then exit;
   action := aCom.Element[0];
   Description := action.Display_Name;
   Name := action.ExecuteOrder;
   Header.ReadFromXML(action);
   Body.ReadFromXML(action);
end;

procedure TxPLMessage.ReadFromXML(const aCom: TXMLCommandType);
begin
   Description := aCom.description;
   Name := aCom.name;
   Header.ReadFromXML(aCom);
   Body.ReadFromXML(aCom);
end;

procedure TxPLMessage.Format_HbeatApp(const aInterval: string; const aPort: string; const aIP: string);
begin
   Body.ResetAll;
   Schema.Tag := K_SCHEMA_HBEAT_APP;
   MessageType:= K_MSG_TYPE_STAT;
   Target.IsGeneric := True;
   Body.AddKeyValuePair(K_HBEAT_ME_INTERVAL,aInterval);
   Body.AddKeyValuePair(K_HBEAT_ME_PORT    ,aPort);
   Body.AddKeyValuePair(K_HBEAT_ME_REMOTEIP,aIP);
end;

procedure TxPLMessage.Format_SensorBasic(const aDevice: string; const aType: string; const aCurrent: string);
begin
   Body.ResetAll;
   Schema.Tag := K_SCHEMA_SENSOR_BASIC;
   Body.AddKeyValuePair('device' ,aDevice);
   Body.AddKeyValuePair('type'   ,aType);
   Body.AddKeyValuePair('current',aCurrent);
end;

end.
