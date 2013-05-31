program xpl_dawndusk;

{$i xpl.inc}
{$R *.res}

uses {$IFDEF UseCThreads}
     cthreads,
     {$ENDIF}
     {$IFDEF DEBUG}
     heaptrc,
     {$ENDIF}
     u_xpl_console_app,
     dawndusk_listener,
     u_xpl_application
     ;

var MyDawnDuskApp : TxPLConsoleApp;

begin
   MyDawnDuskApp := TxPLConsoleApp.Create(nil);
   xPLApplication := TxPLDawnDuskListener.Create(MyDawnDuskApp);

   MyDawnDuskApp.Title := xPLApplication.AppName;
   TxPLDawnDuskListener(xPLApplication).Listen;

   MyDawnDuskApp.Run;
   MyDawnDuskApp.Free;
end.
