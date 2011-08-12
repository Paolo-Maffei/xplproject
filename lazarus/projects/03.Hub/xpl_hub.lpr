program xpl_hub;

{$APPTYPE CONSOLE}
{$ifdef fpc}
   {$mode objfpc}{$H+}
{$endif}

uses u_xpl_hub
     {$IFDEF UNIX}
             {$IFDEF UseCThreads}
             , cthreads
             {$ENDIF}
     {$ENDIF}
     , u_xpl_console_app
     ;

{$r *.res}

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

