program app_configurator;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces
  , Forms, pl_rx
  , u_xpl_application
  , u_xpl_listener
  , u_xpl_gui_resource
  , xpl_win
  , frm_configurator
  , configurator_listener
  , frame_config
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

