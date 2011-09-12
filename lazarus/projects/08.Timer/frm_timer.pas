unit frm_timer;

{$mode objfpc}{$H+}                             

interface
                                         
uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ActnList, ExtCtrls, u_xpl_config, u_xpl_custom_message,
  Buttons, XMLPropStorage, RxAboutDialog,  RTTICtrls, RTTIGrids, timer_listener,
  frm_template;

type

  { TfrmTimer }
  TfrmTimer = class(TFrmTemplate)
    acNewTimer: TAction;
    IdleTimer1: TIdleTimer;
    lvTimers: TListView;
    MenuItem1: TMenuItem;
    MenuItem11: TMenuItem;
    mnuFireNowTimer: TMenuItem;
    MnuStopTimer: TMenuItem;
    MnuEditTimer: TMenuItem;
    MnuNewTimer: TMenuItem;
    popmnuTimer: TPopupMenu;
    ToolButton1: TToolButton;
    procedure acNewTimerExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure JvAppEvents1Idle(Sender: TObject);
    procedure MnuEditTimerClick(Sender: TObject);
    procedure mnuFireNowTimerClick(Sender: TObject);
    procedure MnuStopTimerClick(Sender: TObject);
  private
    Listener : TxPLTimerListener;
    procedure OnJoinedEvent; override;
  end;

var frmTimer: TfrmTimer;

implementation {===============================================================}
uses uxPLConst,
     StrUtils,
     LCLType,
     uRegExpr,
     u_xpl_custom_listener,
     u_xpl_timer,
     frm_LogViewer,
     u_xpl_header,
     u_xpl_application,
     u_xpl_gui_resource,
     frm_xplTimer,
     frm_xplappslauncher;

{ General window functions ====================================================}
procedure TfrmTimer.OnJoinedEvent;
begin
   inherited;
   with Listener do
         acNewTimer.Enabled := (ConnectionStatus = connected);
end;

procedure TfrmTimer.FormCreate(Sender: TObject);
begin
   inherited;
   Listener := TxPLTimerListener(xPLApplication);
   lvTimers.SmallImages := Toolbar.Images;
   lvTimers.StateImages := Toolbar.Images;

   Listener.OnxPLJoinedNet := @OnJoinedEvent;
end;

procedure TfrmTimer.FormShow(Sender: TObject);
begin
   Listener.Listen;
end;

procedure TfrmTimer.JvAppEvents1Idle(Sender: TObject);
var item : tListItem;
    Timer : TxPLTimer;
    i : integer;
    sEstimated_End_Time : string;
begin
   with Listener do
      for i:=lvTimers.items.Count to Timers.Count-1 do begin
         with lvTimers.Items.Add do begin
            Caption := Timers[i].DisplayName;
            SubItems.CommaText:=',,,,,';
            Data := Timers[i];
         end;
   end;
   for item in lvTimers.items do begin
       if Listener.Timers.GetItemId(item.Caption)<>-1 then begin
          Timer := Listener.Timers.FindItemName(item.Caption);
          sEstimated_End_Time := IfThen(Timer.End_Time<>Timer.Start_Time,DateTimeToStr(Timer.End_Time));
          item.Caption     := Timer.DisplayName;
          item.SubItems[0] := Timer.Target;
          item.SubItems[1] := DateTimeToStr(Timer.Start_Time);
          item.SubItems[2] := IntToStr(Timer.Remaining);
          item.SubItems[3] := sEstimated_End_Time;
          item.SubItems[4] := Timer.StatusAsStr;
          item.ImageIndex := 26 + Ord(Timer.Mode);
          item.StateIndex := 11 + Ord(Timer.Status);
       end else item.Free;
   end;
end;

procedure TfrmTimer.acNewTimerExecute(Sender: TObject);
var aTimer : TxPLTimer;
begin
   aTimer := Listener.Timers.Add('');
   aTimer.Status    := halted;
   ShowFrmxPLTimer(aTimer);
end;

// Timers manipulations functions ==============================================
procedure TfrmTimer.MnuEditTimerClick(Sender: TObject);
begin
   if Assigned(lvTimers.Selected) then ShowFrmxPLTimer(TxPLTimer(lvTimers.Selected.Data));
end;

procedure TfrmTimer.mnuFireNowTimerClick(Sender: TObject);
begin
   if Assigned(lvTimers.Selected) then TxPLTimer(lvTimers.Selected.Data).SendStatus;
end;

procedure TfrmTimer.MnuStopTimerClick(Sender: TObject);
begin
   if Assigned(lvTimers.Selected) then TxPLTimer(lvTimers.Selected.Data).Status := stopped;
end;

initialization
  {$I frm_timer.lrs}

end.

(*function TfrmTimer.ReplaceArrayedTag(const aDevice: string; const aValue: string; const aVariable: string; ReturnList: TStringList ): boolean;
var i : integer;
begin
   if aDevice<>K_DEFAULT_DEVICE then exit;
   ReturnList.Clear;

   else if aVariable = 'tmrname'    then for i:=0 to TimerList.Count-1 do ReturnList.Add(TimerList.Timers[i].TimerName)
   else if aVariable = 'tmrtarget'  then for i:=0 to TimerList.Count-1 do ReturnList.Add(TimerList.Timers[i].Target)
   else if aVariable = 'tmrstart'   then for i:=0 to TimerList.Count-1 do ReturnList.Add(DateTimeToStr(TimerList.Timers[i].Start_Time))
   else if aVariable = 'tmrcount'   then for i:=0 to TimerList.Count-1 do ReturnList.Add(IntToStr(TimerList.Timers[i].Remaining))
   else if aVariable = 'tmrstatus'  then for i:=0 to TimerList.Count-1 do ReturnList.Add(TimerList.Timers[i].Status)
   else if aVariable = 'tmrstop'    then for i:=0 to TimerList.Count-1 do ReturnList.Add(DateTimeToStr(TimerList.Timers[i].Estimated_End_Time));

   result := (ReturnList.Count >0);
end;*)

