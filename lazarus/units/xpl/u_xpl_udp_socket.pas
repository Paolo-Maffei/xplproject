unit u_xpl_udp_socket;
{==============================================================================
  UnitName      = u_xpl_udp_socket_client
  UnitDesc      = xPL specific UDP networking management handling
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Created from specific code parts of uxplmessage and uxpllistener to
        isolate xPL logic (message, listener) from UDP logic.
 0.92 : Removed all calls to Indy gStack witch has big problems in determining
        localaddresses - replaced by synamisc
 }

{$mode objfpc}{$H+}

interface

uses Classes
     , IdGlobal
     , IdUDPClient
     , IdUDPServer
     , IdHTTPServer
     , IdTelnetServer
     , IdSocketHandle
     , u_xpl_common
     ;

const XPL_UDP_BASE_PORT     : Integer = 3865;                                   // Port used by devices to send messages

type { TxPLUDPClient ==========================================================}
     TxPLUDPClient = class(TIdUDPClient)                                        // Connexion used to send xPL messages
        public
           constructor Create(const aOwner : TComponent; const aBroadCastAddress : string);
     end;

     { TxPLUDPServer ==========================================================}
     TxPLUDPServer = class(TIdUDPServer)                                        // Connexion used to listen to xPL messages
        private
           fOnReceived : TStrParamEvent;

           procedure AddBinding(const aIP : string; const aPort : integer);
           procedure UDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
        public
           constructor Create(
                       const aOwner : TComponent;
                       const aReceivedProc : TStrParamEvent;                    // Callback procedure used to deliver read messages
                       const aPort : integer = 0);                              // Port used for the binding, 0 = dynamic

        published
           property    Bindings: TIdSocketHandles read FBindings;               // Inherited property
     end;

     { TXHCPServer ============================================================}
     TXHCPServer = class(TIdTelnetServer)                                       // Connexion used to listen XHCP messages
        public
           constructor Create(const aOwner : TComponent);
     end;

     { TWebServer =============================================================}
     TWebServer = class(TIdHTTPServer)
        public
           constructor Create(const aOwner : TComponent);
     end;

implementation //==============================================================
uses  IdStack
      , SysUtils
      , uxPLConst
      , u_xpl_application
      ;

// =============================================================================
const XPL_MAX_MSG_SIZE      : Integer = 1500;                                   // Maximum size of a xpl message
      XPL_BASE_DYNAMIC_PORT : Integer = 50000;                                  // First port used to try to open the listening port
      XPL_BASE_PORT_RANGE   : Integer = 512;                                    //       Range of port to scan for trying to bind socket

// TxPLUDPClient ===============================================================
constructor TxPLUDPClient.Create(const aOwner : TComponent; const aBroadCastAddress : string);
begin
   inherited Create(aOwner);
   BroadcastEnabled := True;
   Port := XPL_UDP_BASE_PORT;
   Host := aBroadCastAddress;
end;

// TxPLUDPServer ===============================================================
constructor TxPLUDPServer.Create(const aOwner : TComponent; const aReceivedProc : TStrParamEvent; const aPort : integer = 0);
{$IFDEF WINDOWS}
   var i : integer;
{$ENDIF}
begin
   inherited Create(aOwner);
   Bindings.Clear;
   BufferSize   := XPL_MAX_MSG_SIZE;
   OnUDPRead    := @UDPRead;
   fOnReceived  := aReceivedProc;
   if TxPLApplication(aOwner).Settings.IsValid then with TxPLApplication(aOwner).Settings do begin
      {$IFDEF WINDOWS}
      i := LocalAddresses.Count-1;
      while i>=0 do begin
            if ListenOnAll or (LocalAddresses[i] = ListenOnAddress)
               then AddBinding(LocalAddresses[i], aPort);
            dec(i);
      end;
      {$ELSE}
      AddBinding(fSettings.ListenOnAddress);
      {$ENDIF}
   end else xPLApplication.Log(etWarning,'xPL settings not set, using default');
   Active := (Bindings.Count > 0);
end;

procedure TxPLUDPServer.AddBinding(const aIP : string; const aPort : integer);
begin
   with Bindings.Add do begin
      IP := aIP;
      if aPort = 0 then begin                                                   // Dynamically assign port
         ClientPortMin := XPL_BASE_DYNAMIC_PORT;
         ClientPortMax := ClientPortMin + XPL_BASE_PORT_RANGE;
         Port := aPort;
      end
      else                                                                      // Fixed assigned port
         Port := aPort;
   end;
end;

procedure TxPLUDPServer.UDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
begin
   with TxPLApplication(Owner).Settings do begin
        if (ListenToAny) or
           (ListenToLocal) and (LocalAddresses.IndexOf(aBinding.PeerIP) >= 0) or
           (AnsiPos(aBinding.PeerIP, ListenToAddresses) > 0)
        then fOnReceived(BytesToString(AData));
   end;
end;

// TXHCPServer ===============================================================
constructor TXHCPServer.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);

   DefaultPort  := XPL_UDP_BASE_PORT;
   LoginMessage := '';
   Active       := True;
end;

// TWebServer =================================================================
constructor TWebServer.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);

   with Bindings.Add do begin                                                  // Dynamically assign port
        IP:=K_IP_LOCALHOST;
        ClientPortMin := XPL_BASE_DYNAMIC_PORT;
        ClientPortMax := ClientPortMin + XPL_BASE_PORT_RANGE;
        Port := 0;
   end;

   //if TxPLApplication(Owner).Settings.ListenOnAddress<>K_IP_LOCALHOST then with Bindings.Add do begin
   //     IP:=TxPLApplication(Owner).Settings.ListenOnAddress;
   //     ClientPortMin := XPL_BASE_DYNAMIC_PORT;
   //     ClientPortMax := ClientPortMin + XPL_BASE_PORT_RANGE;
   //     Port := 0;
   // end;

    AutoStartSession := True;
    SessionTimeOut := 600000;
    SessionState := True;
end;

end.

