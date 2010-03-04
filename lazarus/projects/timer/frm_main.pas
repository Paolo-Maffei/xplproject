unit frm_main;

{$mode objfpc}{$H+}                             

interface
                                         
uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ActnList, ExtCtrls, uxPLListener, uxPLMessage,
  Grids, Buttons, uxPLConfig,  frm_xPLTimer, frm_xplrecurevent,
  uxPLRecurEvent, uxPLTimer, XMLPropStorage;

type

  { TfrmMain }
  TfrmMain = class(TForm)
    About: TAction;
    acNewSingleEvent: TAction;
    acNewRecurringEvent: TAction;
    acNewTimer: TAction;
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
    mnuEditEvent: TMenuItem;
    mnuFireNow: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem6: TMenuItem;
    mnuDeleteEvent: TMenuItem;
    mnuAddRecurringEvent: TMenuItem;
    mnuAddSingleEvent: TMenuItem;
    MnuStopTimer: TMenuItem;
    MenuItem11: TMenuItem;
    MnuEditTimer: TMenuItem;
    MnuNewTimer: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    popmnuTimer: TPopupMenu;
    popmnuEvents: TPopupMenu;
    Quit: TAction;
    SaveSettings: TAction;
    Splitter1: TSplitter;
    TimerImages: TImageList;
    StatusBar1: TStatusBar;
    UpdateSeed: TAction;
    XMLPropStorage1: TXMLPropStorage;
    procedure AboutExecute(Sender: TObject);
    procedure acNewRecurringEventExecute(Sender: TObject);
    procedure acNewSingleEventExecute(Sender: TObject);
    procedure acNewTimerExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure InstalledAppsExecute(Sender: TObject);
//    procedure LogViewerExecute(Sender: TObject);
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

    procedure OnJoined(const aJoined : boolean);
    procedure OnConfigDone(const fConfig : TxPLConfig);
    procedure OnSensorRequest(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
    procedure OnControlBasic (const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
//    procedure SendInitMessage;
  public
     bJoined, bConfigured, bInitMessageLaunched : boolean;

     xPLClient : TxPLListener;
  end;

var frmMain: TfrmMain;

implementation {===============================================================}
uses Frm_About, frm_xPLAppslauncher, uxPLSingleEvent, uxPLConst,
     LCLType, StrUtils, DateUtils, uxPLMsgHeader, XMLCfg;

{==============================================================================}
resourcestring
     K_XPL_APP_VERSION_NUMBER = '1.1.2';
     K_XPL_APP_NAME = 'xPL Timer';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'timer';

{ General window functions ====================================================}
procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.InstalledAppsExecute(Sender: TObject);
begin frmAppLauncher.ShowModal; end;

procedure TfrmMain.QuitExecute(Sender: TObject);
begin Close; end;

procedure TfrmMain.acNewRecurringEventExecute(Sender: TObject);
var anEvent : TxPLRecurEvent;
    itemnum : integer;
begin
   anEvent := TxPLRecurEvent.Create(aMessage);
   if anEvent.Edit then begin
      if eventlist.indexof(anEvent.Name)=-1 then begin
         itemnum := eventlist.add(anEvent.Name);
         eventlist.Objects[itemnum] := anEvent;
      end else begin
         Application.MessageBox('Event already exists','Error',0);
         anEvent.Destroy;
      end;
   end;
end;

procedure TfrmMain.acNewSingleEventExecute(Sender: TObject);
var anEvent : TxPLSingleEvent;
    itemnum : integer;
begin
   anEvent := TxPLSingleEvent.Create(aMessage);
   if anEvent.Edit then begin
      if eventlist.indexof(anEvent.Name)=-1 then begin
         itemnum := eventlist.add(anEvent.Name);
         eventlist.Objects[itemnum] := anEvent;
      end else begin
         Application.MessageBox('Event already exists','Error',0);
         anEvent.Destroy;
      end;
   end else
      anEvent.Destroy;
end;

procedure TfrmMain.acNewTimerExecute(Sender: TObject);
var aTimer : TxPLTimer;
begin
   aTimer := TxPLTimer.Create(TimerList.xPLMessage);
   if aTimer.Edit then begin
      if TimerList.IndexOf(aTimer.TimerName)=-1 then TimerList.Add(aTimer)
                                           else begin
                                                Application.MessageBox('Timer already exists','Error',0);
                                                aTimer.Destroy;
                                           end;
   end else
      aTimer.Destroy;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin CanClose := (Application.MessageBox('Do you want to quit ?','Confirm',MB_YESNO) = IDYES) end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Self.Caption := K_XPL_APP_NAME;            
  bJoined := false;
  bConfigured := false;
  bInitMessageLaunched := false;

  xPLClient := TxPLListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER);
  OnJoined(False);

  with xPLClient do begin
       OnxPLJoinedNet := @OnJoined;
       OnxPLConfigDone:= @OnConfigDone;
       OnxPLSensorRequest := @OnSensorRequest;
       OnxPLControlBasic  := @OnControlBasic;
       Listen;
  end;
end;

procedure TFrmMain.OnJoined(const aJoined: boolean);
begin
   bJoined := aJoined;
   StatusBar1.Panels[0].Text := 'Hub ' + IfThen( xPLClient.JoinedxPLNetwork, '','not') + ' found';
   StatusBar1.Panels[1].Text := 'Configuration ' + IfThen (bConfigured, 'done','pending');
end;

procedure TfrmMain.OnConfigDone(const fConfig: TxPLConfig);
var config : TXmlConfig;
begin
     if bConfigured then exit;

     bConfigured := true;
     config := xPLClient.Config.XmlFile;

     aMessage := xPLClient.PrepareMessage(xpl_mtCmnd,'control.basic');

     eventlist := TxPLEventList.Create(xPLClient, lvEvents);
     timerlist := TxPLTimerList.Create(xPLClient, lvTimers);

     timerList.ReadFromXML(Config,'TimerList');
     eventList.ReadFromXML(Config,'EventList');

     acNewSingleEvent.Enabled := true;
     acNewRecurringEvent.Enabled := true;
     acNewTimer.Enabled := true;

     Config.Flush;
end;

{procedure TFrmMain.SendInitMessage;
begin
   if not (bJoined and bConfigured and not bInitMessageLaunched) then exit;

   aMessage := xPLClient.PrepareMessage(xpl_mtCmnd,'control.basic');
   with aMessage do begin
        Body.AddKeyValuePair('current','start');
        Body.AddKeyValuePair('device','timer_app');
        Send;
   end;
   xPLClient.LogInfo('Init message launched');
   bInitMessageLaunched := True;
end;}

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   if Assigned(aMessage) then aMessage.Destroy;
   if not Assigned(xPLClient) then exit;

   if Assigned(timerlist) then begin
      timerlist.WriteToXML(xPLClient.Config.XmlFile,'TimerList');
      timerlist.destroy;
   end;

   if Assigned(eventlist) then begin
      eventlist.WriteToXML(xPLClient.Config.XmlFile,'EventList');
      eventlist.destroy;
   end;
   xPLClient.destroy;
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

// Event menu manipulations ====================================================

procedure TfrmMain.mnuEditEventClick(Sender: TObject);
begin lvEventsDblClick(sender); end;

procedure TFrmMain.lvEventsDblClick(Sender: TObject);
var anEvent : TxPLSingleEvent;
begin
     if not Assigned(lvEvents.Selected) then exit;

     anEvent := TxPLSingleEvent(lvEvents.Selected.Data);
     anEvent.Edit;
end;

procedure TfrmMain.mnuFireNowClick(Sender: TObject);                            // FS#27 Ajout fonctionnalité Fire Now
var anEvent : TxPLSingleEvent;
begin
   if not Assigned(lvEvents.Selected) then exit;

   anEvent := TxPLSingleEvent(lvEvents.Selected.Data);
   anEvent.Fire;
end;

procedure TfrmMain.mnuDeleteEventClick(Sender: TObject);
var i : integer;
    s : string;
begin
     if not assigned(lvEvents.Selected) then exit;
     s := lvEvents.Selected.Caption;
     i := EventList.IndexOf(s);
     if i<>-1 then begin
        EventList.Delete(i);
        xPLClient.LogInfo('Event ' + s + ' deleted');
     end;
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

