program xpl_logger;

{$mode objfpc}{$H+}
{$DEFINE UseCThreads}
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  LResources,
  app_main,
  frm_main, frm_about, frm_appsettings,
  frm_setupinstance,
  frm_logviewer, xpl_win, indylaz, frm_plugindetail, u_xml_config;

{$IFDEF WINDOWS}{$R xpl_logger.rc}{$ENDIF}

begin
  {$I xpl_logger.lrs}
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TfrmAppSettings, frmAppSettings);
  Application.CreateForm(TfrmLogViewer, frmLogViewer);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmSetupInstance, frmSetupInstance);
  Application.CreateForm(TfrmPluginDetail, frmPluginDetail);
  Application.Icon := FrmMain.Icon;
  Application.Run;
end.

