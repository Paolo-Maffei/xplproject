unit u_xpl_hub;

{$mode objfpc}{$H+}

interface

uses classes
     , IdUDPClient
     , u_xpl_custom_message
     , u_xpl_messages
     , u_xpl_udp_socket
     , u_xpl_application
     , fpc_delphi_compat
     ;

// =============================================================================
type TPortList = TStringList;

     { TxPLHub ================================================================}
     TxPLHub = class(TxPLApplication)
     private
        fInSocket   : TxPLUDPServer;                                              // Connexion used to listen incoming messages
        fSocketList : TPortList;
        fTimer      : TxPLTimer;
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
     , IdUDPBase
     , IdSocketHandle
     , CustApp
     ;

// ============================================================================
const K_ERROR_SETTINGS = 'xPL Settings may not be set ';
      K_ERROR_PORT     = 'Unabled to bind port %d : a hub may already be present';
      K_STARTED        = 'Hub started and listening on %s:%d';
      K_RELEASING      = 'No activity on port %s, released';
      K_DISCOVERED     = 'Discovered %s %s on %s';
      K_VERBOSE        = '%s => %s, %s';

// ============================================================================
procedure TxPLHub.Start;                                                       // Two reason not to start :
var Binding : TCollectionItem;
begin                                                                          //   First  : xPLSettings not set
   try                                                                         //   Second : XPL_UDP_BASE_PORT not free
      fInSocket := TxPLUDPServer.Create(self,@UDPRead, XPL_UDP_BASE_PORT);
      fInSocket.BufferSize := ID_UDP_BUFFERSIZE;                               // Remove xPL limit at hub level : the hub should relay without limiting to 1500 bytes
      if fInSocket.Active then begin
         fLocalIP  := fInSocket.Bindings[0].IP;
         for Binding in fInSocket.Bindings do
             with TIdSocketHandle(Binding) do Log(etInfo,K_STARTED,[IP,Port]);

         fMessage  := TxPLCustomMessage.Create(self);

         fSocketList := TPortList.Create;
         fSocketList.OwnsObjects := true;

         fTimer := TxPLTimer.Create(self);
         fTimer.Interval:= 60 * 1000;                                          // By specification, check every minute
         fTimer.OnTimer := @OnTimer;
         fTimer.StartTimer;
      end
      else
         Log(etError,K_ERROR_SETTINGS);
   except
      Log(etError,K_ERROR_PORT,[XPL_UDP_BASE_PORT]);
   end;
end;

destructor TxPLHub.Destroy;
begin
   fSocketList.Free;
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
var remoteip, port, s : string;
    Binding : TCollectionItem;
    aSocket : TIdUDPClient;
    i       : integer;
begin
   remoteip := aHBeatMsg.Remote_Ip;
   if remoteip='' then remoteip := fLocalIp;
   {$ifdef unix}                                                                // Related to pb under linux, see
      if remoteip = Settings.ListenOnAddress then remoteip := fLocalIP;         // xpl_udp_socket line # 131
   {$endif}

   for Binding in fInSocket.Bindings do begin
      if (TIdSocketHandle(Binding).IP = remoteip) then begin                   // The message is sent from a device located on one of my net cards
         port := IntToStr(aHBeatMsg.Port);
         i := fSocketList.IndexOfName(port);                                   // Search for the current port

         if i=-1 then begin                                                    // If not found
            aSocket := TIdUDPClient.Create(self);
            aSocket.Port:=StrToInt(port);
            {$ifdef unix}                                                       // Check if this is also appliable
            aSocket.Host:=aHBeatMsg.Remote_Ip;                                  // for windows, in this case remove compiler directives
            {$endif}
            i := fSocketList.AddObject(port+'=',aSocket);
            Log(etInfo,K_DISCOVERED,[aHBeatMsg.AppName, aHBeatMsg.Source.RawxPL,port]);
         end;

         fSocketList.ValueFromIndex[i] := DateTimeToStr(Now + (aHBeatMsg.Interval * 2 +1)/(60*24));
      end;
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
