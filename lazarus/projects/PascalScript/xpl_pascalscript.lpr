program xpl_pascalscript;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, 							// this includes the LCL widgetset
  Forms , LResources, 						{ you can add units after this }
  frm_main, frm_about, frm_xplappslauncher,	// standard to all lazarus projects
  TConfiguratorUnit, XPL;


{$IFDEF WINDOWS}{$R xpl_pascalscript.rc}{$ENDIF}

begin
  {$I xpl_pascalscript.lrs}
  Application.Initialize;
  TConfiguratorUnit.doBasicConfiguration;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmAppLauncher, frmAppLauncher);
  Application.Icon := frmMain.Icon;
  Application.Run;
end.

