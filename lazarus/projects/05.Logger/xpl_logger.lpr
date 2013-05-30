program xpl_logger;

{$i xpl.inc}
{$R *.res}

uses {$IFDEF UNIX}
     cthreads,
     {$ENDIF}
     {$IFDEF DEBUG}
     heaptrc,
     {$ENDIF}
     Interfaces, // this includes the LCL widgetset
     Forms, pl_rx, pl_kcontrols, lazcontrols, pl_excontrols, pl_lnetcomp,
     frm_logger,
     u_xpl_application, xpl_win,
     logger_listener, frm_logger_config, frame_message
     ;



begin
   Application.Initialize;

   xPLApplication := TLoggerListener.Create(Application);
   Application.CreateForm(TfrmLogger, frmLogger);
   Application.CreateForm(TFrmLoggerConfig, FrmLoggerConfig);
   Application.Icon := FrmLogger.Icon;
   Application.Run;

   xPLApplication.Free;
end.
