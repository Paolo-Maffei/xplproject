program xpl_free;

{$i compiler.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  app_main;

{$IFDEF WINDOWS}{$R xpl_free.rc}{$ENDIF}

begin
  xPLApplication.Title := 'xpl_free';
  xPLApplication.Run;
  xPLApplication.Free;
end.

