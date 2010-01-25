unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  ComCtrls, Menus, ActnList, ExtCtrls, StdCtrls, Grids, EditBtn,
  Buttons,uxPLWebListener, uxPLConfig,  uxPLMessage,
  XMLPropStorage, IdCustomHTTPServer, IdHTTP, uxPLGlobals;


type

  { TfrmMain }

  TfrmMain = class(TForm)
    About: TAction;
    acInstalledApps: TAction;
    ActionList2: TActionList;
    IdHTTP1: TIdHTTP;
    Memo1: TMemo;
    MenuItem2: TMenuItem;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    Timer1: TTimer;
    XMLPropStorage1: TXMLPropStorage;

    procedure AboutExecute(Sender: TObject);
    procedure acInstalledAppsExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IdHTTP1Redirect(Sender: TObject; var dest: string; var NumRedirect: Integer; var Handled: boolean; var VMethod: TIdHTTPMethod);
    procedure Timer1Timer(Sender: TObject);

  private
    FConnString : string;
    fCalls     : TxPLGlobalList;
    sHDBoxStatus : string;
    sPhoneLine, sFreeLine, sfBoxPublic, sfBoxInternal, sfBoxMac, sfBoxModel : string;
    procedure AddComment(aString : string);
     Stream : TMemoryStream;
      ts     : tstringlist;
  public
    xPLClient  : TxPLWebListener;

    procedure OnJoined(const aJoined : boolean);
    procedure OnConfigDone(const fConfig : TxPLConfig);
    procedure OnMediaBasic(const axPLMsg : TxPLMessage; const aCommand : string; const aMP : string);
    procedure CommandGet(var aPageContent : widestring; aParam, aValue : string);
    function  DownloadWaveFile(aURL : string) : string;
    procedure DeleteWaveFile  (aURL : string);
    procedure OpenConnection;
    procedure SendInitialMessage;
    procedure TestHDBoxState;
  end;

var  frmMain: TfrmMain;

implementation //======================================================================================
uses frm_about, frm_xplappslauncher,uxPLCfgItem,uxPLMsgHeader, cStrings, LCLType,  uRegExTools,
     uxPLConst,  DateUtils, StrUtils;

//=====================================================================================================
resourcestring
     K_XPL_APP_VERSION_NUMBER = '0.1';
     K_XPL_APP_NAME = 'xPL Free';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'free';
     K_DEFAULT_PORT   = '8336';

     K_CONFIG_USERNAME = 'username';
     K_CONFIG_PASSWORD = 'password';
     K_CONFIG_MESSAGE_STORE = 'storedir';                                                    // Directory to store wav files downloaded
     K_CONFIG_X10_FREEBOX = 'fbox-x10';
     K_CONFIG_X10_HDBOX   = 'fboxhd-x10';
     K_CONFIG_POLLING     = 'polling';

const
     K_FREE_BASE_URL   = 'http://subscribe.free.fr/login/login.pl';
     K_FREE_ADSL       = 'http://adsl.free.fr/';
     K_FREE_CONSOLE    = K_FREE_ADSL + 'compte/console.pl?';                                 // Page d'accueil de la console free
     K_FREE_CARTECH    = K_FREE_ADSL + 'suivi/suivi_techgrrr.pl?';                           // Page qui contient les cars tech de la ligne
     K_FREE_TESTDEB    = 'http://adsl.free.fr/ptpl.pl?tpl=/compte/testdebit.html&';                          // Page pour le test de débit
     K_FREE_TEL        = K_FREE_ADSL + 'admin/tel/';
     K_FREE_TEL_NOTIFS = K_FREE_TEL  + 'notification_tel.pl?';                               // Page qui contient les notifications téléphoniques
     K_FREE_MAGNETO    = K_FREE_ADSL + 'admin/magneto.pl?';
     K_FREE_FBOX_CFG   = K_FREE_ADSL + '/admin/fbxcfg/fbxcfg.pl?';                           // Page qui contient la version de freebox et son adresse mac

//=====================================================================================================
procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.acInstalledAppsExecute(Sender: TObject);
begin frmAppLauncher.Show; end;

procedure TfrmMain.OnJoined(const aJoined: boolean);
begin AddComment(Format(K_MSG_HUB_FOUND,['is'])); end;

procedure TfrmMain.AddComment(aString: string);
begin Memo1.Append(aString); end;

procedure TfrmMain.DeleteWaveFile(aURL: string);
begin IdHTTP1.Get(K_FREE_TEL + aURL); end;

procedure TfrmMain.OnConfigDone(const fConfig: TxPLConfig);
begin
     AddComment(Format(K_MSG_CONFIGURED,['done']));
     fCalls.ReadFromXML(xPLClient.Config.XmlFile,'Calls');
     OpenConnection;
     SendInitialMessage;

     Timer1.Interval := StrToIntDef(xPLClient.Config.ItemName[K_CONFIG_POLLING].Value,5) * 1000 * 60;          // poll frequency setup
     Timer1.Enabled:=true;
end;

procedure TfrmMain.OnMediaBasic(const axPLMsg: TxPLMessage; const aCommand: string; const aMP: string);
var x10_address : string;
begin
     x10_address := xPLClient.Config.ItemName[aMP + '-x10'].Value;
     if x10_address = '' then exit;

     if aCommand = 'power' then begin
        with xPLClient.PrepareMessage(xpl_mtCmnd,K_SCHEMA_X10_BASIC) do try
            Body.AddKeyValuePair('command', axPLMsg.Body.GetValueByKey('state'));
            Body.AddKeyValuePair('device', x10_address);
            Send;
        finally
            Destroy;
        end;
     end;
     if aCommand = 'reboot' then begin

     end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   fCalls.WriteToXML;
   fCalls.Destroy;
   xPLClient.Destroy;
   ts.Destroy;
   Stream.Destroy;
end;

procedure TfrmMain.FormCreate(Sender: TObject);

procedure initListener;
begin
   xPLClient := TxPLWebListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_NAME,K_XPL_APP_VERSION_NUMBER, K_DEFAULT_PORT);
   with xPLClient do begin
       OnxPLJoinedNet    := @OnJoined;
       OnxPLConfigDone   := @OnConfigDone;
       OnCommandGet      := @CommandGet;
       OnxPLMediaBasic   := @OnMediaBasic;
       Config.AddItem(K_CONFIG_USERNAME, xpl_ctConfig);
       Config.AddItem(K_CONFIG_PASSWORD, xpl_ctConfig);
       Config.AddItem(K_CONFIG_MESSAGE_STORE, xpl_ctConfig);
       Config.AddItem(K_CONFIG_X10_FREEBOX, xpl_ctConfig);
       Config.AddItem(K_CONFIG_X10_HDBOX, xpl_ctConfig);
       Config.AddItem(K_CONFIG_POLLING, xpl_ctConfig,'5');
   end;

   OnJoined(False);
   xPLClient.Listen;
end;

begin
   Self.Caption := K_XPL_APP_NAME;
   fConnString := '';
   Stream := TMemoryStream.Create;
   ts := tstringlist.Create;
   fCalls:= TxPLGlobalList.Create;
   sHDBoxStatus := '';
   InitListener;
end;

procedure TfrmMain.IdHTTP1Redirect(Sender: TObject; var dest: string; var NumRedirect: Integer; var Handled: boolean; var VMethod: TIdHTTPMethod);
var foo :  string;
begin                                                                  // When connection is established using username and password
   if StrSplitAtChar(dest,'?',foo,FConnString) then begin              // Free redirects us to another URL containing session id
      AddComment('Connected to management console : ' + FConnString);  // something like http://adsl.free.fr/compte/console.pl?id=755252&idt=2ce4938844b2f863
   end;
end;

procedure TfrmMain.TestHDBoxState;
var NewStatus : string;
    s         : widestring;
begin
   s:= IdHTTP1.Get(K_FREE_MAGNETO + fConnString + '&liste=1');
   NewStatus := IfThen(AnsiContainsText(s,'Le boitier HD ne répond pas'),'on','off');
   if sHDBoxStatus<>NewStatus then begin
      with xPLClient.PrepareMessage(xpl_mtTrig,'media.devstate') do try
         Body.AddKeyValuePair('power', NewStatus);
         Body.AddKeyValuePair('connected', IfThen(newstatus='on','true','false'));
         Send;
         sHDBoxStatus := NewStatus;
      finally
         Destroy;
      end;
   end;
end;

procedure TfrmMain.SendInitialMessage;
var s        : widestring;
    //i : integer;
begin
   if ((fConnString = '') or (xPLClient.Disposing)) then exit;

   with xPLClient.PrepareMessage(xpl_mtStat,'free.basic') do try
        s := IdHTTP1.Get(K_FREE_CARTECH + fConnString);

        RegExpEngine.Expression := K_RE_FRENCH_PHONE;
        if RegExpEngine.Exec(s) then begin
           sPhoneLine := StrRemoveChar(RegExpEngine.Match[0],chSpace);
           if RegExpEngine.ExecNext then
              sFreeLine := StrRemoveChar(RegExpEngine.Match[0],chSpace);
           Body.AddKeyValuePair('freeline',sFreeLine);
           Body.AddKeyValuePair('phoneline',sPhoneLine);
        end;

        RegExpEngine.Expression := K_RE_IP_ADDRESS;
        if RegExpEngine.Exec(s) then begin
           sfBoxPublic := RegExpEngine.Match[0];
           if RegExpEngine.ExecNext then
              sfBoxInternal := RegExpEngine.Match[0];
           Body.AddKeyValuePair('fbox-public',sfBoxPublic);
           Body.AddKeyValuePair('fbox-internal',sfBoxInternal);
        end;

        s := IdHTTP1.Get(K_FREE_FBOX_CFG + fConnString);
        RegExpEngine.Expression := K_RE_MAC_ADDRESS;
        if RegExpEngine.Exec(s) then sfBoxMac := RegExpEngine.Match[0];
        Body.AddKeyValuePair('fbox-mac',sfBoxMac);

        RegExpEngine.Expression := 'de la Freebox.*?</td>.*?>(.*?)<';
        if RegExpEngine.Exec(s) then sfBoxModel := RegExpEngine.Match[1];
        Body.AddKeyValuePair('fbox-model',sfBoxModel);
        stream.Clear;
   finally
        Destroy;
   end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
var s : widestring;
    filename : string;
    //,scalldate,scalllength,scalldelete,scalldownload : string;
    bCallPending : boolean;
    myDate : TDateTime;
    myYear, myMonth, myDay : Word;
    myHour, myMin, mySec, myMilli : Word;
begin
   if ((fConnString = '') or (xPLClient.Disposing)) then exit;

   s := IdHTTP1.Get(K_FREE_TEL_NOTIFS + fConnString);                                // Va chercher les infos sur les appels manqués
   RegExpEngine.Expression := 'message</td><td>(.*?)</td>.*?wrap>(.*?) (.*?)</td>.*?wrap>(.*?)</td>.*?href=''(.*?)''>.*?href=''(.*?)''>';
   bCallPending := RegExpEngine.Exec(s);
   if bCallPending then begin
      myDate := StrToDateTime(RegExpEngine.Match[3] + ' ' + RegExpEngine.Match[2]);
      DecodeDateTime(myDate, myYear, myMonth, myDay, myHour, myMin, mySec, myMilli);
      filename := DownloadWaveFile(RegExpEngine.Match[5]);
      fCalls.SetValue(filename,RegExpEngine.Match[1],RegExpEngine.Match[4]);        // Store information about the record (filename, call from, call length)
      DeleteWaveFile  (RegExpEngine.Match[6]);
      with xPLClient.PrepareMessage(xpl_mtTrig,'free.basic') do try
         Body.AddKeyValuePair('calltype' , 'inbound');
         Body.AddKeyValuePair('phone'    , RegExpEngine.Match[1]);
         Body.AddKeyValuePair('length'   , RegExpEngine.Match[4]);
         Body.AddKeyValuePair('call-date', Format('%.2d%.2d%.2d%.2d',[myMonth,myDay,myHour,myMin]));
         Send;
      finally
         Destroy;
      end;
      bCallPending := RegExpEngine.ExecNext;
   end;
   TestHDBoxState;
end;


procedure TfrmMain.CommandGet(var aPageContent: widestring; aParam, aValue: string);
procedure ReplaceVariables(var aText : widestring);
begin
   HtmlReplaceVar( ['free_phoneline', 'free_freeline', 'free_publicip', 'free_gateway', 'free_boxmac', 'free_boxmodel'],
                   [sPhoneLine      , sFreeLine      , sfBoxPublic    , sfBoxInternal , sfBoxMac     , sfBoxModel     ],
                   aText);
end;

procedure LoopOnTemplate(var aPageContent : widestring; aParam, aValue : string);
var
  Pattern : string;
  sOut    : widestring;
  Where   : integer;
  i       : integer;
  item    : string;
  globale : TxPLGlobalValue;
begin
   if aParam='delete' then begin
      i := fCalls.IndexOf(aValue);
      if i<>-1 then begin
         DeleteFile(xPLClient.Config.ItemName[K_CONFIG_MESSAGE_STORE].Value + aValue);
         fCalls.Delete(i);
      end;
   end;

   Pattern := StrBetween(aPageContent,K_WEB_TEMPLATE_BEGIN,K_WEB_TEMPLATE_END);
   if (AnsiPos('{%free_call', Pattern)<>0) then begin                                           // here is a pattern we must handle
        Where  := AnsiPos(K_WEB_TEMPLATE_BEGIN, aPageContent);                                   // Locate where it begins
        Delete(aPageContent,Where,length(K_WEB_TEMPLATE_END + K_WEB_TEMPLATE_BEGIN +Pattern));   // Delete it to avoid being processed by another
        i := fCalls.Count -1;
        while(i>=0) do begin
           item := fCalls[i];
           if (aValue=item) or (aValue='') then begin
              sOut := Pattern;
              globale := TxPLGlobalValue(fCalls.Objects[i]);
              HtmlReplaceVar( ['free_callfrom', 'free_calldate', 'free_calllength', 'free_callname'],
                              [globale.Value           , DateTimeToStr(globale.CreateTS),globale.Comment, item], sOut);
              Insert(sOut,aPageContent,Where);
              Where += length(sOut);
           end;
           dec(i);
        end;
   end;
end;

begin
     ReplaceVariables(aPageContent);
     LoopOnTemplate(aPageContent,aParam,aValue);
end;

function TfrmMain.DownloadWaveFile(aURL: string) : string;                       // aURL : efface_message.pl?id=755252&idt=09cedf4158efe39c&tel=950201201&fichier=20100115_120730_r0041775873.au
var TmpFileStream : TFileStream;
begin
  try
    result := StrBetween(aURL,'fichier=','.au') + '.wav';                                 //On crée un fichier
    TmpFileStream := TFileStream.Create(xPLClient.Config.ItemName[K_CONFIG_MESSAGE_STORE].Value + result, fmCreate);              //On enregistre les données téléchargées dans ce fichier
    IdHTTP1.Get(K_FREE_TEL + aURL, TmpFileStream);
  finally
    FreeAndNil(TmpFileStream);
  end;
end;

procedure TfrmMain.OpenConnection;
const chaine = 'Connection to Free ADSL Service %s';
begin
   ts.add('login=' + xPLClient.Config.ItemName[K_CONFIG_USERNAME].Value);
   ts.add('pass=' + xPLClient.Config.ItemName[K_CONFIG_PASSWORD].Value);

   try
     IdHTTP1.Post(K_FREE_BASE_URL,Ts,Stream);
     AddComment(Format(chaine,['done']));
   except
     AddComment(Format(chaine,['in error']));
   end;
   ts.Clear;
end;



initialization
  {$I frm_main.lrs}

end.

