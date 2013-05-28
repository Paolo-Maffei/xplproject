program app_vendor_files;

{$mode objfpc}{$H+}

uses // heaptrc ,

  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces
  , Forms
  , pl_rx, pl_excontrols, pl_lnetcomp
  , frm_vendor_files
  , u_xpl_application
  ;

{$R *.res}

begin
  Application.Initialize;

  xPLApplication := TxPLApplication.Create(Application);
  Application.CreateForm(Tfrmvendorfiles, frmvendorfiles);
  Application.Run;

end.
