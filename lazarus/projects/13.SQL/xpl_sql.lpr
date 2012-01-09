program xpl_sql;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     u_xpl_console_app,
     sql_listener, u_xpl_db_listener;

{$R *.res}

var MySQLApp : TxPLConsoleApp;
    Listener : TxPLSQLListener;

begin
   MySQLApp := TxPLConsoleApp.Create(nil);
   Listener := TxPLSQLListener.Create(MySQLApp);

   MySQLApp.Title := Listener.AppName;
   Listener.Listen;

   MySQLApp.Run;
   MySQLApp.Free;
end.




