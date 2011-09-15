unit frm_configurator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, ActnList, Menus, StdCtrls, XMLPropStorage, RxAboutDialog,
  RTTICtrls, frm_template, v_xplmsg_opendialog,
  frame_config, u_configuration_record, fpTimer, u_xpl_message,
  fpc_delphi_compat;

type

  { TfrmConfigurator }

  TfrmConfigurator = class(TFrmTemplate)
    acClear: TAction;
    acDiscoverNetwork: TAction;
    acLoadConfig: TAction;
    acRequestConfig: TAction;
    acSaveConfig: TAction;
    acSendConfig: TAction;
    AppActionList: TActionList;
    ckCfgXMLAvail: TTICheckBox;
    frameConfig1: TframeConfig;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblDeviceName: TTILabel;
    lblDieAt: TTILabel;
    lblLastHB: TTILabel;

    OpenMessage: TxPLMsgOpenDialog;
    Panel2: TPanel;
    Splitter1: TSplitter;
    ToolBar2: TToolBar;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    tvDevices: TTreeView;
    xPLMsgSaveDlg: TxPLMsgSaveDialog;
    procedure acClearExecute(Sender: TObject);
    procedure acDiscoverNetworkExecute(Sender: TObject);
    procedure acLoadConfigExecute(Sender: TObject);
    procedure acRequestConfigExecute(Sender: TObject);
    procedure acSaveConfigExecute(Sender: TObject);
    procedure acSendConfigExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure JvAppEvents1Idle(Sender: TObject);
    procedure lbDevicesClick(Sender: TObject);
  private
    node_discovered,
    node_configdone : TTreeNode;
    timer : TxPLTimer;
  public
    Current_Config : TConfigurationRecord;
  end;

var
  frmConfigurator: TfrmConfigurator;

implementation // =============================================================
uses uxPLConst
     , uRegExpr
     , frm_xplappslauncher
     , frm_logviewer
     , u_xpl_gui_resource
     , u_xpl_application
     , u_xpl_common
     , u_xpl_custom_message
     , u_xpl_messages
     , u_xpl_schema
     , u_xpl_header
     , u_xpl_listener
     , u_xpl_address
     , configurator_listener
     , u_xpl_custom_listener
     ;

const //=======================================================================
  rsDiscovered = 'Discovered';
  rsConfigDone = 'Configured';

{ TfrmConfigurator ===========================================================}
procedure TfrmConfigurator.FormCreate(Sender: TObject);
begin
   inherited;

   ToolBar2.Images:= ToolBar.Images;
   acClearExecute(self);
   TConfigListener(xPLApplication).Listen;

   timer := TxPLTimer.Create(self);
   timer.Interval := 50;
   timer.OnTimer:= @JvAppEvents1Idle;
   timer.Enabled := true;
end;

procedure TfrmConfigurator.acDiscoverNetworkExecute(Sender: TObject);
begin
   TConfigListener(xPLApplication).SendHBeatRequestMsg;
end;

procedure TfrmConfigurator.acLoadConfigExecute(Sender: TObject);
var Msg : TConfigCurrentStat;
begin
   OpenMessage.InitialDir := xPLApplication.Folders.DeviceDir;
   if not OpenMessage.Execute then exit;
   Msg := TConfigCurrentStat.Create(self);
   Msg.LoadFromFile(OpenMessage.FileName);
   FrameConfig1.SetConfigCurrent(Msg);
   Msg.Free;
end;

procedure TfrmConfigurator.acRequestConfigExecute(Sender: TObject);
var Msg : TConfigListCmnd;
begin
   Msg := TConfigListCmnd.Create(self);
   Msg.target.Assign(Current_Config.Address);
   TxPLListener(xPLApplication).Send(Msg);
   Msg.Free;
end;

procedure TfrmConfigurator.JvAppEvents1Idle(Sender: TObject);
var aNode,ParentNode : ttreenode;
    adr : TxPLAddress;
    i : integer;
    Device : TConfigurationRecord;
begin
   with TConfigListener(xPLApplication) do begin
      acDiscoverNetwork.Enabled:=(ConnectionStatus = connected);

      for i:=0 to Discovered.Count-1 do begin                                  // Check every discovered device
          Device := Discovered.Data[i];
          aNode  := tvDevices.Items.FindNodeWithText(Device.Address.RawxPL);
          if aNode = nil then begin                                            // A node was discovered and not displayed
             if Device.WaitingConf then ParentNode := node_discovered
                                   else ParentNode := node_configdone;
             aNode := tvDevices.Items.AddChild(ParentNode,Device.Address.RawxPL);
             aNode.Data := Device;
          end else begin                                                       // The node is present,
             if Device.WaitingConf then begin                                  // check that it is in the good tree portion
                if (aNode.Parent = node_configdone) then aNode.MoveTo(node_discovered,naAddChild);
             end else
                if (aNode.Parent = node_discovered) then aNode.MoveTo(node_configdone,naAddChild);
          end;
      end;
      adr := TxPLAddress.Create;
      for aNode in tvDevices.Items do begin                                    // Check that every module present in
          if (aNode<>node_discovered) and (aNode<>node_configdone) then begin  // the tree is always present in discovered list
             adr.RawxPL := aNode.Text;
             if Discovered.IndexOf(adr.Device) = -1 then aNode.Delete;
          end;
      end;
      adr.Free;
   end;

   Panel2.Visible := not (tvDevices.Items.Count < 2);
end;

procedure TfrmConfigurator.acSaveConfigExecute(Sender: TObject);
var Msg : TConfigResponseCmnd;
begin
   xPLMsgSaveDlg.InitialDir := xPLApplication.Folders.DeviceDir;
   xPLMsgSaveDlg.FileName   := Current_Config.Address.RawxPL;
   if xPLMsgSaveDlg.Execute then begin
      Msg := TConfigResponseCmnd.Create(self);
      Msg.MsgName := 'Configuration file for device : ' + Current_Config.Address.RawxPL;
      FrameConfig1.Assign(Msg);
      Msg.SaveToFile(xPLMsgSaveDlg.FileName);
      Msg.Free;
   end;
end;

procedure TfrmConfigurator.acSendConfigExecute(Sender: TObject);
var CfgResponse : TConfigResponseCmnd;
begin
   CfgResponse := TConfigResponseCmnd.Create(self);
   CfgResponse.target.Assign(Current_Config.Address);
   FrameConfig1.Assign(CfgResponse);
   TxPLListener(xPLApplication).Send(CfgResponse);
   CfgResponse.Free;
end;

procedure TfrmConfigurator.acClearExecute(Sender: TObject);
begin
   while tvDevices.Items.Count > 0 do tvDevices.Items[0].Delete;
   node_discovered := tvDevices.Items.Add(nil,rsDiscovered);
   node_configdone := tvDevices.Items.Add(nil,rsConfigDone);
end;

procedure TfrmConfigurator.lbDevicesClick(Sender: TObject);
begin
   if tvDevices.Selected = nil then exit;
   if tvDevices.Selected.Data = nil then exit;

   Current_Config := TConfigurationRecord(tvDevices.Selected.Data);

   lblDeviceName.Link.TIObject := Current_Config.Address;
   lblDeviceName.Link.TIPropertyName := 'RawxPL';
   lblLastHB.Link.TIObject := Current_Config;
   lblLastHB.Link.TIPropertyName := 'LastHBeat';
   lblDieAt.Link.TIObject := Current_Config;
   lblDieAt.Link.TIPropertyName := 'DieAt';
   ckCfgXMLAvail.Link.TIObject := Current_Config;
   ckCfgXMLAvail.Link.TIPropertyName := 'XMLCfgAvail';

//   frameConfig1.SetConfigRecord(Current_Config);
   frameConfig1.SetConfigCurrent(Current_Config.Config.CurrentConfig);
end;

initialization
  {$I frm_configurator.lrs}

end.

