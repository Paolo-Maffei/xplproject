unit app_main;

{$i compiler.inc}

interface

uses classes,
     fpTimer,
     IdUDPClient,
     uxPLCustomMessage,
     u_xpl_udp_socket;

type

{ TxPLHub }

TxPLHub = class(TObject)
     private
        fInSocket : TxPLUDPServer;                                              // Connexion used to listen incoming messages
        fOutSocket: TIdUDPClient;
        fBindings : TStringList;
        fDevices  : TStringList;
        fTimer    : TfpTimer;
        fMessage  : TxPLCustomMessage;

        procedure UDPRead(const aString : string);
        procedure OnTimer(Sender : TObject);
        procedure HandleDevice;
        procedure HandleMessage(const aString : string);
     public
        constructor Create;
        destructor  Destroy; override;
        function    Start : boolean;
     published
        property Bindings: TStringlist read fBindings;
     end;

var  xPLHub      : TxPLHub;

//==============================================================================
const
     K_XPL_APP_VERSION_NUMBER = '3.0';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'hub';

implementation //===============================================================
uses SysUtils,
     StrUtils,
     DateUtils,
     uxPLConst;

{ TxPLHub }

procedure TxPLHub.UDPRead(const aString: string);
begin
   fMessage.RawXPL := aString;

   if (fMessage.MessageType= K_MSG_TYPE_STAT) and
      (AnsiIndexStr(fMessage.Schema.RawxPL,[K_SCHEMA_CONFIG_APP,K_SCHEMA_HBEAT_APP,K_SCHEMA_HBEAT_END])<>-1)
      then HandleDevice;

   HandleMessage(aString);
end;

procedure TxPLHub.OnTimer(Sender: TObject);
var i : integer;
    deadline : TDateTime;
begin
   i:=fDevices.Count - 1;
   while (i>0) do begin
      dec(i);
      deadline := StrToFloat(fDevices.ValueFromIndex[i]);
      if deadline < now then fDevices.Delete(i);
   end;
end;

procedure TxPLHub.HandleDevice;
var port, remoteip : string;
    bLocal : boolean;
    i,interval : integer;
begin
   remoteip := fMessage.Body.GetValueByKey(K_HBEAT_ME_REMOTEIP, fInSocket.Bindings[0].IP); // If no remote-ip param present, let's assume it's local

   for i:=0 to fInSocket.Bindings.Count-1 do
       bLocal := (blocal or (fInSocket.Bindings[i].IP = remoteip));

   if bLocal then begin                                                         // The message is sent from a device located on one of my net cards
      port := fMessage.Body.GetValueByKey(K_HBEAT_ME_PORT);
      interval := 2 * StrToIntDef(fMessage.Body.GetValueByKey(K_HBEAT_ME_INTERVAL),MIN_HBEAT) + 1; // Defined by specifications as dead-line limit
      i := fDevices.IndexOfName(port);
      if i<>-1 then begin                                                       // The application is known
         fDevices.ValueFromIndex[i] := FloatToStr(IncMinute(Now,interval));  // The object stores the next deadline for receiving an hbeat message
      end else begin
         fDevices.Add(port + '=' + FloatToStr(IncMinute(Now,interval)));
      end;
   end;
end;

procedure TxPLHub.HandleMessage(const aString: string);
var i : integer;
begin
   for i:=0 to fDevices.Count-1 do begin
      fOutSocket.Host:=fInSocket.Bindings[0].IP;
      fOutSocket.Port:=StrToInt(fDevices.Names[i]);
      fOutSocket.Send(aString);
   end;
end;

constructor TxPLHub.Create;
begin
  inherited;
  fBindings := TStringList.Create;
end;

destructor TxPLHub.Destroy;
begin
  fInSocket.Free;
  fBindings.Free;
  fDevices.Free;
  fTimer.Free;
  fOutSocket.Free;
  inherited;
end;

function TxPLHub.Start : boolean;                                               // Two reason not to start :
var i : integer;
begin                                                                           //     First  : xPLSettings not set
   try                                                                          //     Second : XPL_UDP_BASE_PORT not free
      fInSocket := TxPLUDPServer.Create(@UDPRead, XPL_UDP_BASE_PORT);
   except
      result := false;
   end;
   if Assigned(fInSocket) then result := fInSocket.Active;

   if result then begin
      for i := 0 to fInSocket.Bindings.Count-1 do
         Bindings.Add(fInSocket.Bindings[i].IP + ':' + IntToStr(fInSocket.Bindings[i].Port));
      fDevices := TStringList.Create;
      fMessage := TxPLCustomMessage.Create;
      fTimer   := TfpTimer.Create(nil);
      fTimer.Interval:= 60 * 1000;                                                // By specification, check every minute
      fTimer.OnTimer := @OnTimer;
      fTimer.StartTimer;
      fOutSocket := TIdUdpClient.Create(nil);
   end;
end;

end.

