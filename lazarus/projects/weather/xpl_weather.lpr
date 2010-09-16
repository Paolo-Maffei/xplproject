program xpl_weather;

{$i compiler.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
  {$IFNDEF CONSOLE_APP}
     Interfaces, // this includes the LCL widgetset
     Forms,
     LResources,
     frm_about,
     frm_xplappslauncher,
     frm_xpllogviewer,
     frm_main,
  {$ENDIF}
     app_main;

{$IFDEF WINDOWS}{$R xpl_weather.rc}{$ENDIF}

begin
  xPLApplication.Title:='xpl_weather';
{$IFNDEF CONSOLE_APP}
  {$I xpl_weather.lrs}
  xPLApplication.Initialize;
  xPLApplication.CreateForm(TfrmMain, frmMain);
  xPLApplication.CreateForm(TfrmAbout, frmAbout);
  xPLApplication.CreateForm(TfrmAppLauncher, frmAppLauncher);
  xPLApplication.CreateForm(TfrmLogViewer, frmLogViewer);
  xPLApplication.Icon := frmMain.Icon;
{$ENDIF}
  xPLApplication.Run;
{$IFNDEF CONSOLE_APP}
  xPLApplication.Free;
{$ENDIF}
end.

