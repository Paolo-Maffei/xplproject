unit frm_balloon;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ExtCtrls, ActnList, fpTimer,
  xplNotifier, u_xpl_message, frm_template;

type

  { TFrmBalloon }

  TFrmBalloon = class(TFrmTemplate)
    acDisplayMessageWindow: TAction;
    ActionList3: TActionList;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupMenu11: TPopupMenu;
    TrayIcon1: TTrayIcon;
    procedure acDisplayWindow(Sender : TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    MessageQueue : TStringList;
    lockedby     : string;
    fTimer       : TfpTimer;
    fNotifier    : TxPLPopupNotifier;
    procedure Display(const aTitle, aText : string; const aLevel : TEventType; const bTimed : boolean = true; const aDelay : integer = -1);
  public
    procedure OnTimer(Sender: TObject);
    procedure OnReceive(const axPLMsg: TxPLMessage);
    procedure CheckQueue;
  end;

var
  FrmBalloon: TFrmBalloon;


implementation //===============================================================
uses frm_about
     , frm_messages
     , uxPLConst
     , u_xpl_application
     , u_xpl_custom_listener
     , u_xpl_config
     , u_xpl_gui_resource
     , u_xpl_common
     , u_xpl_messages
     , StrUtils
     ;

// ============================================================================
const
     K_CONFIG_SHOWSEC = 'showsecs';

// TFrmBalloon ================================================================
procedure TFrmBalloon.FormCreate(Sender: TObject);
begin
   inherited;
   MessageQueue := TStringList.Create;

   fTimer       := TfpTimer.Create(self);
   fTimer.OnTimer:=@OnTimer;

   fNotifier    := TxPLPopupNotifier.Create(self);

   with TxPLCustomListener(xPLApplication) do begin
     OnxPLReceived:=@OnReceive;
     Config.DefineItem(K_CONFIG_SHOWSEC, reconf, 1, '5');
     Config.FilterSet.AddValues(['xpl-trig.*.*.*.log.basic',
                                 'xpl-cmnd.*.*.*.osd.basic']);
     Listen;
   end;

   ActionList3.Images := xPLGUIResource.Images;
   TrayIcon1.Visible := True;

end;

procedure TFrmBalloon.acDisplayWindow(Sender: TObject);
begin
   frmMessages.Visible := acDisplayMessageWindow.Checked;
end;

procedure TFrmBalloon.FormDestroy(Sender: TObject);
begin
    fTimer.Free;
    fNotifier.Free;
    MessageQueue.Free;
    inherited;
end;


procedure TFrmBalloon.OnTimer(Sender : TObject);
begin
   fNotifier.Hide;
   fTimer.Enabled:=false;
   CheckQueue;
end;

procedure TFrmBalloon.CheckQueue;
var aMsg : TxPLMessage;
begin
   if (MessageQueue.Count > 0) and (lockedby='') then begin
      aMsg := TxPLMessage.create(self, MessageQueue[0]);
      MessageQueue.Delete(0);
      OnReceive(aMsg);
      aMsg.Free;
   end;
end;

procedure TFrmBalloon.Display(const aTitle, aText : string; const aLevel : TEventType; const bTimed : boolean = true; const aDelay: integer = -1);
begin
   fNotifier.Title := aTitle;
   fNotifier.Text  := AnsiReplaceStr(aText,'\n',#13#10);
   fNotifier.level := aLevel;
   if bTimed then begin
      if aDelay = -1 then fTimer.Interval := StrToInt(TxPLCustomListener(xPLApplication).Config.GetItemValue(K_CONFIG_SHOWSEC)) * 1000
                     else fTimer.Interval := aDelay * 1000;
      fTimer.StartTimer;
   end;
   fNotifier.Show;
end;

procedure TFrmBalloon.OnReceive(const axPLMsg: TxPLMessage);
var code, initialmessage : string;
    Broked : TxPLMessage;
    bHandled, bTimed : boolean;
begin
   acDisplayWindow(self);
   initialmessage := axPLMsg.RawxPL;
   bHandled := false;
   Broked   := MessageBroker(initialmessage);
   if not fTimer.Enabled then with Broked do  begin
      if Broked is TOsdBasic then begin
         Case AnsiIndexStr(TOsdBasic(Broked).Command,['exclusive','release','clear','write']) of
              0 : if lockedby = '' then begin // Exclusive ======================================
                     lockedby := Source.RawxPL;
                     OnTimer(self);
                     bHandled := true;
                  end;
              1 : if lockedby = Source.RawxPL then begin // Release =============================
                     lockedby := '';
                     OnTimer(self);
                     bHandled := True;
                  end;
              2 : if lockedby = Source.RawxPL then begin // Clear ===============================
                     OnTimer(self);
                     bHandled := True;
                  end;
              3 : if ((lockedby = Source.RawxPL) or (lockedby='')) then begin // Write ==========
                     bTimed := ((lockedby<>'') and (TOsdBasic(Broked).delay<>-1)) or (lockedby='');
                     Display('OSD message',TOsdBasic(Broked).text,etInfo,bTimed,TOsdBasic(Broked).delay);
                     bHandled := True;
                  end;
         end;
         if bHandled then begin
            Schema.Type_:='confirm';
            MessageType := trig;
            if fTimer.Enabled then TOsdBasic(Broked).Delay := fTimer.Interval div 1000;
            Target.Assign(Broked.Source);
            TxPLCustomListener(xPLApplication).Send(Broked);
         end;
      end else if Broked is TLogBasic then begin                               // restriction to xpl-trig + log.basic is done by the filter
         if lockedby='' then begin
            code    := '\n' + TLogBasic(Broked).Code; //.GetValueByKey('code');
            Display('Log Message',TLogBasic(Broked).text + code, TLogBasic(Broked).type_);
            bHandled := True;
         end;
      end;
   end;
   if bHandled then begin
      frmMessages.Display(initialmessage);
      CheckQueue;
   end else
      MessageQueue.Add(initialmessage);
   Broked.Free;
end;


initialization
  {$I frm_balloon.lrs}

end.

