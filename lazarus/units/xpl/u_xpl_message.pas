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

uses classes,
     u_xPL_Custom_Message,
     u_xPL_Header,
     u_xPL_Address,
     u_xpl_schema,
     u_xPL_Body,
//     uxPLConst,
     u_xml_plugins;

type { TxPLMessage ===========================================================}

     TxPLMessage = class(TxPLCustomMessage)
     private
        fMsgName      : string;
     public
        function ElementByName(const anItem : string) : string;
        function ProcessedxPL : string;

        procedure LoadFromFile(aFileName : string);
        procedure SaveToFile(aFileName : string);

        procedure ReadFromJSON(const aCom : TCommandType);

        procedure Format_HbeatApp   (const aInterval : integer; const aPort : string; const aIP : string);
        procedure Format_SensorBasic(const aDevice : string; const aType : string; const aCurrent : string);
     published
        property MsgName      : string      read fMsgName      write fMsgName     ;
     end;

const K_KEYWORDS : Array[0..11] of String = ( 'TIMESTAMP','DATE_YMD','DATE_UK','DATE_US','DATE','DAY',
                                              'MONTH','YEAR','TIME','HOUR','MINUTE','SECOND');

implementation { ==============================================================}
Uses SysUtils
     , uRegExpr
     , StrUtils
     , JclStrings
     , u_xpl_common
     , uxPLConst
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
const K_FORMATS  : Array[0..11] of String = ( 'yyyymmddhhnnss','yyyy/mm/dd','dd/mm/yyyy','mm/dd/yyyy','dd','dd/mm/yyyy',
                                              'm','yyyy','hh:nn:ss','hh','nn','ss');
      K_RE_VARIABLE    = '{[s|S][y|Y][s|S]::(.*?)}';
var rep : string;
    bLoop   : boolean;
begin
   result := RawxPL;
   with TRegExpr.Create do begin
        Expression := K_RE_VARIABLE;
        bLoop := Exec(Result);
        while bLoop do begin
              rep := K_FORMATS[AnsiIndexStr(AnsiUpperCase(Match[1]),K_KEYWORDS)];
              result := StringReplace( result, Match[0], FormatDateTime(rep,now),[rfReplaceAll,rfIgnoreCase]);
              bLoop := ExecNext;
        end;
        Free;
   end;
end;

procedure TxPLMessage.SaveToFile(aFileName: string);
begin
   StreamObjectToFile(aFileName, self);
end;

procedure TxPLMessage.LoadFromFile(aFileName: string);
begin
   ReadObjectFromFile(aFileName, self);
end;

procedure TxPLMessage.ReadFromJSON(const aCom: TCommandType);
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
   Schema.RawxPL := 'sensor.basic';
   Body.AddKeyValuePairs(['device','type','current'],[aDevice,aType,aCurrent]);
end;

end.
