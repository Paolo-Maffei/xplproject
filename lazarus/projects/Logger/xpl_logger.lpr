program xpl_logger;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, LResources,
  TConfiguratorUnit, 
frm_main, XPL, frm_about, frm_xplappslauncher, frm_appsettings;

{$IFDEF WINDOWS}{$R xpl_logger.rc}{$ENDIF}

begin
  {$I xpl_logger.lrs}
  Application.Initialize;
  TConfiguratorUnit.doBasicConfiguration;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TfrmAppSettings, frmAppSettings);     // This one has to be created before frm_Main
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmAppLauncher, frmAppLauncher);
  Application.Icon := FrmMain.Icon;
  Application.Run;
end.

