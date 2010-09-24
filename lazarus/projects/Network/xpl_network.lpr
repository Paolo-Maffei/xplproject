program xpl_network;

{$mode objfpc}{$H+}
{$IFDEF UNIX} {$DEFINE UseCThreads} {$ENDIF}                                    // Needed for Indy under Linux

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, Forms, LResources,
  frm_main,
  frm_about,
  frm_xplappslauncher,
  frm_xpllogviewer,
  u_xml_plugins,
  frm_XMLView, sharedlogger;

{$IFDEF WINDOWS}{$R xpl_network.rc}{$ENDIF}

begin
  {$I xpl_network.lrs}
  Application.Initialize;
  Application.CreateForm(TfrmMain        , FrmMain);
  Application.CreateForm(TfrmAppLauncher , frmAppLauncher);
  Application.CreateForm(TfrmAbout       , frmAbout);
  Application.CreateForm(TfrmLogViewer   , frmLogViewer);
  Application.Icon := FrmMain.Icon;
  Application.CreateForm(TfrmXMLView, frmXMLView);
  Application.Run;
end.

