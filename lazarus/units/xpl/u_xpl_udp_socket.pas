unit u_xpl_udp_socket;
{==============================================================================
  UnitName      = u_xpl_udp_socket_client
  UnitDesc      = xPL specific UDP networking management handling
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Created from specific code parts of uxplmessage and uxpllistener to
        isolate xPL logic (message, listener) from UDP logic.
 0.92 : Removed usage of uxPLConst for strictly limited to this scope constants
 }

{$mode objfpc}{$H+}

interface

uses Classes,
     IdGlobal,
     IdUDPClient,
     IdUDPServer,
     IdTelnetServer,
     IdSocketHandle,
     uxPLSettings;

type TUDPReceivedEvent = procedure(const aString : string) of object;

     TxPLUDPClient = class(TIdUDPClient)                                        // Connexion used to send xPL messages
        public
           constructor Create(const aBroadCastAddress : string);
     end;

     TxPLUDPServer = class(TIdUDPServer)                                        // Connexion used to listen to xPL messages
        private
           fOnReceived : TUDPReceivedEvent;
           fSettings   : TxPLSettings;

           procedure AddBinding(const aIP : string);
        public
           constructor Create(const axPLSettings : TxPLSettings; const aReceivedProc : TUDPReceivedEvent);
           procedure UDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
     end;

     TXHCPServer = class(TIdTelnetServer)                                       // Connexion used to listen XHCP messages
        public
           constructor Create(const aOwner : TComponent);
     end;

implementation //===============================================================
uses  IdStack,
      SysUtils;

const XPL_UDP_BASE_PORT     : Integer = 3865;
      XPL_MAX_MSG_SIZE      : Integer = 1500;                                   // Maximum size of a xpl message
      XPL_BASE_DYNAMIC_PORT : Integer = 50000;                                  // First port used to try to open the listening port
      XPL_BASE_PORT_RANGE   : Integer = 512;                                    //       Range of port to scan for trying to bind socket

// TxPLUDPClient ===============================================================
constructor TxPLUDPClient.Create(const aBroadCastAddress : string);
begin
   inherited Create;
   BroadcastEnabled := True;
   Port := XPL_UDP_BASE_PORT;
   Host := aBroadCastAddress;
end;

// TxPLUDPServer ===============================================================
constructor TxPLUDPServer.Create(const axPLSettings : TxPLSettings; const aReceivedProc : TUDPReceivedEvent);
{$IFDEF WINDOWS} var i : integer; {$ENDIF}
begin
   inherited Create;
   Bindings.Clear;
   BufferSize   := XPL_MAX_MSG_SIZE;
   OnUDPRead    := @UDPRead;
   fOnReceived  := aReceivedProc;
   fSettings    := axPLSettings;

{$IFDEF WINDOWS}
   i := gstack.LocalAddresses.Count-1;
   while i>=0 do begin
      if fSettings.ListenOnAll or
         (gStack.LocalAddresses[i] = fSettings.ListenOnAddress)
      then AddBinding(gstack.LocalAddresses[i]);
      dec(i);
   end;
{$ELSE}
   AddBinding(fSettings.ListenOnAddress);
{$ENDIF}

   If Bindings.Count > 0 then Active := True;
end;

procedure TxPLUDPServer.AddBinding(const aIP : string);
begin
   with Bindings.Add do begin
      ClientPortMin := XPL_BASE_DYNAMIC_PORT;
      ClientPortMax := ClientPortMin + XPL_BASE_PORT_RANGE;
      Port := 0;
      IP   := aIP;
   end;
end;

procedure TxPLUDPServer.UDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
begin
   if (fSettings.ListenToAny) or
      (fSettings.ListenToLocal and (gStack.LocalAddresses.IndexOf(aBinding.PeerIP) > 0)) or
      (AnsiPos(aBinding.PeerIP, fSettings.ListenToAddresses) > 0)
   then fOnReceived(BytesToString(AData));
end;

// TXHCPServer ===============================================================
constructor TXHCPServer.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);

   DefaultPort := XPL_UDP_BASE_PORT;
   LoginMessage:= '';
   Active := True;
end;

end.

