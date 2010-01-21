program xpl_ping;

{$mode objfpc}{$H+}

uses

  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  TConfiguratorUnit,
  Forms , LResources,
  MkPinger , frm_main, frm_about;  {HostEditorF}


{$IFDEF WINDOWS}{$R xpl_ping.rc}{$ENDIF}

begin
  {$I xpl_ping.lrs}
  Application.Title:='xpl ping';
  Application.Initialize;
  TConfiguratorUnit.doBasicConfiguration;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout,frmAbout);
  Application.Icon := frmMain.Icon;
  Application.Run;
end.

