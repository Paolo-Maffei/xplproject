program xpl_network;

{$mode objfpc}{$H+}
{$IFDEF UNIX} {$DEFINE UseCThreads} {$ENDIF}       // Needed for Indy under Linux

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, Forms, LResources,
  frm_main, frm_about, frm_xpllogviewer, frm_xplappslauncher, frm_XMLView;

{$IFDEF WINDOWS}{$R xpl_network.rc}{$ENDIF}

begin
  {$I xpl_network.lrs}
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmLogViewer, frmLogViewer);
  Application.CreateForm(TFrmAppLauncher, frmAppLauncher);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Icon := FrmMain.Icon;
  Application.CreateForm(TfrmXMLView, frmXMLView);
  Application.Run;
end.

