program xpl_logger;

{$mode objfpc}{$H+}
{$ASSERTIONS ON}
{$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  frm_logger,
  frm_appsettings,
  xpl_win,
  frm_plugindetail,
  u_xpl_application,
  u_xpl_common,
  logger_listener,
  u_xpl_gui_resource,
  u_xml_config,
  u_Configuration_Record, frame_message;

{$IFDEF WINDOWS}{$R xpl_logger.rc}{$ENDIF}

{ $ R *.res}

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

