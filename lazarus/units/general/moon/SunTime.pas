{------------------------------------------------------------------------------}
{                                                                              }
{  TSunTime v1.05 -- Calculates times of sunrise, sunset, and solar noon.      }
{  by Kambiz R. Khojasteh                                                      }
{                                                                              }
{  kambiz@delphiarea.com                                                       }
{  http://www.delphiarea.com                                                   }
{  Modified by clinique for integration in Lazarus / xPL project               }
{                                                                              }
{                                                                              }
{  The algorithm is derived from code appearing at                             }
{  http://www.srrb.noaa.gov/highlights/sunrise/sunrise.html                    }
{                                                                              }
{                                                                              }
{  Thanks to:                                                                  }
{                                                                              }
{    :: Laurent PIERRE <laurent.pierre@rivage.com>                             }
{       for providing the time zone functions                                  }
{    :: Marco Gosselink <marco@gosselink.org>                                  }
{       for fixing the bug in calculating the time zone as Day-in-month format }
{                                                                              }
{------------------------------------------------------------------------------}

unit SunTime;

interface

uses SysUtils, Classes;

type

  { TAngle }

  TAngle = class(TPersistent)
  private
    fDegrees: Word;
    fMinutes: Word;
    fSeconds: Word;
    fNegative: Boolean;
    fOnChange: TNotifyEvent;
    procedure SetMinutes(Value: Word);
    procedure SetSeconds(Value: Word);
    procedure SetNegative(Value: Boolean);
    procedure SetValue(AValue: Extended);
    function GetValue: Extended;
    procedure SetRadians(AValue: Extended);
    function GetRadians: Extended;
    procedure DoChange;
  protected
    procedure SetDegrees(Value: Word); virtual;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  public
    procedure Assign(Source: TPersistent); override;
    property Negative: Boolean read fNegative write SetNegative;
    property Degrees: Word read fDegrees write SetDegrees;
    property Minutes: Word read fMinutes write SetMinutes;
    property Seconds: Word read fSeconds write SetSeconds;
    property Value: Extended read GetValue write SetValue;
    property Radians: Extended read GetRadians write SetRadians;
  end;

  TLatitudeDir = (dNorth, dSouth);

  { TLatitude }

  TLatitude = class(TAngle)
  private
    procedure SetDir(aValue: TLatitudeDir);
    procedure SetDir(aValue: String);      overload;
    function GetDir: TLatitudeDir;
  protected
    procedure SetDegrees(aValue: Word); override;
  published
    property Dir: TLatitudeDir read GetDir write SetDir default dNorth;
    property Degrees default 0;
    property Minutes default 0;
    property Seconds default 0;
  end;

  TLongitudeDir = (dWest, dEast);

  { TLongitude }

  TLongitude = class(TAngle)
  private
    procedure SetDir(aValue: TLongitudeDir);
    procedure SetDir(aValue : string);      overload;
    function GetDir: TLongitudeDir;
  protected
    procedure SetDegrees(aValue: Word); override;
  published
    property Dir: TLongitudeDir read GetDir write SetDir default dWest;
    property Degrees default 0;
    property Minutes default 0;
    property Seconds default 0;
  end;

  { TSunTime }

  TSunTime = class(TComponent)
  private
    fDate: TDateTime;
    fTimeZone: Extended;
    fUseSysTimeZone: Boolean;
    fLatitude: TLatitude;
    fLongitude: TLongitude;
    fSunrise: TDateTime;
    fSunset: TDateTime;
    fNoon: TDateTime;
    fReady: Boolean;
    procedure SetDate(Value: TDateTime);
    procedure SetUseSysTimeZone(Value: Boolean);
    procedure SetTimeZone(Value: Extended);
    procedure SetLatitude(Value: TLatitude);
    procedure SetLongitude(Value: TLongitude);
    function IsTimeZoneStored: Boolean;
    procedure LocationChanged(Sender: TObject);
    procedure CalcTimes;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetSunTime(Index: Integer): TDateTime;
    property Date: TDateTime read fDate write SetDate;
  published
    property UseSysTimeZone: Boolean read fUseSysTimeZone write SetUseSysTimeZone default True;
    property TimeZone: Extended read fTimeZone write SetTimeZone stored IsTimeZoneStored;
    property Latitude: TLatitude read fLatitude write SetLatitude;
    property Longitude: TLongitude read fLongitude write SetLongitude;
    property Sunrise: TDateTime index 0 read GetSunTime;
    property Sunset: TDateTime index 1 read GetSunTime;
    property Noon: TDateTime index 2 read GetSunTime;
  end;

implementation

uses
  Math,
  unix,
  baseunix;

{ Helper functions }

// Adjusts the value in the range [L, H)
procedure Adjust(var Value: Extended; const L, H: Extended);
begin
  while Value < L do
    Value := Value + H;
  while Value >= H do
    Value := Value - H;
end;

// Converts degrees to radians
function D2R(const D: Extended): Extended;
begin
  Result := D * Pi / 180.0;
end;

// Converts radians to degrees
function R2D(const R: Extended): Extended;
begin
  Result := R * 180.0 / Pi;
end;

// Converts a date to julian day
function DateToJulian(const Date: TDateTime): Extended;
var
  Year, Month, Day: Word;
  A, B: Integer;
begin
  DecodeDate(Date, Year, Month, Day);
  if Month <= 2 then
  begin
    Dec(Year);
    Inc(Month, 12);
  end;
  A := Year div 100;
  B := 2 - A + A div 4;
  Result := Floor(365.25 * (Year + 4716)) + Floor(30.6001 * (Month + 1)) + Day + B - 1524.5;
end;

{ Time Zone Functions }

function DayOfWeek(const DateTime: TDateTime): Byte;
begin
  // Sunday = 0, Saturday = 1, ...
  Result := DateTimeToTimeStamp(DateTime).Date mod 7;
end;

function DayOfMonthToDate(ADay, ADayOfWeek, AMonth, AYear: Word): TDateTime;
var
  Offset: Integer;
  TempDate: TDateTime;
  DaysInMonth: Word;
begin
  if ADay < 5 then
  begin
    // Start with the first day of the month
    TempDate := EncodeDate(AYear, AMonth, 1);
    Offset := ADayOfWeek - DayOfWeek(TempDate);
    if Offset < 0 then Offset := Offset + 7;
    Result := TempDate + Offset + 7 * (ADay - 1);
  end
  else
  begin
    // Take the last day of the month
    DaysInMonth := MonthDays[(AMonth = 2) and IsLeapYear(AYear), AMonth];
    TempDate := EncodeDate(AYear, AMonth, DaysInMonth);
    Offset := DayOfWeek(TempDate) - ADayOfWeek;
    if Offset < 0 then Offset := Offset + 7;
    Result := TempDate - Offset;
  end;
end;

function GetBiasAtDate(const ADate: TDateTime): Integer;
{$IFNDEF COMPILER4_UP}
const
  TIME_ZONE_ID_INVALID  = $FFFFFFFF;
  TIME_ZONE_ID_UNKNOWN  = 0;
  TIME_ZONE_ID_STANDARD = 1;
  TIME_ZONE_ID_DAYLIGHT = 2;
{$ENDIF}
var
  Info: TTimeVal; //TTimeZoneInformation;
  StdDate, DltDate: TDateTime;
  AYear, AMonth, ADay: Word;
  DaylightOffset: Integer;
begin
  FillChar(Info, SizeOf(Info), 0);
{  GetTimeZoneInformation(Info); TODO  : trouver un équivalent sous linux}
//  Result := Info.Bias;
  Result := Info.tv_sec div 60;
  // Daylight Time is in use
 { if (Info.StandardDate.wMonth <> 0) and (Info.DaylightDate.wMonth <> 0) then
  begin
    DecodeDate(ADate, AYear, AMonth, ADay);
    with Info.StandardDate do
    begin
      if wYear = 0 then
        // Day-in-month format is specified
        StdDate := DayOfMonthToDate(wDay, wDayOfWeek, wMonth, AYear)
                 + EncodeTime(wHour, wMinute, wSecond, wMilliseconds)
      else
        // Exact Date and time (absolute format)
        StdDate := EncodeDate(AYear, wMonth, wDay)
                 + EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
    end;
    with Info.DaylightDate do
    begin
      if wYear = 0 then
        // Day-in-month format is specified
        DltDate := DayOfMonthToDate(wDay, wDayOfWeek, wMonth, AYear)
                 + EncodeTime(wHour, wMinute, wSecond, wMilliseconds)
      else
        // Exact Date and time (absolute format)
        DltDate := EncodeDate(AYear, wMonth, wDay)
                 + EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
    end;
    if StdDate < DltDate then
      if (ADate < StdDate) or (ADate > DltDate) then
        DaylightOffset := Info.DaylightBias
      else
        DaylightOffset := Info.StandardBias
    else
      if (ADate > DltDate) and (ADate < StdDate) then
        DaylightOffset := Info.DaylightBias
      else
        DaylightOffset := Info.StandardBias;
    Inc(Result, DaylightOffset);
  end;       }
end;

{ Solar Position Functions }

// Convert Julian Day to centuries since J2000.0
//   JD : the Julian Day to convert
function GetTimeJulianCent(const JD: Extended): Extended;
begin
   Result := (JD - 2451545.0) / 36525.0;
end;

// Returms the Geometric Mean Longitude of the Sun (in degrees)
//   T : number of Julian centuries since J2000.0
function GetGeomMeanLongSun(const T: Extended): Extended;
begin
  Result := 280.46646 + T * (36000.76983 + 0.0003032 * T);
  Adjust(Result, 0, 360);
end;

// Returns the Geometric Mean Anomaly of the Sun (in degrees)
//   T : number of Julian centuries since J2000.0
function GetGeomMeanAnomalySun(const T: Extended): Extended;
begin
  Result := 357.52911 + T * (35999.05029 - 0.0001537 * T);
end;

// Returns the eccentricity of earth's orbit (unitless)
//   T : number of Julian centuries since J2000.0
function GetEccentricityEarthOrbit(const T: Extended): Extended;
begin
   Result := 0.016708634 - T * (0.000042037 + 0.0000001267 * T);
end;

// Returns the equation of center for the sun (in degrees)
//   T : number of Julian centuries since J2000.0
function GetSunEquationOfCenter(const T: Extended): Extended;
var
  M: Extended;
begin
  M := GetGeomMeanAnomalySun(T);
  Result := Sin(D2R(M)) * (1.914602 - T * (0.004817 + 0.000014 * T))
          + Sin(2 * D2R(M)) * (0.019993 - 0.000101 * T) + Sin(3 * D2R(M)) * 0.000289;
end;

// Returns the true longitude of the sun (in degrees)
//   T : number of Julian centuries since J2000.0
function GetSunTrueLong(const T: Extended): Extended;
var
  L0: Extended;
  C: Extended;
begin
  L0 := GetGeomMeanLongSun(T);
  C := GetSunEquationOfCenter(T);
  Result := L0 + C;
end;

// Returns the true anomaly of the sun (in degrees)
//   T : number of Julian centuries since J2000.0
function GetSunTrueAnomaly(const T: Extended): Extended;
var
  M: Extended;
  C: Extended;
begin
  M := GetGeomMeanAnomalySun(T);
  C := GetSunEquationOfCenter(T);
  Result := M + C;
end;

// Returns the distance to the sun (in AUs)
//   T : number of Julian centuries since J2000.0
function GetSunRadVector(const T: Extended): Extended;
var
  V: Extended;
  E: Extended;
begin
  V := GetSunTrueAnomaly(T);
  E := GetEccentricityEarthOrbit(T);
  Result := (1.000001018 * (1 - E * E)) / (1 + E * Cos(D2R(V)));
end;

// Returns the apparent longitude of the sun (in degrees)
//   T : number of Julian centuries since J2000.0
function GetSunApparentLong(const T: Extended): Extended;
var
  O: Extended;
  Omega: Extended;
begin
  O := GetSunTrueLong(T);
  Omega := 125.04 - 1934.136 * T;
  Result := O - 0.00569 - 0.00478 * Sin(D2R(Omega));
end;

// Returns the mean obliquity of the ecliptic (in degrees)
//   T : number of Julian centuries since J2000.0
function GetMeanObliquityOfEcliptic(const T: Extended): Extended;
var
  Seconds: Extended;
begin
  Seconds := 21.448 - T * (46.8150 + T * (0.00059 - T * (0.001813)));
  Result := 23.0 + (26.0 + (Seconds / 60.0)) / 60.0;
end;

// Returns the corrected obliquity of the ecliptic (in degrees)
//   T : number of Julian centuries since J2000.0
function GetObliquityCorrection(const T: Extended): Extended;
var
  E0: Extended;
  Omega: Extended;
begin
  E0 := GetMeanObliquityOfEcliptic(T);
  Omega := 125.04 - 1934.136 * T;
  Result := E0 + 0.00256 * Cos(D2R(Omega));
end;

// Returns the right ascension of the sun (in degrees)
//   T : number of Julian centuries since J2000.0
function GetSunRtAscension(const T: Extended): Extended;
var
  E: Extended;
  Lambda: Extended;
begin
  E := GetObliquityCorrection(T);
  Lambda := GetSunApparentLong(T);
  Result := R2D(ArcTan2(Cos(D2R(E)) * Sin(D2R(Lambda)), Cos(D2R(Lambda))));
end;

// Returns the declination of the sun (in degrees)
//   T : number of Julian centuries since J2000.0
function GetSunDeclination(const T: Extended): Extended;
var
  E: Extended;
  Lambda: Extended;
begin
  E := GetObliquityCorrection(T);
  Lambda := GetSunApparentLong(T);
  Result := R2D(ArcSin(Sin(D2R(E)) * Sin(D2R(Lambda))));
end;

// Returns the difference between true solar time and mean (in minutes of time)
//   T : number of Julian centuries since J2000.0
function GetEquationOfTime(const T: Extended): Extended;
var
  Epsilon: Extended;
  L0: Extended;
  E: Extended;
  M: Extended;
  Y: Extended;
  ETime: Extended;
begin
  Epsilon := GetObliquityCorrection(T);
  L0 := GetGeomMeanLongSun(T);
  E := GetEccentricityEarthOrbit(T);
  M := GetGeomMeanAnomalySun(T);
  Y := Sqr(Tan(D2R(Epsilon) / 2.0));
  ETime := Y * Sin(2 * D2R(L0)) - 2.0 * E * Sin(D2R(M))
         + 4.0 * E * Y * Sin(D2R(M)) * Cos(2 * D2R(L0))
         - 0.5 * Y * Y * Sin(4 * D2R(L0)) - 1.25 * E * E * Sin(2 * D2R(M));
  Result := R2D(ETime) * 4.0;
end;

//  Returns the hour angle of the sun at sunrise for the latitude (in degrees)
//    Latitude : latitude of observer (in degrees)
//    SolarDec : declination angle of sun (in degrees)
function GetHourAngleSunrise(const Latitude, SolarDec: Extended): Extended;
var
  L: Extended;
  SD: Extended;
  HAarg: Extended;
begin
  L := D2R(Latitude);
  SD := D2R(SolarDec);
  HAarg := Cos(D2R(90.833)) / (Cos(L) * Cos(SD)) - Tan(L) * Tan(SD);
  Result := R2D(ArcCos(HAarg));
end;

//  Returns the hour angle of the sun at sunset for the latitude (in degrees)
//    Latitude : latitude of observer (in degrees)
//    SolarDec : declination angle of sun (in degrees)
function GetHourAngleSunset(const Latitude, SolarDec: Extended): Extended;
var
  L: Extended;
  SD: Extended;
  HAarg: Extended;
begin
  L := D2R(Latitude);
  SD := D2R(SolarDec);
  HAarg := Cos(D2R(90.833)) / (Cos(L) * Cos(SD)) - Tan(L) * Tan(SD);
  Result := -R2D(ArcCos(HAarg));
end;

// Returms the Universal Coordinated Time (UTC) of solar noon for the given
// day at the given location on earth (in minutes)
//   JD  : julian day
//   Longitude : longitude of observer (in degrees)
function GetSolarNoonUTC(const JD, Longitude: Extended): Extended;
var
  T: Extended;
  ETime: Extended;
begin
  T := GetTimeJulianCent(JD + 0.5 + Longitude / 360.0);
  ETime := GetEquationOfTime(T);
  Result := 720 + (Longitude * 4) - ETime;
end;

// Returns the Universal Coordinated Time (UTC) of sunrise for the given day
// at the given location on earth (in minutes)
//   JD  : julian day
//   Latitude : latitude of observer (in degrees)
//   Longitude : longitude of observer (in degrees)
function GetSunriseUTC(const JD, Latitude, Longitude: Extended): Extended;
var
  NoonMin: Extended;
  NoonT: Extended;
  ETime: Extended;
  SolarDec: Extended;
  HourAngle: Extended;
  Delta: Extended;
  TimeDiff: Extended;
  TimeUTC: Extended;
  NewT: Extended;
begin
  NoonMin := GetSolarNoonUTC(JD, Longitude);
  NoonT := GetTimeJulianCent(JD + NoonMin / 1440.0);
  ETime := GetEquationOfTime(NoonT);
  SolarDec := GetSunDeclination(NoonT);
  HourAngle := GetHourAngleSunrise(Latitude, SolarDec);
  Delta := Longitude - HourAngle;
  TimeDiff := 4 * Delta;
  TimeUTC := 720 + TimeDiff - ETime;
  NewT := GetTimeJulianCent(JD + TimeUTC / 1440.0);
  ETime := GetEquationOfTime(NewT);
  SolarDec := GetSunDeclination(NewT);
  HourAngle := GetHourAngleSunrise(Latitude, SolarDec);
  Delta := Longitude - HourAngle;
  TimeDiff := 4 * Delta;
  TimeUTC := 720 + timeDiff - ETime;
  Result := TimeUTC;
end;

// Returns the Universal Coordinated Time (UTC) of sunset for the given day
// at the given location on earth (in minutes)
//   JD  : julian day
//   Latitude : latitude of observer in degrees
//   Longitude : longitude of observer in degrees
function GetSunsetUTC(const JD, Latitude, Longitude: Extended): Extended;
var
  NoonMin: Extended;
  NoonT: Extended;
  ETime: Extended;
  SolarDec: Extended;
  HourAngle: Extended;
  Delta: Extended;
  TimeDiff: Extended;
  TimeUTC: Extended;
  NewT: Extended;
begin
  NoonMin := GetSolarNoonUTC(JD, Longitude);
  NoonT := GetTimeJulianCent(JD + NoonMin / 1440.0);
  ETime := GetEquationOfTime(NoonT);
  SolarDec := GetSunDeclination(NoonT);
  HourAngle := GetHourAngleSunset(Latitude, SolarDec);
  Delta := Longitude - HourAngle;
  TimeDiff := 4 * Delta;
  TimeUTC := 720 + TimeDiff - ETime;
  NewT := GetTimeJulianCent(JD + TimeUTC / 1440.0);
  ETime := GetEquationOfTime(NewT);
  SolarDec := GetSunDeclination(NewT);
  HourAngle := GetHourAngleSunset(Latitude, SolarDec);
  Delta := Longitude - HourAngle;
  TimeDiff := 4 * Delta;
  TimeUTC := 720 + TimeDiff - ETime;
  Result := TimeUTC;
end;

{ TAngle }

procedure TAngle.DoChange;
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TAngle.SetDegrees(Value: Word);
begin
  if Degrees <> Value then
  begin
    fDegrees := Value mod 360;
    DoChange;
  end;
end;

procedure TAngle.SetMinutes(Value: Word);
begin
  if Minutes <> Value then
  begin
    if Value >= 60 then
    begin
      fMinutes := Value mod 60;
      Degrees := Degrees + Value div 60;
    end
    else
    begin
      fMinutes := Value;
      DoChange;
    end;
  end;
end;

procedure TAngle.SetSeconds(Value: Word);
begin
  if Seconds <> Value then
  begin
    if Value >= 60 then
    begin
      fSeconds := Value mod 60;
      Minutes := Minutes + Value div 60;
    end
    else
    begin
      fSeconds := Value;
      DoChange;
    end;
  end;
end;

procedure TAngle.SetNegative(Value: Boolean);
begin
  if Negative <> Value then
  begin
    fNegative := Value;
    DoChange;
  end;
end;

procedure TAngle.SetValue(AValue: Extended);
begin
  Negative := (AValue < 0);
  AValue := Abs(AValue);
  Degrees := Trunc(AValue);
  AValue := Frac(AValue);
  Minutes := Trunc(AValue * 60);
  AValue := Frac(AValue * 60);
  Seconds := Trunc(AValue * 60);
end;

function TAngle.GetValue: Extended;
begin
  Result := Degrees + Minutes / 60 + Seconds / 3600;
  if Negative then Result := -Result;
end;

function TAngle.GetRadians: Extended;
begin
  Result := D2R(Value);
end;

procedure TAngle.SetRadians(AValue: Extended);
begin
  Value := R2D(AValue);
end;

procedure TAngle.Assign(Source: TPersistent);
begin
  if Source is TAngle then
    Value := TAngle(Source).Value
  else
    inherited Assign(Source);
end;

{ TLatitude }

function TLatitude.GetDir: TLatitudeDir;
begin
  if Negative then
    Result := dSouth
  else
    Result := dNorth;
end;

procedure TLatitude.SetDir(aValue: TLatitudeDir);
begin
  Negative := (aValue = dSouth);
end;

procedure TLatitude.SetDir(aValue: String);
begin
  if LowerCase(aValue)='s' then SetDir(dSouth) else SetDir(dNorth);
end;

procedure TLatitude.SetDegrees(aValue: Word);
begin
  while aValue > 90 do
    Dec(aValue, 90);
  inherited SetDegrees(aValue);
end;

{ TLongitude }

function TLongitude.GetDir: TLongitudeDir;
begin
  if Negative then
    Result := dEast
  else
    Result := dWest;
end;

procedure TLongitude.SetDir(aValue: TLongitudeDir);
begin
  Negative := (aValue = dEast);
end;

procedure TLongitude.SetDir(aValue: string);
begin
  if LowerCase(aValue) = 'e' then SetDir(dEast) else SetDir(dWest);
end;

procedure TLongitude.SetDegrees(aValue: Word);
begin
  while aValue > 180 do
    Dec(aValue, 180);
  inherited SetDegrees(aValue);
end;

{ TSunTime }

constructor TSunTime.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  include(fComponentStyle,csSubComponent);
  fLatitude := TLatitude.Create;
  fLatitude.OnChange := @LocationChanged;
  fLongitude := TLongitude.Create;
  fLongitude.OnChange := @LocationChanged;
  fDate := SysUtils.Date;
  SetUseSysTimeZone(True);
end;

destructor TSunTime.Destroy;
begin
  fLatitude.Free;
  fLongitude.Free;
  inherited Destroy;
end;

procedure TSunTime.SetDate(Value: TDateTime);
begin
  if Trunc(Date) <> Trunc(Value) then
  begin
    fDate := Int(Value);
    if UseSysTimeZone then
      fTimeZone := -GetBiasAtDate(Date) / 60;
    fReady := False;
  end;
end;

procedure TSunTime.SetUseSysTimeZone(Value: Boolean);
begin
  if UseSysTimeZone <> Value then
  begin
    fUseSysTimeZone := Value;
    if UseSysTimeZone then
    begin
      fTimeZone := -GetBiasAtDate(Date) / 60;
      fReady := False;
    end;
  end;
end;

procedure TSunTime.SetTimeZone(Value: Extended);
begin
  if (TimeZone <> Value) and (Value >= -12) and (Value <= +12) then
  begin
    fTimeZone := Value;
    fUseSysTimeZone := False;
    fReady := False;
  end;
end;

procedure TSunTime.SetLatitude(Value: TLatitude);
begin
  fLatitude.Assign(Value);
end;

procedure TSunTime.SetLongitude(Value: TLongitude);
begin
  fLongitude.Assign(Value);
end;

function TSunTime.IsTimeZoneStored: Boolean;
begin
  Result := not UseSysTimeZone and (TimeZone <> 0);
end;

function TSunTime.GetSunTime(Index: Integer): TDateTime;
begin
  if not fReady then
    CalcTimes;
  case Index of
    0: Result := fSunrise;
    1: Result := fSunset;
    2: Result := fNoon;
  else
    Result := 0;
  end;
end;

procedure TSunTime.LocationChanged(Sender: TObject);
begin
  fReady := False;
end;

procedure TSunTime.CalcTimes;

  function UTCMinutesToLocalTime(const Minutes: Extended): TDateTime;
  begin
    Result := Int(Date) + (Minutes / 60 + TimeZone) / 24;
  end;

var
  JD: Extended;
  Minutes: Extended;
begin
  JD := DateToJulian(Date);
  try
    Minutes := GetSunriseUTC(JD, Latitude.Value, Longitude.Value);
    fSunrise := UTCMinutesToLocalTime(Minutes);
  except
    fSunrise := 0;  // No sunrise
  end;
  try
    Minutes := GetSunsetUTC(JD, Latitude.Value, Longitude.Value);
    fSunset := UTCMinutesToLocalTime(Minutes);
  except
    fSunset := 0;  // No sunset
  end;
  try
    Minutes := GetSolarNoonUTC(JD, Longitude.Value);
    fNoon := UTCMinutesToLocalTime(Minutes);
  except
    fNoon := 0;    // No solar noon
  end;
  fReady := True;
end;

end.
