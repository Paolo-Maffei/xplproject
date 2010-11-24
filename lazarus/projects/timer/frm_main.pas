unit frm_main;

{$mode objfpc}{$H+}                             

interface
                                         
uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ActnList, ExtCtrls, uxPLWebListener, uxPLMessage,
  Grids, Buttons, uxPLConfig,  frm_xplrecurevent, IdCustomHTTPServer,
  uxPLTimer, uxPLEvent, MOON;

type

  { TfrmMain }
  TfrmMain = class(TForm)
    About: TAction;
    acNewSingleEvent: TAction;
    acNewRecurringEvent: TAction;
    acNewTimer: TAction;
    acLogView: TAction;
    ActionList1: TActionList;
    DownloadSelected: TAction;
    InstalledApps: TAction;
    lvEvents: TListView;
    lvTimers: TListView;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem18: TMenuItem;
    mnuFireNowTimer: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem8: TMenuItem;
    mnuEditEvent: TMenuItem;
    mnuFireNowEvent: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem6: TMenuItem;
    mnuDeleteEvent: TMenuItem;
    mnuAddRecurringEvent: TMenuItem;
    mnuAddSingleEvent: TMenuItem;
    MnuStopTimer: TMenuItem;
    MnuEditTimer: TMenuItem;
    MnuNewTimer: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem9: TMenuItem;
    popmnuTimer: TPopupMenu;
    popmnuEvents: TPopupMenu;
    Quit: TAction;
    SaveSettings: TAction;
    Splitter1: TSplitter;
    TimerImages: TImageList;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    UpdateSeed: TAction;
    procedure AboutExecute(Sender: TObject);
    procedure acLogViewExecute(Sender: TObject);
    procedure acNewEvent(anEvent : TxPLEvent);
    procedure acNewRecurringEventExecute(Sender: TObject);
    procedure acNewSingleEventExecute(Sender: TObject);
    procedure acNewTimerExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvEventsDblClick(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure mnuEditEventClick(Sender: TObject);
    procedure mnuFireNowEventClick(Sender: TObject);
    procedure mnuDeleteEventClick(Sender: TObject);
    procedure MnuEditTimerClick(Sender: TObject);
    procedure mnuFireNowTimerClick(Sender: TObject);
    procedure MnuStopTimerClick(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
  private
    aMessage  : TxPLMessage;
    eventlist : TxPLEventList;
    timerlist : TxPLTimerList;

    procedure OnConfigDone(const fConfig : TxPLConfig);
    procedure OnReceive(const axPLMsg : TxPLMessage);
    function  ReplaceArrayedTag(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean;

  public
     xPLClient : TxPLWebListener;
  end;

var frmMain: TfrmMain;

implementation {===============================================================}
uses Frm_About,
     uxPLConst,
     StrUtils,
     LCLType,
     uRegExpr,
     u_xml,
     uXMLRead,
     u_xml_config,
     DOM,
     app_main,
     frm_LogViewer,
     frm_xplappslauncher,
     frm_xPLActionList,
     u_xpl_event_gui;

{ General window functions ====================================================}
procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.acLogViewExecute(Sender: TObject);
begin frmlogviewer.showmodal; end;

procedure TfrmMain.QuitExecute(Sender: TObject);
begin Close; end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin CanClose := (Application.MessageBox('Do you want to quit ?','Confirm',MB_YESNO) = IDYES) end;

procedure TfrmMain.acNewEvent(anEvent : TxPLEvent);
begin
   if TxPLSingleEventGUI(anEvent).Edit then begin
      if EventList.Add(anEvent.Name,anEvent) = -1 then begin
         Application.MessageBox('Event already exists','Error',0);
         anEvent.Destroy;
      end;
   end else anEvent.Destroy;
end;

procedure TfrmMain.acNewTimerExecute(Sender: TObject);
var aTimer : TxPLTimer;
begin
   aTimer := TxPLTimer.Create(TimerList.xPLMessage);
   if aTimer.Edit then begin
      if TimerList.IndexOf(aTimer.TimerName)=-1 then
         TimerList.Add(aTimer)
      else begin
         Application.MessageBox('Timer already exists','Error',0);
         aTimer.Destroy;
      end;
   end else aTimer.Destroy;
end;

procedure TfrmMain.acNewRecurringEventExecute(Sender: TObject);
var Event : TxPLRecurEventGUI;
    aNode : TDOMElement;
begin
   aNode := EventList.CfgEntry.AddElement('new recurrent event');
   Event := TxPLRecurEventGUI.Create(aNode);
   if Event.Edit then EventList.Add(Event.Name,Event)
                 else begin
                      EventList.CfgEntry.RootNode.RemoveChild(aNode);
                      Event.Destroy;
                 end;
end;

procedure TfrmMain.acNewSingleEventExecute(Sender: TObject);
var Event : TxPLSingleEventGUI;
    aNode : TDOMElement;
begin
   aNode := EventList.CfgEntry.AddElement('new single event');
   Event := TxPLSingleEventGUI.Create(aNode);
   if Event.Edit then EventList.Add(Event.Name,Event)
                 else begin
                      EventList.CfgEntry.RootNode.RemoveChild(aNode);
                      Event.Destroy;
                 end;
end;

procedure TfrmMain.mnuDeleteEventClick(Sender: TObject);
begin
   if not assigned(lvEvents.Selected) then exit;
   EventList.Delete(TxPLEvent(lvEvents.Selected.Data));
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
   xPLClient := TxPLWebListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER, K_DEFAULT_PORT);
   with xPLClient do begin
       OnxPLConfigDone    := @OnConfigDone;
       OnxPLReceived      := @OnReceive;
       OnReplaceArrayedTag := @ReplaceArrayedTag;
   end;
   xPLClient.PassMyOwnMessages:=true;
   xPLClient.Listen;

   Self.Caption := xPLClient.AppName;
end;

procedure TfrmMain.OnConfigDone(const fConfig: TxPLConfig);
var ListRoot : TDOMElement;

begin
   if not assigned(aMessage) then begin
      aMessage := TxPLMessage.Create;
      aMessage.Schema.RawxPL := K_SCHEMA_TIMER_BASIC;
      aMessage.Target.IsGeneric := True;
   end;

   if not assigned(eventlist) then eventlist := TxPLEventList.Create(xPLClient, lvEvents);
   if not assigned(timerlist) then timerlist := TxPLTimerList.Create(xPLClient, lvTimers);

   ListRoot := xPLClient.Config.ConfigFile.LocalData.ElementByName['TimerList'];
   if ListRoot<>nil then timerList.ReadFromXML(TXMLLocalsType.Create(ListRoot,'timers',K_XML_STR_Name));
   ListRoot := xPLClient.Config.ConfigFile.LocalData.AddElement('EventList');
   if ListRoot<>nil then eventList.ReadFromXML(TXMLLocalsType.Create(ListRoot,'events',K_XML_STR_Name));

   acNewSingleEvent.Enabled := true;
   acNewRecurringEvent.Enabled := true;
   acNewTimer.Enabled := true;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var ListRoot : TDOMElement;
begin
   
   if Assigned(aMessage) then aMessage.Destroy;

   if Assigned(timerlist) then begin
      ListRoot := xPLClient.Config.ConfigFile.LocalData.AddElement('TimerList');
      timerlist.WriteToXML(TXMLLocalsType.Create(ListRoot,'timers',K_XML_STR_Name));
      timerlist.destroy;
   end;

//   if Assigned(eventlist) then //begin
//      ListRoot := xPLClient.Config.ConfigFile.LocalData.AddElement('EventList');
//      eventlist.WriteToXML; //(TXMLLocalsType.Create(ListRoot,'events',K_XML_STR_Name));
//      eventlist.destroy;
//   end;
   if Assigned(xPLClient) then xPLClient.destroy;
end;

procedure TfrmMain.OnReceive(const axPLMsg: TxPLMessage);

   procedure TimerBasic;
   var action, device : string;
   begin
      device := axPLMsg.Body.GetValueByKey('device');
      action := axPLMsg.Body.GetValueByKey('action');
      if (length(device) * length(action) = 0) then exit;                    // both parameters are mandatory
      case AnsiIndexStr(action, ['halt','resume','stop','start']) of         // halt=pause - resume = resume - stop = stop - start = start
        0 : TimerList.Pause(Device);
        1 : TimerList.ResumeOrStartATimer(Device);
        2 : TimerList.Stop(Device);
        3 : TimerList.Init( Device,
                            axPLMsg.Header.Source.RawxPL,
                            axPLMsg.Body.GetValueByKey('range','local'),
                            axPLMsg.Body.GetValueByKey('duration'),
                            axPLMsg.Body.GetValueByKey('frequence'));
      end;
   end;

   procedure TimerRequest;
   var device : string;
   begin
      device := axPLMsg.Body.GetValueByKey('device');
      if device<>'' then TimerList.SendStatus(Device);
   end;

begin
   case AnsiIndexStr(axPLMsg.Schema.RawxPL,[K_SCHEMA_TIMER_BASIC,K_SCHEMA_TIMER_REQUEST]) of
        0 : TimerBasic;
        1 : TimerRequest;
   end;
end;

function TfrmMain.ReplaceArrayedTag(const aDevice: string; const aValue: string; const aVariable: string; ReturnList: TStringList ): boolean;
var i : integer;
begin
   if aDevice<>K_DEFAULT_DEVICE then exit;
   ReturnList.Clear;

   if aVariable = 'evtname'    then for i:=0 to EventList.Count-1 do ReturnList.Add(EventList.Events[i].Name)
   else if aVariable = 'evttype'    then for i:=0 to EventList.Count-1 do ReturnList.Add(EventList.Events[i].TypeAsString)
   else if aVariable = 'evtnext'    then for i:=0 to EventList.Count-1 do ReturnList.Add(DateTimeToStr(EventList.Events[i].Next))
   else if aVariable = 'evtenabled' then for i:=0 to EventList.Count-1 do ReturnList.Add(EventList.Events[i].EnabledAsString)

   else if aVariable = 'tmrname'    then for i:=0 to TimerList.Count-1 do ReturnList.Add(TimerList.Timers[i].TimerName)
   else if aVariable = 'tmrtarget'  then for i:=0 to TimerList.Count-1 do ReturnList.Add(TimerList.Timers[i].Target)
   else if aVariable = 'tmrstart'   then for i:=0 to TimerList.Count-1 do ReturnList.Add(DateTimeToStr(TimerList.Timers[i].Start_Time))
   else if aVariable = 'tmrcount'   then for i:=0 to TimerList.Count-1 do ReturnList.Add(IntToStr(TimerList.Timers[i].Remaining))
   else if aVariable = 'tmrstatus'  then for i:=0 to TimerList.Count-1 do ReturnList.Add(TimerList.Timers[i].Status)
   else if aVariable = 'tmrstop'    then for i:=0 to TimerList.Count-1 do ReturnList.Add(DateTimeToStr(TimerList.Timers[i].Estimated_End_Time));

   result := (ReturnList.Count >0);
end;

// Event menu manipulations ====================================================
procedure TfrmMain.mnuEditEventClick(Sender: TObject);
begin
   lvEventsDblClick(sender);
end;

procedure TFrmMain.lvEventsDblClick(Sender: TObject);
begin
   EventList.Edit(lvEvents.Selected.Caption);
end;

procedure TfrmMain.MenuItem18Click(Sender: TObject);
begin
  frmAppLauncher.ShowModal;
end;

procedure TfrmMain.mnuFireNowEventClick(Sender: TObject);                            // FS#27 Ajout fonctionnalité Fire Now
begin
   if Assigned(lvEvents.Selected) then TxPLEvent(lvEvents.Selected.Data).Fire;
end;

// Timers manipulations functions ==============================================
procedure TfrmMain.MnuEditTimerClick(Sender: TObject);
begin
   if Assigned(lvTimers.Selected) then TxPLTimer(lvTimers.Selected.Data).Edit;
end;

procedure TfrmMain.mnuFireNowTimerClick(Sender: TObject);
begin
   if Assigned(lvTimers.Selected) then TxPLTimer(lvTimers.Selected.Data).SendStatus;
end;

procedure TfrmMain.MnuStopTimerClick(Sender: TObject);
begin
   if Assigned(lvTimers.Selected) then TimerList.Stop(lvTimers.Selected.Caption);
end;

initialization
  {$I frm_main.lrs}

end.

