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
        procedure SendSensors(bCheckDifference : boolean; sensorname : string ='');
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
     K_XPL_APP_VERSION_NUMBER = '3.1';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'weather';
     K_DEFAULT_PORT   = '8333';
     K_WEATHER_URI = 'http://xoap.weather.com/weather/local/%s?cc=*&dayf=5&link=xoap&prod=xoap&par=%s&key=%s';

procedure TMyApplication.DoRun;
begin
   CheckSynchronize;
end;

procedure TMyApplication.SendSensors(bCheckDifference: boolean; sensorname : string ='');
procedure IssueSensor(aValue,aDevice,aType : string);
begin
   xPLClient.SendMessage( K_MSG_TYPE_TRIG, K_MSG_TARGET_ANY, K_SCHEMA_SENSOR_BASIC,
                          ['device','type','current','timestamp'],[aDevice,aType,aValue,Weather.Courant.ChaineDateHeure]);
end;
begin
   if assigned(Weather) then with Weather do begin
      if ((sensorname='') or (sensorname='description')) and  (not bCheckDifference or (Weather.Courant.Texte           <> Backup.Courant.Texte           )) then IssueSensor(Weather.Courant.Texte           ,'description' ,'generic');
      if ((sensorname='') or (sensorname='temperature')) and  (not bCheckDifference or (Weather.Courant.Temperature     <> Backup.Courant.Temperature     )) then IssueSensor(Weather.Courant.Temperature     ,'temperature' ,'temp');
      if ((sensorname='') or (sensorname='felt-temp')) and  (not bCheckDifference or (Weather.Courant.TempRessentie   <> Backup.Courant.TempRessentie   )) then IssueSensor(Weather.Courant.TempRessentie   ,'felt-temp'   ,'temp');
      if ((sensorname='') or (sensorname='barometer')) and  (not bCheckDifference or (Weather.Courant.Pression.Valeur <> Backup.Courant.Pression.Valeur )) then IssueSensor(Weather.Courant.Pression.Valeur ,'barometer'   ,'pressure');
      if ((sensorname='') or (sensorname='press-var')) and  (not bCheckDifference or (Weather.Courant.Pression.Variation <> Backup.Courant.Pression.Variation      )) then IssueSensor(Weather.Courant.Pression.Variation      ,'press-var'  ,'generic');
      if ((sensorname='') or (sensorname='wind-speed')) and  (not bCheckDifference or (Weather.Courant.Vent.Vitesse    <> Backup.Courant.Vent.Vitesse    )) then IssueSensor(Weather.Courant.Vent.Vitesse    ,'wind-speed'  ,'speed');
      if ((sensorname='') or (sensorname='wind-gust')) and  (not bCheckDifference or (Weather.Courant.Vent.Gust       <> Backup.Courant.Vent.Gust       )) then IssueSensor(Weather.Courant.Vent.Gust       ,'wind-gust'   ,'speed');
      if ((sensorname='') or (sensorname='wind-dir')) and  (not bCheckDifference or (Weather.Courant.Vent.Sens       <> Backup.Courant.Vent.Sens       )) then IssueSensor(Weather.Courant.Vent.Sens       ,'wind-dir'    ,'direction');
      if ((sensorname='') or (sensorname='humidity')) and  (not bCheckDifference or (Weather.Courant.Humidite        <> Backup.Courant.Humidite        )) then IssueSensor(Weather.Courant.Humidite        ,'humidity'    ,'humidity');
      if ((sensorname='') or (sensorname='visibility')) and  (not bCheckDifference or (Weather.Courant.Visibilite      <> Backup.Courant.Visibilite      )) then IssueSensor(Weather.Courant.Visibilite      ,'visibility'  ,'distance');
      if ((sensorname='') or (sensorname='uv')) and  (not bCheckDifference or (Weather.Courant.UV.Indice       <> Backup.Courant.UV.Indice       )) then IssueSensor(Weather.Courant.UV.Indice       ,'uv'          ,'uv');
      if ((sensorname='') or (sensorname='dewpoint')) and  (not bCheckDifference or (Weather.Courant.Dewp            <> Backup.Courant.Dewp            )) then IssueSensor(Weather.Courant.Dewp            ,'dewpoint'    ,'temp');
      if ((sensorname='') or (sensorname='sunrise')) and  (not bCheckDifference or (Weather.Localite.Sunrise        <> Backup.Localite.Sunrise       ) ) then IssueSensor(Weather.Localite.Sunrise        ,'sunrise'     ,'generic');
      if ((sensorname='') or (sensorname='sunset')) and  (not bCheckDifference or (Weather.Localite.Sunset         <> Backup.Localite.Sunset        )) then IssueSensor(Weather.Localite.Sunset         ,'sunset'      ,'generic');
      if ((sensorname='') or (sensorname='moon-phase')) and  (not bCheckDifference or (Weather.Courant.Lune.Texte      <> Backup.Courant.Lune.Texte      )) then IssueSensor(Weather.Courant.Lune.Texte      ,'moon-phase'  ,'generic');
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
       PassMyOwnMessages := true;
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
   if (aAction <> 'current') then exit;

   Weather.MettreAJour(GetTempDir + 'weather.xml',xPLClient.Config.ItemName['unitsystem'].Value);
   SendSensors(false, aDevice);
end;

procedure TMyApplication.OnConfigDone(const fConfig: TxPLConfig);

begin
  if not Assigned(Weather) then begin
     Backup  := TWeather.Create;
     Weather := TWeather.Create;
     fURI := Format(K_WEATHER_URI,[ xPLClient.Config.ItemName['zipcode'].Value ,
                                    xPLClient.Config.ItemName['partnerid'].Value ,
                                    xPLClient.Config.ItemName['licensekey'].Value]);

     xPLClient.RegisterLocaleDomain(xPLClient.Config.ItemName['translation'].Value,'weather');
     xPLClient.RegisterLocaleDomain(xPLClient.Config.ItemName['translation'].Value,'winddir');
     xPLClient.RegisterLocaleDomain(xPLClient.Config.ItemName['translation'].Value,'moon');
  end;
end;

procedure TMyApplication.OnReceived(const axPLMsg: TxPLMessage);
begin
   with axPLMsg do begin
      if (MessageType = K_MSG_TYPE_STAT) and                                           // Received a timer status message
         (Schema.Tag = K_SCHEMA_TIMER_BASIC) and
         (Body.GetValueByKey('device') = xPLClient.Address.Tag) and                    // from the timer I created
         (Body.GetValueByKey('current') = 'started') then begin                        // that says he's alive
         xPLClient.SendMessage( K_MSG_TYPE_CMND,xPLClient.PrereqList.Values['netget'],K_SCHEMA_NETGET_BASIC,
                                ['protocol','uri','destdir','destfn'],['http',fURI,GetTempDir,'weather.xml']);
      end else
      if (MessageType = K_MSG_TYPE_TRIG) and
         (Schema.Tag = K_SCHEMA_NETGET_BASIC) and
         (Body.GetValueByKey('uri') = fURI) and
         (Body.GetValueByKey('current') = 'done') then begin
            Weather.MettreAJour(GetTempDir + 'weather.xml',xPLClient.Config.ItemName['unitsystem'].Value);
            with Weather, Courant do  xPLClient.LogInfo('Weather data loaded for %s',[Lieu]);
            SendSensors(true);
            Backup.Assign(Weather);
         end;
   end;
end;

procedure TMyApplication.OnPrereqMet;
begin
   xPLClient.SendMessage( K_MSG_TYPE_CMND, xPLClient.PrereqList.Values['timer'], K_SCHEMA_TIMER_BASIC,
                          ['action','device','frequence'],['start',xPLClient.Address.Tag,IntToStr(30 * 60)]);
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

