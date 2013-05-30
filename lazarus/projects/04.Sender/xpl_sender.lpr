program xpl_sender;

{$i xpl.inc}
{$R *.res}


uses {$IFDEF DEBUG}
        heaptrc,
     {$ENDIF}
     {$IFDEF UNIX}
        cthreads,
     {$ENDIF}
  Interfaces, Forms, pl_luicontrols, pl_kcontrols, pl_excontrols,
  pl_rx, pl_lnetcomp, u_xpl_application, u_xpl_sender, u_xpl_message_GUI;

var xPLMessageGUI : TxPLMessageGUI;

begin
   Application.Initialize;
   xPLApplication := TxPLSender.Create(Application);
   xPLMessageGUI  := TxPLMessageGUI.Create(xPLApplication,'');

   xPLApplication.Adresse.Instance := 'instance';       // give a default instance name to application and message created

   if Application.HasOption('s') then begin
      xPLMessageGUI.LoadFromFile(Application.GetOptionValue('s'));
      TxPLSender(xPLApplication).Send(xPLMessageGUI);
   end else begin
      xPLMessageGUI.ShowForEdit([ boLoad, boSave, boCopy, boSend, boClose, boAbout],true);
   end;
   xPLMessageGUI.Destroy ;

end.
