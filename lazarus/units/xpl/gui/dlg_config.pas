unit dlg_config;

{$mode objfpc}{$H+}
{$r *.lfm}

interface

uses Classes, SysUtils, FileUtil, LSControls, LResources, Forms, Controls,
  Graphics, Dialogs, ComCtrls, ActnList, ExtCtrls, Menus, Dlg_Template, frame_config;

type // TDlgConfig ============================================================
     TDlgConfig = class(TDlgTemplate)
        DlgacApply: TAction;
        BtnApply: TLSBitBtn;
        frameConfig1: TframeConfig;
        ToolButton1: TToolButton;
        procedure DlgacApplyExecute(Sender: TObject);
        procedure FormCreate(Sender: TObject);
     end;

  procedure ShowDlgConfig;

implementation // =============================================================
uses u_xpl_config
     , u_xpl_custom_listener
     , u_xpl_gui_resource
     , u_xpl_application
     , u_xpl_messages
     ;

var DlgConfig: TDlgConfig;

// ============================================================================
procedure ShowDlgConfig;
begin
   if not Assigned(DlgConfig) then Application.CreateForm(TDlgConfig, DlgConfig);
   DlgConfig.frameConfig1.SetConfigCurrent(TxPLCustomListener(xPLApplication).Config.CurrentConfig);
   DlgConfig.ShowModal;
end;

// TDlgConfig =================================================================
procedure TDlgConfig.FormCreate(Sender: TObject);
begin
   inherited;
   SetButtonImage(BtnApply,DlgAcApply,K_IMG_DOCUMENT_SAVE);
end;

procedure TDlgConfig.DlgacApplyExecute(Sender: TObject);
var Msg : TConfigResponseCmnd;
begin
   Assert(xPLApplication is TxPLCustomListener);
   Msg := TConfigResponseCmnd.Create(self);
   FrameConfig1.Assign(Msg);
   Msg.target.Assign(xPLApplication.Adresse);
   Msg.Source.Assign(Msg.target);
   TxPLCustomListener(xPLApplication).HandleConfigMessage(Msg);
   Msg.Free;
end;

end.
