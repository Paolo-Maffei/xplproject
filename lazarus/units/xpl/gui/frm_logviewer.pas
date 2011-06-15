unit frm_logviewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, ComCtrls, ActnList, Buttons, StdCtrls, ExtCtrls;

type

  { TfrmLogViewer }

  TfrmLogViewer = class(TForm)
    acDropAllLogs: TAction;
    acReload: TAction;
    Memo1: TMemo;
    acQuit: TAction;
    ActionList1: TActionList;
    tbLaunch: TToolButton;
    ToolBar: TToolBar;
    ToolButton2: TToolButton;
    ToolButton5: TToolButton;
    procedure acDropAllLogsExecute(Sender: TObject);
    procedure acReloadExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure acQuitExecute(Sender: TObject);
  private
  public
  end;

  procedure ShowFrmLogViewer;

var frmLogViewer: TfrmLogViewer;

implementation
uses u_xpl_gui_resource,
     u_xpl_application;

procedure ShowFrmLogViewer;
begin
   if not Assigned(FrmLogViewer) then Application.CreateForm(TFrmLogViewer,FrmLogViewer);
   FrmLogViewer.ShowModal;
end;

procedure TfrmLogViewer.acQuitExecute(Sender: TObject);
begin
   Close;
end;

procedure TfrmLogViewer.FormShow(Sender: TObject);
begin
   ToolBar.Images := xPLGUIResource.Images;
   acReloadExecute(self);
end;

procedure TfrmLogViewer.acDropAllLogsExecute(Sender: TObject);
begin
   xPLApplication.ResetLog;
   acReloadExecute(self);
end;

procedure TfrmLogViewer.acReloadExecute(Sender: TObject);
begin
   Memo1.Lines.LoadFromFile(xPLApplication.LogFileName);
end;

initialization
  {$I frm_logviewer.lrs}

end.

