unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  ComCtrls, Menus, ActnList, ExtCtrls, StdCtrls, Grids, EditBtn,
  Buttons,uxPLMessage, uxPLWebListener, uxPLConfig,
  Weathers, XMLPropStorage, IdCustomHTTPServer;


type

  { TfrmMain }

  TfrmMain = class(TForm)
    About: TAction;
    acInstalledApps: TAction;
    ActionList2: TActionList;
    Memo1: TMemo;
    MenuItem2: TMenuItem;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    XMLPropStorage1: TXMLPropStorage;

    procedure AboutExecute(Sender: TObject);
    procedure acInstalledAppsExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure SendSensors(bCheckDifference : boolean);
    procedure Timer1Timer(Sender: TObject);
  private
    Weather,Backup : TWeather;

  public
    xPLClient  : TxPLWebListener;
    procedure LogUpdate(const aList : TStringList);
    procedure OnSensorRequest(const axPLMsg : TxPLMessage; const aDevice : string; const aAction : string);
    procedure OnConfigDone(const fConfig : TxPLConfig);
    procedure CommandGet(var aPageContent : widestring; ARequestInfo: TIdHTTPRequestInfo);
  end;

var  frmMain: TfrmMain;

implementation //======================================================================================
uses frm_about, frm_xplappslauncher,StrUtils,uxPLCfgItem,uxPLMsgHeader,  LCLType, cStrings, uxPLConst;

//=====================================================================================================
resourcestring
     K_XPL_APP_VERSION_NUMBER = '2.0.1';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'weather';
     K_DEFAULT_PORT   = '8333';

//=====================================================================================================
procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.acInstalledAppsExecute(Sender: TObject);
begin frmAppLauncher.Show; end;

procedure TfrmMain.LogUpdate(const aList: TStringList);
begin Memo1.Lines.Add(aList[aList.Count-1]); end;

procedure TfrmMain.FormCreate(Sender: TObject);

procedure initListener;
begin
   xPLClient := TxPLWebListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER, K_DEFAULT_PORT);
   with xPLClient do begin
       OnxPLSensorRequest := @OnSensorRequest;
       OnxPLConfigDone    := @OnConfigDone;
       OnLogUpdate        := @LogUpdate;
       OnCommandGet       := @CommandGet;
       Config.AddItem('partnerid', xpl_ctConfig);
       Config.AddItem('licensekey',xpl_ctConfig);
       Config.AddItem('zipcode'  , xpl_ctConfig);
       Config.AddItem('unitsystem',xpl_ctConfig);
   end;

   xPLClient.Listen;
end;

begin
   InitListener;
   Self.Caption := xPLClient.AppName;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   xPLClient.Destroy;
   if Assigned(Weather) then Weather.Destroy;
   if Assigned(Backup) then Backup.Destroy;
end;

procedure TfrmMain.CommandGet(var aPageContent : widestring; ARequestInfo: TIdHTTPRequestInfo);
var
  s : widestring;
  i : integer;
begin
      s := StrReplace('{%weatherdesc%}',Weather.Courant.Texte,aPageContent,false);
      s := StrReplace('{%weathericon%}',Weather.Courant.Icone,s,false);
      s := StrReplace('{%timestamp%}',Weather.Courant.ChaineDateHeure,s,false);                   // date and time of prevision creation at weather.com
      s := StrReplace('{%description%}',Weather.Courant.Texte,s,false);
      s := StrReplace('{%temperature%}',Weather.Courant.Temperature,s,false);
      s := StrReplace('{%felt-temp%}',Weather.Courant.TempRessentie,s,false);
      s := StrReplace('{%barometer%}',Weather.Courant.Pression.Valeur,s,false);
      s := StrReplace('{%wind-speed%}',Weather.Courant.Vent.Vitesse,s,false);
      s := StrReplace('{%wind-gust%}',Weather.Courant.Vent.Gust,s,false);
      s := StrReplace('{%wind-dir%}',Weather.Courant.Vent.Sens,s,false);
      s := StrReplace('{%pressureevol%}',Weather.Courant.Pression.Variation,s,false);
      s := StrReplace('{%humidity%}',Weather.Courant.Humidite,s,false);
      s := StrReplace('{%visibility%}',Weather.Courant.Visibilite,s,false);
      s := StrReplace('{%uv%}',Weather.Courant.UV.Indice,s,false);
      s := StrReplace('{%uv-desc%}',Weather.Courant.UV.Texte,s,false);
      s := StrReplace('{%dewpoint%}',Weather.Courant.Dewp,s,false);
      s := StrReplace('{%moon%}',Weather.Courant.Lune.Texte,s,false);
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
      s := StrReplace('{%fcdayweatherdesc'+inttostr(i)+'%}'  ,Weather.Previsions.Jours[i].Jour.Texte,s,false);
      s := StrReplace('{%fcdaywind-speed'+inttostr(i)+'%}'   ,Weather.Previsions.Jours[i].Jour.Vent.Vitesse,s,false);
      s := StrReplace('{%fcdaywind-gust'+inttostr(i)+'%}'    ,Weather.Previsions.Jours[i].Jour.Vent.Gust,s,false);
      s := StrReplace('{%fcdaywind-dir'+inttostr(i)+'%}'     ,Weather.Previsions.Jours[i].Jour.Vent.Sens,s,false);
      s := StrReplace('{%fcdayrainprob'+inttostr(i)+'%}'     ,Weather.Previsions.Jours[i].Jour.RisquePrecipitation,s,false);
      s := StrReplace('{%fcdayhumidity'+inttostr(i)+'%}'     ,Weather.Previsions.Jours[i].Jour.Humidite,s,false);
      s := StrReplace('{%fcnightweathericon'+inttostr(i)+'%}',Weather.Previsions.Jours[i].Nuit.Icone,s,false);
      s := StrReplace('{%fcnightweatherdesc'+inttostr(i)+'%}',Weather.Previsions.Jours[i].Nuit.Texte,s,false);
      s := StrReplace('{%fcnightwind-speed'+inttostr(i)+'%}' ,Weather.Previsions.Jours[i].Nuit.Vent.Vitesse,s,false);
      s := StrReplace('{%fcnightwind-gust'+inttostr(i)+'%}'  ,Weather.Previsions.Jours[i].Nuit.Vent.Gust,s,false);
      s := StrReplace('{%fcnightwind-dir'+inttostr(i)+'%}'   ,Weather.Previsions.Jours[i].Nuit.Vent.Sens,s,false);
      s := StrReplace('{%fcnightrainbrob'+inttostr(i)+'%}'   ,Weather.Previsions.Jours[i].Nuit.RisquePrecipitation,s,false);
      s := StrReplace('{%fcnighthumidity'+inttostr(i)+'%}'   ,Weather.Previsions.Jours[i].Nuit.Humidite,s,false);
                         end;

   aPageContent := s;
end;

procedure TfrmMain.OnSensorRequest(const axPLMsg: TxPLMessage; const aDevice: string; const aAction: string);
begin
   if (aDevice = 'weather') and (aAction = 'current') then begin
      Weather.MettreAJour;
      SendSensors(false);
   end;
end;

procedure TfrmMain.OnConfigDone(const fConfig: TxPLConfig);
var ageofinfo : tdatetime;
    hour, min, sec, msec, elapsed, timetoupdate : word;

begin
  if not Assigned(Weather) then begin
     Backup  := TWeather.Create(self);
     Weather := TWeather.Create( self,
                                 xPLClient.Config.ItemName['zipcode'].Value ,
                                 xPLClient.Config.ItemName['licensekey'].Value ,
                                 xPLClient.Config.ItemName['partnerid'].Value ,
                                 xPLClient.Config.ItemName['unitsystem'].Value
             );
     Weather.MettreAJour;                                   // Initialisation des données

     AgeOfInfo  := Now - Weather.Courant.TimeStamp;
     DecodeTime(AgeOfInfo, hour, min, sec, msec);           // Should always be between 0 and 30 minutes
     Elapsed := min * 60 + sec;
     TimeToUpdate := 30* 60 - Elapsed;
     Timer1.Interval := (TimeToUpdate + 120) * 1000;        // Adjust next timer tick to website update
     Timer1.Enabled := True;

     SendSensors(true);
     Backup.Assign(Weather);
  end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
   Timer1.Interval := 30*60*1000;                        // Reset Timer interval to 30mn
   Weather.MettreAJour;
   SendSensors(true);
end;

procedure TfrmMain.SendSensors(bCheckDifference : boolean);
procedure IssueSensor(aValue,aDevice,aType : string);
var aMessage : TxPLMessage;
begin
   aMessage := xPLClient.PrepareMessage(xpl_mtTrig,'sensor.basic');
   aMessage.Body.AddKeyValuePair('device',aDevice);
   aMessage.Body.AddKeyValuePair('type',aType);
   aMessage.Body.AddKeyValuePair('current',aValue);
   aMessage.Body.AddKeyValuePair('timestamp',Weather.Courant.ChaineDateHeure);
   aMessage.Send;
   aMessage.Destroy;
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

      with Weather, Courant do  xPLClient.LogInfo('Data loaded for ' + Lieu);
   end;
end;

initialization
  {$I frm_main.lrs}

end.

