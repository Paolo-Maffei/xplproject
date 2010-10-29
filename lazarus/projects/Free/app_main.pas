unit app_main;

{$i compiler.inc}

interface

uses
  Classes, SysUtils,
  CustApp,
  uxPLMessage,
  uxPLMsgBody,
  uxPLWebListener,
  IdCustomHTTPServer,
  IdHTTP,
  IdMessage,
  Decal,
  IdIOHandlerStack,
  IdSSLOpenSSL;

type

{ TMyApplication }

  TMyApplication = class(TCustomApplication)
     protected
        IdHTTP1: TIdHTTP;
        IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
     private
        fConnString : string;
        ts : tstringlist;
        fGlobals : DMAP;
        fCalls : DMultiMAP;
        fPhoneNumbers : DMAP;
        sHDBoxStatus : string;
        Stream : TMemoryStream;
        procedure IdHTTP1Redirect(Sender: TObject; var dest: string; var NumRedirect: Integer; var Handled: boolean; var VMethod: TIdHTTPMethod);
        procedure Timer1Timer(Sender: TObject);
        procedure ReadFromXML;
        procedure WriteToXML;
     public
        constructor Create(TheOwner: TComponent); override;
        procedure OnMediaBasic(const axPLMsg : TxPLMessage; const aCommand : string; const aMP : string);
        procedure OnReceived(const axPLMsg : TxPLMessage);
        procedure DoRun; override;
        procedure OnPrereqMet;
        procedure OnHBeatPrepare(const aBody   : TxPLMsgBody);
        procedure CommandGet(var aPageContent : widestring; ARequestInfo: TIdHTTPRequestInfo);
        destructor Destroy; override;
        function  ReplaceTag (const aDevice : string; const aParam : string; aValue : string; const aVariable : string; out ReplaceString : string) : boolean;
        function  ReplaceArrayedTag(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean;
        function  DownloadWaveFile(aURL : string) : string;
        procedure OpenConnection;
        procedure DeleteWaveFile  (aURL : string);
        procedure HandlePhoneNumber(const aPhoneNumber : string);
        procedure CollectGlobalData;
        procedure TestHDBoxState;
     end;

var  xPLApplication : TMyApplication;
     xPLClient      : TxPLWebListener;

implementation //======================================================================================
uses uxPLConst,
     cStrings,
     cFileUtils,
     StrUtils,
     uRegExpr,
     DateUtils;

type TCall = class
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
     K_CONFIG_MESSAGE_STORE = 'storedir';                                                 // Directory to store wav files downloaded
     K_CONFIG_X10_FREEBOX = 'fbox-x10';
     K_CONFIG_X10_HDBOX   = 'fboxhd-x10';
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

//=====================================================================================================
procedure TMyApplication.DoRun;
begin
   CheckSynchronize;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
   inherited Create(TheOwner);

   fConnString := '';
   Stream := TMemoryStream.Create;
   ts := tstringlist.Create;
   sHDBoxStatus := '';

   StopOnException:=True;
   xPLClient := TxPLWebListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER, K_DEFAULT_PORT);
   with xPLClient do begin
       OnCommandGet        := @CommandGet;
       OnxPLMediaBasic     := @OnMediaBasic;
       OnxPLPrereqMet      := @OnPrereqMet;
       OnxPLHBeatPrepare   := @OnHBeatPrepare;
       OnReplaceTag        := @ReplaceTag;
       OnReplaceArrayedTag := @ReplaceArrayedTag;
       OnxPLReceived       := @OnReceived;
       Config.AddItem(K_CONFIG_USERNAME,      K_XPL_CT_CONFIG);
       Config.AddItem(K_CONFIG_PASSWORD,      K_XPL_CT_CONFIG);
       Config.AddItem(K_CONFIG_MESSAGE_STORE, K_XPL_CT_CONFIG);
       Config.AddItem(K_CONFIG_X10_FREEBOX,   K_XPL_CT_CONFIG);
       Config.AddItem(K_CONFIG_X10_HDBOX,     K_XPL_CT_CONFIG);
       Config.AddItem(K_CONFIG_POLLING,       K_XPL_CT_CONFIG,'5');
       PrereqList.Add('timer=0');
       PrereqList.Add('netget=0');
       //PrereqList.Add('nntp=0');  This module is nice to have but not mandatory at this time
       Listen;
   end;

   IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create;
   IdHTTP1 := TIdHTTP.Create;
   with IdHTTP1 do begin
        if xPLClient.Settings.UseProxy then begin
           ProxyParams.ProxyServer:=xPLClient.Settings.HTTPProxSrvr;
           ProxyParams.ProxyPort:=StrToInt(xPLClient.Settings.HTTPProxPort);
        end;
        HandleRedirects := True;
        IOHandler := IdSSLIOHandlerSocketOpenSSL1;
        OnRedirect := @IdHTTP1Redirect;
   end;
end;

destructor TMyApplication.Destroy;
begin
  idHTTP1.destroy;
  if Assigned(fCalls) then fCalls.Destroy;
  if Assigned(fGlobals) then fGlobals.Destroy;
  if Assigned(fPhoneNumbers) then fPhoneNumbers.Destroy;
  ts.Destroy;
  Stream.Destroy;
  xPLClient.Destroy;
  inherited Destroy;
end;

procedure TMyApplication.OpenConnection;
begin
   ts.clear;
   ts.add('login=' + xPLClient.Config.ItemName[K_CONFIG_USERNAME].Value);
   ts.add('pass=' + xPLClient.Config.ItemName[K_CONFIG_PASSWORD].Value);

   IdHTTP1.Post(K_FREE_BASE_URL,Ts,Stream);                                     // Try to open the connection, as soon as opened it will be redirected
   ts.Clear;
end;

procedure TMyApplication.IdHTTP1Redirect(Sender: TObject; var dest: string; var NumRedirect: Integer; var Handled: boolean; var VMethod: TIdHTTPMethod);
begin                                                                           // When connection is established using username and password
   FConnString := ExtractWord(2,dest,['?']);                                    // Free redirects us to another URL containing session id
   xPLClient.LogInfo('Connected to management console : %s',[FConnString]);     // something like http://adsl.free.fr/compte/console.pl?id=755252&idt=2ce4938844b2f863
end;

procedure TMyApplication.OnPrereqMet;
begin
   fCalls   := DMultiMAP.Create;
   fGlobals := DMAP.Create;
   fPhoneNumbers := DMAP.Create;

   ReadFromXML;
                                                                                // Initialize my timer and newsgroup monitoring
   xPLClient.SendMessage( K_MSG_TYPE_CMND, xPLClient.PrereqList.Values['timer'], 'control.basic',
                          ['current','device','frequence'],['start',xPLClient.Address.Tag,IntToStr(StrToIntDef(xPLClient.Config.ItemName[K_CONFIG_POLLING].Value,5) * 60)]);
   xPLClient.SendMessage( K_MSG_TYPE_CMND, xplClient.PrereqList.Values['nntp'], 'control.basic',
                          ['current','device'],['start','proxad.free.annonces']);

   OpenConnection;
   CollectGlobalData;
   Timer1Timer(self);
end;

procedure TMyApplication.OnHBeatPrepare(const aBody: TxPLMsgBody);
var iter : DIterator;
    key : string;
begin
   if not Assigned(fGlobals) then exit;

   Iter := fGlobals.start;
   While iterateOver(iter) do begin
        setToKey(iter);
        key := GetString(iter);
        setToValue(iter);
        aBody.AddKeyValuePair(Key,GetString(iter));
   end;
end;

procedure TMyApplication.CollectGlobalData;
var s : widestring;
begin
   if ((fConnString = '') or (xPLClient.Disposing)) then exit;

   s := IdHTTP1.Get(K_FREE_CARTECH + fConnString);
   with TRegExpr.Create do begin
      Expression := K_RE_FRENCH_PHONE;
      if Exec(s) then begin
         fGlobals.PutPair([V_KF_PHONELINE,StrRemoveChar(Match[0],chSpace)]);

         if ExecNext then fGlobals.PutPair([V_KF_FREELINE,StrRemoveChar(Match[0],chSpace)]);
      end;

      Expression := K_RE_IP_ADDRESS;
      if Exec(s) then begin
         fGlobals.PutPair([V_KF_PUBLICIP,Match[0]]);
         if ExecNext then fGlobals.PutPair([V_KF_GATEWAY,Match[0]]);
      end;

      s := IdHTTP1.Get(K_FREE_FBOX_CFG + fConnString);
      Expression := K_RE_MAC_ADDRESS;
      if Exec(s) then fGlobals.PutPair([V_KF_BOXMAC,Match[0]]);
      Expression := 'de la Freebox.*?</td>.*?>(.*?)<';
      if Exec(s) then fGlobals.PutPair([V_KF_BOXMODEL,Match[1]]);

      s := IdHTTP1.Get(Format(K_FREE_WIFI_CFG,[fConnString]));
      Expression := 'wifi_key".*?value="(.*?)"';
      if Exec(s) then fGlobals.PutPair([V_KF_KEY,Match[1]]);

      Expression := 'wifi_ssid.*?value="(.*?)"';
      if Exec(s) then fGlobals.PutPair([V_KF_SSID,Match[1]]);

      Stream.Clear;
   end;
   WriteToXML;
end;

procedure TMyApplication.OnReceived(const axPLMsg: TxPLMessage);
begin
   with axPLMsg do begin
      if (MessageType = K_MSG_TYPE_STAT) and (Schema.Tag = K_SCHEMA_TIMER_BASIC) and                // Received a timer status message
         (Body.GetValueByKey('device') = xPLClient.Address.Tag) and                                 // from the timer I created
         (Body.GetValueByKey('current') = 'started')                                                // that says kick me
         then Timer1Timer(self)
      else
      if (MessageType = K_MSG_TYPE_TRIG) and (Schema.Tag = K_SCHEMA_NETGET_BASIC) and               // A result is incoming for a phone
         (Body.GetValueByKey('regexpr') = K_PJ_ANNUAIRE_RE) and                                     // number search
         (Body.GetValueByKey('current') = 'success')                                                // and it is successfull
         then begin
            fPhoneNumbers.PutPair([Body.GetValueByKey('qphone'),Body.GetValueByKey('result')]);     // let's record it
            self.WriteToXML;                                                                        // And save it
         end;
   end;
end;

function TMyApplication.DownloadWaveFile(aURL: string) : string;                                    // aURL : efface_message.pl?id=755252&idt=09cedf4158efe39c&tel=950201201&fichier=20100115_120730_r0041775873.au
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

procedure TMyApplication.DeleteWaveFile(aURL: string);
begin
   IdHTTP1.Get(K_FREE_TEL + aURL);
end;


procedure TMyApplication.Timer1Timer(Sender: TObject);
var s : widestring;
    bCallPending : boolean;
    myYear, myMonth, myDay : Word;
    myHour, myMin, mySec, myMilli : Word;
    aCall : TCall;
begin
   if ((fConnString = '') or (xPLClient.Disposing)) then exit;

   xPLClient.LogInfo('Checking incoming calls : %s %s',[K_FREE_TEL_NOTIFS,fConnString]);
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

procedure TMyApplication.HandlePhoneNumber(const aPhoneNumber: string);
begin
   fPhoneNumbers.PutPair([aPhoneNumber,'*** Unknown ***']);
   xPLClient.SendMessage( K_MSG_TYPE_CMND,xPLClient.PrereqList.Values['netget'],K_SCHEMA_NETGET_BASIC,
                          ['protocol','uri','qphone','regexpr'],['get',K_PJ_ANNUAIRE_INV,aPhoneNumber,K_PJ_ANNUAIRE_RE]);
end;

procedure TMyApplication.WriteToXML;
var i : integer;
    iter : DIterator;
    key : string;
    aCall : TCall;
begin
   Iter := fGlobals.start;
   While iterateOver(iter) do begin
      setToKey(iter);
      key := GetString(iter);
      setToValue(iter);
      xPLClient.Config.XMLFile.SetValue('Free/Globals/'+ key,GetString(iter));
   end;

   Iter := fPhoneNumbers.Start;
   i:=0;
   xPLClient.Config.XMLFile.SetValue('Free/PhoneNumbers/Count',fPhoneNumbers.size);
   While iterateOver(iter) do begin
      setToKey(iter);
      xPLClient.Config.XMLFile.SetValue('Free/PhoneNumbers/'+ intToStr(i) + '/Phone',GetString(iter));
      setToValue(iter);
      xPLClient.Config.XMLFile.SetValue('Free/PhoneNumbers/'+ intToStr(i) + '/Name',GetString(iter));
      inc(i);
   end;

   Iter := fCalls.Start;
   i:=0;
   xPLClient.Config.XMLFile.SetValue('Free/Calls/Count',fPhoneNumbers.size);
   setToValue(iter);
   While iterateOver(iter) do begin
      aCall := TCall(GetObject(iter));
      xPLClient.Config.XMLFile.SetValue('Free/Calls/'+ intToStr(i) + '/FileName',aCall.FileName);
      xPLClient.Config.XMLFile.SetValue('Free/Calls/'+ intToStr(i) + '/From',aCall.From);
      xPLClient.Config.XMLFile.SetValue('Free/Calls/'+ intToStr(i) + '/Length',aCall.Length);
      xPLClient.Config.XMLFile.SetValue('Free/Calls/'+ intToStr(i) + '/Recept',DateTimeToStr(aCall.Recept));
      inc(i);
   end;

   xPLClient.Config.XMLFile.Flush;
end;

procedure TMyApplication.ReadFromXML;
var i,c : integer;
    aCall : TCall;
begin
   for i := 0 to High(K_GLOBALS_ARRAY) do
      fGlobals.PutPair([K_GLOBALS_ARRAY[i],xPLClient.Config.XMLFile.GetValue('Free/Globals/' + K_GLOBALS_ARRAY[i],'')]);

   c := StrToInt(xPLClient.Config.XMLFile.GetValue('Free/PhoneNumbers/Count','0'));
   for i:=0 to c-1 do begin
      fPhoneNumbers.PutPair([
                             xPLClient.Config.XMLFile.GetValue('Free/PhoneNumbers/'+ intToStr(i) + '/Phone',''),
                             xPLClient.Config.XMLFile.GetValue('Free/PhoneNumbers/'+ intToStr(i) + '/Name', '')]);
   end;

   c := StrToInt(xPLClient.Config.XMLFile.GetValue('Free/Calls/Count','0'));
   for i:=0 to c-1 do begin
      aCall := TCall.Create;
      aCall.Filename := xPLClient.Config.XMLFile.GetValue('Free/Calls/'+ intToStr(i) + '/FileName','');
      aCall.From     := xPLClient.Config.XMLFile.GetValue('Free/Calls/'+ intToStr(i) + '/From','');
      aCall.Length   := xPLClient.Config.XMLFile.GetValue('Free/Calls/'+ intToStr(i) + '/Length','');
      aCall.Recept   := StrToDateTime(xPLClient.Config.XMLFile.GetValue('Free/Calls/'+ intToStr(i) + '/Recept',''));
      fCalls.putPair([aCall.From,aCall]);
   end;
end;

function TMyApplication.ReplaceTag(const aDevice : string; const aParam : string; aValue : string; const aVariable : string; out ReplaceString : string) : boolean;
var iter : DIterator;
begin
   if aDevice <> K_DEFAULT_DEVICE then exit;        // This isn't for me

   iter := fGlobals.locate([aVariable]);
   ReplaceString := Ifthen(atEnd(iter),'',getString(iter));

   Result := ReplaceString<>'';
end;

function TMyApplication.ReplaceArrayedTag(const aDevice: string; const aValue : string; const aVariable: string; ReturnList: TStringList): boolean;
var iter,iter2 : DIterator;
    aCall : TCall;
    objet : string;
begin
   if aDevice<>K_DEFAULT_DEVICE then exit;
   ReturnList.Clear;

   case AnsiIndexStr( ExtractWord(1,aVariable,['_']) , ['call','pn'] ) of
       0 : begin
           Objet := ExtractWord(2,aVariable,['_']);
           iter := fCalls.start;
           setToValue(iter);
           while iterateOver(iter) do begin
                 aCall := TCall(GetObject(iter));
                 case AnsiIndexStr(objet,['from','date','length','name']) of
                      0 : begin
                          iter2 := fPhoneNumbers.locate([aCall.From]);
                          if atEnd(iter2) then returnlist.add(aCall.From)
                                          else begin
                                               setToValue(iter2);
                                               returnlist.add(getString(iter2) + '(' + aCall.From +')');
                                               end;
                          end;
                      1 : returnlist.add(DateTimeToStr(aCall.Recept));
                      2 : returnlist.add(aCall.Length);
                      3 : returnlist.add(aCall.Filename);
                 end;
           end;
       end;
       1 : begin
           iter := fPhoneNumbers.start;
           case AnsiIndexStr( ExtractWord(2,aVariable,['_']) ,['number','contact']) of
                0 : setToKey(iter);
                1 : setToValue(iter);
           end;
           While iterateOver(iter) do if ((aValue='') or (aValue=getString(iter))) then ReturnList.Add(getString(iter));
       end;
   end;
   result := (ReturnList.Count >0);
end;

procedure TMyApplication.CommandGet(var aPageContent: widestring; ARequestInfo: TIdHTTPRequestInfo);
var bHandeld : boolean;
    iter : DIterator;
    s,s2 : string;
begin
   bHandeld  := true;

   Case AnsiIndexStr(AnsiLowerCase(ARequestInfo.Params.Values['Submit']),['delete_call','delete_pn','change name']) of
        0 : begin
                 iter := fCalls.Locate([ARequestInfo.Params.Values['free_callname']]);
                 if not atEnd(iter) then begin
                    DeleteFile(PathInclSuffix(xPLClient.Config.ItemName[K_CONFIG_MESSAGE_STORE].Value) + ARequestInfo.Params.Values['free_callname']);
                    fCalls.removeAt(iter);
                 end;
            end;
        1 : fPhoneNumbers.removeValue([ARequestInfo.Params.Values['pn_number']]);
        2 : fPhoneNumbers.putpair([ARequestInfo.Params.Values['pn_number'],ARequestInfo.Params.Values['pn_contact']]);
        else bHandeld := false;
   end;
   if bHandeld then begin
      ARequestInfo.Params.Clear;
      WriteToXML;
   end;
end;


procedure TMyApplication.TestHDBoxState;
var NewStatus : string;
    s         : widestring;
begin
   s:= IdHTTP1.Get(K_FREE_MAGNETO + fConnString + '&liste=1');
   NewStatus := IfThen(AnsiContainsText(s,'Le boitier HD ne répond pas'),'on','off');
   if sHDBoxStatus<>NewStatus then begin
      xPLClient.SendMessage(K_MSG_TYPE_TRIG,K_MSG_TARGET_ANY,'media.devstate',['power','connected'],[NewStatus,IfThen(newstatus='on','true','false')]);
      sHDBoxStatus := NewStatus;
   end;
end;

procedure TMyApplication.OnMediaBasic(const axPLMsg: TxPLMessage; const aCommand: string; const aMP: string);
var x10_address : string;
begin
     x10_address := xPLClient.Config.ItemName[aMP + '-x10'].Value;
     if x10_address = '' then exit;

     if aCommand = 'power' then begin
     xPLClient.SendMessage( K_MSG_TYPE_CMND,K_MSG_TARGET_ANY,K_SCHEMA_X10_BASIC,
                            ['command','device'],[axPLMsg.Body.GetValueByKey('state'),x10_address]);
     end;
     if aCommand = 'reboot' then begin

     end;
end;

initialization
   xPLApplication:=TMyApplication.Create(nil);
end.

