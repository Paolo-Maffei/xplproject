unit frm_logviewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, ComCtrls, ActnList, Buttons, StdCtrls, ExtCtrls, Dlg_Template;

type

  { TfrmLogViewer }

  TfrmLogViewer = class(TDlgTemplate)
    acDropAllLogs: TAction;
    acReload: TAction;
    Memo1: TMemo;
    ToolButton1: TToolButton;
    procedure acDropAllLogsExecute(Sender: TObject);
    procedure acReloadExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

  procedure ShowFrmLogViewer;

var frmLogViewer: TfrmLogViewer;

implementation // =============================================================
uses u_xpl_gui_resource
     , u_xpl_application
     ;

//=============================================================================
procedure ShowFrmLogViewer;
begin
   if not Assigned(FrmLogViewer) then Application.CreateForm(TFrmLogViewer,FrmLogViewer);
   FrmLogViewer.ShowModal;
end;

//=============================================================================
procedure TfrmLogViewer.FormShow(Sender: TObject);
begin
   inherited;
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

//=============================================================================
initialization
  {$I frm_logviewer.lrs}

end.

