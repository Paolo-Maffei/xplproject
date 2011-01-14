unit uxplmessage;
{==============================================================================
  UnitName      = uxplmessage
  UnitDesc      = xPL Message management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.95 : Name and Description fields added
 0.96 : Usage of uxPLConst
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
     uxPLCustomMessage,
     uxPLHeader,
     uxPLAddress,
     uxPLMsgBody,
     uxPLSchema,
     uxPLConst,
     uxPLClient
     ;

type        (*TODO : nettoyer ce code suite à la modification de l'héritage via TxPLCustomMessage*)

     { TxPLMessage }

     TxPLMessage = class(TxPLCustomMessage) //(TComponent)
     private
        fName         : string;
        fDescription  : string;
        fExecuteOrder : integer;
        fClient       : TxPLClient;

        function  GetRawXPL: string;
        function  Get_Strings: TStringList;
        procedure SetRawXPL(const AValue: string);
        procedure Set_Strings(const AValue: TStringList);
     public
        property MsgName      : string            read fName            write fName            ;
        property Description  : string            read fDescription     write fDescription     ;
        property ExecuteOrder : integer           read fExecuteOrder    write fExecuteOrder    ;
        property Strings      : TStringList       read Get_Strings      write Set_Strings;

        constructor create;
        constructor create(const aClient : TxPLClient; const aRawxPL : string = ''); overload;

        function SourceFilterTag : tsFilter; // Return a message like a filter string
        function TargetFilterTag : tsFilter;
        function IsValid : boolean;
        function ElementByName(const anItem : string) : string;
        function ProcessedxPL : string;
        function  LoadFromFile(aFileName : string) : boolean;
        procedure SaveToFile(aFileName : string);
        procedure ReadFromTable(const id : integer; const tbHeader, tbBody : string);

//        function  WriteToXML(const aDoc : TXMLDocument): TXMLxplActionType; overload;
//        procedure WriteToXML(const aCom : TXMLxplActionType); overload;
//        procedure ReadFromXML(const aCom : TXMLActionsType); overload;
//        procedure ReadFromXML(const aCom : TXMLxplActionType); overload;
//        procedure ReadFromXML(const aCom : TXMLCommandType); overload;

        procedure Format_HbeatApp   (const aInterval : string; const aPort : string; const aIP : string);
        procedure Format_SensorBasic(const aDevice : string; const aType : string; const aCurrent : string);
     end;

implementation { ==============================================================}
Uses SysUtils,
     uRegExpr,
     cStrings,
     cUtils;

// TxPLMessage =================================================================
constructor TxPLMessage.Create(const aClient : TxPLClient; const aRawxPL : string = '');
begin
   inherited Create(aRawxPL);
//   fHeader   := TxPLHeader.Create;
//   fBody     := TxPLBody.Create;
   fClient   := aClient;
//   if aRawxPL<>'' then RawXPL := aRawXPL;
end;

constructor TxPLMessage.create;
begin
  Create(nil,'');
end;

function TxPLMessage.SourceFilterTag: tsFilter;  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
begin
   result := Format(K_FMT_FILTER,[Header.MessageType,Source.FilterTag,Schema.RawxPL]);
end;

function TxPLMessage.TargetFilterTag: tsFilter;  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
begin
   result := Format(K_FMT_FILTER,[Header.MessageType,Target.FilterTag,Schema.RawxPL]);
end;

function TxPLMessage.GetRawXPL: string;
begin
   result := Header.RawxPL + Body.RawxPL;
end;

function TxPLMessage.Get_Strings: TStringList;
var arrStr : StringArray;
    j      : integer;
begin
    result := TStringList.Create;
    arrStr := StrSplit(RawXPL,#10);
    for j:=0 to high(arrStr) do result.Add(arrStr[j]);
end;

procedure TxPLMessage.Set_Strings(const AValue: TStringList);
var s : string;
    j : integer;
begin
   s:= '';

   for j:=0 to aValue.Count-1 do
       s += (aValue[j] + #10);

   RawxPL := s;
end;

function TxPLMessage.IsValid: boolean;
begin
   result := (Header.IsValid) and (Body.IsValid)
end;

function TxPLMessage.ElementByName(const anItem: string): string;
begin
   if anItem = 'Schema' then result := Schema.RawxPL;
   if anItem = 'Source' then result := Source.RawxPL;
   if anItem = 'Target' then result := Target.RawxPL;
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
         Body.RawXPL   := Match[3];
      end;
      finally Free;
   end;
end;

function TxPLMessage.LoadFromFile(aFileName: string): boolean;
var f : textfile;
    fichier,ligne : string;
begin
   System.Assign(f,aFileName);
   Reset(f);
   fichier := '';
   while not eof(f) do begin
      System.Readln(f, ligne);
      fichier += #10+ligne;
   end;
   RawxPL := fichier;
   Close(f);
   Result := IsValid;
end;

procedure TxPLMessage.SaveToFile(aFileName: string);
var f : textfile;
begin
   System.Assign(f,aFileName);
   ReWrite(f);
   Writeln(f, RawxPL);
   Close(f);
end;

(*function TxPLMessage.WriteToXML(const aDoc : TXMLDocument): TXMLxplActionType;
begin
   result := TXMLxplActionType.Create(aDoc);
   WriteToXML(result);
end;

procedure TxPLMessage.WriteToXML(const aCom: TXMLxplActionType);
begin
   aCom.Display_Name := Name;
   aCom.ExecuteOrder := IntToStr(fExecuteOrder);
   Header.WriteToXML(aCom);
   Body.WriteToXML(aCom);
end;

procedure TxPLMessage.ReadFromXML(const aCom : TXMLActionsType);
begin
   if aCom.Count<=0 then exit;
   ReadFromXML(aCom.Element[0]);
end;

procedure TxPLMessage.ReadFromXML(const aCom: TXMLxplActionType);
begin
   self.ResetValues;
   ExecuteOrder:= StrToIntDef(aCom.ExecuteOrder,0);
   Name := aCom.Display_Name;
   Header.ReadFromXML(aCom);
   Body.ReadFromXML(aCom);
end;  *)

procedure TxPLMessage.ReadFromTable(const id: integer; const tbHeader, tbBody: string);
const K_SELECT = 'select * from %s where comtrig_id=%d';
begin
   with fClient.DBSettings.GetDataSet(Format(K_SELECT,[tbHeader,id])) do begin
        if RecordCount=1 then begin
           ResetValues;
           Description   := FieldByName('description').AsString;
           MsgName       := FieldByName('name').AsString;
           MessageType   := K_MSG_TYPE_HEAD + FieldByName('msg_type').AsString;
           Target.RawxPL := K_MSG_TARGET_ANY;
           Schema.RawxPL := FieldByName('msg_schema').AsString;

           with fClient.DBSettings.GetDataSet(Format(K_SELECT,[tbBody,id])) do begin
                if RecordCount>0 then repeat
                   Body.AddKeyValuePairs([FieldByName('name').AsString],[FieldByName('default_').AsString]);
                   Next;
                until eof;
                Destroy;
           end;
        end;
        Destroy;
   end;
end;

(*procedure TxPLMessage.ReadFromXML(const aCom: TXMLCommandType);
begin
   self.ResetValues;
   Description := aCom.description;
   Name := aCom.name;
   Header.ReadFromXML(aCom);
   Body.ReadFromXML(aCom);
end;*)

procedure TxPLMessage.Format_HbeatApp(const aInterval: string; const aPort: string; const aIP: string);
begin
   Body.ResetValues;
   Schema.RawxPL := K_SCHEMA_HBEAT_APP;
   MessageType:= K_MSG_TYPE_STAT;
   Target.IsGeneric := True;
   Body.AddKeyValuePairs( [K_HBEAT_ME_INTERVAL, K_HBEAT_ME_PORT, K_HBEAT_ME_REMOTEIP],
                          [aInterval,           aPort,           aIP]);
end;

procedure TxPLMessage.Format_SensorBasic(const aDevice: string; const aType: string; const aCurrent: string);
begin
   Body.ResetValues;
   Schema.RawxPL := K_SCHEMA_SENSOR_BASIC;
   Body.AddKeyValuePairs( ['device' , 'type' , 'current'],
                          [aDevice  , aType  ,  aCurrent]);
end;

end.
