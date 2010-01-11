unit uxPLListener;
{==============================================================================
  UnitName      = uxPLListener
  UnitVersion   = 0.91
  UnitDesc      = xPL Listener object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Seperation of basic xPL Client (listener and sender) from pure listener
 0.92 : Modification made to avoid handling of my own emitted messages
}

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, uxPLAddress, IdUDPServer,IdSocketHandle,
     ExtCtrls, IdGlobal,uxPLMessage, uxPLConfig,  uXPLFilter,
     uxPLMsgBody,  uxPLMsgHeader, uxPLClient;

type
      TxPLReceivedEvent = procedure(const axPLMsg : TxPLMessage) of object;
      TxPLJoinedEvent   = procedure(const aJoined : boolean)     of object;
      TxPLConfigDone    = procedure(const fConfig : TxPLConfig)  of object;
      TxPLHBeatPrepare  = procedure(const aBody   : TxPLMsgBody) of object;
      TxPLSensorRequest = procedure(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string) of object;
      TxPLTTSBasic      = procedure(const axPLMsg : TxPLMessage; const aSpeech : string) of object;

      { TxPLListener }

      TxPLListener = class(TxPLClient)
      protected
        FOnxPLReceived      : TxPLReceivedEvent;
        FOnxPLJoinedNet     : TxPLJoinedEvent;
        FOnxPLHBeatPrepare  : TxPLHBeatPrepare;
        FOnxPLConfigDone    : TxPLConfigDone;
        FOnxPLSensorRequest : TxPLSensorRequest;
        FOnxPLControlBasic  : TxPLSensorRequest;
        FOnxPLTTSBasic      : TxPLTTSBasic;


      private
        fConfig : TxPLConfig;
        fAdresse : TxPLAddress;
        IncomingSocket : TIdUDPServer;
        HBTimer,HBReqTimer   : TTimer;                       // HBReqTimer is dedicated to hbeat requests
        fFilterSet : TxPLFilters;
        iNoHubTimerCount : integer;
        bHubFound  : Boolean;
        bDisposing : Boolean;

        bConfigOnly : Boolean;

        procedure InitSocket();
        procedure HandleError(aError : string);
     public
        PassMyOwnMessages : boolean;

        constructor create(aOwner : TComponent; aVendor, aDevice, aAppName, aAppVersion : string);
        destructor destroy; override;
        procedure CallConfigDone; dynamic;
        procedure TimerElapsed(Sender : TObject);
        procedure HandleHBeatRequest;   dynamic;
        procedure SendHeartBeatMessage; dynamic;
        procedure HandleConfigMessage(aMessage : TxPLMessage); dynamic;

        property Config              : TxPLConfig read fConfig;
        property AwaitingConfiguration : Boolean read bConfigOnly write bConfigOnly;
        property Address             : TxPLAddress read fAdresse;

        property OnxPLReceived      : TxPLReceivedEvent  read FOnxPLReceived      write FOnxPLReceived;
        property OnxPLJoinedNet     : TxPLJoinedEvent    read FOnxPLJoinedNet     write FOnxPLJoinedNet;
        property OnxPLCOnfigDone    : TxPLConfigDone     read FOnxPLConfigDone    write FOnxPLConfigDone;
        property OnxPLHBeatPrepare  : TxPLHBeatPrepare   read FOnxPLHBeatPrepare  write FOnxPLHBeatPrepare;
        property OnxPLSensorRequest : TxPLSensorRequest  read FOnxPLSensorRequest write FOnxPLSensorRequest;
        property OnxPLControlBasic  : TxPLSensorRequest  read FOnxPLControlBasic  write FOnxPLControlBasic;
        property OnxPLTTSBasic      : TxPLTTSBasic       read FOnxPLTTSBasic      write FOnxPLTTSBasic;

        procedure DoxPLJoinedNet(aJoined    : boolean);
        function DoSensorRequest(aMessage : TxPLMessage) : boolean;
        function DoControlBasic (aMessage : TxPLMessage) : boolean;
        function DoTTSBasic     (aMessage : TxPLMessage) : boolean;

        function  CheckOrigin(aRemoteIP : string) : boolean;
        procedure UDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
        procedure SendMessage(const aMsgType : TxPLMessageType; const aDest : string; const aRawBody : string);
        procedure SendRawxPL(const aRawXPL : string);
        function  PrepareMessage(const aMsgType: TxPLMessageType; const aSchema : string; const aTarget : string = '*') : TxPLMessage;

        property JoinedxPLNetwork : boolean read bHubFound;

        procedure Listen;
        procedure Dispose;
     end;

implementation { ==============================================================}
uses IdStack,uxplcfgitem, cRandom, StrUtils, uxPLSchema, uIPutils, Interfaces;
Const XPL_BASE_DYNAMIC_PORT : Integer = 50000;           // First port used to try to open the listening port
      XPL_BASE_PORT_RANGE   : Integer = 512;             //       Range of port to scan for trying to bind socket
      MAX_XPL_MSG_SIZE      : Integer = 1500;            // Maximum size of a xpl message
      NOHUB_HBEAT           : Integer = 3;               // seconds between HBEATs until hub is detected
      NOHUB_LOWERFREQ       : Integer = 30;              // lower frequency probing for hub
      NOHUB_TIMEOUT         : Integer = 120;             // after these nr of seconds lower the probing frequency to NOHUB_LOWERFREQ

{ TxPLListener ================================================================}


constructor TxPLListener.create(aOwner : TComponent; aVendor, aDevice, aAppName, aAppVersion : string);
begin
   inherited Create(aOwner, aAppName, aAppVersion);

   PassMyOwnMessages := false;

   fAdresse := TxPLAddress.Create(aVendor,aDevice);
      fAdresse.Instance := TxPLAddress.RandomInstance ;

   fConfig:= TxPLConfig.Create(self);

   fFilterSet := TxPLFilters.Create(fConfig);

   HBTimer := TTimer.Create(self);

   HBReqTimer := TTimer.Create(self);
      HBReqTimer.OnTimer  := @TimerElapsed;

   try
     IncomingSocket:=TIdudpServer.create;
     IncomingSocket.Bindings.Clear;
     IncomingSocket.BufferSize := MAX_XPL_MSG_SIZE;
     IncomingSocket.OnUDPRead  := @UDPRead;
   except
     HandleError('Unable to initialize incoming UDP server');
   end;

   bHubFound := False;
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
     inherited destroy;
end;

procedure TxPLListener.InitSocket();
var Binding : TIdSocketHandle;
    i : integer;
begin
     i := gstack.LocalAddresses.Count-1;
     while i>=0 do begin
        //fSetting.ListenOnAll or (gStack.LocalAddresses[i] = fSetting.ListenOnAddress)
        // If network settings are not prepared, then ListenOnAddress may be empty
        if fSetting.ListenOnAll or (gStack.LocalAddresses[i] = fSetting.ListenOnAddress) then begin
            Binding := IncomingSocket.Bindings.Add;
            Binding.ClientPortMin := XPL_BASE_DYNAMIC_PORT;
            Binding.ClientPortMax := Binding.ClientPortMin + XPL_BASE_PORT_RANGE;
            Binding.Port          := 0;
            Binding.IP            := gstack.LocalAddresses[i];
            LogInfo('Client binded on port ' + IntToStr(Binding.Port) + ' for address ' + Binding.IP);
        end;
        dec(i);
     end;

     If IncomingSocket.Bindings.Count > 0 then begin                             // Lets be sure we found an address to bind to
        IncomingSocket.Active:=true;
        HBTimer.Interval := NOHUB_HBEAT * 1000;
        HBTimer.OnTimer  := @TimerElapsed;
        HBTimer.Enabled  := True;
        TimerElapsed(self);
     end else HandleError('Socket unable to bind to IP Addresses');

end;

procedure TxPLListener.HandleError(aError: string);
begin
   LogError(aError);
   Raise Exception.Create(aError);
end;

procedure TxPLListener.CallConfigDone;
begin
     if Assigned(OnxPLConfigDone) then OnxPLConfigDone(fConfig);
end;

procedure TxPLListener.Listen;
begin                                                       
  if bDisposing then bDisposing := false;
  bConfigOnly := not fConfig.Load(fAdresse.Vendor + '-' + fAdresse.Device);
  if not bConfigOnly then begin
                          fAdresse.Instance := fConfig.Instance;
                          CallConfigDone;
                     end
                     else fConfig.Instance  := fAdresse.Instance;
  InitSocket;
end;

procedure TxPLListener.Dispose;
begin
   bDisposing := True;
   if bHubFound then SendHeartBeatMessage;
   if IncomingSocket.Active then IncomingSocket.Active := False;
end;

procedure TxPLListener.SendMessage(const aMsgType : TxPLMessageType; const aDest : string; const aRawBody : string);
var MyMessage : TxPLMessage;
begin
   MyMessage := TxPLMessage.Create;
   MyMessage.Source.Assign(fAdresse);

   with MyMessage do begin
          Body.ResetValues ;
          MessageType := aMsgType;
          Source.Assign(fAdresse);
          Target.Tag  := aDest;
          Body.RawxPL := aRawBody;
          if IsValid then Send
                     else LogError('Error sending message :' + RawXPL);
   end;
   MyMessage.Destroy;
end;

procedure TxPLListener.SendRawxPL(const aRawXPL : string);
begin
   with TxPLMessage.Create do begin
        RawXPL := aRawXPL;
        Source.Assign(fAdresse);
        Send;
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

procedure TxPLListener.SendHeartBeatMessage;
var i : integer;
    aBody : TxPLMsgBody;
begin
     aBody := TxPLMsgBody.Create;
     with aBody do try
        for i:=0 to IncomingSocket.Bindings.Count-1 do begin
            Format_HbeatApp(IntToStr(fConfig.HBInterval),
                            IntToStr(IncomingSocket.Bindings[i].Port),
                            IncomingSocket.Bindings[i].IP);
            aBody.AddKeyValuePair('appname', fAppName);
            aBody.AddKeyValuePair('version', fAppVersion);

            if bConfigOnly then Schema.Classe := xpl_scConfig;                // Change Schema class in this case
            if bDisposing  then Schema.TypeAsString   := 'end';               // Change Schema type in this case
            if Assigned(OnxPLHBeatPrepare) then OnxPLHBeatPrepare(aBody);
            SendMessage(xpl_mtStat,'*',RawxPL);
        end;
        finally Destroy;
     end;
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
    bConfigOk : boolean;
begin
  if aMessage.Header.MessageType <> xpl_mtCmnd then exit;

  with TxPLMessage.Create do try
     Header.MessageType := xpl_mtStat;
     Header.Source.Assign(fAdresse);
     Header.Target.IsGeneric := True;
     Body.ResetValues;

     case AnsiIndexStr(aMessage.Body.Schema.TypeAsString, ['current', 'list', 'response']) of
          // config.current message handling =========================================
          0 : if aMessage.Body.GetValueByKey('command') = 'request' then begin
                 Body.Schema.Tag := aMessage.Body.Schema.Tag;
                 for i := 0 to fConfig.Count-1 do
                     for j:= 0 to fConfig[i].ValueCount -1 do
                         Body.AddKeyValuePair(fConfig[i].Key,fConfig[i].Values[j]);
                 Send;
              end;
          // config.list message handling ============================================
          1 : begin
                Body.Schema.Tag := aMessage.Body.Schema.Tag;
                for i := 0 to fConfig.Count-1 do
                    Body.AddKeyValuePair( fConfig[i].ConfigTypeAsString,
                                          fConfig[i].Key + fConfig[i].MaxValueAsString);
                Send ;
              end;
          // config.response message handling ========================================
          2 : begin
                fConfig.ResetValues;
                bConfigOk := true;
                for i:= 0 to aMessage.Body.ItemCount-1 do
                    if not fConfig.SetItem( AnsiLowerCase(aMessage.Body.Keys[i]), aMessage.Body.Values[i])   // Some configuration elements may need to be upper/lower sensitive
                       then begin
                          self.LogError('Error setting value of config item "'+ aMessage.Body.Keys[i]+'" to "'+aMessage.Body.Values[i]+'"');
                          bConfigOk := false;
                       end;
                if bConfigOk then begin
                   fAdresse.Instance := fConfig.Instance;    // Instance name may have changed
                   bConfigOnly := False;
                   SendHeartBeatMessage;
                   fConfig.Save(fAdresse.Vendor + '-' + fAdresse.Device);
                   CallConfigDone;
                end;
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

function TxPLListener.CheckOrigin(aRemoteIP : string): boolean;
begin
     result := True;
     // These values may be empty if network setting are not initialized to be checked earlier
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

         if (fAdresse.Equals(Source) and (not bHubFound)) then DoxPLJoinedNet(true);

         if (fFilterSet.MatchesFilters(aMessage) and not bConfigOnly ) and
            (PassMyOwnMessages or not fAdresse.Equals(Source))                                                     // 0.92 : to avoid handling of my self emitted messages
         then begin
            if not DoSensorRequest(aMessage) then                                                                  // process messages only once
            if not DoControlBasic (aMessage) then
            if not DoTTSBasic     (aMessage) then
            if Assigned(OnxPLReceived) then OnxPLReceived(aMessage);
         end;
      end;

      finally Destroy;
   end;
end;

procedure TxPLListener.DoxPLJoinedNet(aJoined: boolean);
begin
   if aJoined <> true then exit; { TODO -oGLH : Le cas contraire (perte de hub) devrait etre géré ultérieurement}

   bHubFound := aJoined;
   iNoHubTimerCount := 0;
   HBTimer.Interval := fConfig.HBInterval * 60000;
   if Assigned(FOnxPLJoinedNet) then OnxPLJoinedNet(true);
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
     if aMessage.Schema.Tag  <> 'sensor.request' then exit;

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
     if aMessage.Schema.Tag  <> 'control.basic' then exit;

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
     if aMessage.Schema.Tag  <> 'tts.basic' then exit;
     if aMessage.Source.Tag = fAdresse.Tag then exit;
     OnxPLTTSBasic( aMessage, aMessage.Body.GetValueByKey('speech') );

     result := true;
end;

end.


