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

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses u_xpl_custom_message,
     u_xml_plugins;

type // TxPLMessage ===========================================================
     TxPLMessage = class(TxPLCustomMessage)
     private
        fMsgName : string;
     public
        function  ProcessedxPL : string;
        function  ElementByName(const aItem : string) : string;
        procedure ReadFromJSON (const aCom : TCommandType);

     published
        property MsgName : string read fMsgName write fMsgName;
     end;

implementation // =============================================================
Uses Classes
     , SysUtils
     , u_xpl_common
     , u_xpl_processor
     ;

// TxPLMessage ================================================================
function TxPLMessage.ElementByName(const aItem: string): string;
begin
   if aItem = 'Schema' then result := Schema.RawxPL;
   if aItem = 'Source' then result := Source.RawxPL;
   if aItem = 'Target' then result := Target.RawxPL;
   if aItem = 'Type'   then result := MsgTypeAsStr;
   if aItem = 'Body'   then result := Body.RawxPL;
   if aItem = 'TimeStamp' then result := DateTimeToStr(TimeStamp);
end;

function TxPLMessage.ProcessedxPL: string;
begin
   with TxPLProcessor.Create do begin
        Result := Transform(Source,RawxPL);
        Free;
   end;
end;

procedure TxPLMessage.ReadFromJSON(const aCom: TCommandType);
var item : TCollectionItem;
begin
   ResetValues;
   MsgName := aCom.name;
   MsgTypeAsStr := K_MSG_TYPE_HEAD + aCom.msg_type;
   Target.IsGeneric := true;
   source.RawxPL := TCommandsType(aCom.Collection).DV + '.instance' ;
   Schema.RawxPL := aCom.msg_schema;

   for item in aCom.Elements do
       Body.AddKeyValuePairs([TElementType(item).Name],[TElementType(item).default_]);
end;

end.