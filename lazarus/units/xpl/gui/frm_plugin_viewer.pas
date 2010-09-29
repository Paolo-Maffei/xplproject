unit frm_plugin_viewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls,u_xml_xplplugin;

type

  { TfrmPluginViewer }

  TfrmPluginViewer = class(TForm)
    edtDeviceBetaVersion: TEdit;
    edtDeviceDescription: TMemo;
    edtDeviceInfoURL: TEdit;
    edtDeviceDownloadURL: TEdit;
    edtDevicePlatform: TEdit;
    edtDeviceStableVersion: TEdit;
    edtDeviceType_: TEdit;
    edtDeviceId: TEdit;
    edtPluginVendor: TEdit;
    edtPluginVersion: TEdit;
    edtPluginURL: TEdit;
    edtPluginInfoURL: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Splitter1: TSplitter;
    TabSheet1: TTabSheet;
    tsPlugin: TTabSheet;
    tsDevice: TTabSheet;
    tbLaunch: TToolButton;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    tvPlugin: TTreeView;
    procedure FormShow(Sender: TObject);
    procedure tbLaunchClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure tvPluginSelectionChanged(Sender: TObject);
  private
    { private declarations }
    plugin : TXMLxplpluginType;
  public
    { public declarations }
    filePath : string;
  end; 

var
  frmPluginViewer: TfrmPluginViewer;

implementation { TfrmPluginViewer }
uses frm_About,
     frm_XMLView,
     DOM;

procedure TfrmPluginViewer.tbLaunchClick(Sender: TObject);
begin
   Plugin.Destroy;
   Close;
end;

procedure TfrmPluginViewer.ToolButton1Click(Sender: TObject);
begin
   frmXMLView.FilePath := FilePath;
   frmXMLView.ShowModal;
end;

procedure TfrmPluginViewer.tvPluginSelectionChanged(Sender: TObject);
var aNode : TTreeNode;
begin
     aNode := tvPlugin.Selected;
     if TObject(aNode.Data) is TXMLxplpluginType then begin
        PageControl1.ActivePage := tsPlugin;
        edtPluginVendor.Text  := TXMLxplpluginType(aNode.Data).Vendor;
        edtPluginVersion.Text := TXMLxplpluginType(aNode.Data).Version;
        edtPluginURL.Text     := TXMLxplpluginType(aNode.Data).Plugin_URL;
        edtPluginInfoURL.Text := TXMLxplpluginType(aNode.Data).Info_URL
     end;
     if TObject(aNode.Data) is TDOmElement then begin
         PageControl1.ActivePage := tsDevice;
         edtDeviceBetaVersion.Text := TXMLDeviceType(aNode.Data).beta_version;
         edtDeviceDescription.Text := TXMLDeviceType(aNode.Data).Description;
         edtDeviceInfoURL.Text     := TXMLDeviceType(aNode.Data).info_url;
         edtDeviceDownloadURL.Text := TXMLDeviceType(aNode.Data).download_url;
         edtDevicePlatform.Text    := TXMLDeviceType(aNode.Data).platform_;
         edtDeviceStableVersion.Text := TXMLDeviceType(aNode.Data).Version;
         edtDeviceType_.Text         := TXMLDeviceType(aNode.Data).type_;
         edtDeviceId.Text            := TXMLDeviceType(aNode.Data).id;

     end;
end;

procedure TfrmPluginViewer.FormShow(Sender: TObject);
var topNode : TTreeNode;
    DeviceNode : TTreeNode;
    commandsNode, configItemsNode,SchemasNode,TriggersNode,MenuItemsNode : TTreeNode;
    node : TTreeNode;
    i,j : integer;
begin
   tvPlugin.Items.Clear;
   Caption := FilePath;
   ToolBar3.Images := frmAbout.ilStandardActions;
   plugin := TXMLxplpluginType.Create(FilePath);
   topNode := tvPlugin.Items.AddChild(nil,plugin.vendor);
   topNode.Data:=plugin;
   for i:=0 to plugin.count-1 do begin
       DeviceNode := tvPlugin.Items.AddChild(topNode, plugin[i].id);
       DeviceNode.Data := plugin[i];
       if plugin[i].Commands.Count > 0 then begin
          CommandsNode := tvPlugin.Items.AddChild(DeviceNode, 'Commands');
          for j:=0 to plugin[i].Commands.Count-1 do begin
             tvPlugin.Items.AddChild(CommandsNode,plugin[i].Commands[j].Name);
          end;
       end;
       if plugin[i].ConfigItems.Count > 0 then begin
          configItemsNode := tvPlugin.Items.AddChild(DeviceNode, 'ConfigItems');
          for j:=0 to plugin[i].ConfigItems.Count-1 do begin
             tvPlugin.Items.AddChild(configItemsNode,plugin[i].ConfigItems[j].Name);
          end;
       end;
       if plugin[i].Schemas.Count > 0 then begin
          SchemasNode := tvPlugin.Items.AddChild(DeviceNode, 'Schemas');
          for j:=0 to plugin[i].Schemas.Count-1 do begin
             tvPlugin.Items.AddChild(SchemasNode,plugin[i].Schemas[j].Name);
          end;
       end;
       if plugin[i].Triggers.Count > 0 then begin
          TriggersNode := tvPlugin.Items.AddChild(DeviceNode, 'Triggers');
          for j:=0 to plugin[i].Triggers.Count-1 do begin
             tvPlugin.Items.AddChild(TriggersNode,plugin[i].Triggers[j].Name);
          end;
       end;
       if plugin[i].MenuItems.Count > 0 then begin
          MenuItemsNode := tvPlugin.Items.AddChild(DeviceNode, 'MenuItems');
          for j:=0 to plugin[i].MenuItems.Count-1 do begin
             tvPlugin.Items.AddChild(MenuItemsNode,plugin[i].MenuItems[j].Name);
          end;
       end;
   end;
end;

initialization
  {$I frm_plugin_viewer.lrs}

end.

