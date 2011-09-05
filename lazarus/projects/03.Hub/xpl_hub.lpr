program xpl_hub;

{$APPTYPE CONSOLE}
{$ifdef fpc}
   {$mode objfpc}{$H+}
{$endif}

uses {$DEFINE UseCThreads}
     {$IFDEF UNIX}
        {$ifdef UseCThreads}                                                   // Warning : this unit must be the first
           cthreads ,                                                          // loaded under linux
        {$endif}
     {$ENDIF}
     u_xpl_hub
     , u_xpl_console_app
     ;

// ============================================================================
var HubApplication : TxPLConsoleApp;
    xPLHub         : TxPLHub;

{$R *.res}

// ============================================================================
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
