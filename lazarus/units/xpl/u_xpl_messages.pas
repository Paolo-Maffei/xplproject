unit u_xpl_messages;

// These classes handle specific class of messages and their behaviour

{$ifdef fpc}
   {$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , u_xpl_message
     , u_xpl_common
     , fpc_delphi_compat
     ;

type // THeartBeatMsg =========================================================

     { TOsdBasic }

     TOsdBasic = class(TxPLMessage)
     private
       function Get_Column: integer;
       function Get_Command: string;
       function Get_Delay: integer;
       function Get_Row: integer;
       function Get_Text: string;
       procedure Set_Column(const AValue: integer);
       procedure Set_Command(const AValue: string);
       procedure Set_Delay(const AValue: integer);
       procedure Set_Row(const AValue: integer);
       procedure Set_Text(const AValue: string);
     public
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     published
        property Command : string read Get_Command write Set_Command;
        property Text  : string read Get_Text write Set_Text;
        property Row  : integer read Get_Row write Set_Row;
        property Column  : integer read Get_Column write Set_Column;
        property Delay : integer read Get_Delay write Set_Delay;
     end;

     { TLogBasic }

     TLogBasic = class(TxPLMessage)
     private
       function Get_Code: string;
       function Get_Text: string;
       function Get_Type: TEventType;
       procedure Set_Code(const AValue: string);
       procedure Set_Text(const AValue: string);
       procedure Set_Type(const AValue: TEventType);
     public
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     published
        property Type_ : TEventType read Get_Type write Set_Type;
        property Text  : string read Get_Text write Set_Text;
        property Code  : string read Get_Code write Set_Code;
     end;

     { TConfigRespMsg }

     { TConfigReqMsg }

     { TConfigMessageFamily }

     TConfigMessageFamily = class(TxPLMessage)
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     end;

     TConfigListCmnd = class(TConfigMessageFamily)
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     end;

     { TConfigListMsg }

     TConfigCurrentCmnd = class(TConfigListCmnd)
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     end;

     TConfigResponseCmnd = class(TConfigMessageFamily)
        fFilters : TStringList;
        fGroups  : TStringList;
     public
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
        destructor  Destroy; override;
        function  IsCoreValue(const aIndex : integer) : boolean;
     private
       function Get_Filters: TStringList;
       function Get_Groups: TStringList;
       function get_interval: integer;
       function get_newconf: string;
       procedure Set_Filters(const AValue: TStringList);
       procedure Set_Groups(const AValue: TStringList);
       procedure set_interval(const AValue: integer);
       procedure set_newconf(const AValue: string);

     published
        property newconf : string read get_newconf write set_newconf;
        property interval: integer read get_interval write set_interval;
        property filters : TStringList read Get_Filters write Set_Filters;
        property groups  : TStringList read Get_Groups write Set_Groups;
     end;

     TConfigCurrentStat = class(TConfigResponseCmnd)
     public
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;

        procedure   Assign(aMessage : TPersistent); override;
     published
        property Interval;
        property NewConf;
        property Filters;
        property Groups;
     end;

     THeartBeatReq = class(TxPLMessage)
     public
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     end;

     THeartBeatMsg = class(TxPLMessage)
     private
        function  Get_AppName: string;
        function  Get_Interval: integer;
        function  Get_port: integer;
        function  Get_remote_ip: string;
        function  Get_Version: string;
        procedure Set_AppName(const AValue: string);
        procedure Set_Interval(const AValue: integer);
        procedure Set_port(const AValue: integer);
        procedure Set_remote_ip(const AValue: string);
        procedure Set_Version(const AValue: string);

     public
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
        procedure   Send;

     published
        property interval : integer read Get_Interval  write Set_Interval;
        property port     : integer read Get_port      write Set_port;
        property remote_ip: string  read Get_remote_ip write Set_remote_ip;
        property appname  : string  read Get_AppName   write Set_AppName;
        property version  : string  read Get_Version   write Set_Version;
     end;

     // TFragmentReq ==========================================================

     { TFragmentReqMsg }
     TFragmentMsg = class(TxPLMessage)

     end;

     TFragmentReqMsg = class(TFragmentMsg)

     private
        function Get_Message: integer;
        function Get_Parts: IntArray;
        procedure Set_Message(const AValue: integer);
        procedure Set_Parts(const AValue: IntArray);

     public
        constructor Create(const aOwner : TComponent); overload;

        procedure AddPart(const aPart : integer);
     published
        property Parts : IntArray read Get_Parts write Set_Parts;
        property Message : integer read Get_Message write Set_Message;
     end;

     { TFragmentBasicMsg }

     TFragBasicMsg = class(TFragmentMsg)
     private
        fPartNum, fPartMax, fUniqueId : integer;

        procedure Set_PartMax(const AValue: integer);
        procedure Set_PartNum(const AValue: integer);
        procedure Set_UniqueId(const AValue: integer);

        procedure ReadPartIdElements;
        procedure WritePartIdElements;

     public
        constructor Create(const aOwner : TComponent; const aSourceMsg : TxPLMessage; const FirstOne : boolean = false); reintroduce; overload;
        function    Identifier : string;
        function    IsTheFirst : boolean;
        function    ToMessage  : TxPLMessage;
        function    IsValid    : boolean; reintroduce;

        property    PartNum  : integer read fPartNum  write Set_PartNum;
        property    PartMax  : integer read fPartMax  write Set_PartMax;
        property    UniqueId : integer read fUniqueId write Set_UniqueId;
     end;

     function MessageBroker(const aRawxPL : string) : TxPLMessage;

// ============================================================================
implementation

uses StrUtils
     , u_xpl_schema
     , u_xpl_sender
     , u_xpl_custom_listener
     , uxplConst
     ;

const K_HBEAT_ME_INTERVAL = 'interval';
      K_HBEAT_ME_PORT     = 'port';
      K_HBEAT_ME_REMOTEIP = 'remote-ip';
      //K_HBEAT_ME_WEB_PORT = 'webport';
      K_HBEAT_ME_VERSION  = 'version';
      K_HBEAT_ME_APPNAME  = 'appname';

      K_FRAGREQ_ME_MESSAGE = 'message';
      K_FRAGBAS_ME_PARTID  = 'partid';

      K_CONFIG_RESPONSE_KEYS : Array[0..3] of string = ('newconf','interval','filter','group');

// ===========================================================================
function MessageBroker(const aRawxPL: string): TxPLMessage;
var aMsg : TxPLMessage;
begin
   aMsg := TxPLMessage.Create(nil,aRawxPL);
   if
     aMsg.Schema.Equals(Schema_FragBasic) then result := TFragBasicMsg.Create(nil,aMsg)
   else if
     aMsg.Schema.Equals(Schema_FragReq)   then result := TFragmentReqMsg.Create(nil,aRawxPL)
   else if
     aMsg.Schema.Equals(Schema_HBeatApp)  then result := THeartBeatMsg.Create(nil,aRawxPL)
   else if
     aMsg.Schema.Equals(Schema_HBeatReq)  then result := THeartBeatReq.Create(nil,aRawxPL)
   else if
     (aMsg.Schema.Equals(Schema_ConfigList)) and (aMsg.MessageType = cmnd) then result := TConfigListCmnd.Create(nil,aRawxPL)
   else if
     (aMsg.Schema.Equals(Schema_ConfigCurr)) and (aMsg.MessageType = cmnd) then result := TConfigCurrentCmnd.Create(nil,aRawxPL)
   else if
     (aMsg.Schema.Equals(Schema_ConfigResp)) and (aMsg.MessageType = cmnd) then result := TConfigResponseCmnd.Create(nil,aRawxPL)
   else if
     aMsg.Schema.RawxPL = 'log.basic' then result := TLogBasic.Create(nil,aRawxPL)
   else if
     aMsg.Schema.RawxPL = 'osd.basic' then result := TOsdBasic.Create(nil,aRawxPL)
   else result := aMsg;

   if result<>aMsg then aMsg.Free;
end;

// TConfigMessageFamily =======================================================
constructor TConfigMessageFamily.Create(const aOwner: TComponent; const aRawxPL: string);
begin
   inherited Create(aOwner,aRawxPL);
   if aRawxPL = '' then begin
      Schema.Classe := 'config';
   end;
end;

{ TConfigCurrentStat }
constructor TConfigCurrentStat.Create(const aOwner: TComponent;  const aRawxPL: string);
begin
   inherited Create(aOwner, aRawxPL);
   if aRawxPL = '' then begin
      Schema.Type_:= 'current';
      MessageType := stat;
   end;
end;

procedure TConfigCurrentStat.Assign(aMessage: TPersistent);
begin
   Body.ResetValues;
   inherited Assign(aMessage);
end;

{ TConfigListCmnd }
constructor TConfigListCmnd.Create(const aOwner: TComponent; const aRawxPL: string);      // formerly TConfigReqMsg
begin
   inherited Create(aOwner, aRawxPL);
   if aRawxPL = '' then begin
      Schema.Type_:= 'list';
      MessageType := cmnd;
      Body.AddKeyValuePairs( ['command'],['request']);
   end;
end;

{ TConfigCurrentCmnd }
constructor TConfigCurrentCmnd.Create(const aOwner: TComponent; const aRawxPL: string);    // formerly TConfigCurrMsg
begin
   inherited Create(aOwner, aRawxPL);
   if aRawxPL = '' then begin
      Schema.Type_:= 'current';
   end;
end;

{ TConfigRespMsg }
constructor TConfigResponseCmnd.Create(const aOwner: TComponent; const aRawxPL: string);        // formerly TConfigRespMsg
begin
   inherited Create(aOwner, aRawxPL);
   fFilters := TStringList.Create;
   fGroups  := TStringList.Create;
   if aRawxPL = '' then begin
      Schema.Type_:= 'response';
      MessageType := cmnd;
      Body.AddKeyValuePairs( K_CONFIG_RESPONSE_KEYS,['','','','']);
   end;
end;

destructor TConfigResponseCmnd.Destroy;
begin
   fFilters.Free;
   fGroups.Free;
   inherited Destroy;
end;

function TConfigResponseCmnd.Get_Filters: TStringList;
var i : integer;
begin
   fFilters.Clear;
   for i := 0 to Pred(Body.ItemCount) do
       if (Body.Keys[i] = 'filter') and (Body.Values[i]<>'') then fFilters.Add(Body.Values[i]);
   result := fFilters;
end;

procedure TConfigResponseCmnd.Set_Filters(const AValue: TStringList);
var i : integer;
begin
   for i:=Pred(Body.ItemCount)-1 downto 0 do
       if Body.Keys[i] = 'filter' then Body.DeleteItem(i);
   if aValue.Count = 0 then Body.AddKeyValue('filter=')
   else for i:=0 to Pred(aValue.Count) do
            Body.AddKeyValue('filter=' + aValue[i]);
end;

procedure TConfigResponseCmnd.Set_Groups(const AValue: TStringList);
var i : integer;
begin
   for i:=Pred(Body.ItemCount)-1 downto 0 do
       if Body.Keys[i] = 'group' then Body.DeleteItem(i);
   if aValue.Count = 0 then Body.AddKeyValue('group=')
   else for i:=0 to Pred(aValue.Count) do
            Body.AddKeyValue('group=' + aValue[i]);
end;

function TConfigResponseCmnd.Get_Groups: TStringList;
var i : integer;
begin
   fGroups.Clear;
   for i := 0 to Pred(Body.ItemCount) do
       if (Body.Keys[i] = 'group') and (Body.Values[i]<>'') then fGroups.Add(Body.Values[i]);
   result := fGroups;
end;

function TConfigResponseCmnd.get_interval: integer;
begin
   result := StrToIntDef(Body.GetValueByKey('interval',''),-1);
end;

function TConfigResponseCmnd.get_newconf: string;
begin
   result := Body.GetValueByKey('newconf','');
end;

procedure TConfigResponseCmnd.set_interval(const AValue: integer);
begin
   Body.SetValueByKey('interval',IntToStr(aValue));
end;

procedure TConfigResponseCmnd.set_newconf(const AValue: string);
begin
   Body.SetValueByKey('newconf',aValue);
end;

function TConfigResponseCmnd.IsCoreValue(const aIndex: integer): boolean;
begin
   result := AnsiIndexStr(Body.Keys[aIndex],K_CONFIG_RESPONSE_KEYS) <>-1;
end;

{ TLogBasic }
constructor TLogBasic.Create(const aOwner: TComponent; const aRawxPL: string);
begin
   inherited Create(aOwner,aRawxPL);
   if aRawxPL='' then begin
      Schema.RawxPL := 'log.basic';
      Target.IsGeneric := True;
      MessageType      := trig;
      Body.AddKeyValuePairs( ['type','text'],['','']);
   end;
end;

function TLogBasic.Get_Code: string;
begin
   result := Body.GetValueByKey('code','');
end;

function TLogBasic.Get_Text: string;
begin
   result := Body.GetValueByKey('text');
end;

function TLogBasic.Get_Type: TEventType;
begin
   result := xPLLevelToEventType(Body.GetValueByKey('type'));
end;

procedure TLogBasic.Set_Code(const AValue: string);
begin
   Body.SetValueByKey('code',aValue);
end;

procedure TLogBasic.Set_Text(const AValue: string);
begin
   Body.SetValueByKey('text',aValue);
end;

procedure TLogBasic.Set_Type(const AValue: TEventType);
begin
   Body.SetValueByKey('type',EventTypeToxPLLevel(aValue));
end;

{ TOsdBasic }

function TOsdBasic.Get_Column: integer;
begin
   result := StrToIntDef(Body.GetValueByKey('column'),0);
end;

function TOsdBasic.Get_Command: string;
begin
   result := Body.GetValueByKey('command','write');
end;

function TOsdBasic.Get_Delay: integer;
begin
   result := StrToIntDef(Body.GetValueByKey('delay'),-1);
end;

function TOsdBasic.Get_Row: integer;
begin
   result := StrToIntDef(Body.GetValueByKey('row'),0);
end;

function TOsdBasic.Get_Text: string;
begin
   result := Body.GetValueByKey('text');
end;

procedure TOsdBasic.Set_Column(const AValue: integer);
begin
   Body.SetValueByKey('column',IntToStr(aValue));
end;

procedure TOsdBasic.Set_Command(const AValue: string);
begin
   Body.SetValueByKey('command',aValue);
end;

procedure TOsdBasic.Set_Delay(const AValue: integer);
begin
   if Get_Delay=-1 then Body.AddKeyValue('delay=');
   Body.SetValueByKey('delay',IntToStr(aValue));
end;

procedure TOsdBasic.Set_Row(const AValue: integer);
begin
   Body.SetValueByKey('row',IntToStr(aValue));
end;

procedure TOsdBasic.Set_Text(const AValue: string);
begin
   Body.SetValueByKey('text',aValue);
end;

constructor TOsdBasic.Create(const aOwner: TComponent; const aRawxPL: string);
begin
   inherited Create(aOwner,aRawxPL);
   if aRawxPL='' then begin
      Schema.RawxPL := 'osd.basic';
      Target.IsGeneric := True;
      MessageType      := cmnd;
      Body.AddKeyValuePairs( ['command','text'],['','']);
   end;
end;

// TFragmentBasicMsg =========================================================
constructor TFragBasicMsg.Create(const aOwner: TComponent; const aSourceMsg : TxPLMessage; const FirstOne : boolean = false);
begin
   fPartNum  := -1;
   fPartMax  := -1;
   fUniqueId := -1;

   inherited Create(aOwner);                                                   // This object can be created from two purposes :
   if aSourceMsg.schema.Equals(Schema_FragBasic) then begin                    //    1°/ Creating it from rawxpl received on the network
      Assign(aSourceMsg);
      ReadPartIdElements;
   end else begin                                                              //    2°/ Having a big message of class.type schema to explode it
      AssignHeader(aSourceMsg);
      Schema.Assign(Schema_FragBasic);
      Body.addkeyvaluepairs([K_FRAGBAS_ME_PARTID],['%d/%d:%d']);
      if FirstOne then begin
         Body.addkeyvaluepairs(['schema'],[aSourceMsg.Schema.RawxPL]);
         fPartNum := 1;
      end;
   end;
end;

procedure TFragBasicMsg.Set_PartMax(const AValue: integer);
begin
   if aValue = fPartMax then exit;
   fPartMax := aValue;
   WritePartIdElements;
end;

procedure TFragBasicMsg.Set_PartNum(const AValue: integer);
begin
   if aValue = fPartNum then exit;
   fPartNum := aValue;
   WritePartIdElements;
end;

procedure TFragBasicMsg.Set_UniqueId(const AValue: integer);
begin
   if aValue = fUniqueId then exit;
   fUniqueId := aValue;
   WritePartIdElements;
end;

procedure TFragBasicMsg.ReadPartIdElements;
var List   : TStringList;
    partid : string;
begin
    partid := AnsiReplaceStr(Body.GetValueByKey('partid'),'/',':');
    List   := TStringList.Create;
    List.Delimiter := ':';
    List.DelimitedText := partid;

//    ExtractTokensL(partid,':/',#0,true,list);
//    StrTokenToStrings(partid,'/',list);
    if list.Count=3 then begin
       fPartNum  := StrToIntDef(list[0],-1);
       fPartMax  := StrToIntDef(list[1],-1);
       fUniqueId := StrToIntDef(list[2],-1);
    end;
    list.Free;
end;

procedure TFragBasicMsg.WritePartIdElements;
begin
   Body.SetValueByKey(K_FRAGBAS_ME_PARTID, Format('%d/%d:%d',[fPartNum, fPartMax, fUniqueID]));
end;

function TFragBasicMsg.ToMessage: TxPLMessage;
begin
   if IsTheFirst then begin
      Result := TxPLMessage.Create(owner);
      if IsValid then begin
         Result.Assign(self);
         Result.schema.RawxPL := Body.GetValueByKey('schema');
         Result.Body.DeleteItem(0);                                               // Delete the partid line
         if Result.Schema.IsValid then Result.Body.DeleteItem(0);                 // delete the schema line
      end;
   end else Result := nil;
end;

function TFragBasicMsg.IsValid: boolean;
begin
   Result := inherited IsValid and ( (fPartNum * fPartMax * fUniqueId) >= 0);
   if IsTheFirst then Result := Result and (Body.GetValueByKey('schema')<>'');
end;

function TFragBasicMsg.Identifier: string;
begin
   result := AnsiReplaceStr(Source.AsFilter,'.','') + IntToStr(fUniqueId);
end;

function TFragBasicMsg.IsTheFirst: boolean;
begin
   result := (fPartNum = 1);
end;

// TFragmentReq ==============================================================
constructor TFragmentReqMsg.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   Schema.Assign(Schema_FragReq);
   MessageType := cmnd;
   Body.AddKeyValuePairs( ['command',K_FRAGREQ_ME_MESSAGE], ['resend','']);
end;

function TFragmentReqMsg.Get_Message: integer;
begin
   result := StrToIntDef(Body.GetValueByKey(K_FRAGREQ_ME_MESSAGE),-1);
end;

function TFragmentReqMsg.Get_Parts: IntArray;
var i : integer;

begin
   SetLength(Result,0);
   for i:=0 to Pred(Body.ItemCount) do
       if Body.Keys[i]='part' then begin
          SetLength(Result,Length(result)+1);
          Result[length(result)-1] := StrToInt(Body.Values[i]);
       end;
end;

procedure TFragmentReqMsg.Set_Message(const AValue: integer);
begin
   Body.SetValueByKey(K_FRAGREQ_ME_MESSAGE,IntToStr(aValue));
end;

procedure TFragmentReqMsg.AddPart(const aPart: integer);
begin
   Body.AddKeyValue('part=' + IntToStr(aPart));
end;

procedure TFragmentReqMsg.Set_Parts(const AValue: IntArray);
var i : integer;
begin
   for i:=low(aValue) to high(aValue) do AddPart(aValue[i]);
end;

// THeartBeatReq ==============================================================
constructor THeartBeatReq.Create(const aOwner: TComponent; const aRawxPL : string = '');
begin
   inherited Create(aOwner,aRawxPL);
   if aRawxPL='' then begin
      Schema.Assign(Schema_HBeatReq);
      Target.IsGeneric := True;
      MessageType      := cmnd;
      Body.AddKeyValuePairs( ['command'],['request']);
   end;
end;

// THeartBeatMsg ==============================================================
constructor THeartBeatMsg.Create(const aOwner: TComponent; const aRawxPL : string = '');
begin
   inherited Create(aOwner, aRawxPL);
   if aRawxPL='' then begin
      Schema.Assign(Schema_HBeatApp);
      MessageType:= stat;
      Target.IsGeneric := True;
      Body.AddKeyValuePairs( [K_HBEAT_ME_INTERVAL,K_HBEAT_ME_PORT,K_HBEAT_ME_REMOTEIP,K_HBEAT_ME_APPNAME ,K_HBEAT_ME_VERSION],
                             ['','','','','']);
      if Owner is TxPLCustomListener then with TxPLCustomListener(Owner) do begin
         Self.Interval := Config.Interval;
         Self.AppName  := AppName;
         Self.Version  := Version;
         if not Config.IsValid then Schema.Classe := 'config';
         if csDestroying in ComponentState then Schema.Type_ := 'end';
      end;
   end;
end;

procedure THeartBeatMsg.Send;
begin
   if Owner is TxPLSender then
      TxPLSender(Owner).Send(self);
end;

function THeartBeatMsg.Get_AppName: string;
begin
   result := Body.GetValueByKey('appname','');
end;

function THeartBeatMsg.Get_Interval: integer;
begin
   result := StrToIntDef(Body.GetValueByKey(K_HBEAT_ME_INTERVAL),MIN_HBEAT);
end;

function THeartBeatMsg.Get_port: integer;
begin
   Assert(Body.GetValueByKey(K_HBEAT_ME_PORT,'')<>'');
   result := StrToInt(Body.GetValueByKey(K_HBEAT_ME_PORT));
end;

function THeartBeatMsg.Get_remote_ip: string;
begin
   result := Body.GetValueByKey(K_HBEAT_ME_REMOTEIP);
end;

function THeartBeatMsg.Get_Version: string;
begin
   result := Body.GetValueByKey('version','');
end;

procedure THeartBeatMsg.Set_AppName(const AValue: string);
begin
   Body.SetValueByKey('appname',aValue);
end;

procedure THeartBeatMsg.Set_Interval(const AValue: integer);
begin
   Body.SetValueByKey(K_HBEAT_ME_INTERVAL,IntToStr(aValue));
end;

procedure THeartBeatMsg.Set_port(const AValue: integer);
begin
   Body.SetValueByKey(K_HBEAT_ME_PORT,IntToStr(aValue));
end;

procedure THeartBeatMsg.Set_remote_ip(const AValue: string);
begin
   Body.SetValueByKey(K_HBEAT_ME_REMOTEIP,aValue);
end;

procedure THeartBeatMsg.Set_Version(const AValue: string);
begin
   Body.SetValueByKey('version',aValue);
end;

end.

