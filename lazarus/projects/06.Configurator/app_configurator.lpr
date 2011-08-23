program app_configurator;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces
  , Forms, jvclinport
  , u_xpl_application
  , u_xpl_listener
  , u_xpl_gui_resource
  , frm_configurator
  , configurator_listener
  ;

{$IFDEF WINDOWS}{$R app_configurator.rc}{$ENDIF}

begin
  Application.Title:='xPL configurator';
  Application.Initialize;

  xPLApplication := TConfigListener.Create(Application);
  xPLGUIResource := TxPLGUIResource.Create;
  Application.CreateForm(TfrmConfigurator, frmConfigurator);
  Application.Run;

  xPLGUIResource.Free;
  xPLApplication.Free;
end.

