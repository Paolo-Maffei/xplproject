unit u_xpl_hub;

{$mode objfpc}{$H+}

interface

uses classes
     , IdUDPClient
     , u_xpl_messages
     , u_xpl_udp_socket
     , u_xpl_application
     , u_xpl_custom_message
     ;

// ============================================================================
type TPortList = TStringList;

     // TxPLHub ===============================================================
     TxPLHub = class(TxPLApplication)
     private
        fInSocket   : TxPLUDPServer;                                           // Connexion used to listen incoming messages
        fSocketList : TPortList;
        fMessage    : TxPLCustomMessage;
        fLocalIP    : string;

        procedure HandleDevice (const aHBeatMsg : THeartBeatMsg);
        procedure UDPRead      (const aString : string);
        procedure OnTimer      (Sender : TObject);

     public
        destructor  Destroy; override;
        procedure   Start;
     end;

implementation // =============================================================
uses SysUtils
     , CustApp
     , IdUDPBase
     ;
// ============================================================================
const K_ERROR_SETTINGS = 'Network settings may not be set ';
      K_ERROR_PORT     = 'Unabled to bind port %d : a hub may already be present';
      K_STARTED        = 'Hub started';
      K_LISTENING      = 'Listening on %s:%d';
      K_RELEASING      = 'No activity on port %s, released';
      K_DISCOVERED     = 'Discovered %s %s on %s';
      K_INVALID_PORT   = 'Discovered %s but invalid port (%s) in message body';
      K_VERBOSE        = '%s => %s, %s';
      XPL_UDP_BASE_PORT= 3865;

// ============================================================================
procedure TxPLHub.Start;                                                       // Two reason not to start :
var i : integer;
begin                                                                          //   First  : xPLSettings not set
   try                                                                         //   Second : XPL_UDP_BASE_PORT not free
      fInSocket := TxPLUDPServer.Create(self,XPL_UDP_BASE_PORT,XPL_UDP_BASE_PORT);
      fInSocket.BufferSize := ID_UDP_BUFFERSIZE;                               // Remove xPL limit at hub level : the hub should relay without limiting to 1500 bytes
      if fInSocket.Active then begin
         fInSocket.OnReceived := @UDPRead;
         Log(etInfo,K_STARTED);
         fLocalIP := fInSocket.Bindings[0].IP;
         for i := 0 to Pred(fInSocket.Bindings.Count) do
             Log(etInfo,K_LISTENING,[fInSocket.Bindings[i].IP,fInSocket.Bindings[i].Port]);

         fMessage  := TxPLCustomMessage.Create(self);

         fSocketList := TPortList.Create;
         fSocketList.OwnsObjects := true;

         xPLApplication.TimerPool.Add(60*1000, @OnTimer).StartTimer;           // By specification, check every minute
      end
      else
         Log(etError,K_ERROR_SETTINGS);
   except
      Log(etError,K_ERROR_PORT,[XPL_UDP_BASE_PORT]);
   end;
end;

destructor TxPLHub.Destroy;
begin
   if Assigned(fSocketList) then fSocketList.Free;
   inherited;
end;

procedure TxPLHub.UDPRead(const aString: string);
var i  : integer;
begin

   fMessage.RawXPL := aString;                                                 // Check if it is a heart beat
   if fMessage.IsLifeSign then HandleDevice(THeartBeatMsg(fMessage));          // if this is the case, see if I already recorded it

   if TCustomApplication(Owner).HasOption('v') then
      writeln( Format(K_VERBOSE,[fMessage.source.RawxPL,fMessage.target.RawxPL,fMessage.schema.RawxPL]));

   for i:=0 to Pred(fSocketList.Count) do
       TIdUDPClient(fSocketList.Objects[i]).Send(aString);                     // relaying the message
end;

procedure TxPLHub.HandleDevice(const aHBeatMsg : THeartBeatMsg);
var remoteip, port : string;
    aSocket : TIdUDPClient;
    c,i       : integer;
begin
   remoteip := aHBeatMsg.Remote_Ip;
   if remoteip='' then remoteip := fLocalIp;
   {$ifdef unix}                                                               // Related to pb under linux, see
      if remoteip = Settings.ListenOnAddress then remoteip := fLocalIP;        // xpl_udp_socket line # 131
   {$endif}

   for c:=0 to Pred(fInSocket.Bindings.Count) do begin
       if (fInSocket.Bindings[c].IP = remoteip) then                           // The message is sent from a device located on one of my net cards
         if (aHBeatMsg.Port<>-1) then begin
            port := IntToStr(aHBeatMsg.Port);
            i := fSocketList.IndexOfName(port);                                // Search for the current port

            if i=-1 then begin                                                 // If not found
               aSocket := TIdUDPClient.Create(self);
               aSocket.Port:=StrToInt(port);
               i := fSocketList.AddObject(port+'=',aSocket);
               Log(etInfo,K_DISCOVERED,[aHBeatMsg.AppName, aHBeatMsg.Source.RawxPL,port]);
            end;
            fSocketList.ValueFromIndex[i] := DateTimeToStr(Now + (aHBeatMsg.Interval * 2 +1)/(60*24));
         end else
            Log(etWarning,K_INVALID_PORT,[aHBeatMsg.AppName,aHBeatMsg.port]);
       end;
end;

procedure TxPLHub.OnTimer(Sender: TObject);
var i  : integer;
begin
   i := Pred(fSocketList.Count);
   while( i>=0) do begin
      if StrToDateTime(fSocketList.ValueFromIndex[i]) < now then begin
         Log(etInfo, K_RELEASING, [ fSocketList.Names[i] ]);
         fSocketList.Delete(i);
      end;
      dec(i);
   end;
end;

end.

