unit frm_main;

{$mode objfpc}{$H+}

// Détail du protocole Grenouille : http://wiki.grenouille.com/index.php/Projet_Technique#Commande_post_dl_ftp

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, ComCtrls,
  Menus, ActnList, ExtCtrls, StdCtrls, Grids, EditBtn, Buttons, uxPLListener, uxPLMessage,
   IdCustomHTTPServer, IdHTTP, IdMessage, IdIOHandlerStack,
  IdSSLOpenSSL, IdFTP, IdComponent,  IdAntiFreeze;

type
  TFtpRecord = record
     Remaining : integer;
     Frequency : integer;
     StartTime : TDateTime;
     StopTime  : TDateTime;
     SourceFile: string;
     TargetFile: string;
     FileSize  : Int64;
     max       : Int64;
     ratiomax : Int64;
     bandwidth  : Extended;
  end;

  { TfrmMain }

  TfrmMain = class(TForm)
    DLFTP: TIdFTP;
    IdAntiFreeze1: TIdAntiFreeze;
    StatusBar1: TStatusBar;
    ULFTP: TIdFTP;
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;

    procedure AboutExecute(Sender: TObject);

    procedure DLFTPAfterGet(ASender: TObject; AStream: TStream);
    procedure DLFTPDisconnected(Sender: TObject);
    procedure DLFTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure DLTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
//    procedure FormDestroy(Sender: TObject);
    procedure ULFTPAfterPut(Sender: TObject);
    procedure ULFTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure ULTimerTimer(Sender: TObject);
  private
    DlFtpStats : TFtpRecord;
    UlFtpStats : TFtpRecord;
    procedure AddComment(aString : string);

  public
    xPLClient  : TxPLListener;

//    procedure OnJoined(const aJoined : boolean);

    procedure LogUpdate(const aList : TStringList);
    procedure OpenConnection;
    procedure OnReceiveMsg(const axPLMsg : TxPLMessage);
  end;

var  frmMain: TfrmMain;

implementation //======================================================================================
uses frm_about,  LCLType,  uRegExTools, RegExpr, IdFTPCommon, uxPLConst,  DateUtils, cDateTime;

//=====================================================================================================
const
     K_XPL_APP_VERSION_NUMBER = '0.1';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'ftp';

     K_DL_MSG_START = 'Download : downloading %s on %s at %s';
     K_UL_MSG_START = 'Upload  : uploading %s on %s at %s';
     K_DL_MSG_ERROR = 'Download : unable to open connection to %s';
     K_UL_MSG_ERROR = 'Upload : unable to open connection to %s';
     K_DL_MSG_STOP  = '   finished downloading %s - filesize : %u bytes at %s, speed : %n';
     K_UL_MSG_STOP  = '   finished uploading %s - filesize : %u bytes at %s, speed : %n';
//=====================================================================================================
procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.AddComment(aString: string);
begin xPLClient.LogInfo(aString,[]); end;

procedure TfrmMain.LogUpdate(const aList: TStringList);
begin Memo1.Lines.Add(aList[aList.Count-1]); end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
   xPLClient := TxPLListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER, False);
   with xPLClient do begin
       OnxPLReceived := @OnReceiveMsg;
       OnLogUpdate   := @LogUpdate;
   end;

   xPLClient.Listen;
   Self.Caption := xPLClient.AppName;
   Self.Icon    := Application.Icon ;
end;

procedure TfrmMain.OnReceiveMsg(const axPLMsg: TxPLMessage);
var sens : string;
    fromFile : string;
    toFile   : string;
    username : string;
    password : string;
begin
   with axPLMsg do begin
        if MessageType <> K_MSG_TYPE_CMND then exit;
        if Schema.Tag  <> 'ftp.basic' then exit;
        fromFile := Body.GetValueByKey('from');
        toFile   := Body.GetValueByKey('to');
        username := Body.GetValueByKey('username','anonymous');
        password := Body.GetValueByKey('password','xplftp');
   end;
end;

// DOWNLOAD TEST PROCEDURES ==============================================================
procedure TfrmMain.DLTimerTimer(Sender: TObject);
begin
   DlFtpStats.Remaining  := 0;
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
      DLFtpStats.Remaining:=DLFtpStats.Frequency;
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
   DlFtpStats.Remaining := DlFtpStats.Frequency;
   DlFtpStats.FileSize  := AStream.Size;

   DlFtpStats.bandwidth := (DlFtpStats.FileSize / DiffMilliSeconds(DlFtpStats.StartTime, DlFtpStats.StopTime)) * 1000 / 1024;
   If DlFtpStats.bandwidth > DlFtpStats.max then DlFtpStats.bandwidth := -1;
   xPLClient.LogInfo(K_DL_MSG_STOP,[DlFtpStats.SourceFile,DlFtpStats.FileSize,DateTimeToStr(DlFtpStats.StopTime), DlFtpStats.bandwidth]);

   aMessage := xPLClient.PrepareMessage(K_MSG_TYPE_TRIG,'');
   aMessage.Body.Format_SensorBasic('download','flow', FloatToStr(Round(DlFtpStats.bandwidth)));
   aMessage.Body.AddKeyValuePair('highest', IntToStr(DlFtpStats.Max));
   aMessage.Body.AddKeyValuePair('units','kb/s');
   aMessage.Send ;
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
   UlFtpSTats.Remaining:=0;
   if not ULFTP.Connected then ULFTP.Connect;
   if ULFTP.Connected then begin
         ULFtp.Put(UlFtpStats.SourceFile,UlFtpStats.TargetFile);
   end else begin
      xPLClient.LogError(K_UL_MSG_ERROR,[ULFTP.Host]);
      UlFtpStats.StopTime := Now;
      UlFtpStats.Remaining:=UlFtpStats.Frequency;
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
   UlFtpStats.Remaining:=UlFtpStats.Frequency;
   ULFtpStats.bandwidth := (ULFtpStats.FileSize / DiffMilliSeconds(ULFtpStats.StartTime, ULFtpStats.StopTime)) * 1000 / 1024;
   If ULFtpStats.bandwidth > ULFtpStats.max then ULFtpStats.bandwidth := -1;

   aMessage := xPLClient.PrepareMessage(K_MSG_TYPE_TRIG,'');
   aMessage.Body.Format_SensorBasic('upload','flow', FloatToStr(Round(ULFtpStats.bandwidth)));
   aMessage.Body.AddKeyValuePair('highest', IntToStr(ULFtpStats.Max));
   aMessage.Body.AddKeyValuePair('units','kb/s');
   aMessage.Send ;
   aMessage.Destroy;

   ULFTP.Disconnect(True);
   xPLClient.LogInfo(K_UL_MSG_STOP,[UlFtpStats.SourceFile,UlFtpStats.FileSize,DateTimeToStr(UlFtpStats.StopTime), UlFtpStats.bandwidth]);
end;

// Web server management procedures =====================================================
{procedure TfrmMain.OnJoined(const aJoined: boolean);
begin
   if xPLClient.AwaitingConfiguration then exit;
   xPLClient.PassMyOwnMessages:=True;

   DLFTP.Username   := 'anonymous';
   DLFTP.Password   := 'ano@nymous.com';
   DLFTP.Passive    := true;
   DLFTP.TransferType:=ftBinary;

   ULFTP.Username   := DLFTP.Username;
   ULFTP.Password   := DLFTP.Password;
   ULFTP.Passive    := true;
   ULFTP.TransferType:=ftBinary;

   OpenConnection;
end;}


{procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   if FileExists(UlFtpStats.SourceFile) then DeleteFile(UlFtpStats.SourceFile);
   xPLClient.Destroy;
end;}

procedure TfrmMain.OpenConnection;
begin
{         DLFTP.Host       := sl.Values['dl_host'];
         DlFtpStats.Frequency := StrToInt(sl.Values['dl_frequency']);
         DlFtpStats.SourceFile := sl.Values['dl_path'] + sl.Values['dl_file'];
         DlFtpStats.max := StrToInt(sl.Values['dl_max']);
         DlFtpStats.ratiomax := StrToInt(sl.Values['dl_ratiomaxdl']);
         DlFtpStats.Remaining:=DlFtpStats.Frequency;
         DlFtpStats.StopTime:=Now;

         ULFTP.Host       := sl.Values['ul_host'];
         UlFtpStats.Frequency  := StrToInt(sl.Values['ul_frequency']);
         UlFtpStats.TargetFile := sl.Values['ul_path'] + sl.Values['ul_file'];
         UlFtpStats.FileSize   := StrToInt(sl.Values['ul_size']);
         UlFtpStats.max := StrToInt(sl.Values['ul_max']);
         UlFtpStats.ratiomax := StrToInt(sl.Values['ul_ratiomaxul']);
         UlFtpStats.Remaining:=UlFtpStats.Frequency;
         ULFtpStats.StopTime:=Now;
         ULCreateTempFile;}
end;



initialization
  {$I frm_main.lrs}

end.

