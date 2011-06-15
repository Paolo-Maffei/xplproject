{

Composant de lecture de la météo sur weather.com
Version 1
Ecris par Roud59

INTRODUCTION
------------

  Suite à une question sur le forum DelphiFR,  voici un composant qui interroge le serveur
  wheater.com et récupère les informations et prévisions météo d'une région donnée.

  Wheather.com actualise les conditions courantes toutes les 30mn et les prévisions
  pour les jours suivants toutes les 12h.

  Le composant utilise le composant Indy TidHTTP et un composant TXMLDocument.
  XMLDocument sert à l'analyse des résultats. Il n'est pas très rapide mais est simple
  à utiliser.

  Les textes fournis par le serveur sont malheureusement en anglais. Le composant intègre un
  petit système de traduction 'mot à mot' en fonction d'un fichier "dictionnaire.ini".
  Les adjectifs anglais se terminant par 'ed' sont mis à la fin de la chaîne avant traduction
  pour que la traduction soit plus naturelle. Ce fichier est à compléter en fonction des
  phrases données par le serveur. Si quelqu'un connaît un serveur web gennre soap
  qui pourrait traduire les quelques mots, je suis preneur.

UTILISATION DU COMPOSANT
------------------------

  1) Mettre dans ZIP le code de la région voulue (ex: FRXX0052). Si ce code est inconnu, voir 3.

  2) Appeler la methode MettreAJour pour interroger le serveur et remplir les propriétés résultats.
  La methode renvoie True si tout se passe bien, sinon False.

  3) Pour rechercher un code de localité, utiliser la methode ChercherLocalite en lui transmettant
  une chaine, par exemple 'paris'. Elle renvoie les reponses du serveur dans une TString
  contenant des chaines ID=Localite, par exemple :
    FRXX0076=Paris, France
    FRXX0077=Paris/Charles De Gaulle, France
    USAR0433=Paris, AR
    USID0192=Paris, ID
    ...etc...
  La methode renvoie True si le server a été trouvé, sinon false.


DESCRIPTION DES CHAMPS RETOURNES.
---------------------------------

  Tous les champs sont stockés en string car ils sont recus en chaines et sûrement
  destinés à l'affichage ce qui nécessite une chaîne.

  - Informations générales sur la localité

      Localite.Id	: Code du lieu (ex: FRXX0052)
      Localite.Name	: Ville (ex: Lille, France)
      Localite.Time   : Heure locale (ex: 9:43 AM)
      Localite.Latitude : Latitude locale (ex: 50.63)
      Localite.Longitude : Longitude locale (ex: 3.07)
      Localite.Sunrise : Heure du lever du soleil (ex: 7:41 AM)
      Localite.Sunset : Heure du coucher du soleil (ex: 6:22 PM)
      Loalite.Zone	: ?

  - Informations générales les conditions méteo courantes (Mises à jour par weather.com
    toutes les 30 mn)

      Courant.ChaineDateHure : Date et heure observation mise à jour toutes les 30 mn (ex: 2/25/06 9:30 AM Local Time)
      Courant.DateHure : ChaineDateHeure en TDateTime
      Courant.Lieu = Localite.Name
      Courant.Temperature : Température mesurée en °C (ex: -1)
      Courant.TempRessentie : Température ressentie en °C (ex: -7)
      Courant.Texte : Description (ex: Fair)
      Courant.TexteFrancais : Description traduite en français (ex: Beau temps)
      Courant.Icone : N° de l'icône décrivant le temps (ex: 34)
      Courant.Pression.Valeur : Pression acuelle en mb (ex: 1013.9à
      Courant.Pression.Variation : Variation de la pression (ex: steady)
      Courant.Vent.Vitesse : Vitesse du vent en km/h (ex: 26)
      Courant.Vent.Gust : ? (ex: N/A)
      Courant.Vent.Degres : Orientation du vent en degres (ex: 26)
      Courant.Vent.Sens : Orientation du vent (ex: NE)
      Courant.Humidite : Taux d'humidité en %(ex: 60)
      Courant.Visiblite : Visibilité en km (ex: 10.0)
      Courant.UV.Indice : Indice UV (ex: 0)
      Courant.UV.Texte : Description indice UV (ex: Low)
      Courant.UV.TexteFrancais : Description indice UV en français(ex: Faible)
      Courant.Dewp : ? (ex: -4)
      Courant.Lune.Icone : Icone description de la lune
      Courant.Lune.Texte : Texte description (ex: Waning Crescent)
      Courant.Lune.TexteFrancais : Texte description en français

  - Previsions sur 10 jours (0 = aujourd'hui) (Mises à jour par weather.com
    toutes les 12h)

      Previsions.ChaineDateJour : Date et heure de mise à jour des prévisions (ex: 2/25/06 7:21 AM Local Time)
      Previsions.DateJour : ChaineDateJour en TDateTime
      Previsions.Jours[0..10].JourSemaine : Jour de la prévision (ex: Saturday)
      Previsions.Jours[0..10].Date : date de la prévision (ex: Feb 25)
      Previsions.Jours[0..10].Mini : température mini en °C (ex: -3)
      Previsions.Jours[0..10].Maxi : température maxi en °C (ex: 3)
      Previsions.Jours[0..10].LeverSoleil : Heure du lever du soleil (ex: 7:41 AM)
      Previsions.Jours[0..10].CoucherSoleil : Heure du coucher du soleil (ex: 6:22 PM)
      Previsions.Jours[0..10].Jour.Icone : N° de l'icône décrivant le temps dans la journée (ex: 34)
      Previsions.Jours[0..10].Jour.Texte : Description dans la journée (ex: Partly Cloudy)
      Previsions.Jours[0..10].Jour.TexteFrancais : Description traduite en français (ex: Partiellement nuageux)
      Previsions.Jours[0..10].Jour.Resume : Desctiption courte dans la journée (ex: P Cloudy)
      Previsions.Jours[0..10].Jour.Vent.Vitesse : Vitesse du vent dans la journée en km/h (ex: 26)
      Previsions.Jours[0..10].Jour.Vent.Gust : ? dans la journée (ex: N/A)
      Previsions.Jours[0..10].Jour.Vent.Sens : Orientation du vent dans la journée (ex: NE)
      Previsions.Jours[0..10].Jour.Vent.Degres : Orientation du vent en degres dans la journée (ex: 26)
      Previsions.Jours[0..10].Jour.RisquePrecipitation : Risque de pluie dans la journée en % (ex: 10)
      Previsions.Jours[0..10].Jour.Himite : Taux d'humidité en %dans la journée (ex: 60)
      Previsions.Nuits[0..10].Nuit.Icone : N° de l'icône décrivant le temps dans la nuit (ex: 34)
      Previsions.Nuits[0..10].Nuit.Texte : Description dans la nuit (ex: Partly Cloudy)
      Previsions.Nuits[0..10].Nuit.TexteFrancais : Description traduite en français (ex: Partiellement nuageux)
      Previsions.Nuits[0..10].Nuit.Resume : Desctiption courte dans la nuit (ex: P Cloudy)
      Previsions.Nuits[0..10].Nuit.Vent.Vitesse : Vitesse du vent dans la nuit en km/h (ex: 26)
      Previsions.Nuits[0..10].Nuit.Vent.Gust : ? dans la nuit (ex: N/A)
      Previsions.Nuits[0..10].Nuit.Vent.Sens : Orientation du vent dans la nuit (ex: NE)
      Previsions.Nuits[0..10].Nuit.Vent.Degres : Orientation du vent en degres dans la nuit (ex: 26)
      Previsions.Nuits[0..10].Nuit.RisquePrecipitation : Risque de pluie dans la nuit en % (ex: 10)
      Previsions.Nuits[0..10].Nuit.Himite : Taux d'humidité en %dans la nuit (ex: 60)
}
{$mode objfpc}{$H+}
unit Weathers;

interface

uses
  Classes, SysUtils;

type

  { TLocalite }

  TLocalite = class(TPersistent)    // Structure décrivant le lieu choisi
  private
     fId,fName,fTime,fLatitude,fLongitude,fSunrise,fSunset,fZone : string;
  published
    property Id : string read FId write fId;
    property Name : string read FName write fName;
    property Time : string read FTime write fTime;
    property Latitude : string read FLatitude write fLatitude;
    property Longitude : string read FLongitude write fLongitude;
    property Sunrise : string read FSunrise write fSunrise;
    property Sunset : string read FSunset write fSunset;
    property Zone : string read FZone write fZone;
  end;

  TCourant = class(TPersistent)    // Structure décrivant les conditions métés en cours
    private
    fChaineDateHeure: string;
//    fLieu: string;
    fTemperature: string;
    fTempRessentie: string;
    fTexte: string;
    fIcone : string;
    fTimeStamp : TDateTime;
    fPression_Valeur : string;
    fPression_Variation : string;
    fVent_Vitesse : string;
    fVent_Gust : string;
    fVent_Sens : string;
    fVent_Degres : string;
    fHumidite : string;
    fVisibilite : string;
    fUV_Indice : string;
    fUV_Texte : string;
    fDewp : string;
    fLune_Icone : string;
    fLune_Texte : string;
  published
    property ChaineDateHeure: string read fChaineDateHeure;
    property Temperature: string read fTemperature;
    property TempRessentie: string read fTempressentie;
    property Texte: string read fTexte;
    property Icone : string read fIcone;
    property Pression_Valeur : string read fPression_Valeur;
    property Pression_Variation : string read fPression_Variation;
    property Vent_Vitesse : string read fVent_Vitesse;
    property Vent_Gust : string read fVent_Gust;
    property Vent_Sens : string read fVent_Sens;
    property Vent_Degres : string read fVent_Degres;
    property Humidite : string read fHumidite;
    property Visibilite : string read fVisibilite;
    property UV_Indice : string read fUV_Indice;
    property UV_Texte : string read fUV_Texte;
    property Dewp : string read fDewp;
    property Lune_Icone : string read fLune_Icone;
    property Lune_Texte : string read fLune_Texte;
  end;

  TDemiPrevision = record  // Structure stockant les infos pour 1/2 journée, jour ou nuit
    Icone : string;
    Texte : string;
    Resume : string;
    Vent : record
      Vitesse, Gust, Sens, Degres : string;
    end;
    RisquePrecipitation : string;
    Humidite : string;
  end;

  TPrevision = record     // Description de prévisions méteo pour une journée
    JourSemaine, ChaineDateJour : string;
    Mini, Maxi : string;
    LeverSoleil, CoucherSoleil : String;
    Jour, Nuit : TDemiPrevision;
  end;

  TPrevisions = record   // Description de la météo à 10 jours
    DateHeure : string;
    Jours : array[0..10] of TPrevision;  // 0 = aujourd'hui
  end;

  { TWeather }
  TWeather = class(TPersistent)
  private
     fSystem    : string;
     FCourant : TCourant;
     Previsions : TPrevisions;
     FLocalite   : TLocalite;

     function StoreDegreeValue  (aValue : string) : string;
     function StorePressureValue(aValue : string) : string;
     function StoreSpeedValue   (aValue : string) : string;
  public
     constructor Create;
     destructor Destroy; override;
     function MettreAJour(aFile : string; aSystem : string) : boolean;
     procedure Assign(aWeather : TWeather); overload;

  published
     property Courant  : TCourant  read fCourant;
     property Localite : TLocalite read FLocalite;
  end;

implementation {====================================================================================}
uses DateUtils,
     StrUtils,
     DOM,
     XMLRead,
     cStrings,
     StdConvs,
     ConvUtils;

const
   rsMetric = 'metric';
   rsNA = 'N/A';

{ Utility functions ===========================================================}
function WeatherDt2Dt(aDateTime : string) : TDateTime;                         // Takes a string like : 7/29/09 02:30 PM Local Time
var year,month,day,hour,minute,left,right : string;                            //         and returns  20090729143000

begin
   StrSplitAtChar(aDateTime,'/',month,right);                                  // First, get the month
   StrSplitAtChar(right,'/',day,right);                                        // Then get the day
   StrSplitAtChar(right,' ',year,right);
   year := '20' + year;

   StrSplitAtChar(right,':',hour,right);
   StrSplitAtChar(right,' ',minute,right);
   StrSplitAtChar(right,'M',left,right);
   hour := ifthen(strToint(hour)<12,hour,'00');
   if left = 'P' then hour := IntToStr(12+StrToInt(hour));
   result := EncodeDateTime( StrToInt(year),StrToInt(Month),StrToInt(Day),
                             StrToInt(Hour),StrToInt(Minute),0,0);
end;

function WeatherDt2XPLDt(const aDateTime : string) : string;                   // Takes a string like : 07/2/09 02:30 PM Local Time
var    dt : tdatetime;                                                         //         and returns  20090729143000
begin
   dt := WeatherDt2Dt(aDateTime);
   result := FormatDateTime('yyyymmddhhmm',dt) + '00';
end;

{ TLocalite }


{ TWeather ====================================================================}
function TWeather.StoreDegreeValue(aValue : string) : string;                  // by default, weather.com supplies values in farenheit
var adb : double;
begin                                                                          // let's translate it
    result := aValue;
    result := AnsiReplaceStr(result,'.',',');
    if result = rsNA then exit;

    if fSystem = rsMetric then begin
       adb := CelsiusToFahrenheit ( StrToFloat( result));                      // there's an error in fpc library, both functions seems interverted...
       adb := Round(adb);
       result := FloatToStr( adb);
    end;
end;

function TWeather.StorePressureValue(aValue : string) : string;                // by default, weather.com supplies values in inches of mercury
var adb : double;
begin                                                                          // let's translate it
    result := aValue;
    result := AnsiReplaceStr(result,'.',',');
    if result = rsNA then exit;

    if fSystem = rsMetric then begin
       adb := StrToFloat(result);                                              // 29,94 inch
       adb := Convert(adb,duInches,duMillimeters);                             // 760   mm HG
       adb := adb * 1.33322;                                                   // 1013,549548  hPA ou/et millibar
       adb := Round(adb);                                                      // 1014
       result := FloatToStr(adb);
    end;
end;

function TWeather.StoreSpeedValue(aValue : string) : string;                   // by default, weather.com supplies values in miles per hour
var adb : double;
begin                                                                          // let's translate it
    result := aValue;
    result := AnsiReplaceStr(result,'.',',');
    if aValue = rsNA then exit;

    if fSystem = rsMetric then begin
       adb := StrToFloat(result);
       adb := Convert(adb,duMiles,duKilometers);
       adb := Round(adb);
       result := FloatToStr(adb);
    end;
end;

constructor TWeather.Create;
begin
  inherited;
  fLocalite := TLocalite.Create;
  fCourant  := TCourant.Create;
end;

destructor TWeather.Destroy;
begin
  fLocalite.Free;
  fCourant.Free;
  inherited Destroy;
end;

function TWeather.MettreAJour(aFile : string; aSystem : string) : boolean;
var aDoc : TXMLDocument;
    N,N2 : TDOMNode;
    NL : TDOMNodeList;
    i : integer;

  // Récupération de la prévision d'une demi journée <part>...</part>
  procedure RecupererPrevisionDemiJour(var P : TDemiPrevision; Node : TDOMNode);
  var N2 : TDOMNode;
  begin
    with Node do begin
      P.Icone := FindNode('icon').FirstChild.NodeValue;
      P.Texte := FindNode('t').FirstChild.NodeValue;
      P.Resume := FindNode('bt').FirstChild.NodeValue;
      P.RisquePrecipitation := FindNode('ppcp').FirstChild.NodeValue;
      P.Humidite := FindNode('hmid').FirstChild.NodeValue;
      N2 := N.FindNode('wind');
      with P, N2 do begin
        Vent.Vitesse := StoreSpeedValue(FindNode('s').FirstChild.NodeValue);
        Vent.Gust := StoreSpeedValue(FindNode('gust').FirstChild.NodeValue);
        Vent.Degres := FindNode('d').FirstChild.NodeValue;
        Vent.Sens := FindNode('t').FirstChild.NodeValue;
      end;
    end;
  end;

  // Récupération d'une prévision journalière <day>...</day>
  procedure RecupererPrevisionJour(var P : TPrevision; Node : TDOMNode);
  var
    i : integer;
  begin
    P.JourSemaine := TDOMElement(Node).GetAttribute('t');
    P.ChaineDateJour := TDOMElement(Node).GetAttribute('dt');

    with Node do begin
      P.Mini := StoreDegreeValue(FindNode('low').FirstChild.NodeValue);
      P.Maxi := StoreDegreeValue(FindNode('hi').FirstChild.NodeValue);
      P.LeverSoleil   := TimeToStr(StrToTime(FindNode('sunr').FirstChild.NodeValue)); // Change 6:20 AM to 06:20:00
      P.CoucherSoleil := TimeToStr(StrToTime(FindNode('suns').FirstChild.NodeValue));
      for i := 0 to Node.ChildNodes.Count -1 do begin
        N := Node.ChildNodes[i];
        if N.NodeName = 'part' then
          case String(TDOMElement(N).GetAttribute('p'))[1] of
            'd' : RecupererPrevisionDemiJour(P.Jour, N);
            'n' : RecupererPrevisionDemiJour(P.Nuit, N);
          end;
      end;
    end;
  end;


begin
  fSystem := aSystem;
  Result := false;

  aDoc := TXMLDocument.Create;
  with aDoc do try
        ReadXMLFile(aDoc,aFile);

        N := DocumentElement.FindNode('loc');
        FLocalite.ID := TDOMElement(N).GetAttribute('id');
        FLocalite.Name := N.FindNode('dnam').FirstChild.NodeValue ;
        FLocalite.Zone := N.FindNode('zone').FirstChild.NodeValue ;
        FLocalite.Latitude := N.FindNode('lat').FirstChild.NodeValue ;
        FLocalite.Longitude := N.FindNode('lon').FirstChild.NodeValue ;
        FLocalite.Time    := TimeToStr(StrToTime(N.FindNode('tm')  .FirstChild.NodeValue));  // Change originial 07:31 PM to 19:31:00
        FLocalite.Sunrise := TimeToStr(StrToTime(N.FindNode('sunr').FirstChild.NodeValue));  // Change originial 07:31 PM to 19:31:00
        FLocalite.Sunset  := TimeToStr(StrToTime(N.FindNode('suns').FirstChild.NodeValue));  // Change originial 07:31 PM to 19:31:00

        N := DocumentElement.FindNode('cc');
        FCourant.fChaineDateHeure := WeatherDt2XPLDt(N.FindNode('lsup').FirstChild.NodeValue);
        FCourant.fTimeStamp := WeatherDt2DT(N.FindNode('lsup').FirstChild.NodeValue);
//        FCourant.fLieu := N.FindNode('obst').FirstChild.NodeValue ;
        FCourant.fTexte := N.FindNode('t').FirstChild.NodeValue ;
        FCourant.fIcone := N.FindNode('icon').FirstChild.NodeValue ;

        FCourant.fTemperature := StoreDegreeValue(N.FindNode('tmp').FirstChild.NodeValue);
        FCourant.fTempRessentie := StoreDegreeValue(N.FindNode('flik').FirstChild.NodeValue);

        N2 := N.FindNode('bar');
        with FCourant, N2 do begin
          fPression_Valeur := StorePressureValue(FindNode('r').FirstChild.NodeValue);
          fPression_Variation := FindNode('d').FirstChild.NodeValue;
        end;

        N2 := N.FindNode('wind');
        with FCourant, N2 do begin
          fVent_Vitesse := StoreSpeedValue(FindNode('s').FirstChild.NodeValue);
          fVent_Gust := StoreSpeedValue(FindNode('gust').FirstChild.NodeValue);
          fVent_Degres := FindNode('d').FirstChild.NodeValue;
          fVent_Sens := FindNode('t').FirstChild.NodeValue;
        end;

        FCourant.fHumidite := N.FindNode('hmid').FirstChild.NodeValue;
        FCourant.fVisibilite := StoreSpeedValue(N.FindNode('vis').FirstChild.NodeValue);

        N2 := N.FindNode('uv');
        with FCourant, N2 do begin
          fUV_Indice := FindNode('i').FirstChild.NodeValue;
          fUV_Texte := FindNode('t').FirstChild.NodeValue;
        end;

        FCourant.fDewp := StoreDegreeValue(N.FindNode('dewp').FirstChild.NodeValue);
        N2 := N.FindNode('moon');
        with FCourant, N2 do begin
          fLune_Icone := FindNode('icon').FirstChild.NodeValue;
          fLune_Texte := FindNode('t').FirstChild.NodeValue;
        end;

        // Lecture des prévisions
        N := DocumentElement.FindNode('dayf');

        N2 := N.FindNode('lsup');
        Previsions.DateHeure := WeatherDt2XPLDt(N2.FirstChild.NodeValue);

        NL := N.ChildNodes;
        for i := 0 to NL.Count-1 do           // Parcourir les noeud de DAYF
          if NL[i].NodeName = 'day' then      // On a trouvé une prévision
             RecupererPrevisionJour(Previsions.Jours[StrToInt(TDOMElement(NL[i]).GetAttribute('d'))], NL[i]);

        result := true;
     finally
        free;
     end;
end;

procedure TWeather.Assign(aWeather: TWeather);
begin
   fSystem     := aWeather.fSystem;
   FCourant    := aWeather.FCourant;
   FLocalite   := aWeather.fLocalite;
end;


end.


