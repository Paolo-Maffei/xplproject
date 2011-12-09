unit u_xpl_console_app;

{$mode objfpc}

interface

uses Classes
     , SysUtils
     , CustApp
     , fpTimer
     ;

type TxPLConsoleApp = class(TCustomApplication)
     protected
        procedure DoRun; override;
     public
        destructor  Destroy;                      override;
        procedure   Run;                          reintroduce;
     end;

implementation // =============================================================
uses Keyboard;

const K_STR_1 = 'Quitting the application...';
      K_STR_2 = 'Press "q" to quit.';


// TxPLConsoleApp =============================================================
procedure TxPLConsoleApp.DoRun;
var k : TKeyEvent;
begin
   inherited DoRun;

   if PollKeyEvent<>0 then begin
      K := TranslateKeyEvent(GetKeyEvent);
      if KeyEventToString(K) = 'q' then terminate;
   end;

   CheckSynchronize(500);
end;

destructor TxPLConsoleApp.Destroy;
begin
   writeln(K_STR_1);
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
   writeln(K_STR_2);

   inherited Run;
end;

end.

