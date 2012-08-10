program xpl_sql;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     u_xpl_console_app,
     u_xpl_application,
     sql_listener, u_xpl_db_listener;

{$R *.res}

var MySQLApp : TxPLConsoleApp;
//    Listener : TxPLSQLListener;

begin
   MySQLApp := TxPLConsoleApp.Create(nil);
   xPLApplication := TxPLSQLListener.Create(MySQLApp);

   MySQLApp.Title := xPLApplication.AppName;
   TxPLSQLListener(xPLApplication).Listen;

   MySQLApp.Run;
   MySQLApp.Free;
end.




