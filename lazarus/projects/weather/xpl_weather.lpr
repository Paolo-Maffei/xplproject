program xpl_weather;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  TConfiguratorUnit,
  { you can add units after this }LResources, frm_about, frm_main,
  frm_xplappslauncher, indylaz;

{$IFDEF WINDOWS}{$R xpl_weather.rc}{$ENDIF}

begin
  {$I xpl_weather.lrs}
  Application.Initialize;
  TConfiguratorUnit.doBasicConfiguration;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmAppLauncher, frmAppLauncher);
  Application.Icon := frmMain.Icon;
  Application.Run;
end.

