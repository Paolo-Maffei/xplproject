program xpl_calevent;

{$i compiler.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFNDEF CONSOLE_APP}
     Interfaces, // this includes the LCL widgetset
     Forms,
     LResources,
     frm_main,
  {$ENDIF}
     app_main;

{$IFDEF WINDOWS}{$R xpl_calevent.rc}{$ENDIF}
begin
  Application.Title:='xpl_calevent';
{$IFNDEF CONSOLE_APP}
  {$I xpl_calevent.lrs}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
{$ENDIF}
  Application.Run;
end.

