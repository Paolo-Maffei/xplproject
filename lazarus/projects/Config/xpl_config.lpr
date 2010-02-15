program xpl_config;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, LResources,
  uxPLListener, frm_main, XPL, frm_about;

{$IFDEF WINDOWS}{$R xpl_config.rc}{$ENDIF}

begin
  {$I xpl_config.lrs}
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmAbout,FrmAbout);
  Application.Run;
end.

