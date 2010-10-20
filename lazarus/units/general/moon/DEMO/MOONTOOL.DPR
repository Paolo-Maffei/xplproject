program moontool;

uses
  Forms,
  MAIN in 'MAIN.PAS' {MainForm},
  about in 'ABOUT.PAS' {AboutForm},
  More in 'MORE.PAS' {frm_more},
  julian in 'julian.pas' {frm_julian},
  utc in 'utc.pas' {frm_utc},
  location in 'location.pas' {frm_locations},
  jewish in 'jewish.pas' {frm_jewish};

(*$ifdef ver80 *)
  {$R moontool.R16}
(*$else *)
  {$R moontool.r32}
(*$endif *)

begin
(*$ifndef ver80 *)
  Application.Initialize;
(*$endif *)
  Application.Title := 'Moontool';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(Tfrm_more, frm_more);
  Application.CreateForm(Tfrm_julian, frm_julian);
  Application.CreateForm(Tfrm_utc, frm_utc);
  Application.CreateForm(Tfrm_locations, frm_locations);
  Application.CreateForm(Tfrm_jewish, frm_jewish);
  Application.Run;
  end.
