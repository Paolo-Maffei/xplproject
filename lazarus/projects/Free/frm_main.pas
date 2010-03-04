unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  ComCtrls, Menus, ActnList, ExtCtrls, StdCtrls, Grids, EditBtn,
  Buttons,uxPLWebListener,  uxPLMessage,
  XMLPropStorage, IdCustomHTTPServer, IdHTTP, uxPLGlobals;


type

  { TfrmMain }

  TfrmMain = class(TForm)
    About: TAction;
    ActionList2: TActionList;
    IdHTTP1: TIdHTTP;
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    XMLPropStorage1: TXMLPropStorage;

    procedure AboutExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IdHTTP1Redirect(Sender: TObject; var dest: string; var NumRedirect: Integer; var Handled: boolean; var VMethod: TIdHTTPMethod);
    procedure Timer1Timer(Sender: TObject);

  private
    FConnString : string;
    fCalls     : TxPLGlobalList;
    fPhoneNumbers : TxPLGlobalList;
    sHDBoxStatus : string;
    fGlobals           : TxPLGlobalList;
    procedure AddComment(aString : string);
     Stream : TMemoryStream;
      ts     : tstringlist;
  public
    xPLClient  : TxPLWebListener;

    procedure OnJoined(const aJoined : boolean);
    procedure OnMediaBasic(const axPLMsg : TxPLMessage; const aCommand : string; const aMP : string);
    procedure LogUpdate(const aList : TStringList);
    procedure CommandGet(var aPageContent : widestring; ARequestInfo: TIdHTTPRequestInfo);
    function  DownloadWaveFile(aURL : string) : string;
    procedure DeleteWaveFile  (aURL : string);
    procedure OpenConnection;
    procedure SendInitialMessage;
    procedure HandlePhoneNumber(const aPhoneNumber : string);
    procedure TestHDBoxState;
    function  ReplaceTag (const aDevice : string; const aParam : string; aValue : string; const aVariable : string; out ReplaceString : string) : boolean;
    function  ReplaceArrayedTag(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean;
  end;

var  frmMain: TfrmMain;

implementation //======================================================================================
uses frm_about, frm_xplappslauncher,uxPLMsgHeader, cStrings, LCLType,  uRegExTools,
     uxPLConst,  DateUtils, StrUtils;

//=====================================================================================================
resourcestring
     K_XPL_APP_VERSION_NUMBER = '0.5';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'free';
     K_DEFAULT_PORT   = '8336';

     K_CONFIG_USERNAME = 'username';
     K_CONFIG_PASSWORD = 'password';
     K_CONFIG_MESSAGE_STORE = 'storedir';                                                 // Directory to store wav files downloaded
     K_CONFIG_X10_FREEBOX = 'fbox-x10';
     K_CONFIG_X10_HDBOX   = 'fboxhd-x10';
     K_CONFIG_POLLING     = 'polling';

const
     K_FREE_BASE_URL   = 'http://subscribe.free.fr/login/login.pl';
     K_FREE_ADSL       = 'http://adsl.free.fr/';
     K_FREE_CONSOLE    = K_FREE_ADSL + 'compte/console.pl?';                              // Page d'accueil de la console free
     K_FREE_CARTECH    = K_FREE_ADSL + 'suivi/suivi_techgrrr.pl?';                        // Page qui contient les cars tech de la ligne
     K_FREE_TEL        = K_FREE_ADSL + 'admin/tel/';
     K_FREE_TEL_NOTIFS = K_FREE_TEL  + 'notification_tel.pl?';                            // Page qui contient les notifications téléphoniques
     K_FREE_MAGNETO    = K_FREE_ADSL + 'admin/magneto.pl?';
     K_FREE_FBOX_CFG   = K_FREE_ADSL + '/admin/fbxcfg/fbxcfg.pl?';                        // Page qui contient la version de freebox et son adresse mac
     K_FREE_WIFI_CFG   = K_FREE_FBOX_CFG + '%s&tpl=wifi';                                   // Page qui contient la configuration wifi

     K_PJ_ANNUAIRE_INV = 'http://www.infobel.com/fr/france/Inverse.aspx?q=France';

//=====================================================================================================
function StreamToString(Stream : TStream) : String;
var ms : TMemoryStream;
begin
  Result := '';
  ms := TMemoryStream.Create;
  try
    ms.LoadFromStream(Stream);
    SetString(Result,PChar(ms.memory),ms.Size);
  finally
    ms.free;
  end;
end;

procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.OnJoined(const aJoined: boolean);
begin
   if xPLClient.AwaitingConfiguration then exit;

   fCalls.ReadFromXML(xPLClient.Config.XmlFile,'Calls');
   fPhoneNumbers.ReadFromXML(xPLClient.Config.XmlFile,'PhoneNumbers');
   fGlobals.ReadFromXML(xPLClient.Config.XmlFile,'Globals');
   OpenConnection;
   SendInitialMessage;
   Timer1.Interval := StrToIntDef(xPLClient.Config.ItemName[K_CONFIG_POLLING].Value,5) * 1000 * 60;          // poll frequency setup
   Timer1.Enabled:=true;
end;

procedure TfrmMain.AddComment(aString: string);
begin xPLClient.LogInfo(aString); end;

procedure TfrmMain.DeleteWaveFile(aURL: string);
begin IdHTTP1.Get(K_FREE_TEL + aURL); end;

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

procedure TfrmMain.LogUpdate(const aList: TStringList);
begin
  Memo1.Lines.Add(aList[aList.Count-1]);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   fCalls.Destroy;
   fPhoneNumbers.Destroy;
   fGlobals.Destroy;
   xPLClient.Destroy;
   ts.Destroy;
   Stream.Destroy;
end;

procedure TfrmMain.FormCreate(Sender: TObject);

procedure initListener;
begin
   xPLClient := TxPLWebListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER, K_DEFAULT_PORT);
   with xPLClient do begin
       OnxPLJoinedNet    := @OnJoined;
       OnCommandGet      := @CommandGet;
       OnxPLMediaBasic   := @OnMediaBasic;
       OnLogUpdate       := @LogUpdate;
       OnReplaceTag      := @ReplaceTag;
       OnReplaceArrayedTag := @ReplaceArrayedTag;
       Config.AddItem(K_CONFIG_USERNAME, xpl_ctConfig);
       Config.AddItem(K_CONFIG_PASSWORD, xpl_ctConfig);
       Config.AddItem(K_CONFIG_MESSAGE_STORE, xpl_ctConfig);
       Config.AddItem(K_CONFIG_X10_FREEBOX, xpl_ctConfig);
       Config.AddItem(K_CONFIG_X10_HDBOX, xpl_ctConfig);
       Config.AddItem(K_CONFIG_POLLING, xpl_ctConfig,'5');
   end;

   xPLClient.Listen;
end;

begin
   fConnString := '';
   Stream := TMemoryStream.Create;
   ts := tstringlist.Create;
   fCalls:= TxPLGlobalList.Create;
   fPhoneNumbers := TxPLGlobalList.Create;
   fGlobals := TxPLGlobalList.Create;
   sHDBoxStatus := '';
   InitListener;
   Self.Caption := xPLClient.AppName;
   Self.Icon    := Application.Icon ;
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

function TfrmMain.ReplaceTag(const aDevice : string; const aParam : string; aValue : string; const aVariable : string; out ReplaceString : string) : boolean;
var i : integer;
begin
   if aDevice <> K_DEFAULT_DEVICE then exit;        // This isn't for me
   ReplaceString := '';

   For i:=0 to fGlobals.Count-1 do
       if aVariable = fGlobals[i] then ReplaceString := fGlobals.GetValue(i);
   Result := ReplaceString<>'';
end;

function TfrmMain.ReplaceArrayedTag(const aDevice: string; const aValue : string; const aVariable: string; ReturnList: TStringList): boolean;
var i : integer;
    numero, appelant : string;
begin
   if aDevice<>K_DEFAULT_DEVICE then exit;
   ReturnList.Clear;

   if aVariable = 'callfrom'   then for i:=0 to fCalls.Count-1 do begin
                                        numero := fCalls.GetValue(i);
                                        appelant := fPhoneNumbers.GetValue(numero);
                                        if appelant<>'' then ReturnList.Add(Appelant + ' (' + numero +')')
                                                        else ReturnList.Add(numero);
                                        end
   else if aVariable = 'calldate'   then for i:=0 to fCalls.Count-1 do ReturnList.Add(DateTimeToStr(TxPLGlobalValue(fCalls.Objects[i]).CreateTS))
   else if aVariable = 'calllength' then for i:=0 to fCalls.Count-1 do ReturnList.Add(TxPLGlobalValue(fCalls.Objects[i]).Comment)
   else if aVariable = 'callname'   then for i:=0 to fCalls.Count-1 do ReturnList.Add(fCalls[i])
   else if aVariable = 'pn_number'  then for i:=0 to fPhoneNumbers.Count-1 do begin if ((aValue='') or (aValue=fPhoneNumbers[i])) then ReturnList.Add(fPhoneNumbers[i]); end
   else if aVariable = 'pn_contact' then for i:=0 to fPhoneNumbers.Count-1 do begin if ((aValue='') or (aValue=fPhoneNumbers[i])) then ReturnList.Add(fPhoneNumbers.GetValue(i)); end;

   result := (ReturnList.Count >0);
end;

procedure TfrmMain.CommandGet(var aPageContent: widestring; ARequestInfo: TIdHTTPRequestInfo);
var i : integer;
    bHandeld : boolean;
begin
   bHandeld  := false;

   Case AnsiIndexStr(AnsiLowerCase(ARequestInfo.Params.Values['Submit']),['delete_call','delete_pn','change name']) of
        0 : begin
            i := fCalls.IndexOf(ARequestInfo.Params.Values['free_callname']);
            if i<>-1 then begin
               DeleteFile(xPLClient.Config.ItemName[K_CONFIG_MESSAGE_STORE].Value + ARequestInfo.Params.Values['free_callname']);
               fCalls.Delete(ARequestInfo.Params.Values['free_callname']);
            end;
            bHandeld := True;
            end;
        1 : begin
            fPhoneNumbers.Delete(ARequestInfo.Params.Values['pn_number']);
            bHandeld := True;
            end;
        2 : begin
            fPhoneNumbers.SetValue(ARequestInfo.Params.Values['pn_number'],ARequestInfo.Params.Values['pn_contact']);
            bHandeld := True;
            end;
   end;
   if bHandeld then ARequestInfo.Params.Clear;
end;


procedure TfrmMain.SendInitialMessage;
var s        : widestring;
    i        : integer;
begin
   if ((fConnString = '') or (xPLClient.Disposing)) then exit;

   with xPLClient.PrepareMessage(xpl_mtStat,'free.basic') do try

        s := IdHTTP1.Get(K_FREE_CARTECH + fConnString);

        RegExpEngine.Expression := K_RE_FRENCH_PHONE;
        if RegExpEngine.Exec(s) then begin
           fGlobals.SetValue('phoneline',StrRemoveChar(RegExpEngine.Match[0],chSpace));
           if RegExpEngine.ExecNext then fGlobals.SetValue('freeline',StrRemoveChar(RegExpEngine.Match[0],chSpace));
        end;

        RegExpEngine.Expression := K_RE_IP_ADDRESS;
        if RegExpEngine.Exec(s) then begin
           fGlobals.SetValue('publicip',RegExpEngine.Match[0]);
           if RegExpEngine.ExecNext then
              fGlobals.SetValue('gateway',RegExpEngine.Match[0]);
        end;

        s := IdHTTP1.Get(K_FREE_FBOX_CFG + fConnString);
        RegExpEngine.Expression := K_RE_MAC_ADDRESS;
        if RegExpEngine.Exec(s) then         fGlobals.SetValue('boxmac',RegExpEngine.Match[0]);
        RegExpEngine.Expression := 'de la Freebox.*?</td>.*?>(.*?)<';
        if RegExpEngine.Exec(s) then fGlobals.SetValue('boxmodel',RegExpEngine.Match[1]);

        s := IdHTTP1.Get(Format(K_FREE_WIFI_CFG,[fConnString]));
        RegExpEngine.Expression := 'wifi_key".*?value="(.*?)"';
        if RegExpEngine.Exec(s) then         fGlobals.SetValue('key',RegExpEngine.Match[1]);

        RegExpEngine.Expression := 'wifi_ssid.*?value="(.*?)"';
        if RegExpEngine.Exec(s) then         fGlobals.SetValue('ssid',RegExpEngine.Match[1]);

        For i:=0 to fGlobals.Count-1 do
            Body.AddKeyValuePair(fGlobals[i],fGlobals.GetValue(i));

        send;
        stream.Clear;
   finally
        Destroy;
   end;
end;

procedure TfrmMain.HandlePhoneNumber(const aPhoneNumber: string);
begin
     fPhoneNumbers.SetValue(aPhoneNumber,'*** unknown ***');
     ts.add('qPhone=' + aPhoneNumber);
     IdHTTP1.Post(K_PJ_ANNUAIRE_INV,Ts,Stream);
     RegExpEngine.Expression := 'QName=(.*?)&amp;QNum';
     if RegExpEngine.Exec(StreamToString(Stream)) then begin
        fPhoneNumbers.SetValue(aPhoneNumber,RegExpEngine.Match[1]);
     end;
     Stream.Clear;
     ts.Clear;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
var s : widestring;
    filename : string;
    bCallPending : boolean;
    myDate : TDateTime;
    myYear, myMonth, myDay : Word;
    myHour, myMin, mySec, myMilli : Word;
begin
   if ((fConnString = '') or (xPLClient.Disposing)) then exit;
   OpenConnection;
   s := IdHTTP1.Get(K_FREE_TEL_NOTIFS + fConnString);                                     // Va chercher les infos sur les appels manqués
   RegExpEngine.Expression := 'message</td><td>(.*?)</td>.*?wrap>(.*?) (.*?)</td>.*?wrap>(.*?)</td>.*?href=''(.*?)''>.*?href=''(.*?)''>';
   bCallPending := RegExpEngine.Exec(s);
   if bCallPending then begin
      myDate := StrToDateTime(RegExpEngine.Match[3] + ' ' + RegExpEngine.Match[2]);
      DecodeDateTime(myDate, myYear, myMonth, myDay, myHour, myMin, mySec, myMilli);
      filename := DownloadWaveFile(RegExpEngine.Match[5]);
      fCalls.SetValue(filename,RegExpEngine.Match[1],RegExpEngine.Match[4]);              // Store information about the record (filename, call from, call length)
      HandlePhoneNumber(RegExpEngine.Match[1]);                                           // Store the phone number and tries to identify it
      DeleteWaveFile   (RegExpEngine.Match[6]);
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

function TfrmMain.DownloadWaveFile(aURL: string) : string;                                // aURL : efface_message.pl?id=755252&idt=09cedf4158efe39c&tel=950201201&fichier=20100115_120730_r0041775873.au
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
begin
   ts.add('login=' + xPLClient.Config.ItemName[K_CONFIG_USERNAME].Value);
   ts.add('pass=' + xPLClient.Config.ItemName[K_CONFIG_PASSWORD].Value);

   IdHTTP1.Post(K_FREE_BASE_URL,Ts,Stream);
   ts.Clear;
end;



initialization
  {$I frm_main.lrs}

end.

