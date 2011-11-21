unit dlg_config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ActnList, ExtCtrls, Menus, Dlg_Template,
  frame_config, u_xpl_messages;

type

  { TDlgConfig }

  TDlgConfig = class(TDlgTemplate)
    DlgacApply: TAction;
    frameConfig1: TframeConfig;
    ToolButton1: TToolButton;
    procedure DlgacApplyExecute(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  procedure ShowDlgConfig;

implementation

uses u_xpl_config
     , u_xpl_custom_listener
     , u_xpl_application
     ;

var DlgConfig: TDlgConfig;

// ============================================================================
procedure ShowDlgConfig; //(const Current : TConfigCurrentStat);
begin
   if not Assigned(DlgConfig) then Application.CreateForm(TDlgConfig, DlgConfig);
   DlgConfig.frameConfig1.SetConfigCurrent(TxPLCustomListener(xPLApplication).Config.CurrentConfig);
   DlgConfig.ShowModal;
end;

{ TDlgConfig }

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

initialization
  {$I dlg_config.lrs}

end.

