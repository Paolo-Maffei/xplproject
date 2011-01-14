unit frm_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ExtCtrls, ActnList, PopupNotifier, StdCtrls, fpTimer,
  xplNotifier,
  uxPLConfig,
  uxPLMessage,
  uxPLListener;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    acQuit: TAction;
    acAbout: TAction;
    ActionList: TActionList;
    Edit1: TEdit;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupMenu1: TPopupMenu;
    procedure acAboutExecute(Sender: TObject);
    procedure acQuitExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    MessageQueue : TStringList;
    lockedby     : string;
    fTimer       : TfpTimer;
    fNotifier    : TxPLPopupNotifier;
    procedure Display(const aTitle, aText, aLevel : string; const bTimed : boolean = true; const aDelay : integer = -1);
  public
    procedure OnConfigDone(const fConfig : TxPLConfig);
    procedure OnReceive(const axPLMsg : TxPLMessage);
    procedure OnJoined(const aJoined : boolean);
    procedure OnTimer(Sender: TObject);
    procedure CheckQueue;
  end;

var
  FrmMain: TFrmMain;


implementation //===============================================================
uses app_main,
     frm_about,
     uxPLConst,
     StrUtils;

{==============================================================================}
const
   K_CONFIG_SHOWSEC = 'showsecs';

procedure TFrmMain.FormCreate(Sender: TObject);
begin
   MessageQueue := TStringList.Create;

   fTimer       := TfpTimer.Create(self);
   fTimer.OnTimer:=@OnTimer;

   fNotifier    := TxPLPopupNotifier.Create(self);

   xPLClient := TxPLListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER);
   with xPLClient do begin
       OnxPLConfigDone    := @OnConfigDone;
       OnxPLReceived      := @OnReceive;
       OnxPLJoinedNet     := @OnJoined;
       Config.DefineItem(K_CONFIG_SHOWSEC, K_XPL_CT_CONFIG, 1, '5');
       Config.SetItemValue(K_CONF_FILTER,'xpl-trig.*.*.*.log.basic');
       Config.SetItemValue(K_CONF_FILTER,'xpl-cmnd.*.*.*.osd.basic');
       Listen;
   end;
end;

procedure TFrmMain.acAboutExecute(Sender: TObject);
begin
   frmAbout.ShowModal;
end;

procedure TFrmMain.acQuitExecute(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
   fTimer.Free;
   xPLClient.Free;
   fNotifier.Free;
   MessageQueue.Free;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
   ActionList.Images := frmabout.ilStandardActions;
//   WindowState := wsMinimized;
end;

procedure TFrmMain.OnTimer(Sender : TObject);
begin
   fNotifier.Hide;
   fTimer.Enabled:=false;
   CheckQueue;
end;

procedure TFrmMain.CheckQueue;
var aMsg : TxPLMessage;
begin
   if (MessageQueue.Count > 0) and (lockedby='') then begin
      aMsg := TxPLMessage.create;
      aMsg.RawXPL:= MessageQueue[0];
      MessageQueue.Delete(0);
      OnReceive(aMsg);
      aMsg.Free;
   end;
end;

procedure TFrmMain.OnReceive(const axPLMsg: TxPLMessage);
var command, texte, type_, code : string;
    delay : integer;
    bHandled, bTimed : boolean;
begin
   bHandled := false;
   if not fTimer.Enabled then with axPLMsg do begin
      texte   := Body.GetValueByKey('text');
      if (Schema.Classe='osd') then begin     // restriction to xpl-cmnd + osd.basic is done by the filter
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
                     Display('OSD message',texte,K_LOG_BASIC_INF,bTimed,delay);
                     bHandled := True;
                  end;
         end;
         if bHandled then begin
            Schema.Type_:='confirm';
            if fTimer.Enabled then begin
               if delay=-1 then Body.AddKeyValue('delay=');
               Body.SetValueByKey('delay', IntToStr(fTimer.Interval div 1000));
            end;
            xPLClient.Send(axPLMsg);
         end;
      end else if (Schema.Classe = 'log') then begin // restriction to xpl-trig + log.basic is done by the filter
         if lockedby='' then begin
            type_   := Body.GetValueByKey('type',K_LOG_BASIC_INF);
            code    := '\n' + Body.GetValueByKey('code');
            Display('Log Message',texte + code, type_);
            bHandled := True;
         end;
      end;
   end;
   if not bHandled then MessageQueue.Add(axPLMsg.RawXPL)
                   else CheckQueue;
end;

procedure TFrmMain.OnJoined(const aJoined: boolean);
begin
   Display('Info','Joined the xPL network',K_LOG_BASIC_INF);
end;

procedure TFrmMain.OnConfigDone(const fConfig: TxPLConfig);
begin
   Display('xPL Message','Configuration Loaded\nListening',K_LOG_BASIC_INF);
end;

procedure TFrmMain.Display(const aTitle, aText, aLevel : string; const bTimed : boolean = true; const aDelay: integer = -1);
begin
   fNotifier.Title := aTitle;
   fNotifier.Text  := AnsiReplaceStr(aText,'\n',#13#10);;
   fNotifier.level := aLevel;
   if bTimed then begin
      if aDelay = -1 then fTimer.Interval := StrToInt(xPLClient.Config.ItemValue(K_CONFIG_SHOWSEC)) * 1000
                     else fTimer.Interval := aDelay * 1000;
      fTimer.StartTimer;
   end;
   fNotifier.Show;
end;


initialization
  {$I frm_main.lrs}

end.

