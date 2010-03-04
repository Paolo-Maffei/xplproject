program xpl_timer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms , LResources, { you can add units after this }
  TConfiguratorUnit,
  frm_main, frm_xPLSingleEvent, frm_about, frm_xplappslauncher,
  frm_xplrecurevent, uxPLTimer;

{$IFDEF WINDOWS}{$R xpl_timer.rc}{$ENDIF}

begin
  {$I xpl_timer.lrs}
  Application.Initialize;
  TConfiguratorUnit.doBasicConfiguration;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Icon := frmMain.Icon;
  Application.Run;
end.

