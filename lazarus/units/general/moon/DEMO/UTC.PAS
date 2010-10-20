unit utc;
(*@/// interface *)
interface

uses
(*$ifdef ver80 *)
  winprocs,
  wintypes,
(*$else *)
  Windows,
(*$endif *)
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, consts,
  ah_tool,
  moon,
  main;

type
  (*@/// Tfrm_utc = class(TForm) *)
  Tfrm_utc = class(TForm)
    grp_utc: TGroupBox;
    edt_year: TEdit;
    lbl_year: TLabel;
    cbx_month: TComboBox;
    lbl_month: TLabel;
    edt_day: TEdit;
    lbl_day: TLabel;
    edt_hour: TEdit;
    edt_min: TEdit;
    edt_sec: TEdit;
    lbl_hour: TLabel;
    lbl_sec: TLabel;
    lbl_min: TLabel;
    grp_julian: TGroupBox;
    lbl_julian: TLabel;
    btn_now: TButton;
    btn_ok: TButton;
    btn_cancel: TButton;
    procedure btn_nowClick(Sender: TObject);
    procedure anyChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    date: TDateTime;
    procedure set_edit;
  end;
  (*@\\\0000001A01*)

var
  frm_utc: Tfrm_utc;
(*@\\\0000000B14*)
(*@/// implementation *)
implementation

{$R *.DFM}
(*$i moontool.inc *)
(*$i ah_def.inc *)

(*@/// procedure Tfrm_utc.btn_nowClick(Sender: TObject); *)
procedure Tfrm_utc.btn_nowClick(Sender: TObject);
begin
  date:=now;
  set_edit;
  end;
(*@\\\0000000303*)
(*@/// procedure Tfrm_utc.anyChange(Sender: TObject); *)
procedure Tfrm_utc.anyChange(Sender: TObject);
var
  valid: boolean;
begin
  valid:=false;
  try
    date:=EncodeDateCorrect(StrToInt(edt_year.text),cbx_month.itemindex+1,
                            StrToInt(edt_day.text));
    date:=date+Encodetime(StrToInt(edt_hour.text),
                          StrToInt(edt_min.text),
                          StrToInt(edt_sec.text),0);
    lbl_julian.caption:=FloatToStrF(Julian_date(date),ffFixed,12,5);
    valid:=true;
  except
    end;
  btn_ok.enabled:=valid;
  if not valid then
    lbl_julian.caption:=LoadStr(SInvalid);
  end;
(*@\\\0000000801*)
(*@/// procedure Tfrm_utc.FormCreate(Sender: TObject); *)
procedure Tfrm_utc.FormCreate(Sender: TObject);
var
  i: integer;
begin
  grp_julian.caption:=loadStr(SJulianDate);
  self.caption:=LoadStr(SSetUTC);
  btn_now.caption:=LoadStr(SNow);
  grp_utc.caption:=LoadStr(SUTC);
  (*$ifdef delphi_ge_4 *)
  btn_ok.caption:=SOKButton;
  btn_cancel.caption:=SCancelButton;
  (*$else *)
  btn_ok.caption:=LoadStr(SOKButton);
  btn_cancel.caption:=LoadStr(SCancelButton);
  (*$endif *)
  lbl_year .caption:=LoadStr(SYear);
  lbl_month.caption:=LoadStr(SMonth);
  lbl_day  .caption:=LoadStr(SDay);
  lbl_hour .caption:=LoadStr(SHour);
  lbl_min  .caption:=LoadStr(SMinute);
  lbl_sec  .caption:=LoadStr(SSecond);
  for i:=1 to 12 do
    cbx_month.items.add(LongMonthNames[i]);
  helpcontext:=hc_setutc;
  end;
(*@\\\0000001801*)
(*@/// procedure Tfrm_utc.FormShow(Sender: TObject); *)
procedure Tfrm_utc.FormShow(Sender: TObject);
begin
  set_edit;
  end;
(*@\\\000000030C*)
(*@/// procedure Tfrm_utc.set_edit; *)
procedure Tfrm_utc.set_edit;
var
  y,m,d: word;
  h,min,s,ms: word;
  help: TdateTime;
begin
  help:=date;
  help:=FalsifyTDateTime(help);
  DecodeDate(help,y,m,d);
  DecodeTime(help,h,min,s,ms);
  edt_year.text:=inttostr(y);
  edt_day.text:=inttostr(d);
  cbx_month.itemindex:=m-1;
  edt_hour.text:=inttostr(h);
  edt_min.text:=inttostr(min);
  edt_sec.text:=inttostr(s);
  end;
(*@\\\*)
(*@\\\0000000901*)
(*$ifndef ver80 *) (*$warnings off*) (*$endif *)
end.
(*@\\\000E000401000431000401000401*)
