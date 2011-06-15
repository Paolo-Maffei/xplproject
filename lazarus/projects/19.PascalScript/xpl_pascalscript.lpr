program xpl_pascalscript;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  u_xpl_console_app
  , PS_Listener
  ;

var MyPSScriptApp : TxPLConsoleApp;
    Listener : TxPLPSListener;

begin
   MyPSScriptApp := TxPLConsoleApp.Create(nil);
   Listener := TxPLPSListener.Create(MyPSScriptApp);

   MyPSScriptApp.Title := Listener.AppName;
   Listener.Listen;

   MyPSScriptApp.Run;
   MyPSScriptApp.Free;
end.


