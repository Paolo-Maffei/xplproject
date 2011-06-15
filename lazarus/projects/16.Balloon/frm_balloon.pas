unit frm_balloon;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ExtCtrls, ActnList, fpTimer,
  xplNotifier, u_xpl_message;

type

  { TFrmBalloon }

  TFrmBalloon = class(TForm)
    acQuit: TAction;
    acAbout: TAction;
    ActionList: TActionList;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    PopupMenu1: TPopupMenu;
    TrayIcon1: TTrayIcon;
    procedure acAboutExecute(Sender: TObject);
    procedure acQuitExecute(Sender: TObject);
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
uses frm_about,
     uxPLConst,
     u_xpl_application,
     u_xpl_custom_listener,
     u_xpl_config,
     u_xpl_gui_resource,
     u_xpl_common,
     StrUtils;
const      K_CONFIG_SHOWSEC = 'showsecs';
{==============================================================================}

procedure TFrmBalloon.FormCreate(Sender: TObject);
begin
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

   ActionList.Images := xPLGUIResource.Images;
   TrayIcon1.Visible := True;
end;

procedure TFrmBalloon.acAboutExecute(Sender: TObject);
begin
   ShowFrmAbout;
end;

procedure TFrmBalloon.acQuitExecute(Sender: TObject);
begin
   Close;
end;

procedure TFrmBalloon.FormDestroy(Sender: TObject);
begin
    fTimer.Free;
    fNotifier.Free;
    MessageQueue.Free;
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
var command, texte, code : string;
    type_ : TEventType;
    delay : integer;
    bHandled, bTimed : boolean;
begin
   bHandled := false;
   if not fTimer.Enabled then with axPLMsg do begin
      texte   := Body.GetValueByKey('text');
      if (Schema.Classe='osd') then begin                                       // restriction to xpl-cmnd + osd.basic is done by the filter
         command := Body.GetValueByKey('command','write');
         delay   := StrToIntDef(Body.GetValueByKey('delay'),-1);
         Case AnsiIndexStr(command,['exclusive','release','clear','write']) of
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
                     bTimed := ((lockedby<>'') and (delay<>-1)) or (lockedby='');
                     Display('OSD message',texte,etInfo,bTimed,delay);
                     bHandled := True;
                  end;
         end;
         if bHandled then begin
            Schema.Type_:='confirm';
            if fTimer.Enabled then begin
               if delay=-1 then Body.AddKeyValue('delay=');
               Body.SetValueByKey('delay', IntToStr(fTimer.Interval div 1000));
            end;
            Target.Assign(Source);
            TxPLCustomListener(xPLApplication).Send(axPLMsg);
         end;
      end else if (Schema.Classe = 'log') then begin                            // restriction to xpl-trig + log.basic is done by the filter
         if lockedby='' then begin
            type_   := xPLLevelToEventType(Body.GetValueByKey('type'));
            code    := '\n' + Body.GetValueByKey('code');
            Display('Log Message',texte + code, type_);
            bHandled := True;
         end;
      end;
   end;
   if not bHandled then MessageQueue.Add(axPLMsg.RawXPL)
                   else CheckQueue;
end;


initialization
  {$I frm_balloon.lrs}

end.

