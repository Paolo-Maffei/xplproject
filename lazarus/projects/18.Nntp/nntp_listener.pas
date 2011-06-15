unit Nntp_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses Classes
     , SysUtils
     , IdNNTP
     , u_xpl_listener
     , u_xpl_message
     ;

type

{ TxPLNNTPListener }

     TxPLNNTPListener = class(TxPLListener)
     protected
        IdNNTP : TIdNNTP;
     private
        fMonitored : TStringList;
     public
        constructor Create(const aOwner : TComponent); overload;
        destructor  Destroy; override;
        procedure   OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;
        procedure   OnPrereqMet;
        procedure   UpdateConfig; override;
        procedure   Process(const aMessage : TxPLMessage);
        procedure   CheckNNTP;
     published
        property Monitored : TStringList read fMonitored write fMonitored;
     end;


implementation
uses u_xpl_common
     , u_xpl_header
     , u_xpl_config
     , u_xpl_schema
     , u_xpl_body
     , TypInfo
     , IdMessage
     , IdHTTP
     , DateUtils
     , uxPLConst
     , u_xpl_custom_message
     , LResources
     ;
const //======================================================================================
     K_CONFIG_NEWS_HOST   = 'newssrvr';
     K_CONFIG_NEWS_USER   = 'username';
     K_CONFIG_NEWS_PASS   = 'password';

// ===========================================================================================
{ TxPLNNTPListener }

constructor TxPLNNTPListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);

   Config.DefineItem(K_CONFIG_NEWS_HOST, TxPLConfigItemType.config,1,'news.free.fr');
   Config.DefineItem(K_CONFIG_NEWS_USER,TxPLConfigItemType.config,1);
   Config.DefineItem(K_CONFIG_NEWS_PASS,TxPLConfigItemType.config,1);

   fMonitored := TStringList.Create;
   fMonitored.Duplicates := dupIgnore;

   IdNNTP := TIdNNTP.Create;

   PrereqList.DelimitedText := 'timer';
   OnxPLPrereqMet    := @OnPrereqMet;

   FilterSet.AddValues([ 'xpl-cmnd.*.*.*.control.basic',
                         'xpl-stat.*.*.*.timer.basic']);
end;

destructor TxPLNNTPListener.Destroy;
begin
   IdNNTP.Free;
   inherited Destroy;
   fMonitored.Free;
end;

procedure TxPLNNTPListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
   if CompareText(AClassName, 'TxPLNNTPListener') = 0 then ComponentClass := TxPLNNTPListener
   else inherited;
end;

procedure TxPLNNTPListener.UpdateConfig;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin
     IdNNTP.Host     := Config.GetItemValue(K_CONFIG_NEWS_HOST) ;
     IdNNTP.Username := Config.GetItemValue(K_CONFIG_NEWS_USER) ;
     IdNNTP.Password := Config.GetItemValue(K_CONFIG_NEWS_PASS) ;
     OnxPLReceived := @Process;
  end else OnxPLReceived := nil;
end;

procedure TxPLNNTPListener.OnPrereqMet;
begin
   SendMessage( cmnd, DeviceAddress('timer'), 'timer.basic',                   // Initializes my timer to scan newsgroups
   ['action','device','frequence'],['start',Adresse.RawxPL,'60']);

end;


procedure TxPLNNTPListener.Process(const aMessage: TxPLMessage);
const chaine = 'Ok boss, I will no%s monitor %s';
var i : integer;
    aDevice,aAction : string;
begin
   if aMessage.Schema.Equals(Schema_ControlBasic) then begin
      aDevice := aMessage.Body.GetValueByKey('device');
      aAction := aMessage.Body.GetValueByKey('current');
      i := fMonitored.IndexOfName(aDevice);
      if (aAction =  'start') and ( i = -1) then begin
         fMonitored.Add(aDevice + '=0');
         Log(etInfo,chaine,['w', aDevice]);
      end else if (aAction = 'stop') and (i <> -1) then begin
          fMonitored.Delete(i);
          Log(etInfo,chaine,[' longer', aDevice]);
      end;
      SaveConfig;
   end;
   if (aMessage.MessageType = stat) and                               // When I receive my timer tick
      (aMessage.Schema.Equals(Schema_TimerBasic)) and
      (aMessage.Body.GetValueByKey('device') = Adresse.RawxPL) and
      (aMessage.Body.GetValueByKey('current') = 'started') then begin
      CheckNNTP;
   end;
end;

procedure TxPLNNTPListener.CheckNNTP;
var high, low, lastnews, i : integer;
    idMessage   : TIdMessage;
    group       : string;
    bChanges : boolean;
begin
   if fMonitored.Count > 0 then begin
      if not IdNNTP.Connected then IdNNTP.Connect;
      bChanges := false;
      if IdNNTP.Connected then begin
         Log(etInfo,'Checking groups');
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
                  SendOSDBasic(group + ' : ' + idMessage.Subject);
                  inc(low);
                  bChanges := true;
             end;
             fMonitored.ValueFromIndex[i] := IntToStr(high);
         end;
         IdMessage.Free;
         IdNNTP.Disconnect;
      end;
      if bChanges then SaveConfig;
   end;
end;


end.

