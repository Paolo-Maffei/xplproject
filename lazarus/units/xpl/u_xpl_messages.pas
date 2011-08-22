unit u_xpl_messages;

// These classes handle specific class of messages and their behaviour

{$ifdef fpc}
   {$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , u_xpl_message
     ;

type // THeartBeatMsg =========================================================
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
        constructor Create(const aOwner : TComponent); overload;
        procedure   Send;

     published
        property interval : integer read Get_Interval  write Set_Interval;
        property port     : integer read Get_port      write Set_port;
        property remote_ip: string  read Get_remote_ip write Set_remote_ip;
        property appname  : string  read Get_AppName   write Set_AppName;
        property version  : string  read Get_Version   write Set_Version;
     end;

     // TFragmentReq ==========================================================
     IntArray = array of integer;

     { TFragmentReqMsg }

     TFragmentReqMsg = class(TxPLMessage)

     private
        function Get_Message: integer;
        function Get_Parts: IntArray;
        procedure Set_Message(const AValue: integer);
        procedure Set_Parts(const AValue: IntArray);

     public
        constructor Create(const aOwner : TComponent); reintroduce;

        procedure AddPart(const aPart : integer);
     published
        property Parts : IntArray read Get_Parts write Set_Parts;
        property Message : integer read Get_Message write Set_Message;
     end;

     { TFragmentBasicMsg }

     TFragBasicMsg = class(TxPLMessage)
     private
        fPartNum, fPartMax, fUniqueId : integer;

        //function Get_PartMax: integer;
        //function Get_PartNum: integer;
        //function Get_UniqueId: integer;
        procedure Set_PartMax(const AValue: integer);
        procedure Set_PartNum(const AValue: integer);
        procedure Set_UniqueId(const AValue: integer);

        procedure ReadPartIdElements;
        procedure WritePartIdElements;

     public
        constructor Create(const aOwner : TComponent; const aSourceMsg : TxPLMessage; const FirstOne : boolean = false); overload; reintroduce;
        function    Identifier : string;
        function    IsTheFirst : boolean;
        function    ToMessage  : TxPLMessage;
        function    IsValid    : boolean; reintroduce;

        property    PartNum  : integer read fPartNum  write Set_PartNum;
        property    PartMax  : integer read fPartMax  write Set_PartMax;
        property    UniqueId : integer read fUniqueId write Set_UniqueId;
        //property    PartNum  : integer read Get_PartNum  write Set_PartNum;
        //property    PartMax  : integer read Get_PartMax  write Set_PartMax;
        //property    UniqueId : integer read Get_UniqueId write Set_UniqueId;
     end;

// ============================================================================
implementation

uses u_xpl_schema
     , u_xpl_common
     , u_xpl_sender
     , u_xpl_custom_listener
     , uxplConst
     , StrUtils
     , JclStrings
     ;

const K_HBEAT_ME_INTERVAL = 'interval';
      K_HBEAT_ME_PORT     = 'port';
      K_HBEAT_ME_REMOTEIP = 'remote-ip';
      //K_HBEAT_ME_WEB_PORT = 'webport';
      K_HBEAT_ME_VERSION  = 'version';
      K_HBEAT_ME_APPNAME  = 'appname';

      K_FRAGREQ_ME_MESSAGE = 'message';
      K_FRAGBAS_ME_PARTID  = 'partid';

// TFragmentBasicMsg =========================================================
constructor TFragBasicMsg.Create(const aOwner: TComponent; const aSourceMsg : TxPLMessage; const FirstOne : boolean = false);
begin
   fPartNum  := -1;
   fPartMax  := -1;
   fUniqueId := -1;

   inherited Create(aOwner);                                                   // This object can be created from two purposes :
   if aSourceMsg.schema.Equals(Schema_FragBasic) then begin                    //    2°/ Creating it from rawxpl received on the network
      Assign(aSourceMsg);
      ReadPartIdElements;
   end else begin                                                              //    1°/ Having a big message of class.type schema to explode it
      AssignHeader(aSourceMsg);
      Schema.Assign(Schema_FragBasic);
      Body.addkeyvaluepairs([K_FRAGBAS_ME_PARTID],['%d/%d:%d']);
      if FirstOne then begin
         Body.addkeyvaluepairs(['schema'],[aSourceMsg.Schema.RawxPL]);
         fPartNum := 1;
      end;
   end;
end;

//function TFragBasicMsg.Get_PartMax: integer;
//begin
//   ReadPartIdElements;
//   Result := fPartMax;
//end;
//
//function TFragBasicMsg.Get_PartNum: integer;
//begin
//   ReadPartIdElements;
//   Result := fPartNum;
//end;
//
//function TFragBasicMsg.Get_UniqueId: integer;
//begin
//   ReadPartIdElements;
//   Result := fUniqueId;
//end;

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
    partid    := AnsiReplaceStr(Body.GetValueByKey('partid'),':','/');
    List := TStringList.Create;
    StrTokenToStrings(partid,'/',list);
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
   end;
end;

function TFragBasicMsg.IsValid: boolean;
begin
//   ReadPartIdElements;                                                         // Be sure we read it
   Result := inherited IsValid and ( (fPartNum * fPartMax * fUniqueId) >= 0);
   if IsTheFirst then Result := Result and (Body.GetValueByKey('schema')<>'');
end;

function TFragBasicMsg.Identifier: string;
begin
//   ReadPartIdElements;
   result := AnsiReplaceStr(Source.AsFilter,'.','') + IntToStr(fUniqueId);
end;

function TFragBasicMsg.IsTheFirst: boolean;
begin
//   ReadPartIdElements;
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

// THeartBeatMsg ==============================================================
constructor THeartBeatMsg.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
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

