unit timer_listener;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  u_xpl_custom_listener,
  u_xpl_timer,
  u_xpl_message;

type // TxPLTimerListener =====================================================
     TxPLTimerListener = class(TxPLCustomListener)
     private
        fTimers : TxPLTimers;
     protected
        procedure OnReceive   (const axPLMsg : TxPLMessage);

     public
        constructor Create(const aOwner : TComponent); reintroduce;
        procedure OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;

     published
        property Timers : TxPLTimers read fTimers write fTimers;
     end;

implementation // =============================================================
uses u_xpl_common
     ,LResources
     ,StrUtils
     ;

{ TxPLTimerListener ==========================================================}
constructor TxPLTimerListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   Config.FilterSet.AddValues(['xpl-cmnd.*.*.*.timer.basic',
                               'xpl-cmnd.*.*.*.timer.request']);
   fTimers := TxPLTimers.Create(self);
   include(fComponentStyle,csSubComponent);
   OnxPLReceived     := @OnReceive;
end;

procedure TxPLTimerListener.OnReceive(const axPLMsg: TxPLMessage);
var adevice : string;
    aAction : string;
    timer  : TxPLTimer;
begin
   adevice := axPLMsg.Body.GetValueByKey('device');
   if axPLMsg.Schema.Equals(Schema_TimerBasic) then begin
      aAction := axPLMsg.Body.GetValueByKey('action');
      if (length(aDevice) * length(aAction) <> 0) then begin                     // both parameters are mandatory
         case AnsiIndexStr(aAction, ['halt','resume','stop','start']) of         // halt=pause - resume = resume - stop = stop - start = start
              0 : Timers.FindItemName(aDevice).Status := halted;
              1 : Timers.FindItemName(aDevice).Status := started;
              2 : begin
                     Timers.FindItemName(aDevice).Status := stopped;
                     Timers.Delete(Timers.GetItemId(aDevice));
                  end;
              3 : begin
                     if Timers.FindItemName(aDevice)<>nil then begin
                        Timers.FindItemName(aDevice).Status := stopped;
                        Timers.FindItemName(aDevice).Free;
                     end;
                     Timer := Timers.Add(aDevice);
                     Timer.InitComponent(axPLMsg);
                  end;
         end;
      end;
   end else
       if axPLMsg.Schema.Equals(Schema_TimerRequest) then Timers.FindItemName(aDevice).SendStatus;
end;

procedure TxPLTimerListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
   if CompareText(AClassName, 'TxPLTimerListener') = 0 then ComponentClass := TxplTimerListener
   else inherited;
end;

end.
