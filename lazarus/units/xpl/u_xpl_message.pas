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
        function  ElementByName(const anItem : string) : string;
        procedure ReadFromJSON (const aCom : TCommandType);

     published
        property MsgName : string read fMsgName write fMsgName;
     end;

const K_KEYWORDS : Array[0..11] of String = ( 'TIMESTAMP','DATE_YMD','DATE_UK',
                                              'DATE_US','DATE','DAY', 'MONTH',
                                              'YEAR','TIME','HOUR','MINUTE','SECOND');

implementation // =============================================================
Uses Classes
     , SysUtils
     , StrUtils
     , u_xpl_common
     ;

// TxPLMessage ================================================================
function TxPLMessage.ElementByName(const anItem: string): string;
begin
   if anItem = 'Schema' then result := Schema.RawxPL;
   if anItem = 'Source' then result := Source.RawxPL;
   if anItem = 'Target' then result := Target.RawxPL;
   if anItem = 'Type'   then result := MsgTypeAsStr; //MsgTypeToStr(MessageType);
   if anItem = 'Body'   then result := Body.RawxPL;
   if anItem = 'TimeStamp' then result := DateTimeToStr(TimeStamp);
end;

function TxPLMessage.ProcessedxPL: string;
const K_FORMATS  : Array[0..11] of String = ( 'yyyymmddhhnnss','yyyy/mm/dd', 'dd/mm/yyyy',
                                              'mm/dd/yyyy','dd/mm/yyyy','dd', 'm',
                                              'yyyy', 'hh:nn:ss','hh','nn','ss');
var b,e : integer;
    constant, rep  : string;
begin
   result := AnsiReplaceStr(RawxPL, '{VDI}', source.RawxPL);
   result := AnsiReplaceStr(result, '{INSTANCE}', source.Instance);
   result := AnsiReplaceStr(result, '{DEVICE}', source.Device);
   result := AnsiReplaceStr(result, '{SCHEMA}', Schema.RawxPL);

   b := AnsiPos('{SYS::',result);
   while b<>0 do begin
      inc(b,6);
      e := PosEx('}',result, b);
      constant := Copy(result,b, e-b);
      rep := K_FORMATS[AnsiIndexStr(AnsiUpperCase(constant),K_KEYWORDS)];
      result := StringReplace( result, '{SYS::' + constant+'}', FormatDateTime(rep,now),[rfReplaceAll,rfIgnoreCase]);
      b := PosEx('{SYS::',result,b);
   end;

   //b := AnsiPos('{XPL::',result);               // Same to do with global variables for {xpl::globalname}
   //while b<>0 do begin
   //   inc(b,6);
   //   e := PosEx('}',result, b);
   //   constant := Copy(result,b, e-b);
   //    ...
   //   b := PosEx('{XPL::',result,b);
   //end;
end;

procedure TxPLMessage.ReadFromJSON(const aCom: TCommandType);
var item : TCollectionItem;
begin
   ResetValues;
   MsgName := aCom.name;
//   MessageType := StrToMsgType(K_MSG_TYPE_HEAD + aCom.msg_type);
   MsgTypeAsStr := K_MSG_TYPE_HEAD + aCom.msg_type;
   Target.IsGeneric := true;
   Schema.RawxPL := aCom.msg_schema;

   for item in aCom.Elements do
       Body.AddKeyValuePairs([TElementType(item).Name],[TElementType(item).default_]);
end;

end.
