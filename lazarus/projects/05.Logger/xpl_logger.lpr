program xpl_logger;

{$mode objfpc}{$H+}
{$ASSERTIONS ON}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
//  heaptrc,
  Interfaces, // this includes the LCL widgetset
  Forms, pl_rx, pl_kcontrols, lazcontrols, pl_excontrols, pl_lnetcomp,
  frm_logger,
  u_xpl_application, xpl_win,
  logger_listener, frm_logger_config, frame_message
  ;

{$R *.res}

begin
   Application.Initialize;

   xPLApplication := TLoggerListener.Create;
   Application.CreateForm(TfrmLogger, frmLogger);
   Application.CreateForm(TfrmLoggerConfig,frmLoggerConfig);
   Application.Icon := FrmLogger.Icon;
   Application.Run;

   xPLApplication.Free;
end.
