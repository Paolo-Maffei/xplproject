program app_vendor_files;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces
  , Forms
  , uniqueinstance_package
  , multiloglaz
  , pl_rx
  , frm_vendor_files
  , u_xpl_application
  , u_xpl_gui_resource
  ;

{$IFDEF WINDOWS}
   {$R app_vendor_files.rc}
{$else}
   {$r *.res}
{$ENDIF}



begin
  Application.Initialize;

  xPLApplication := TxPLApplication.Create(Application);
  xPLGUIResource := TxPLGUIResource.Create;

  Application.CreateForm(Tfrmvendorfiles, frmvendorfiles);
  Application.Run;

  xPLGUIResource.Free;
end.
