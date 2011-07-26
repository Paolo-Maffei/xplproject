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
     , u_xpl_udp_socket
     , u_xpl_message
     , u_xpl_config
     , u_xpl_heart_beater
     , u_xpl_body
     , u_xpl_sender
     , fpc_delphi_compat
     ;

type TConnectionStatus = (discovering,connected, csNone);

type  TxPLReceivedEvent = procedure(const axPLMsg : TxPLMessage) of object;
      TxPLConfigDone    = procedure(const aConfig : TxPLCustomConfig)  of object;
      TxPLHBeatPrepare  = procedure(const aBody   : TxPLBody) of object;
      TxPLJoinedNed     = procedure of object;

      // TxPLCustomListener ===================================================

      TxPLCustomListener = class(TxPLSender)
      private
        fConfig        : TxPLCustomConfig;
        fCfgFname      : string;
        fProbingTimer  : TxPLTimer;
        IncomingSocket : TxPLUDPServer;
        HBeat          : TxPLHeartBeater;
        fFilterSet     : TxPLConfigItem;
        function Get_ConnectionStatus: TConnectionStatus;
        procedure  NoAnswerReceived(sender : TObject);
     public
        OnxPLReceived     : TxPLReceivedEvent;
        OnPreProcessMsg   : TxPLReceivedEvent;
        OnxPLConfigDone   : TxPLConfigDone   ;
        OnxPLHBeatPrepare : TxPLHBeatPrepare ;
        OnxPLHBeatApp     : TxPLReceivedEvent;
        OnxPLJoinedNet    : TxPLJoinedNed;

        Constructor Create(const aOwner : TComponent); reintroduce;
        Destructor  Destroy; override;

        //Procedure OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); dynamic;
        procedure SaveConfig; dynamic;
        procedure LoadConfig; dynamic;

        procedure FinalizeHBeatMsg(const aMessage  : TxPLMessage; const aPort : string; const aIP : string); dynamic;
        procedure HandleConfigMessage(aMessage : TxPLMessage); dynamic;
        procedure SendHeartBeatMessage; dynamic;
        function  ConnectionStatusAsStr : string;
        procedure Set_ConnectionStatus(const aValue : TConnectionStatus); virtual;
        property  FilterSet  : TxPLConfigItem read fFilterSet;

        procedure UpdateConfig; dynamic;
        function  DoHBeatApp    (const aMessage : TxPLMessage) : boolean; dynamic;
        function  DoxPLReceived (const aMessage : TxPLMessage) : boolean; dynamic;
        procedure UDPRead(const aString : string);
        procedure Listen;
     published
        property Config : TxPLCustomConfig read fConfig;
        property ConnectionStatus : TConnectionStatus read Get_ConnectionStatus write Set_ConnectionStatus stored false;
     end;

const K_HBEAT_ME_APPNAME  = 'appname';

implementation { ==============================================================}
uses u_xpl_header
     , u_xpl_schema
     , u_xpl_common
     , typinfo
     ;

const K_MSG_BIND_OK       = 'Listening on port %u for address %s';
      K_MSG_CONFIG_LOADED = 'Configuration loaded from %s';
      K_MSG_CONFIG_WRITEN = 'Configuration saved to %s';
      K_MSG_IP_ERROR      = 'Socket unable to bind to IP Addresses';
      K_MSG_UDP_ERROR     = 'Unable to initialize incoming UDP server';
      K_HBEAT_ME_VERSION  = 'version';
      K_MSG_CONFIG_RECEIVED = 'Config received from %s and saved';
      K_MSG_CONF_ERROR      = 'Badly formed or incomplete config information received';
      K_NETWORK_STATUS      = 'xPL Network status : %s';

// TxPLCustomListener =========================================================
constructor TxPLCustomListener.Create(const aOwner : TComponent);
begin
   inherited;
   fConfig    := TxPLCustomConfig.Create(self);
   fFilterSet := fConfig.FilterSet;
   fCfgFname  := Folders.DeviceDir + Adresse.VD + '.cfg';

   fProbingTimer := TxPLTimer.Create(self);
   fProbingTimer.Interval := 10 * 1000;                                        // Let say 10 sec is needed to receive an answer
   fProbingTimer.OnTimer  := {$ifdef fpc}@{$endif}NoAnswerReceived;
end;

destructor TxPLCustomListener.destroy;
begin
   if ConnectionStatus = connected then SendHeartBeatMessage;
   IncomingSocket.Active:=false;                                               // Be sure no more message will be heart
   SaveConfig;
   inherited destroy;
end;

function TxPLCustomListener.ConnectionStatusAsStr: string;
begin
   Result := Format(K_NETWORK_STATUS,[GetEnumName(TypeInfo(TConnectionStatus),Ord(ConnectionStatus))]);
end;

procedure TxPLCustomListener.SaveConfig;
begin
   StreamObjectToFile(fCfgFName,self);
   Log(etInfo,K_MSG_CONFIG_WRITEN,[fCfgFName]);
end;

procedure TxPLCustomListener.LoadConfig;
begin
   ReadObjectFromFile(fCfgFName,self);
   Log(etInfo,K_MSG_CONFIG_LOADED,[fCfgFName]);
   Adresse.Instance := Config.Instance;
end;

//procedure TxPLCustomListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
//begin
//  if CompareText(AClassName, 'TxPLCustomConfig') = 0 then ComponentClass := TxPLCustomConfig
//  else if CompareText(AClassName, 'TxPLCustomListener') = 0 then ComponentClass := TxPLCustomListener
//end;

procedure TxPLCustomListener.UpdateConfig;
begin
   LoadConfig;
   if fConfig.IsValid then begin
      if ConnectionStatus = connected then SendHeartBeatMessage;
      if Assigned(OnxPLConfigDone)    then OnxPLConfigDone(fConfig);
   end;
end;

procedure TxPLCustomListener.Listen;
begin
   try
     IncomingSocket:=TxPLUDPServer.create(self,{$ifdef fpc}@{$endif}UDPRead);
     If IncomingSocket.Active then begin                                       // Lets be sure we found an address to bind to
        HBeat := TxPLHeartBeater.Create(self);
        Log(etInfo,K_MSG_BIND_OK,[IncomingSocket.Bindings[0].Port,IncomingSocket.Bindings[0].IP]);

        if not FileExists(fCfgFName) then SaveConfig;
        UpdateConfig;
        ConnectionStatus := discovering;                                       // Consider we've not reached any xPL network at this time

     end
     else Log(etError,K_MSG_IP_ERROR);
   except
     Log(etError, K_MSG_UDP_ERROR);
   end;
end;

procedure TxPLCustomListener.NoAnswerReceived(sender: TObject);                // This procedure is called by the probing
begin                                                                          // timer when we're waiting unsuccessfully
   ConnectionStatus := discovering;                                            // for the heart beat I sent
end;

function TxPLCustomListener.Get_ConnectionStatus: TConnectionStatus;
begin
   result := csNone;
   if not Assigned(HBeat) then exit;
   if ((HBeat.Rate = rfDiscovering) or (Hbeat.Rate = rfNoHubLowFreq)) then result := discovering
   else if ((HBeat.Rate = rfRandom) or (HBeat.Rate = rfConfig)) then result := connected;
end;

procedure TxPLCustomListener.FinalizeHBeatMsg(const aMessage  : TxPLMessage; const aPort : string; const aIP : string);
begin
   aMessage.Format_HbeatApp(fConfig.Interval,aPort,aIP);
   aMessage.Body.AddKeyValuePairs( [K_HBEAT_ME_APPNAME , K_HBEAT_ME_VERSION], [AppName, Version]);
   if not Config.IsValid then aMessage.Schema.Classe := K_SCHEMA_CLASS_CONFIG; // Change Schema class in this case
   if csDestroying in ComponentState then aMessage.Schema.Type_ := 'end';      // Change Schema type in this case
end;

procedure TxPLCustomListener.SendHeartBeatMessage;
var i : integer;
    aMessage : TxPLMessage;
begin
   aMessage := TxPLMessage.Create(self);

   for i:=0 to IncomingSocket.Bindings.Count-1 do begin
       FinalizeHBeatMsg(aMessage,IntToStr(IncomingSocket.Bindings[i].Port),IncomingSocket.Bindings[i].IP);
       if Assigned(OnxPLHBeatPrepare) and (Config.IsValid) then OnxPLHBeatPrepare(aMessage.Body);
       Send(aMessage);
   end;

   fProbingTimer.Enabled := True;
   aMessage.Destroy;
end;

procedure TxPLCustomListener.HandleConfigMessage(aMessage: TxPLMessage);
begin
   if (aMessage.MessageType = cmnd) and (Adresse.Equals(aMessage.Target)) then begin
      if aMessage.Schema.Equals(Schema_ConfigResp) then begin
         Config.CurrentConfig := aMessage.Body;
         if fConfig.IsValid then begin
            Log(etInfo,K_MSG_CONFIG_RECEIVED,[aMessage.Source.RawxPL]);
            SaveConfig;
            UpdateConfig;
         end else
            Log(etError, K_MSG_CONF_ERROR);
   end else
       with TxPLMessage(PrepareMessage(stat,aMessage.Schema)) do try
            if aMessage.Schema.Equals(Schema_ConfigCurr) and
               (aMessage.Body.GetValueByKey('command') = 'request') then
               Body.Assign(Config.CurrentConfig)
            else if aMessage.Schema.Equals(Schema_ConfigList) then
                    Body.Assign(Config.ConfigList);
            Send(ProcessedxPL);
       finally
           free;
       end;
   end;
   ConnectionStatus := connected;
end;

procedure TxPLCustomListener.UDPRead(const aString : string);
var aMessage : TxPLMessage;
begin
   if csDestroying in ComponentState then exit;
   fProbingTimer.Enabled := false;                                             // Stop waiting anything, I received a message
   aMessage := TxPLMessage.Create(self, aString);
   with aMessage do try
      if Assigned(OnPreprocessMsg) then OnPreprocessMsg(aMessage);
      { TODO : There's a bug here : having these three or leads the program to accept messages that are not directed to him if it matches its filters }
      if ((Adresse.Equals(Target)) or (Target.Isgeneric) (*or MatchesFilter(fFilterSet)*)) then begin  // It is directed to me
      {EoTODO : check that this modification is ok}

         if Schema.Classe = K_SCHEMA_CLASS_HBEAT then begin
            if Adresse.Equals(Source)   then ConnectionStatus := connected;
            if Schema.Type_ = 'request' then HBeat.Rate := rfRandom;           // Choose a random value between 2 and 6 second
         end;
         if Schema.Classe = K_SCHEMA_CLASS_CONFIG then HandleConfigMessage(aMessage);
         if ( MatchesFilter(fFilterSet) and Config.IsValid ) and (not Adresse.Equals(Source)) then
            if not  DoHBeatApp(aMessage)
               then DoxPLReceived(aMessage);
      end;
      finally Destroy;
   end;
end;

procedure TxPLCustomListener.Set_ConnectionStatus(const aValue : TConnectionStatus);
begin
   if ConnectionStatus<>aValue then begin
      if aValue = connected then
         HBeat.Rate := rfConfig
      else
         HBeat.Rate := rfDiscovering;
      Log(etInfo,ConnectionStatusAsStr);
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
   result := false;
   if aMessage.MessageType <> stat then exit;
   if not aMessage.Schema.Equals(Schema_HBeatApp) then exit;

   if (aMessage.Source.Equals(Adresse)) (*and (not PassMyOwnMessages)*) then exit;

   if Assigned(OnxPLHBeatApp) then OnxPLHBeatApp( aMessage);

   result := true;
end;

function TxPLCustomListener.DoxPLReceived(const aMessage: TxPLMessage): boolean;
begin
   result := false;
   if Assigned(OnxPLReceived) then begin
      OnxPLReceived( aMessage);
      Result := true;
   end;
end;

end.

initialization
   Classes.RegisterClass(TxPLCustomListener);
