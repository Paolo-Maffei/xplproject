unit u_xpl_console_app;

{$i xpl.inc}

interface

uses CustApp;

type // TxPLConsoleApp ========================================================
     TxPLConsoleApp = class(TCustomApplication)
     protected
        procedure DoRun; override;
     public
        destructor  Destroy; override;
        procedure   Run;  reintroduce;
     end;

implementation // =============================================================
uses Keyboard
     , Classes
     , SysUtils
     , u_xpl_application
     ;

const K_STR_1 = 'Quitting the application...';
      K_STR_2 = 'Press "q" to quit.';

// TxPLConsoleApp =============================================================
procedure TxPLConsoleApp.DoRun;
begin
   inherited DoRun;

   if (PollKeyEvent<>0) and (KeyEventToString(TranslateKeyEvent(GetKeyEvent)) = 'q')
      then terminate;

   CheckSynchronize(500);
end;

destructor TxPLConsoleApp.Destroy;
begin
   xPLApplication.Log(etInfo,K_STR_1);
   DoneKeyboard;

   inherited Destroy;
   {if destroy hangs it comes from this fu**ing fptimer bug, get the good here
   http://svn.freepascal.org/cgi-bin/viewvc.cgi/trunk/packages/fcl-base/src/fptimer.pp?revision=13012
   et forcer son utilisation en ajoutant le chemin de recherche :
   C:\pp\packages\fcl-base\src\ dans les paths du projet }
end;

procedure TxPLConsoleApp.Run;
begin
   InitKeyboard;
   xPLApplication.Log(etInfo,K_STR_2);

   inherited Run;
end;

end.
