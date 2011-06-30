unit u_xpl_message;
{==============================================================================
  UnitName      = uxplmessage
  UnitDesc      = xPL Message management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.95 : Name and Description fields added
 0.98 : Removed user interface function to u_xpl_message_gui to enable console apps
        Introduced usage of u_xpl_udp_socket_client
 0.99 : Modified due to schema move from Body to Header
 1.00 : Added system variable handling
        Ripped off fSocket and sending capabilities from TxPLMessage object, moved
        to dedicated TxPLSender object
 1.01 : Added Strings property
 }
{$mode objfpc}{$H+}

interface

uses classes,
     u_xPL_Custom_Message,
     u_xPL_Header,
     u_xPL_Address,
     u_xpl_schema,
     u_xPL_Body,
     uxPLConst,
     u_xml_plugins,
     u_xml_xplplugin;

type { TxPLMessage ===========================================================}

     TxPLMessage = class(TxPLCustomMessage)
     private
        fMsgName      : string;
     protected
        procedure OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); virtual;
     public
        function ElementByName(const anItem : string) : string;
        function ProcessedxPL : string;

        procedure LoadFromFile(aFileName : string);
        procedure SaveToFile(aFileName : string);

        //procedure ReadFromXML(const aCom : TXMLCommandType); overload;         // Reads a message from vendor plugin file
        procedure ReadFromJSON(const aCom : TCommandType);

        procedure Format_HbeatApp   (const aInterval : integer; const aPort : string; const aIP : string);
        procedure Format_SensorBasic(const aDevice : string; const aType : string; const aCurrent : string);
     published
        property MsgName      : string      read fMsgName      write fMsgName     ;
     end;

implementation { ==============================================================}
Uses SysUtils
     , uRegExpr
     , cStrings
     , LResources
     , u_xpl_common
     ;

// TxPLMessage =================================================================
function TxPLMessage.ElementByName(const anItem: string): string;
begin
   if anItem = 'Schema' then result := Schema.RawxPL;
   if anItem = 'Source' then result := Source.RawxPL;
   if anItem = 'Target' then result := Target.RawxPL;
   if anItem = 'Type'   then result := MsgTypeToStr(MessageType);
   if anItem = 'Body'   then result := Body.RawxPL;
   if anItem = 'TimeStamp' then result := DateTimeToStr(TimeStamp);
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

procedure TxPLMessage.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
  if CompareText(AClassName, 'TxPLMessage') = 0 then ComponentClass := TxPLMessage
end;

procedure TxPLMessage.SaveToFile(aFileName: string);
var AStream: TMemoryStream;
begin
  AStream:=TMemoryStream.Create;
  try
    WriteComponentAsTextToStream(AStream, self);
    aStream.SaveToFile(aFileName);
  finally
    AStream.Free;
  end;
end;

procedure TxPLMessage.LoadFromFile(aFileName: string);
var aStream : TMemoryStream;
begin
   aStream := TMemoryStream.Create;
   try
      aStream.LoadFromFile(aFileName);
      ReadComponentFromTextStream(aStream,TComponent(self),@OnFindClass, self);
   finally
      aStream.Free;
   end;
end;

//procedure TxPLMessage.ReadFromXML(const aCom: TXMLCommandType);                 // Reads a message from a vendor file
//var i : integer;
//begin
//   ResetValues;
//   MsgName := aCom.name;
//   MessageType := StrToMsgType(K_MSG_TYPE_HEAD + aCom.msg_type);
//   Target.IsGeneric := true;
//   Schema.RawxPL := aCom.msg_schema;
//   for i := 0 to aCom.elements.Count-1 do
//       Body.AddKeyValuePairs([aCom.Elements[i].Name],[aCom.Elements[i].default_]);
//end;

procedure TxPLMessage.ReadFromJSON(const aCom: TCommandType);
//var i : integer;
var item : TCollectionItem;
begin
   ResetValues;
   MsgName := aCom.name;
   MessageType := StrToMsgType(K_MSG_TYPE_HEAD + aCom.msg_type);
   Target.IsGeneric := true;
   Schema.RawxPL := aCom.msg_schema;

   for item in aCom.Elements do
       Body.AddKeyValuePairs([TElementType(item).Name],[TElementType(item).default_]);
end;

procedure TxPLMessage.Format_HbeatApp(const aInterval: integer; const aPort: string; const aIP: string);
begin
   Body.ResetValues;
   Schema.Assign(Schema_HBeatApp);
   MessageType:= stat;
   Target.IsGeneric := True;
   Body.AddKeyValuePairs([K_HBEAT_ME_INTERVAL,K_HBEAT_ME_PORT,K_HBEAT_ME_REMOTEIP],[IntToStr(aInterval),aPort,aIP]);
end;

procedure TxPLMessage.Format_SensorBasic(const aDevice: string; const aType: string; const aCurrent: string);
begin
   Body.ResetValues;
   Schema.RawxPL := K_SCHEMA_SENSOR_BASIC;
   Body.AddKeyValuePairs(['device','type','current'],[aDevice,aType,aCurrent]);
end;

end.
