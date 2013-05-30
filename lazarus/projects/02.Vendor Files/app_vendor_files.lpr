program app_vendor_files;

{$i xpl.inc}
{$R *.res}

uses {$IFDEF DEBUG}
     heaptrc,
     {$ENDIF}
     {$IFDEF UNIX}
     cthreads,
     {$ENDIF}
     Interfaces
     , Forms
     , pl_rx, pl_excontrols, pl_lnetcomp
     , frm_vendor_files
     , u_xpl_application
     ;

begin
  Application.Initialize;

  xPLApplication := TxPLApplication.Create(Application);
  Application.CreateForm(Tfrmvendorfiles, frmvendorfiles);
  Application.Run;

end.
