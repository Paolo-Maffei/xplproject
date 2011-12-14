program xpl_jabber;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
     cthreads,
  {$ENDIF}
     u_xpl_console_app,
     jabber_listener;

{$R *.res}

var MyjabberApp : TxPLConsoleApp;
    Listener : TxPLjabberListener;

begin
   MyjabberApp := TxPLConsoleApp.Create(nil);
   Listener := TxPLjabberListener.Create(MyjabberApp);

   MyjabberApp.Title := Listener.AppName;
   Listener.Listen;

   MyjabberApp.Run;
   MyjabberApp.Free;
end.
