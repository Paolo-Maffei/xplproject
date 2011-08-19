program app_vendor_files;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces
  , Forms, uniqueinstance_package, multiloglaz
  , frm_vendor_files
  , u_xpl_application
  , u_xpl_gui_resource
  ;

{$IFDEF WINDOWS}{$R app_vendor_files.rc}{$ENDIF}

{ $ R *.res}

begin
  Application.Title:='xPL Vendor Files';
  //Application.Title:='xPL Vendor Files';
  Application.Initialize;

  xPLApplication := TxPLApplication.Create(Application);
  xPLGUIResource := TxPLGUIResource.Create;

  Application.CreateForm(Tfrmvendorfiles, frmvendorfiles);
  Application.Run;

  xPLGUIResource.Free;
end.

