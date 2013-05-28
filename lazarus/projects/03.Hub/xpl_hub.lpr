program xpl_hub;

{$ifdef fpc}
   {$mode objfpc}{$H+}
{$endif}
{$R *.res}

uses heaptrc,
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
