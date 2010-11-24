unit frm_plugin_viewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Grids, u_xml_xplplugin, v_class_combo,
  v_msgbody_stringgrid, MStringGrid, MEdit, uxPLMsgBody;

type

  { TfrmPluginViewer }

  TfrmPluginViewer = class(TForm)
    btnNewNumeric: TButton;
    btnNewDropDown: TButton;
    btnNewTextbox: TButton;
    cbCommandClasse: TxPLClassCombo;
    cbCommandType: TMedit;
    cbType:    TComboBox;
    ckStatus: TCheckBox;
    ckListen: TCheckBox;
    ckTrigger: TCheckBox;
    ckCommand: TCheckBox;
    edtMenuItemName: TEdit;
    edtCommandName: TEdit;
    GroupBox1: TGroupBox;
    Label25:   TLabel;
    Label26:   TLabel;
    mgMenuItemBody: TBodyMessageGrid;
    cbSchemaClasse: TxPLClassCombo;
    cbMenuItemClasse: TxPLClassCombo;
    edtMaxVal: TEdit;
    edtMinVal: TEdit;
    edtDevicePlatform: TComboBox;
    edtDeviceType_: TComboBox;
    edtRegExp: TEdit;
    edtPluginVersion: TEdit;
    edtPluginURL: TEdit;
    edtPluginInfoURL: TEdit;
    edtCommandDescription: TEdit;
    edtComment: TEdit;
    edtDeviceBetaVersion: TEdit;
    edtDeviceDescription: TMemo;
    edtDeviceInfoURL: TEdit;
    edtDeviceDownloadURL: TEdit;
    edtDeviceStableVersion: TEdit;
    edtDeviceId: TEdit;
    cbSchemaType: TMedit;
    edtMenuItemType: TMedit;
    Label1:    TLabel;
    Label10:   TLabel;
    Label11:   TLabel;
    Label12:   TLabel;
    Label13:   TLabel;
    Label14:   TLabel;
    Label15:   TLabel;
    Label2:    TLabel;
    Label20:   TLabel;
    Label21:   TLabel;
    Label22:   TLabel;
    Label23:   TLabel;
    Label24:   TLabel;
    Label3:    TLabel;
    Label4:    TLabel;
    Label5:    TLabel;
    Label6:    TLabel;
    Label7:    TLabel;
    Label8:    TLabel;
    Label9:    TLabel;
    sgDropDown: TMStringGrid;
    Notebook:  TNotebook;
    pcCommand: TPageControl;
    pgEmpty:   TPage;
    pgPlugin:  TPage;
    pgDevice:  TPage;
    pgMenuItem: TPage;
    pgConfigItem: TPage;
    pgSchema:  TPage;
    pgCommand: TPage;
    sgConfigItems: TMStringGrid;
    sgCommandElements: TMStringGrid;
    Panel1:    TPanel;
    Splitter1: TSplitter;
    TabSheet1: TTabSheet;
    tbAdd:     TToolButton;
    tbDel1:    TToolButton;
    tbDel2:    TToolButton;
    ToolBar2:  TToolBar;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    tbDel:     TToolButton;
    ToolButton5: TToolButton;
    tsTextBox: TTabSheet;
    tsDropDownList: TTabSheet;
    tsNumeric: TTabSheet;
    tbLaunch:  TToolButton;
    tbLaunch1: TToolButton;
    tbSave:    TToolButton;
    ToolBar1:  TToolBar;
    ToolBar3:  TToolBar;
    ToolButton1: TToolButton;
    tvPlugin:  TTreeView;
    procedure btnNewDropDownClick(Sender: TObject);
    procedure btnNewNumericClick(Sender: TObject);
    procedure btnNewTextboxClick(Sender: TObject);
    procedure btnSaveDeviceClick(Sender: TObject);
    procedure edtDeviceIdEditingDone(Sender: TObject);
    procedure edtMaxValExit(Sender: TObject);
    procedure edtMinValExit(Sender: TObject);
    procedure edtRegExpExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure NotebookPageChanged(Sender: TObject);
    procedure sgCommandElementsSelectCell(Sender: TObject; aCol, aRow: integer;
      var CanSelect: boolean);
    procedure sgCommandElementsSelectEditor(Sender: TObject;
      aCol, aRow: integer; var Editor: TWinControl);
    procedure sgDropDownExit(Sender: TObject);
    procedure tbAddClick(Sender: TObject);
    procedure tbDel2Click(Sender: TObject);
    procedure tbDelClick(Sender: TObject);
    procedure tbLaunchClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure tvPluginSelectionChanged(Sender: TObject);
  private
    { private declarations }
    plugin:  TXMLxplpluginType;
    topNode: TTreeNode;
    aBody:   TxPLMsgBody;
  public
    { public declarations }
    filePath: string;
  end;

var
  frmPluginViewer: TfrmPluginViewer;

implementation { TfrmPluginViewer }

uses frm_About,
  frm_XMLView,
  u_xml_xplplugin_ex,
  u_xml,
  uxPLSchema,
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
var
  aNode: TTreeNode;
  i:     integer;
  aSchema: TxPLSchema;
  Elements: TXMLElementsType;
begin
  aNode := tvPlugin.Selected;
  NoteBook.ActivePageComponent := pgEmpty;

  tbAdd.Enabled := True;
  tbDel.Enabled := (aNode <> nil) and (aNode.Data <> nil) and (aNode <> TopNode);
  if aNode = nil then
    exit;
  if TObject(aNode.Data) is TXMLxplpluginType then
  begin
    NoteBook.ActivePageComponent := pgPlugin;
    edtPluginVersion.Text := TXMLxplpluginType(aNode.Data).Version;
    edtPluginURL.Text     := TXMLxplpluginType(aNode.Data).Plugin_URL;
    edtPluginInfoURL.Text := TXMLxplpluginType(aNode.Data).Info_URL;
  end;
  if aNode.Text = 'ConfigItems' then
  begin //(aNode.Data) is TXMLConfigItemsType then begin
    NoteBook.ActivePageComponent := pgConfigItem;
    sgConfigItems.RowCount := TXMLDeviceType(aNode.Parent.Data).ConfigItems.Count + 1;
    for i := 0 to TXMLDeviceType(aNode.Parent.Data).ConfigItems.Count - 1 do
    begin
      sgConfigItems.Cells[1, i + 1] :=
        TXMLDeviceType(aNode.Parent.Data).ConfigItems[i].Name;
      sgConfigItems.Cells[2, i + 1] :=
        TXMLDeviceType(aNode.Parent.Data).ConfigItems[i].Description;
      sgConfigItems.Cells[3, i + 1] :=
        TXMLDeviceType(aNode.Parent.Data).ConfigItems[i].Format;
    end;
    sgConfigItems.SetFocus;
  end;
  if TObject(aNode.Data) is TDOmElement then
  begin
    if TDOMElement(aNode.Data).NodeName = K_XML_STR_Device then
    begin
      tbAdd.Enabled    := False;
      NoteBook.ActivePageComponent := pgDevice;
      edtDeviceBetaVersion.Text := TXMLDeviceType(aNode.Data).beta_version;
      edtDeviceDescription.Text := TXMLDeviceType(aNode.Data).Description;
      edtDeviceInfoURL.Text := TXMLDeviceType(aNode.Data).info_url;
      edtDeviceDownloadURL.Text := TXMLDeviceType(aNode.Data).download_url;
      edtDevicePlatform.Text := TXMLDeviceType(aNode.Data).platform_;
      edtDeviceStableVersion.Text := TXMLDeviceType(aNode.Data).Version;
      edtDeviceType_.Text := TXMLDeviceType(aNode.Data).type_;
      edtDeviceId.Text := TXMLDeviceType(aNode.Data).Device;
      edtDeviceId.SetFocus;
    end;
    if TDOMElement(aNode.Data).NodeName = K_XML_STR_MenuItem then
    begin
      tbAdd.Enabled := False;
      NoteBook.ActivePageComponent := pgMenuItem;
      edtMenuItemName.Text := TXMLMenuItemTypeEx(aNode.Data).Name;
      aSchema := TXMLMenuItemTypeEx(aNode.Data).Schema;
      cbMenuItemClasse.Text := aSchema.Classe;
      edtMenuItemType.Text := aSchema.Type_;
      aSchema.Destroy;
      aBody := TXMLMenuItemTypeEx(aNode.Data).Body;
      mgMenuItemBody.Assign(aBody);
    end;
    if TDOMElement(aNode.Data).NodeName = K_XML_STR_Schema then
    begin
      tbAdd.Enabled := False;
      NoteBook.ActivePageComponent := pgSchema;
      aSchema := TXMLSchemaTypeEx(aNode.Data).Schema;
      cbSchemaClasse.Text := aSchema.Classe;
      cbSchemaType.Text := aSchema.Type_;
      aSchema.Destroy;
      ckCommand.Checked  := TXMLSchemaType(aNode.Data).command;
      ckStatus.Checked   := TXMLSchemaType(aNode.Data).status;
      ckListen.Checked   := TXMLSchemaType(aNode.Data).listen;
      ckTrigger.Checked  := TXMLSchemaType(aNode.Data).trigger;
      edtComment.Text := TXMLSchemaType(aNode.Data).comment;
    end;
    if ((TDOMElement(aNode.Data).NodeName = K_XML_STR_COMMAND) or
      (TDOMElement(aNode.Data).NodeName = K_XML_STR_TRIGGER)) then
    begin
      tbAdd.Enabled := False;
      NoteBook.ActivePageComponent := pgCommand;
      edtCommandName.Text := TXMLCommandType(aNode.Data).Name;
      edtCommandName.SetFocus;
      cbType.Text := TXMLCommandType(aNode.Data).msg_type;
      edtCommandDescription.Text := TXMLCommandType(aNode.Data).description;
      aSchema     := TXMLCommandTypeEx(aNode.Data).Schema;
      cbCommandClasse.Text := aSchema.Classe;
      cbCommandType.Text := aSchema.Type_;
      aSchema.Destroy;
      Elements := TXMLCommandType(aNode.Data).elements;
      sgCommandElements.Rowcount := 1;
      for i := 0 to Elements.Count - 1 do
      begin
        sgCommandElements.RowAppend(self);
        sgCommandElements.Cells[0, i + 1]   := Elements[i].Name;
        sgCommandElements.Cells[1, i + 1]   := Elements[i].label_;
        sgCommandElements.Cells[2, i + 1]   := Elements[i].control_type;
        sgCommandElements.Cells[3, i + 1]   := Elements[i].default_;
        sgCommandElements.Cells[4, i + 1]   := Elements[i].conditional_visibility;
        sgCommandElements.Objects[0, i + 1] := Elements[i];
      end;
    end;
  end;
end;


procedure TfrmPluginViewer.FormShow(Sender: TObject);
var
  DeviceNode: TTreeNode;
  commandsNode, configItemsNode, SchemasNode, TriggersNode, MenuItemsNode: TTreeNode;
  node: TTreeNode;
  i, j: integer;
begin
  tvPlugin.Items.Clear;
  Caption := FilePath;
  Notebook.ShowTabs := False;
  pcCommand.ShowTabs := False;
  tbAdd.Enabled := False;
  ToolBar3.Images := frmAbout.ilStandardActions;
  ToolBar1.Images := frmAbout.ilStandardActions;
  ToolBar2.Images := frmAbout.ilStandardActions;

  plugin := TXMLxplpluginType.Create(FilePath);
  if plugin.Valid then
  begin
    topNode      := tvPlugin.Items.AddChild(nil, plugin.vendor);
    topNode.Data := plugin;
    for i := 0 to plugin.Count - 1 do
    begin
      DeviceNode      := tvPlugin.Items.AddChild(topNode, plugin[i].id);
      DeviceNode.Data := plugin[i];
      CommandsNode    := tvPlugin.Items.AddChild(DeviceNode, 'Commands');
      SchemasNode     := tvPlugin.Items.AddChild(DeviceNode, 'Schemas');
      TriggersNode    := tvPlugin.Items.AddChild(DeviceNode, 'Triggers');
      MenuItemsNode   := tvPlugin.Items.AddChild(DeviceNode, 'MenuItems');
      configItemsNode := tvPlugin.Items.AddChild(DeviceNode, 'ConfigItems');
      configItemsNode.Data := plugin[i].ConfigItems;
      if plugin[i].Commands.Count > 0 then
        for j := 0 to plugin[i].Commands.Count - 1 do
        begin
          node      := tvPlugin.Items.AddChild(CommandsNode, plugin[i].Commands[j].Name);
          node.Data := plugin[i].Commands[j];
        end;

      if plugin[i].Schemas.Count > 0 then
        for j := 0 to plugin[i].Schemas.Count - 1 do
        begin
          node      := tvPlugin.Items.AddChild(SchemasNode, plugin[i].Schemas[j].Name);
          node.Data := plugin[i].Schemas[j];
        end;

      if plugin[i].Triggers.Count > 0 then
        for j := 0 to plugin[i].Triggers.Count - 1 do
        begin
          node      := tvPlugin.Items.AddChild(TriggersNode, plugin[i].Triggers[j].Name);
          node.Data := plugin[i].Triggers[j];
        end;

      if plugin[i].MenuItems.Count > 0 then
        for j := 0 to plugin[i].MenuItems.Count - 1 do
        begin
          node      := tvPlugin.Items.AddChild(MenuItemsNode, plugin[i].MenuItems[j].Name);
          node.Data := plugin[i].MenuItems[j];
        end;

    end;
    tvPlugin.Selected := topnode;

  end;
end;

procedure TfrmPluginViewer.NotebookPageChanged(Sender: TObject);
begin
  tbSave.Enabled := False;
end;

procedure TfrmPluginViewer.sgCommandElementsSelectCell(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);
var
  aNode: TTreeNode;
  i:     integer;
begin
  aNode := tvPlugin.Selected;
  if aNode = nil then  exit;
  if aNode.Data = nil then  exit;
  if TXMLCommandType(aNode.Data).Elements.Count = 0 then  exit;
  if sgCommandElements.Cells[2, aRow] = 'numeric' then begin
    pcCommand.ActivePageIndex := 2;
    edtMinVal.Text := TXMLCommandType(aNode.Data).elements[aRow - 1].Min_Val;
    edtMaxVal.Text := TXMLCommandType(aNode.Data).elements[aRow - 1].Max_Val;
  end
  else
  if sgCommandElements.Cells[2, aRow] = 'dropdownlist' then begin
    pcCommand.ActivePageIndex := 1;
    sgDropDown.RowCount := TXMLCommandType(aNode.Data).elements[aRow - 1].Options.Count + 1;
    for i := 0 to TXMLCommandType(aNode.Data).elements[aRow - 1].Options.Count - 1 do begin
      sgDropDown.Cells[0, i + 1] := TXMLCommandType(aNode.Data).elements[aRow - 1].Options[i].Value;
      sgDropDown.Cells[1, i + 1] := TXMLCommandType(aNode.Data).elements[aRow - 1].Options[i].Label_;
    end;
  end
  else
  if sgCommandElements.Cells[2, aRow] = 'textbox' then
  begin
    pcCommand.ActivePageIndex := 0;
    edtRegExp.Text := TXMLCommandType(aNode.Data).elements[aRow - 1].RegExp;
  end
  else
    pcCommand.ActivePageIndex := 3;
end;

procedure TfrmPluginViewer.sgCommandElementsSelectEditor(Sender: TObject; aCol, aRow: integer; var Editor: TWinControl);
begin
  if aCol = 2 then editor := nil;
end;

procedure TfrmPluginViewer.tbAddClick(Sender: TObject);
var
  i: integer;
  aNode, NewNode, ConfigNode: TTreeNode;
begin
  aNode := tvPlugin.Selected;
  if aNode = topNode then
  begin
    i := TXMLxplPluginType(aNode.Data).Count;
    NewNode := tvPlugin.Items.AddChild(aNode, '');
    NewNode.Data := TXMLxplPluginType(aNode.Data).AddElement(IntToStr(i));
    NewNode.Text := TXMLxplPluginType(aNode.Data)[i].Id;
    tvPlugin.Items.AddChild(NewNode, 'Commands');
    tvPlugin.Items.AddChild(NewNode, 'ConfigItems');
    tvPlugin.Items.AddChild(NewNode, 'Schemas');
    tvPlugin.Items.AddChild(NewNode, 'Triggers');
    ConfigNode      := tvPlugin.Items.AddChild(NewNode, 'MenuItems');
    ConfigNode.Data := TXMLxplPluginType(aNode.Data)[i].ConfigItems;
    exit;
  end;
  if aNode.Parent.Parent <> topNode then
    exit;                                  // We must be under the device level
  if (aNode.Text = 'MenuItems') then
  begin
    i := TXMLDeviceType(aNode.Parent.Data).MenuItems.Count;
    NewNode := tvPlugin.Items.AddChild(aNode, '');
    NewNode.Data := TXMLDeviceType(aNode.Parent.Data).MenuItems.AddElement(IntToStr(i));
    NewNode.Text := TXMLDeviceType(aNode.Parent.Data).MenuItems[i].Name;
  end;
  if (aNode.Text = 'ConfigItems') then
  begin
    sgCOnfigItems.RowAppend(self);
    NoteBook.ActivePageComponent := pgConfigItem;
    sgConfigItems.RowCount := TXMLDeviceType(aNode.Parent.Data).ConfigItems.Count + 2;
    sgConfigItems.SetFocus;
    exit;
  end;
  if (aNode.Text = 'Schemas') then
  begin
    NewNode      := tvPlugin.Items.AddChild(aNode, '');
    NewNode.Data := TXMLDeviceType(aNode.Parent.Data).Schemas.AddElement('shema.type');
    NewNode.Text := TXMLDeviceType(aNode.Parent.Data).Schemas[i].Name;
  end;
  if (aNode.Text = 'Commands') then
  begin
    NewNode := tvPlugin.Items.AddChild(aNode, '');
    i := TXMLDeviceType(aNode.Parent.Data).Commands.Count;
    NewNode.Data := TXMLDeviceType(aNode.Parent.Data).Commands.AddElement(IntToStr(i));
    NewNode.Text := TXMLDeviceType(aNode.Parent.Data).Commands[i].Name;
  end;
  if (aNode.Text = 'Triggers') then
  begin
    NewNode := tvPlugin.Items.AddChild(aNode, '');
    i := TXMLDeviceType(aNode.Parent.Data).Triggers.Count;
    NewNode.Data := TXMLDeviceType(aNode.Parent.Data).Triggers.AddElement(IntToStr(i));
    NewNode.Text := TXMLDeviceType(aNode.Parent.Data).Triggers[i].Name;
  end;
  Plugin.Save;
  tvPlugin.Selected := NewNode;
  NewNode.Expanded  := True;
end;

procedure TfrmPluginViewer.tbDel2Click(Sender: TObject);
var
  element: TXMLElementType;
begin
  element := TXMLElementType(sgCommandElements.Objects[0, sgCommandElements.Row]);
  TXMLCommandType(tvPlugin.Selected.Data).Elements.RootNode.RemoveChild(element);
  sgCommandElements.RowDelete(self);
end;

procedure TfrmPluginViewer.tbDelClick(Sender: TObject);
var
  aNode: TTreeNode;
begin
  aNode := tvPlugin.Selected;
  if TObject(aNode.Data) is TXMLConfigItemsType then
  begin
    sgConfigItems.RowDelete(self);
    exit;
  end;
  if TObject(aNode.Data) is TDOmElement then
  begin
    if TDOMElement(aNode.Data).NodeName = K_XML_STR_Device then
      TXMLxplPluginType(aNode.Parent.Data).RootNode.RemoveChild(TXMLDeviceType(aNode.Data))
    else
    if TDOMElement(aNode.Data).NodeName = K_XML_STR_MenuItem then
      TXMLDeviceType(aNode.Parent.Parent.Data).MenuItems.RootNode.RemoveChild(TXMLMenuItemType(aNode.Data))
    else
    if TDOMElement(aNode.Data).NodeName = K_XML_STR_Schema then
      TXMLDeviceType(aNode.Parent.Parent.Data).MenuItems.RootNodE.RemoveChild(TXMLSchemaType(aNode.Data))
    else
    if TDOMElement(aNode.Data).NodeName = K_XML_STR_Command then
      TXMLDeviceType(aNode.Parent.Parent.Data).Triggers.RootNode.RemoveChild(TXMLCommandType(aNode.Data))
    else
    if TDOMElement(aNode.Data).NodeName = K_XML_STR_Trigger then
      TXMLDeviceType(aNode.Parent.Parent.Data).Triggers.RootNode.RemoveChild(TXMLCommandType(aNode.Data));

    tvPlugin.Selected := aNode.Parent;
    tvPlugin.Items.Delete(aNode);
    Plugin.Save;
    tbDel.Enabled := False;
  end;
end;


procedure TfrmPluginViewer.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if assigned(plugin) then Plugin.Destroy;
end;

procedure TfrmPluginViewer.btnSaveDeviceClick(Sender: TObject);
var
  i: integer;
  configItem: TXMLConfigItemType;
  element: TXMLElementType;
begin
  if NoteBook.ActivePageComponent = pgDevice then
  begin
    TXMLDeviceType(tvPlugin.Selected.Data).Description := edtDeviceDescription.Text;
    TXMLDeviceType(tvPlugin.Selected.Data).download_url := edtDeviceDownloadURL.Text;
    TXMLDeviceType(tvPlugin.Selected.Data).Device := edtDeviceId.Text;
    TXMLDeviceType(tvPlugin.Selected.Data).info_url := edtDeviceInfoURL.Text;
    TXMLDeviceType(tvPlugin.Selected.Data).beta_version := edtDeviceBetaVersion.Text;
    TXMLDeviceType(tvPlugin.Selected.Data).platform_ := edtDevicePlatform.Text;
    TXMLDeviceType(tvPlugin.Selected.Data).Version := edtDeviceStableVersion.Text;
    TXMLDeviceType(tvPlugin.Selected.Data).type_ := edtDeviceType_.Text;
    TXMLDeviceType(tvPlugin.Selected.Data).device := edtDeviceId.Text;
    tvPlugin.Selected.Text := TXMLDeviceType(tvPlugin.Selected.Data).Id;
    // Reflect modification in treeview
  end;
  if NoteBook.ActivePageComponent = pgMenuItem then
  begin
    abody.ResetAll;
    mgMenuItemBody.CopyTo(aBody);
    TXMLMenuItemTypeEx(tvPlugin.Selected.Data).Set_Body(aBody.RawxPL);
    TXMLMenuItemTypeEx(tvPlugin.Selected.Data).Set_Schema(TxPLSchema.FormatRawxPL(cbMenuItemClasse.Text, edtMenuItemType.Text));
    TXMLMenuItemType(tvPlugin.Selected.Data).Name := edtMenuItemName.Text;
    aBody.Destroy;
    tvPlugin.Selected.Text := TXMLMenuItemType(tvPlugin.Selected.Data).Name;
  end;
  if NoteBook.ActivePageComponent = pgPlugin then
  begin
    TXMLxplpluginType(tvPlugin.Selected.Data).Version    := edtPluginVersion.Text;
    TXMLxplpluginType(tvPlugin.Selected.Data).Plugin_URL := edtPluginURL.Text;
    TXMLxplpluginType(tvPlugin.Selected.Data).Info_URL   := edtPluginInfoURL.Text;
  end;
  if NoteBook.ActivePageComponent = pgConfigItem then
  begin
    TXMLDeviceType(tvPlugin.Selected.Parent.Data).ConfigItems.EmptyList;
    for i := 1 to sgConfigItems.RowCount - 1 do
    begin
      configItem := TXMLDeviceType(tvPlugin.Selected.Parent.Data).ConfigItems.AddElement(sgConfigItems.Cells[1, i]);
      configItem.description := sgConfigItems.Cells[2, i];
      configItem.Format := sgConfigItems.Cells[3, i];
    end;
  end;
  if NoteBook.ActivePageComponent = pgSchema then
  begin
    TXMLSchemaType(tvPlugin.Selected.Data).command := ckCommand.Checked;
    TXMLSchemaType(tvPlugin.Selected.Data).comment := edtComment.Text;
    TXMLSchemaType(tvPlugin.Selected.Data).status := ckStatus.Checked;
    TXMLSchemaType(tvPlugin.Selected.Data).listen := ckListen.Checked;
    TXMLSchemaType(tvPlugin.Selected.Data).trigger := ckTrigger.Checked;
    TXMLSchemaType(tvPlugin.Selected.Data).Name := TxPLSchema.FormatRawxPL(cbSchemaClasse.Text, cbSchemaType.Text);
    tvPlugin.Selected.Text := TXMLSchemaType(tvPlugin.Selected.Data).Name;
  end;
  if NoteBook.ActivePageComponent = pgCommand then
  begin
    TXMLCommandType(tvPlugin.Selected.Data).Name     := edtCommandName.Text;
    TXMLCommandType(tvPlugin.Selected.Data).description := edtCommandDescription.Text;
    TXMLCommandType(tvPlugin.Selected.Data).msg_schema := TxPLSchema.FormatRawxPL(cbCommandClasse.Text, cbCommandType.Text);
    TXMLCommandType(tvPlugin.Selected.Data).msg_type := cbType.Text;
    for i := 1 to sgCommandElements.RowCount - 1 do
    begin
      element := TXMLElementType(sgCommandElements.Objects[0, i]);
      element.label_ := sgCommandElements.Cells[1, i];
      element.Control_type := sgCommandElements.Cells[2, i];
      element.default_ := sgCommandElements.Cells[3, i];
      element.conditional_visibility := sgCommandElements.Cells[4, i];
    end;
    tvPlugin.Selected.Text := TXMLCommandType(tvPlugin.Selected.Data).Name;
  end;
  if NoteBook.ActivePageComponent = pgCommand then
  begin
    TXMLCommandType(tvPlugin.Selected.Data).Name     := edtCommandName.Text;
    TXMLCommandType(tvPlugin.Selected.Data).description := edtCommandDescription.Text;
    TXMLCommandType(tvPlugin.Selected.Data).msg_schema := TxPLSchema.FormatRawxPL(cbCommandClasse.Text, cbCommandType.Text);
    TXMLCommandType(tvPlugin.Selected.Data).msg_type := cbType.Text;
    for i := 1 to sgCommandElements.RowCount - 1 do
    begin
      element := TXMLElementType(sgCommandElements.Objects[0, i]);
      element.name:= sgCommandElements.Cells[0,i];
      element.label_ := sgCommandElements.Cells[1, i];
      element.Control_type := sgCommandElements.Cells[2, i];
      element.default_ := sgCommandElements.Cells[3, i];
      element.conditional_visibility := sgCommandElements.Cells[4, i];
    end;
    tvPlugin.Selected.Text := TXMLCommandType(tvPlugin.Selected.Data).Name;
  end;
  Plugin.Save;
  tbSave.Enabled := False;
end;

procedure TfrmPluginViewer.btnNewNumericClick(Sender: TObject);
var
  i: integer;
  element: TXMLElementType;
begin
  sgCommandElements.RowAppend(self);
  i := sgCommandElements.RowCount - 1;
  element := TXMLCommandType(tvPlugin.Selected.Data).Elements.AddElement('Element_' + IntToStr(i));
  sgCommandElements.Cells[2, i] := 'numeric';
  sgCommandElements.Objects[0, i] := element;
  sgCommandElements.Cells[0, i] := element.Name;
end;

procedure TfrmPluginViewer.btnNewTextboxClick(Sender: TObject);
var
  i: integer;
  element: TXMLElementType;
begin
  sgCommandElements.RowAppend(self);
  i := sgCommandElements.RowCount - 1;
  element := TXMLCommandType(tvPlugin.Selected.Data).Elements.AddElement('Element_' + IntToStr(i));
  sgCommandElements.Cells[2, i] := 'textbox';
  sgCommandElements.Objects[0, i] := element;
  sgCommandElements.Cells[0, i] := element.Name;
  edtRegExp.Text := element.regexp;
end;

procedure TfrmPluginViewer.btnNewDropDownClick(Sender: TObject);
var
  i: integer;
  element: TXMLElementType;
begin
  sgCommandElements.RowAppend(self);
  i := sgCommandElements.RowCount - 1;
  element := TXMLCommandType(tvPlugin.Selected.Data).Elements.AddElement('Element_' + IntToStr(i));
  sgCommandElements.Cells[2, i] := 'dropdownlist';
  sgCommandElements.Objects[0, i] := element;
  sgCommandElements.Cells[0, i] := element.Name;
end;

procedure TfrmPluginViewer.edtDeviceIdEditingDone(Sender: TObject);
begin
  tbSave.Enabled := True;
end;

procedure TfrmPluginViewer.edtMaxValExit(Sender: TObject);
begin
  TXMLElementType(sgCommandElements.Objects[0, sgCommandElements.Row]).max_val := edtMaxVal.Text;
end;

procedure TfrmPluginViewer.edtMinValExit(Sender: TObject);
begin
  TXMLElementType(sgCommandElements.Objects[0, sgCommandElements.Row]).min_val := edtMinVal.Text;
end;

procedure TfrmPluginViewer.edtRegExpExit(Sender: TObject);
begin
  TXMLElementType(sgCommandElements.Objects[0, sgCommandElements.Row]).regexp :=  edtRegExp.Text;
end;

procedure TfrmPluginViewer.sgDropDownExit(Sender: TObject);
var
  element: TXMLElementType;
  i:      integer;
  option: TXMLOptionType;
begin
  element := TXMLElementType(sgCommandElements.Objects[0, sgCommandElements.Row]);
  element.Options.EmptyList;
  for i := 1 to sgDropDown.RowCount - 1 do begin
    option := element.Options.AddElement(sgDropDown.Cells[0, i]);
    option.label_ := sgDropDown.Cells[1, i];
  end;
end;

initialization
  {$I frm_plugin_viewer.lrs}

end.

