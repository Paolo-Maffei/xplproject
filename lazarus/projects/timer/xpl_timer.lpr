program xpl_timer;

{$i compiler.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFNDEF CONSOLE_APP}
     Interfaces, // this includes the LCL widgetset
     Forms,
     LResources, indylaz,
     frm_xplappslauncher,
     frm_main,
  {$ENDIF}
     app_main,
     uxpltimer,
     SunTime,
     uxPLEvent, frm_logviewer, frm_about;

{$IFDEF WINDOWS}{$R xpl_timer.rc}{$ENDIF}

begin
{$IFNDEF CONSOLE_APP}
  {$I xpl_timer.lrs}
  xPLApplication.Initialize;
  xPLApplication.CreateForm(TfrmMain, frmMain);
     xPLClient      := frmmain.xPLClient;
  xPLApplication.CreateForm(TfrmAbout, frmAbout);
//  xPLApplication.CreateForm(TfrmAppLauncher, frmAppLauncher);
  xPLApplication.CreateForm(TfrmLogViewer, frmLogViewer);
  xPLApplication.Icon := frmMain.Icon;
{$ENDIF}
  xPLApplication.Run;
{$IFNDEF CONSOLE_APP}
  xPLApplication.Free;
{$ENDIF}
end.

