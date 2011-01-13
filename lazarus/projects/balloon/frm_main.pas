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
    procedure Image1Click(Sender: TObject);
  private
    MessageQueue : TStringList;
    lockedby     : string;
    fTimer       : TfpTimer;
    fNotifier    : TxPLPopupNotifier;
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
   fNotifier    := TxPLPopupNotifier.Create(self);
   xPLClient := TxPLListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER);
   with xPLClient do begin
       OnxPLConfigDone    := @OnConfigDone;
       OnxPLReceived      := @OnReceive;
       OnxPLJoinedNet     := @OnJoined;
       Config.DefineItem(K_CONFIG_SHOWSEC, K_XPL_CT_CONFIG, 1, '3');
       Listen;
   end;
   MessageQueue := TStringList.Create;
   fTimer       := TfpTimer.Create(self);
   fTimer.OnTimer:=@OnTimer;

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

procedure TFrmMain.Image1Click(Sender: TObject);
begin

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

procedure TFrmMain.OnConfigDone(const fConfig: TxPLConfig);
begin
   fNotifier.Title       :='xPL Message';
   fNotifier.Text        :='Configuration Loaded'#13'Listening...';
   fNotifier.Visible     := true;
end;

procedure TFrmMain.OnReceive(const axPLMsg: TxPLMessage);
var command, texte, type_, code, delay : string;
    bHandled : boolean;
begin
   if not (axPLMsg.MessageType = K_MSG_TYPE_CMND) then exit;
   bHandled := false;
   if not fTimer.Enabled then with axPLMsg do begin
      texte   := Body.GetValueByKey('text');
      texte   := AnsiReplaceStr(texte,'\n',#13#10);
      delay   := Body.GetValueByKey('delay');
      if Schema.RawxPL='osd.basic' then begin
         command := Body.GetValueByKey('command','write');
         Case AnsiIndexStr(command,['exclusive','release','clear','write']) of
           0 : begin
             if lockedby = '' then begin
                lockedby := axPLMsg.Source.RawxPL;
                OnTimer(self);
                bHandled := true;
             end;
           end;
           1 : begin
             if lockedby = axPLMsg.Source.RawxPL then begin
                lockedby := '';
                OnTimer(self);
                bHandled := True;
             end;
           end;
           2 : begin
              if lockedby = axPLMsg.Source.RawxPL then begin
                 OnTimer(self);
                 bHandled := True;
              end;
           end;
           3 : begin
              if (lockedby = axPLMsg.Source.RawxPL) or (lockedby='') then begin
                if lockedby<>'' then begin
                   if (delay <> '') then begin
                      fTimer.Interval := StrToInt(delay) * 1000;
                      fTimer.StartTimer;
                   end
                end else begin
                   if delay = '' then delay := xPLClient.Config.ItemValue(K_CONFIG_SHOWSEC);
                   fTimer.Interval := StrToInt(delay) * 1000;
                   fTimer.StartTimer;
                end;
                fNotifier.Text := texte;
                fNotifier.Show;
                bHandled := True;
              end;
           end;

         end;
      end else if Schema.RawxPL = 'log.basic' then begin
         if lockedby='' then begin
            type_   := Body.GetValueByKey('type',K_LOG_BASIC_INF);
            code    := Body.GetValueByKey('code');
            fNotifier.Title:='xPL Message';
            fNotifier.Text := texte + IfThen(code<>'',#13 + code);
            if (delay = '') then fTimer.Interval := StrToInt(xPLClient.Config.ItemValue(K_CONFIG_SHOWSEC)) * 1000
                            else fTimer.Interval := StrToInt(delay) * 1000;
            fNotifier.level := type_;
            fNotifier.Show;
            fTimer.StartTimer;
            bHandled := True;
         end;
      end;
   end;
   if not bHandled then MessageQueue.Add(axPLMsg.RawXPL)
                   else CheckQueue;
end;

procedure TFrmMain.OnJoined(const aJoined: boolean);
begin
   fNotifier.Title:='Info';
   fNotifier.Text :='Joined the xPL network';
   fTimer.Interval:=StrToInt(xPLClient.Config.ItemValue(K_CONFIG_SHOWSEC)) * 1000;
   fNotifier.Show;
   fTimer.StartTimer;
end;

initialization
  {$I frm_main.lrs}

end.

