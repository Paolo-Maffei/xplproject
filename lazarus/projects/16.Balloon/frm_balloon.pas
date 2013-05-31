unit frm_balloon;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, ComCtrls, Menus, ExtCtrls, ActnList, Grids, Buttons, PopupNotifier,
  XMLPropStorage, RTTICtrls, fpTimer, u_xpl_message, frm_template,
  fpc_delphi_compat;

type // TFrmBalloon ===========================================================
     TFrmBalloon = class(TFrmTemplate)
        acDisplayMessageWindow: TAction;
        dgMessages: TStringGrid;
        btnClear: TToolButton;
        PopupNotifier1: TPopupNotifier;
        procedure btnClearClick(Sender: TObject);
        procedure dgMessagesDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; {%H-}aState: TGridDrawState);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
     private
        MessageQueue : TStringList;
        lockedby     : string;
        fTimer       : TxPLTimer;
        procedure Display(const aTitle, aText : string; const aLevel : TEventType; const bTimed : boolean = true; const aDelay : integer = -1);
     public
        procedure OnTimer(Sender: TObject);
        procedure OnReceive(const axPLMsg: TxPLMessage);
        procedure CheckQueue;
        procedure Display(aMessage : string);
     end;

var
  FrmBalloon: TFrmBalloon;


implementation //===============================================================
uses uxPLConst
     , u_xpl_application
     , u_xpl_custom_listener
     , u_xpl_config
     , u_xpl_gui_resource
     , u_xpl_common
     , u_xpl_messages
     , StrUtils
     , typInfo
     ;

// ============================================================================
const
     K_CONFIG_SHOWSEC = 'showsecs';

// TFrmBalloon ================================================================
procedure TFrmBalloon.FormCreate(Sender: TObject);
var aMenu : TMenuItem;
begin
   inherited;
   MessageQueue := TStringList.Create;

   fTimer := xPLApplication.TimerPool.Add(0,@OnTimer);

   with TxPLCustomListener(xPLApplication) do begin
     OnxPLReceived:=@OnReceive;
     Config.DefineItem(K_CONFIG_SHOWSEC, reconf, 1, '5');
     Config.FilterSet.Add('xpl-trig.*.*.*.log.basic');
     Config.FilterSet.Add('xpl-cmnd.*.*.*.osd.basic');
     Listen;
   end;

//   TrayIcon1.Visible := True;

   aMenu := TMenuItem.Create(self);
   aMenu.Action := acDisplayMessageWindow;
   xPLMenu.Insert(0,aMenu);

   AppMenu.Visible:=false;
   btnClear.ImageIndex := 4;

   dgMessages.Columns[0].Width := 130;
   dgMessages.Columns[1].Width := 50;
   dgMessages.Columns[2].Width := 150;
   dgMessages.Columns[3].Width := 300;
   Display('Started',xPLApplication.FullTitle,etInfo)
end;

procedure TFrmBalloon.btnClearClick(Sender: TObject);
var i : integer;
    aMsg : TxPLMessage;
begin
   for i:=1 to dgMessages.Rowcount-1 do begin
       aMsg := dgMessages.Objects[0,i] as TxPLMessage;
       aMsg.Free;
   end;
   dgMessages.RowCount := 1;
end;

procedure TFrmBalloon.dgMessagesDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var aMsg : TxPLMessage;
    img : TImage;
begin
   if aCol = 0 then begin
      aMsg := TxPLMessage(dgMessages.Objects[0,aRow]);
      if assigned(aMsg) then
         try
            img := TImage.Create(self);
            if aMsg is TLogBasic then
               Case TLogBasic(aMsg).Type_ of
                    etInfo    : img.Picture.LoadFromLazarusResource('greenbadge');
                    etWarning : img.Picture.LoadFromLazarusResource('orangebadge');
                    etError   : img.Picture.LoadFromLazarusResource('redbadge');
               end
            else if aMsg is TOsdBasic then
                 img.Picture.LoadFromLazarusResource('menu_information');
            dgMessages.Canvas.Draw(aRect.Left+2,aRect.Top+2,img.Picture.Graphic);
         finally
            img.free;
         end;
   end;
end;

procedure TFrmBalloon.FormDestroy(Sender: TObject);
begin
    btnClearClick(self);
    MessageQueue.Free;
    inherited;
end;


procedure TFrmBalloon.OnTimer(Sender : TObject);
begin
   popupnotifier1.Hide;
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

procedure TFrmBalloon.Display(aMessage: string);
var aMsg : TxPLMessage;
begin
   aMsg := MessageBroker(aMessage);
   dgMessages.RowCount := dgMessages.RowCount+1;
   dgMessages.Objects[0,dgMessages.Rowcount-1] := aMsg;
   dgMessages.Cells[1,dgMessages.RowCount-1] := DateTimeToStr(now);
   dgMessages.Cells[2,dgMessages.RowCount-1] := aMsg.schema.Classe;
   dgMessages.Cells[3,dgMessages.RowCount-1] := aMsg.source.RawxPL;
   dgMessages.Cells[4,dgMessages.RowCount-1] := '';
   if aMsg is TLogBasic then
     dgMessages.Cells[4,dgMessages.RowCount-1] := TLogBasic(aMsg).text;
   if aMsg is TOSDBasic then
     dgMessages.Cells[4,dgMessages.RowCount-1] := TOSDBasic(aMsg).text;
end;

procedure TFrmBalloon.Display(const aTitle, aText : string; const aLevel : TEventType; const bTimed : boolean = true; const aDelay: integer = -1);
begin
   popupnotifier1.Text:= AnsiReplaceStr(aText,'\n',#13#10);;
   popupnotifier1.Title:=aTitle;
   popupnotifier1.Icon.LoadFromLazarusResource(GetEnumName(TypeInfo(TEventType),Ord(aLevel)));
   popupnotifier1.Show;
   if bTimed then begin
      if aDelay = -1 then fTimer.Interval := StrToInt(TxPLCustomListener(xPLApplication).Config.GetItemValue(K_CONFIG_SHOWSEC)) * 1000
                     else fTimer.Interval := aDelay * 1000;
      fTimer.StartTimer;
   end;
end;

procedure TFrmBalloon.OnReceive(const axPLMsg: TxPLMessage);
var code, initialmessage : string;
    Broked : TxPLMessage;
    bHandled, bTimed : boolean;
begin
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
      Display(initialmessage);
      CheckQueue;
   end else
      MessageQueue.Add(initialmessage);
   Broked.Free;
end;


initialization
  {$I frm_balloon.lrs}

end.
