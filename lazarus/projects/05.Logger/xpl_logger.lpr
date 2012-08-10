program xpl_logger;

{$mode objfpc}{$H+}
{$ASSERTIONS ON}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, pl_rx, pl_kcontrols, lazcontrols, pl_excontrols,
  frm_logger,
  u_xpl_application,
  logger_listener,
  xpl_win
  , frm_logger_config
  , frame_message
  ;

{$R *.res}

begin
   Application.Initialize;

   xPLApplication := TLoggerListener.Create;
   Application.CreateForm(TfrmLogger, frmLogger);
   Application.CreateForm(TFrmLoggerConfig, FrmLoggerConfig);
   Application.Icon := FrmLogger.Icon;
   Application.Run;

   xPLApplication.Free;
end.

