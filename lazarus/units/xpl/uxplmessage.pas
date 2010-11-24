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
 1.01 : Added Strings property
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
        fExecuteOrder : integer;

        function GetRawXPL: string;
        function Get_Strings: TStringList;
        procedure SetRawXPL(const AValue: string);
        procedure Set_Strings(const AValue: TStringList);
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
        property ExecuteOrder : integer          read fExecuteOrder    write fExecuteOrder    ;
        property Strings     : TStringList       read Get_Strings      write Set_Strings;

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

        function  WriteToXML(const aDoc : TXMLDocument): TXMLxplActionType; overload;
        procedure WriteToXML(const aCom : TXMLxplActionType); overload;
        procedure ReadFromXML(const aCom : TXMLActionsType); overload;
        procedure ReadFromXML(const aCom : TXMLxplActionType); overload;
        procedure ReadFromXML(const aCom : TXMLCommandType); overload;

        procedure Format_HbeatApp   (const aInterval : string; const aPort : string; const aIP : string);
        procedure Format_SensorBasic(const aDevice : string; const aType : string; const aCurrent : string);
     end;

implementation { ==============================================================}
Uses SysUtils,
     uRegExpr,
     cStrings,
     cUtils,
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
   WriteToXML(xDoc);
   writeXMLFile(xdoc,aFileName);
   xdoc.Free;
end;

function TxPLMessage.WriteToXML(const aDoc : TXMLDocument): TXMLxplActionType;
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
end;

procedure TxPLMessage.ReadFromXML(const aCom: TXMLCommandType);
begin
   self.ResetValues;
   Description := aCom.description;
   Name := aCom.name;
   Header.ReadFromXML(aCom);
   Body.ReadFromXML(aCom);
end;

procedure TxPLMessage.Format_HbeatApp(const aInterval: string; const aPort: string; const aIP: string);
begin
   Body.ResetAll;
   Schema.RawxPL := K_SCHEMA_HBEAT_APP;
   MessageType:= K_MSG_TYPE_STAT;
   Target.IsGeneric := True;
   Body.AddKeyValuePairs( [K_HBEAT_ME_INTERVAL, K_HBEAT_ME_PORT, K_HBEAT_ME_REMOTEIP],
                          [aInterval,           aPort,           aIP]);
end;

procedure TxPLMessage.Format_SensorBasic(const aDevice: string; const aType: string; const aCurrent: string);
begin
   Body.ResetAll;
   Schema.RawxPL := K_SCHEMA_SENSOR_BASIC;
   Body.AddKeyValuePairs( ['device' , 'type' , 'current'],
                          [aDevice  , aType  ,  aCurrent]);
end;

end.
