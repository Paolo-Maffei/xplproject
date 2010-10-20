unit julian;
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
  StdCtrls, moon, main, consts, ah_tool;

type
  (*@/// Tfrm_julian = class(TForm) *)
  Tfrm_julian = class(TForm)
    lbl_julian: TLabel;
    edt_julian: TEdit;
    grp_utc: TGroupBox;
    lbl_utc: TLabel;
    btn_now: TButton;
    btn_ok: TButton;
    btn_cancel: TButton;
    procedure btn_nowClick(Sender: TObject);
    procedure edt_julianChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
      procedure FormShow(Sender: TObject);
  public
    date: TDateTime;
    procedure set_edit;
  end;
  (*@\\\*)

var
  frm_julian: Tfrm_julian;
(*@\\\0000000B28*)
(*@/// implementation *)
implementation

{$R *.DFM}

(*$i moontool.inc *)
(*$i ah_def.inc *)

(*@/// procedure Tfrm_julian.btn_nowClick(Sender: TObject); *)
procedure Tfrm_julian.btn_nowClick(Sender: TObject);
begin
  date:=now;
  set_edit;
  end;
(*@\\\*)
(*@/// procedure Tfrm_julian.set_edit; *)
procedure Tfrm_julian.set_edit;
begin
  edt_julian.text:=FloatToStrF(Julian_date(date),ffFixed,12,5);
  end;
(*@\\\000000030D*)
(*@/// procedure Tfrm_julian.edt_julianChange(Sender: TObject); *)
procedure Tfrm_julian.edt_julianChange(Sender: TObject);
var
  j_date: extended;
  valid: boolean;
begin
  valid:=false;
  try
    j_date:=StrToFloat(edt_julian.text);
    date:=Delphi_Date(j_date);
    lbl_utc.caption:=date2string(date);
    valid:=true;
  except
    end;
  btn_ok.enabled:=valid;
  if not valid then begin
    date:=0;
    lbl_utc.caption:=LoadStr(SInvalid);
    end;
  end;
(*@\\\0000000805*)
(*@/// procedure Tfrm_julian.FormCreate(Sender: TObject); *)
procedure Tfrm_julian.FormCreate(Sender: TObject);
begin
  lbl_julian.caption:=loadStr(SJulianDate);
  self.caption:=LoadStr(SSetJulian);
  btn_now.caption:=LoadStr(SNow);
  grp_utc.caption:=LoadStr(SUTC);
  (*$ifdef delphi_ge_4 *)
  btn_ok.caption:=SOKButton;
  btn_cancel.caption:=SCancelButton;
  (*$else *)
  btn_ok.caption:=LoadStr(SOKButton);
  btn_cancel.caption:=LoadStr(SCancelButton);
  (*$endif *)
  helpcontext:=hc_setjulian;
  end;
(*@\\\0000000E1D*)
(*@/// procedure Tfrm_julian.FormShow(Sender: TObject); *)
procedure Tfrm_julian.FormShow(Sender: TObject);
begin
  set_edit;
  end;
(*@\\\*)
(*@\\\0000000B01*)
(*$ifndef ver80 *) (*$warnings off*) (*$endif *)
end.
(*@\\\000E000401000431000505000505*)
