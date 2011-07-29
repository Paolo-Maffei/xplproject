program xpl_exec;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     u_xpl_console_app,
     u_xpl_common,
     exec_listener;

{$R *.res}

var MyexecApp : TxPLConsoleApp;
    Listener : TxPLexecListener;

begin
   InstanceInitStyle := iisMacAddress;
   MyexecApp := TxPLConsoleApp.Create(nil);
   Listener := TxPLexecListener.Create(MyexecApp);

   MyexecApp.Title := Listener.AppName;
   Listener.Listen;

   MyexecApp.Run;
   MyexecApp.Free;
end.




