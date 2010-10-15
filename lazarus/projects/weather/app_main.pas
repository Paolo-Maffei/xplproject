unit app_main;

{$i compiler.inc}

interface

uses
  Classes, SysUtils,
  CustApp,
  uxPLMessage,
  uxPLWebListener,
  uxPLConfig,
  Weathers,
  IdCustomHTTPServer;

type

{ TMyApplication }

TMyApplication = class(TCustomApplication)
     protected
        fURI : string;
        Weather,Backup : TWeather;
        procedure DoRun; override;
        procedure SendSensors(bCheckDifference : boolean);
     public
        constructor Create(TheOwner: TComponent); override;
        procedure OnSensorRequest(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
        procedure OnConfigDone(const fConfig : TxPLConfig);
        procedure OnReceived(const axPLMsg : TxPLMessage);
        procedure OnPrereqMet;
        procedure CommandGet(var aPageContent : widestring; ARequestInfo: TIdHTTPRequestInfo);
        destructor Destroy; override;
     end;

var  xPLApplication : TMyApplication;
     xPLClient      : TxPLWebListener;

implementation //======================================================================================
uses uxPLConst, cStrings;

//=====================================================================================================
const
     K_XPL_APP_VERSION_NUMBER = '3.0';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'weather';
     K_DEFAULT_PORT   = '8333';
     K_WEATHER_URI = 'http://xoap.weather.com/weather/local/%s?cc=*&dayf=5&link=xoap&prod=xoap&par=%s&key=%s';

procedure TMyApplication.DoRun;
var ErrorMsg: String;
begin
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  if HasOption('h','help') then begin
    Terminate;
    Exit;
  end;

  while true do begin
        CheckSynchronize;
  end;
  Terminate;
end;

procedure TMyApplication.SendSensors(bCheckDifference: boolean);
procedure IssueSensor(aValue,aDevice,aType : string);
//var aMsg : TxPLMessage;
begin
//   aMsg := xPLClient.PrepareMessage(K_MSG_TYPE_TRIG,K_SCHEMA_SENSOR_BASIC);
//   with aMsg do begin
//        Body.AddKeyValuePair('device',aDevice);
//        Body.AddKeyValuePair('type',aType);
//        Body.AddKeyValuePair('current',aValue);
//        Body.AddKeyValuePair('timestamp',Weather.Courant.ChaineDateHeure);
//        xPLClient.Send(aMsg);
//        Destroy;
//   end;
   xPLClient.SendMessage( K_MSG_TYPE_TRIG, K_MSG_TARGET_ANY, K_SCHEMA_SENSOR_BASIC,
                          ['device','type','current','timestamp'],[aDevice,aType,aValue,Weather.Courant.ChaineDateHeure]);
end;
begin
   if assigned(Weather) then with Weather do begin
      if not bCheckDifference or (Weather.Courant.Texte           <> Backup.Courant.Texte           ) then IssueSensor(Weather.Courant.Texte           ,'description' ,'generic');
      if not bCheckDifference or (Weather.Courant.Temperature     <> Backup.Courant.Temperature     ) then IssueSensor(Weather.Courant.Temperature     ,'temperature' ,'temp');
      if not bCheckDifference or (Weather.Courant.TempRessentie   <> Backup.Courant.TempRessentie   ) then IssueSensor(Weather.Courant.TempRessentie   ,'felt-temp'   ,'temp');
      if not bCheckDifference or (Weather.Courant.Pression.Valeur <> Backup.Courant.Pression.Valeur ) then IssueSensor(Weather.Courant.Pression.Valeur ,'barometer'   ,'pressure');
      if not bCheckDifference or (Weather.Courant.Pression.Variation <> Backup.Courant.Pression.Variation      ) then IssueSensor(Weather.Courant.Pression.Variation      ,'press-var'  ,'generic');
      if not bCheckDifference or (Weather.Courant.Vent.Vitesse    <> Backup.Courant.Vent.Vitesse    ) then IssueSensor(Weather.Courant.Vent.Vitesse    ,'wind-speed'  ,'speed');
      if not bCheckDifference or (Weather.Courant.Vent.Gust       <> Backup.Courant.Vent.Gust       ) then IssueSensor(Weather.Courant.Vent.Gust       ,'wind-gust'   ,'speed');
      if not bCheckDifference or (Weather.Courant.Vent.Sens       <> Backup.Courant.Vent.Sens       ) then IssueSensor(Weather.Courant.Vent.Sens       ,'wind-dir'    ,'direction');
      if not bCheckDifference or (Weather.Courant.Humidite        <> Backup.Courant.Humidite        ) then IssueSensor(Weather.Courant.Humidite        ,'humidity'    ,'humidity');
      if not bCheckDifference or (Weather.Courant.Visibilite      <> Backup.Courant.Visibilite      ) then IssueSensor(Weather.Courant.Visibilite      ,'visibility'  ,'distance');
      if not bCheckDifference or (Weather.Courant.UV.Indice       <> Backup.Courant.UV.Indice       ) then IssueSensor(Weather.Courant.UV.Indice       ,'uv'          ,'uv');
      if not bCheckDifference or (Weather.Courant.Dewp            <> Backup.Courant.Dewp            ) then IssueSensor(Weather.Courant.Dewp            ,'dewpoint'    ,'temp');
      if not bCheckDifference or (Weather.Localite.Sunrise        <> Backup.Localite.Sunrise        ) then IssueSensor(Weather.Localite.Sunrise        ,'sunrise'     ,'generic');
      if not bCheckDifference or (Weather.Localite.Sunset         <> Backup.Localite.Sunset         ) then IssueSensor(Weather.Localite.Sunset         ,'sunset'      ,'generic');
      if not bCheckDifference or (Weather.Courant.Lune.Texte      <> Backup.Courant.Lune.Texte      ) then IssueSensor(Weather.Courant.Lune.Texte      ,'moon-phase'  ,'generic');

      with Weather, Courant do  xPLClient.LogInfo('Weather data loaded for %s',[Lieu]);
   end;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
  xPLClient := TxPLWebListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER, K_DEFAULT_PORT);
  with xPLClient do begin
       OnxPLSensorRequest := @OnSensorRequest;
       OnxPLConfigDone    := @OnConfigDone;
       OnCommandGet       := @CommandGet;
       OnxPLPrereqMet     := @OnPrereqMet;
       OnxPLReceived      := @OnReceived;
       Config.AddItem('partnerid', K_XPL_CT_CONFIG);
       Config.AddItem('licensekey',K_XPL_CT_CONFIG);
       Config.AddItem('zipcode'  , K_XPL_CT_CONFIG);
       Config.AddItem('unitsystem',K_XPL_CT_CONFIG);
       Config.AddItem('translation',K_XPL_CT_CONFIG,'us');
       PrereqList.Add('timer=0');
       PrereqList.Add('netget=0');
       Listen;
  end;
end;

destructor TMyApplication.Destroy;
begin
  xPLClient.Destroy;
  inherited Destroy;
end;

procedure TMyApplication.OnSensorRequest(const axPLMsg: TxPLMessage; const aDevice: string; const aAction: string);
begin
   if not ((aDevice = 'weather') and (aAction = 'current')) then exit;

   Weather.MettreAJour(GetTempDir + 'weather.xml',xPLClient.Config.ItemName['unitsystem'].Value);
   SendSensors(false);
end;

procedure TMyApplication.OnConfigDone(const fConfig: TxPLConfig);
var ageofinfo : tdatetime;
//    hour, min, sec, msec, elapsed, timetoupdate : word;

begin
  if not Assigned(Weather) then begin
     Backup  := TWeather.Create;
     Weather := TWeather.Create;
     fURI := Format(K_WEATHER_URI,[ xPLClient.Config.ItemName['zipcode'].Value ,
                                    xPLClient.Config.ItemName['partnerid'].Value ,
                                    xPLClient.Config.ItemName['licensekey'].Value]);
//     AgeOfInfo  := Now - Weather.Courant.TimeStamp;
//     DecodeTime(AgeOfInfo, hour, min, sec, msec);           // Should always be between 0 and 30 minutes
//     Elapsed := min * 60 + sec;
//     TimeToUpdate := 30* 60 - Elapsed;
//     Timer1.Interval := (TimeToUpdate + 120) * 1000;        // Adjust next timer tick to website update
//     Timer1.Enabled := True;

     xPLClient.RegisterLocaleDomain(xPLClient.Config.ItemName['translation'].Value,'weather');
     xPLClient.RegisterLocaleDomain(xPLClient.Config.ItemName['translation'].Value,'winddir');
     xPLClient.RegisterLocaleDomain(xPLClient.Config.ItemName['translation'].Value,'moon');
  end;
end;

procedure TMyApplication.OnReceived(const axPLMsg: TxPLMessage);
//var aMsg : TxPLMessage;
begin
   with axPLMsg do begin
      if (MessageType = K_MSG_TYPE_STAT) and                                        // Received a timer status message
         (Schema.Tag = K_SCHEMA_TIMER_BASIC) and
         (Body.GetValueByKey('device') = xPLClient.Address.Tag) and                    // from the timer I created
         (Body.GetValueByKey('current') = 'started') then begin                        // that says he's alive
//         aMsg := xPLClient.PrepareMessage(K_MSG_TYPE_CMND,'netget.basic',xPLClient.PrereqList.Values['netget']);
         xPLClient.SendMessage( K_MSG_TYPE_CMND,xPLClient.PrereqList.Values['netget'],'netget.basic',
                                ['protocol','uri','destdir','destfn'],['http',fURI,GetTempDir,'weather.xml']);
//         with aMsg do begin
//              Body.AddKeyValuePair('protocol','http');
//              Body.AddKeyValuePair('uri', fURI);
//              Body.AddKeyValuePair('destdir',GetTempDir);
//              Body.AddKeyValuePair('destfn','weather.xml');
//              xPLClient.Send(aMsg);
//              Destroy;
//         end;
      end else
      if (MessageType = K_MSG_TYPE_TRIG) and
         (Schema.Tag = 'netget.basic') and
         (Body.GetValueByKey('uri') = fURI) and
         (Body.GetValueByKey('current') = 'done') then begin
            Weather.MettreAJour(GetTempDir + 'weather.xml',xPLClient.Config.ItemName['unitsystem'].Value);
            SendSensors(true);
            Backup.Assign(Weather);
         end;
   end;
end;

procedure TMyApplication.OnPrereqMet;
//var aMsg : TxPLMessage;
begin
//   aMsg := xPLClient.PrepareMessage(K_MSG_TYPE_CMND,'control.basic',xPLClient.PrereqList.Values['timer']);
//   with aMsg do begin
//      Body.AddKeyValuePair('current','start');
//      Body.AddKeyValuePair('device',xPLClient.Address.Tag);
//      Body.AddKeyValuePair('frequence',IntToStr(30 * 60));                      // Start a 30mn timer
//      xPLClient.Send(aMsg);
//      Destroy;
//   end;
   xPLClient.SendMessage( K_MSG_TYPE_CMND, xPLClient.PrereqList.Values['timer'], 'control.basic',
                          ['current','device','frequence'],['start',xPLClient.Address.Tag,IntToStr(30 * 60)]);
end;

procedure TMyApplication.CommandGet(var aPageContent: widestring; ARequestInfo: TIdHTTPRequestInfo);
var
  s : widestring;
  i : integer;
begin
      s := StrReplace('{%weatherdesc%}',xPLClient.Translate('weather',Weather.Courant.Texte),aPageContent,false);
      s := StrReplace('{%weathericon%}',Weather.Courant.Icone,s,false);
      s := StrReplace('{%timestamp%}',Weather.Courant.ChaineDateHeure,s,false); // date and time of prevision creation at weather.com
      s := StrReplace('{%temperature%}',Weather.Courant.Temperature,s,false);
      s := StrReplace('{%felt-temp%}',Weather.Courant.TempRessentie,s,false);
      s := StrReplace('{%barometer%}',Weather.Courant.Pression.Valeur,s,false);
      s := StrReplace('{%wind-speed%}',Weather.Courant.Vent.Vitesse,s,false);
      s := StrReplace('{%wind-gust%}',Weather.Courant.Vent.Gust,s,false);
      s := StrReplace('{%wind-dir%}',xPLClient.Translate('weather',Weather.Courant.Vent.Sens),s,false);
      s := StrReplace('{%pressureevol%}',Weather.Courant.Pression.Variation,s,false);
      s := StrReplace('{%humidity%}',Weather.Courant.Humidite,s,false);
      s := StrReplace('{%visibility%}',Weather.Courant.Visibilite,s,false);
      s := StrReplace('{%uv%}',Weather.Courant.UV.Indice,s,false);
      s := StrReplace('{%uv-desc%}',Weather.Courant.UV.Texte,s,false);
      s := StrReplace('{%dewpoint%}',Weather.Courant.Dewp,s,false);
      s := StrReplace('{%moon%}',xPLClient.Translate('moon',Weather.Courant.Lune.Texte),s,false);
      s := StrReplace('{%moonicon%}',Weather.Courant.Lune.Icone,s,false);
      s := StrReplace('{%today-sunrise%}',Weather.Localite.Sunrise,s,false);
      s := StrReplace('{%today-sunset%}',Weather.Localite.Sunset,s,false);
      s := StrReplace('{%fctimestamp%}'       ,Weather.Previsions.DateHeure,s,false);

      for i:=0 to 10 do begin
          s := StrReplace('{%fcday'+inttostr(i)+'%}'             ,Weather.Previsions.Jours[i].JourSemaine,s,false);
          s := StrReplace('{%fcdate'+inttostr(i)+'%}'            ,Weather.Previsions.Jours[i].ChaineDateJour,s,false);
          s := StrReplace('{%fcmintemp'+inttostr(i)+'%}'         ,Weather.Previsions.Jours[i].Mini,s,false);
          s := StrReplace('{%fcmaxtemp'+inttostr(i)+'%}'         ,Weather.Previsions.Jours[i].Maxi,s,false);
          s := StrReplace('{%fcsunrise'+inttostr(i)+'%}'         ,Weather.Previsions.Jours[i].LeverSoleil,s,false);
          s := StrReplace('{%fcsunset'+inttostr(i)+'%}'          ,Weather.Previsions.Jours[i].CoucherSoleil,s,false);
          s := StrReplace('{%fcdayweathericon'+inttostr(i)+'%}'  ,Weather.Previsions.Jours[i].Jour.Icone,s,false);
          s := StrReplace('{%fcdayweatherdesc'+inttostr(i)+'%}'  ,xPLClient.Translate('weather',Weather.Previsions.Jours[i].Jour.Texte),s,false);
          s := StrReplace('{%fcdaywind-speed'+inttostr(i)+'%}'   ,Weather.Previsions.Jours[i].Jour.Vent.Vitesse,s,false);
          s := StrReplace('{%fcdaywind-gust'+inttostr(i)+'%}'    ,Weather.Previsions.Jours[i].Jour.Vent.Gust,s,false);
          s := StrReplace('{%fcdaywind-dir'+inttostr(i)+'%}'     ,xPLClient.Translate('winddir',Weather.Previsions.Jours[i].Jour.Vent.Sens),s,false);
          s := StrReplace('{%fcdayrainprob'+inttostr(i)+'%}'     ,Weather.Previsions.Jours[i].Jour.RisquePrecipitation,s,false);
          s := StrReplace('{%fcdayhumidity'+inttostr(i)+'%}'     ,Weather.Previsions.Jours[i].Jour.Humidite,s,false);
          s := StrReplace('{%fcnightweathericon'+inttostr(i)+'%}',Weather.Previsions.Jours[i].Nuit.Icone,s,false);
          s := StrReplace('{%fcnightweatherdesc'+inttostr(i)+'%}',xPLClient.Translate('weather',Weather.Previsions.Jours[i].Nuit.Texte),s,false);
          s := StrReplace('{%fcnightwind-speed'+inttostr(i)+'%}' ,Weather.Previsions.Jours[i].Nuit.Vent.Vitesse,s,false);
          s := StrReplace('{%fcnightwind-gust'+inttostr(i)+'%}'  ,Weather.Previsions.Jours[i].Nuit.Vent.Gust,s,false);
          s := StrReplace('{%fcnightwind-dir'+inttostr(i)+'%}'   ,xPLClient.Translate('winddir',Weather.Previsions.Jours[i].Nuit.Vent.Sens),s,false);
          s := StrReplace('{%fcnightrainbrob'+inttostr(i)+'%}'   ,Weather.Previsions.Jours[i].Nuit.RisquePrecipitation,s,false);
          s := StrReplace('{%fcnighthumidity'+inttostr(i)+'%}'   ,Weather.Previsions.Jours[i].Nuit.Humidite,s,false);
      end;
      aPageContent := s;
end;

initialization
   xPLApplication:=TMyApplication.Create(nil);
end.

