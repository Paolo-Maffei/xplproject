unit u_xpl_udp_socket;
{==============================================================================
  UnitName      = u_xpl_udp_socket_client
  UnitDesc      = xPL specific UDP networking management handling
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 }

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , IdGlobal
     , IdUDPClient
     , IdUDPServer
     , IdSocketHandle
     , u_xpl_common
     ;

type // TxPLUDPClient =========================================================
     TxPLUDPClient = class(TIdUDPClient)                                       // Connexion used to send xPL messages
        private
           fLastSentTime : TDateTime;

        protected
           procedure InitComponent; override;

        public
           procedure   Send(const AData: string); overload;
     end;

     // TxPLUDPServer =========================================================
     TxPLUDPServer = class(TIdUDPServer)                                       // Specialized connexion used to listen to xPL messages
        private
           fOnReceived : TStrParamEvent;

        protected
           procedure DoUDPRead({%H-}AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle); override;
           procedure DoOnUDPException({%H-}AThread: TIdUDPListenerThread; {%H-}ABinding: TIdSocketHandle; const AMessage : String; const {%H-}AExceptionClass : TClass); override;

        public
           constructor Create(const AOwner: TComponent; const aMinPort : integer = XPL_MIN_PORT; const aMaxPort : integer = XPL_MAX_PORT); reintroduce;

        published
           property OnReceived : TStrParamEvent read fOnReceived write fOnReceived;

     end;

implementation //==============================================================
uses  IdStack
      , SysUtils
      , StrUtils
      , DateUtils
      , uxPLConst
      , u_xpl_application
      ;

// ============================================================================
const K_SENDING_TEMPO = 50;                                                    // Temporisation to avoid message flooding
      K_SIZE_ERROR    = '%s : message size (%d bytes) exceeds xPL limit (%d bytes)';
      K_USING_DEFAULT = 'xPL settings not set, using defaults';

// TxPLUDPClient ==============================================================
procedure TxPLUDPClient.InitComponent;
begin
   inherited;

   BroadcastEnabled := True;
   Port := XPL_UDP_BASE_PORT;
   Host := TxPLApplication(Owner).Settings.BroadCastAddress;
   fLastSentTime := now;
end;

procedure TxPLUDPClient.Send(const AData: string);
var Tempo : integer;
begin
   if length(aData) <= XPL_MAX_MSG_SIZE then begin
      Tempo := MillisecondsBetween(fLastSentTime, now);
      if Tempo < K_SENDING_TEMPO then Sleep(K_SENDING_TEMPO-Tempo);
      inherited Send(aData);
      fLastSentTime := now;
   end else
      xPLApplication.Log(etWarning,K_SIZE_ERROR,[ClassName, length(aData), XPL_MAX_MSG_SIZE])
end;

// TxPLUDPServer ===============================================================
constructor TxPLUDPServer.Create(const AOwner: TComponent; const aMinPort : integer = XPL_MIN_PORT; const aMaxPort : integer = XPL_MAX_PORT);
var address : string;
begin
   inherited Create(aOwner);

   BufferSize := XPL_MAX_MSG_SIZE;
   DefaultPort := 0;

   with xPLApplication.Settings do begin
      if not IsValid then xPLApplication.Log(etWarning,K_USING_DEFAULT);

      for address in LocalAddresses do
          if ListenOnAll or (address = ListenOnAddress) then with Bindings.Add do begin
             IP := address;
             ClientPortMin := aMinPort;
             ClientPortMax := aMaxPort;
          end;
   end;

   Active := (Bindings.Count > 0);
end;

procedure TxPLUDPServer.DoUDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
begin
   with xPLApplication.Settings do
      if Assigned(fOnReceived) and (
         ((ListenToAny) or                                                     // Accept all senders
         (ListenToLocal and (LocalAddresses.IndexOf(aBinding.PeerIP) >= 0)) or // or only accept local to this machine senders
         (AnsiPos(aBinding.PeerIP, ListenToAddresses) > 0)))                   // or sender present in specified list
      then fOnReceived(BytesToString(AData));
end;

procedure TxPLUDPServer.DoOnUDPException(AThread: TIdUDPListenerThread; ABinding: TIdSocketHandle; const AMessage: String; const AExceptionClass: TClass);
begin
   xPLApplication.Log(etWarning,'%s : %s',[ClassName,AnsiReplaceStr(aMessage,#13,' ')]);
end;

end.

