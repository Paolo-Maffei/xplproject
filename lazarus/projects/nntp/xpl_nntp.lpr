program xpl_nntp;

{$i compiler.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     app_main;

{$IFDEF WINDOWS}{$R xpl_nntp.rc}{$ENDIF}

begin
  xPLApplication.Title:='xpl_nntp';
  xPLApplication.Run;
  xPLApplication.Free;
end.

