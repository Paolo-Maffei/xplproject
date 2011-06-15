unit weather_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses Classes
     , SysUtils
     , u_xpl_web_listener
     , Weathers
     , u_xpl_config
     , u_xpl_actionlist
     , u_xpl_schema
     , fpTimer
     , u_xpl_message
     , superobject
     ;

type

{ TxPLweatherListener }

     TxPLweatherListener = class(TxPLWebListener)
     private
        fURI : string;
        Weather,Backup : TWeather;
        procedure SendSensors(bCheckDifference : boolean; sensorname : string ='');
 //     procedure OnSensorRequest(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
        procedure OnReceived(const axPLMsg : TxPLMessage);
        procedure OnPrereqMet;

     public
        constructor Create(const aOwner : TComponent); overload;
        procedure   UpdateConfig;               override;
        procedure   GetData(const aSuperObject : ISuperObject); override;
        procedure   OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;
     published
        property aWeather : TWeather read Weather write Weather;
     end;

var  Schema_DDBasic : TxPLSchema;

implementation
uses u_xpl_common
     , u_xpl_header
     , u_xpl_body
     , TypInfo
     , DateUtils
     , uxPLConst
     , u_xpl_custom_message
     , LResources
     ;
//=============================================================================
const K_WEATHER_URI = 'http://xoap.weather.com/weather/local/%s?cc=*&dayf=5&link=xoap&prod=xoap&par=%s&key=%s';

// ============================================================================
{ TxPLweatherListener }

constructor TxPLweatherListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);

   Config.DefineItem('partnerid'  , u_xpl_config.config, 1);                    //,'Partner ID delivered by weather.com','^[A-Za-z0-9]{1,50}$');
   Config.DefineItem('licensekey' , u_xpl_config.config, 1);                    //,'License key delivered by weather.com','^[A-Za-z0-9]{1,50}$');
   Config.DefineItem('zipcode'    , u_xpl_config.config, 1);                    //,'Code of the city','^[A-Za-z0-9]{1,50}$');
   Config.DefineItem('unitsystem' , u_xpl_config.config, 1);                    //,'Either `us` or `metric` system','us|metric');
   Config.DefineItem('translation', u_xpl_config.config, 1);                    //'Language used to display weather informations','us|fr',1,'us');

   Config.FilterSet.AddValues([ 'xpl-stat.*.*.*.timer.basic',                   // Message used to launch file download query
                               'xpl-trig.*.*.*.netget.basic',                   // Message received when download finished
                               'xpl-cmnd.*.*.*.sensor.request' ]);              // Message received to ask sensor value(s)

   PrereqList.DelimitedText := 'timer,netget';

   OnxPLPrereqMet    := @OnPrereqMet;
end;

procedure TxPLweatherListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
   if CompareText(AClassName, 'TxPLweatherListener') = 0 then ComponentClass := TxplweatherListener
   else inherited;
end;

procedure TxPLweatherListener.UpdateConfig;
var found : boolean;
    LocaleTarget : string;
begin
  inherited UpdateConfig;
  if Config.IsValid and not Assigned(Weather) then begin
      Backup  := TWeather.Create;
      Weather := TWeather.Create;
      fURI    := Format(K_WEATHER_URI,[ Config.GetItemValue('zipcode'),
                                        Config.GetItemValue('partnerid'),
                                        Config.GetItemValue('licensekey')]);

      LocaleTarget := Config.GetItemValue('translation');
      RegisterLocaleDomain(LocaleTarget,'weather');
      RegisterLocaleDomain(LocaleTarget,'winddir');
      RegisterLocaleDomain(LocaleTarget,'moon');

     OnxPLReceived := @OnReceived;
  end else OnxPLReceived := nil;
end;

procedure TxPLweatherListener.SendSensors(bCheckDifference: boolean; sensorname: string);
procedure IssueSensor(aValue,aDevice,aType : string);
begin
   SendMessage( trig, '*', 'sensor.basic',
                          ['device','type','current','timestamp'],[aDevice,aType,aValue,Weather.Courant.ChaineDateHeure]);
end;
begin
   if assigned(Weather) then with Weather do begin
      if ((sensorname='') or (sensorname='description' )) and  (not bCheckDifference or (Weather.Courant.Texte              <> Backup.Courant.Texte              )) then IssueSensor(Weather.Courant.Texte              ,'description' ,'generic'   );
      if ((sensorname='') or (sensorname='temperature' )) and  (not bCheckDifference or (Weather.Courant.Temperature        <> Backup.Courant.Temperature        )) then IssueSensor(Weather.Courant.Temperature        ,'temperature' ,'temp'      );
      if ((sensorname='') or (sensorname='felt-temp'   )) and  (not bCheckDifference or (Weather.Courant.TempRessentie      <> Backup.Courant.TempRessentie      )) then IssueSensor(Weather.Courant.TempRessentie      ,'felt-temp'   ,'temp'      );
      if ((sensorname='') or (sensorname='barometer'   )) and  (not bCheckDifference or (Weather.Courant.Pression_Valeur    <> Backup.Courant.Pression_Valeur    )) then IssueSensor(Weather.Courant.Pression_Valeur    ,'barometer'   ,'pressure'  );
      if ((sensorname='') or (sensorname='press-var'   )) and  (not bCheckDifference or (Weather.Courant.Pression_Variation <> Backup.Courant.Pression_Variation )) then IssueSensor(Weather.Courant.Pression_Variation ,'press-var'   ,'generic'   );
      if ((sensorname='') or (sensorname='wind-speed'  )) and  (not bCheckDifference or (Weather.Courant.Vent_Vitesse       <> Backup.Courant.Vent_Vitesse       )) then IssueSensor(Weather.Courant.Vent_Vitesse       ,'wind-speed'  ,'speed'     );
      if ((sensorname='') or (sensorname='wind-gust'   )) and  (not bCheckDifference or (Weather.Courant.Vent_Gust          <> Backup.Courant.Vent_Gust          )) then IssueSensor(Weather.Courant.Vent_Gust          ,'wind-gust'   ,'speed'     );
      if ((sensorname='') or (sensorname='wind-dir'    )) and  (not bCheckDifference or (Weather.Courant.Vent_Sens          <> Backup.Courant.Vent_Sens          )) then IssueSensor(Weather.Courant.Vent_Sens          ,'wind-dir'    ,'direction' );
      if ((sensorname='') or (sensorname='humidity'    )) and  (not bCheckDifference or (Weather.Courant.Humidite           <> Backup.Courant.Humidite           )) then IssueSensor(Weather.Courant.Humidite           ,'humidity'    ,'humidity'  );
      if ((sensorname='') or (sensorname='visibility'  )) and  (not bCheckDifference or (Weather.Courant.Visibilite         <> Backup.Courant.Visibilite         )) then IssueSensor(Weather.Courant.Visibilite         ,'visibility'  ,'distance'  );
      if ((sensorname='') or (sensorname='uv'          )) and  (not bCheckDifference or (Weather.Courant.UV_Indice          <> Backup.Courant.UV_Indice          )) then IssueSensor(Weather.Courant.UV_Indice          ,'uv'          ,'uv'        );
      if ((sensorname='') or (sensorname='dewpoint'    )) and  (not bCheckDifference or (Weather.Courant.Dewp               <> Backup.Courant.Dewp               )) then IssueSensor(Weather.Courant.Dewp               ,'dewpoint'    ,'temp'      );
      if ((sensorname='') or (sensorname='sunrise'     )) and  (not bCheckDifference or (Weather.Localite.Sunrise           <> Backup.Localite.Sunrise           )) then IssueSensor(Weather.Localite.Sunrise           ,'sunrise'     ,'generic'   );
      if ((sensorname='') or (sensorname='sunset'      )) and  (not bCheckDifference or (Weather.Localite.Sunset            <> Backup.Localite.Sunset            )) then IssueSensor(Weather.Localite.Sunset            ,'sunset'      ,'generic'   );
      if ((sensorname='') or (sensorname='moon-phase'  )) and  (not bCheckDifference or (Weather.Courant.Lune_Texte         <> Backup.Courant.Lune_Texte         )) then IssueSensor(Weather.Courant.Lune_Texte         ,'moon-phase'  ,'generic'   );
   end;
end;

procedure TxPLweatherListener.OnReceived(const axPLMsg: TxPLMessage);
begin
   with axPLMsg do begin
      if (Schema.RawxPL = 'timer.basic') and                                   // Received a timer status message
         (Body.GetValueByKey('device') = Adresse.Device) and                   // from the timer I created
         (Body.GetValueByKey('current') = 'started') then begin                // that says he's alive
         SendMessage( cmnd, DeviceAddress('netget'),'netget.basic',            // Ask the download of the file
                                ['protocol','uri','destdir','destfn'],
                                ['http',fURI,GetTempDir,'weather.xml']);
      end else
      if ((Schema.RawxPL = 'netget.basic') and (Body.GetValueByKey('uri') = fURI) and (Body.GetValueByKey('current') = 'done')) or
         ((Schema.RawxPL = 'sensor.request') and (axPLMsg.Body.GetValueByKey('request')='current'))
         then begin
            Weather.MettreAJour(GetTempDir + 'weather.xml', Config.GetItemValue('unitsystem'));
            Log(etInfo,'Weather data loaded for %s',[Weather.Localite.Name]);
            SendSensors(true);
            Backup.Assign(Weather);
         end;
   end;
end;

procedure TxPLweatherListener.OnPrereqMet;
var s: string;
begin
   s := DeviceAddress('timer');
   s := DeviceAddress('netget');
   SendMessage( cmnd, DeviceAddress('timer'), 'timer.basic',
                      ['action','device','frequence'],['start',Adresse.Device,IntToStr(30 * 60)]);
end;


procedure TxPLweatherListener.GetData(const aSuperObject : ISuperObject);

begin
   inherited;
//   streamer := TJSONStreamer.Create(self);
//   jso := streamer.ObjectToJSON(self);
//   s := jso.AsJSON;
//   aSuperObject.S['e'] := s;
//   streamer.Free;
   //aSuperObject.S['description' ] := Weather.Courant.Texte;
   //aSuperObject.S['temperature' ] := Weather.Courant.Temperature;
   //aSuperObject.S['felt-temp'   ] := Weather.Courant.TempRessentie;
   //aSuperObject.S['barometer'   ] := Weather.Courant.Pression.Valeur;
   //aSuperObject.S['press-var'   ] := Weather.Courant.Pression.Variation;
   //aSuperObject.S['wind-speed'  ] := Weather.Courant.Vent.Vitesse;
   //aSuperObject.S['wind-gust'   ] := Weather.Courant.Vent.Gust;
   //aSuperObject.S['wind-dir'    ] := Weather.Courant.Vent.Sens;
   //aSuperObject.S['humidity'    ] := Weather.Courant.Humidite ;
   //aSuperObject.S['visibility'  ] := Weather.Courant.Visibilite;
   //aSuperObject.S['uv'          ] := Weather.Courant.UV.Indice ;
   //aSuperObject.S['dewpoint'    ] := Weather.Courant.Dewp      ;
   //aSuperObject.S['sunrise'     ] := Weather.Localite.Sunrise  ;
   //aSuperObject.S['sunset'      ] := Weather.Localite.Sunset   ;
   //aSuperObject.S['moon-phase'  ] := Weather.Courant.Lune.Texte;

//   aSuperObject['path[0]'] := TSuperObject.Create(stArray);
//   aSuperObject['path[0]'] := SA(['string',true,1.2]);

//   aSuperObject.S['path[0]'] := 'chaine';
//   aSuperObject['path[2]'] := TSuperObject.Create(stArray);
//   aSuperObject['path[1]'] := SA(['trois',true,1.2]);
//   aSuperObject.ForcePath('path',stArray);

//   arr := TSuperObject.Create;
//   for i:=0 to 10 do begin
////         prev := aSuperObject['prevs[' + intToStr(i) + ']'];
//         prev := TSuperObject.Create;
//         prev.I['prev'] := i;
////         arr.AsArray.Add(prev);
//         aSuperObject['prevs[]'] := prev;
//   end;
//   so['prevs'] := arr;
//   so.ForcePath('prevs',stArray);

      //   for i:=0 to 10 do begin
      //    s := StrReplace('{%fcday'+inttostr(i)+'%}'             ,Weather.Previsions.Jours[i].JourSemaine,s,false);
      //    s := StrReplace('{%fcdate'+inttostr(i)+'%}'            ,Weather.Previsions.Jours[i].ChaineDateJour,s,false);
      //    s := StrReplace('{%fcmintemp'+inttostr(i)+'%}'         ,Weather.Previsions.Jours[i].Mini,s,false);
      //    s := StrReplace('{%fcmaxtemp'+inttostr(i)+'%}'         ,Weather.Previsions.Jours[i].Maxi,s,false);
      //    s := StrReplace('{%fcsunrise'+inttostr(i)+'%}'         ,Weather.Previsions.Jours[i].LeverSoleil,s,false);
      //    s := StrReplace('{%fcsunset'+inttostr(i)+'%}'          ,Weather.Previsions.Jours[i].CoucherSoleil,s,false);
      //    s := StrReplace('{%fcdayweathericon'+inttostr(i)+'%}'  ,Weather.Previsions.Jours[i].Jour.Icone,s,false);
      //    s := StrReplace('{%fcdayweatherdesc'+inttostr(i)+'%}'  ,xPLAppFramework.Translate('weather',Weather.Previsions.Jours[i].Jour.Texte),s,false);
      //    s := StrReplace('{%fcdaywind-speed'+inttostr(i)+'%}'   ,Weather.Previsions.Jours[i].Jour.Vent.Vitesse,s,false);
      //    s := StrReplace('{%fcdaywind-gust'+inttostr(i)+'%}'    ,Weather.Previsions.Jours[i].Jour.Vent.Gust,s,false);
      //    s := StrReplace('{%fcdaywind-dir'+inttostr(i)+'%}'     ,xPLAppFramework.Translate('winddir',Weather.Previsions.Jours[i].Jour.Vent.Sens),s,false);
      //    s := StrReplace('{%fcdayrainprob'+inttostr(i)+'%}'     ,Weather.Previsions.Jours[i].Jour.RisquePrecipitation,s,false);
      //    s := StrReplace('{%fcdayhumidity'+inttostr(i)+'%}'     ,Weather.Previsions.Jours[i].Jour.Humidite,s,false);
      //    s := StrReplace('{%fcnightweathericon'+inttostr(i)+'%}',Weather.Previsions.Jours[i].Nuit.Icone,s,false);
      //    s := StrReplace('{%fcnightweatherdesc'+inttostr(i)+'%}',xPLAppFramework.Translate('weather',Weather.Previsions.Jours[i].Nuit.Texte),s,false);
      //    s := StrReplace('{%fcnightwind-speed'+inttostr(i)+'%}' ,Weather.Previsions.Jours[i].Nuit.Vent.Vitesse,s,false);
      //    s := StrReplace('{%fcnightwind-gust'+inttostr(i)+'%}'  ,Weather.Previsions.Jours[i].Nuit.Vent.Gust,s,false);
      //    s := StrReplace('{%fcnightwind-dir'+inttostr(i)+'%}'   ,xPLAppFramework.Translate('winddir',Weather.Previsions.Jours[i].Nuit.Vent.Sens),s,false);
      //    s := StrReplace('{%fcnightrainbrob'+inttostr(i)+'%}'   ,Weather.Previsions.Jours[i].Nuit.RisquePrecipitation,s,false);
      //    s := StrReplace('{%fcnighthumidity'+inttostr(i)+'%}'   ,Weather.Previsions.Jours[i].Nuit.Humidite,s,false);
      //end;
end;


initialization
   Schema_DDBasic := 'weather.basic';

end.

