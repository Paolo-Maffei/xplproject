unit configurator_listener;

{$mode objfpc}{$H+}

interface

uses Classes
     , SysUtils
     , u_xpl_listener
     , u_xpl_message
     , u_xpl_custom_listener
     , u_configuration_record
     ;

type { TConfigListener }
     TConfigListener = class(TxPLListener)
     private
       //fDiscovered: TConfigurationRecordList;
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        function    DoHBeatApp (const aMessage : TxPLMessage) : boolean; override;
        procedure   OnReceive(const axPLMsg : TxPLMessage);
        procedure   Set_ConnectionStatus(const aValue : TConnectionStatus); override;
        procedure   OnDie(Sender : TObject); override;
     published
        property    Discovered : TConfigurationRecordList read fDiscovered;
     end;

implementation // =============================================================

uses u_xpl_common
     , u_xpl_schema
     , u_xpl_messages
     ;

{ TConfigListener }

constructor TConfigListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);

   Config.FilterSet.Add('xpl-stat.*.*.*.hbeat.app');
   Config.FilterSet.Add('xpl-stat.*.*.*.hbeat.end');
   Config.FilterSet.Add('xpl-stat.*.*.*.config.app');
   Config.FilterSet.Add('xpl-stat.*.*.*.config.current');
   Config.FilterSet.Add('xpl-stat.*.*.*.config.response');
   Config.FilterSet.Add('xpl-stat.*.*.*.config.list');

   OnxPLReceived      := @OnReceive;
end;

function TConfigListener.DoHBeatApp(const aMessage: TxPLMessage): boolean;
var i : integer;
    Msg : TConfigListCmnd;
    LogMsg : TLogBasic;
begin
   i := fDiscovered.Count;
   Result:=inherited DoHBeatApp(aMessage);

   if fDiscovered.Count<>i then begin                                          // a new module was identified
      Msg := TConfigListCmnd.Create(self);                                     // then ask him its configuration
      Msg.Target.Assign(aMessage.Source);
      Send(Msg);
      Msg.Free;

      LogMsg := TLogBasic.Create(self);
      LogMsg.Type_:= etInfo;
      LogMsg.Text := aMessage.Source.RawxPL + ' discovered';
      Send(LogMsg);
      LogMsg.Free;
   end;
end;

procedure TConfigListener.OnReceive(const axPLMsg: TxPLMessage);
var item : integer;
    Config_Elmt: TConfigurationRecord;
    Msg : TConfigCurrentCmnd;
begin
   if ((axPLMsg.Body.Keys.Count = 0) or
       (axPLMsg.Schema.Classe <> 'config') or
       (axPLMsg.MessageType <> stat)) then exit;                               // Don't handle config request messages

   item := fDiscovered.IndexOf(axPLMsg.Source.Device);                         // I received a config.app message,
   if item = -1 then begin
         axPLMsg.Schema.Assign(Schema_HBeatApp);                               // handle it as an HBeatMessage
         DoHBeatApp(axPLMsg);
         exit;
   end;

   Config_Elmt := fDiscovered.Data[item];
   if axPLMsg.Schema.Equals(Schema_ConfigList) then begin
      Config_Elmt.Config.ConfigList.Assign(axPLMsg);
      Msg := TConfigCurrentCmnd.Create(self);
      Msg.target.Assign(axPLMsg.source);
      Send(Msg);
      Msg.Free;
   end else if axPLMsg.Schema.Equals(Schema_ConfigCurr) then begin
      Config_Elmt.Config.CurrentConfig.Assign(axPLMsg);
   end;
end;

procedure TConfigListener.Set_ConnectionStatus(const aValue: TConnectionStatus);
var backval : TConnectionStatus;
begin
   backval := ConnectionStatus;
   inherited Set_ConnectionStatus(aValue);
   if (backVal<>ConnectionStatus) and (aValue = connected) then SendHBeatRequestMsg;                           // I'm connected, let's discover the network
end;

procedure TConfigListener.OnDie(Sender: TObject);
var Config_Elmt : TConfigurationRecord;
    LogMsg      : TLogBasic;
begin
   Config_Elmt := TConfigurationRecord(Sender);
   LogMsg := TLogBasic.Create(self);
   LogMsg.Type_:= etWarning;
   LogMsg.Text := Config_Elmt.Address.RawxPL + ' disappeared';
   Send(LogMsg);
   LogMsg.Free;
   inherited OnDie(sender);
end;

end.
