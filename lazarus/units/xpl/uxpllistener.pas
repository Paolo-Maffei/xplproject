unit uxPLListener;
{==============================================================================
  UnitName      = uxPLListener
  UnitDesc      = xPL Listener object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Seperation of basic xPL Client (listener and sender) from pure listener
 0.92 : Modification made to avoid handling of my own emitted messages
 0.93 : Modifications made for modif 0.92 for uxPLConfig
 0.94 : Use of uxPLConst
        Removed bHubfound, redondant with JoinedxPLNetwork
        Removed bConfigOnly, redondant with AwaitingConfiguration
 0.94 : Replacement of TTimer with TfpTimer
 0.95 : Added 'no config' capability to allow light focused xPL Client avoid waiting config
 0.96 : Suppressed symbolic constants for Schema
Rev 298 : Modified to enable Linux support
 0.97 : Removed fAdresse field, moved to TxPLClient object
        Removed field AwaitingConfiguration that was redundant with Config.ConfigNeeded
 0.98 : Added SeeAll variable to enable logger to see messages not targetted to him
 1.00 : Added Prerequisite modules handling
        Added descendance from TxPLSender functionalities extracted from xPLMessage
}

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, u_xpl_udp_socket,
     uxPLMessage, uxPLConfig,  uXPLFilter, fpTimer,
     uxPLMsgBody,  u_xpl_sender, uxPLConst;

type
      TxPLReceivedEvent = procedure(const axPLMsg : TxPLMessage) of object;
      TxPLJoinedEvent   = procedure(const aJoined : boolean)     of object;
      TxPLPrereqMet     = procedure                              of object;
      TxPLConfigDone    = procedure(const fConfig : TxPLConfig)  of object;
      TxPLHBeatPrepare  = procedure(const aBody   : TxPLMsgBody) of object;
      TxPLSensorRequest = procedure(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string) of object;
      TxPLTTSBasic      = procedure(const axPLMsg : TxPLMessage; const aSpeech : string) of object;
      TxPLHBeatApp      = procedure(const axPLMsg : TxPLMessage) of object;
      TxPLMediaBasic    = procedure(const axPLMsg : TxPLMessage; const aCommand : string; const aMP : string) of object;

      { TxPLListener }

      TxPLListener = class(TxPLSender)
      private
        fConfig  : TxPLConfig;
        fPrereqList : TStringList;                                              // Handles list of needed modules in device=VDI form
        fPrereqMet  : boolean;
        IncomingSocket : TxPLUDPServer;
        HBTimer, HBReqTimer : TFPTimer;                                         // HBReqTimer is dedicated to hbeat requests
        fFilterSet : TxPLFilters;
        iNoHubTimerCount : integer;
        bDisposing : Boolean;

        procedure InitSocket();
     public
        OnxPLReceived      : TxPLReceivedEvent;
        OnxPLJoinedNet     : TxPLJoinedEvent  ;
        OnxPLPrereqMet     : TxPLPrereqMet    ;                                 // Called when needed modules has been seen on the xPL network
        OnxPLCOnfigDone    : TxPLConfigDone   ;
        OnxPLHBeatPrepare  : TxPLHBeatPrepare ;
        OnxPLSensorRequest : TxPLSensorRequest;
        OnxPLControlBasic  : TxPLSensorRequest;
        OnxPLTTSBasic      : TxPLTTSBasic     ;
        OnxPLHBeatApp      : TxPLHBeatApp     ;
        OnxPLMediaBasic    : TxPLMediaBasic   ;
        PassMyOwnMessages  : Boolean;
        JoinedxPLNetwork   : Boolean;                                           // This should be read only by other objects
        SeeAll             : Boolean;                                           // This variable may only be set to true for a logger to let him see all messages

        constructor create(const aVendor : tsVendor; const aDevice : tsDevice; const aAppVersion : string; const bConfigNeeded : boolean = true);
        destructor destroy; override;
        procedure CallConfigDone; dynamic;
        procedure TimerElapsed(Sender : TObject);
        procedure HandleHBeatRequest;   dynamic;
        procedure FinalizeHBeatMsg(const aMessage  : TxPLMessage; const aPort : string; const aIP : string); dynamic;
        procedure HandleConfigMessage(aMessage : TxPLMessage); dynamic;
        procedure SendHeartBeatMessage; dynamic;

        property Config              : TxPLConfig read fConfig;
        property Disposing           : Boolean read bDisposing;
        property PrereqList          : TStringList read fPrereqList;
        property PrereqMet           : boolean read fPrereqMet;

        procedure DoxPLJoinedNet (aJoined    : boolean) ;
        procedure DoxPLPrereqMet                        ;
        function  DoSensorRequest(aMessage : TxPLMessage) : boolean;
        function  DoControlBasic (aMessage : TxPLMessage) : boolean;
        function  DoTTSBasic     (aMessage : TxPLMessage) : boolean;
        function  DoHBeatApp     (aMessage : TxPLMessage) : boolean;
        function  DoMediaBasic   (aMessage : TxPLMessage) : boolean;

        procedure UDPRead(const aString : string);
	procedure LogInfo(Const Formatting  : string; Const Data  : array of const ); override;            // Info are only stored in log file
        procedure Listen;
        procedure Dispose;
     end;

implementation { ==============================================================}
uses StrUtils;

{ TxPLListener ================================================================}
constructor TxPLListener.create(const aVendor : tsVendor; const aDevice : tsDevice; const aAppVersion : string; const bConfigNeeded : boolean = true);
begin
   inherited Create(aVendor, aDevice, aAppVersion);

   PassMyOwnMessages := false;
   SeeAll            := false;
   fPrereqList       := TStringList.Create;
   fConfig           := TxPLConfig.Create(self, bConfigNeeded);
   Adresse.Instance  := fConfig.Instance;                                       // Instance name will be determined by configuration need or not
   fFilterSet        := TxPLFilters.Create(fConfig);

   HBTimer    := TfpTimer.Create(nil);
      HBTimer.Interval    := NOHUB_HBEAT * 1000;
      HBTimer.OnTimer     := @TimerElapsed;
   HBReqTimer := TfpTimer.Create(nil);
      HBReqTimer.OnTimer  := @TimerElapsed;

   JoinedxPLNetwork := false;
   bDisposing := False;
   iNoHubTimerCount := 0;
end;

destructor TxPLListener.destroy;
begin
     if not bDisposing then Dispose;
     fPrereqList.Destroy;
     fFilterSet.Destroy;
     IncomingSocket.Destroy;
     fConfig.Destroy;
     HBReqTimer.Destroy;
     HBTimer.Destroy;

     inherited destroy;
end;

procedure TxPLListener.InitSocket();
begin
   if not Settings.IsValid then exit;
   try
     IncomingSocket:=TxPLUDPServer.create(Settings,@UDPRead);
     If IncomingSocket.Active then begin                             // Lets be sure we found an address to bind to
        LogInfo(K_MSG_BIND_OK,[IncomingSocket.Bindings[0].Port,IncomingSocket.Bindings[0].IP]);
        HBTimer.Enabled  := True;
        TimerElapsed(self);
     end else LogError(K_MSG_IP_ERROR,[]);
   except
     LogError(K_MSG_UDP_ERROR,[]);
   end;
end;

procedure TxPLListener.CallConfigDone;
begin
   LogInfo(K_MSG_CONFIG_LOADED,[]);
   if Assigned(OnxPLConfigDone) then OnxPLConfigDone(fConfig);                 // Assume that this can never be done if NoConfig has been specified !
end;

procedure TxPLListener.Listen;
begin                                                       
   bDisposing := false;
   Config.Load;
   fPrereqMet := not (fPrereqList.Count > 0);
   if not Config.ConfigNeeded then begin
      Adresse.Instance := fConfig.Instance;
      CallConfigDone;
   end;
   InitSocket;
end;

procedure TxPLListener.Dispose;
begin
   bDisposing := True;
   if JoinedxPLNetwork then SendHeartBeatMessage;
   if IncomingSocket.Active then LogInfo(K_MSG_BIND_RELEASED,[]);
   IncomingSocket.Active := False;
end;

procedure TxPLListener.LogInfo(const Formatting: string; const Data: array of const);
begin
   inherited LogInfo(Formatting, Data);
   if JoinedxPLNetwork then SendLOGBasic('info', Format(Formatting,Data));
end;

procedure TxPLListener.FinalizeHBeatMsg(const aMessage  : TxPLMessage; const aPort : string; const aIP : string);
begin
   aMessage.Format_HbeatApp(IntToStr(fConfig.HBInterval),aPort,aIP);
   aMessage.Body.AddKeyValuePair(K_HBEAT_ME_APPNAME, AppName);
   aMessage.Body.AddKeyValuePair(K_HBEAT_ME_VERSION, fAppVersion);

   if Config.ConfigNeeded then aMessage.Schema.Classe := K_SCHEMA_CLASS_CONFIG;       // Change Schema class in this case
   if bDisposing  then aMessage.Schema.Type_ := 'end';                         // Change Schema type in this case
end;

procedure TxPLListener.SendHeartBeatMessage;
var i : integer;
    aMessage : TxPLMessage;
begin
   aMessage := TxPLMessage.Create;

   for i:=0 to IncomingSocket.Bindings.Count-1 do begin
       FinalizeHBeatMsg(aMessage,IntToStr(IncomingSocket.Bindings[i].Port),IncomingSocket.Bindings[i].IP);
       if Assigned(OnxPLHBeatPrepare) and (not Config.ConfigNeeded) then OnxPLHBeatPrepare(aMessage.Body);
       SendMessage(K_MSG_TYPE_STAT,K_ADDR_ANY_TARGET,aMessage.Schema.Tag,aMessage.Body.RawxPL);
   end;
   aMessage.Destroy;
end;


procedure TxPLListener.TimerElapsed(Sender: TObject);
begin
     if HBReqTimer.Enabled then HBReqTimer.Enabled := False;

     if not JoinedxPLNetwork then begin                      // Initial probing
        inc(iNoHubTimerCount,NOHUB_HBEAT);                   // Still a high frequency ?
        if iNoHubTimerCount > NOHUB_TIMEOUT then HBTimer.Interval := NOHUB_LOWERFREQ * 1000;
     end;

     SendHeartBeatMessage;
end;

procedure TxPLListener.HandleConfigMessage(aMessage: TxPLMessage);
var i,j : integer;

begin
  if aMessage.Header.MessageType <> K_MSG_TYPE_CMND then exit;

  with TxPLMessage.Create do try
     MessageType := K_MSG_TYPE_STAT;
     Source.Assign(Adresse);
     Target.IsGeneric := True;
     Body.ResetValues;

     case AnsiIndexStr(aMessage.Schema.Type_, ['current', 'list', 'response']) of
          0 : if aMessage.Body.GetValueByKey('command') = 'request' then begin                        // config.current message handling
                 Schema.Tag := aMessage.Schema.Tag;
                 for i := 0 to fConfig.Count-1 do
                     for j:= 0 to fConfig[i].ValueCount -1 do
                         Body.AddKeyValuePair(fConfig[i].Key,fConfig[i].Values[j]);
                 Send(ProcessedxPL);
              end;
          1 : begin                                                                                   // config.list message handling
                  Schema.Tag := aMessage.Schema.Tag;
                for i := 0 to fConfig.Count-1 do
                    Body.AddKeyValuePair( fConfig[i].ConfigType,
                                          fConfig[i].Key + fConfig[i].MaxValueAsString);
                Send(ProcessedxPL);
              end;
          2 : begin                                                                                   // config.response message handling
                fConfig.ResetValues;
                for i:= 0 to aMessage.Body.ItemCount-1 do
                    fConfig.SetItem( AnsiLowerCase(aMessage.Body.Keys[i]), aMessage.Body.Values[i]);  // Some configuration elements may need to be upper/lower sensitive
                Adresse.Instance := fConfig.Instance;                                                // Instance name may have changed
                SendHeartBeatMessage;
                fConfig.Save;
                LogInfo(K_MSG_CONFIG_RECEIVED,[aMessage.Source.Tag]);
                CallConfigDone;
              end;
     end;
     finally destroy;
   end;
end;

procedure TxPLListener.HandleHBeatRequest;
begin
   HBReqTimer.Interval := Random(4000) + 2000;     // Choose a random value between 2 and 6 seconds
   HBReqTimer.Enabled  := True;
end;

procedure TxPLListener.UDPRead(const aString : string);
var aMessage : TxPLMessage;
begin
   if bDisposing then exit;
   aMessage := TxPLMessage.Create(aString);
   with aMessage do try
      if ((Adresse.Equals(Target)) or (Target.Isgeneric) or fFilterSet.CheckGroup(Target.Tag)) then begin        // It is directed to me
         if ( Schema.Classe = K_SCHEMA_CLASS_HBEAT ) and (Schema.Type_ = 'request') then HandleHBeatRequest;
         if ( Schema.Classe = K_SCHEMA_CLASS_CONFIG) then HandleConfigMessage(aMessage);
         if ( Adresse.Equals(Source) and (not JoinedxPLNetwork)) then DoxPLJoinedNet(true);

         if ( fFilterSet.MatchesFilters(aMessage) and not Config.ConfigNeeded ) and
            (PassMyOwnMessages or not Adresse.Equals(Source))                                                     // 0.92 : to avoid handling of my self emitted messages
            then begin
               if not DoSensorRequest(aMessage) then                                                                  // process messages only once
               if not DoControlBasic (aMessage) then
               if not DoTTSBasic     (aMessage) then
               if not DoHBeatApp     (aMessage) then
               if not DoMediaBasic   (aMessage) then
               if Assigned(OnxPLReceived)       then OnxPLReceived(aMessage);
            end;
      end else if SeeAll then OnxPLReceived(aMessage);
      finally Destroy;
   end;
end;

procedure TxPLListener.DoxPLPrereqMet;
begin
   LogInfo('Prerequisite modules found',[]);
   if Assigned(OnxPLPrereqMet) then OnxPLPrereqMet;
end;

procedure TxPLListener.DoxPLJoinedNet(aJoined: boolean);
begin
   LogInfo(K_MSG_HUB_FOUND,[IfThen(aJoined,'','not')]);
   if aJoined <> true then exit; { TODO -oGLH : Le cas contraire (perte de hub) devrait etre géré ultérieurement}

   JoinedxPLNetwork := true;
   iNoHubTimerCount := 0;
   HBTimer.Interval := fConfig.HBInterval * 60000;
   if Assigned(OnxPLJoinedNet) then OnxPLJoinedNet(true);

   if not fPrereqMet then begin;
      LogInfo('Probing for presence of prerequisite modules : %s',[PrereqList.CommaText]);
      SendHBeatRequestMsg;
   end;
end;

{------------------------------------------------------------------------
 DoSensorRequest :
   Transfers the message to the application only if the message completes
   required tests : sensor request has to be of xpl-cmnd type and the
   schema has to be sensor.request
   IN  : the message to test and transmit
   OUT : result indicates wether the message has been transmitted or not
 ------------------------------------------------------------------------}
function TxPLListener.DoSensorRequest(aMessage : TxPLMessage) : boolean;
begin
     result := false;
     if not Assigned(OnxPLSensorRequest) then exit;
     if aMessage.MessageType <> K_MSG_TYPE_CMND then exit;
     if aMessage.Schema.Tag  <> K_SCHEMA_SENSOR_REQUEST then exit;

     OnxPLSensorRequest( aMessage, aMessage.Body.GetValueByKey('device'),
                                   aMessage.Body.GetValueByKey('request')
                         );

     result := true;
end;

{------------------------------------------------------------------------
 DoControlBasic :
   Transfers the message to the application only if the message completes
   required tests : control basic has to be of xpl-cmnd type and the
   schema has to be control.basic
   IN  : the message to test and transmit
   OUT : result indicates wether the message has been transmitted or not
 ------------------------------------------------------------------------}
function TxPLListener.DoControlBasic(aMessage : TxPLMessage) : boolean;
begin
     result := false;
     if not Assigned(OnxPLControlBasic) then exit;
     if aMessage.MessageType <> K_MSG_TYPE_CMND then exit;
     if aMessage.Schema.Tag  <> K_SCHEMA_CONTROL_BASIC then exit;

     OnxPLControlBasic( aMessage, aMessage.Body.GetValueByKey('device'),
                                  aMessage.Body.GetValueByKey('current')
                        );

     result := true;
end;

{------------------------------------------------------------------------
 DoTTSBasic :
   Transfers the message to the application only if the message completes
   required tests : has to be of xpl-cmnd type and the
   schema has to be tts.basic
   IN  : the message to test and transmit
   OUT : result indicates wether the message has been transmitted or not
 ------------------------------------------------------------------------}
function TxPLListener.DoTTSBasic(aMessage : TxPLMessage) : boolean;
begin
     result := false;
     if not Assigned(OnxPLTTSBasic) then exit;
     if aMessage.MessageType <> K_MSG_TYPE_CMND then exit;
     if aMessage.Schema.Tag  <> K_SCHEMA_TTS_BASIC then exit;
     if aMessage.Source.Tag = Adresse.Tag then exit;
     OnxPLTTSBasic( aMessage, aMessage.Body.GetValueByKey('speech') );

     result := true;
end;

{------------------------------------------------------------------------
 DoHBeatApp :
   Transfers the message to the application only if the message completes
   required tests : has to be of xpl-stat type and the
   schema has to be hbeat.app
   IN  : the message to test and transmit
   OUT : result indicates wether the message has been transmitted or not
 ------------------------------------------------------------------------}
function TxPLListener.DoHBeatApp(aMessage: TxPLMessage): boolean;
var i : integer;
begin
   result := false;
   if aMessage.MessageType <> K_MSG_TYPE_STAT then exit;
   if aMessage.Schema.Tag  <> K_SCHEMA_HBEAT_APP then exit;
   if aMessage.Source.Tag = Adresse.Tag then exit;
   if not fPrereqMet then begin
      fPrereqMet := true;
      for i:=0 to PrereqList.Count-1 do begin
          if aMessage.Source.Device = PrereqList.Names[i] then PrereqList.ValueFromIndex[i]:=aMessage.Source.Tag;
          fPrereqMet := fPrereqMet and (PrereqList.ValueFromIndex[i]<>'0')
      end;
      if fPrereqMet then DoxPLPrereqMet;
   end;

   if Assigned(OnxPLHBeatApp) then OnxPLHBeatApp( aMessage);

   result := true;
end;

{------------------------------------------------------------------------
 DoMediaBasic :
   Transfers the message to the application only if the message completes
   required tests : has to be of xpl-cmnd type and the
   schema has to be media.basic
   IN  : the message to test and transmit
   OUT : result indicates wether the message has been transmitted or not
 ------------------------------------------------------------------------}
function TxPLListener.DoMediaBasic(aMessage: TxPLMessage): boolean;
begin
     result := false;
     if not Assigned(OnxPLMediaBasic) then exit;
     if aMessage.MessageType <> K_MSG_TYPE_CMND then exit;
     if aMessage.Schema.Tag  <> K_SCHEMA_MEDIA_BASIC then exit;
     if aMessage.Source.Tag = Adresse.Tag then exit;
     OnxPLMediaBasic( aMessage, aMessage.Body.GetValueByKey('command'),aMessage.Body.GetValueByKey('mp'));

     result := true;
end;




end.


