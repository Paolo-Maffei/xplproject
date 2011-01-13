program xpl_hub;

{$i compiler.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     app_main, u_xpl_hub;

{$IFDEF WINDOWS}{$R xpl_hub.rc}{$ENDIF}
begin
  xPLApplication.Title:='xpl_hub';
  xPLApplication.Run;
  xPLApplication.Free;
end.

