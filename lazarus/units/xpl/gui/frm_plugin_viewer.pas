unit frm_plugin_viewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Grids, u_xml_xplplugin,
  MStringGrid;

type

  { TfrmPluginViewer }

  TfrmPluginViewer = class(TForm)
    edtDevicePlatform: TComboBox;
    edtDeviceType_: TComboBox;
    edtPluginVersion: TEdit;
    edtPluginURL: TEdit;
    edtPluginInfoURL: TEdit;
    edtCommandDescription: TEdit;
    edtSchema: TEdit;
    edtCommand: TEdit;
    edtStatus: TEdit;
    edtListen: TEdit;
    edtTrigger: TEdit;
    edtComment: TEdit;
    edtDeviceBetaVersion: TEdit;
    edtDeviceDescription: TMemo;
    edtDeviceInfoURL: TEdit;
    edtDeviceDownloadURL: TEdit;
    edtDeviceStableVersion: TEdit;
    edtDeviceId: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    edtxPLMsg: TMemo;
    Notebook: TNotebook;
    pgEmpty: TPage;
    pgPlugin: TPage;
    pgDevice: TPage;
    pgMenuItem: TPage;
    pgConfigItem: TPage;
    pgSchema: TPage;
    pgCommand: TPage;
    sgConfigItems: TMStringGrid;
    sgCommandElements: TMStringGrid;
    Panel1: TPanel;
    Splitter1: TSplitter;
    tbLaunch: TToolButton;
    tbLaunch1: TToolButton;
    tbSave: TToolButton;
    ToolBar1: TToolBar;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    tvPlugin: TTreeView;
    procedure btnSaveDeviceClick(Sender: TObject);
    procedure edtDeviceIdEditingDone(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure NotebookPageChanged(Sender: TObject);
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
     u_xml,
     DOM;

procedure TfrmPluginViewer.tbLaunchClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmPluginViewer.ToolButton1Click(Sender: TObject);
begin
   frmXMLView.FilePath := FilePath;
   frmXMLView.ShowModal;
end;

procedure TfrmPluginViewer.tvPluginSelectionChanged(Sender: TObject);
var aNode : TTreeNode;
    i : integer;
begin
   aNode := tvPlugin.Selected;
   NoteBook.ActivePageComponent := pgEmpty;
   if aNode = nil then exit;
     if TObject(aNode.Data) is TXMLxplpluginType then begin
        NoteBook.ActivePageComponent := pgPlugin;
        edtPluginVersion.Text := TXMLxplpluginType(aNode.Data).Version;
        edtPluginURL.Text     := TXMLxplpluginType(aNode.Data).Plugin_URL;
        edtPluginInfoURL.Text := TXMLxplpluginType(aNode.Data).Info_URL
     end;
     if TObject(aNode.Data) is TXMLConfigItemsType then begin
        NoteBook.ActivePageComponent := pgConfigItem;
        sgConfigItems.RowCount:=TXMLConfigItemsType(aNode.Data).Count +1;
         for i := 0 to TXMLConfigItemsType(aNode.Data).Count-1 do begin
             sgConfigItems.Cells[1,i+1] := TXMLConfigItemsType(aNode.Data)[i].Name;
             sgConfigItems.Cells[2,i+1] := TXMLConfigItemsType(aNode.Data)[i].Description;
             sgConfigItems.Cells[3,i+1] := TXMLConfigItemsType(aNode.Data)[i].Format;
         end;
     end;
     if TObject(aNode.Data) is TDOmElement then begin
        if TDOMElement(aNode.Data).NodeName = K_XML_STR_Device then begin
         NoteBook.ActivePageComponent := pgDevice;
         edtDeviceBetaVersion.Text := TXMLDeviceType(aNode.Data).beta_version;
         edtDeviceDescription.Text := TXMLDeviceType(aNode.Data).Description;
         edtDeviceInfoURL.Text     := TXMLDeviceType(aNode.Data).info_url;
         edtDeviceDownloadURL.Text := TXMLDeviceType(aNode.Data).download_url;
         edtDevicePlatform.Text    := TXMLDeviceType(aNode.Data).platform_;
         edtDeviceStableVersion.Text := TXMLDeviceType(aNode.Data).Version;
         edtDeviceType_.Text         := TXMLDeviceType(aNode.Data).type_;
         edtDeviceId.Text            := TXMLDeviceType(aNode.Data).Device;
        end;
        if TDOMElement(aNode.Data).NodeName = K_XML_STR_MenuItem then begin
         NoteBook.ActivePageComponent := pgMenuItem;
         edtxPLMsg.Lines.Clear;
         edtxPLMsg.Lines.Delimiter:=#13;
         edtxPLMsg.Lines.DelimitedText := ( TXMLMenuItemType(aNode.Data).xPLMsg);
        end;
        if TDOMElement(aNode.Data).NodeName = K_XML_STR_Schema then begin
         NoteBook.ActivePageComponent := pgSchema;
         edtCommand.Text := TXMLSchemaType(aNode.Data).command;
         edtStatus.Text  := TXMLSchemaType(aNode.Data).status;
         edtListen.Text  := TXMLSchemaType(aNode.Data).listen;
         edtTrigger.Text := TXMLSchemaType(aNode.Data).trigger;
         edtComment.Text := TXMLSchemaType(aNode.Data).comment;
        end;
        if TDOMElement(aNode.Data).NodeName = K_XML_STR_COMMAND then begin
         NoteBook.ActivePageComponent := pgCommand;
         edtCommandDescription.Text := TXMLCommandType(aNode.Data).description;
         edtSchema.Text  := TXMLCommandType(aNode.Data).msg_schema;
         sgCommandElements.RowCount:=TXMLCommandType(aNode.Data).elements.Count +1;
         for i := 0 to TXMLCommandType(aNode.Data).elements.Count-1 do begin
             sgCommandElements.Cells[0,i+1] := TXMLCommandType(aNode.Data).elements[i].Name;
             sgCommandElements.Cells[1,i+1] := TXMLCommandType(aNode.Data).elements[i].label_;
             sgCommandElements.Cells[2,i+1] := TXMLCommandType(aNode.Data).elements[i].control_type;
             sgCommandElements.Cells[3,i+1] := TXMLCommandType(aNode.Data).elements[i].default_;
             sgCommandElements.Cells[4,i+1] := TXMLCommandType(aNode.Data).elements[i].conditional_visibility;
         end;
        end;
        if TDOMElement(aNode.Data).NodeName = K_XML_STR_TRIGGER then begin
         NoteBook.ActivePageComponent := pgCommand;
         edtCommandDescription.Text := TXMLTriggerType(aNode.Data).description;
         edtSchema.Text  := TXMLTriggerType(aNode.Data).msg_schema;
         sgCommandElements.RowCount:=TXMLTriggerType(aNode.Data).elements.Count +1;
         for i := 0 to TXMLTriggerType(aNode.Data).elements.Count-1 do begin
             sgCommandElements.Cells[0,i+1] := TXMLTriggerType(aNode.Data).elements[i].Name;
             sgCommandElements.Cells[1,i+1] := TXMLTriggerType(aNode.Data).elements[i].label_;
             sgCommandElements.Cells[2,i+1] := TXMLTriggerType(aNode.Data).elements[i].control_type;
             sgCommandElements.Cells[3,i+1] := TXMLTriggerType(aNode.Data).elements[i].default_;
             sgCommandElements.Cells[4,i+1] := TXMLTriggerType(aNode.Data).elements[i].conditional_visibility;
         end;
        end;
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
   Notebook.ShowTabs:=False;
   ToolBar3.Images := frmAbout.ilStandardActions;
   ToolBar1.Images := frmAbout.ilStandardActions;

   plugin := TXMLxplpluginType.Create(FilePath);
   topNode := tvPlugin.Items.AddChild(nil,plugin.vendor);
   topNode.Data:=plugin;
   for i:=0 to plugin.count-1 do begin
       DeviceNode := tvPlugin.Items.AddChild(topNode, plugin[i].id);
       DeviceNode.Data := plugin[i];
       if plugin[i].Commands.Count > 0 then begin
          CommandsNode := tvPlugin.Items.AddChild(DeviceNode, 'Commands');
          for j:=0 to plugin[i].Commands.Count-1 do begin
             node := tvPlugin.Items.AddChild(CommandsNode,plugin[i].Commands[j].Name);
             node.Data := plugin[i].Commands[j];
          end;
       end;
       if plugin[i].ConfigItems.Count > 0 then begin
          configItemsNode := tvPlugin.Items.AddChild(DeviceNode, 'ConfigItems');
          configItemsNode.Data := plugin[i].ConfigItems;
       end;
       if plugin[i].Schemas.Count > 0 then begin
          SchemasNode := tvPlugin.Items.AddChild(DeviceNode, 'Schemas');
          for j:=0 to plugin[i].Schemas.Count-1 do begin
             node := tvPlugin.Items.AddChild(SchemasNode,plugin[i].Schemas[j].Name);
             node.Data := plugin[i].Schemas[j];
          end;
       end;
       if plugin[i].Triggers.Count > 0 then begin
          TriggersNode := tvPlugin.Items.AddChild(DeviceNode, 'Triggers');
          for j:=0 to plugin[i].Triggers.Count-1 do begin
             node := tvPlugin.Items.AddChild(TriggersNode,plugin[i].Triggers[j].Name);
             node.Data := plugin[i].Triggers[j];
          end;
       end;
       if plugin[i].MenuItems.Count > 0 then begin
          MenuItemsNode := tvPlugin.Items.AddChild(DeviceNode, 'MenuItems');
          for j:=0 to plugin[i].MenuItems.Count-1 do begin
             node := tvPlugin.Items.AddChild(MenuItemsNode,plugin[i].MenuItems[j].Name);
             node.Data := plugin[i].MenuItems[j];
          end;
       end;
   end;
   tvPlugin.Selected:=topnode;
end;

procedure TfrmPluginViewer.NotebookPageChanged(Sender: TObject);
begin
  tbSave.Enabled := False;
end;


procedure TfrmPluginViewer.FormClose(Sender: TObject;  var CloseAction: TCloseAction);
begin
   Plugin.Destroy;
end;

procedure TfrmPluginViewer.btnSaveDeviceClick(Sender: TObject);
var i : integer;
    configItem : TXMLConfigItemType;
begin
   if NoteBook.ActivePageComponent = pgDevice then begin
      TXMLDeviceType(tvPlugin.Selected.Data).Description := edtDeviceDescription.Text;
      TXMLDeviceType(tvPlugin.Selected.Data).download_url := edtDeviceDownloadURL.Text;
      TXMLDeviceType(tvPlugin.Selected.Data).Device := edtDeviceId.Text;
      TXMLDeviceType(tvPlugin.Selected.Data).info_url := edtDeviceInfoURL.Text;
      TXMLDeviceType(tvPlugin.Selected.Data).beta_version := edtDeviceBetaVersion.Text;
      TXMLDeviceType(tvPlugin.Selected.Data).platform_ := edtDevicePlatform.Text;
      TXMLDeviceType(tvPlugin.Selected.Data).Version := edtDeviceStableVersion.Text;
      TXMLDeviceType(tvPlugin.Selected.Data).type_ := edtDeviceType_.Text;
   end;
   if NoteBook.ActivePageComponent = pgMenuItem then begin
      TXMLMenuItemType(tvPlugin.Selected.Data).xPLMsg := edtxPLMsg.Lines.DelimitedText;
   end;
   if NoteBook.ActivePageComponent = pgPlugin then begin
        TXMLxplpluginType(tvPlugin.Selected.Data).Version:= edtPluginVersion.Text;
        TXMLxplpluginType(tvPlugin.Selected.Data).Plugin_URL := edtPluginURL.Text;
        TXMLxplpluginType(tvPlugin.Selected.Data).Info_URL := edtPluginInfoURL.Text;
   end;
   if NoteBook.ActivePageComponent = pgConfigItem then begin
      TXMLConfigItemsType(tvPlugin.Selected.Data).EmptyList;
         for i := 1 to sgConfigItems.RowCount-1 do begin
            configItem := TXMLConfigItemsType(tvPlugin.Selected.Data).AddElement(sgConfigItems.Cells[1,i]);
            configItem.description := sgConfigItems.Cells[2,i];
            configItem.Format      := sgConfigItems.Cells[3,i];
         end;
   end;
   if NoteBook.ActivePageComponent = pgSchema then begin
      TXMLSchemaType(tvPlugin.Selected.Data).command := edtCommand.Text;
      TXMLSchemaType(tvPlugin.Selected.Data).status  := edtStatus.Text ;
      TXMLSchemaType(tvPlugin.Selected.Data).listen  := edtListen.Text ;
      TXMLSchemaType(tvPlugin.Selected.Data).trigger := edtTrigger.Text;
      TXMLSchemaType(tvPlugin.Selected.Data).comment := edtComment.Text;
   end;
   Plugin.Save;
   tbSave.Enabled:=False;
end;

procedure TfrmPluginViewer.edtDeviceIdEditingDone(Sender: TObject);
begin
  tbSave.Enabled:=true;
end;

initialization
  {$I frm_plugin_viewer.lrs}

end.

