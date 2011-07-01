program app_plugin_editor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  frm_plugin_viewer,
  u_xml_xplplugin,
  u_xpl_application,
  u_xpl_gui_resource;

{$IFDEF WINDOWS}{$R app_plugin_editor.rc}{$ENDIF}

begin
  Application.Initialize;

  xPLApplication := TxPLApplication.Create(Application);
  xPLGUIResource := TxPLGUIResource.Create;
  Application.CreateForm(TfrmPluginViewer, frmPluginViewer);
  if Application.HasOption('l') then frmPluginViewer.FilePath := Application.GetOptionValue('l');

  Application.Run;

  xPLGUIResource.Free;
end.

