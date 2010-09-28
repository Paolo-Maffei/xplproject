program xpl_network;

{$mode objfpc}{$H+}
{$IFDEF UNIX} {$DEFINE UseCThreads} {$ENDIF}       // Needed for Indy under Linux

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, Forms, LResources,
  app_main,
  frm_main,
  frm_about,
  frm_logviewer,
  frm_xplappslauncher,
  u_xml_plugins,
  frm_XMLView;

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

