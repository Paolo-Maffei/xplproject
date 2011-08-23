unit frm_configurator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, ActnList, Menus, StdCtrls, JvAppEvent, RTTICtrls,
  frm_template, v_xplmsg_opendialog, v_msgbody_stringgrid,
  u_configuration_record, fpTimer, u_xpl_message;

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
    HBDetail: TBodyMessageGrid;
    JvAppEvents1: TJvAppEvents;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblDeviceName: TTILabel;
    lblDieAt: TTILabel;
    lblError: TLabel;
    lblLastHB: TTILabel;
    lblRegExpr: TLabel;
    Memo1: TMemo;
    OpenMessage: TxPLMsgOpenDialog;
    Panel2: TPanel;
    Panel3: TPanel;
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
    procedure HBDetailEditingDone(Sender: TObject);
    procedure HBDetailSelection(Sender: TObject; aCol, aRow: Integer);
    procedure JvAppEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure lbDevicesClick(Sender: TObject);
  private
    node_discovered,
    node_configdone : TTreeNode;
  public
    Current_Config : TConfigurationRecord;
  end;

var
  frmConfigurator: TfrmConfigurator;

implementation // =============================================================
uses frm_about
     , uxPLConst
     , uRegExpr
     , frm_xplappslauncher
     , frm_logviewer
     , u_xpl_gui_resource
     , u_xpl_application
     , u_xpl_common
     , u_xpl_custom_message
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
   JvAppEvents1 := TJvAppEvents.Create(self);
   JvAppEvents1.OnIdle:=@JvAppEvents1Idle;
end;

procedure TfrmConfigurator.acDiscoverNetworkExecute(Sender: TObject);
begin
   TConfigListener(xPLApplication).SendHBeatRequestMsg;
end;

procedure TfrmConfigurator.acLoadConfigExecute(Sender: TObject);
begin
   OpenMessage.InitialDir := xPLApplication.Folders.DeviceDir;
   if not OpenMessage.Execute then exit;
   with TxPLMessage.Create(nil) do try
        LoadFromFile(OpenMessage.FileName);
        HBDetail.Assign(Body);
   finally
      Free;
   end;
end;

procedure TfrmConfigurator.acRequestConfigExecute(Sender: TObject);
begin
   TxPLListener(xPLApplication).SendMessage(cmnd,Current_Config.Address.RawxPL,Schema_ConfigList,['command'],['request']);
end;

procedure TfrmConfigurator.JvAppEvents1Idle(Sender: TObject; var Done: Boolean);
var aNode,ParentNode : ttreenode;
    adr : TxPLAddress;
    i : integer;
    aMsg : TxPLCustomMessage;
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

   Panel2.Visible := not (tvDevices.Items.Count < 3);
end;

procedure TfrmConfigurator.acSaveConfigExecute(Sender: TObject);
begin
   xPLMsgSaveDlg.InitialDir := xPLApplication.Folders.DeviceDir;
   xPLMsgSaveDlg.FileName   := Current_Config.Address.RawxPL;
   if xPLMsgSaveDlg.Execute then with TxPLMessage.Create(nil) do try
         MsgName := 'Configuration file for device : ' + Current_Config.Address.RawxPL;
         HBDetail.CopyTo(Body);
         SaveToFile(xPLMsgSaveDlg.FileName);
      finally
         Free;
      end;
end;

procedure TfrmConfigurator.acSendConfigExecute(Sender: TObject);
var keys, values : Array of String;
    i : integer;
begin
   SetLength(Keys,HBDetail.Rowcount-1);
   SetLength(Values,HBDetail.Rowcount-1);

   for i := 1 to HBDetail.Rowcount-1 do begin                                   // Browse all configuration items
      Keys[i-1]   := HBDetail.GetKey(i);
      Values[i-1] := HBDetail.GetValue(i);
   end;

   TxPLListener(xPLApplication).SendMessage(cmnd, Current_Config.Address.RawxPL, Schema_ConfigResp, Keys, Values );
end;

procedure TfrmConfigurator.acClearExecute(Sender: TObject);
begin
   while tvDevices.Items.Count > 0 do tvDevices.Items[0].Delete;
   node_discovered := tvDevices.Items.Add(nil,rsDiscovered);
   node_configdone := tvDevices.Items.Add(nil,rsConfigDone);
end;

procedure TfrmConfigurator.HBDetailEditingDone(Sender: TObject);
begin
   if lblRegExpr.Caption = '' then exit;
   with TRegExpr.Create do try
      Expression := lblRegExpr.Caption;
      lblError.Visible := not Exec( HBDetail.GetValue(HBDetail.Row));
   finally
      free;
   end;
   if lblError.Visible then lblError.Caption := 'Value error for : ' + HBDetail.GetKey(HBDetail.Row);
end;

procedure TfrmConfigurator.HBDetailSelection(Sender: TObject; aCol, aRow: Integer);
var i : integer;
begin
   memo1.lines.Clear;
   lblRegExpr.Caption := '';
   if not Current_Config.XMLCfgAvail then exit;
   for i := 0 to Current_Config.Plug_Detail.ConfigItems.Count-1 do
       if Current_Config.Plug_Detail.ConfigItems[i].Name = HBDetail.GetKey(aRow) then begin
          Memo1.Lines.Add(Current_Config.Plug_Detail.ConfigItems[i].Description);
          lblRegExpr.Caption := Current_Config.Plug_Detail.ConfigItems[i].Format;
       end;
end;

procedure TfrmConfigurator.lbDevicesClick(Sender: TObject);
var j : integer;
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

   HBDetail.Clear;
   HBDetail.PossibleKeys.Clear;
   HBDetail.Visible := True;
   lblError.Visible := false;

   HBDetail.Assign(Current_Config.Config.CurrentConfig);
   for j:=0 to Current_Config.Config.ConfigItems.Count-1 do
       if Current_Config.Config.ConfigItems[j].ItemMax > 1 then
          HBDetail.PossibleKeys.Add(Current_Config.Config.ConfigItems[j].DisplayName);
end;

initialization
  {$I frm_configurator.lrs}

end.

