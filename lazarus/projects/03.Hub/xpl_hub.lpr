program xpl_hub;

{$ifdef fpc}
   {$mode objfpc}{$H+}
{$endif}
{$R *.res}

uses {$define UseCThreads}
     {$IFDEF UNIX}
        {$IFDEF UseCThreads}
           cthreads,
        {$ENDIF}
     {$ENDIF}
     u_xpl_hub
     , u_xpl_application
     , u_xpl_console_app;

// ============================================================================
var HubApplication : TxPLConsoleApp;

// ============================================================================
begin
   HubApplication := TxPLConsoleApp.Create(nil);

   xPLApplication := TxPLHub.Create(HubApplication);
   try
      TxPLHub(xPLApplication).Start;
   except                                                                      // Catch errors that can appear when
   end;                                                                        // starting the listener

   HubApplication.Run;
   HubApplication.Free;
end.

