program ALxPL;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  app_main;


begin
  MyAliceApp.Run;
  MyAliceApp.Free;
end.
