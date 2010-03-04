unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ActnList, ExtCtrls, Grids, StdCtrls,MkPinger,
  DateUtils, IdICMPClient,IdCustomHTTPServer,
  Variants,  Buttons, uxPLConfig,uxPLWebListener, uxPLMessage, uxPLMsgHeader, uxPLConst;

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

    procedure OnSensorRequest(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
    procedure OnConfigDone(const fConfig : TxPLConfig);
    procedure SendSensorMsg(aMsgType : TxPLMessageType; aDevice: string; aValue: string);
    function  AppendAHost(aHostName : string) : TMkPinger;
    procedure CommandGet(var aPageContent : widestring;  ARequestInfo: TIdHTTPRequestInfo);
    procedure LogUpdate(const aList : TStringList);
    function  ReplaceTag(const aDevice : string; const aParam : string; aValue : string; const aVariable : string; out ReplaceString : string) : boolean;
    function  ReplaceArrayedTag(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean;
  end;

var frmMain: TfrmMain;

implementation {==========================================================================================}
uses Frm_About,LCLType,  XMLCfg, StrUtils;

//=====================================================================================================
resourcestring
     K_XPL_APP_VERSION_NUMBER ='1.7';
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

procedure TfrmMain.LogUpdate(const aList: TStringList);
begin Memo1.Lines.Add(aList[aList.Count-1]); end;

procedure TfrmMain.FormCreate(Sender: TObject);

procedure initListener;
begin
   xPLClient := TxPLWebListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE, K_XPL_APP_VERSION_NUMBER,K_DEFAULT_PORT);
   with xPLClient do begin
       OnxPLSensorRequest  := @OnSensorRequest;
       OnxPLConfigDone     := @OnConfigDone;
       OnCommandGet        := @CommandGet;
       OnLogUpdate         := @LogUpdate;
       OnReplaceTag        := @ReplaceTag;
       OnReplaceArrayedTag := @ReplaceArrayedTag;
       Config.AddItem(K_CONFIG_INTERVAL, xpl_ctConfig ,'2');
       Config.AddItem(K_CONFIG_TIMEOUT, xpl_ctConfig ,'5');
       Config.AddItem(K_CONFIG_RETRIES   , xpl_ctConfig ,'3');
   end;
   xPLClient.Listen;
end;

begin
  bConfirmExit := True;

  InitListener;
  aMessage := xPLClient.PrepareMessage(xpl_mtStat,'');
  Self.Caption := xPLClient.AppName;
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

function TfrmMain.ReplaceTag(const aDevice: string; const aParam : string; aValue : string; const aVariable: string; out ReplaceString: string): boolean;
var item : TMKPinger;
begin
   ReplaceString := '';
   if aParam='hostname' then begin
      item := fPingerList.ItemByName(aValue);
      if Assigned(item) then begin
         if aVariable = 'hostname'  then ReplaceString := Item.Host
         else if aVariable = 'ipaddress' then ReplaceString := IfThen(Item.Statistics.Host<>'',Item.Statistics.Host,'unknown')
         else if aVariable = 'pingtime'  then ReplaceString := FloatToStr(Item.Statistics.RttAvg)
         else if aVariable = 'status'    then ReplaceString := Item.StatusAsString;
      end;
   end;
   result := ReplaceString<>'';
end;

function TfrmMain.ReplaceArrayedTag(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean;
var i : integer;
begin
   if aDevice<>K_DEFAULT_DEVICE then exit;
   ReturnList.Clear;

   if aVariable = 'hostname'  then for i:=0 to fPingerList.Count-1 do ReturnList.Add(TMkPinger(fPingerList.Items[i]).Host)
   else if aVariable = 'ipaddress' then for i:=0 to fPingerList.Count-1 do ReturnList.Add(TMkPinger(fPingerList.Items[i]).Statistics.Host)
   else if aVariable = 'pingtime'  then for i:=0 to fPingerList.Count-1 do ReturnList.Add(FloatToStr(TMkPinger(fPingerList.Items[i]).Statistics.RttAvg))
   else if aVariable = 'status'    then for i:=0 to fPingerList.Count-1 do ReturnList.Add(TMkPinger(fPingerList.Items[i]).StatusAsString);

   result := (ReturnList.Count >0);
end;


procedure TfrmMain.CommandGet(var aPageContent : widestring; ARequestInfo: TIdHTTPRequestInfo);
var aParam : string;
begin
   if ARequestInfo.Params.Count=0 then exit;

      aParam := ARequestInfo.Params.Names[0];
      if aParam ='delete'   then fPingerList.DeletePing(ARequestInfo.Params.Values[aParam])
      else if aParam ='add' then AppendAHost(ARequestInfo.Params.Values[aParam]);

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


// xPL Messages management ====================================================================================
procedure TfrmMain.OnSensorRequest(const axPLMsg: TxPLMessage; const aDevice : string; const aAction : string);
var item    : TMkPinger;
begin
    if aAction = 'current' then begin
       item := fPingerList.ItemByName(aDevice);
       if item<>nil then SendSensorMsg(xpl_mtStat,aDevice, item.StatusAsString);
    end;
end;

procedure TfrmMain.SendSensorMsg(aMsgType : TxPLMessageType; aDevice: string; aValue: string);
begin
   aMessage.Header.MessageType := aMsgType;
   aMessage.Body.Format_SensorBasic(aDevice,'ping',aValue);
   aMessage.Send ;
end;

// Ping management ============================================================================================
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

  xPLClient.LogInfo('Pinging...');
end;

procedure TfrmMain.PingsFinished(Sender: TObject);
begin
    Application.ProcessMessages;
    Timer.Enabled := true;
end;

initialization
  {$I frm_main.lrs}

end.

