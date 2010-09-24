program xpl_sender;

{$mode objfpc}{$H+}
{$DEFINE FPC}
{$IFDEF UNIX} {$DEFINE UseCThreds} {$ENDIF}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, LResources, frm_main, XPL, frm_about, uxPLMessage,
  frm_xplappslauncher,
  frm_xpllogviewer,
  sharedlogger,
  u_xml_plugins,
  u_xml_xplplugin;

{$IFDEF WINDOWS}{$R xpl_sender.rc}{$ENDIF}
var SendMsg : TxPLMessage;
begin
  {$I xpl_sender.lrs}
  Application.Initialize;

  if Application.HasOption('s') then begin
     SendMsg := TxPLMessage.Create;
     SendMsg.LoadFromFile(Application.GetOptionValue('s'));
     SendMsg.Send;
     SendMsg.Destroy ;
  end else begin
     Application.CreateForm(TfrmMain, frmMain);
     Application.CreateForm(TfrmAppLauncher, frmAppLauncher);
     Application.CreateForm(TfrmAbout, frmAbout);
     Application.CreateForm(TfrmLogViewer, frmLogViewer);
     Application.Icon := frmMain.Icon;
     Application.Run;
  end;
end.

