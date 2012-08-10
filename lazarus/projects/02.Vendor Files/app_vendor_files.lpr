program app_vendor_files;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces
  , Forms
  , pl_rx, pl_excontrols
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

