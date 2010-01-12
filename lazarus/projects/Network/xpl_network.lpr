program xpl_network;

{$mode objfpc}{$H+}
{$IFDEF UNIX} {$DEFINE UseCThreads} {$ENDIF}       // Needed for Indy under Linux

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, Forms, LResources,
  frm_main, frm_about, frm_xplappslauncher, indylaz;

{$IFDEF WINDOWS}{$R xpl_network.rc}{$ENDIF}

begin
  {$I xpl_network.lrs}
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmAppLauncher, frmAppLauncher);
  Application.Icon := FrmMain.Icon;
  Application.Run;
end.

