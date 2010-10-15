program xpl_sender;

{$mode objfpc}{$H+}
{$DEFINE FPC}
{$IFDEF UNIX} {$DEFINE UseCThreds} {$ENDIF}

uses
  {$IFDEF UNIX}
     {$IFDEF UseCThreads}
     cthreads,
     {$ENDIF}
  {$ENDIF}
  Interfaces,
  Forms,
  LResources, indylaz,
  frm_main,
  frm_about,
  frm_logviewer,
  frm_xplappslauncher,
  uxPLMessage,
  XPL,
  app_main,
  u_xml_plugins,
  u_xml_xplplugin, u_xpl_sender;

{$IFDEF WINDOWS}{$R xpl_sender.rc}{$ENDIF}
begin
  Application.Title:='xpl_sender';
  {$I xpl_sender.lrs}
  Application.Initialize;
  SendMsg   := TxPLMessage.Create;
  if Application.HasOption('s') then begin
     SendMsg.LoadFromFile(Application.GetOptionValue('s'));
     xPLClient.Send(SendMsg);
  end else begin
     Application.CreateForm(TfrmMain, frmMain);
     Application.CreateForm(TfrmAbout, frmAbout);
     Application.CreateForm(TfrmLogViewer, frmLogViewer);
     Application.CreateForm(TfrmAppLauncher, frmAppLauncher);
     Application.Icon := frmMain.Icon;
     Application.Run;
  end;
  SendMsg.Destroy ;
end.

