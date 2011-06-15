program xpl_dawndusk;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     u_xpl_console_app,
     dawndusk_listener;

{$R *.res}

var MyDawnDuskApp : TxPLConsoleApp;
    Listener : TxPLDawnDuskListener;

begin
   MyDawnDuskApp := TxPLConsoleApp.Create(nil);
   Listener := TxPLDawnDuskListener.Create(MyDawnDuskApp);

   MyDawnDuskApp.Title := Listener.AppName;
   Listener.Listen;

   MyDawnDuskApp.Run;
   MyDawnDuskApp.Free;
end.

