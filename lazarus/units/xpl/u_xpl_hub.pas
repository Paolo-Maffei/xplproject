unit u_xpl_hub;

{$mode objfpc}{$H+}

interface

uses classes,
     fpTimer,
     IdUDPClient,
     uxPLCustomMessage,
     fgl,
     u_xpl_udp_socket;

type TxPLLogUpdate = procedure(const aString : string) of object;

// =============================================================================
   TDeviceRecord = class
        port     : integer;
        deadline : TDateTime;
        address  : string;
     end;
   TDeviceList = specialize TFPGList<TDeviceRecord>;

     TxPLHub = class(TObject)
     private
        fInSocket : TxPLUDPServer;                                              // Connexion used to listen incoming messages
        fOutSocket: TIdUDPClient;                                               // Connexion used to relay messages
        fDeviceList : TDeviceList;
        fTimer    : TfpTimer;
        fMessage  : TxPLCustomMessage;
        fOnLog    : TxPLLogUpdate;

        procedure UDPRead(const aString : string);
        procedure OnTimer(Sender : TObject);
        procedure HandleDevice;
        procedure HandleMessage(const aString : string);
        procedure DoLog(const aString : string);
     public
        destructor  Destroy; override;
        function    Start : boolean;
     published
        property    OnLog   : TxPLLogUpdate read fOnLog write fOnLog;
     end;

implementation // ==============================================================
uses uxPLConst,
     StrUtils,
     SysUtils,
     DateUtils;

// =============================================================================
const
     K_ERROR_SETTINGS = 'ERROR : xPL Settings may not be set ';
     K_ERROR_PORT     = 'ERROR when trying to attach port %d, check it is free';
     K_STARTED        = 'Hub started and listening';
     K_BINDED         = ' binded on %s : %d';
     K_RELEASING      = 'No activity on port %d, %s released';
     K_DISCOVERED     = 'Discovered %s on %d';

// =============================================================================
destructor TxPLHub.Destroy;
begin
  fInSocket.Free;
  fDeviceList.Free;
  fTimer.Free;
  fOutSocket.Free;
  inherited;
end;

function TxPLHub.Start : boolean;                                               // Two reason not to start :
var i : integer;
begin                                                                           //     First  : xPLSettings not set
   try                                                                          //     Second : XPL_UDP_BASE_PORT not free
      fInSocket := TxPLUDPServer.Create(@UDPRead, XPL_UDP_BASE_PORT);
      if not fInSocket.Active then DoLog(K_ERROR_SETTINGS);
   except
      result := false;
      DoLog(Format(K_ERROR_PORT,[XPL_UDP_BASE_PORT]));
   end;
   if Assigned(fInSocket) then result := fInSocket.Active;

   if not result then exit;

   DoLog(K_STARTED);
   for i := 0 to fInSocket.Bindings.Count-1 do
       DoLog(Format(K_BINDED,[fInSocket.Bindings[i].IP,fInSocket.Bindings[i].Port]));

   fDeviceList := TDeviceList.Create;

   fMessage := TxPLCustomMessage.Create;

   fTimer   := TfpTimer.Create(nil);
   fTimer.Interval:= 60 * 1000;                                                // By specification, check every minute
   fTimer.OnTimer := @OnTimer;
   fTimer.StartTimer;

   fOutSocket := TIdUdpClient.Create(nil);
   fOutSocket.Host:=fInSocket.Bindings[0].IP;
end;

procedure TxPLHub.UDPRead(const aString: string);
begin
   fMessage.RawXPL := aString;                                                 // Get the message

   if (fMessage.MessageType= K_MSG_TYPE_STAT) and                              // Check if it is a heart beat
      (AnsiIndexStr(fMessage.Schema.RawxPL,[K_SCHEMA_CONFIG_APP,K_SCHEMA_HBEAT_APP,K_SCHEMA_HBEAT_END])<>-1)
   then HandleDevice;                                                          // if this is the case, see if I already recorded it

   HandleMessage(aString);                                                     // Relay the message
end;

procedure TxPLHub.OnTimer(Sender: TObject);
var i : integer;
begin
   i := fDeviceList.Count - 1;
   while (i>0) do begin                                                        // Search for devices I didn't heard of
      dec(i);                                                                  // since a long time
      if fDeviceList[i].Deadline  < now then begin
         DoLog(Format(K_RELEASING,[ fDeviceList[i].port,
                                    fDeviceList[i].address ]));
         fDeviceList.Delete(i);
      end;
   end;
end;

procedure TxPLHub.HandleDevice;
   function SeekPort(const aPort : integer) : integer;
   begin
      result := fDeviceList.Count - 1;
      while (result >= 0) and (fDeviceList[result].port <> aPort) do
         dec(result);
   end;

var port : integer;
    remoteip : string;
    bLocal : boolean;
    i,interval : integer;
begin
   remoteip := fMessage.Body.GetValueByKey(K_HBEAT_ME_REMOTEIP, fInSocket.Bindings[0].IP); // If no remote-ip param present, let's assume it's local

   bLocal := false;
   for i:=0 to fInSocket.Bindings.Count-1 do
       bLocal := (blocal or (fInSocket.Bindings[i].IP = remoteip));

   if not bLocal then exit;                                                     // The message is sent from a device located on one of my net cards

   port := StrToInt(fMessage.Body.GetValueByKey(K_HBEAT_ME_PORT));
   interval := 2 * StrToIntDef(fMessage.Body.GetValueByKey(K_HBEAT_ME_INTERVAL),MIN_HBEAT) + 1; // Defined by specifications as dead-line limit
   i := SeekPort(port);
   if i = -1 then begin                                                               // The application is known
      i := fDeviceList.Add(TDeviceRecord.Create);
      fDeviceList[i].port := port;
      DoLog(Format(K_DISCOVERED,[fMessage.Header.Source.RawxPL,port]));
   end;
   fDeviceList[i].deadline := IncMinute(Now,interval);
end;

procedure TxPLHub.HandleMessage(const aString: string);
var i : integer;
begin
   for i:=0 to fDeviceList.Count-1 do begin
      fOutSocket.Port:= fDeviceList[i].port;
      fOutSocket.Send(aString);
   end;
end;

procedure TxPLHub.DoLog(const aString: string);
begin
   if Assigned(OnLog) then OnLog(aString);
end;

end.

