program xpl_opc;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  TConfiguratorUnit,
  { you can add units after this }LResources, frm_about, u_xml_globals,
  frm_main, indylaz, uxpldeterminators, uHoldingStringList, u_xpl_opc, 
uxpldevices;

{$IFDEF WINDOWS}{$R xpl_opc.rc}{$ENDIF}

begin
  {$I xpl_opc.lrs}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.

