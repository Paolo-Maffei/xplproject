program xpl_jabber;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
     cthreads,
  {$ENDIF}
     u_xpl_console_app
     , u_xpl_application
     , jabber_listener
     ;

var MyjabberApp : TxPLConsoleApp;

{$R *.res}

begin
   MyjabberApp := TxPLConsoleApp.Create(nil);
   xPLApplication := TxPLjabberListener.Create(MyjabberApp);

   MyjabberApp.Title := xPLApplication.AppName;
   TxPLJabberListener(xPLApplication).Listen;

   MyjabberApp.Run;
   MyjabberApp.Free;

end.
