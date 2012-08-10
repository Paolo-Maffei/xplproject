unit jabber_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses Classes
     , SysUtils
     , u_xpl_custom_listener
     , u_xpl_config
     , u_xpl_schema
     , fpTimer
     , u_xpl_message
     , uxmpp
     ;

type // TxPLjabberListener ====================================================
     TxPLjabberListener = class(TxPLCustomListener)
     private
        fXMPP : TXMPP;
        fRoster : TStringList;
     protected
        procedure DoOnError(Sender:TObject;Value:string);
        procedure DoOnLoggin(Sender:TObject);
        procedure DoOnLogout(Sender:TObject);
        procedure DoOnDebugXML(Sender:TObject;Value:string);
        procedure DoOnMsg(Sender:TObject;From,MsgText,MsgHTML:string; TimeStamp:TDateTime;MsgType:TMessageType);
        procedure DoOnJoinedRoom(Sender:TObject;JID:string);
        procedure DoOnLeftRoom(Sender:TObject;JID:string);
        procedure DoOnRoster(Sender:TObject;JID,aName,Subscription,Group:string);

     public
        constructor Create(const aOwner : TComponent); reintroduce;
        Destructor  Destroy; override;
        procedure   UpdateConfig; override;
        procedure   Process(const aMessage : TxPLMessage);
     published
     end;

var  Schema_DDBasic : TxPLSchema;

implementation
uses StrUtils
     , TypInfo
     , u_xpl_messages
     , u_xpl_common
     ;
const //=======================================================================
     K_CONFIG_USER = 'username';
     K_CONFIG_PWD  = 'password';
     K_CONFIG_SRVR = 'server';
     K_CONFIG_PORT = 'port';

// TxPLjabberListener =========================================================
constructor TxPLjabberListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);

   Config.DefineItem(K_CONFIG_USER, TxPLConfigItemType.config,1,'domotique.lhopital@gmail.com');
   Config.DefineItem(K_CONFIG_PWD , TxPLConfigItemType.config,1,'pendoloch');
   Config.DefineItem(K_CONFIG_SRVR, TxPLConfigItemType.reconf,1,'gmail.com');
   Config.DefineItem(K_CONFIG_PORT, TxPLConfigItemType.reconf,1,'5222');

   fRoster := TStringList.Create;
   fRoster.Duplicates := dupIgnore;

   fXMPP := TXmpp.Create;
   with fXMPP do begin
      OnError          := @DoOnError;
      OnDebugXML       := @DoOnDebugXML;
      OnMessage        := @DoOnMsg;
      OnUserJoinedRoom := @DoOnJoinedRoom;
      OnUserLeftRoom   := @DoOnLeftRoom;
      OnLogin          := @DoOnLoggin;
      OnLogout         := @DoOnLogout;
      OnRoomList       := @DoOnDebugXML;
      OnRoster         := @DoOnRoster;
   end;
end;

destructor TxPLjabberListener.Destroy;
begin
   if fXMPP.IsConnected then fXMPP.Logout;
   fXMPP.Free;
   fRoster.Free;
   inherited Destroy;
end;

procedure TxPLjabberListener.UpdateConfig;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin
     fXMPP.Host := Config.GetItemValue(K_CONFIG_SRVR);
     fXMPP.Port := Config.GetItemValue(K_CONFIG_PORT);
     fXMPP.JabberID := Config.GetItemValue(K_CONFIG_USER);
     fXMPP.Password := Config.GetItemValue(K_CONFIG_PWD);
     OnxPLReceived    := @Process;
     fXMPP.Login;
  end else OnxPLReceived := nil;
end;

procedure TxPLjabberListener.DoOnLoggin(Sender: TObject);
var aMsg : TLogBasic;
begin
   aMsg := TLogBasic.Create(self);
   aMsg.Type_ := etInfo;
   aMsg.Text  := 'successfully connected to ' + fXMPP.Host;
   Send(aMsg);
   aMsg.Free;
end;

procedure TxPLjabberListener.DoOnLogout(Sender: TObject);
var aMsg : TLogBasic;
begin
   aMsg := TLogBasic.Create(self);
   aMsg.Type_ := etInfo;
   aMsg.Text  := 'disconnected from ' + fXMPP.Host;
   Send(aMsg);
   aMsg.Free;
end;

procedure TxPLjabberListener.DoOnError(Sender: TObject; Value: string);
var aMsg : TLogBasic;
begin
   aMsg := TLogBasic.Create(self);
   aMsg.Type_ := etError;
   aMsg.Text  := value;
   Send(aMsg);
   aMsg.Free;
end;

procedure TxPLjabberListener.Process(const aMessage: TxPLMessage);
var to_, body : string;
begin
   if aMessage is TSendmsgBasic then with TSendMsgBasic(aMessage) do begin
      if MessageType = cmnd then
        fXMPP.SendPersonalMessage(To_, Text);
   end;
end;

procedure TxPLjabberListener.DoOnDebugXML(Sender: TObject; Value: string);
begin

end;

procedure TxPLjabberListener.DoOnMsg(Sender: TObject; From, MsgText, MsgHTML: string; TimeStamp: TDateTime; MsgType: TMessageType);
var aMsg : TReceiveMsgBasic;
    aFrom : string;
begin
   aFrom := AnsiLeftStr(From,Pred(AnsiPos('/',From)));
   aMsg := TReceiveMsgBasic.Create(self);
   aMsg.From := aFrom;
   aMsg.Text := MsgText;
   Send(aMsg);
   aMsg.Free;
end;

procedure TxPLjabberListener.DoOnJoinedRoom(Sender: TObject; JID: string);
var aMsg : TSensorBasic;
    aFrom, current : string;

begin
   aFrom := AnsiLeftStr(JID,Pred(AnsiPos('/',JID)));

   current  := 'present';
   if fRoster.Values[aFrom] = '' then fRoster.Add(aFrom + '=absent');
   if fRoster.Values[aFrom] = current then exit;

   aMsg := TSensorBasic.Create(self);
   aMsg.Device := aFrom;
   aMsg.Type_  := 'presence';
   aMsg.Current:= current;
   Send(aMsg);
   aMsg.Free;

   fRoster.Values[aFrom] := current;
end;

procedure TxPLjabberListener.DoOnLeftRoom(Sender: TObject; JID: string);
var aMsg : TSensorBasic;
    aFrom, previous, current : string;

begin
   aFrom := AnsiLeftStr(JID,Pred(AnsiPos('/',JID)));

   current  := 'absent';
   if fRoster.Values[aFrom] = '' then fRoster.Add(aFrom + '=present');
   if fRoster.Values[aFrom] = current then exit;

   aMsg := TSensorBasic.Create(self);
   aMsg.Device := aFrom;
   aMsg.Type_  := 'presence';
   aMsg.Current:= current;
   Send(aMsg);
   aMsg.Free;

   fRoster.Values[aFrom] := current;
end;

procedure TxPLjabberListener.DoOnRoster(Sender: TObject; JID, aName, Subscription, Group: string);
begin

end;


end.
