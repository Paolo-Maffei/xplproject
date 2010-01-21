unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ActnList, ExtCtrls, Grids, StdCtrls,MkPinger,
  DateUtils, IdICMPClient,IdCustomHTTPServer,
  Variants,  Buttons, uxPLConfig,uxPLWebListener, uxPLMessage, uxPLMsgHeader;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem3: TMenuItem;

    Quit: TAction;
    About: TAction;
    ActionList1: TActionList;
    MenuItem2: TMenuItem;
    Timer: TTimer;
    ToolBar1: TToolBar;
    procedure AboutExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure ICMPReply (ASender: TComponent; const ReplyStatus: TReplyStatus);
    procedure ICMPFinish(ASender: TComponent; const AStatistics : TPingerStat);
  private
    aMessage    : TxPLMessage;
    FPingerList : TMkPingerList;

     procedure PingsFinished(Sender: TObject);
  public
    Ping_Interval : integer;

    bConfirmExit : boolean;
    xPLClient   : TxPLWebListener;

    { xPL Part }
    procedure OnJoined(const aJoined : boolean);
    procedure OnSensorRequest(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
    procedure OnConfigDone(const fConfig : TxPLConfig);
    procedure SendSensorMsg(aMsgType : TxPLMessageType; aDevice: string; aValue: string);
    procedure UpdateStatusBar;
    function  AppendAHost(aHostName : string) : TMkPinger;

    procedure CommandGet(var aPageContent : widestring; aParam, aValue : string);
  end;

var
  frmMain: TfrmMain;

implementation {==========================================================================================}
uses Frm_About,LCLType, uxplcfgitem, StrUtils, cStrings, XMLCfg, uxPLConst;

//=====================================================================================================
resourcestring
     K_XPL_APP_VERSION_NUMBER ='1.5';
     K_XPL_APP_NAME = 'xPL Ping';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'ping';
     K_DEFAULT_PORT   = '8334';

     K_CONFIG_INTERVAL = 'ping_interval';
     K_CONFIG_TIMEOUT  = 'receive_tmout';
     K_CONFIG_RETRIES  = 'nb_retries';

//=====================================================================================================
procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.QuitExecute(Sender: TObject);
begin Close; end;

procedure TFrmMain.OnJoined(const aJoined: boolean);
begin UpdateStatusBar; end;

procedure TfrmMain.UpdateStatusBar;
begin
   Memo1.Lines.Add(Format(K_MSG_HUB_FOUND,[IfThen( xPLClient.JoinedxPLNetwork, '','not')]));
   Memo1.Lines.Add(Format(K_MSG_CONFIGURED,[IfThen(xPLClient.AwaitingConfiguration, 'pending','done')]));
end;

procedure TfrmMain.FormCreate(Sender: TObject);
procedure initListener;
begin
  xPLClient := TxPLWebListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE, K_XPL_APP_NAME, K_XPL_APP_VERSION_NUMBER,K_DEFAULT_PORT);
  with xPLClient do begin
       OnxPLJoinedNet     := @OnJoined;
       OnxPLSensorRequest := @OnSensorRequest;
       OnxPLConfigDone    := @OnConfigDone;
       OnCommandGet       := @CommandGet;
       Config.AddItem(K_CONFIG_INTERVAL, xpl_ctConfig ,'2');
       Config.AddItem(K_CONFIG_TIMEOUT, xpl_ctConfig ,'5');
       Config.AddItem(K_CONFIG_RETRIES   , xpl_ctConfig ,'3');
  end;
  OnJoined(False);
  xPLClient.Listen;
end;

begin
  Self.Caption := K_XPL_APP_NAME;
  bConfirmExit := True;

  InitListener;
  aMessage := xPLClient.PrepareMessage(xpl_mtStat,'');
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
     if (bConfirmExit) then begin
        CanClose := (Application.MessageBox('Do you want to quit ?','Confirm',MB_YESNO) = IDYES);
        if CanClose then begin
           Timer.Enabled := False;
           xPLClient.LogInfo('Configuration saved');
        end;
     end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var i : integer;
    config : TXmlConfig;
begin
  if Assigned(aMessage) then aMessage.Destroy;
  if Assigned(xPLClient) then begin
     Timer.Enabled := false;
     config := xPLClient.Config.XmlFile;
     for i:=0 to fPingerList.Count-1 do begin
         Config.SetValue('PingList/Ping_' + intToStr(i) + '/HostName',fPingerList[i].Host);
     end;
     xPLClient.destroy;
     FPingerList.Free;
  end;
end;

function TfrmMain.AppendAHost(aHostName : string) : TMkPinger;
begin
     result := nil;

     if fPingerList.ItemByName(aHostName)<> nil then exit;

     result := fPingerList.AddNewPing;
     result.Host := aHostName;
     result.OnEachReply := @ICMPReply;
     result.OnFinish    := @ICMPFinish;
end;

procedure TfrmMain.CommandGet(var aPageContent : widestring; aParam, aValue : string);
var
  Pattern : string;
  sOut    : widestring;
  Where   : integer;
  i       : integer;
  item    : TMkPinger;
begin
   if aParam='delete' then begin fPingerList.DeletePing(aValue); aValue:=''; end;
   if aParam='add'    then begin AppendAHost(aValue); aValue:=''; end;

   Pattern := StrBetween(aPageContent,K_WEB_TEMPLATE_BEGIN,K_WEB_TEMPLATE_END);
   if (AnsiPos('{%ping_', Pattern)<>0) then begin                                           // here is a pattern we must handle
      Where  := AnsiPos(K_WEB_TEMPLATE_BEGIN, aPageContent);                                   // Locate where it begins
      Delete(aPageContent,Where,length(K_WEB_TEMPLATE_END + K_WEB_TEMPLATE_BEGIN +Pattern));   // Delete it to avoid being processed by another
      i := fPingerList.Count -1;
      while(i>=0) do begin
         item := TMkPinger(fPingerList.Items[i]);
         if (aValue=item.Host) or (aValue='') then begin
           sOut := Pattern;
           HtmlReplaceVar( ['ping_hostname', 'ping_ipaddress', 'ping_pingtime', 'ping_status'],
                           [item.Host      , item.Statistics.Host  , FloatToStr(item.Statistics.RttAvg), item.StatusAsString],sOut);
           Insert(sOut,aPageContent,Where);
           Where += length(sOut);
         end;
         dec(i);
      end;
   end;
end;

procedure TfrmMain.ICMPReply(ASender: TComponent;  const ReplyStatus: TReplyStatus);
var s : string;
begin
  Application.ProcessMessages;
  S := Format( '%32s %17s %5d ms  %2d RStatus', [TMkPinger(aSender).Host, ReplyStatus.FromIpAddress, ReplyStatus.MsRoundTripTime, ord( ReplyStatus.ReplyStatusType)]);
  xPLClient.LogInfo(s);
end;

procedure TfrmMain.ICMPFinish(ASender: TComponent; const AStatistics: TPingerStat);
var item    : TMkPinger;
begin
  Application.ProcessMessages;
  item := fPingerList.ItemByName(TMkPinger(aSender).Host);

  if not assigned (item) then exit;
  if item.OldStatus<>item.StatusAsSTring then begin
     SendSensorMsg(xpl_mtTrig,item.Host,AnsiLowerCase(item.StatusAsSTring));
     item.OldStatus := item.StatusAsString;
  end;

  Memo1.Lines.Add('Pinging...');
end;

procedure TfrmMain.SendSensorMsg(aMsgType : TxPLMessageType; aDevice: string; aValue: string);
begin
   aMessage.Header.MessageType := aMsgType;
   aMessage.Body.Format_SensorBasic(aDevice,'ping',aValue);
   aMessage.Send ;
end;

procedure TfrmMain.OnConfigDone(const fConfig: TxPLConfig);
var  config : TXmlConfig;
    i : integer;
begin
  if not assigned(FPingerList) then FPingerList := TMkPingerList.Create;
  config := xPLClient.Config.XmlFile;
  FPingerList.OnFinish := @PingsFinished;
  FPingerList.TimeOut  := fConfig.ItemName['receive_tmout'].AsInteger*1000;
  Ping_Interval := fConfig.ItemName['ping_interval'].AsInteger;
  i := 0;
  while (Config.GetValue('PingList/Ping_' + intToStr(i) + '/HostName', 'myDummyImprobableHostname')<> 'myDummyImprobableHostname' ) do begin
        AppendAHost(Config.GetValue('PingList/Ping_' + intToStr(i) + '/HostName',''));
        Config.DeletePath ('PingList/Ping_' + intToStr(i)); // Ensure we won't reload it once again later
        inc(i);
  end;
  Timer.Enabled := true;
  UpdateStatusBar;
end;

procedure TfrmMain.TimerTimer(Sender: TObject);
var NowDT : TDateTime;
begin
  NowDT := Now;

  if ( SecondOfTheYear( NowDT) MOD ( Ping_Interval * 60) = 0) AND ( NOT FPingerList.Pinging) then begin
           Application.ProcessMessages;
           Timer.Enabled := false;
           FPingerList.Process;
           Application.ProcessMessages;
     end
end;

procedure TfrmMain.PingsFinished(Sender: TObject);
begin
    Application.ProcessMessages;
    Timer.Enabled := true;
end;

procedure TfrmMain.OnSensorRequest(const axPLMsg: TxPLMessage; const aDevice : string; const aAction : string);
var item    : TMkPinger;
begin
    if aAction = 'current' then begin
       item := fPingerList.ItemByName(aDevice);
       if item<>nil then SendSensorMsg(xpl_mtStat,aDevice, item.StatusAsString);
    end;
end;


initialization
  {$I frm_main.lrs}

end.

