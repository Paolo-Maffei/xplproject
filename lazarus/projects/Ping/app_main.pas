unit app_main;

{$i compiler.inc}

interface

uses Classes,
     CustApp,
     SysUtils,
     uxPLMessage,
     MKPinger,
     IdICMPClient,
     IdCustomHTTPServer,
     uxPLConfig,
     uxPLWebListener;

type

{ TMyApplication }

TMyApplication = class(TCustomApplication)
        protected
           aMessage    : TxPLMessage;
           FPingerList : TMkPingerList;

           procedure DoRun; override;

           procedure ICMPReply (ASender: TComponent; const ReplyStatus: TReplyStatus);
           procedure ICMPFinish(ASender: TComponent; const AStatistics : TPingerStat);
           procedure PingsFinished(Sender: TObject);
        public
           constructor Create(TheOwner: TComponent); override;
           destructor Destroy; override;

           procedure OnSensorRequest(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
           procedure OnConfigDone(const fConfig : TxPLConfig);
           procedure SendSensorMsg(aMsgType : string; aDevice: string; aValue: string);
           function  AppendAHost(aHostName : string) : TMkPinger;
           procedure RemoveAHost(aHostName : string);
           procedure OnPrereqMet;
           procedure OnReceived(const axPLMsg : TxPLMessage);
           procedure CommandGet(var aPageContent : widestring;  ARequestInfo: TIdHTTPRequestInfo);
           function  ReplaceTag(const aDevice : string; const aParam : string; aValue : string; const aVariable : string; out ReplaceString : string) : boolean;
           function  ReplaceArrayedTag(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean;
     end;

var  xPLApplication : TMyApplication;
     xPLClient      : TxPLWebListener;

implementation
uses uxPLConst,
     StrUtils,
     DOM;

const //======================================================================================
     K_XPL_APP_VERSION_NUMBER ='2.0';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'ping';
     K_DEFAULT_PORT   = '8334';
     K_CONFIG_INTERVAL = 'ping-interval';
     K_CONFIG_TIMEOUT  = 'receive-tmout';
     K_CONFIG_RETRIES  = 'nb-retries';

procedure TMyApplication.DoRun;
begin
   CheckSynchronize;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
   xPLClient := TxPLWebListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE, K_XPL_APP_VERSION_NUMBER,K_DEFAULT_PORT);
   with xPLClient do begin
       OnxPLSensorRequest  := @OnSensorRequest;
       OnxPLConfigDone     := @OnConfigDone;
       OnxPLPrereqMet      := @OnPrereqMet;
       OnCommandGet        := @CommandGet;
       OnReplaceTag        := @ReplaceTag;
       OnReplaceArrayedTag := @ReplaceArrayedTag;
       OnxPLReceived       := @OnReceived;
       Config.AddItem(K_CONFIG_INTERVAL , K_XPL_CT_CONFIG , '', '^[3-9]{1}$' ,1, '5');
       Config.AddItem(K_CONFIG_TIMEOUT  , K_XPL_CT_CONFIG , '', '^[1-9]{1}$' ,1, '5');
       Config.AddItem(K_CONFIG_RETRIES  , K_XPL_CT_CONFIG , '', '^[2-9]{1}$' ,1, '3');
       PrereqList.Add('timer=0');
   end;
   xPLClient.Listen;
   aMessage := xPLClient.PrepareMessage(K_MSG_TYPE_STAT,'');
end;

destructor TMyApplication.Destroy;
begin
  if Assigned(aMessage) then aMessage.Destroy;
  if Assigned(xPLClient) then begin
     xPLClient.destroy;
     FPingerList.Free;
  end;

  xPLClient.Destroy;
  inherited Destroy;
end;

function TMyApplication.AppendAHost(aHostName : string) : TMkPinger;
var elmt : TDOMElement;
begin
     result := nil;

     if fPingerList.ItemByName(aHostName)<> nil then exit;

     elmt := xPLClient.Config.ConfigFile.LocalData.ElementByName[aHostName];
     if elmt=nil then begin
        xPLClient.Config.ConfigFile.LocalData.AddElement(aHostName);
        xPLClient.Config.Save;
     end;

     result := fPingerList.AddNewPing;
     result.Host := aHostName;
     result.OnEachReply := @ICMPReply;
     result.OnFinish    := @ICMPFinish;
end;

procedure TMyApplication.RemoveAHost(aHostName: string);
begin
     if fPingerList.ItemByName(aHostName)<>nil then exit;
     fPingerList.DeletePing(aHostName);
     xPLClient.Config.ConfigFile.LocalData.RemoveElement(aHostName);
     xPLClient.Config.Save;
end;

function TMyApplication.ReplaceTag(const aDevice: string; const aParam : string; aValue : string; const aVariable: string; out ReplaceString: string): boolean;
var item : TMKPinger;
begin
   ReplaceString := '';
   if aParam='hostname' then begin
      item := fPingerList.ItemByName(aValue);
      if Assigned(item) then begin
         if aVariable = 'hostname'  then ReplaceString := Item.Host
         else if aVariable = 'ipaddress' then ReplaceString := IfThen(Item.Statistics.Host<>'',Item.Statistics.Host,'unknown')
         else if aVariable = 'pingtime'  then ReplaceString := FloatToStr(Item.Statistics.RttAvg)
         else if aVariable = 'status'    then ReplaceString := Item.StatusAsString;
      end;
   end;
   result := ReplaceString<>'';
end;

function TMyApplication.ReplaceArrayedTag(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean;
var i : integer;
begin
   if aDevice<>K_DEFAULT_DEVICE then exit;
   ReturnList.Clear;

   if aVariable = 'hostname'  then for i:=0 to fPingerList.Count-1 do ReturnList.Add(TMkPinger(fPingerList.Items[i]).Host)
   else if aVariable = 'ipaddress' then for i:=0 to fPingerList.Count-1 do ReturnList.Add(TMkPinger(fPingerList.Items[i]).Statistics.Host)
   else if aVariable = 'pingtime'  then for i:=0 to fPingerList.Count-1 do ReturnList.Add(FloatToStr(TMkPinger(fPingerList.Items[i]).Statistics.RttAvg))
   else if aVariable = 'status'    then for i:=0 to fPingerList.Count-1 do ReturnList.Add(TMkPinger(fPingerList.Items[i]).StatusAsString);

   result := (ReturnList.Count >0);
end;

procedure TMyApplication.CommandGet(var aPageContent : widestring; ARequestInfo: TIdHTTPRequestInfo);
var aParam : string;
begin
   if ARequestInfo.Params.Count=0 then exit;

      aParam := ARequestInfo.Params.Names[0];
      if aParam ='delete'   then RemoveAHost(ARequestInfo.Params.Values[aParam])
      else if aParam ='add' then AppendAHost(ARequestInfo.Params.Values[aParam]);

end;

procedure TMyApplication.OnConfigDone(const fConfig: TxPLConfig);
var i : integer;
    elmt : TDOMElement;
begin
  if not assigned(FPingerList) then FPingerList := TMkPingerList.Create;
  FPingerList.OnFinish := @PingsFinished;
  FPingerList.TimeOut  := fConfig.ItemName[K_CONFIG_TIMEOUT].AsInteger*1000;

  with xPLClient.Config.ConfigFile do begin
       i := LocalData.Count;
       while i>0 do begin
             dec(i);
             elmt := LocalData[i];
             AppendAHost( elmt.GetAttribute('id'));
       end;
  end;
end;

procedure TMyApplication.OnPrereqMet;
begin
   with xPLClient.Config do begin
   if IsValid then                                     // My configuration has been done
      xPLClient.SendMessage( K_MSG_TYPE_CMND, xPLClient.PrereqList.Values['timer'], K_SCHEMA_TIMER_BASIC,
                             ['action','device','frequence'],['start',xPLClient.Address.Tag,IntToStr(ItemName[K_CONFIG_RETRIES].AsInteger * 60)]);

   end;
end;

procedure TMyApplication.OnReceived(const axPLMsg: TxPLMessage);
begin
   with axPLMsg do begin
      if (MessageType = K_MSG_TYPE_STAT) and                                           // Received a timer status message
         (Schema.Tag = K_SCHEMA_TIMER_BASIC) and
         (Body.GetValueByKey('device') = xPLClient.Address.Tag) and                    // from the timer I created
         (Body.GetValueByKey('current') = 'started') then begin                        // that says he's alive

         if not FPingerList.Pinging then begin
           CheckSynchronize;
           FPingerList.Process;
           CheckSynchronize;
         end;

      end;
   end;
end;

// xPL Messages management =====================================================
procedure TMyApplication.OnSensorRequest(const axPLMsg: TxPLMessage; const aDevice : string; const aAction : string);
var item    : TMkPinger;
begin
    if aAction = 'current' then begin
       item := fPingerList.ItemByName(aDevice);
       if item<>nil then SendSensorMsg(K_MSG_TYPE_STAT,aDevice, item.StatusAsString);
    end;
end;

procedure TMyApplication.SendSensorMsg(aMsgType : string; aDevice: string; aValue: string);
begin
   aMessage.Header.MessageType := aMsgType;
   aMessage.Format_SensorBasic(aDevice,'ping',aValue);
   xPLClient.Send(aMessage);
end;

// Ping management =============================================================
procedure TMyApplication.ICMPReply(ASender: TComponent;  const ReplyStatus: TReplyStatus);
begin
  CheckSynchronize;
  xPLClient.LogInfo('%32s %17s %5d ms  %2d RStatus',[TMkPinger(aSender).Host, ReplyStatus.FromIpAddress, ReplyStatus.MsRoundTripTime, ord( ReplyStatus.ReplyStatusType)]);
end;

procedure TMyApplication.ICMPFinish(ASender: TComponent; const AStatistics: TPingerStat);
var item    : TMkPinger;
begin
  CheckSynchronize;
  item := fPingerList.ItemByName(TMkPinger(aSender).Host);

  if not assigned (item) then exit;
  if item.OldStatus<>item.StatusAsSTring then begin
     SendSensorMsg(K_MSG_TYPE_TRIG,item.Host,AnsiLowerCase(item.StatusAsSTring));
     item.OldStatus := item.StatusAsString;
  end;

  xPLClient.LogInfo('Pinging...',[]);
end;

procedure TMyApplication.PingsFinished(Sender: TObject);
begin
    CheckSynchronize;
end;

initialization
   xPLApplication:=TMyApplication.Create(nil);

end.

