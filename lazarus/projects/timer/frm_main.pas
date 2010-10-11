unit frm_main;

{$mode objfpc}{$H+}                             

interface
                                         
uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ActnList, ExtCtrls, uxPLWebListener, uxPLMessage, SunTime,
  Grids, Buttons, uxPLConfig,  frm_xPLTimer, frm_xplrecurevent, IdCustomHTTPServer,
  uxPLTimer, uxPLEvent;

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
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem8: TMenuItem;
    mnuEditEvent: TMenuItem;
    mnuFireNow: TMenuItem;
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
    procedure mnuEditEventClick(Sender: TObject);
    procedure mnuFireNowClick(Sender: TObject);
    procedure mnuDeleteEventClick(Sender: TObject);
    procedure MnuEditTimerClick(Sender: TObject);
    procedure MnuStopTimerClick(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
  private
    aMessage  : TxPLMessage;
    eventlist : TxPLEventList;
    timerlist : TxPLTimerList;
    SunTime   : TSuntime;
    Dawn      : TxPLSunEvent;
    Dusk      : TxPLSunEvent;
    Noon      : TxPLSunEvent;
    procedure OnConfigDone(const fConfig : TxPLConfig);
    procedure OnSensorRequest(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
    procedure OnControlBasic (const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
    procedure OnReceive(const axPLMsg : TxPLMessage);
    function  ReplaceArrayedTag(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean;

  public
//     procedure LogUpdate(const aList : TStringList);
     xPLClient : TxPLWebListener;
  end;

var frmMain: TfrmMain;

implementation {===============================================================}
uses Frm_About,
     uxPLConst,
     StrUtils,
     LCLType,
     uRegExpr,
     DateUtils,
     frm_LogViewer;

{==============================================================================}
resourcestring
     K_XPL_APP_VERSION_NUMBER = '1.5.2';
     K_DEFAULT_VENDOR         = 'clinique';
     K_DEFAULT_DEVICE         = 'timer';
     K_DEFAULT_PORT           = '8339';

     K_CONFIG_LATITUDE        = 'latitude';
     K_CONFIG_LONGITUDE       = 'longitude';

{ General window functions ====================================================}
procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.acLogViewExecute(Sender: TObject);
begin
  frmlogviewer.showmodal;
end;

procedure TfrmMain.QuitExecute(Sender: TObject);
begin Close; end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin CanClose := (Application.MessageBox('Do you want to quit ?','Confirm',MB_YESNO) = IDYES) end;

procedure TfrmMain.acNewEvent(anEvent : TxPLEvent);
begin
   if anEvent.Edit then begin
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
begin acNewEvent(TxPLRecurEvent.Create(aMessage));  end;

procedure TfrmMain.acNewSingleEventExecute(Sender: TObject);
begin acNewEvent(TxPLSingleEvent.Create(aMessage)); end;

procedure TfrmMain.FormCreate(Sender: TObject);
procedure initListener;
begin
   xPLClient := TxPLWebListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER, K_DEFAULT_PORT);
   with xPLClient do begin
       OnxPLControlBasic  := @OnControlBasic;
       OnxPLSensorRequest := @OnSensorRequest;
       OnxPLConfigDone    := @OnConfigDone;
       OnxPLReceived      := @OnReceive;
       OnReplaceArrayedTag := @ReplaceArrayedTag;
       Config.AddItem(K_CONFIG_LATITUDE, K_XPL_CT_CONFIG);
       Config.AddItem(K_CONFIG_LONGITUDE,K_XPL_CT_CONFIG);
   end;
   xPLClient.PassMyOwnMessages:=true;
   xPLClient.Listen;
end;

begin
   Suntime := TSuntime.Create(self);
   InitListener;

   Self.Caption := xPLClient.AppName;
end;

procedure TfrmMain.OnConfigDone(const fConfig: TxPLConfig);
begin
   if not assigned(aMessage)  then aMessage := xPLClient.PrepareMessage(K_MSG_TYPE_CMND,'control.basic');
   if not assigned(eventlist) then eventlist := TxPLEventList.Create(xPLClient, lvEvents);
   if not assigned(timerlist) then timerlist := TxPLTimerList.Create(xPLClient, lvTimers);

   timerList.ReadFromXML(xPLClient.Config.XmlFile,'TimerList');
   eventList.ReadFromXML(xPLClient.Config.XmlFile,'EventList');

   acNewSingleEvent.Enabled := true;
   acNewRecurringEvent.Enabled := true;
   acNewTimer.Enabled := true;

   with TRegExpr.Create do begin
        Expression := K_RE_LATITUDE;
        if Exec(xPLClient.Config.ItemName[K_CONFIG_LATITUDE].Value) then begin
           Suntime.Latitude.Degrees := StrToInt(Match[1]);
           Suntime.Latitude.Minutes := StrToInt(Match[2]);
           Suntime.Latitude.Seconds := StrToInt(Match[3]);
           Suntime.Latitude.Dir     := Match[4];
        end;
        Expression := K_RE_LONGITUDE;
        if Exec(xPLClient.Config.ItemName[K_CONFIG_LONGITUDE].Value) then begin
           Suntime.Longitude.Degrees := StrToInt(Match[1]);
           Suntime.Longitude.Minutes := StrToInt(Match[2]);
           Suntime.Longitude.Seconds := StrToInt(Match[3]);
           Suntime.Longitude.Dir     := Match[4];
        end;
        destroy;
   end;

   if not Assigned(Dawn) then Dawn := TxPLSunEvent.Create(xPLClient.Address,Suntime,setDawn);
   if not Assigned(Dusk) then Dusk := TxPLSunEvent.Create(xPLClient.Address,Suntime,setDusk);
   if not Assigned(Noon) then Noon := TxPLSunEvent.Create(xPLClient.Address,Suntime,setNoon);

   EventList.Add(Dawn.Name, Dawn);
   EventList.Add(Dusk.Name, Dusk);
   EventList.Add(Noon.Name, Noon);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   if Assigned(Dawn) then EventList.Delete(Dawn);
   if Assigned(Dusk) then EventList.Delete(Dusk);
   if Assigned(Noon) then EventList.Delete(Noon);

   Suntime.Destroy;

   if Assigned(aMessage) then aMessage.Destroy;

   if Assigned(timerlist) then begin
      timerlist.WriteToXML(xPLClient.Config.XmlFile,'TimerList');
      timerlist.destroy;
   end;

   if Assigned(eventlist) then begin
      eventlist.WriteToXML(xPLClient.Config.XmlFile,'EventList');
      eventlist.destroy;
   end;
   if Assigned(xPLClient) then xPLClient.destroy;
end;

procedure TfrmMain.OnSensorRequest(const axPLMsg: TxPLMessage; const aDevice: string; const aAction : string);
begin
    if aAction = 'current' then TimerList.SendStatus(aDevice);
end;

procedure TfrmMain.OnControlBasic(const axPLMsg: TxPLMessage; const aDevice: string; const aAction : string);
begin
   case AnsiIndexStr(aAction, ['halt','resume','stop','start']) of         // halt=pause - resume = resume - stop = stop - start = start
        0 : TimerList.Pause(aDevice);
        1 : TimerList.ResumeOrStartATimer(aDevice);
        2 : TimerList.Stop(aDevice);
        3 : TimerList.Init( aDevice,
                            axPLMsg.Header.Source.Tag,
                            axPLMsg.Body.GetValueByKey('range','local'),
                            axPLMsg.Body.GetValueByKey('duration'),
                            axPLMsg.Body.GetValueByKey('frequence'));
   end;
end;

procedure TfrmMain.OnReceive(const axPLMsg: TxPLMessage);
var aMsg : TxPLMessage;
    level, delta, lag : longint;
    status : string;
    fixdawn, fixnoon : TDateTime;
begin
   if axPLMsg.Schema.Tag = K_SCHEMA_DAWNDUSK_REQUEST then begin
      aMsg := xPLClient.PrepareMessage(K_MSG_TYPE_STAT,K_SCHEMA_DAWNDUSK_BASIC);
      aMsg.Body.AddKeyValue('type=daynight');
      status := IfThen (Dawn.Next>Dusk.Next,'day','night');
      aMsg.Body.AddKeyValue( 'status=' + status );

      level := 0;
      if status = 'day' then begin
         FixDawn := Dawn.Next;
         if FixDawn > Dusk.Next then FixDawn := FixDawn -1;

         FixNoon := Noon.Next;
         if FixNoon > Dusk.Next then FixNoon := FixNoon -1;

         delta := MinutesBetween(Now,FixNoon);

         lag := MinutesBetween(FixDawn,FixNoon);
         level := Round(6/lag * (lag-delta));
      end;
      aMsg.Body.AddKeyValue('level=' + IntToStr(level));
      aMsg.Send;
      aMsg.Destroy;
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
   else if aVariable = 'tmrstart'   then for i:=0 to TimerList.Count-1 do ReturnList.Add(DateTimeToStr(TimerList.Timers[i].StartTime))
   else if aVariable = 'tmrcount'   then for i:=0 to TimerList.Count-1 do ReturnList.Add(IntToStr(TimerList.Timers[i].Remaining))
   else if aVariable = 'tmrstatus'  then for i:=0 to TimerList.Count-1 do ReturnList.Add(TimerList.Timers[i].Status)
   else if aVariable = 'tmrstop'    then for i:=0 to TimerList.Count-1 do ReturnList.Add(DateTimeToStr(TimerList.Timers[i].EstimatedEnd));

   result := (ReturnList.Count >0);
end;

// Event menu manipulations ====================================================
procedure TfrmMain.mnuEditEventClick(Sender: TObject);
begin lvEventsDblClick(sender); end;

procedure TFrmMain.lvEventsDblClick(Sender: TObject);
begin
   if not Assigned(lvEvents.Selected) then exit;
   TxPLEvent(lvEvents.Selected.Data).Edit;
end;

procedure TfrmMain.mnuFireNowClick(Sender: TObject);                            // FS#27 Ajout fonctionnalité Fire Now
begin
   if not Assigned(lvEvents.Selected) then exit;
   TxPLEvent(lvEvents.Selected.Data).Fire;
end;

procedure TfrmMain.mnuDeleteEventClick(Sender: TObject);
var s : string;
begin
   if not assigned(lvEvents.Selected) then exit;
   s := lvEvents.Selected.Caption;
   EventList.Delete(TxPLEvent(lvEvents.Selected.Data));
   xPLClient.LogInfo('Event %s deleted',[s]);
end;

// Timers manipulations functions ==============================================
procedure TfrmMain.MnuEditTimerClick(Sender: TObject);
begin
   if Assigned(lvTimers.Selected) then TxPLTimer(lvTimers.Selected.Data).Edit;
end;

procedure TfrmMain.MnuStopTimerClick(Sender: TObject);
begin
   if not Assigned(lvTimers.Selected) then exit;
   OnControlBasic(aMessage,lvTimers.Selected.Caption,'stop');                // I can't self target myself, then I must shortcut directly to the function
end;                                                                         // aMessage has no importance at all here

initialization
  {$I frm_main.lrs}

end.

