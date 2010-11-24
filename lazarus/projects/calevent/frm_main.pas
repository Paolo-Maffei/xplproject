unit frm_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus,

  SunTime,
  uxPLEvent,
  uxPLConfig,
  uxPLMessage,
  uxPLMsgBody,
  uxPLListener;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    lvEvents: TListView;
    MainMenu1: TMainMenu;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
        fSunTime   : TSuntime;
        Dawn, Dusk, Noon : TxPLSunEvent;
        fSpring,fWinter,fSummer,fAutumn : TxPLSeasonEvent;
        fEventList : TxPLEventList;
    { private declarations }
  public
        procedure OnConfigDone(const fConfig : TxPLConfig);
        procedure OnReceive(const axPLMsg : TxPLMessage);
        procedure OnHBeatPrepare(const aBody   : TxPLMsgBody);
    { public declarations }
  end; 

var
  FrmMain: TFrmMain;


implementation //===============================================================
uses MOON,
     app_main,
     StrUtils,
     XMLRead,
     DateUtils,
     uxPLConst;

{==============================================================================}
const
     K_CONFIG_LATITUDE    = 'latitude';
     K_CONFIG_LONGITUDE   = 'longitude';
//     K_GMAPS_LAT_QRY      = '<lat>(.*?)</lat>';
//     K_GMAPS_LNG_QRY      = '<lng>(.*?)</lng>';
//     K_GMAPS_URL          = 'http://maps.googleapis.com/maps/api/geocode/xml?address=%s+%s&sensor=false';

procedure TFrmMain.FormCreate(Sender: TObject);
begin
   fSuntime := TSuntime.Create(self);
   xPLClient := TxPLListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER,false);
   with xPLClient do begin
       OnxPLConfigDone    := @OnConfigDone;
       OnxPLReceived      := @OnReceive;
//       OnxPLPrereqMet     := @OnPrereqMet;
       OnxPLHBeatPrepare  := @OnHBeatPrepare;
       Config.AddItem(K_CONFIG_LATITUDE, K_XPL_CT_CONFIG,'',''(*K_RE_LATITUDE*),1);
       Config.AddItem(K_CONFIG_LONGITUDE,K_XPL_CT_CONFIG,'',''(*K_RE_LONGITUDE*),1);
       PrereqList.Add('netget=0');
       Listen;
   end;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
   fSuntime.Destroy;
   fEventList.Destroy;
   xPLClient.Destroy;
end;

procedure TFrmMain.OnConfigDone(const fConfig: TxPLConfig);
begin
   fEventList:= TxPLEventList.Create(xPLClient,frmMain.lvEvents);
   fSuntime.Latitude.Value  := StrToFloat(xPLClient.Config.ItemName[K_CONFIG_LATITUDE].Value);
   fSuntime.Longitude.Value := StrToFloat(xPLClient.Config.ItemName[K_CONFIG_LONGITUDE].Value);

   Dawn := TxPLSunEvent.Create(xPLClient.Address,fSuntime,setDawn);
   Dusk := TxPLSunEvent.Create(xPLClient.Address,fSuntime,setDusk);
   Noon := TxPLSunEvent.Create(xPLClient.Address,fSuntime,setNoon);

   fSpring := TxPLSeasonEvent.Create(Spring);
   fWinter := TxPLSeasonEvent.Create(Winter);
   fAutumn := TxPLSeasonEvent.Create(Autumn);
   fSummer := TxPLSeasonEvent.Create(Summer);

   fEventList.Add('dawn',Dawn);
   fEventList.Add('dusk',Dusk);
   fEventList.Add('noon',Noon);
   fEventList.Add('Spring',fSpring);
   fEventList.Add('Winter',fWinter);
   fEventList.Add('Autumn',fAutumn);
   fEventList.Add('Summer',fSummer);
end;

procedure TFrmMain.OnReceive(const axPLMsg: TxPLMessage);
   procedure DawnDuskRequest;
   var level, delta, lag : longint;
       status,query : string;
       fixdawn, fixnoon : TDateTime;
   begin
       query := axPLMsg.Body.GetValueByKey('query','dawndusk');
       if query ='daynight'
          then status := IfThen (Dawn.Next>Dusk.Next,'day','night')
          else status := IfThen (Dawn.Next>Dusk.Next,'dawn','dusk');
       level := 0;
       if (status = 'day') or (status='dawn')then begin
          FixDawn := Dawn.Next;
          if FixDawn > Dusk.Next then FixDawn := FixDawn -1;
          FixNoon := Noon.Next;
          if FixNoon > Dusk.Next then FixNoon := FixNoon -1;
          delta := MinutesBetween(Now,FixNoon);
          lag := MinutesBetween(FixDawn,FixNoon);
          level := Round(6/lag * (lag-delta));
       end;
       xPLClient.SendMessage( K_MSG_TYPE_STAT,K_MSG_TARGET_ANY,K_SCHEMA_DAWNDUSK_BASIC,
                              [ 'type',  'status', 'level',         'dawn', 'noon','dusk'],
                              [ query,   status,   IntToStr(level), FormatDateTime('hh:mm:ss',Dawn.Next), FormatDateTime('hh:mm:ss',Noon.Next), FormatDateTime('hh:mm:ss',Dusk.Next) ]);
   end;

begin
   if axPLMsg.Schema.RawxPL = K_SCHEMA_DAWNDUSK_REQUEST then DawnDuskRequest;
end;

procedure TFrmMain.OnHBeatPrepare(const aBody: TxPLMsgBody);
var latest_season : TxPLSeasonEvent;
begin
   aBody.AddKeyValuePairs(['status'],[IfThen (Dawn.Next>Dusk.Next,'day','night')]);
   latest_season := fSpring;
   if fSummer.Next > latest_season.Next then latest_season := fsummer;
   if fAutumn.Next > latest_season.Next then latest_season := fAutumn;
   if fWinter.Next > latest_season.Next then latest_season := fWinter;
   aBody.AddKeyValuePairs(['season'],[latest_season.name]);
end;

//procedure TFrmMain.OnPrereqMet;
//var city, country : string;
//
//begin
//   city := xPLClient.Settings.ReadKeyString(K_SET_CITY);
//   country := xPLClient.Settings.ReadKeyString(K_SET_COUNTRY);      //aMsg : TxPLMessage;
//
//   xPLClient.SendMessage( K_MSG_TYPE_CMND,xPLClient.PrereqList.Values['netget'],K_SCHEMA_NETGET_BASIC,
//                                ['protocol','uri','destdir','destfn'],['http',Format(K_GMAPS_URL,[city,country]),GetTempDir,'gmaps.xml']);
//end;

initialization
  {$I frm_main.lrs}

end.

