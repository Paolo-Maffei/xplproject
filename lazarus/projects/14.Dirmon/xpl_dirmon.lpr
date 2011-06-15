program xpl_dirmon;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     u_xpl_console_app,
     dirmon_listener;

{$R *.res}

var MydirmonApp : TxPLConsoleApp;
    Listener : TxPLdirmonListener;

begin
   MydirmonApp := TxPLConsoleApp.Create(nil);
   Listener := TxPLdirmonListener.Create(MydirmonApp);

   MydirmonApp.Title := Listener.AppName;
   Listener.Listen;

   MydirmonApp.Run;
   MydirmonApp.Free;
end.




