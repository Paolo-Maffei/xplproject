unit main;
(*@/// interface *)
interface

(*@/// uses *)
uses
(*$ifdef ver80 *)
  winprocs,
  wintypes,
(*$else *)
  Windows,
(*$endif *)
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  Clipbrd,
  inifiles,
  moon,
  mooncomp,
  ah_tool,
(*$ifndef ver80 *)
  trayicon,
(*$endif *)
  Menus;
(*@\\\0000001401*)

type
  (*@/// TForm1 = class(TForm) *)
  TMainForm = class(TForm)
    Moon: TMoon;
    lbl_age: TLabel;
    lbl_firstquart: TLabel;
    lbl_full: TLabel;
    lbl_julian: TLabel;
    lbl_lastlunation: TLabel;
    lbl_lastnew: TLabel;
    lbl_lastquart: TLabel;
    lbl_local: TLabel;
    lbl_moon_distance: TLabel;
    lbl_moon_subtend: TLabel;
    lbl_nextlunation: TLabel;
    lbl_nextnew: TLabel;
    lbl_phase: TLabel;
    lbl_sun_distance: TLabel;
    lbl_sun_subtend: TLabel;
    lbl_utc: TLabel;
    val_age: TLabel;
    val_firstquart: TLabel;
    val_full: TLabel;
    val_julian: TLabel;
    val_lastlunation: TLabel;
    val_lastquart: TLabel;
    val_local: TLabel;
    val_moon_distance: TLabel;
    val_moon_subtend: TLabel;
    val_newmoon: TLabel;
    val_nextlunation: TLabel;
    val_nextnew: TLabel;
    val_phase: TLabel;
    val_sun_subtend: TLabel;
    val_sun_distance: TLabel;
    val_utc: TLabel;
    Timer: TTimer;
    MainMenu: TMainMenu;
    mnu_file: TMenuItem;
      mnu_tray: TMenuItem;
      mnu_exit: TMenuItem;
    mnu_edit: TMenuItem;
      mnu_copy: TMenuItem;
    mnu_options: TMenuItem;
      mnu_fast: TMenuItem;
      mnu_stop: TMenuItem;
      mnu_line1: TMenuItem;
      mnu_julian: TMenuItem;
      mnu_utc: TMenuItem;
      mnu_jewish: TMenuItem;
      mnu_line3: TMenuItem;
      mnu_color: TMenuItem;
      mnu_rotate: TMenuItem;
        mnu_rot_north: TMenuItem;
        mnu_rot_south: TMenuItem;
      mnu_line4: TMenuItem;
      mnu_locations: TMenuItem;
      mnu_more: TMenuItem;
    mnu_help: TMenuItem;
      mnu_about: TMenuItem;
      mnu_line2: TMenuItem;
      mnu_timezone: TMenuItem;
      mnu_help_item: TMenuItem;
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnu_stopClick(Sender: TObject);
    procedure mnu_exitClick(Sender: TObject);
    procedure mnu_fastClick(Sender: TObject);
    procedure mnu_aboutClick(Sender: TObject);
    procedure mnu_moreClick(Sender: TObject);
    procedure mnu_julianClick(Sender: TObject);
    procedure mnu_utcClick(Sender: TObject);
    procedure mnu_timezoneClick(Sender: TObject);
    procedure mnu_copyClick(Sender: TObject);
    procedure mnu_help_itemClick(Sender: TObject);
    procedure mnu_locationsClick(Sender: TObject);
    procedure mnu_jewishClick(Sender: TObject);

    procedure tray_dblclick(sender: TObject);
    procedure minimize_to_tray(sender: TObject);
    procedure mnu_rotate_Click(Sender: TObject);
    procedure mnu_colorClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    last_phase_value: integer;
    first_now: TDateTime;
    PhaseHint: string;
    Kilometers: string;
    EarthRadii: string;
    AstronomicalUnits: string;
    AgeOfMoonValue: string;
  (*$ifndef ver80 *)
    trayicon: TTrayIcon;
  (*$endif *)
  public
    start_time: TDateTime;
    procedure SetLanguage(Sender: TObject);
    end;
  (*@\\\0000005F01*)

function datestring(x:TDateTime):string;
function date2string(x:TDateTime):string;
function degree2string(x:extended):string;
function TimeZoneBias:longint;

var
  MainForm: TMainForm;

const
  negative_dates_broken: boolean = false;
  helpfilename = 'moon.hlp';
  moontool_inifile: string = 'moontool.ini';
  time_max_width: integer = 150;
  hc_main      = 1000;
  hc_timezones = 1001;
  hc_mainform  = 1002;
  hc_moredata  = 1003;
  hc_setjulian = 1011;
  hc_setutc    = 1010;
  hc_setjewish = 1012;
  hc_locations = 1013;
(*@\\\0000001403*)
(*@/// implementation *)
implementation

uses about, more, julian, utc, location, jewish;

{$R *.DFM}
(*$i moontool.inc *)

const
  AU=149597869;             (* astronomical unit in km *)

(*@/// function datestring(x:TDateTime):string; *)
function datestring(x:TDateTime):string;
begin
  x:=FalsifyTDateTime(x);
  result:=formatdatetime('hh:nn',x)+' UTC '+formatdatetime('d mmmm yyyy',x);
  end;
(*@\\\0000000306*)
(*@/// function date2string(x:TDateTime):string; *)
function date2string(x:TDateTime):string;
begin
  x:=FalsifyTDateTime(x);
  result:=formatdatetime('hh:nn:ss d mmmm yyyy',x);
  end;
(*@\\\0000000304*)
(*@/// function degree2string(x:extended):string; *)
function degree2string(x:extended):string;
var
  d,m,s: integer;
begin
  if x<0 then
    result:='-'
  else
    result:='';
  x:=round(abs(x)*3600);
  s:=round(x) mod 60;
  m:=round((x-s)/60) mod 60;
  d:=round((x-s-m*60)/3600);
  result:=result+inttostr(d)+chr(176)+' ';
  result:=result+inttostr(m)+chr(39)+' ';
  result:=result+inttostr(s)+chr(39)+chr(39);
  end;
(*@\\\0000000D25*)

(*@/// procedure get_settings(var rotate: integer; var color:boolean); *)
procedure get_settings(var rotate: integer; var color:boolean);
var
  IniFile : TIniFile;
begin
  IniFile:=NIL;
  try
    IniFile := TIniFile.Create(moontool_inifile);
    rotate:=IniFile.ReadInteger('Current','Rotate',0);
    color:=IniFile.ReadBool('Current','Color',false);
  finally
    Inifile.Free;
    end;
  end;
(*@\\\000000091C*)
(*@/// procedure save_settings(rotate: integer; color: boolean); *)
procedure save_settings(rotate: integer; color: boolean);
var
  IniFile : TIniFile;
begin
  IniFile:=NIL;
  try
    IniFile := TIniFile.Create(moontool_inifile);
    Inifile.writeinteger('Current','Rotate',rotate);
    Inifile.writebool('Current','Color',color);
  finally
    Inifile.Free;
    end;
  end;
(*@\\\*)

(*@/// function TimeZoneBias:longint;          // in minutes ! *)
function TimeZoneBias:longint;
(*@/// 16 bit way: try a 32bit API call via thunking layer, if that fails try the TZ *)
(*$ifdef ver80 *)
(*@/// function GetEnvVar(const s:string):string; *)
function GetEnvVar(const s:string):string;
var
  L: Word;
  P: PChar;
begin
  L := length(s);
  P := GetDosEnvironment;
  while P^ <> #0 do begin
    if (StrLIComp(P, @s[1], L) = 0) and (P[L] = '=') then begin
      GetEnvVar := StrPas(P + L + 1);
      EXIT;
      end;
    Inc(P, StrLen(P) + 1);
    end;
  GetEnvVar := '';
  end;
(*@\\\*)

(*@/// function day_in_month(month,year,weekday: word; count: integer):TDateTime; *)
function day_in_month(month,year,weekday: word; count: integer):TDateTime;
var
  h: integer;
begin
  if count>0 then begin
    h:=dayofweek(encodedate(year,month,1));
    h:=((weekday-h+7) mod 7) +1 + (count-1)*7;
    result:=encodedate(year,month,h);
    end
  else begin
    h:=dayofweek(encodedate(year,month,1));
    h:=((weekday-h+7) mod 7) +1 + 6*7;
    while count<0 do begin
      h:=h-7;
      try
        result:=encodedate(year,month,h);
        inc(count);
        if count=0 then EXIT;
      except
        end;
      end;
    end;
  end;
(*@\\\*)
(*@/// function DayLight_Start:TDateTime;     // american way ! *)
function DayLight_Start:TDateTime;
var
  y,m,d: word;
begin
  DecodeDate(now,y,m,d);
  result:=day_in_month(4,y,1,1);
  (* for european one: day_in_month(3,y,1,-1) *)
  end;
(*@\\\*)
(*@/// function DayLight_End:TDateTime;       // american way ! *)
function DayLight_End:TDateTime;
var
  y,m,d: word;
begin
  DecodeDate(now,y,m,d);
  result:=day_in_month(10,y,1,-1);
  end;
(*@\\\*)
type    (* stolen from windows.pas *)
  (*@/// TSystemTime = record ... end; *)
  PSystemTime = ^TSystemTime;
  TSystemTime = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;
  (*@\\\*)
  (*@/// TTimeZoneInformation = record ... end; *)
  TTimeZoneInformation = record
    Bias: Longint;
    StandardName: array[0..31] of word;  (* wchar *)
    StandardDate: TSystemTime;
    StandardBias: Longint;
    DaylightName: array[0..31] of word;  (* wchar *)
    DaylightDate: TSystemTime;
    DaylightBias: Longint;
    end;
  (*@\\\*)
var
  tz_info: TTimeZoneInformation;
  LL32:function (LibFileName: PChar; handle: longint; special: longint):Longint;
  FL32:function (hDll: Longint):boolean;
  GA32:function (hDll: Longint; functionname: PChar):longint;
  CP32:function (buffer:TTimeZoneInformation; prochandle,adressconvert,dwParams:Longint):longint;
  hdll32,dummy,farproc: longint;
  hdll:THandle;
  sign: integer;
  s: string;
begin
  hDll:=GetModuleHandle('kernel');                  { get the 16bit handle of kernel }
  @LL32:=GetProcAddress(hdll,'LoadLibraryEx32W');   { get the thunking layer functions }
  @FL32:=GetProcAddress(hdll,'FreeLibrary32W');
  @GA32:=GetProcAddress(hdll,'GetProcAddress32W');
  @CP32:=GetProcAddress(hdll,'CallProc32W');
  (*@/// if possible then   call GetTimeZoneInformation via Thunking *)
  if (@LL32<>NIL) and
     (@FL32<>NIL) and
     (@GA32<>NIL) and
     (@CP32<>NIL) then begin
    hDll32:=LL32('kernel32.dll',dummy,1);            { get the 32bit handle of kernel32 }
    farproc:=GA32(hDll32,'GetTimeZoneInformation');  { get the 32bit adress of the function }
    case CP32(tz_info,farproc,1,1) of                { and call it }
      1: result:=tz_info.StandardBias+tz_info.Bias;
      2: result:=tz_info.DaylightBias+tz_info.Bias;
      else result:=0;
      end;
    FL32(hDll32);                                    { and free the 32bit dll }
    end
  (*@\\\*)
  (*@/// else  calculate the bias out of the TZ environment variable *)
  else begin
    s:=GetEnvVar('TZ');
    while (length(s)>0) and (not(s[1] in ['+','-','0'..'9'])) do
      s:=copy(s,2,length(s));
    case s[1] of
      (*@/// '+': *)
      '+': begin
        sign:=1;
        s:=copy(s,2,length(s));
        end;
      (*@\\\*)
      (*@/// '-': *)
      '-': begin
        sign:=-1;
        s:=copy(s,2,length(s));
        end;
      (*@\\\*)
      else sign:=1;
      end;
    try
      result:=strtoint(copy(s,1,2))*60;
      s:=copy(s,3,length(s));
    except
      try
        result:=strtoint(s[1])*60;
        s:=copy(s,2,length(s));
      except
        result:=0;
        end;
      end;
    (*@/// if s[1]=':' then    minutes offset *)
    if s[1]=':' then begin
      try
        result:=result+strtoint(copy(s,2,2));
        s:=copy(s,4,length(s));
      except
        try
          result:=result+strtoint(s[2]);
          s:=copy(s,3,length(s));
        except
          end;
        end;
      end;
    (*@\\\*)
    (*@/// if s[1]=':' then    seconds offset - ignored *)
    if s[1]=':' then begin
      try
        strtoint(copy(s,2,2));
        s:=copy(s,4,length(s));
      except
        try
          strtoint(s[2]);
          s:=copy(s,3,length(s));
        except
          end;
        end;
      end;
    (*@\\\*)
    result:=result*sign;
    (*@/// if length(s)>0 then daylight saving activated, calculate it *)
    if length(s)>0 then begin
      (* forget about the few hours on the start/end day *)
      if (now>daylight_start) and (now<DayLight_End+1) then
        result:=result-60;
      end;
    (*@\\\*)
    end;
  (*@\\\*)
  end;
(*@\\\*)
(*@/// 32 bit way: API call GetTimeZoneInformation *)
(*$else *)
var
  tz_info: TTimeZoneInformation;
begin
  case GetTimeZoneInformation(tz_info) of
    1: result:=tz_info.StandardBias+tz_info.Bias;
    2: result:=tz_info.DaylightBias+tz_info.Bias;
    else result:=0;
    end;
  end;
(*$endif *)
(*@\\\*)
(*@\\\0000000301*)

(*@/// procedure TForm1.FormCreate(Sender: TObject); *)
procedure TMainForm.FormCreate(Sender: TObject);
var
  rotate: integer;
  use_color: boolean;
begin
  SetLanguage(NIL);
  first_now:=now;
  start_time:=now;
  (*$ifndef ver80 *)
  trayicon:=TTrayIcon.create(self);
  trayicon.OnDblClick:=tray_dblclick;
  mnu_tray.visible:=true;
  (*$endif *)
  get_settings(rotate,use_color);
  if use_color then
    moon.moonstyle:=mscolor
  else
    moon.moonstyle:=msclassic;
  if rotate=180 then begin
    moon.rotation:=rot_180;
    end
  else begin
    moon.rotation:=rot_none;
    end;
  mnu_rot_south.checked:=(rotate=180);
  mnu_rot_north.checked:=(rotate=0);
  mnu_color.checked:=use_color;
  Timer.OnTimer(NIL);
  Application.Icon:=Moon.Icon;
  if fileexists(helpfilename) then
    application.helpfile:=helpfilename;
  InvalidateRect(Application.Handle, nil, true);
  last_phase_value:=199;
  mnu_timezone.enabled:=application.helpfile<>'';
  self.helpcontext:=hc_mainform;
  end;
(*@\\\0000001201*)

(*@/// procedure TMainForm.TimerTimer(Sender: TObject); *)
procedure TMainForm.TimerTimer(Sender: TObject);
var
  jetzt: TDateTime;
  temp: TDateTime;
  dist,age: extended;
  s:string;
  h,m,sec,ms: word;
  bias: integer;
  new_phase: integer;
  lunation_value: integer;
begin
  bias:=TimeZoneBias;
  if mnu_fast.checked then begin
    jetzt:=(now-first_now)*3600+start_time;
    val_local.caption:='';
    end
  else begin
    jetzt:=(now-first_now)+start_time;
    val_local.caption:=date2string(jetzt);
    end;

  jetzt:=jetzt+bias/(60*24);
  val_utc.caption:=date2string(jetzt);
  str(julian_date(jetzt):12:5,s);
  val_julian.caption:=s;

  val_newmoon.caption:='';
  val_firstquart.caption:='';
  val_full.caption:='';
  val_lastquart.caption:='';
  val_nextnew.caption:='';
  val_lastlunation.caption:='';
  val_nextlunation.caption:='';
  try
    temp:=last_phase(jetzt,Newmoon);
    lunation_value:=lunation(temp+1);
    val_newmoon.caption:=datestring(temp);
    val_firstquart.caption:=datestring(next_phase(temp,FirstQuarter));
    val_full.caption:=datestring(next_phase(temp,FullMoon));
    if is_blue_moon(lunation_value) then
      lbl_full.font.color:=clBlue
    else
      lbl_full.font.color:=clWindowText;
    val_lastquart.caption:=datestring(next_phase(temp,LastQuarter));
    val_nextnew.caption:=datestring(next_phase(jetzt,NewMoon));
    val_lastlunation.caption:=inttostr(lunation_value);
    val_nextlunation.caption:=inttostr(lunation_value+1);
  except
    (* ignore exception which might be raised if too close to October 1582 *)
    end;

  dist:=moon_distance(jetzt);
  str(dist/6378.15:4:1,s);
  val_moon_distance.caption:=inttostr(round(dist))+' '+kilometers+', '+s+' '+EarthRadii+'.';
  dist:=sun_distance(jetzt);
  str(dist:6:3,s);
  val_sun_distance.caption:=inttostr(round(dist*AU))+' '+kilometers+', '+s+' '+AstronomicalUnits+'.';

  age:=age_of_moon(jetzt);
  decodetime(age,h,m,sec,ms);
  val_age.caption:=exchange_s('%1%',inttostr(trunc(age)),
                   exchange_s('%2%',inttostr(trunc(h)),
                   exchange_s('%3%',inttostr(trunc(m)),
                   exchange_s('%4%',inttostr(trunc(sec)),
                   AgeOfMoonValue))));
  new_phase:=round(current_phase(jetzt)*100);
  val_phase.caption:=inttostr(new_phase)+'% '+PhaseHint;

  str(moon_diameter(jetzt)/3600:6:4,s);
  val_moon_subtend.caption:=s;
  str(sun_diameter(jetzt)/3600:6:4,s);
  val_sun_subtend.caption:=s;

  if new_phase<>last_phase_value then begin
    moon.date:=jetzt;
    Application.Icon:=Moon.Icon;
    InvalidateRect(Application.Handle, nil, true);
    last_phase_value:=new_phase;
    (*$ifndef ver80 *)
    if trayicon<>NIL then begin
      trayicon.icon:=moon.icon;
      trayicon.tooltip:=inttostr(new_phase)+'%';
      end;
    (*$endif *)
    end;
  end;
(*@\\\0000002801*)
(*@/// procedure TMainForm.mnu_stopClick(Sender: TObject); *)
procedure TMainForm.mnu_stopClick(Sender: TObject);
begin
  timer.enabled:=not timer.enabled;
  if timer.enabled then
     mnu_stop.caption:='&Stop'
  else
    mnu_stop.caption:='&Run';
  end;
(*@\\\*)
(*@/// procedure TMainForm.mnu_fastClick(Sender: TObject); *)
procedure TMainForm.mnu_fastClick(Sender: TObject);
begin
  mnu_fast.checked:=not mnu_fast.checked;
  first_now:=now;
  end;
(*@\\\*)
(*@/// procedure TMainForm.mnu_exitClick(Sender: TObject); *)
procedure TMainForm.mnu_exitClick(Sender: TObject);
begin
  self.close;
  end;
(*@\\\*)
(*@/// procedure TMainForm.mnu_aboutClick(Sender: TObject); *)
procedure TMainForm.mnu_aboutClick(Sender: TObject);
begin
  aboutform.showmodal;
  end;
(*@\\\0000000301*)
(*@/// procedure TMainForm.mnu_moreClick(Sender: TObject); *)
procedure TMainForm.mnu_moreClick(Sender: TObject);
begin
  frm_more.show;
  end;
(*@\\\0000000303*)
(*@/// procedure TMainForm.mnu_julianClick(Sender: TObject); *)
procedure TMainForm.mnu_julianClick(Sender: TObject);
var
  bias: TDateTime;
begin
  bias:=TimeZoneBias/(60*24);
  frm_julian.date:=start_time+(now-first_now)+bias;
  if frm_julian.showmodal=mrOk then begin
    start_time:=frm_julian.date-(now-first_now)-bias;
    TimerTimer(NIL);
    frm_more.start_time:=start_time;
    end;
  end;
(*@\\\0000000835*)
(*@/// procedure TMainForm.mnu_utcClick(Sender: TObject); *)
procedure TMainForm.mnu_utcClick(Sender: TObject);
var
  bias: TDateTime;
begin
  bias:=TimeZoneBias/(60*24);
  frm_utc.date:=start_time+(now-first_now)+bias;
  if frm_utc.showmodal=mrOk then begin
    start_time:=frm_utc.date-(now-first_now)-bias;
    TimerTimer(NIL);
    frm_more.start_time:=start_time;
    end;
  end;
(*@\\\0000000201*)
(*@/// procedure TMainForm.mnu_jewishClick(Sender: TObject); *)
procedure TMainForm.mnu_jewishClick(Sender: TObject);
var
  bias: TDateTime;
begin
  bias:=TimeZoneBias/(60*24);
  frm_jewish.date:=start_time+(now-first_now)+bias;
  if frm_jewish.showmodal=mrOk then begin
    start_time:=frm_jewish.date-(now-first_now)-bias;
    TimerTimer(NIL);
    frm_more.start_time:=start_time;
    end;
end;
(*@\\\*)
(*@/// procedure TMainForm.mnu_timezoneClick(Sender: TObject); *)
procedure TMainForm.mnu_timezoneClick(Sender: TObject);
begin
  Application.HelpContext(hc_timezones);
  end;
(*@\\\0000000301*)
(*@/// procedure TMainForm.mnu_copyClick(Sender: TObject); *)
procedure TMainForm.mnu_copyClick(Sender: TObject);
var
  h: TBitmap;
begin
  h:=NIL;
  try
    h:=TBitmap.Create;
    h.width:=self.clientwidth;
    h.height:=self.clientheight;
    self.update;
    h.canvas.copyrect(rect(0,0,clientwidth,clientheight),
      self.canvas,rect(0,0,clientwidth,clientheight));
    clipboard.assign(h);
  finally
    h.free;
    end;
  end;
(*@\\\000000070F*)
(*@/// procedure TMainForm.mnu_help_itemClick(Sender: TObject); *)
procedure TMainForm.mnu_help_itemClick(Sender: TObject);
begin
  Application.HelpContext(hc_main);
  end;
(*@\\\0000000301*)
(*@/// procedure TMainForm.mnu_locationsClick(Sender: TObject); *)
procedure TMainForm.mnu_locationsClick(Sender: TObject);
begin
  if frm_locations.showmodal=mrOK then
  end;
(*@\\\0000000301*)
(*@/// procedure TMainForm.mnu_rotate_Click(Sender: TObject); *)
procedure TMainForm.mnu_rotate_Click(Sender: TObject);
begin
  if false then
  else if sender=mnu_rot_north then
    moon.rotation:=rot_none
  else if sender=mnu_rot_south then
    moon.rotation:=rot_180;
  mnu_rot_north.checked:=(moon.rotation=rot_none);
  mnu_rot_south.checked:=(moon.rotation=rot_180);
  last_phase_value:=199;
  TimerTimer(NIL);
  end;
(*@\\\0000000301*)
(*@/// procedure TMainForm.mnu_colorClick(Sender: TObject); *)
procedure TMainForm.mnu_colorClick(Sender: TObject);
begin
  mnu_color.checked:=not mnu_color.checked;
  if (mnu_color.checked) then
    moon.moonstyle:=msColor
  else
    moon.moonstyle:=msClassic;
  last_phase_value:=199;
  TimerTimer(NIL);
  end;
(*@\\\003C00050100060100070100080100071F*)

(*@/// procedure TMainForm.tray_dblclick(sender: TObject); *)
procedure TMainForm.tray_dblclick(sender: TObject);
begin
  self.visible:=true;
  (*$ifndef ver80 *)
  trayicon.active:=false;
  showwindow(application.handle,sw_show);
  application.restore;
  (*$endif *)
  end;
(*@\\\*)
(*@/// procedure TMainForm.minimize_to_tray(sender: TObject); *)
procedure TMainForm.minimize_to_tray(sender: TObject);
begin
  (*$ifndef ver80 *)
  trayicon.active:=true;
  application.minimize;
  showwindow(application.handle,sw_hide);
  (*$endif *)
  end;
(*@\\\0000000503*)

(*@/// procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction); *)
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  rotate: integer;
begin
  if moon.rotation=rot_180 then
    rotate:=180
  else
    rotate:=0;
  save_settings(rotate,moon.moonstyle=msColor);
  end;
(*@\\\000200092E00092E*)

(*@/// procedure TMainForm.SetLanguage(Sender: TObject); *)
procedure TMainForm.SetLanguage(Sender: TObject);
const
  offset = 10;
  moon_size = 80;
  lunation_value_size = 383-336;
var
  size_x, pos_x, i: integer;
begin
  PhaseHint                  := LoadStr(SPhaseHint);
  Kilometers                 := LoadStr(SKilometers);
  EarthRadii                 := LoadStr(SEarthRadii);
  AstronomicalUnits          := LoadStr(SAstronomicalUnits);
  AgeOfMoonValue             := LoadStr(SAgeOfMoonValue);
  Timer.OnTimer(NIL);  (* make sure the val_* are set *)
  self              .caption := LoadStr(SMoontool);
  lbl_age           .caption := LoadStr(SAgeOfMoon);
  lbl_firstquart    .caption := LoadStr(SFirstQuarter);
  lbl_full          .caption := LoadStr(SFullMoon);
  lbl_julian        .caption := LoadStr(SJuliandate);
  lbl_lastlunation  .caption := LoadStr(SLunation);
  lbl_lastnew       .caption := LoadStr(SLastNewMoon);
  lbl_lastquart     .caption := LoadStr(SLastQuarter);
  lbl_local         .caption := LoadStr(SLocalTime);
  lbl_moon_distance .caption := LoadStr(SMoonDistance);
  lbl_moon_subtend  .caption := LoadStr(SMoonSize);
  lbl_nextlunation  .caption := LoadStr(SLunation);
  lbl_nextnew       .caption := LoadStr(SNextNewMoon);
  lbl_phase         .caption := LoadStr(SMoonPhase);
  lbl_sun_distance  .caption := LoadStr(SSunDistance);
  lbl_sun_subtend   .caption := LoadStr(SSunSize);
  lbl_utc           .caption := LoadStr(SUTC);
  mnu_file          .caption := LoadStr(SMenuFile);
  mnu_tray          .caption := LoadStr(SMinimizeTray);
  mnu_exit          .caption := LoadStr(SMenuExit);
  mnu_edit          .caption := LoadStr(SMenuEdit);
  mnu_copy          .caption := LoadStr(SMenuCopy);
  mnu_options       .caption := LoadStr(SMenuOptions);
  mnu_fast          .caption := LoadStr(SMenuFast);
  mnu_stop          .caption := LoadStr(SMenuStop);
  mnu_julian        .caption := LoadStr(SMenuSetJulian);
  mnu_utc           .caption := LoadStr(SMenuSetUTC);
  mnu_jewish        .caption := LoadStr(SMenuJewish);
  mnu_locations     .caption := LoadStr(SMenuLocation);
  mnu_rotate        .caption := LoadStr(SMenuRotate);
  mnu_rot_north     .caption := LoadStr(SMenuRotateNorth);
  mnu_rot_south     .caption := LoadStr(SMenuRotateSouth);
  mnu_color         .caption := LoadStr(SMenuColorMoon);
  mnu_more          .caption := LoadStr(SMenuMore);
  mnu_help          .caption := LoadStr(SMenuHelp);
  mnu_about         .caption := LoadStr(SMenuAbout);
  mnu_timezone      .caption := LoadStr(SMenuTimeZones);
  application.title:=self.caption;
  (* Reposition controls: calc max width of first row *)
  pos_x:=104;
  size_x:=384;
{   pos_x_2:=272; }
  for i:=0 to self.controlcount-1 do
    if controls[i].tag=1 then
      pos_x:=max(pos_x,controls[i].left+controls[i].width+offset);
  (* Reposition controls: reposition first value row, get offset and width for the rest *)
  for i:=0 to self.controlcount-1 do begin
    if controls[i].tag in [2,3,4] then
      controls[i].left:=pos_x;
    case controls[i].tag of
      2: size_x:=max(size_x,controls[i].left+controls[i].width+offset+moon_size);
      3: size_x:=max(size_x,controls[i].left+controls[i].width+offset);
      4: time_max_width:=max(time_max_width,controls[i].width);
      end;
    end;
  pos_x:=pos_x+time_max_width+offset;
  (* reposition the second row, get width *)
  for i:=0 to self.controlcount-1 do
    if controls[i].tag=5 then begin
      controls[i].left:=pos_x;
      size_x:=max(size_x,controls[i].left+controls[i].width+offset+lunation_value_size);
      end;
  (* reposition the second data row *)
  for i:=0 to self.controlcount-1 do
    if controls[i].tag=6 then
      controls[i].left:=size_x-lunation_value_size;
  moon.left:=size_x-moon_size;
  self.width:=size_x;
{   size_x:=pos_x+80; }
  end;
(*@\\\0000005401*)

(*@/// procedure init; *)
procedure init;
var
  s: string;
begin
  s:=paramstr(0);
  s:=copy(s,1,posn('\',s,-1));
  moontool_inifile:=s+moontool_inifile;
  end;
(*@\\\*)
(*@\\\0000002901*)
begin
  init;
  (*$ifndef ver80 *) (*$warnings off*) (*$endif *)
  end.
(*@\\\0001000011*)
