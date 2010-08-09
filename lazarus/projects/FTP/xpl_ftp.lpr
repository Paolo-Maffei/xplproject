program xpl_ftp;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  TConfiguratorUnit,
  { you can add units after this }LResources, frm_about, frm_main, indylaz, uRegExTools;

{$IFDEF WINDOWS}{$R xpl_ftp.rc}{$ENDIF}

begin
  {$I xpl_ftp.lrs}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.

