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
     , uIP
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
           function InternalGetUsableAddress(const aIPAdd : TIPAddress) : string; virtual; abstract;
           function InternalCheckIncoming(const {%H-}aPeerIP : string) : boolean; virtual;
           function InternalGetMaxBufferSize : integer; virtual; abstract;
           procedure DoUDPRead({%H-}AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle); override;
           procedure DoOnUDPException({%H-}AThread: TIdUDPListenerThread; {%H-}ABinding: TIdSocketHandle; const AMessage : String; const {%H-}AExceptionClass : TClass); override;
           procedure AfterBind(Sender: TObject);
           procedure BeforeBind(AHandle: TIdSocketHandle);

        public
           constructor Create(const AOwner: TComponent; const aMinPort : integer = XPL_MIN_PORT; const aMaxPort : integer = XPL_MAX_PORT); reintroduce;

        published
           property OnReceived : TStrParamEvent read fOnReceived write fOnReceived;
     end;

     // THubServer ============================================================
     THubServer = class(TxPLUDPServer)
     protected
         function InternalGetUsableAddress(const aIPAdd : TIPAddress) : string; override;
         function InternalCheckIncoming(const aPeerIP : string) : boolean; override;
         function InternalGetMaxBufferSize : integer; override;
     public
        constructor Create(const AOwner: TComponent); reintroduce;
     end;

     // TAppServer ============================================================
     TAppServer = class(TxPLUDPServer)
     protected
         function InternalGetUsableAddress(const aIPAdd : TIPAddress) : string; override;
         function InternalGetMaxBufferSize : integer; override;
     end;

implementation //==============================================================
uses  IdStack
      , IdUDPBase
      , SysUtils
      , StrUtils
      , DateUtils
      , lin_win_compat
      , uxPLConst
      , u_xpl_application
      ;

// ============================================================================
const K_SENDING_TEMPO = 50;                                                    // Temporisation to avoid message flooding
      XPL_UDP_BASE_PORT= 3865;
      K_SIZE_ERROR    = '%s : message size (%d bytes) exceeds xPL limit (%d bytes)';
      K_USING_DEFAULT = 'xPL network settings not set, using defaults';

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

// TxPLHubServer ==============================================================
constructor THubServer.Create(const AOwner: TComponent);
begin
   inherited Create(aOwner,XPL_UDP_BASE_PORT,XPL_UDP_BASE_PORT);
end;

function THubServer.InternalGetUsableAddress(const aIPAdd: TIPAddress): string;
begin                                                                          // hub will listen on broadcast addresses
   Result := aIPAdd.BroadCast;
end;

function THubServer.InternalCheckIncoming(const aPeerIP: string): boolean;
begin
   with xPLApplication.Settings do
        Result := ListenToAny or
                  (ListenToLocal and Assigned(LocalIPAddresses.GetByIP(aPeerIP))) or
                  (AnsiPos(aPeerIP,ListenToAddresses) > 0);
   Result := Result and inherited;
end;

function THubServer.InternalGetMaxBufferSize: integer;
begin
   Result := ID_UDP_BUFFERSIZE;                                                // Remove xPL limit at hub level : the hub should relay without limiting to 1500 bytes
end;

// TxPLAppServer ==============================================================
function TAppServer.InternalGetUsableAddress(const aIPAdd: TIPAddress): string;
begin                                                                         // apps will listen on specific addresses
   Result := aIPAdd.Address;
end;

function TAppServer.InternalGetMaxBufferSize: integer;
begin
   Result := XPL_MAX_MSG_SIZE;
end;

// TxPLUDPServer ===============================================================
constructor TxPLUDPServer.Create(const AOwner: TComponent; const aMinPort : integer = XPL_MIN_PORT; const aMaxPort : integer = XPL_MAX_PORT);
var address : TIPAddress;
begin
   inherited Create(aOwner);
   BufferSize := InternalGetMaxBufferSize;
   DefaultPort := 0;
   OnUDPException:=@DoOnUDPException;
   OnAfterBind:=@AfterBind;
   OnBeforeBind:=@BeforeBind;
   with TxPLApplication(aOwner).Settings do begin
      if not IsValid then xPLApplication.Log(etWarning,K_USING_DEFAULT);

      for address in LocalIPAddresses do
          if ListenOnAll or (address.Address = ListenOnAddress) then
          with Bindings.Add do begin
             IP := InternalGetUsableAddress(Address);
             ClientPortMin := aMinPort;
             ClientPortMax := aMaxPort;
          end;
   end;

   Active := (Bindings.Count > 0);
end;

function TxPLUDPServer.InternalCheckIncoming(const aPeerIP: string): boolean;
begin
   Result := Assigned(fOnReceived);
end;

procedure TxPLUDPServer.DoUDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
begin
   if InternalCheckIncoming(aBinding.PeerIP)
      then fOnReceived(BytesToString(aData));
end;

procedure TxPLUDPServer.DoOnUDPException(AThread: TIdUDPListenerThread; ABinding: TIdSocketHandle; const AMessage: String; const AExceptionClass: TClass);
begin
   xPLApplication.Log(etWarning,'%s : %s',[ClassName,AnsiReplaceStr(aMessage,#13,' ')]);
end;

procedure TxPLUDPServer.AfterBind(Sender: TObject);
begin
   xPLApplication.Log(etInfo,'Connected',[]);;
end;

procedure TxPLUDPServer.BeforeBind(AHandle: TIdSocketHandle);
begin
   xPLApplication.Log(etInfo,'Binding on %s:%d',[aHandle.IP,aHandle.ClientPortMin]);
end;

end.
