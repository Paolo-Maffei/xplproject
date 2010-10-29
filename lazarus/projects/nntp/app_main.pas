unit app_main;

{$i compiler.inc}

interface

uses
  Classes,
  SysUtils,
  CustApp,
  IdNNTP,
  uxPLMessage,
  uxPLConfig,
  uxPLListener;

type

{ TMyApplication }

  TMyApplication = class(TCustomApplication)
     protected
        IdNNTP : TIdNNTP;
        fMonitored : TStringList;
        procedure DoRun; override;

        procedure ReadFromXML;
        procedure WriteToXML;
     public
        constructor Create(TheOwner: TComponent); override;
        procedure OnReceived(const axPLMsg : TxPLMessage);
        procedure OnConfigDone(const fConfig : TxPLConfig);
        procedure OnPrereqMet;
        procedure OnControlBasic(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
        destructor Destroy; override;
        procedure CheckNNTP;
     end;

var  xPLApplication : TMyApplication;
     xPLClient      : TxPLListener;

// Informations regarding NNTP component : http://www.felix-colibri.com/papers/web/threaded_indy_news_reader/threaded_indy_news_reader.html
implementation //===============================================================
uses uxPLConst,
     FileUtil,
     uRegExpr,
     IdMessage,
     IdHTTP;

//==============================================================================
const
     K_XPL_APP_VERSION_NUMBER = '0.8';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'nntp';

     K_CONFIG_NEWS_HOST   = 'newssrvr';
     K_CONFIG_NEWS_USER   = 'newsuser';
     K_CONFIG_NEWS_PASS   = 'newspass';

//==============================================================================
procedure TMyApplication.DoRun;
var ErrorMsg: String;
begin
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  if HasOption('h','help') then begin
    Terminate;
    Exit;
  end;

  while true do begin
        CheckSynchronize;
  end;
  Terminate;
end;

procedure TMyApplication.ReadFromXML;
var i : integer;
begin
   i := StrToInt(xPLClient.Config.XMLFile.GetValue('Monitored/groups', '0')) - 1;
   while i>=0 do begin
      fMonitored.Add(xPLClient.Config.XMLFile.GetValue('Monitored/groups/N' + IntToStr(i),''));
      xPLClient.LogInfo('Restoring monitoring of "%s" at index : %s',[fMonitored.Names[fMonitored.Count-1],fMonitored.ValueFromIndex[fMonitored.Count-1]]);
      dec(i);
   end;
end;

procedure TMyApplication.WriteToXML;
var i : integer;
begin
   xPLClient.Config.XMLFile.SetValue('Monitored/groups',fMonitored.Count);
   for i:=0 to fMonitored.Count-1 do
       xPLClient.Config.XMLFile.SetValue('Monitored/groups/N' + IntToStr(i), fMonitored[i]);
   xPLClient.Config.XMLFile.Flush;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fMonitored := TStringList.Create;
  fMonitored.Duplicates := dupIgnore;
  IdNNTP := TIdNNTP.Create;
  xPLClient := TxPLListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER);
  with xPLClient do begin
     OnxPLReceived   := @OnReceived;
     OnxPLConfigDone := @OnConfigDone;
     OnxPLControlBasic := @OnControlBasic;
     OnxPLPrereqMet    := @OnPrereqMet;
     Config.AddItem(K_CONFIG_NEWS_USER, K_XPL_CT_CONFIG);
     Config.AddItem(K_CONFIG_NEWS_PASS, K_XPL_CT_CONFIG);
     Config.AddItem(K_CONFIG_NEWS_HOST, K_XPL_CT_CONFIG,'news.free.fr');
     PrereqList.Add('timer=0');
     Listen;
  end;
end;

procedure TMyApplication.OnPrereqMet;
begin
   // Initializes my timer to scan newsgroups
   xPLClient.SendMessage( K_MSG_TYPE_CMND,  xPLClient.PrereqList.Values['timer'], 'control.basic',
                          ['current','device','frequence'], ['start', xPLClient.Address.Tag, '60']);
end;

procedure TMyApplication.OnReceived(const axPLMsg: TxPLMessage);
begin
   if (axPLMsg.MessageType = K_MSG_TYPE_STAT) and                               // When I receive my timer tick
      (axPLMsg.Schema.Tag = 'timer.basic') and
      (axPLMsg.Body.GetValueByKey('device') = xPLClient.Address.Tag) and
      (axPLMsg.Body.GetValueByKey('current') = 'started') then begin
      CheckNNTP;
   end;
end;

procedure TMyApplication.CheckNNTP;
var high, low, lastnews, i : integer;
    idMessage   : TIdMessage;
    group       : string;
    bChanges : boolean;
begin
   IdNNTP.Connect;
   bChanges := false;
   if IdNNTP.Connected then begin
      xPLClient.LogInfo('Checking groups',[]);
      IdMessage := TIdMessage.Create;
      for i := 0 to fMonitored.Count-1 do begin
          group := fMonitored.Names[i];
          lastnews  := StrToInt(fMonitored.ValueFromIndex[i]);
          IdNNTP.SelectGroup(group);
          high := IdNNTP.MsgHigh;
          low  := IdNNTP.MsgLow;
          if low < lastnews then low := lastnews;
          while (low < high) do begin
               IdNNTP.GetArticle(low+1,idMessage);
               xPLClient.SendOSDBasic(group + ' : ' + idMessage.Subject);
               inc(low);
               bChanges := true;
          end;
          fMonitored.ValueFromIndex[i] := IntToStr(high);
      end;
      IdMessage.Destroy;
      IdNNTP.Disconnect;
   end;
   if bChanges then WriteToXML;
end;

procedure TMyApplication.OnConfigDone(const fConfig: TxPLConfig);
begin
   IdNNTP.Host     := xPLClient.Config.ItemName[K_CONFIG_NEWS_HOST].Value ;
   IdNNTP.Username := xPLClient.Config.ItemName[K_CONFIG_NEWS_USER].Value ;
   IdNNTP.Password := xPLClient.Config.ItemName[K_CONFIG_NEWS_PASS].Value ;
   ReadFromXML;
end;

procedure TMyApplication.OnControlBasic(const axPLMsg: TxPLMessage; const aDevice: string; const aAction: string);
const chaine = 'Ok boss, I will no%s monitor %s';
var i : integer;
begin
   i := fMonitored.IndexOfName(aDevice);
   if (aAction =  'start') and ( i = -1) then begin
      fMonitored.Add(aDevice + '=0');
      xPLClient.LogInfo(chaine,['w', aDevice]);
   end else if (aAction = 'stop') and (i <> -1) then begin
       fMonitored.Delete(i);
       xPLClient.LogInfo(chaine,[' longer', aDevice]);
   end;
   WriteToXML;
end;

destructor TMyApplication.Destroy;
begin
   xPLClient.Destroy;
   fMonitored.Destroy;
   IdNNTP.Destroy;
   inherited Destroy;
end;

initialization
   xPLApplication:=TMyApplication.Create(nil);
end.

