program xpl_balloon;

{$i compiler.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFNDEF CONSOLE_APP}
     Interfaces, // this includes the LCL widgetset
     Forms,
     LResources, frm_about, zcomponent,
     frm_main,
  {$ENDIF}
     app_main, xplnotifier;

{$IFDEF WINDOWS}{$R xpl_balloon.rc}{$ENDIF}
begin
  Application.Title:='xpl_balloon';
{$IFNDEF CONSOLE_APP}
  {$I xpl_balloon.lrs}
  {$I pictures.lrs}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
{$ENDIF}
  Application.Run;
end.

