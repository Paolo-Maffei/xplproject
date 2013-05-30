program xpl_hub;

{$i xpl.inc}
{$R *.res}

uses {$IFDEF DEBUG}
        heaptrc,
     {$ENDIF}
     {$IFDEF UNIX}
        cthreads,
        cwstring,
     {$ENDIF}
     u_xpl_hub
     , u_xpl_application
     , u_xpl_console_app
     ;

// ============================================================================
var HubApplication : TxPLConsoleApp;

// ============================================================================
begin
   HubApplication := TxPLConsoleApp.Create(nil);

   xPLApplication := TxPLHub.Create(HubApplication);
   TxPLHub(xPLApplication).Start;

   HubApplication.Run;
   HubApplication.Free;
end.
