program xpl_nntp;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     u_xpl_console_app,
     nntp_listener;

{$R *.res}

var MynntpApp : TxPLConsoleApp;
    Listener : TxPLnntpListener;

begin
   MynntpApp := TxPLConsoleApp.Create(nil);
   Listener := TxPLnntpListener.Create(MynntpApp);

   MynntpApp.Title := Listener.AppName;
   Listener.Listen;

   MynntpApp.Run;
   MynntpApp.Free;
end.
