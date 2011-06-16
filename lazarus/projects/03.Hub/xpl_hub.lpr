program xpl_hub;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses u_xpl_hub
     {$IFDEF UNIX}
             {$IFDEF UseCThreads}
             , cthreads
             {$ENDIF}
     {$ENDIF}
     , u_xpl_console_app
     ;

{$R *.res}

var HubApplication : TxPLConsoleApp;
    xPLHub         : TxPLHub;

begin
   HubApplication := TxPLConsoleApp.Create(nil);

   xPLHub := TxPLHub.Create(HubApplication);
   try
      xPLHub.Start;
   except                                                                      // Catch errors that can appear when
   end;                                                                        // starting the listener

   HubApplication.Run;
   HubApplication.Free;
end.

