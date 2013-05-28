unit u_xpl_custom_listener;

{==============================================================================
  UnitName      = uxPLListener
  UnitDesc      = xPL Listener object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Seperation of basic xPL Client (listener and sender) from pure listener
 0.92 : Modification made to avoid handling of my own emitted messages
 0.94 : Removed bHubfound, redondant with JoinedxPLNetwork
        Removed bConfigOnly, redondant with AwaitingConfiguration
 0.94 : Replacement of TTimer with TfpTimer
 0.97 : Removed field AwaitingConfiguration that was redundant with Config.ConfigNeeded
 0.98 : Added SeeAll variable to enable logger to see messages not targetted to him
 1.00 : Added descendance from TxPLSender functionalities extracted from xPLMessage
 1.01 : Suppressed HBReqTimer, fusionned with hBTimer to avoid the app to answering
        both to a hbeat request and a few seconds after to send it's own hbeat
 1.03 : Added detection of lost xPL network connectivity
}

{$ifdef fpc}
{$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses Classes
     , SysUtils
     , u_xpl_common
     , u_xpl_udp_socket
     , u_xpl_message
     , u_xpl_config
     , u_xpl_heart_beater
     , u_xpl_body
     , u_xpl_sender
     , fpc_delphi_compat
     ;

type TxPLReceivedEvent = procedure(const axPLMsg: TxPLMessage) of object;
     TxPLConfigDone = procedure(const aConfig: TxPLCustomConfig) of object;
     TxPLHBeatPrepare = procedure(const aBody: TxPLBody) of object;

     // TxPLCustomListener ====================================================
     TxPLCustomListener = class(TxPLSender)
        private
           fConfig: TxPLCustomConfig;
           fCfgFname: string;
           fProbingTimer: TxPLTimer;
           IncomingSocket: TAppServer;
           Connection: TxPLConnHandler;

          procedure NoAnswerReceived({%H-}Sender: TObject);

        protected
           function Get_ConnectionStatus: TConnectionStatus;
           procedure Set_ConnectionStatus(const aValue : TConnectionStatus); virtual;

        public
           OnxPLReceived: TxPLReceivedEvent;
           OnPreProcessMsg: TxPLReceivedEvent;
           OnxPLConfigDone: TxPLConfigDone;
           OnxPLHBeatPrepare: TxPLHBeatPrepare;
           OnxPLHBeatApp: TxPLReceivedEvent;
           OnxPLJoinedNet: TNoParamEvent;

           constructor Create(const aOwner: TComponent); reintroduce;
           destructor Destroy; override;

           procedure SaveConfig; dynamic;
           procedure LoadConfig; dynamic;
           procedure UpdateConfig; dynamic;
           procedure Listen; dynamic;

           procedure HandleConfigMessage(aMessage: TxPLMessage); dynamic;
           procedure SendHeartBeatMessage; dynamic;
           function ConnectionStatusAsStr: string;


           function DoHBeatApp(const aMessage: TxPLMessage): boolean; dynamic;
           function DoxPLReceived(const aMessage: TxPLMessage): boolean; dynamic;
           procedure UDPRead(const aString: string);

        published
           property Config: TxPLCustomConfig read fConfig;
           property ConnectionStatus : TConnectionStatus read Get_ConnectionStatus write Set_ConnectionStatus stored false;
        end;

implementation // =============================================================

uses u_xpl_schema
     , u_xpl_messages
     ;

const K_MSG_BIND_OK = 'Listening on %s:%u';
      K_MSG_CONFIG_LOADED = 'Configuration loaded for %s';
      K_MSG_CONFIG_WRITEN = 'Configuration saved to %s';
      K_MSG_IP_ERROR = 'Socket unable to bind to IP Addresses';
      K_MSG_UDP_ERROR = 'Unable to initialize incoming UDP server';
      K_MSG_CONFIG_RECEIVED = 'Config received from %s and saved';
      K_MSG_CONF_ERROR = 'Badly formed or incomplete config information received';

// TxPLCustomListener =========================================================
constructor TxPLCustomListener.Create(const aOwner: TComponent);
begin
   inherited;

   fConfig := TxPLCustomConfig.Create(self);
   fCfgFname := Folders.DeviceDir + Adresse.VD + '.cfg';
   fProbingTimer := TimerPool.Add(9 * 1000, {$ifdef fpc}@{$endif}NoAnswerReceived); // Let say 9 sec is needed to receive an answer
end;

destructor TxPLCustomListener.Destroy;
begin
   if Connection.Status = connected then SendHeartBeatMessage;
   IncomingSocket.Active := False;                                              // Be sure no more message will be heard
   SaveConfig;

   inherited Destroy;
end;

function TxPLCustomListener.ConnectionStatusAsStr: string;
begin
   result := Connection.StatusAsStr;
end;

procedure TxPLCustomListener.SaveConfig;
begin
   StreamObjectToFile(fCfgFName, self);
   Log(etInfo, K_MSG_CONFIG_WRITEN, [fCfgFName]);
end;

procedure TxPLCustomListener.LoadConfig;
begin
   ReadObjectFromFile(fCfgFName, self);
   Adresse.Instance := Config.Instance;
   Log(etInfo, K_MSG_CONFIG_LOADED, [Adresse.RawxPL]);
end;

procedure TxPLCustomListener.UpdateConfig;
begin
   LoadConfig;
   if fConfig.IsValid then begin
      if Connection.Status = connected then SendHeartBeatMessage;
      if Assigned(OnxPLConfigDone) then OnxPLConfigDone(fConfig);
   end;
end;

procedure TxPLCustomListener.Listen;
var i : integer;
begin
   try
      IncomingSocket := TAppServer.Create(self);
      if IncomingSocket.Active then begin                                      // Lets be sure we found an address to bind to
         IncomingSocket.OnReceived := {$ifdef fpc}@{$endif}UDPRead;
         Connection := TxPLConnHandler.Create(self);
         for i:=0 to Pred(IncomingSocket.Bindings.Count) do
             Log(etInfo, K_MSG_BIND_OK, [IncomingSocket.Bindings[i].IP,IncomingSocket.Bindings[i].Port]);

         if not FileExists(fCfgFName) then SaveConfig;
         UpdateConfig;
         ConnectionStatus := discovering;
      end else
         Log(etError, K_MSG_IP_ERROR);
   except
      Log(etError, K_MSG_UDP_ERROR);
   end;
end;

procedure TxPLCustomListener.NoAnswerReceived(Sender: TObject);                // This procedure is called by the probing
begin                                                                          // timer when we're waiting unsuccessfully
   ConnectionStatus := discovering;                                            // for the heart beat I sent
end;

function TxPLCustomListener.Get_ConnectionStatus : TConnectionStatus;
begin
   if Assigned(Connection) then result := Connection.Status
                           else result := csNone
end;

procedure TxPLCustomListener.SendHeartBeatMessage;
var i: integer;
begin
   with THeartBeatMsg.Create(self) do begin
      for i := 0 to IncomingSocket.Bindings.Count - 1 do begin
          Port := IncomingSocket.Bindings[i].Port;
          Remote_Ip := IncomingSocket.Bindings[i].IP;
          if Assigned(OnxPLHBeatPrepare) and (Config.IsValid) then OnxPLHBeatPrepare(Body);
          Send;
      end;

      fProbingTimer.Enabled := not (csDestroying in ComponentState);           // Don't wait for an answer if I'm leaving
      Free;
   end;
end;

procedure TxPLCustomListener.HandleConfigMessage(aMessage: TxPLMessage);
begin
   if not Adresse.Equals(aMessage.Target) or (aMessage.MessageType <> cmnd) then exit;

   if aMessage is TConfigCurrentCmnd then Send(Config.CurrentConfig)
   else if aMessage is TConfigListCmnd then Send(Config.ConfigList)
   else if aMessage is TConfigResponseCmnd then begin
      Config.CurrentConfig.Body.Assign(aMessage.Body);
      if fConfig.IsValid then begin
         Log(etInfo, K_MSG_CONFIG_RECEIVED, [aMessage.Source.RawxPL]);
         SaveConfig;
         UpdateConfig;
      end else
         Log(etError, K_MSG_CONF_ERROR);
   end;
   ConnectionStatus := connected;
end;

procedure TxPLCustomListener.UDPRead(const aString: string);
var aMessage: TxPLMessage;
begin
   CheckSynchronize;
   if csDestroying in ComponentState then exit;

   fProbingTimer.Enabled := False;                                             // Stop waiting, I received a message
   aMessage := MessageBroker(aString);
   with aMessage do try
      if Assigned(OnPreprocessMsg) then OnPreprocessMsg(aMessage);
      if (Adresse.Equals(Target)) or (Target.Isgeneric) then begin             // It is directed to me
         if Adresse.Equals(Source) then ConnectionStatus := connected          // I heard something from me : I'm connected
         else if aMessage is THeartBeatReq then Connection.Rate := rfRandom
         else if aMessage is TFragmentMsg then FragmentMgr.Handle(TFragmentMsg(aMessage))
         else if Schema.IsConfig then HandleConfigMessage(aMessage);

         if (MatchesFilter(Config.FilterSet) and Config.IsValid) and (not Adresse.Equals(Source)) then
            if not DoHBeatApp(aMessage) then
               DoxPLReceived(aMessage);
      end;
   finally
      Free;
   end;
end;

procedure TxPLCustomListener.Set_ConnectionStatus(const aValue: TConnectionStatus);
begin
   if Connection.Status <> aValue then begin
      Connection.Status := aValue;
      Log(etInfo, Connection.StatusAsStr);
      if (aValue = connected) and not Config.IsValid then Log(etInfo, 'Configuration pending');
      if Assigned(OnxPLJoinedNet) then OnxPLJoinedNet;
   end;
end;

{------------------------------------------------------------------------
 DoHBeatApp :
   Transfers the message to the application only if the message completes
   required tests : has to be of xpl-stat type and the
   schema has to be hbeat.app
   IN  : the message to test and transmit
   OUT : result indicates wether the message has been transmitted or not
 ------------------------------------------------------------------------}
function TxPLCustomListener.DoHBeatApp(const aMessage: TxPLMessage): boolean;
begin
   Result := (aMessage is THeartBeatMsg) and not(aMessage.Source.Equals(Adresse));

   if Result and Assigned(OnxPLHBeatApp) then OnxPLHBeatApp(aMessage);
end;

function TxPLCustomListener.DoxPLReceived(const aMessage: TxPLMessage): boolean;
begin
   Result := Assigned(OnxPLReceived);
   if Result then
      OnxPLReceived(aMessage);
end;

initialization // =============================================================
  Classes.RegisterClass(TxPLCustomListener);

end.

