program xpl_netget;

{$i compiler.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     app_main;

{$IFDEF WINDOWS}{$R xpl_netget.rc}{$ENDIF}

begin
  xPLApplication.Title:='xpl_netget';
  xPLApplication.Run;
  xPLApplication.Free;
end.
