program xpl_frog;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  TConfiguratorUnit,
  { you can add units after this }LResources, frm_about, frm_main, indylaz, uRegExTools;

{$IFDEF WINDOWS}{$R xpl_frog.rc}{$ENDIF}

begin
  {$I xpl_frog.lrs}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.

