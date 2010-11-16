program xpl_ping;

{$i compiler.inc}

uses

  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  app_main,
  MkPinger;

{$IFDEF WINDOWS}{$R xpl_ping.rc}{$ENDIF}

begin
  xPLApplication.Title:='xpl ping';
  xPLApplication.Run;
  xPLApplication.Free;
end.

