program xpl_free;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     u_xpl_console_app,
     free_listener;

{$R *.res}

var MyfreeApp : TxPLConsoleApp;
    Listener : TxPLfreeListener;

begin
   MyfreeApp := TxPLConsoleApp.Create(nil);
   Listener := TxPLfreeListener.Create(MyfreeApp);

   MyfreeApp.Title := Listener.AppName;
   Listener.Listen;

   MyfreeApp.Run;
   MyfreeApp.Free;
end.




