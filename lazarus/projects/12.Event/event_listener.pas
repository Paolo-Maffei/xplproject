unit event_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses Classes
     , SysUtils
     , u_xpl_custom_listener
     , u_xpl_config
     , u_xpl_actionlist
//     , JvScheduledEvents
     , u_xpl_message
     , u_xpl_schema
     ;

type


{ TxPLeventListener }

     TxPLeventListener = class(TxPLCustomListener)
     private
        fEvents : TJvEventCollection;
        fSchedule : TJvScheduledEvents;
        procedure Set_Events(const AValue: TJvEventCollection);
     protected
        procedure OnReceive   (const axPLMsg : TxPLMessage);
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        destructor  Destroy; override;
        procedure   OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;
        function    AddNewEvent : TJvEventCollectionItem;
        procedure   Execute(Sender: TJvEventCollectionItem; const IsSnoozeEvent: Boolean);
        procedure Set_ConnectionStatus(const aValue : TConnectionStatus); override;
     published
        property EventList : TJvEventCollection read fEvents write Set_Events;
     end;

var
  Schema_EventBasic : TxPLSchema;

implementation
uses u_xpl_common
     , u_xpl_header
     , u_xpl_custom_message
     , LResources
     , u_xpl_application
     , JclSchedule
     , STrUtils
     ;

{ TxPLeventListener }

constructor TxPLeventListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   Config.FilterSet.AddValues(['xpl-cmnd.*.*.*.timer.basic',
                               'xpl-cmnd.*.*.*.timer.request']);
   fSchedule := TJvScheduledEvents.Create(self);
   fSchedule.StartAll;
   fEvents    := fSchedule.Events;
   OnxPLReceived     := @OnReceive;
end;

procedure TxPLeventListener.OnReceive(const axPLMsg: TxPLMessage);
var adevice, aAction, aType, aDate : string;
    dt : TDateTime;
    Event : TJvEventCollectionItem;
begin
   adevice := axPLMsg.Body.GetValueByKey('device');
   if axPLMsg.Schema.Equals(Schema_EventBasic) then begin
      aAction := axPLMsg.Body.GetValueByKey('action');
      aType := axPLMsg.Body.GetValueByKey('type');
      aDate := axPLMsg.Body.GetValueByKey('date');

      if (length(aDevice) * length(aAction) * length(aType)* length(aDate)<> 0) then begin                     // both parameters are mandatory
         case AnsiIndexStr(aAction, ['halt','resume','stop','start']) of         // halt=pause - resume = resume - stop = stop - start = start
              0 : ;//Timers.FindItemName(aDevice).Status := halted;
              1 : ;//Timers.FindItemName(aDevice).Status := started;
              2 : ;//begin
                  //   Timers.FindItemName(aDevice).Status := stopped;
                  //   Timers.Delete(Timers.GetItemId(aDevice));
                  //end;
              3 : begin
                      if aType = 'oneshot' then begin
                         dt := XplDT2DateTime(aDate);
                         Event := AddNewEvent;
                         Event.Name := aDevice;
                         Event.Schedule.RecurringType := srkOneShot;
                         Event.Schedule.StartDate := DateTimeToTimeStamp(dt);
                         Event.Start;
                      end;
                  end;
         end;
      end;
   end;
end;




destructor TxPLeventListener.Destroy;
begin
   SaveConfig;
   inherited;
end;

procedure TxPLeventListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
   if CompareText(AClassName, 'TxPLeventListener') = 0 then ComponentClass := TxpleventListener
   else inherited;
end;

function TxPLeventListener.AddNewEvent: TJvEventCollectionItem;
begin
   result := EventList.Add;
   with Result do begin
        Name := 'Event #' + IntToStr(EventList.Count);
        OnExecute:=@Execute;
   end;
end;

procedure TxPLeventListener.Execute(Sender: TJvEventCollectionItem; const IsSnoozeEvent: Boolean);
var aMsg : TxPLCustomMessage;
begin
   aMsg := PrepareMessage(cmnd,'event.basic');
   aMsg.Body.AddKeyValuePairs(['device','status'],[sender.name,'fired']);
   Send(aMsg);
   aMsg.Free;
end;

procedure TxPLeventListener.Set_ConnectionStatus(const aValue: TConnectionStatus);
var Event : TCollectionItem;
begin
  inherited Set_ConnectionStatus(aValue);
  if aValue = connected then begin
    for Event in EventList do                                  // relink events to message emitting on execution
        TJvEventCollectionItem(Event).OnExecute:=@Execute;
    fSchedule.StartAll;
  end;
end;


procedure TxPLeventListener.Set_Events(const AValue: TJvEventCollection);
begin
   fEvents.Assign(AValue);
end;

initialization
  Schema_EventBasic   := 'event.basic';


end.

