program xpl_balloon;

{$i xpl.inc}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
//  heaptrc,
  {$IFNDEF CONSOLE_APP}
     Interfaces, // this includes the LCL widgetset
     Forms, pl_rx, runtimetypeinfocontrols, pl_excontrols,
     pl_luicontrols, frm_balloon,
  {$ENDIF}
     xplnotifier,
     SysUtils,
     u_xpl_gui_resource,
     u_xpl_custom_listener,
     u_xpl_application,
     u_xpl_common;

{$IFDEF WINDOWS}{ $ R xpl_balloon.rc}{$ENDIF}

{$R *.res}

begin
   Application.Initialize;

   xPLApplication := TxPLCustomListener.Create(Application);
   Application.CreateForm(TFrmBalloon, FrmBalloon);
   Application.Run;

   xPLApplication.Free;
end.
