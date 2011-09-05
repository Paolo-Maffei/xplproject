program xpl_netget;

{$APPTYPE CONSOLE}
{$DEFINE CONSOLE_APP}
{$mode objfpc}{$H+}

uses {$define UseCThreads}
     {$IFDEF UNIX}
        {$IFDEF UseCThreads}
           cthreads,
        {$ENDIF}
     {$ENDIF}
     app_main;

{$R *.res}

begin
  MyNetGetApp.Run;
  MyNetGetApp.Free;
end.
