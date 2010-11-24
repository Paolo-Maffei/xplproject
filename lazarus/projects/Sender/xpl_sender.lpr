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
  frm_about,
  frm_logviewer,
  frm_xplappslauncher,
  xpl_win,
  uxPLMessage,
  app_main,
  uxPLConst,
  u_xml_plugins,
  u_xml_xplplugin,
  u_xpl_message_GUI,
  u_xpl_sender;

{$IFDEF WINDOWS}{$R xpl_sender.rc}{$ENDIF}

begin
  Application.Title:='xpl_sender';
  {$I xpl_sender.lrs}
  Application.Initialize;
  xPLClient     := TxPLSender.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER);
  xPLMessageGUI := TxPLMessageGUI.Create;
  if Application.HasOption('s') then begin
     xPLMessageGUI.LoadFromFile(Application.GetOptionValue('s'));
     xPLClient.Send(xPLMessageGUI);
  end else begin
     Application.CreateForm(TfrmAbout, frmAbout);
     xPLMessageGUI.ShowForEdit([ boLoad, boSave, boCopy, boSend, boClose, boAbout],true);
  end;
  xPLMessageGUI.Destroy ;
end.

