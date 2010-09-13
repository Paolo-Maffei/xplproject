unit u_xpl_udp_socket;
{==============================================================================
  UnitName      = u_xpl_udp_socket_client
  UnitDesc      = xPL specific UDP networking management handling
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Created from specific code parts of uxplmessage and uxpllistener to
        isolate xPL logic (message, listener) from UDP logic.
 }

{$mode objfpc}{$H+}

interface

uses IdGlobal,
     IdUDPClient,
     IdUDPServer,
     IdSocketHandle,
     uxPLSettings;

type TUDPReceivedEvent = procedure(const aString : string) of object;

     TxPLUDPClient = class(TIdUDPClient)
        public
           constructor Create(const aBroadCastAddress : string);
     end;

     TxPLUDPServer = class(TIdUDPServer)
        private
           fOnReceived : TUDPReceivedEvent;
           fSettings   : TxPLSettings;

           procedure AddBinding(const aIP : string);
        public
           constructor Create(const axPLSettings : TxPLSettings; const aReceivedProc : TUDPReceivedEvent);
           procedure UDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
     end;

implementation //===============================================================

uses IdStack,
     SysUtils,
     uxPLConst;

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
var i : integer;
begin
   inherited Create;
   Bindings.Clear;
   BufferSize   := MAX_XPL_MSG_SIZE;
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
   AddBinding(fSetting.ListenOnAddress);
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


end.

