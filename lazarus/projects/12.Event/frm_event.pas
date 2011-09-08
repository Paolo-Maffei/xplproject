unit frm_event;

{$mode objfpc}{$H+}                             

interface
                                         
uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ActnList, ExtCtrls, u_xpl_config, u_xpl_custom_message,
  Buttons, RTTICtrls, RTTIGrids, event_listener,  JvScheduledEvents,
  frm_template;

type

  { Tfrmevent }
  Tfrmevent = class(TFrmTemplate)
    acNewevent: TAction;
    acEditEvent: TAction;
    acDeleteEvent: TAction;
    acRename: TAction;
    lvEvents: TListView;
    MnuEditevent: TMenuItem;
    tbDel1: TToolButton;
    tbEdit1: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure acDeleteEventExecute(Sender: TObject);
    procedure acEditEventExecute(Sender: TObject);
    procedure acNeweventExecute(Sender: TObject);
    procedure acRenameExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure JvAppEvents1Idle(Sender: TObject; var Done: Boolean);
  private
    Listener : TxPLeventListener;
    procedure AddEventInList(const aEvent : TJVEventCollectionItem);
  end;

var frmevent: Tfrmevent;

implementation {===============================================================}
uses Frm_About,
     uxPLConst,
     LCLType,
     typInfo,
     u_xpl_header,
     JvScheduleEditorForm,
     uRegExpr,
     frm_LogViewer,
     u_xpl_application,
     u_xpl_gui_resource,
     frm_xplappslauncher;

{ General window functions ====================================================}
procedure Tfrmevent.FormCreate(Sender: TObject);
begin
   inherited;
   Listener := TxPLeventListener(xPLApplication);
   Listener.OnxPLJoinedNet := @OnJoinedEvent;
   if not Assigned(FrmScheduleEditor) then Application.CreateForm(TFrmScheduleEditor,FrmScheduleEditor);
end;

procedure TFrmEvent.AddEventInList(const aEvent : TJVEventCollectionItem);
begin
   with lvEvents.Items.Add do begin
      Caption := aEvent.Name;
      Data    := aEvent;
      SubItems.DelimitedText:=',,,';
   end;
end;

procedure Tfrmevent.acNeweventExecute(Sender: TObject);
var Event : TJvEventCollectionItem;
begin
   Event := Listener.AddNewEvent;
   FrmScheduleEditor.Schedule := Event.Schedule;
   FrmScheduleEditor.ShowModal;
   Event.Start;
end;

procedure Tfrmevent.acRenameExecute(Sender: TObject);
var Event : TJvEventCollectionItem;
    s : string;
begin
   Event := TJvEventCollectionItem(lvEvents.Selected.Data);
   s := InputBox('Change Event Name','New event name',Event.Name);
   if s<>Event.Name then Event.Name := s;
end;

procedure Tfrmevent.acEditEventExecute(Sender: TObject);
var Event : TJvEventCollectionItem;
begin
   Event := TJvEventCollectionItem(lvEvents.Selected.Data);
   FrmScheduleEditor.Schedule := Event.Schedule;
   FrmScheduleEditor.ShowModal;
   Event.Start;
end;

procedure Tfrmevent.acDeleteEventExecute(Sender: TObject);
var sName  : string;
    i     : integer;
begin
   sName := lvEvents.Selected.Caption;
   i := listener.EventList.Count-1;
   while i>=0 do begin
      if listener.EventList[i].Name = sName then begin
         listener.EventList.Delete(i);
         lvEvents.Items[i].Delete;
      end;
      dec(i);
   end;
end;

procedure Tfrmevent.FormShow(Sender: TObject);
begin
   Listener.Listen;
end;

procedure Tfrmevent.JvAppEvents1Idle(Sender: TObject; var Done: Boolean);
var Event : TJVEventCollectionItem;
    ci    : TCollectionItem;
    item    : tListItem;
begin
   acEditEvent.Enabled := lvEvents.SelCount <> 0;
   acDeleteEvent.Enabled := acEditEvent.Enabled;
   acRename.Enabled:=acEditEvent.Enabled;

   for Item in lvEvents.Items do begin                                                                 // Synchronize displayed event with list
       Event := TJVEventCollectionItem(item.Data);
       Item.SubItems[0] := GetEnumName(TypeInfo(TScheduledEventState),Ord(Event.State));
       Item.Caption     := Event.Name;                                                                 // Name may have changed
   end;
   for ci in Listener.EventList do begin                                                               // Synchronize displayed list with memory list
       Event := TJVEventCollectionItem(ci);                                                            // liste mais pas affichés
       if lvEvents.Items.FindCaption(0,Event.Name,false,true,false) = nil then AddEventInList(Event);  // alors on les créée
   end;
end;

initialization
  {$I frm_event.lrs}

end.


