unit about;
(*@/// interface *)
interface

 {$i ah_def.inc }
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
  StdCtrls,
  ExtCtrls,
  consts,
(*$ifdef delphi_ge_2 *)
  shellapi,
(*$endif *)
  ah_tool,
  mooncomp,
  moon;
(*@\\\000000150B*)

type
  (*@/// TAboutForm = class(TForm) *)
  TAboutForm = class(TForm)
    btn_ok: TButton;
    Moon: TMoon;
    lbl_main: TLabel;
    lbl_copyright: TLabel;
    lbl_reference_1: TLabel;
    lbl_reference_2: TLabel;
    lbl_url: TLabel;
    lbl_translation: TLabel;
    procedure FormShow(Sender: TObject);
    procedure lbl_urlClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    end;
  (*@\\\0000000401*)

var
  AboutForm: TAboutForm;
(*@\\\0000000401*)
(*@/// implementation *)
implementation

{$R *.DFM}
(*$i moontool.inc *)
(*$ifndef delphi_ge_3 *)
const
  crHandPoint = -21;
(*$endif *)

(*@/// procedure TAboutForm.FormShow(Sender: TObject); *)
procedure TAboutForm.FormShow(Sender: TObject);
begin
  moon.date:=now;
  end;
(*@\\\0000000401*)
(*@/// procedure TAboutForm.lbl_urlClick(Sender: TObject); *)
procedure TAboutForm.lbl_urlClick(Sender: TObject);
begin
(*$ifdef delphi_ge_2 *)
  ShellExecute(Application.Handle,PChar('open'),'http://www.hoerstemeier.com',PChar(''),nil,SW_NORMAL);
(*$else *)
  WinExec('http://www.hoerstemeier.com',SW_NORMAL);
(*$endif *)
  end;
(*@\\\0000000603*)
(*@/// procedure TAboutForm.FormCreate(Sender: TObject); *)
procedure TAboutForm.FormCreate(Sender: TObject);
begin
  (*$ifdef delphi_ge_4 *)
  btn_ok.caption:=SOKButton;
  (*$else *)
  btn_ok.caption:=LoadStr(SOKButton);
  (*$endif *)
  self           .caption:=LoadStr(SAboutBox);
  lbl_main       .caption:=LoadStr(SMoontoolAbout);
  lbl_reference_1.caption:=LoadStr(SBased1);
  lbl_reference_2.caption:=LoadStr(SBased2);
  lbl_translation.caption:=LoadStr(STranslation);
  end;
(*@\\\0000000A12*)
(*@/// procedure TAboutForm.MouseMove(Sender: TObject; Shift: TShiftState; X,Y:integer); *)
procedure TAboutForm.MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
var
  p: tpoint;
begin
  if sender=NIL then EXIT;
  if not (sender is TControl) then EXIT;
  p:=point(x,y);
  p:=TControl(sender).clienttoscreen(p);
  p:=self.screentoclient(p);
  if self.ControlAtPos(p,false)=lbl_url then begin
    if lbl_url.font.color<>clBlue then begin
      lbl_url.font.color:=clBlue;
      lbl_url.cursor:=crHandPoint;
      end;
    end
  else begin
    if lbl_url.font.color<>clBlack then begin
      lbl_url.font.color:=clBlack;
      lbl_url.cursor:=crDefault;
      end;
    end;
end;
(*@\\\0000000610*)
(*@\\\*)
(*$ifndef ver80 *) (*$warnings off*) (*$endif *)
end.
(*@\\\000E000401000431000301000301*)
