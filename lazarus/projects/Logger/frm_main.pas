unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ActnList, Menus, ComCtrls, Grids, StdCtrls, Buttons, frm_About, uxPLConfig,
  uxPLMessage, uxPLPluginFile,uxPLListener, ExtCtrls,MCheckListBox, XMLPropStorage, uxPLConst;

type

  { TFrmMain }

  { TLoggerListener }

  TFrmMain = class(TForm)
    About: TAction;
    acAppSettings: TAction;
    acDiscover: TAction;
    acRequestConfig: TAction;
    acSetupInstance: TAction;
    acNetworkSettings: TAction;
    acLogging: TAction;
    acPluginDetail: TAction;
    acVendorPlugins: TAction;
    ckConfigList: TCheckBox;
    ckCurrentConf: TCheckBox;
    ClasseImages: TImageList;
    Memo1: TMemo;
    MenuItem10: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    mnuCommands: TMenuItem;
    mnuConfigurations: TMenuItem;
    mnuSendMessage: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    TypeImages: TImageList;
    clbType: TMCheckListBox;
    clbSchema: TMCheckListBox;
    lvMessages: TListView;
    ActionList1: TActionList;
    BtnRefresh: TBitBtn;
    Clear: TAction;
    Filter: TAction;
    Label2: TLabel;
    Label3: TLabel;
    Load: TAction;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    PageControl1: TPageControl;
    Pause: TAction;
    Play: TAction;
    Quit: TAction;
    Export: TAction;
    SaveDialog: TSaveDialog;
    sgStats: TStringGrid;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    tvMessages: TTreeView;
    XMLPropStorage1: TXMLPropStorage;
    procedure AboutExecute(Sender: TObject);
//    procedure acAppLauncherExecute(Sender: TObject);
    procedure acAppSettingsExecute(Sender: TObject);
    procedure acDiscoverExecute(Sender: TObject);
    procedure acLoggingExecute(Sender: TObject);
    procedure acNetworkSettingsExecute(Sender: TObject);
    procedure acPluginDetailExecute(Sender: TObject);
    procedure acRequestConfigExecute(Sender: TObject);
    procedure acSetupInstanceExecute(Sender: TObject);
    procedure acVendorPluginsExecute(Sender: TObject);
    procedure ClearExecute(Sender: TObject);
    function CheckFilter(aMsg : TxPLMessage): boolean;
    procedure ExportExecute(Sender: TObject);
    procedure FilterExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvMessagesColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvMessagesDblClick(Sender: TObject);
    procedure lvMessagesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure mnuSendMessageClick(Sender: TObject);
    procedure mnuCommandClick(Sender: TObject);
    procedure PauseExecute(Sender: TObject);
    procedure PlayExecute(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure tvMessagesChange(Sender: TObject; Node: TTreeNode);
    procedure tvMessagesSelectionChanged(Sender: TObject);
  private
    topNode : TTreeNode;
    CurrentTreeFilter : string;

    LastSortedColumn: integer;
    Ascending: boolean;

    bConfirmExit : boolean;

    iReceivedMsg : integer;
    iLoggedMsg : integer;
    dtLogStart : TDateTime;

    Messages : TStringList;

    procedure OnMessageReceived(const axPLMessage : TxPLMessage);
    function StatusString : string;
    procedure GetSourceChain(var c1 : string; var c2 : string; var c3 : string);
    function  GetSourceAddress : string;
    procedure AddToTreeview(aMessageNum : integer);
  public
     xPLClient : TxPLListener;
  end;

  TConfigurationRecord = class
     plug_config : TxPLConfig;
     plug_detail : TxPLDevice;
     config_current: string;
     config_list   : string;
     Device        : tsDevice;
     Vendor        : tsVendor;
     Instance      : tsInstance;
  end;


var
  FrmMain: TFrmMain;

implementation { TFrmLogger =====================================================}
uses frm_xplappslauncher, frm_AppSettings, cDateTime,  StrUtils, frm_xpllogviewer,
     uxPLAddress, uxplMsgHeader,  frm_PluginDetail,
     cRandom, LCLType, ClipBrd, uxPLFilter, cutils, cStrings, frm_SetupInstance,
     frm_networksettings, frm_vendorplugins;

// ===============================================================================
resourcestring
     K_XPL_APP_VERSION_NUMBER = '2.0';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'logger';

// ===============================================================================
procedure TFrmMain.FormCreate(Sender: TObject);
var i : TxPLMessageType;
    k : integer;
begin
  saveDialog.Filter := 'txt file|*.txt';
  saveDialog.DefaultExt := 'txt';
  saveDialog.FilterIndex := 1;

  bConfirmExit := True;

  xPLClient := TxPLListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE, K_XPL_APP_VERSION_NUMBER);
  xPLClient.OnxPLReceived  := @OnMessageReceived;
  xPLClient.PassMyOwnMessages := True;
  Self.Caption := xPLClient.AppName;

  for i:= xpl_mtTrig to xpl_mtCmnd do                                         // There's no descriptor for mtNone
     clbType.Items.Add(TxPLMsgHeader.MsgType2String(i));

  for k := Low(K_XPL_CLASS_DESCRIPTORS) to High(K_XPL_CLASS_DESCRIPTORS) do
     clbSchema.Items.Add(K_XPL_CLASS_DESCRIPTORS[k]);

  Messages := TStringList.Create;

  ClearExecute(self);

  PageControl1.PageIndex := 0;
  LastSortedColumn := -1;
  Ascending := True;

  clbType.SetCheckedAll(self);
  clbSchema.SetCheckedAll(self);

  topNode := tvMessages.Items.AddChild(nil,'xPL Network');
  tvMessages.Selected := topNode;

  xPLClient.Listen;
  xPLClient.AwaitingConfiguration := false;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  xPLClient.destroy;
  Messages.Destroy;
end;

procedure TFrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TFrmMain.acLoggingExecute(Sender: TObject);
begin frmLogViewer.Showmodal; end;

procedure TFrmMain.acNetworkSettingsExecute(Sender: TObject);
begin frmNetworkSettings.ShowModal; end;

procedure TFrmMain.acVendorPluginsExecute(Sender: TObject);
begin frmVendorPlugins.ShowModal; end;

procedure TFrmMain.FilterExecute(Sender: TObject);
begin { Nothing to do but the function must be present } end;

//procedure TFrmMain.acAppLauncherExecute(Sender: TObject);
//begin frmAppLauncher.Show; end;

procedure TFrmMain.acAppSettingsExecute(Sender: TObject);
var i : integer;
begin
   frmAppSettings.ShowModal;
   if frmAppSettings.ckIcons.Checked then lvMessages.SmallImages := ClasseImages
                                     else lvMessages.SmallImages := TypeImages;
   for i:=0 to lvMessages.Columns.Count-1 do
       lvMessages.Column[i].Caption := frmAppSettings.ListBox1.Items[i];
   Memo1.Visible := frmAppSettings.ckShowPreview.Checked;
   tvMessagesSelectionChanged(Sender);
end;

procedure TFrmMain.acDiscoverExecute(Sender: TObject);
begin
   xPLClient.SendMessage(xpl_mtCmnd,K_MSG_TARGET_ANY,K_SCHEMA_HBEAT_REQUEST+#10'{'#10'command=request'#10'}'#10);
end;

procedure TFrmMain.acRequestConfigExecute(Sender: TObject);
begin
   xPLClient.SendMessage(xpl_mtCmnd,GetSourceAddress,K_SCHEMA_CONFIG_LIST+#10'{'#10'command=request'#10'}'#10);
   xPLClient.SendMessage(xpl_mtCmnd,GetSourceAddress,K_SCHEMA_CONFIG_CURRENT+#10'{'#10'command=request'#10'}'#10);
end;

procedure TFrmMain.acPluginDetailExecute(Sender: TObject);
var ConfElmts : TConfigurationRecord;
begin
     ConfElmts := TConfigurationRecord(tvMessages.Selected.Data);
     if ConfElmts=nil then exit;
     frmPluginDetail.Configuration := ConfElmts;
     frmPluginDetail.ShowModal;
end;

procedure TFrmMain.ClearExecute(Sender: TObject);
begin
     iLoggedMsg := 0;
     iReceivedMsg := 0;
     lvMessages.Items.Clear ;
     PlayExecute(self);
     Messages.Clear;
end;

function TFrmMain.CheckFilter(aMsg : TxPLMessage): boolean;
var i, elt : integer;
    ch : string;
begin
     result := true;
     for i:=0 to clbSchema.Items.Count-1 do begin
         ch := aMsg.Schema.ClasseAsString;
         elt := clbSchema.Items.IndexOf(ch);
         if elt<>-1 then result := result and clbSchema.Checked[elt];
     end;
     for i:=0 to clbType.Items.Count-1 do begin
         ch := aMsg.Header.MessageTypeAsString;
         elt := clbSchema.Items.IndexOf(ch);
         if elt<>-1 then result := result and clbType.Checked[elt];
     end;
end;

procedure TFrmMain.ExportExecute(Sender: TObject);
const CHAR_SEP = ';';
var i, j:Integer;
    Str:String;
begin
     if not SaveDialog.Execute then exit;

     Str := '';

     for i := 0 to lvMessages.Items.Count-1 do begin
         if (i <> 0) then Str += #13#10;
         for j := 0 to (lvMessages.Items[i].SubItems.Count-2) do
             Str += lvMessages.Items[i].SubItems[j] + Char_SEP;
     end;

     with TStringList.Create do try
        Add(Str);
        SaveToFile(SaveDialog.FileName);
     finally
        Free;
     end;
end;

procedure TFrmMain.lvMessagesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var j :integer;
    aMsg : TxPLMessage;
    arrStr : StringArray;
begin
  aMsg := TxPLMessage(Messages.Objects[ StrToInt(Item.SubItems[4]) ]);

  memo1.Lines.Clear;
  arrStr := StrSplit(aMsg.RawXPL,#10);

   for j:=0 to high(arrStr) do
       if arrStr[j]<>'' then memo1.Lines.Add(arrStr[j]);
end;


procedure TFrmMain.mnuSendMessageClick(Sender: TObject);
var aMessage : txPLMessage;
begin
     aMessage := TxPLMessage.Create ;
     aMessage.Header.Source := xPLClient.Address;
     aMessage.Header.Target.Tag := GetSourceAddress;
     aMessage.ShowForEdit([boSave,boSend]) ;                                              // Potential issue here : aMessage not destroyed
end;

procedure TFrmMain.lvMessagesColumnClick(Sender: TObject; Column: TListColumn);
var sl:TstringList; //used for sorting
    counter,target,
    SubItemsColumnCount,
    IndexOfCurrentColumn:integer;
begin
    if Column.Index = LastSortedColumn then
      Ascending := not Ascending
    else
      LastSortedColumn := Column.Index;

 sl := TStringList.Create;
 try
   IndexOfCurrentColumn:= column.index;

   if IndexOfCurrentColumn = 0 then begin
     for counter := 0  to lvMessages.items.count -1 do begin
       sl. AddObject(lvMessages.Items[counter].Caption,lvMessages.items[counter]);
     end;
   end
   else begin
     for counter := 0  to lvMessages.items.count -1 do begin
       SubItemsColumnCount:= lvMessages.items[counter].subitems.Count;

       if (SubItemsColumnCount >= IndexOfCurrentColumn) then
          sl.AddObject(lvMessages.items[counter].SubItems[IndexOfCurrentColumn-1],lvMessages.items[counter])
       else
          sl.AddObject('',lvMessages.items[counter]);
     end;
   end;

   sl.sort;

   for counter := 0  to lvMessages.items.count -1 do begin
       if not Ascending then Target := lvMessages.items.count - 1 - counter
                        else Target := counter;
     lvMessages.items[target] := TListItem(sl. Objects[counter]);
   end;

 finally
   sl.free;
 end;
end;

procedure TFrmMain.lvMessagesDblClick(Sender: TObject);
var i :integer;
begin
   if not assigned(lvMessages.Selected) then exit;

   i := StrToInt( lvMessages.Selected.SubItems[4]);
   with TxPLMessage(Messages.Objects[i]) do Show([boSave,boCopy,boSend]);
end;

procedure TFrmMain.PauseExecute(Sender: TObject);
begin
  Pause.Enabled := False;
  Play.Enabled  := not Pause.Enabled;
end;

procedure TFrmMain.PlayExecute(Sender: TObject);
begin
  Pause.Enabled := True;
  Play.Enabled  := not Pause.Enabled;
  dtLogStart := now;
  iLoggedMsg := 0;
end;

procedure TFrmMain.QuitExecute(Sender: TObject);
begin
  if (not bConfirmExit) or
     (Application.MessageBox('Do you want to quit ?','Confirm',MB_YESNO) = IDYES)
  then Close;
end;

procedure TFrmMain.acSetupInstanceExecute(Sender: TObject);
var ConfElmts : TConfigurationRecord;
begin
     ConfElmts := TConfigurationRecord(tvMessages.Selected.Data);
     if ConfElmts=nil then exit;
     frmSetupInstance.Configuration := ConfElmts;
     frmSetupInstance.ShowModal;
end;

procedure TFrmMain.tvMessagesChange(Sender: TObject; Node: TTreeNode);
var ConfElmts : TConfigurationRecord;
    i : integer;
    aMenu : tmenuitem;
begin
   acRequestConfig.Visible := (Node.Data<>nil);
   if acRequestConfig.Visible then begin
      ConfElmts := TConfigurationRecord(Node.Data);
      acPluginDetail.Visible := (ConfElmts.Plug_Config<>nil);
      ckConfigList.Checked := length(ConfElmts.config_list)>0;
      ckCurrentConf.Checked := length(ConfElmts.config_current)>0;
   end else begin
      acPluginDetail.Visible := false;
      ckConfigList.Checked := false;
      ckCurrentConf.Checked := false;
   end;
   acSetupInstance.Visible := ckConfigList.Checked or acPluginDetail.Visible;
   mnuCommands.Visible := acSetupInstance.Visible;
   if ConfElmts.plug_detail<>nil then begin
      mnuCommands.Clear;
      for i := 0 to ConfElmts.plug_detail.Commands.Count-1 do begin
          aMenu := TMenuItem.Create(self);
          aMenu.Caption := ConfElmts.plug_detail.Commands[i];
          aMenu.OnClick := @mnuCommandClick;
          mnuCommands.Add(aMenu);
      end;
      mnuCommands.Enabled := (mnuCommands.Count > 0);
   end;
end;

procedure TFrmMain.mnuCommandClick(Sender: TObject);
var sCommand : string;
    node : TTreeNode;
    ConfElmts : TConfigurationRecord;
    aMessage : TxPLMessage;
begin
     sCommand := TMenuItem(Sender).Caption;
     node := tvMessages.Selected;
     if node.Data = nil then exit;
     ConfElmts := TConfigurationRecord(Node.Data);
     aMessage:=ConfElmts.plug_detail.CommandAsMessage(sCommand);
     aMessage.Target.Tag := GetSourceAddress;
     xPLClient.SendMessage(aMessage.RawXPL);
     aMessage.Free;
end;

procedure TFrmMain.GetSourceChain(var c1: string; var c2: string; var c3: string);
begin
   c1 := '*';
   c2 := c1;
   c3 := c1;

   if tvMessages.Selected <> topnode then begin
      if tvMessages.Selected.Parent=topnode then
         c1 := tvMessages.Selected.Text
         else
             if not tvMessages.Selected.HasChildren then begin
                c3 := tvMessages.Selected.Text;
                c2 := tvMessages.Selected.Parent.Text;
                c1 := tvMessages.Selected.Parent.Parent.Text;
           end else begin
               c2 := tvMessages.Selected.Text;
               c1 := tvMessages.Selected.Parent.Text;
           end;
   end;
end;

function TFrmMain.GetSourceAddress : string;
var c1,c2,c3 : string;
begin
   GetSourceChain(c1,c2,c3);
   result := TxPLAddress.ComposeAddress(c1,c2,c3)
end;

procedure TFrmMain.tvMessagesSelectionChanged(Sender: TObject);
var i : integer;
    c1,c2,c3 : string;
begin
   GetSourceChain(c1,c2,c3);
   CurrentTreeFilter := '*.' + TxPLAddress.ComposeAddressFilter(c1,c2,c3) + '.*.*';
   lvMessages.items.Clear;

   for i := 0 to Messages.Count -1 do
       if TxPLFilters.Matches(CurrentTreeFilter, TxPLMessage(Messages.Objects[i]).FilterTag) then
            AddToTreeview(i);
end;

procedure TFrmMain.AddToTreeview(aMessageNum : integer);
var s : array[0..4] of string;
    i : integer;
begin
     with lvMessages.Items.Add,TxPLMessage(Messages.Objects[aMessageNum]) do begin
        if frmAppSettings.ckIcons.Checked then ImageIndex := Ord(Schema.Classe)
                                          else ImageIndex := Ord(MessageType);

        for i:=0 to 4 do
           if frmAppSettings.ListBox1.Items[i]='Time'
              then s[i] := Messages[aMessageNum]
              else s[i] := ElementByName(frmAppSettings.ListBox1.Items[i]);

        Caption := s[0];
        for i:=1 to 4 do SubItems.Add(s[i]);

        SubItems.Add(IntToStr(aMessageNum));                                              // Stores the number of the message in the tv
     end;
end;

function TFrmMain.StatusString : string;
var i : extended;
begin
     i := DiffMinutes(DtLogStart, Now);
     if i<>0 then Result := Format('Logged %d during %s ( %n msg/min )',[iLoggedMsg,TimeToStr(Now-dtLogStart),iLoggedMsg / i]);
end;

procedure TFrmMain.OnMessageReceived(const axPLMessage: TxPLMessage);
var anode1, anode2, anode3 : TTreeNode;
    Config_Elmts :   TConfigurationRecord;

function SeekPlugin(Vendor : tsVendor; Device : tsDevice) : TxPLDevice;
begin
   result := nil;
   result := xPLClient.PluginList.GetDevice(Vendor,Device);
end;
function SeekConfig(aDevice : TxPLDevice) : TxPLConfig;
begin
   result := nil;
   if not Assigned(aDevice) then exit;

   result := TxPLConfig.Create(xPLClient);
   result.ReadFromXML(aDevice.Node);
end;

procedure HandleConfigMessages;
begin
   if ((axPLMessage.Body.Keys.Count=0 ) or (axPLMessage.Schema.Classe<>xpl_scConfig) or (axPLMessage.MessageType<>xpl_mtStat)) then exit;      // Don't handle config request messages
   case AnsiIndexStr(axPLMessage.Schema.Tag, [K_SCHEMA_CONFIG_CURRENT,K_SCHEMA_CONFIG_LIST]) of
        0 : Config_Elmts.config_current:= axPLMessage.Body.RawxPL;
        1 : Config_Elmts.config_list:= axPLMessage.Body.RawxPL;
   end;
end;


begin
   inc(iReceivedMsg);

   if  Play.Enabled or (Filter.Checked and (not CheckFilter(axPLMessage))) then exit;

   inc(iLoggedMsg);
   Messages.AddObject( TimeToStr(Now), TxPLMessage.create(axPLMessage.RawXPL));

   with axPLMessage.Source do begin                                             // Update left pane if needed
      anode1 := topNode.FindNode(Vendor);
      if anode1 = nil then anode1 := tvMessages.Items.AddChild(topNode,Vendor);

      anode2 := anode1.FindNode(Device);
      if anode2=nil then anode2 := tvMessages.Items.AddChild(aNode1,Device);
      anode3 := anode2.FindNode(Instance);
      if anode3=nil then begin                              // Add a new application instance to the treeview
         aNode3 := tvMessages.Items.AddChild(aNode2,Instance);
         Config_Elmts := TConfigurationRecord.Create;
         Config_Elmts.plug_detail := SeekPlugin(Vendor,Device);
         Config_Elmts.Plug_Config := SeekConfig(Config_Elmts.plug_detail);
         Config_Elmts.Device := Device;
         Config_Elmts.Vendor := Vendor;
         Config_Elmts.Instance := Instance;
         aNode3.Data := Config_Elmts;
         if frmAppSettings.ckAutoGetSetup.Checked then begin
               xPLClient.SendMessage(xpl_mtCmnd,TxPLAddress.ComposeAddress(Vendor,Device,Instance),K_SCHEMA_CONFIG_LIST+#10'{'#10'command=request'#10'}'#10);
               xPLClient.SendMessage(xpl_mtCmnd,TxPLAddress.ComposeAddress(Vendor,Device,Instance),K_SCHEMA_CONFIG_CURRENT+#10'{'#10'command=request'#10'}'#10);
         end;
      end;
      Config_Elmts := TConfigurationRecord(aNode3.Data);
   end;

   StatusBar1.Panels[0].Text := StatusString;

   if TxPLFilters.Matches(CurrentTreeFilter,axPLMessage.FilterTag) then
        AddToTreeview(Messages.Count-1);

   HandleConfigMessages;
end;



initialization
  {$I frm_main.lrs}

end.

