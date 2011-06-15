program app_vendor_files;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, frm_vendor_files, LResources, superxmlparser,
  u_xpl_application,
  u_xpl_gui_resource;

{$IFDEF WINDOWS}{$R app_vendor_files.rc}{$ENDIF}

begin
  {$I app_vendor_files.lrs}
  Application.Title:='xPL Vendor Files';
  Application.Initialize;

  xPLApplication := TxPLApplication.Create(nil,'vendfile','clinique','4.0.0');
  xPLGUIResource := TxPLGUIResource.Create;

  Application.CreateForm(Tfrmvendorfiles, frmvendorfiles);

  Application.Run;

  xPLGUIResource.Free;
  xPLApplication.Free;
end.

