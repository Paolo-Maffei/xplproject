program xpl_free;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  TConfiguratorUnit,
  { you can add units after this }LResources, frm_about, frm_main,
  frm_xplappslauncher, indylaz, uRegExTools;

{$IFDEF WINDOWS}{$R xpl_free.rc}{$ENDIF}

begin
  {$I xpl_free.lrs}
  Application.Initialize;
  TConfiguratorUnit.doBasicConfiguration;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmAppLauncher, frmAppLauncher);
  Application.Icon := frmMain.Icon;
  Application.Run;
end.

