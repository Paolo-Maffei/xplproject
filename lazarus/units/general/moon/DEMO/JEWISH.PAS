unit jewish;
(*@/// interface *)
interface

uses
(*$ifdef ver80 *)
  winprocs,
  wintypes,
(*$else *)
  Windows,
(*$endif *)
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, moon,
  StdCtrls, consts, ah_tool;

type
  (*@/// Tfrm_jewish = class(TForm) *)
  Tfrm_jewish = class(TForm)
    grp_gregorian: TGroupBox;
    lbl_year: TLabel;
    lbl_month: TLabel;
    lbl_day: TLabel;
    edt_year: TEdit;
    cbx_month: TComboBox;
    edt_day: TEdit;
    grp_julian: TGroupBox;
    lbl_julian: TLabel;
    btn_now: TButton;
    btn_ok: TButton;
    btn_cancel: TButton;
    grp_jewish: TGroupBox;
    lbl_year_jewish: TLabel;
    lbl_month_jewish: TLabel;
    lbl_day_jewish: TLabel;
    edt_year_jewish: TEdit;
    cbx_month_jewish: TComboBox;
    edt_day_jewish: TEdit;
    procedure christianChange(Sender: TObject);
    procedure jewishChange(Sender: TObject);
    procedure btn_nowClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    changing: boolean;
  public
    date: TDateTime;
    procedure set_edit;
  end;
  (*@\\\*)

var
  frm_jewish: Tfrm_jewish;
(*@\\\0000000B1C*)
(*@/// implementation *)
implementation

uses
  main;

{$R *.DFM}
(*$i moontool.inc *)
(*$i ah_def.inc *)

(*@/// procedure Tfrm_jewish.christianChange(Sender: TObject); *)
procedure Tfrm_jewish.christianChange(Sender: TObject);
begin
  if changing then EXIT;
  try
    date:=Encodedate(strtoint(edt_year.text),cbx_month.itemindex+1,strtoint(edt_day.text));
    set_edit;
    btn_ok.enabled:=true;
  except
    lbl_julian.caption:=LoadStr(SInvalid);
    btn_ok.enabled:=false;
    end;
  end;
(*@\\\*)
(*@/// procedure Tfrm_jewish.jewishChange(Sender: TObject); *)
procedure Tfrm_jewish.jewishChange(Sender: TObject);
begin
  if changing then EXIT;
  try
    date:=EncodedateJewish(strtoint(edt_year_jewish.text),cbx_month_jewish.itemindex+1,strtoint(edt_day_jewish.text));
    set_edit;
    btn_ok.enabled:=true;
  except
    lbl_julian.caption:=LoadStr(SInvalid);
    btn_ok.enabled:=false;
    end;
  end;
(*@\\\*)
(*@/// procedure Tfrm_jewish.btn_nowClick(Sender: TObject); *)
procedure Tfrm_jewish.btn_nowClick(Sender: TObject);
begin
  date:=now;
  set_edit;
  end;
(*@\\\*)
(*@/// procedure Tfrm_jewish.set_edit; *)
procedure Tfrm_jewish.set_edit;
var
  y,m,d: word;
begin
  changing:=true;
  try
    DecodedateCorrect(date,y,m,d);
    edt_year.text:=inttostr(y);
    cbx_month.itemindex:=m-1;
    edt_day.text:=inttostr(d);
    DecodeDateJewish(date,y,m,d);
    edt_year_jewish.text:=inttostr(y);
    cbx_month_jewish.itemindex:=m-1;
    edt_day_jewish.text:=inttostr(d);
    lbl_julian.caption:=FloatToStrF(Julian_date(int(date)),ffFixed,12,5);
  finally
    changing:=false;
    end;
  end;
(*@\\\*)
(*@/// procedure Tfrm_jewish.FormShow(Sender: TObject); *)
procedure Tfrm_jewish.FormShow(Sender: TObject);
begin
  set_edit;
  end;
(*@\\\*)
(*@/// procedure Tfrm_jewish.FormCreate(Sender: TObject); *)
procedure Tfrm_jewish.FormCreate(Sender: TObject);
var
  i: integer;
begin
  grp_julian.caption:=loadStr(SJulianDate);
  self.caption:=LoadStr(SJewishDate);
  grp_gregorian.caption:=LoadStr(SChristianDate);
  grp_jewish.caption:=LoadStr(SJewishDate);
  btn_now.caption:=LoadStr(SNow);
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
  lbl_year_jewish .caption:=LoadStr(SYear);
  lbl_month_jewish.caption:=LoadStr(SMonth);
  lbl_day_jewish  .caption:=LoadStr(SDay);
  for i:=1 to 12 do
    cbx_month.items.add(LongMonthNames[i]);
  for i:=1 to 13 do
    cbx_month_jewish.items.add(Jewish_Month_Name[i]);
  helpcontext:=hc_setjewish;
  end;
(*@\\\0000001B16*)
(*@\\\0000000901*)
(*$ifndef ver80 *) (*$warnings off*) (*$endif *)
end.
(*@\\\000E000401000431000505000505*)
