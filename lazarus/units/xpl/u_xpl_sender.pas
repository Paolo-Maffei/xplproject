unit u_xpl_sender;
{===============================================================================
  UnitName      = u_xpl_sender
  UnitDesc      = xPL Sender object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ===============================================================================
  0.8 : First version, spined off from uxPLMessage
}

{$ifdef fpc}
   {$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses Classes
     , u_xpl_custom_message
     , u_xpl_common
     , u_xpl_schema
     , u_xpl_address
     , u_xpl_application
     , u_xpl_udp_socket
     ;

type // TxPLSender ============================================================
     TxPLSender = class(TxPLApplication)
     protected
        fSocket : TxPLUDPClient;
        fFragCounter : integer;
        procedure Send(const aMessage : string);      overload;

     public
        constructor create(const aOwner : TComponent); overload;

        procedure Send(const aMessage : TxPLCustomMessage; const bEnforceSender : boolean = true); overload;
        procedure SendMessage(const aMsgType : TxPLMessageType; const aDest, aSchema, aRawBody : string; const bClean : boolean = false); overload;
        procedure SendMessage(const aMsgType : TxPLMessageType; const aDest, aSchema : string; const Keys, Values : Array of string); overload;
        procedure SendMessage(const aMsgType : TxPLMessageType; const aDest : string; aSchema : TxPLSchema; const Keys, Values : Array of string); overload;
        procedure SendMessage(const aRawXPL  : string); overload;

        function  PrepareMessage(const aMsgType: TxPLMessageType; const aSchema : string; const aTarget : string = '*') : TxPLCustomMessage; overload;
        function  PrepareMessage(const aMsgType: TxPLMessageType; const aSchema : TxPLSchema; const aTarget : TxPLTargetAddress = nil) : TxPLCustomMessage; overload;

        procedure SendHBeatRequestMsg;
        procedure SendOSDBasic(const aString : string);
        procedure SendLOGBasic(const aLevel : string; const aString : string);
     end;

implementation // =============================================================
uses u_xpl_message
     , u_xpl_header
     , SysUtils
     ;

constructor TxPLSender.create(const aOwner : TComponent);
begin
   inherited;
   fSocket := TxPLUDPClient.Create(self, Settings.BroadCastAddress);
   fFragCounter := 0;
end;

procedure TxPLSender.Send(const aMessage: string);
begin
   fSocket.Send(aMessage)
end;

procedure TxPLSender.Send(const aMessage: TxPLCustomMessage; const bEnforceSender : boolean = true);
var messagelist : TList;
    newfrag,dupmsg : TxPLMessage;
    i,j,runner,overhead  : integer;
begin
   if bEnforceSender then
      aMessage.Source.Assign(Adresse);                     // Let's be sure I'm identified as the sender

   if not aMessage.IsValid then Log(etWarning,'Error sending message %s',[aMessage.RawxPL])
      else begin
     if not aMessage.MustFragment then Send(TxPLMessage(aMessage).ProcessedxPL)
                                  else begin
        messagelist := TList.Create;

        i := 0;
        while (i< aMessage.Body.ItemCount) do begin
            newfrag := TxPLMessage.Create(self);
            newfrag.Assign(aMessage);
            newfrag.schema.assign(Schema_FragBasic);
            newfrag.body.resetvalues;
            newfrag.body.addkeyvaluepairs(['partid'],['%d/%d:%d']);
            if messagelist.count = 0 then
               newfrag.body.addkeyvaluepairs(['schema'],[aMessage.Schema.RawxPL]);

            while (i<aMessage.Body.ItemCount) and (not newfrag.mustfragment) do begin
                  newfrag.Body.AddKeyValuePairs([aMessage.Body.Keys[i]],[aMessage.Body.Values[i]]);
                  inc(i);
            end;

            if newfrag.mustfragment then begin
               newfrag.Body.DeleteItem(newfrag.body.itemcount-1);
               dec(i);
            end;

            messagelist.Add(newfrag);
        end;

        for i:=0 to messagelist.count-1 do begin
            newfrag := TxPLMessage(messagelist[i]);
            newfrag.body.Values[0] := Format(newfrag.body.Values[0],[i+1,messagelist.count,fFragCounter]);
            Send(newfrag);
        end;

        messagelist.free;
        inc(fFragCounter);
     end;
   end

end;

procedure TxPLSender.SendMessage(const aMsgType : TxPLMessageType; const aDest : string; const aSchema : string; const aRawBody : string; const bClean : boolean = false);
var aMsg : TxPLCustomMessage;
begin
   aMsg := PrepareMessage(aMsgType,aSchema,aDest);
   with aMsg do begin
      Body.RawxPL := aRawBody;
      if bClean then Body.CleanEmptyValues;
      Send(aMsg);
      Free;
   end;
end;

procedure TxPLSender.SendMessage(const aRawXPL : string);
var aMsg :  TxPLCustomMessage;
begin
   aMsg := TxPLCustomMessage.Create(self, aRawxPL);
   with aMsg do begin
      Source.Assign(Adresse);
      Send(aMsg);
      Free;
   end;
end;

function TxPLSender.PrepareMessage(const aMsgType: TxPLMessageType; const aSchema : string; const aTarget : string = '*' ): TxPLCustomMessage;
begin
   result := TxPLCustomMessage.Create(self);
   with Result do begin
      Source.Assign(Adresse);
      MessageType := aMsgType;
      Target.RawxPL  := aTarget;
      Schema.RawxPL  := aSchema;
   end;
end;

function TxPLSender.PrepareMessage(const aMsgType: TxPLMessageType; const aSchema : TxPLSchema; const aTarget : TxPLTargetAddress = nil) : TxPLCustomMessage;
var sTarget : string;
begin
   if aTarget = nil then sTarget := '*' else sTarget := aTarget.RawxPL;
   result := PrepareMessage(aMsgType,aSchema.RawxPL,sTarget);
end;

procedure TxPLSender.SendMessage(const aMsgType: TxPLMessageType; const aDest, aSchema: string; const Keys, Values: array of string);
var aMsg : TxPLCustomMessage;
begin
   aMsg := PrepareMessage(aMsgType, aSchema, aDest);
   aMsg.Body.AddKeyValuePairs(Keys,Values);
   Send(aMsg);
   aMsg.Free;
end;

procedure TxPLSender.SendMessage(const aMsgType: TxPLMessageType; const aDest : string; aSchema: TxPLSchema; const Keys, Values: array of string);
begin
   SendMessage(aMsgType,aDest,aSchema.RawxPL,Keys,Values);
end;

procedure TxPLSender.SendHBeatRequestMsg;
begin
   SendMessage(cmnd,K_ADDR_ANY_TARGET,Schema_HBeatReq,['command'],['request']);
end;

procedure TxPLSender.SendOSDBasic(const aString: string);
begin
   SendMessage(cmnd,K_ADDR_ANY_TARGET,'osd.basic',['command','text'],['write',aString]);
end;

procedure TxPLSender.SendLOGBasic(const aLevel : string; const aString: string);
begin
   SendMessage(trig,K_ADDR_ANY_TARGET,'log.basic',['type','text'],[aLevel,aString]);
end;

end.

