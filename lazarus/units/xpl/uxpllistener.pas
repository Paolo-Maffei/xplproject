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
}

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, uxPLAddress, IdUDPServer,IdSocketHandle,
     ExtCtrls, IdGlobal,uxPLMessage, uxPLConfig,  uXPLFilter, DOM,
     uxPLMsgBody,  uxPLMsgHeader, uxPLClient, uxPLConst, uxPLPluginFile;

type
      TxPLReceivedEvent = procedure(const axPLMsg : TxPLMessage) of object;
      TxPLJoinedEvent   = procedure(const aJoined : boolean)     of object;
      TxPLConfigDone    = procedure(const fConfig : TxPLConfig)  of object;
      TxPLHBeatPrepare  = procedure(const aBody   : TxPLMsgBody) of object;
      TxPLSensorRequest = procedure(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string) of object;
      TxPLTTSBasic      = procedure(const axPLMsg : TxPLMessage; const aSpeech : string) of object;
      TxPLHBeatApp      = procedure(const axPLMsg : TxPLMessage) of object;
      TxPLMediaBasic    = procedure(const axPLMsg : TxPLMessage; const aCommand : string; const aMP : string) of object;

      { TxPLListener }

      TxPLListener = class(TxPLClient)
      private
        fConfig  : TxPLConfig;
        fAdresse : TxPLAddress;
        IncomingSocket : TIdUDPServer;
        HBTimer,HBReqTimer   : TTimer;                       // HBReqTimer is dedicated to hbeat requests
        fFilterSet : TxPLFilters;
        iNoHubTimerCount : integer;
        bDisposing : Boolean;

        procedure InitSocket();
     public
        PassMyOwnMessages     : Boolean;
        JoinedxPLNetwork      : Boolean;                    // This should be read only by other objects
        AwaitingConfiguration : Boolean;                    // This should be read only by other objects

        constructor create(aOwner : TComponent; const aVendor : tsVendor; const aDevice : tsDevice; const aAppVersion : string);
        destructor destroy; override;
        procedure CallConfigDone; dynamic;
        procedure TimerElapsed(Sender : TObject);
        procedure HandleHBeatRequest;   dynamic;
        procedure SendHeartBeatMessage; dynamic;
        procedure FinalizeHBeatMsg(const aBody  : TxPLMsgBody; const aPort : string; const aIP : string); dynamic;
        procedure HandleConfigMessage(aMessage : TxPLMessage); dynamic;

        property Config              : TxPLConfig read fConfig;
        property Address             : TxPLAddress read fAdresse;
        property Disposing           : Boolean read bDisposing;
        function Instance : tsInstance;

        OnxPLReceived      : TxPLReceivedEvent;
        OnxPLJoinedNet     : TxPLJoinedEvent  ;
        OnxPLCOnfigDone    : TxPLConfigDone   ;
        OnxPLHBeatPrepare  : TxPLHBeatPrepare ;
        OnxPLSensorRequest : TxPLSensorRequest;
        OnxPLControlBasic  : TxPLSensorRequest;
        OnxPLTTSBasic      : TxPLTTSBasic     ;
        OnxPLHBeatApp      : TxPLHBeatApp     ;
        OnxPLMediaBasic    : TxPLMediaBasic   ;

        procedure DoxPLJoinedNet(aJoined    : boolean);
        function DoSensorRequest(aMessage : TxPLMessage) : boolean;
        function DoControlBasic (aMessage : TxPLMessage) : boolean;
        function DoTTSBasic     (aMessage : TxPLMessage) : boolean;
        function DoHBeatApp     (aMessage : TxPLMessage) : boolean;
        function DoMediaBasic   (aMessage : TxPLMessage) : boolean;

        function  CheckOrigin(aRemoteIP : string) : boolean;
        procedure UDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
        procedure SendMessage(const aMsgType : TxPLMessageType; const aDest : string; const aRawBody : string);
        procedure SendMessage(const aRawXPL : string); overload;
        function  PrepareMessage(const aMsgType: TxPLMessageType; const aSchema : string; const aTarget : string = '*') : TxPLMessage;

        //function VendorFile : TXMLDocument;

        procedure Listen;
        procedure Dispose;
     end;

implementation { ==============================================================}
uses IdStack, cRandom, StrUtils, uIPutils, Interfaces;

{ TxPLListener ================================================================}
constructor TxPLListener.create(aOwner : TComponent; const aVendor : tsVendor; const aDevice : tsDevice; const aAppVersion : string);
begin
   inherited Create(aOwner, aVendor, aDevice, aAppVersion);

   PassMyOwnMessages := false;

   fAdresse   := TxPLAddress.Create(aVendor,aDevice, TxPLAddress.RandomInstance);
   fConfig    := TxPLConfig.Create(self);
   fFilterSet := TxPLFilters.Create(fConfig);

   HBTimer    := TTimer.Create(self);
      HBTimer.Interval    := NOHUB_HBEAT * 1000;
      HBTimer.OnTimer     := @TimerElapsed;
   HBReqTimer := TTimer.Create(self);
      HBReqTimer.OnTimer  := @TimerElapsed;

   JoinedxPLNetwork := False;
   bDisposing := False;
   iNoHubTimerCount := 0;
end;

destructor TxPLListener.destroy;
begin
     if not bDisposing then Dispose;

     fFilterSet.Destroy;
     IncomingSocket.Destroy;
     fConfig.Destroy;
     HBReqTimer.Destroy;
     HBTimer.Destroy;
     fAdresse.Destroy;

     inherited destroy;
end;

procedure TxPLListener.InitSocket();
var i : integer;
begin
   if not Setting.IsValid then exit;
   try
     IncomingSocket:=TIdudpServer.create;
     IncomingSocket.Bindings.Clear;
     IncomingSocket.BufferSize := MAX_XPL_MSG_SIZE;
     IncomingSocket.OnUDPRead  := @UDPRead;
   except
     LogError(K_MSG_UDP_ERROR);
   end;

   i := gstack.LocalAddresses.Count-1;
   while i>=0 do begin
      if fSetting.ListenOnAll or (gStack.LocalAddresses[i] = fSetting.ListenOnAddress) then
      with IncomingSocket.Bindings.Add do begin
           ClientPortMin := XPL_BASE_DYNAMIC_PORT;
           ClientPortMax := ClientPortMin + XPL_BASE_PORT_RANGE;
           Port          := 0;
           IP            := gstack.LocalAddresses[i];
      end;
      dec(i);
   end;

   If IncomingSocket.Bindings.Count > 0 then begin                             // Lets be sure we found an address to bind to
      IncomingSocket.Active:=true;
      LogInfo(Format(K_MSG_BIND_OK,[IncomingSocket.Bindings[0].Port,IncomingSocket.Bindings[0].IP]));
      HBTimer.Enabled  := True;
      TimerElapsed(self);
   end else LogError(K_MSG_IP_ERROR);
end;

procedure TxPLListener.CallConfigDone;
begin
   LogInfo(K_MSG_CONFIG_LOADED);
   if Assigned(OnxPLConfigDone) then OnxPLConfigDone(fConfig);
end;

procedure TxPLListener.Listen;
begin                                                       
   bDisposing := false;
   AwaitingConfiguration := not fConfig.Load;
   if not AwaitingConfiguration then begin
      fAdresse.Instance := fConfig.Instance;
      CallConfigDone;
   end;
   InitSocket;
end;

procedure TxPLListener.Dispose;
begin
   bDisposing := True;
   if JoinedxPLNetwork then SendHeartBeatMessage;
   if IncomingSocket.Active then begin
      IncomingSocket.Active := False;
      LogInfo(K_MSG_BIND_RELEASED);
   end;
end;

procedure TxPLListener.SendMessage(const aMsgType : TxPLMessageType; const aDest : string; const aRawBody : string);
begin
   with TxPLMessage.Create do begin
          MessageType := aMsgType;
          Target.Tag  := aDest;
          Body.RawxPL := aRawBody;
          SendMessage(RawXPL);
          Destroy;
   end;
end;

procedure TxPLListener.SendMessage(const aRawXPL : string);
begin
   with TxPLMessage.Create do begin
        RawXPL := aRawXPL;
        Source.Assign(fAdresse);
        if IsValid then Send
                   else LogError('Error sending message :' + RawXPL);
        Destroy;
   end;
end;

function TxPLListener.PrepareMessage(const aMsgType: TxPLMessageType; const aSchema : string; const aTarget : string = '*' ): TxPLMessage;
begin
  result := TxPLMessage.Create;
  with Result do begin
     Source.Assign(fAdresse);
     MessageType := aMsgType;
     Target.Tag  := aTarget;
     Body.Schema.Tag := aSchema;
  end;
end;

//function TxPLListener.VendorFile : TXMLDocument;
//begin
//     result := PluginList.VendorFile(Address.Vendor);                      // Identify my plugin vendor file
//end;

procedure TxPLListener.FinalizeHBeatMsg(const aBody  : TxPLMsgBody; const aPort : string; const aIP : string);
begin
   aBody.Format_HbeatApp(IntToStr(fConfig.HBInterval),aPort,aIP);
   aBody.AddKeyValuePair(K_HBEAT_ME_APPNAME, AppName);
   aBody.AddKeyValuePair(K_HBEAT_ME_VERSION, fAppVersion);

   if AwaitingConfiguration then aBody.Schema.Classe := xpl_scConfig;                // Change Schema class in this case
   if bDisposing  then aBody.Schema.TypeAsString   := 'end';               // Change Schema type in this case
end;

procedure TxPLListener.SendHeartBeatMessage;
var i : integer;
    aBody : TxPLMsgBody;
begin
     aBody := TxPLMsgBody.Create;

     for i:=0 to IncomingSocket.Bindings.Count-1 do begin
         FinalizeHBeatMsg(aBody,IntToStr(IncomingSocket.Bindings[i].Port),IncomingSocket.Bindings[i].IP);
         if Assigned(OnxPLHBeatPrepare) and (not AwaitingConfiguration) then OnxPLHBeatPrepare(aBody);
         SendMessage(xpl_mtStat,'*',aBody.RawxPL);
     end;

     aBody.Destroy;
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
  if aMessage.Header.MessageType <> xpl_mtCmnd then exit;

  with TxPLMessage.Create do try
     MessageType := xpl_mtStat;
     Source.Assign(fAdresse);
     Target.IsGeneric := True;
     Body.ResetValues;

     case AnsiIndexStr(aMessage.Schema.TypeAsString, ['current', 'list', 'response']) of
          0 : if aMessage.Body.GetValueByKey('command') = 'request' then begin                        // config.current message handling
                 Schema.Tag := aMessage.Body.Schema.Tag;
                 for i := 0 to fConfig.Count-1 do
                     for j:= 0 to fConfig[i].ValueCount -1 do
                         Body.AddKeyValuePair(fConfig[i].Key,fConfig[i].Values[j]);
                 Send;
              end;
          1 : begin                                                                                   // config.list message handling
                Schema.Tag := aMessage.Body.Schema.Tag;
                for i := 0 to fConfig.Count-1 do
                    Body.AddKeyValuePair( fConfig[i].ConfigTypeAsString,
                                          fConfig[i].Key + fConfig[i].MaxValueAsString);
                Send ;
              end;
          2 : begin                                                                                   // config.response message handling
                fConfig.ResetValues;
                for i:= 0 to aMessage.Body.ItemCount-1 do
                    fConfig.SetItem( AnsiLowerCase(aMessage.Body.Keys[i]), aMessage.Body.Values[i]);  // Some configuration elements may need to be upper/lower sensitive
                fAdresse.Instance := fConfig.Instance;                                                // Instance name may have changed
                SendHeartBeatMessage;
                fConfig.Save;
                LogInfo('Client configuration renewed and saved');
                CallConfigDone;
              end;
     end;
     finally destroy;
   end;
end;

//function TxPLListener.Vendor: tsVendor;
//begin result := fAdresse.Vendor; end;

//function TxPLListener.Device: tsDevice;
//begin result := fAdresse.Device; end;

function TxPLListener.Instance: tsInstance;
begin result := fAdresse.Instance; end;

procedure TxPLListener.HandleHBeatRequest;
begin
     HBReqTimer.Interval := Random(4000) + 2000;     // Choose a random value between 2 and 6 seconds
     HBReqTimer.Enabled  := True;
end;

function TxPLListener.CheckOrigin(aRemoteIP : string): boolean;
begin
     result := True;

     if fSetting.ListenToAny then exit;
     if fSetting.ListenToLocal then
        result := (gStack.LocalAddresses.IndexOf(aRemoteIP) > 0)
     else                   // we're in a list of ip
        result := (AnsiPos(aRemoteIP, fSetting.ListenToAddresses) > 0)
end;

procedure TxPLListener.UDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes;   ABinding: TIdSocketHandle);
var aMessage : TxPLMessage;
begin
   if bDisposing then exit;

   aMessage := TxPLMessage.Create(BytesToString(AData));
   with aMessage do try
      if CheckOrigin(aBinding.PeerIP) then begin
         if ((fAdresse.Equals(Target)) or (Target.Isgeneric) or fFilterSet.CheckGroup(Target.Tag)) then   // It is directed to me
            case Schema.Classe of
                 xpl_scHBeat  : if Schema.TypeAsString = 'request' then HandleHBeatRequest;
                 xpl_scConfig : HandleConfigMessage(aMessage);
            end;

         if (fAdresse.Equals(Source) and (not JoinedxPLNetwork)) then DoxPLJoinedNet(true);

         if (fFilterSet.MatchesFilters(aMessage) and not AwaitingConfiguration ) and
            (PassMyOwnMessages or not fAdresse.Equals(Source))                                                     // 0.92 : to avoid handling of my self emitted messages
         then begin
            if not DoSensorRequest(aMessage) then                                                                  // process messages only once
            if not DoControlBasic (aMessage) then
            if not DoTTSBasic     (aMessage) then
            if not DoHBeatApp     (aMessage) then
            if not DoMediaBasic   (aMessage) then
            if Assigned(OnxPLReceived)       then OnxPLReceived(aMessage);
         end;
      end;

      finally Destroy;
   end;
end;

procedure TxPLListener.DoxPLJoinedNet(aJoined: boolean);
begin
   LogInfo(Format(K_MSG_HUB_FOUND,[IfThen(aJoined,'','not')]));
   if aJoined <> true then exit; { TODO -oGLH : Le cas contraire (perte de hub) devrait etre géré ultérieurement}

   JoinedxPLNetwork := true;
   iNoHubTimerCount := 0;
   HBTimer.Interval := fConfig.HBInterval * 60000;
   if Assigned(OnxPLJoinedNet) then OnxPLJoinedNet(true);
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
     if aMessage.MessageType <> xpl_mtCmnd then exit;
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
     if aMessage.MessageType <> xpl_mtCmnd then exit;
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
     if aMessage.MessageType <> xpl_mtCmnd then exit;
     if aMessage.Schema.Tag  <> K_SCHEMA_TTS_BASIC then exit;
     if aMessage.Source.Tag = fAdresse.Tag then exit;
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
begin
     result := false;
     if not Assigned(OnxPLHBeatApp) then exit;
     if aMessage.MessageType <> xpl_mtStat then exit;
     if aMessage.Schema.Tag  <> K_SCHEMA_HBEAT_APP then exit;
     if aMessage.Source.Tag = fAdresse.Tag then exit;
     OnxPLHBeatApp( aMessage);

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
     if aMessage.MessageType <> xpl_mtCmnd then exit;
     if aMessage.Schema.Tag  <> K_SCHEMA_MEDIA_BASIC then exit;
     if aMessage.Source.Tag = fAdresse.Tag then exit;
     OnxPLMediaBasic( aMessage, aMessage.Body.GetValueByKey('command'),aMessage.Body.GetValueByKey('mp'));

     result := true;
end;

end.


