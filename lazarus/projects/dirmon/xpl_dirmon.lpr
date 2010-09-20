program xpl_dirmon;

{$i compiler.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     app_main;

{$IFDEF WINDOWS}{$R xpl_dirmon.rc}{$ENDIF}

begin
  xPLApplication.Title:='xpl_dirmon';
  xPLApplication.Run;
  xPLApplication.Free;
end.

