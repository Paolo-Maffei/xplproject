unit u_xpl_hub;

{$mode objfpc}{$H+}

interface

uses classes
     , IdUDPClient
     , u_xpl_custom_message
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

        procedure UDPRead(const aString : string);
        procedure OnTimer(Sender : TObject);
        procedure HandleDevice;
     public
        destructor  Destroy; override;
        procedure    Start;
     end;

implementation // =============================================================
uses SysUtils
     , uxPLConst
     , IdSocketHandle
     ;

// ============================================================================
const
     K_ERROR_SETTINGS = 'xPL Settings may not be set ';
     K_ERROR_PORT     = 'Unabled to bind port %d : a hub may already be present';
     K_STARTED        = 'Hub started and listening on %s:%d';
     K_RELEASING      = 'No activity on port %s, released';
     K_DISCOVERED     = 'Discovered %s on %s';

// ============================================================================
procedure TxPLHub.Start;                                                       // Two reason not to start :
var Binding : TCollectionItem;
begin                                                                          //   First  : xPLSettings not set
   try                                                                         //   Second : XPL_UDP_BASE_PORT not free
      fInSocket := TxPLUDPServer.Create(self,@UDPRead, XPL_UDP_BASE_PORT);
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
   if fMessage.IsLifeSign then HandleDevice;                                   // if this is the case, see if I already recorded it

   for i:=0 to Pred(fSocketList.Count) do
       TIdUDPClient(fSocketList.Objects[i]).Send(aString);                     // relaying the message
end;

procedure TxPLHub.HandleDevice;
var interval : integer;
    remoteip, port : string;
    Binding : TCollectionItem;
    aSocket : TIdUDPClient;
    i       : integer;
begin
   remoteip := fMessage.Body.GetValueByKey(K_HBEAT_ME_REMOTEIP, fLocalIP);     // If no remote-ip param present, let's assume it's local

   for Binding in fInSocket.Bindings do
      if (TIdSocketHandle(Binding).IP = remoteip) then begin                   // The message is sent from a device located on one of my net cards
         port := fMessage.Body.GetValueByKey(K_HBEAT_ME_PORT);
         interval := StrToIntDef(fMessage.Body.GetValueByKey(K_HBEAT_ME_INTERVAL),MIN_HBEAT) * 2 + 1; // Defined by specifications as dead-line limit

         i := fSocketList.IndexOfName(port);                                   // Search for the current port

         if i=-1 then begin                                                    // If not found
            aSocket := TIdUDPClient.Create(self);
            aSocket.Port:=StrToInt(port);
            i := fSocketList.AddObject(port+'=',aSocket);
            Log(etInfo,K_DISCOVERED,[fMessage.Source.RawxPL,port]);
         end;

         fSocketList.ValueFromIndex[i] := DateTimeToStr(Now + interval/(60*24));
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

