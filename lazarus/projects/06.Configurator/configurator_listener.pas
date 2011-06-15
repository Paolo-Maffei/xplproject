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

type

{ TConfigListener }

TConfigListener = class(TxPLListener)
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        procedure   OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;

        function    DoHBeatApp (const aMessage : TxPLMessage) : boolean; override;
        procedure   OnReceive(const axPLMsg : TxPLMessage);
        procedure   Set_ConnectionStatus(const aValue : TConnectionStatus); override;
     published
        property    Discovered : TConfigurationRecordList read fDiscovered;
     end;

implementation // =============================================================

uses u_xpl_common
     , u_xpl_schema
     ;

{ TConfigListener }

constructor TConfigListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   Config.FilterSet.AddValues([ 'xpl-stat.*.*.*.hbeat.app',       'xpl-stat.*.*.*.hbeat.end',
                                'xpl-stat.*.*.*.config.app',      'xpl-stat.*.*.*.config.current',
                                'xpl-stat.*.*.*.config.response', 'xpl-stat.*.*.*.config.list',
                                'xpl-stat.*.*.*.config.end']);

   OnxPLReceived      := @OnReceive;
end;

function TConfigListener.DoHBeatApp(const aMessage: TxPLMessage): boolean;
var i : integer;
begin
   i := fDiscovered.Count;
   Result:=inherited DoHBeatApp(aMessage);

   if fDiscovered.Count<>i then                                                // a new module was identified
      SendMessage(cmnd,aMessage.Source.RawxPL,Schema_ConfigList,['command'],['request']); // request its configuration
end;

procedure TConfigListener.OnReceive(const axPLMsg: TxPLMessage);
var item : integer;
    Config_Elmt: TConfigurationRecord;
begin
   if ((axPLMsg.Body.Keys.Count = 0) or
       (axPLMsg.Schema.Classe <> K_SCHEMA_CLASS_CONFIG) or
       (axPLMsg.MessageType <> stat)) then exit;                               // Don't handle config request messages

   item := fDiscovered.IndexOf(axPLMsg.Source.Device);                         // I received a config.app message,
//   if item = -1 then begin
//         axPLMsg.Schema.Assign(Schema_HBeatApp);                               // handle it as an HBeatMessage
//         DoHBeatApp(axPLMsg);
//         exit;
//   end;

   Config_Elmt := fDiscovered.Data[item];
   if axPLMsg.Schema.Equals(Schema_ConfigList) then begin
      Config_Elmt.Config.ConfigList    := axPLMsg.Body;
      SendMessage(cmnd,axPLMsg.Source.RawxPL,Schema_ConfigCurr,['command'],['request']);
   end else if axPLMsg.Schema.Equals(Schema_ConfigCurr) then
       Config_Elmt.Config.CurrentConfig := axPLMsg.Body;
end;

procedure TConfigListener.Set_ConnectionStatus(const aValue: TConnectionStatus);
var backval : TConnectionStatus;
begin
   backval := ConnectionStatus;
   inherited Set_ConnectionStatus(aValue);
   if (backVal<>ConnectionStatus) and (aValue = connected) then SendHBeatRequestMsg;                           // I'm connected, let's discover the network
end;

procedure TConfigListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
   if CompareText(AClassName, 'TConfigListener') = 0 then ComponentClass := TConfigListener
   else inherited;
end;

end.

