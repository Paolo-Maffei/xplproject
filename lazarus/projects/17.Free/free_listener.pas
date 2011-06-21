unit free_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses
  Classes, SysUtils,
  u_xpl_listener,
  u_xpl_config,
  u_xpl_actionlist,
  u_xpl_message,
  IdHTTP,
  IdIOHandlerStack,
  IdSSLOpenSSL;


type

{ TxPLfreeListener }

     TxPLfreeListener = class(TxPLListener)
     protected
        IdHTTP1: TIdHTTP;
        IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
     private
        fConnString : string;
        ts : tstringlist;
        fGlobals : TStringList;
//        fCalls : DMultiMAP;
//        fPhoneNumbers : DMAP;
        sHDBoxStatus : string;
        Stream : TMemoryStream;
        procedure IdHTTP1Redirect(Sender: TObject; var dest: string; var NumRedirect: Integer; var Handled: boolean; var VMethod: TIdHTTPMethod);
        procedure GetPhoneCalls(Sender: TObject);
        procedure OnPrereqMet;
     public
        constructor Create(const aOwner : TComponent); overload;
        destructor  Destroy; override;
        procedure   OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;
        procedure   UpdateConfig; override;
        procedure OnReceived(const axPLMsg : TxPLMessage);
        function  DownloadWaveFile(aURL : string) : string;
        procedure CollectGlobalData;
        procedure FinalizeHBeatMsg(const aMessage  : TxPLMessage; const aPort : string; const aIP : string); override;
     published
        property Globals : TStringList read fGlobals write fGlobals;
     end;

implementation
uses u_xpl_common
     , u_xpl_header
     , uRegExpr
     , u_xpl_body
     , StrUtils
     , uxPLConst
     , cStrings
     , u_xpl_custom_message
     , LResources
     ;

type TCall = class
     private
        Filename,
        From,
        Length : string;
        Recept : TDateTime;
     end;


//=====================================================================================================
const
     K_XPL_APP_VERSION_NUMBER = '0.8';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'free';
     K_DEFAULT_PORT   = '8336';

     K_CONFIG_USERNAME = 'username';
     K_CONFIG_PASSWORD = 'password';
//     K_CONFIG_MESSAGE_STORE = 'storedir';                                                 // Directory to store wav files downloaded
//     K_CONFIG_X10_FREEBOX = 'fbox-x10';
//     K_CONFIG_X10_HDBOX   = 'fboxhd-x10';
     K_CONFIG_POLLING     = 'polling';

     K_FREE_BASE_URL   = 'https://subscribes.free.fr/login/login.pl';
     K_FREE_ADSL       = 'https://adsls.free.fr/';
     K_FREE_CONSOLE    = K_FREE_ADSL + 'compte/console.pl?';                              // Page d'accueil de la console free
     K_FREE_CARTECH    = K_FREE_ADSL + 'suivi/suivi_techgrrr.pl?';                        // Page qui contient les cars tech de la ligne
     K_FREE_TEL        = K_FREE_ADSL + 'admin/tel/';
     K_FREE_TEL_NOTIFS = K_FREE_TEL  + 'notification_tel.pl?';                            // Page qui contient les notifications téléphoniques
     K_FREE_MAGNETO    = K_FREE_ADSL + 'admin/magneto.pl?';
     K_FREE_FBOX_CFG   = K_FREE_ADSL + '/admin/fbxcfg/fbxcfg.pl?';                        // Page qui contient la version de freebox et son adresse mac
     K_FREE_WIFI_CFG   = K_FREE_FBOX_CFG + '%s&tpl=wifi';                                 // Page qui contient la configuration wifi

     K_PJ_ANNUAIRE_INV = 'http://www.infobel.com/fr/france/Inverse.aspx?q=France';
     K_PJ_ANNUAIRE_RE  = 'QName=(.*?)&amp;QNum';                                          // Regex pour identifier le nom de l'abonné dans la page

     V_KF_PHONELINE = 'phoneline';
     V_KF_FREELINE = 'freeline';
     V_KF_PUBLICIP = 'publicip';
     V_KF_GATEWAY = 'gateway';
     V_KF_BOXMAC = 'boxmac';
     V_KF_BOXMODEL = 'boxmodel';
     V_KF_KEY = 'key';
     V_KF_SSID = 'ssid';

     K_GLOBALS_ARRAY : Array [0..7] of string = ( V_KF_PHONELINE,V_KF_FREELINE,V_KF_PUBLICIP,V_KF_GATEWAY,
                                                  V_KF_BOXMAC, V_KF_BOXMODEL, V_KF_KEY, V_KF_SSID);


// ===========================================================================================
{ TxPLfreeListener }
procedure TxPLfreeListener.IdHTTP1Redirect(Sender: TObject; var dest: string; var NumRedirect: Integer; var Handled: boolean; var VMethod: TIdHTTPMethod);
begin                                                                          // When connection is established using username and password
   FConnString := ExtractWord(2,dest,['?']);                                   // Free redirects us to another URL containing session id
   Log(etInfo, 'Connected to management console : %s',[FConnString]);          // something like http://adsl.free.fr/compte/console.pl?id=755252&idt=2ce4938844b2f863
end;

procedure TxPLfreeListener.FinalizeHBeatMsg(const aMessage: TxPLMessage; const aPort: string; const aIP: string);
var ch : string;
begin
  inherited FinalizeHBeatMsg(aMessage, aPort, aIP);
  for ch in fGlobals do aMessage.Body.AddKeyValue(ch);
end;


constructor TxPLfreeListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);

   fConnString := '';
   Stream := TMemoryStream.Create;
   ts := tstringlist.Create;
   fGlobals := tStringList.Create;
   fGlobals.Duplicates:=dupIgnore;
   fGlobals.Sorted:=true;
   sHDBoxStatus := '';

//   OnxPLMediaBasic     := @OnMediaBasic;
   OnxPLPrereqMet      := @OnPrereqMet;
   OnxPLReceived       := @OnReceived;
   Config.DefineItem(K_CONFIG_USERNAME,      TxPLConfigItemType.config,1);
   Config.DefineItem(K_CONFIG_PASSWORD,      TxPLConfigItemType.config,1);
//   Config.DefineItem(K_CONFIG_MESSAGE_STORE, TxPLConfigItemType.config,1);
//   Config.DefineItem(K_CONFIG_X10_FREEBOX,   TxPLConfigItemType.config,1);
//   Config.DefineItem(K_CONFIG_X10_HDBOX,     TxPLConfigItemType.config,1);
   Config.DefineItem(K_CONFIG_POLLING,       TxPLConfigItemType.config,1,'5');

   PrereqList.DelimitedText := 'timer,netget';

//   FilterSet.AddValues(['xpl-cmnd.*.*.*.db.basic']);

   IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create;
   IdHTTP1 := TIdHTTP.Create;
   with IdHTTP1 do begin
//     if xPLClient.Settings.UseProxy then begin
//        ProxyParams.ProxyServer:=xPLClient.Settings.HTTPProxSrvr;
//        ProxyParams.ProxyPort:=StrToInt(xPLClient.Settings.HTTPProxPort);
//     end;
   HandleRedirects := True;
   IOHandler := IdSSLIOHandlerSocketOpenSSL1;
   OnRedirect := @IdHTTP1Redirect;
   end;

end;

function TxPLfreeListener.DownloadWaveFile(aURL: string) : string;                                    // aURL : efface_message.pl?id=755252&idt=09cedf4158efe39c&tel=950201201&fichier=20100115_120730_r0041775873.au
var TmpFileStream : TFileStream;
begin                                                                                               // Essayé sans résultat positif de sous traiter le téléchargement du fichier à netget
//  xPLClient.SendMessage( K_MSG_TYPE_CMND, xPLClient.PrereqList.Values['netget'], K_SCHEMA_NETGET_BASIC,
//                         ['protocol','uri','destdir','destfn'],                                   // Il semble que celà pose un problème d'accréditation ou de redirection
//                         ['https',K_FREE_TEL + aURL,PathInclSuffix(xPLClient.Config.ItemName[K_CONFIG_MESSAGE_STORE].Value),StrBetween(aURL,'fichier=',K_FEXT_AU) + K_FEXT_WAV]);
  try
    result := StrBetween(aURL,'fichier=','.au') + '.wav';                                           //On crée un fichier
    TmpFileStream := TFileStream.Create(PathInclSuffix(xPLClient.Config.ItemName[K_CONFIG_MESSAGE_STORE].Value) + result, fmCreate);
    IdHTTP1.Get(K_FREE_TEL + aURL, TmpFileStream);                                                  //On enregistre les données téléchargées dans ce fichier
  finally
     FreeAndNil(TmpFileStream);
  end;
end;

procedure TxPLfreeListener.GetPhoneCalls(Sender: TObject);
var s : widestring;
    bCallPending : boolean;
    myYear, myMonth, myDay : Word;
    myHour, myMin, mySec, myMilli : Word;
    aCall : TCall;
begin
   if ((fConnString = '') or (csDestroying in ComponentState)) then exit;

   Log(etInfo,'Checking incoming calls : %s %s',[K_FREE_TEL_NOTIFS,fConnString]);
   s := IdHTTP1.Get(K_FREE_TEL_NOTIFS + fConnString);                                     // Va chercher les infos sur les appels manqués
   with TRegExpr.Create do begin
      Expression := 'message</td><td>(.*?)</td>.*?wrap>(.*?) (.*?)</td>.*?wrap>(.*?)</td>.*?href=''(.*?)''>.*?href=''(.*?)''>';
      bCallPending := Exec(s);
      while bCallPending do begin
         aCall := TCall.Create;
         aCall.Filename:=DownloadWaveFile(Match[5]);
         aCall.From    := Match[1];
         aCall.Length  := Match[4];
         aCall.Recept  := StrToDateTime(Match[3] + ' ' + Match[2]);                       // A noter : la date de réception de l'appel est aussi présente
         DecodeDateTime(aCall.Recept, myYear, myMonth, myDay, myHour, myMin, mySec, myMilli);
         fCalls.putPair([aCall.From,aCall]);                                              // Dans le nom du fichier sous la forme yyyymmdd_hhmmss
         HandlePhoneNumber(Match[1]);                                                     // Store the phone number and tries to identify it
//         DeleteWaveFile   (Match[6]);
         xPLClient.SendMessage( K_MSG_TYPE_TRIG,K_MSG_TARGET_ANY,'free.basic',
                                ['calltype','phone','length','call-date'],
                                ['inbound',aCall.From,aCall.Length,Format('%.2d%.2d%.2d%.2d',[myMonth,myDay,myHour,myMin])]);
         bCallPending := ExecNext;
      end;
   end;
   TestHDBoxState;
end;

procedure TxPLfreeListener.CollectGlobalData;
var s : widestring;
begin
   if ((fConnString = '') or (csDestroying in ComponentState)) then exit;

   s := IdHTTP1.Get(K_FREE_CARTECH + fConnString);
   with TRegExpr.Create do begin
      Expression := K_RE_FRENCH_PHONE;
      if Exec(s) then begin
         fGlobals.Add(V_KF_PHONELINE + '=' + StringReplace(Match[0],' ','',[rfReplaceAll]));
         if ExecNext then fGlobals.Add(V_KF_FREELINE + '=' + StringReplace(Match[0],' ','',[rfReplaceAll]));
      end;

      Expression := K_RE_IP_ADDRESS;
      if Exec(s) then begin
         fGlobals.Add(V_KF_PUBLICIP+ '=' + Match[0]);
         if ExecNext then fGlobals.Add(V_KF_GATEWAY+'='+Match[0]);
      end;

      s := IdHTTP1.Get(K_FREE_FBOX_CFG + fConnString);
      Expression := K_RE_MAC_ADDRESS;
      if Exec(s) then fGlobals.Add(V_KF_BOXMAC + '=' + Match[0]);
      Expression := 'de la Freebox.*?</td>.*?>(.*?)<';
      if Exec(s) then fGlobals.Add(V_KF_BOXMODEL +'=' +Match[1]);

      s := IdHTTP1.Get(Format(K_FREE_WIFI_CFG,[fConnString]));
      Expression := 'wifi_key".*?value="(.*?)"';
      if Exec(s) then fGlobals.Add(V_KF_KEY + '=' + Match[1]);

      Expression := 'wifi_ssid.*?value="(.*?)"';
      if Exec(s) then fGlobals.Add(V_KF_SSID +'='+Match[1]);

      Stream.Clear;
   end;
end;

procedure TxPLfreeListener.OnPrereqMet;
begin
//   fCalls   := DMultiMAP.Create;
//   fPhoneNumbers := DMAP.Create;

   SendMessage( cmnd, DeviceAddress('timer'), 'timer.basic',
                          ['action','device','frequence'],['start',Adresse.RawxPL,IntToStr(StrToIntDef(Config.GetItemValue(K_CONFIG_POLLING),5) * 60)]);
//   SendMessage( cmnd, DeviceAddress('nntp'), 'control.basic',
//                          ['current','device'],['start','proxad.free.annonces']);

   // Open the connection =========================================
   ts.clear;
   ts.add('login=' + Config.GetItemValue(K_CONFIG_USERNAME));
   ts.add('pass=' + Config.GetItemValue(K_CONFIG_PASSWORD));

   IdHTTP1.Post(K_FREE_BASE_URL,Ts,Stream);                                     // Try to open the connection, as soon as opened it will be redirected
   ts.Clear;
   // =============================================================
   CollectGlobalData;
   Timer1Timer(self);
end;

destructor TxPLfreeListener.Destroy;
begin
   idHTTP1.free;
//   if Assigned(fCalls) then fCalls.Free;

//   if Assigned(fPhoneNumbers) then fPhoneNumbers.Free;
   ts.Free;
   Stream.Free;
   inherited Destroy;
   if Assigned(fGlobals) then fGlobals.Free;
end;

procedure TxPLfreeListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
   if CompareText(AClassName, 'TxPLfreeListener') = 0 then ComponentClass := TxplfreeListener
   else inherited;
end;

procedure TxPLfreeListener.UpdateConfig;
var found : boolean;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin


     OnxPLReceived := @OnReceived;
  end else OnxPLReceived := nil;
end;

procedure TxPLfreeListener.OnReceived(const axPLMsg: TxPLMessage);
begin
   with axPLMsg do begin
      if (MessageType = stat) and (Schema.RawxPL = 'timer.basic') and                // Received a timer status message
         (Body.GetValueByKey('device') = Adresse.RawxPL) and                                 // from the timer I created
         (Body.GetValueByKey('current') = 'started')                                                // that says kick me
         then Timer1Timer(self)
      else
      if (MessageType = trig) and (Schema.RawxPL = 'netget.basic') and               // A result is incoming for a phone
         (Body.GetValueByKey('regexpr') = K_PJ_ANNUAIRE_RE) and                                     // number search
         (Body.GetValueByKey('current') = 'success')                                                // and it is successfull
         then begin
//            fPhoneNumbers.PutPair([Body.GetValueByKey('qphone'),Body.GetValueByKey('result')]);     // let's record it
//            self.WriteToXML;                                                                        // And save it
         end;
   end;
end;

end.

