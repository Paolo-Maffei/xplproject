program xpl_logger;

{$mode objfpc}{$H+}
{$ASSERTIONS ON}
{$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, pl_rx, pl_kcontrols, lazcontrols,
  frm_logger,
  u_xpl_application,
  logger_listener,
  xpl_win, frm_logger_config;

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
