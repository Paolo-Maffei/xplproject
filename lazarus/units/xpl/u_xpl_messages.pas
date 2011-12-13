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

     TSendmsgBasic = class(TxPLMessage)
     private
       function Get_Text: string;
       function Get_To: string;
       procedure Set_Text(const AValue: string);
       procedure Set_To(const AValue: string);
     public
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     published
        property Text  : string read Get_Text write Set_Text;
        property To_  : string read Get_To write Set_To;
     end;

     { TReceiveMsgBasic }

     TReceiveMsgBasic = class(TSendmsgBasic)
     private
       function Get_From: string;
       procedure Set_From(AValue: string);
     public
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     published
        property From : string read Get_From write Set_From;
     end;

     TSensorBasic = class(TxPLMessage)
     private
       function Get_Device : string;
       function Get_Current : string;
       function Get_Type : string;
       procedure Set_Type(const AValue: string);
       procedure Set_Current(const AValue: string);
       procedure Set_Device(const aValue : string);
     public
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     published
        property Device  : string read Get_Device write Set_Device;
        property Current : string read Get_Current write Set_Current;
        property Type_  : string read Get_Type write Set_Type;
     end;

     { TConfigMessageFamily }

     TConfigMessageFamily = class(TxPLMessage)
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     end;

     TConfigListCmnd = class(TConfigMessageFamily)
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     end;

     { TConfigListStat }

     TConfigListStat = class(TConfigListCmnd)
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     public
        function ItemMax(const i : integer) : integer;
        function ItemName(const i : integer) : string;
     end;

     { TConfigListMsg }

     TConfigCurrentCmnd = class(TConfigListCmnd)
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
     end;

     { TConfigResponseCmnd }

     TConfigResponseCmnd = class(TConfigMessageFamily)
     private
        fMultiValued : TStringList;

        function Get_Filters : TStringList;
        function Get_Groups : TStringList;
        procedure Read_Multivalued(const aListIndex : integer);
        function  get_interval: integer;
        function  get_newconf: string;
        procedure set_interval(const AValue: integer);
        procedure set_newconf(const AValue: string);
     public
        constructor Create(const aOwner: TComponent; const aRawxPL : string = ''); reintroduce;
        destructor  Destroy; override;
        function  IsCoreValue(const aIndex : integer) : boolean;

        procedure SlChanged(Sender : TObject);
        function  GetMultiValued(const aValue : string) : TStringList;
     published
        property newconf : string read get_newconf write set_newconf stored false;
        property interval: integer read get_interval write set_interval stored false;
        property filters : TStringList read Get_Filters stored false; //write Set_Filters stored false;
        property groups  : TStringList read Get_Groups stored false; // write Set_Groups stored false;
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
     (aMsg.Schema.Equals(Schema_ConfigCurr)) and (aMsg.MessageType = stat) then result := TConfigCurrentStat.Create(nil,aRawxPL)
   else if
     aMsg.Schema.RawxPL = 'log.basic' then result := TLogBasic.Create(nil,aRawxPL)
   else if
     aMsg.Schema.RawxPL = 'osd.basic' then result := TOsdBasic.Create(nil,aRawxPL)
   else if
     aMsg.Schema.RawxPL = 'sendmsg.basic' then result := TSendmsgBasic.Create(nil,aRawxPL)
   else if
     aMsg.Schema.RawxPL = 'rcvmsg.basic' then result := TReceivemsgBasic.Create(nil,aRawxPL)
   else if
     aMsg.Schema.RawxPL = 'sensor.basic' then result := TSensorBasic.Create(nil,aRawxPL)
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
      Target.IsGeneric:=true;
   end;
end;

procedure TConfigCurrentStat.Assign(aMessage: TPersistent);
begin
   Body.ResetValues;
   inherited Assign(aMessage);
   if aMessage is TConfigCurrentStat then begin
      fMultiValued.Assign(tConfigCurrentStat(aMessage).fMultiValued);
   end;
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

constructor TConfigListStat.Create(const aOwner: TComponent;   const aRawxPL: string);
begin
   inherited Create(aOwner, aRawxPL);
   if aRawxPL = '' then begin
      MessageType := stat;
      Body.ResetValues;
      Body.AddKeyValuePairs( ['reconf','option','option','option'],['newconf','interval','filter[16]','group[16]']);
   end;
end;

function TConfigListStat.ItemMax(const i: integer): integer;
var sl : tstringlist;
    s  : string;
begin
   sl := TStringList.Create;
   s := AnsiReplaceStr(Body.Values[i],']','[');
   sl.Delimiter := '[';
   sl.DelimitedText := s;
   if sl.Count=1 then result := 1 else result := StrToInt(sl[1]);
   sl.free;
end;

function TConfigListStat.ItemName(const i: integer): string;
var sl : tstringlist;
    s  : string;
begin
   sl := TStringList.Create;
   s := AnsiReplaceStr(Body.Values[i],']','[');
   sl.Delimiter := '[';
   sl.DelimitedText := s;
   result := sl[0];
   sl.free;
end;

{ TConfigCurrentCmnd }
constructor TConfigCurrentCmnd.Create(const aOwner: TComponent; const aRawxPL: string);    // formerly TConfigCurrMsg
begin
   inherited Create(aOwner, aRawxPL);
   if aRawxPL = '' then begin
      Schema.Type_:= 'current';
   end;
end;

// TConfigRespMsg =============================================================
constructor TConfigResponseCmnd.Create(const aOwner: TComponent; const aRawxPL: string);        // formerly TConfigRespMsg
begin
   inherited Create(aOwner, aRawxPL);
   fMultiValued := TStringList.Create;

   if aRawxPL = '' then begin
      Schema.Type_:= 'response';
      MessageType := cmnd;
      Body.AddKeyValuePairs( K_CONFIG_RESPONSE_KEYS,['','','','']);
   end;
end;

destructor TConfigResponseCmnd.Destroy;
begin
   fMultiValued.Free;
   inherited Destroy;
end;

function TConfigResponseCmnd.Get_Filters : TStringList;
begin
   result := GetMultiValued('filter');
end;

function TConfigResponseCmnd.Get_Groups : TStringList;
begin
   result := GetMultiValued('group');
end;

procedure TConfigResponseCmnd.SlChanged(Sender: TObject);
var j,i : integer;
begin
   for j:=0 to Pred(fMultiValued.Count) do begin
       if (fMultiValued.Objects[j] = sender) then begin                        // Identify the sending stringlist
          for i:=Pred(Body.ItemCount) downto 0 do
              if Body.Keys[i] = fMultiValued[j] then Body.DeleteItem(i);
          if TStringList(Sender).Count = 0
             then Body.AddKeyValue(fMultiValued[j]+'=')
             else for i:=0 to Pred(TStringList(Sender).Count) do
                  Body.AddKeyValue(fMultiValued[j] + '=' + TStringList(Sender)[i]);
       end;
   end;
end;

function TConfigResponseCmnd.GetMultiValued(const aValue: string): TStringList;
         function NewList : TStringList;
         begin
            result := TStringList.Create;
            result.Sorted := true;
            result.Duplicates:=dupIgnore;
            result.OnChange  :=@slChanged;
         end;
var i : integer;
begin
   result := nil;

   for i:=0 to Pred(fMultiValued.count) do
       if fMultiValued[i] = aValue then
          result := TStringList(fMultiValued.Objects[i]);
   if (result = nil) then begin
      result := NewList;
      i := fMultiValued.AddObject(aValue,Result);
      Read_MultiValued(i);
   end;
end;

procedure TConfigResponseCmnd.Read_Multivalued(const aListIndex: integer);
var i : integer;
    aSl : TStringList;
begin
   aSL := TStringList(fMultiValued.Objects[aListIndex]);
   aSL.BeginUpdate;
   aSL.Clear;
   for i := 0 to Pred(Body.ItemCount) do
       if (Body.Keys[i] = fMultiValued[aListIndex]) and (Body.Values[i]<>'') then aSL.Add(Body.Values[i]);
   aSL.EndUpdate;
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

{ TSendmsgBasic }
constructor TSensorBasic.Create(const aOwner: TComponent; const aRawxPL: string);
begin
   inherited Create(aOwner,aRawxPL);
   if aRawxPL='' then begin
      Schema.RawxPL := 'sensor.basic';
      Target.IsGeneric := True;
      MessageType      := trig;
      Body.AddKeyValuePairs( ['device','type','current'],['','','']);
   end;
end;

function TSensorBasic.Get_Device: string;
begin
   result := Body.GetValueByKey('device','');
end;

function TSensorBasic.Get_Type: string;
begin
   result := Body.GetValueByKey('type','');
end;

function TSensorBasic.Get_Current: string;
begin
   result := Body.GetValueByKey('current','');
end;

procedure TSensorBasic.Set_Current(const AValue: string);
begin
   Body.SetValueByKey('current',aValue);
end;

procedure TSensorBasic.Set_Type(const AValue: string);
begin
   Body.SetValueByKey('type',aValue);
end;

procedure TSensorBasic.Set_Device(const AValue: string);
begin
   Body.SetValueByKey('device',aValue);
end;

{ TSendmsgBasic }
constructor TSendmsgBasic.Create(const aOwner: TComponent; const aRawxPL: string);
begin
   inherited Create(aOwner,aRawxPL);
   if aRawxPL='' then begin
      Schema.RawxPL := 'sendmsg.basic';
      Target.IsGeneric := True;
      MessageType      := cmnd;
      Body.AddKeyValuePairs( ['body','to'],['','']);
   end;
end;

function TSendmsgBasic.Get_To: string;
begin
   result := Body.GetValueByKey('to','');
end;

function TSendmsgBasic.Get_Text: string;
begin
   result := Body.GetValueByKey('body');
end;

procedure TSendmsgBasic.Set_Text(const AValue: string);
begin
   Body.SetValueByKey('body',aValue);
end;

procedure TSendmsgBasic.Set_To(const AValue: string);
begin
   Body.SetValueByKey('to',aValue);
end;

{ TReceiveMsgBasic }

constructor TReceiveMsgBasic.Create(const aOwner: TComponent; const aRawxPL: string);
begin
   inherited Create(aOwner,aRawxPL);
   if aRawxPL='' then begin
      Schema.RawxPL := 'rcvmsg.basic';
      MessageType      := trig;
      Body.AddKeyValuePairs( ['from'],['']);
   end;
end;

function TReceiveMsgBasic.Get_From: string;
begin
   result := Body.GetValueByKey('from','');
end;

procedure TReceiveMsgBasic.Set_From(AValue: string);
begin
   Body.SetValueByKey('from',aValue);
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
   result := StrToIntDef(Body.GetValueByKey(K_HBEAT_ME_PORT),-1);
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

