unit u_xpl_sender;
{===============================================================================
  UnitName      = u_xpl_sender
  UnitDesc      = xPL Sender object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ===============================================================================
  0.8 : First version, spined off from uxPLMessage
}
{$mode objfpc}{$H+}

interface

uses Classes,
     uxPLConst,
     uxPLClient,
     uxPLMessage,
     uxPLAddress,
     u_xpl_udp_socket;

type

{ TxPLSender }

     TxPLSender = class(TxPLClient)
        fSocket : TxPLUDPClient;
     protected
        procedure Send(const aMessage : string);      overload;
     public
        property Address             : TxPLAddress read fAdresse;
        property Instance            : string read fAdresse.fInstance;

        constructor create(const aVendor : tsVendor; const aDevice : tsDevice; const aAppVersion : string);
        destructor destroy; override;

        procedure Send(const aMessage : TxPLMessage);
        procedure SendMessage(const aMsgType : tsMsgType; const aDest, aSchema : string; const aRawBody : string; const bClean : boolean = false);
        procedure SendMessage(const aMsgType : tsMsgType; const aDest, aSchema : string; const Keys, Values : Array of string);
        procedure SendMessage(const aRawXPL : string); overload;
        procedure SendOSDBasic(const aString : string);
        procedure SendLOGBasic(const aLevel : string; const aString : string);
        function  PrepareMessage(const aMsgType: tsMsgType; const aSchema : string; const aTarget : string = '*') : TxPLMessage;
        procedure SendConfigRequestMsg(const aTarget : string);
        procedure SendHBeatRequestMsg;
     end;

implementation { ==============================================================}
constructor TxPLSender.create(const aVendor: tsVendor; const aDevice: tsDevice; const aAppVersion: string);
begin
  inherited create(aVendor, aDevice, aAppVersion);
  fSocket := TxPLUDPClient.Create(Settings.BroadCastAddress);
end;

destructor TxPLSender.destroy;
begin
  fSocket.Destroy;
  inherited destroy;
end;

procedure TxPLSender.Send(const aMessage: string);
begin
  fSocket.Send(aMessage);
end;

procedure TxPLSender.Send(const aMessage: TxPLMessage);
begin
  aMessage.Source.Assign(Address);                                              // Let's be sure I'm identified as the sender
  Send(aMessage.ProcessedxPL);
end;

procedure TxPLSender.SendMessage(const aMsgType : tsMsgType; const aDest : string; const aSchema : string; const aRawBody : string; const bClean : boolean = false);
var aMsg : TxPLMessage;
begin
   aMsg := PrepareMessage(aMsgType,aSchema,aDest);
   with aMsg do begin
      Body.RawxPL := aRawBody;
      if bClean then Body.CleanEmptyValues;
      Send(aMsg);
      Destroy;
   end;
end;

procedure TxPLSender.SendMessage(const aRawXPL : string);
var aMsg :  TxPLMessage;
begin
   aMsg := TxPLMessage.Create(aRawxPL);
   with aMsg do begin
      Source.Assign(Adresse);
      if IsValid then Send(aMsg)
                 else LogError('Error sending message : %s',[RawXPL]);
      Destroy;
   end;
end;

function TxPLSender.PrepareMessage(const aMsgType: tsMsgType; const aSchema : string; const aTarget : string = '*' ): TxPLMessage;
begin
  result := TxPLMessage.Create;
  with Result do begin
     Source.Assign(Adresse);
     MessageType := aMsgType;
     Target.Tag  := aTarget;
     Schema.Tag  := aSchema;
  end;
end;

procedure TxPLSender.SendOSDBasic(const aString: string);
begin
   SendMessage(K_MSG_TYPE_CMND,K_MSG_TARGET_ANY,K_SCHEMA_OSD_BASIC,['command','text'],['write',aString]);
end;

procedure TxPLSender.SendLOGBasic(const aLevel : string; const aString: string);
begin
   SendMessage(K_MSG_TYPE_TRIG,K_MSG_TARGET_ANY,K_SCHEMA_LOG_BASIC,['type','text'],[aLevel,aString]);
end;

procedure TxPLSender.SendMessage(const aMsgType: tsMsgType; const aDest, aSchema: string; const Keys, Values: array of string);
var aMsg : TxPLMessage;
//    i : integer;
begin
   aMsg := PrepareMessage(aMsgType, aSchema, aDest);
   aMsg.Body.AddKeyValuePairs(Keys,Values);
//   for i := low(Keys) to High(Keys) do
//       aMsg.Body.AddKeyValuePair(Keys[i],Values[i]);
   Send(aMsg);
   aMsg.Destroy;
end;

procedure TxPLSender.SendConfigRequestMsg(const aTarget : string);
begin
   SendMessage(K_MSG_TYPE_CMND,aTarget,K_SCHEMA_CONFIG_LIST,['command'],['request']);
   SendMessage(K_MSG_TYPE_CMND,aTarget,K_SCHEMA_CONFIG_CURRENT,['command'],['request']);
end;

procedure TxPLSender.SendHBeatRequestMsg;
begin
   SendMessage(K_MSG_TYPE_CMND,K_MSG_TARGET_ANY,K_SCHEMA_HBEAT_REQUEST,['command'],['request']);
end;

end.

