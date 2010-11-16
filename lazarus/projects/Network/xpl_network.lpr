program xpl_network;

{$mode objfpc}{$H+}
{$IFDEF UNIX} {$DEFINE UseCThreads} {$ENDIF}       // Needed for Indy under Linux

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, Forms, LResources, multiloglaz,
  app_main,
  frm_main,
  frm_about,
  frm_logviewer,
  frm_xplappslauncher,
  u_xml_plugins,
  frm_XMLView, frm_plugin_viewer, xpl_win, u_xml_xplplugin_ex;

{$IFDEF WINDOWS}{$R xpl_network.rc}{$ENDIF}

begin
  {$I xpl_network.lrs}
  Application.Initialize;
  Application.CreateForm(TfrmMain       , frmMain);
  Application.CreateForm(TfrmAbout      , frmAbout);
  Application.CreateForm(TfrmXMLView    , frmXMLView);
  Application.CreateForm(TfrmLogViewer  , frmLogViewer);
  Application.CreateForm(TfrmAppLauncher, frmAppLauncher);
  Application.Icon := FrmMain.Icon;
  Application.CreateForm(TfrmPluginViewer, frmPluginViewer);
  Application.Run;
end.

