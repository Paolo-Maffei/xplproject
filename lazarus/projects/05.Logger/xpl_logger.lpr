program xpl_logger;

{$mode objfpc}{$H+}
{$ASSERTIONS ON}
{$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, pl_rx, pl_kcontrols, uniqueinstance_package, multiloglaz, aformula,
  frm_logger, u_xpl_config,
  u_xpl_application,
  u_xpl_common,
  logger_listener, frm_plugindetail,
  u_xpl_gui_resource, dlg_config, frame_config, xpl_win, frm_logger_config;

{$IFDEF WINDOWS}{$R xpl_logger.rc}{$ENDIF}

begin
   Application.Initialize;

   xPLApplication := TLoggerListener.Create;
   xPLGUIResource := TxPLGUIResource.Create;
   Application.CreateForm(TfrmLogger, frmLogger);
   Application.CreateForm(TFrmLoggerConfig, FrmLoggerConfig);
   Application.Icon := FrmLogger.Icon;
   Application.Run;

   xPLGUIResource.Free;
   xPLApplication.Free;
end.

