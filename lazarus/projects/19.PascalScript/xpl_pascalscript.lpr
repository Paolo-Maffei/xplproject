program xpl_pascalscript;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  u_xpl_console_app
  , PS_Listener, u_xpl_cache_manager;

var MyPSScriptApp : TxPLConsoleApp;
    Listener : TxPLPSListener;

{$R *.res}

begin
   MyPSScriptApp := TxPLConsoleApp.Create(nil);
   Listener := TxPLPSListener.Create(MyPSScriptApp);

   MyPSScriptApp.Title := Listener.AppName;
   Listener.Listen;

   MyPSScriptApp.Run;
   MyPSScriptApp.Free;
end.


