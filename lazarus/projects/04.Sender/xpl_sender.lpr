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
  Forms, pl_kcontrols, uniqueinstance_package, multiloglaz, pl_rx,
  u_xPL_Message,
  uxPLConst,
  u_xpl_application,
  u_xpl_gui_resource,
  u_xpl_sender,
  u_xpl_common,
  u_xpl_message_GUI, xpl_win;

{$IFDEF WINDOWS}{$R xpl_sender.rc}{$ENDIF}

var  xPLMessageGUI : TxPLMessageGUI;

{$R *.res}

begin
   Application.Initialize;
   AllowMultiInstance := true;
   xPLApplication := TxPLSender.Create(Application);
   xPLGUIResource := TxPLGUIResource.Create;
   xPLMessageGUI  := TxPLMessageGUI.Create(xPLApplication,'');

   xPLApplication.Adresse.Instance := 'instance';       // give a default instance name to application and message created

   if Application.HasOption('s') then begin
      xPLMessageGUI.LoadFromFile(Application.GetOptionValue('s'));
      TxPLSender(xPLApplication).Send(xPLMessageGUI);
   end else begin
      xPLMessageGUI.ShowForEdit([ boLoad, boSave, boCopy, boSend, boClose, boAbout],true);
   end;
   xPLMessageGUI.Destroy ;

   xPLGUIResource.Free;
end.

