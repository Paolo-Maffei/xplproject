program xpl_balloon;

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFNDEF CONSOLE_APP}
     Interfaces, // this includes the LCL widgetset
     Forms, runtimetypeinfocontrols,
     frm_balloon,
  {$ENDIF}
     xplnotifier,
     SysUtils,
     u_xpl_gui_resource,
     u_xpl_custom_listener,
     u_xpl_application,
     u_xpl_common, ngradient, frm_messages;

{$IFDEF WINDOWS}{ $ R xpl_balloon.rc}{$ENDIF}

{$R *.res}

begin
   Application.Initialize;
   Application.ShowMainForm:=false;

   xPLApplication := TxPLCustomListener.Create(nil);
   xPLGUIResource := TxPLGUIResource.Create;

   Application.CreateForm(TFrmBalloon, FrmBalloon);
   Application.CreateForm(TfrmMessages, frmMessages);
   Application.Run;

   xPLGUIResource.Free;
   xPLApplication.Free;
end.

