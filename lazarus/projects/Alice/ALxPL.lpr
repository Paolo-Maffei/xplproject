program ALxPL;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, LResources,
  // UDebug in 'UDebug.pas' {DebugForm},
  frm_main, frm_about;


{$IFDEF WINDOWS}{$R ALxPL.rc}{$ENDIF}

begin
  {$I ALxPL.lrs}

  Application.Initialize;

//  Log:=TLog.Create;

  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmAbout, FrmAbout);
  Application.Icon := frmMain.Icon;
  Application.Run;




end.
