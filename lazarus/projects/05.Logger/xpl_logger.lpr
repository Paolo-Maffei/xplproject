program xpl_logger;

{$mode objfpc}{$H+}
{$ASSERTIONS ON}
{$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, aformula, pl_rx, pl_kcontrols,
  frm_logger,
  u_xpl_application,
  u_xpl_common,
  logger_listener, frm_appsettings, frm_plugindetail,
  u_xpl_gui_resource;

{$IFDEF WINDOWS}{$R xpl_logger.rc}{$ENDIF}

begin
   Application.Initialize;

   xPLApplication := TLoggerListener.Create;
   xPLGUIResource := TxPLGUIResource.Create;
   Application.CreateForm(TfrmLogger, frmLogger);
   Application.CreateForm(TfrmAppSettings, frmAppSettings);
   Application.Icon := FrmLogger.Icon;
   Application.Run;

   xPLGUIResource.Free;
   xPLApplication.Free;
end.

