unit frm_main;

{$mode objfpc}{$H+}

// Détail du protocole Grenouille : http://wiki.grenouille.com/index.php/Projet_Technique#Commande_post_dl_ftp

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, ComCtrls,
  Menus, ActnList, ExtCtrls, StdCtrls, Grids, EditBtn, Buttons, uxPLWebListener, uxPLMessage,
  IdCustomHTTPServer, IdHTTP, fpTimer, IdMessage, IdIOHandlerStack,
  IdSSLOpenSSL, IdFTP, IdComponent, IdIcmpClient, IdAntiFreeze, Decal;

type
  TFtpRecord = record
//     Remaining : integer;
//     Frequency : integer;
     StartTime : TDateTime;
     StopTime  : TDateTime;
     SourceFile: string;
     TargetFile: string;
     FileSize  : Int64;
     max       : Int64;
     ratiomax : Int64;
     bandwidth  : Extended;
  end;

  TPingRecord = record
//     Remaining : integer;
//     Frequency : integer;
     StopTime  : TDateTime;
     Quantity : integer;
     Min : integer;
     Max : integer;
     Str : String;
     Counted : integer;
     Somme : integer;
  end;

  TBDRecord = record
//     Remaining : integer;
//     Frequency : integer;
     StopTime  : TDateTime;
     Quantity : integer;
     Counted  : integer;
     Flag     : boolean;
  end;

  { TfrmMain }

  TfrmMain = class(TForm)
    DLFTP: TIdFTP;
    BDPING: TIdIcmpClient;
    IdAntiFreeze1: TIdAntiFreeze;
    PING: TIdIcmpClient;
    StatusBar1: TStatusBar;
    GeneralTimer: TFPTimer;
    ULFTP: TIdFTP;
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;

    procedure AboutExecute(Sender: TObject);
    procedure BDPINGReply(ASender: TComponent; const AReplyStatus: TReplyStatus );
    procedure BDTimerTimer(Sender: TObject);
    procedure DLFTPAfterGet(ASender: TObject; AStream: TStream);
    procedure DLFTPDisconnected(Sender: TObject);
    procedure DLFTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure DLTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GeneralTimerTimer(Sender: TObject);
    procedure PINGReply(ASender: TComponent; const AReplyStatus: TReplyStatus);
    procedure PINGTimerTimer(Sender: TObject);
    procedure ULFTPAfterPut(Sender: TObject);
    procedure ULFTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure ULTimerTimer(Sender: TObject);
    procedure ControlBasic(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
  private
    DlFtpStats : TFtpRecord;
    UlFtpStats : TFtpRecord;
    PingStats  : TPingRecord;
    BDHosts    : DMap;
    BDStats    : TBDRecord;
    procedure AddComment(aString : string);

  public
    procedure OnPrereqMet;
    procedure OnReceived(const axPLMsg : TxPLMessage);
    procedure LogUpdate(const aString : string);
    function  ReplaceTag (const aDevice : string; const aParam : string; aValue : string; const aVariable : string; out ReplaceString : string) : boolean;
    function  ReplaceArrayedTag(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean;
    procedure OpenConnection;
    procedure OpenConnection2;
    procedure ULCreateTempFile;
  end;

var  frmMain: TfrmMain;

implementation //======================================================================================
uses app_main,
     frm_about,
     StrUtils,
     cStrings,
     LCLType,
     IdFTPCommon,
     cUtils,
     uxPLConst,
     DateUtils,
     cDateTime;

//=====================================================================================================
const
     K_XPL_APP_VERSION_NUMBER = '0.5';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'frog';
     K_DEFAULT_PORT   = '8340';

     K_CONFIG_USERNAME = 'username';
     K_CONFIG_PASSWORD = 'password';

     K_GRENOUILLE_BASE_URL = 'http://www.grenouille.com/';
     K_GRAPH_URL = K_GRENOUILLE_BASE_URL + '/graph/?zone_name=%s';
     BASE_URL = K_GRENOUILLE_BASE_URL + 'interface.php?command=hello&username=%s&password=%s&client=%s&version=%s&system=%s';
     BASE_COMMAND = K_GRENOUILLE_BASE_URL + 'interface.php?command=%s&id=%s';

     K_DL_MSG_START = 'Download test : downloading %s on %s at %s';
     K_UL_MSG_START = 'Upload test : uploading %s on %s at %s';
     K_DL_MSG_ERROR = 'Download test : unable to open connection to %s';
     K_UL_MSG_ERROR = 'Upload test : unable to open connection to %s';
     K_DL_MSG_STOP  = '   finished downloading %s - filesize : %u bytes at %s, speed : %n';
     K_UL_MSG_STOP  = '   finished uploading %s - filesize : %u bytes at %s, speed : %n';
     K_PING_MSG_START = 'Ping test :  started at %s';
     K_PING_MSG_STOP  = 'Finished ping test at %s, average : %n ms';

//=====================================================================================================
Function CrypterPassword(password : String) :  String;
var clef : String;
    i : Integer;
    asciiPass : Integer;
    asciiClef : Integer;
begin
   clef := 'pasfaciledetrouverlaclefpourouvrirlaporte';
   result := '';

   For i := 1 to Length(password) do begin
      asciiPass := Ord(AnsiMidStr(Lowercase(password), i, 1)[1]);
      asciiClef := Ord(AnsiMidStr(Lowercase(clef), i, 1)[1]);
      If ((asciiPass >= Ord('a')) And (asciiPass <= Ord('z'))) Then
        result := Chr((asciiPass + asciiClef) Mod 26 + Ord('a')) + result
      Else begin
         If ((asciiPass >= Ord('0')) And (asciiPass <= Ord('9'))) Then
           result := Chr((asciiPass + asciiClef) Mod 10 + Ord('0')) + result
         Else
           result := '_' + result
      End
   end;
End;

procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.AddComment(aString: string);
begin xPLClient.LogInfo(aString,[]); end;

procedure TfrmMain.LogUpdate(const aString : string);
begin Memo1.Lines.Add(aString); end;

// DOWNLOAD TEST PROCEDURES ==============================================================
procedure TfrmMain.DLTimerTimer(Sender: TObject);
begin
//   DlFtpStats.Remaining  := 0;
   DLFTP.Connect;
   if DLFTP.Connected then begin
      if DlFtpStats.TargetFile = ''
      then
         DlFtpStats.TargetFile := GetTempFileName(GetTempDir,K_DEFAULT_DEVICE)
      else DeleteFile(DlFtpStats.TargetFile);
      DLFTP.Get(DlFtpStats.SourceFile, DlFtpStats.TargetFile);
   end else begin
      xPLClient.LogError(K_DL_MSG_ERROR,[DLFTP.Host]);
      DLFtpStats.StopTime := Now;
//      DLFtpStats.Remaining:=DLFtpStats.Frequency;
   end;
end;

procedure TfrmMain.DLFTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
   DlFtpStats.StartTime := Now;
   xPLClient.LogInfo(K_DL_MSG_START,[DlFtpStats.SourceFile,DLFTP.Host,DateTimeToStr(DlFtpStats.StartTime)]);
end;

procedure TfrmMain.DLFTPAfterGet(ASender: TObject; AStream: TStream);
var aMessage : TxPLMessage;
begin
   DlFtpStats.StopTime  := Now;
//   DlFtpStats.Remaining := DlFtpStats.Frequency;
   DlFtpStats.FileSize  := AStream.Size;

   DlFtpStats.bandwidth := (DlFtpStats.FileSize / DiffMilliSeconds(DlFtpStats.StartTime, DlFtpStats.StopTime)) * 1000 / 1024;
   If DlFtpStats.bandwidth > DlFtpStats.max then DlFtpStats.bandwidth := -1;
   xPLClient.LogInfo(K_DL_MSG_STOP,[DlFtpStats.SourceFile,DlFtpStats.FileSize,DateTimeToStr(DlFtpStats.StopTime), DlFtpStats.bandwidth]);

   aMessage := TxPLMessage.Create;
   aMessage.MessageType := K_MSG_TYPE_TRIG;
   aMessage.Target.IsGeneric := true;
   aMessage.Format_SensorBasic('download','flow', FloatToStr(Round(DlFtpStats.bandwidth)));
   aMessage.Body.AddKeyValuePair('highest', IntToStr(DlFtpStats.Max));
   aMessage.Body.AddKeyValuePair('units','kb/s');
   xPLClient.Send(aMessage);
   aMessage.Destroy;
   DLFTP.Disconnect(True);
end;

procedure TfrmMain.DLFTPDisconnected(Sender: TObject);
begin
   //DeleteFile(DlFtpStats.TargetFile);
end;

// UPLOAD TEST PROCEDURES ================================================================
procedure TfrmMain.ULTimerTimer(Sender: TObject);
begin
//   UlFtpSTats.Remaining:=0;
   if not ULFTP.Connected then ULFTP.Connect;
   if ULFTP.Connected then begin
         ULFtp.Put(UlFtpStats.SourceFile,UlFtpStats.TargetFile);
   end else begin
      xPLClient.LogError(K_UL_MSG_ERROR,[ULFTP.Host]);
      UlFtpStats.StopTime := Now;
//      UlFtpStats.Remaining:=UlFtpStats.Frequency;
   end;
end;

procedure TfrmMain.ControlBasic(const axPLMsg: TxPLMessage;  const aDevice: string; const aAction: string);
begin
   case AnsiIndexStr(aAction,['download','upload','ping','breakdown']) of
        0 : DLTimerTimer(self);
        1 : ULTimerTimer(self);
        2 : PingTimerTimer(self);
        3 : BDTimerTimer(self);
   end;
end;

procedure TfrmMain.ULFTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
   UlFtpStats.StartTime := Now;
   xPLClient.LogInfo(K_UL_MSG_START,[UlFtpStats.SourceFile,ULFTP.Host,DateTimeToStr(UlFtpStats.StartTime)]);
end;

procedure TfrmMain.ULFTPAfterPut(Sender: TObject);
var aMessage : TxPLMessage;
begin
   UlFtpStats.StopTime := Now;
//   UlFtpStats.Remaining:=UlFtpStats.Frequency;
   ULFtpStats.bandwidth := (ULFtpStats.FileSize / DiffMilliSeconds(ULFtpStats.StartTime, ULFtpStats.StopTime)) * 1000 / 1024;
   If ULFtpStats.bandwidth > ULFtpStats.max then ULFtpStats.bandwidth := -1;

   aMessage := TxPLMessage.Create;
   aMessage.MessageType := K_MSG_TYPE_TRIG;
   aMessage.Target.IsGeneric := True;
   aMessage.Format_SensorBasic('upload','flow', FloatToStr(Round(ULFtpStats.bandwidth)));
   aMessage.Body.AddKeyValuePair('highest', IntToStr(ULFtpStats.Max));
   aMessage.Body.AddKeyValuePair('units','kb/s');
   xPLClient.Send(aMessage);
   aMessage.Destroy;

   ULFTP.Disconnect(True);
   xPLClient.LogInfo(K_UL_MSG_STOP,[UlFtpStats.SourceFile,UlFtpStats.FileSize,DateTimeToStr(UlFtpStats.StopTime), UlFtpStats.bandwidth]);
end;

// PING TEST PROCEDURES ================================================================
procedure TfrmMain.PINGTimerTimer(Sender: TObject);
var i : integer;
begin
//   PingStats.Remaining:=0;
   PingStats.Counted:=0;
   PingStats.Somme:=0;

   xPLClient.LogInfo(K_PING_MSG_START,[DateTimeToStr(Now)]);
   for i:=1 to PingStats.Quantity do PING.Ping(PingStats.Str, i);
end;

procedure TfrmMain.PINGReply(ASender: TComponent; const AReplyStatus: TReplyStatus);
var aMessage : TxPLMessage;
    current : extended;
begin
   Inc(PingStats.Counted);
   PingStats.Somme += aReplyStatus.MsRoundTripTime;
   if PingStats.Counted = PingStats.Quantity then begin
      PingStats.StopTime:=Now;
      current := Round(PingStats.Somme / PingStats.Quantity);
      xPLClient.LogInfo(K_PING_MSG_STOP,[DateTimeToStr(Now), PingStats.Somme / PingStats.Counted]);
//      PingStats.Remaining := PingStats.Frequency;

      aMessage := TxPLMessage.Create;
      aMessage.MessageType := K_MSG_TYPE_TRIG;
      aMessage.Target.IsGeneric := True;
      aMessage.Format_SensorBasic('ping','lag', FloatToStr(current));
      aMessage.Body.AddKeyValuePair('lowest', IntToStr(PingStats.Min));
      aMessage.Body.AddKeyValuePair('highest', IntToStr(PingStats.Max));
      aMessage.Body.AddKeyValuePair('units','ms');
      xPLClient.Send(aMessage);
      aMessage.Destroy;
   end;
end;

// BREAKDOWN PROCEDURES ==================================================================
procedure TfrmMain.BDTimerTimer(Sender: TObject);
var i : integer;
begin
//   BDStats.Remaining:=0;
   xPLClient.LogInfo('Starting breakdown test',[]);
   BDStats.Counted := 0;
   for i := 1 to BDStats.Quantity do begin
(*      BDPING.Host:=BDHosts[i-1];*)
      BDPING.Ping('',i);
   end;
end;

procedure TfrmMain.BDPINGReply(ASender: TComponent; const AReplyStatus: TReplyStatus);
var aMessage : TxPLMessage;
begin
(*   BDHosts.SetValue( BDPing.Host, IfThen(aReplyStatus.ReplyStatusType = rsEcho,'on','error'),
                  aReplyStatus.FromIpAddress + ' in ' + IntToStr(aReplyStatus.MsRoundTripTime) + ' ms');*)

   Inc(BDStats.Counted);

   if BDStats.Counted=BDStats.Quantity then begin
      BdStats.StopTime:=Now;
      xPLClient.LogInfo('Finished breakdown test',[]);
//      BDStats.Remaining := BDStats.Frequency;

      if (BDStats.Flag or (aReplyStatus.ReplyStatusType = rsEcho))<>BDStats.Flag then begin
         BDStats.Flag := not BDStats.Flag;
         aMessage := TxPLMessage.Create;
         aMessage.MessageType := K_MSG_TYPE_TRIG;
         aMessage.Target.IsGeneric := True;
         aMessage.Format_SensorBasic('internet','connectivity',IfThen(BDStats.Flag,'up','down'));
         xPLClient.Send(aMessage);
         aMessage.Destroy;
      end;
   end;
end;

// Web server management procedures =====================================================
function TfrmMain.ReplaceTag(const aDevice: string; const aParam: string; aValue: string; const aVariable: string; out ReplaceString: string): boolean;
begin
   if aDevice <> K_DEFAULT_DEVICE then exit;        // This isn't for me
   ReplaceString := '';
   if aVariable = 'dl_bandwidth' then ReplaceString := IntToStr(Round(DlFtpStats.bandwidth))
   else if aVariable = 'ul_bandwidth' then ReplaceString := IntToStr(Round(UlFtpStats.bandwidth))
   else if aVariable = 'ping' then begin
           if PingStats.Counted<>0 then ReplaceString :=  IntToSTr(Round((PingStats.Somme / PingStats.Counted))) else ReplaceString := '-'
        end
(*   else if aVariable = 'dl_next' then ReplaceString := IntToStr(DlFtpStats.Remaining div 60)
   else if aVariable = 'ul_next' then ReplaceString := IntToStr(UlFtpStats.Remaining div 60)
   else if aVariable = 'ping_next' then ReplaceString := IntToStr(PingStats.Remaining div 60)*)
   else if aVariable = 'dl_max' then ReplaceString := FloatToStr(DlFtpStats.max)
   else if aVariable = 'ul_max' then ReplaceString := IntToStr(UlFtpStats.max)
   else if aVariable = 'bd_status' then ReplaceString := IfThen(BDStats.Flag,'on','error')
   else if aVariable = 'graph_url' then ReplaceString := Format(K_GRAPH_URL,[xPLClient.Config.ItemName[K_CONFIG_USERNAME].Value])
   else if aVariable = 'ping_max' then ReplaceString := IntToStr(PingStats.Max);
  ;
   Result := ReplaceString<>'';
end;

function TfrmMain.ReplaceArrayedTag(const aDevice: string; const aValue: string; const aVariable: string; ReturnList: TStringList ): boolean;
var i : integer;
begin
   if aDevice<>K_DEFAULT_DEVICE then exit;
   ReturnList.Clear;

(*   if aVariable = 'hostname'  then for i:=0 to BDHosts.Count-1 do ReturnList.Add(BDHosts[i])
   else if aVariable = 'comment' then for i:=0 to BDHosts.Count-1 do ReturnList.Add(BDHosts.Item(i).Comment)
   else if aVariable = 'status'  then for i:=0 to BDHosts.Count-1 do ReturnList.Add(BDHosts.Item(i).Value);*)
   result := (ReturnList.Count >0);
end;

procedure TfrmMain.OnPrereqMet;
var URI : string;
begin
   DLFTP.Username   := 'anonymous';
   DLFTP.Password   := 'ano@nymous.com';
   DLFTP.Passive    := true;
   DLFTP.TransferType:=ftBinary;

   ULFTP.Username   := DLFTP.Username;
   ULFTP.Password   := DLFTP.Password;
   ULFTP.Passive    := true;
   ULFTP.TransferType:=ftBinary;
   GeneralTimer.Enabled := True;

   URI := Format(BASE_URL,[xPLClient.Config.ItemName[K_CONFIG_USERNAME].Value,
                           CrypterPassword(xPLClient.Config.ItemName[K_CONFIG_PASSWORD].Value),
                           'vbGrenouille','1.02','win32']);
   xPLClient.SendMessage( K_MSG_TYPE_CMND,xPLClient.PrereqList.Values['netget'],K_SCHEMA_NETGET_BASIC,
                          ['protocol','uri','destdir','destfn'],['http',URI,GetTempDir,'grenouille_log.txt']);
end;

procedure TfrmMain.OnReceived(const axPLMsg: TxPLMessage);
begin
   with axPLMsg do begin
      if (MessageType = K_MSG_TYPE_TRIG) and
         (Schema.Tag = K_SCHEMA_NETGET_BASIC) and
         (Body.GetValueByKey('current') = 'done') then begin
            if (Body.GetValueByKey('destfn') = 'grenouille_log.txt') then OpenConnection;
            if (Body.GetValueByKey('destfn') = 'grenouille.txt') then OpenConnection2;
         end;
   end;
end;


procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   GeneralTimer.Destroy;
   if FileExists(UlFtpStats.SourceFile) then DeleteFile(UlFtpStats.SourceFile);
   BDHosts.Destroy;
   xPLClient.Destroy;
end;

procedure TfrmMain.GeneralTimerTimer(Sender: TObject);
begin
(*     if DlFtpStats.Remaining = 1 then DLTimerTimer(self) else Dec(DlFtpStats.Remaining);
     if UlFtpStats.Remaining = 1 then ULTimerTimer(self) else Dec(UlFtpStats.Remaining);
     if PingStats.Remaining = 1 then PingTimerTimer(self) else Dec(PingStats.Remaining);
     if BdStats.Remaining = 1 then BDTimerTimer(self) else Dec(BdStats.Remaining);

     if DlFtpStats.Remaining>0 then StatusBar1.Panels[0].Text:= 'DL in ' + IntToStr(DlFtpStats.Remaining) else StatusBar1.Panels[0].Text:= 'DL running';
     if UlFtpStats.Remaining>0 then StatusBar1.Panels[1].Text:= 'UL in ' + IntToStr(UlFtpStats.Remaining) else StatusBar1.Panels[1].Text:= 'UL running';
     if PingStats.Remaining>0 then StatusBar1.Panels[2].Text:= 'Ping in ' + IntToStr(PingStats.Remaining) else StatusBar1.Panels[2].Text:= 'Ping running';
     if BdStats.Remaining>0 then StatusBar1.Panels[3].Text:= 'BD in ' + IntToStr(BDStats.Remaining)       else StatusBar1.Panels[3].Text:= 'BD running';*)
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
   xPLClient := TxPLWebListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER, K_DEFAULT_PORT);
   with xPLClient do begin
       OnxPLPrereqMet    := @OnPrereqMet;
       OnLogUpdate       := @LogUpdate;
       OnxPLReceived     := @OnReceived;
       OnReplaceTag      := @ReplaceTag;
       OnReplaceArrayedTag := @ReplaceArrayedTag;
       OnxPLControlBasic:= @ControlBasic;
       Config.AddItem(K_CONFIG_USERNAME, K_XPL_CT_CONFIG);
       Config.AddItem(K_CONFIG_PASSWORD, K_XPL_CT_CONFIG);
       PrereqList.Add('netget=0');
       PrereqList.Add('timer=0');
       PassMyOwnMessages:=True;
   end;

   xPLClient.Listen;
   Self.Caption := xPLClient.AppName;
   Self.Icon    := Application.Icon ;
   BDHosts      := DMAP.Create;

   GeneralTimer := TFPTimer.Create(self);
   GeneralTimer.Interval := 1000;
   GeneralTimer.OnTimer := @GeneralTimerTimer;
end;

procedure TfrmMain.OpenConnection;
var id : string;
    sl : TStringList;
begin
   sl := TStringList.Create;
   sl.Delimiter:=#10;
   sl.LoadFromFile(GetTempDir + 'grenouille_log.txt');

   if sl.Values['result']='OK' then begin
      id := sl.Values['id'];
      xPLClient.SendMessage( K_MSG_TYPE_CMND,xPLClient.PrereqList.Values['netget'],K_SCHEMA_NETGET_BASIC,
                          ['protocol','uri','destdir','destfn'],['http',Format(BASE_COMMAND,['get_config',id]),GetTempDir,'grenouille.txt']);
   end;
   sl.destroy;
end;

procedure TFrmMain.OpenConnection2;
var sl : TStringList;
    s : widestring;
    sa : StringArray;
    i : integer;
begin
   sl := TStringList.Create;
   sl.Delimiter := #10;
   sl.LoadFromFile(GetTempDir + 'grenouille.txt');
   s := sl.Text;
   s := AnsiReplaceStr(s,' ','#');
   s := AnsiReplaceStr(s,',','#');
   sl.DelimitedText:=s;
   if sl.Values['result']='OK' then begin
      memo1.lines.AddStrings(sl);
      xPLClient.LogInfo('Successfully connected to grenouille.com',[]);
      DLFTP.Host       := sl.Values['dl_host'];
//      DlFtpStats.Frequency := StrToInt(sl.Values['dl_frequency']);
      DlFtpStats.SourceFile := sl.Values['dl_path'] + sl.Values['dl_file'];
      DlFtpStats.max := StrToInt(sl.Values['dl_max']);
      DlFtpStats.ratiomax := StrToInt(sl.Values['dl_ratiomaxdl']);
      xPLClient.SendMessage( K_MSG_TYPE_CMND, xPLClient.PrereqList.Values['timer'], 'control.basic',
                          ['current','device','frequence'],['start','dlftp',sl.Values['dl_frequency']]);
//      DlFtpStats.Remaining:=DlFtpStats.Frequency;
      DlFtpStats.StopTime:=Now;

      ULFTP.Host       := sl.Values['ul_host'];
//      UlFtpStats.Frequency  := StrToInt(sl.Values['ul_frequency']);
      UlFtpStats.TargetFile := sl.Values['ul_path'] + sl.Values['ul_file'];
      UlFtpStats.FileSize   := StrToInt(sl.Values['ul_size']);
      UlFtpStats.max := StrToInt(sl.Values['ul_max']);
      UlFtpStats.ratiomax := StrToInt(sl.Values['ul_ratiomaxul']);
//      UlFtpStats.Remaining:=UlFtpStats.Frequency;
      xPLClient.SendMessage( K_MSG_TYPE_CMND, xPLClient.PrereqList.Values['timer'], 'control.basic',
                          ['current','device','frequence'],['start','ulftp',sl.Values['ul_frequency']]);
      ULFtpStats.StopTime:=Now;
      ULCreateTempFile;

      PING.Host:=sl.Values['ping_host'];
//      PingStats.Frequency := StrToInt(sl.Values['ping_frequency']);
      PingStats.Quantity  := StrToInt(sl.Values['ping_quantity']);
      PingStats.Min := StrToInt(sl.Values['ping_min']);
      PingStats.Max := StrToInt(sl.Values['ping_max']);
      PingStats.Str := sl.Values['ping_string'];
//      PingStats.Remaining:=PingStats.Frequency;
//      UlFtpStats.Remaining:=UlFtpStats.Frequency;
      xPLClient.SendMessage( K_MSG_TYPE_CMND, xPLClient.PrereqList.Values['timer'], 'control.basic',
                          ['current','device','frequence'],['start','ping',sl.Values['ping_frequency']]);
      PingStats.StopTime:=Now;

//      BDStats.Frequency := StrToInt(sl.Values['breakdown_frequency']);
      sa := StrSplit(sl.Values['breakdown_host'],'#');
      for i:=0 to High(sa)-1 do
(*             if sa[i]<>'' then BDHosts.SetValue(sa[i],'unknown');*)
      BDStats.Quantity:=BDHosts.size;
//      BDStats.Remaining := BDStats.Frequency;
      xPLClient.SendMessage( K_MSG_TYPE_CMND, xPLClient.PrereqList.Values['timer'], 'control.basic',
                          ['current','device','frequence'],['start','bd',sl.Values['breakdown_frequency']]);
      BDStats.StopTime:=Now;
   end;
   sl.Destroy;
end;

procedure TfrmMain.ULCreateTempFile;
var i : Int64;
    fs : TFileStream;
begin
   UlFtpStats.SourceFile:= GetTempFileName(GetTempDir,K_DEFAULT_DEVICE);
   fs := TFileStream.Create(UlFtpStats.SourceFile, fmCreate);
   i := UlFtpStats.FileSize;
   Repeat
      fs.Write(random(255),sizeof(byte));
      dec(i);
   until i=0;
   fs.free;
end;


initialization
  {$I frm_main.lrs}

end.

