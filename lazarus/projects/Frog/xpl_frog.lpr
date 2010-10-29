program xpl_frog;

{$i compiler.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  app_main,
  { you can add units after this }LResources, frm_about, frm_main, indylaz;

{$IFDEF WINDOWS}{$R xpl_frog.rc}{$ENDIF}

begin
  {$I xpl_frog.lrs}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.

