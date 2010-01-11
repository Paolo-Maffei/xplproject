program xpl_sender;

{$mode objfpc}{$H+}
{$IFDEF UNIX} {$DEFINE UseCThreds} {$ENDIF}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, LResources, frm_main, XPL, frm_about, uxPLMessage,
  TConfiguratorUnit,
  frm_xplappslauncher;

{$IFDEF WINDOWS}{$R xpl_sender.rc}{$ENDIF}
var SendMsg : TxPLMessage;
begin
  {$I xpl_sender.lrs}
  Application.Initialize;

  if Application.HasOption('s') then begin
     SendMsg := TxPLMessage.Create;
     SendMsg.LoadFromFile(Application.GetOptionValue('s'));
     SendMsg.Send;
     SendMsg.Destroy ;
  end else begin
     TConfiguratorUnit.doBasicConfiguration;
     Application.CreateForm(TfrmMain, frmMain);
     Application.CreateForm(TfrmAppLauncher, frmAppLauncher);
     Application.CreateForm(TfrmAbout, frmAbout);
     Application.Icon := frmMain.Icon;
     Application.Run;
  end;
end.

