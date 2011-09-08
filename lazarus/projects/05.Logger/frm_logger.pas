unit frm_logger;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ActnList, Menus, ComCtrls, Grids, StdCtrls, Buttons, u_xPL_Config,
  u_xpl_custom_message, u_xPL_Message, ExtCtrls, Spin, XMLPropStorage,
  RTTICtrls, RTTIGrids,  uxPLConst, frm_template,
  frame_message, logger_listener, u_xpl_header;

type

  { TfrmLogger }
  TfrmLogger = class(TFrmTemplate)
    acAppSettings: TAction;
    acLogging: TAction;
    acPluginDetail: TAction;
    acDiscoverNetwork: TAction;
    acShowMessage: TAction;
    acConversation: TAction;
    acResend: TAction;
    acPlay: TAction;
    acAddToMacro: TAction;
    acAssembleFragments: TAction;
    ckLoop: TCheckBox;
    dgMessages: TStringGrid;
    Label4: TLabel;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem8: TMenuItem;
    mnuCommands: TMenuItem;
    mnuSendMessage: TMenuItem;
    Panel1:    TPanel;
    mnuTreeView: TPopupMenu;
    MessageFrame: TTMessageFrame;
    mnuListView: TPopupMenu;
    Panel2: TPanel;
    Panel5: TPanel;
    seSleep: TSpinEdit;
    tbMacro: TToolBar;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton102: TToolButton;
    tbListen: TToolButton;
    ToolButton4: TToolButton;
    ToolButton7: TToolButton;
    ToolButton92: TToolButton;
    ActionList1: TActionList;
    BtnRefresh: TBitBtn;
    Clear:     TAction;
    Load:      TAction;
    acExport:    TAction;
    SaveDialog: TSaveDialog;
    sgStats:   TStringGrid;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ToolButton3: TToolButton;
    ToolButton6: TToolButton;
    tvMessages: TTreeView;
    xPLMenu2: TPopupMenu;
    procedure acAddToMacroExecute(Sender: TObject);
    procedure acConversationExecute(Sender: TObject);
    procedure acDiscoverNetworkExecute(Sender: TObject);
    procedure acPlayExecute(Sender: TObject);
    procedure acPluginDetailExecute(Sender: TObject);
    procedure acResendExecute(Sender: TObject);
    procedure acAssembleFragmentsExecute(Sender : TObject);
    procedure acShowMessageExecute(Sender: TObject);
    procedure ClearExecute(Sender: TObject);
    procedure acExportExecute(Sender: TObject);
    procedure dgMessagesDrawCell(Sender: TObject; aCol, aRow: Integer;  aRect: TRect; aState: TGridDrawState);
    procedure dgMessagesHeaderClick(Sender: TObject; IsColumn: Boolean; Index: Integer);
    procedure dgMessagesSelection(Sender: TObject; aCol, aRow: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnuListViewPopup(Sender: TObject);
    procedure mnuSendMessageClick(Sender: TObject);
    procedure mnuCommandClick(Sender: TObject);
    procedure PlayExecute(Sender: TObject);
    procedure mnuTreeViewPopup(Sender: TObject);
    procedure tvMessagesChange(Sender: TObject; Node: TTreeNode);
    procedure tvMessagesClick(Sender: TObject);
    procedure tvMessagesSelectionChanged(Sender: TObject);
    procedure acLaunchMyConfig(Sender: TObject);
  private
    NetNode,MsgNode,ConNode,MacNode : TTreeNode;
    MacroList : TMessageList;

    procedure OnMessageReceived(const axPLMessage: TxPLMessage);
    function StatusString: string;
    function UpdateFilter : string;
    procedure AddToTreeview(const axPLMessage: TxPLMessage);
    procedure DisplayFilteredMessage(const aMsg : TxPLCustomMessage);
  public
    procedure ApplySettings(Sender: TObject);
    procedure OnJoinedEvent; override;
  end;

var frmLogger: TfrmLogger;

implementation { TFrmLogger =============================================================}
uses frm_xplappslauncher
     , u_configuration_record
     , StrUtils
     , u_xpl_message_gui
     , dlg_config
     , frm_logger_config
     , u_xPL_Address
     , u_xpl_gui_resource
     , u_xpl_listener
     , u_xpl_application
     , u_xpl_schema
     , u_xpl_common
     , u_xpl_fragment_mgr
     , u_xpl_messages
     , frm_PluginDetail
     , LCLType
     , LCLIntf
     , ClipBrd
     ;

const K_ROOT_NODE_NAME = 'Network';
      K_MESSAGES_ROOT  = 'Messages';
      K_CONVERSATION_ROOT = 'Conversations';
      K_MACRO_ROOT = 'Macro';

// ======================================================================================
procedure TfrmLogger.FormCreate(Sender: TObject);
var aMenu : TMenuItem;
    column : TCollectionItem;
begin
   inherited;

   TLoggerListener(xPLApplication).OnMessage := @OnMessageReceived;
   MacroList := TMessageList.Create;

   ClearExecute(self);

   TxPLListener(xPLApplication).Listen;

   aMenu := TMenuItem.Create(self);
   aMenu.Caption := '-';
   xPLMenu.Items.Insert(0,aMenu);

   aMenu := TMenuItem.Create(self);
   aMenu.Action := acExport;
   xPLMenu.Items.Insert(0,aMenu);

   mnuListView.Images:= xPLGUIResource.Images;
   acConversation.ImageIndex := K_IMG_THREAD;
   acResend.ImageIndex:=K_IMG_MAIL_FORWARD;
   acShowMessage.ImageIndex := K_IMG_EDIT_FIND;
   ToolButton3.ImageIndex:=K_IMG_RECORD;
   tbMacro.Images := xPLGUIResource.Images;
   acPlay.ImageIndex:=K_IMG_MENU_RUN;

   tvMessages.Images := xPLGUIResource.Images;
   NetNode := tvMessages.Items.AddChild(nil, K_ROOT_NODE_NAME);
   NetNode.ImageIndex:=K_IMG_NETWORK;
   msgNode := tvMessages.Items.AddChild(nil, K_MESSAGES_ROOT);
   msgNode.ImageIndex:=K_IMG_MESSAGE;
   ConNode := tvMessages.Items.AddChild(nil, K_CONVERSATION_ROOT);
   ConNode.ImageIndex:=K_IMG_THREAD;
   MacNode := tvMessages.items.AddChild(nil, K_MACRO_ROOT);
   tvMessages.Selected := NetNode;

   for Column in dgMessages.Columns do
       TGridColumn(Column).Width:=TGridColumn(Column).MinSize;

   MessageFrame.ReadOnly:=true;
   tvMessagesClick(self);

   acCoreConfigure.OnExecute := @acLaunchMyConfig;                          // Override standard config dialog

end;

procedure TfrmLogger.FormDestroy(Sender: TObject);
begin
   MacroList.Free;
end;

procedure TfrmLogger.acAddToMacroExecute(Sender: TObject);
begin
   MacroList.Add(dgMessages.Objects[0,dgMessages.Row]);
   MacNode.Text := Format('Macro (%d elts)',[MacroList.Count]);
end;

procedure TfrmLogger.acConversationExecute(Sender: TObject);
var aNode : TTreeNode;
    aMsg  : TxPLCustomMessage;
    sl    : TStringList;
    title : string;
begin
   if dgMessages.Row<>-1 then begin
      sl := TStringList.Create;
      sl.Sorted := true;
      aMsg := TxPLCustomMessage(dgMessages.Objects[0,dgMessages.Row]);
      sl.Add(aMsg.Source.RawxPL);
      sl.Add(aMsg.Target.RawxPL);
      title := sl.DelimitedText;
      anode := ConNode.FindNode(title);
      if anode = nil then anode := tvMessages.Items.AddChild(conNode,title);
      anode.Selected := true;
      sl.Free;
   end;
end;

procedure TfrmLogger.acDiscoverNetworkExecute(Sender: TObject);
begin
   TLoggerListener(xPLApplication).SendHBeatRequestMsg;
end;

procedure TfrmLogger.acPlayExecute(Sender: TObject);
var i : integer;
    iStop : cardinal;
begin
   repeat
      for i := 0 to Pred(MacroList.Count) do begin
          dgMessages.Row:= i + 1;
          TLoggerListener(xPLApplication).Send(TxPLCustomMessage(MacroList.Items[i]), false);

          iStop := GetTickCount + seSleep.Value * 1000 + 1;
          while GetTickCount < iStop do begin
             Application.ProcessMessages;
             sleep(1);
          end;
      end;
   until not ckLoop.Checked;
end;

procedure TfrmLogger.OnJoinedEvent;
begin
   inherited;
   with TxPLListener(xPLApplication) do begin
      ToolButton3.Down:=TLoggerListener(xPLApplication).fLogAtStartUp;
      PlayExecute(self);
      StatusBar1.Panels[1].Text := ConnectionStatusAsStr;
   end;
end;

procedure TfrmLogger.PlayExecute(Sender: TObject);
begin
   TLoggerListener(xPLApplication).Listening := ToolButton3.Down;
end;

function TfrmLogger.StatusString: string;
var i: extended;
begin
   with TLoggerListener(xPLApplication) do begin
        i := integer(Trunc((Now - LogStart) / (1 / 24 / 60)));
        Result := Format('Logged %d messages in %s secs',[MessageCount,TimeToStr(Now-LogStart)]);
        if i<>0 then Result += Format(' (%n msg/min',[MessageCount/i]);
   end;
end;

procedure TfrmLogger.AddToTreeview(const axPLMessage: TxPLMessage);
var i: integer;
begin
   dgMessages.RowCount := dgMessages.RowCount+1;
   dgMessages.Objects[0,dgMessages.RowCount-1] := axPLMessage;
   for i := 0 to 5 do
       dgMessages.Cells[i+1,dgMessages.RowCount-1] :=
          axPLMessage.ElementByName(dgMessages.Columns[i].Title.Caption);

end;

function TfrmLogger.UpdateFilter : string;
var //s : string;
    sl : TStringList;
    header : TxPLHeader;
begin
   header := TxPLHeader.Create(self);
   sl := TStringList.Create;
     if tvMessages.Selected.Parent = nil then                                  // We're on one of the roots
         StatusBar1.Panels[2].Text := '*.*.*.*.*.*'
      else if (tvMessages.Selected.Parent = ConNode) then begin                // We're on a conversation node
        sl.DelimitedText:=tvMessages.Selected.Text;
        header.source.RawxPL:=sl[0];
        header.Target.RawxPL:=sl[1];
        StatusBar1.Panels[2].Text := header.Source.RawxPL + ',' + header.Target.RawxPL;
        end else begin
//           s := StringReplace(tvMessages.Selected.GetTextPath,'/',' ',[rfReplaceAll]);
//           StrTokens(s,sl);
           Sl.Delimiter:= '/';
           Sl.DelimitedText:=tvMessages.Selected.GetTextPath;
//           ExtractTokensL(tvMessages.Selected.GetTextPath,'/',#0,false,sl);
           if sl[0] = K_ROOT_NODE_NAME then begin
              if (sl.Count>1) then header.source.Vendor := sl[1];
              if (sl.Count>2) then header.source.Device := sl[2];
              if (sl.Count>3) then header.source.Instance:= sl[3];
              StatusBar1.Panels[2].Text := '*.' + header.Source.AsFilter + '.*.*';
           end else begin
              if (sl.Count>1) then header.MessageType   := StrToMsgType(sl[1]);
              if (sl.Count>2) then header.schema.Classe := sl[2];
              if (sl.Count>3) then header.schema.Type_  := sl[3];
              StatusBar1.Panels[2].Text := header.SourceFilter;
           end;
           if Assigned(tvMessages.Selected.Parent.Data) then begin             // We're at a device level
              StatusBar1.Panels[2].Text := StatusBar1.Panels[2].Text + ',device=' + tvMessages.Selected.Text;
           end;
           result := Header.Source.AsFilter;
      end;
   sl.free;
   Header.Free;
end;

procedure TfrmLogger.ClearExecute(Sender: TObject);
begin
   dgMessages.RowCount:=1;
   PlayExecute(self);
   if tvMessages.Selected = MacNode then begin
      MacroList.Clear;
      if Assigned(MacNode) then MacNode.Text := 'Macro';
   end else TLoggerListener(xPLApplication).MessageList.Clear;
end;

procedure TfrmLogger.ApplySettings(Sender: TObject);                           // Correction bug FS#39 , This method is also called by frmAppSettings
begin                                                                          //    after having load the application default setup
   with FrmLoggerConfig do begin
        TLoggerListener(xPLApplication).fMessageLimit := seMaxPool.Value;
        TLoggerListener(xPLApplication).fLogAtStartUp := ckStartAtLaunch.Checked;
        PlayExecute(self);
        Panel1.Visible := ckShowPreview.Checked;
        tvMessagesSelectionChanged(Sender);
  end;
end;

procedure TfrmLogger.OnMessageReceived(const axPLMessage: TxPLMessage);
var anode1, anode2 : TTreeNode;
    s : string;
begin
  Application.ProcessMessages;

  anode1 := MsgNode.FindNode(MsgTypeToStr(axPLMessage.MessageType));           // Populate message list by message type
  if anode1 = nil then begin
     anode1 := tvMessages.Items.AddChild(MsgNode,MsgTypeToStr(axPLMessage.MessageType));
     anode1.ImageIndex:= K_IMG_CMND + Ord(axPLMessage.MessageType);
  end;
  aNode2 := anode1.FindNode(axPLMessage.schema.Classe);
  if aNode2 = nil then
     aNode2 := tvMessages.Items.AddChild(anode1,axPLMessage.Schema.Classe);
  anode1 := aNode2.FindNode(axPLMessage.Schema.Type_);
  if anode1 = nil then
     anode1 := tvMessages.Items.AddChild(aNode2,axPLMessage.Schema.Type_);

  with axPLMessage.Source do begin                                             // Populate message list by VDI
     anode1 := NetNode.findnode(Vendor);
     if anode1 = nil then
        anode1 := tvMessages.Items.AddChild(NetNode,Vendor);

     anode2 := anode1.FindNode(Device);
     if anode2 = nil then
        anode2 := tvMessages.Items.AddChild(aNode1, Device);

     anode1 := anode2.FindNode(Instance);
     if anode1 = nil then
        anode1 := tvMessages.Items.AddChildObject(aNode2,Instance,TConfigurationRecord.Create(xPLApplication,THeartBeatMsg(axPLMessage),nil));

     s := axPLMessage.Body.GetValueByKey('device');
     if s<>'' then begin
        anode2 := aNode1.FindNode(s);
        if anode2 = nil then tvMessages.Items.AddChild(aNode1,s);
     end;
  end;

  StatusBar1.Panels[3].Text := StatusString;

  if tvMessages.Selected <> MacNode then DisplayFilteredMessage(axPLMessage);  // The macro node doesn't need to be updated
end;

procedure TFrmLogger.DisplayFilteredMessage(const aMsg : TxPLCustomMessage);
var sl : TStringList;
    sFilter : string;
begin
  sl := TStringList.Create;
  sl.DelimitedText := StatusBar1.Panels[2].Text;
  if FrmLoggerConfig.rgFilterBy.ItemIndex = 0 then sFilter := aMsg.SourceFilter else sFilter := aMsg.TargetFilter;
  if sl.Count = 1 then                                                         // We're at VDI or Message level
    begin
       if xPLMatches(StatusBar1.Panels[2].Text, sFilter) then AddToTreeView(TxPLMessage(aMsg));
    end else begin                                                             // We're in conversation or device=xxx level
       if AnsiContainsText(sl[1],'device=') then begin                         // We're in device =
          if xPLMatches(sl[0], sFilter) then begin
             if aMsg.Body.Strings.IndexOf(sl[1])<>-1 then AddToTreeView(TxPLMessage(aMsg));
          end;
       end else begin                                                          // We're in conversation
          if ((aMsg.Source.RawxPL = sl[0]) or (aMsg.Source.RawxPL=sl[1])) and
            ((aMsg.Target.IsGeneric) or (aMsg.Target.RawxPL = sl[0]) or (aMsg.Target.RawxPL = sl[1])) then
             AddToTreeView(TxPLMessage(aMsg));
       end;
    end;
  sl.Free;
  dgMessagesSelection(self,0,0);                                                // Update message preview panel
end;

procedure TfrmLogger.tvMessagesSelectionChanged(Sender: TObject);
var i: integer;
    liste : TMessageList;
begin
   UpdateFilter;
   dgMessages.RowCount:=1;
   if tvMessages.Selected = MacNode then
        liste := MacroList
   else
        liste := TLoggerListener(xPLApplication).MessageList;

   for i:=0 to Pred(liste.Count) do
      DisplayFilteredMessage(TxPLMessage(liste.Items[i]));
   if dgMessages.RowCount>1 then dgMessages.Row:=1;
end;

procedure TfrmLogger.acLaunchMyConfig(Sender: TObject);
begin
   ShowDlgLoggerConfig;
   ApplySettings(sender);
end;

procedure TfrmLogger.mnuSendMessageClick(Sender: TObject);
var aMsg : TxPLMessage;
begin
   aMsg := TxPLMessage.Create(self);
   with TxPLMessageGUI(aMsg) do begin
        Source.Assign(xPLApplication.Adresse);
        Target.RawxPL := UpdateFilter;
        Schema.RawxPL := 'control.basic';
        MessageType := cmnd;                                                   // 2.1.2 correction
        Body.ResetValues;
        Body.AddKeyValuePairs(['key'], ['value']);                             // 2.0.3
        ShowForEdit([boSave, boSend]);
  end;
end;

procedure TfrmLogger.mnuTreeViewPopup(Sender: TObject);
begin
   tvMessagesChange(Sender, tvMessages.Selected);
end;

procedure TfrmLogger.acPluginDetailExecute(Sender: TObject);
var ConfElmts: TConfigurationRecord;
begin
   ConfElmts := TConfigurationRecord(tvMessages.Selected.Data);
   if ConfElmts = nil then exit;
   if ConfElmts.Plug_Detail = nil then exit;

   ShowFrmPluginDetail(ConfElmts.Plug_Detail);
end;

procedure TfrmLogger.acResendExecute(Sender: TObject);
begin
   TxPLListener(xPLApplication).Send(TxPLMessage(dgMessages.Objects[0,dgMessages.Row]));
end;

procedure TfrmLogger.acAssembleFragmentsExecute(Sender: TObject);
var aMsg : TxPLMessageGUI;
    aFrag : TFragBasicMsg;
    fFragFactory : TFragmentFactory;
begin
   aFrag := TFragBasicMsg.Create(self,TxPLMessage(dgMessages.Objects[0,dgMessages.Selection.Top]));
   fFragFactory := TLoggerListener(xPLApplication).FragmentMgr.GetFactory(aFrag.Identifier);
   if Assigned(fFragFactory) then begin
//   aMsg := TxPLMessageGUI(dgMessages.Objects[0,dgMessages.Selection.Top]);
//   fFragFactory := TLoggerListener(xPLApplication).FragmentMgr.AddFragment(TFragmentBasicMsg(aMsg));
     if fFragFactory.IsCompleted then begin
        aMsg := TxPLMessageGUI(fFragFactory.Assembled);
        if Assigned(aMsg) then aMsg.ShowForEdit([boClose, boSave, boCopy, boSend], false);
     end;
   end;
   aFrag.Free;
end;

procedure TfrmLogger.acShowMessageExecute(Sender: TObject);
var aMsg : TxPLMessageGUI;
begin
   aMsg := TxPLMessageGUI(dgMessages.Objects[0,dgMessages.Row]);
   if Assigned(aMsg) then aMsg.ShowForEdit([boClose, boSave, boCopy, boSend], false);
end;

procedure TfrmLogger.tvMessagesClick(Sender: TObject);
begin
   acDiscoverNetwork.Visible := (tvMessages.Selected = NetNode);
   acPluginDetail.Visible    := (tvMessages.Selected.Data <> nil);
   mnuCommands.Visible       := acPluginDetail.Visible;
   tbMacro.Visible           := (tvMessages.Selected = MacNode);
end;

procedure TfrmLogger.mnuListViewPopup(Sender: TObject);                        // Correction bug #FS68
var ControlCoord, NewCell: TPoint;
    i : integer;
    fFragFactory : TFragmentFactory;
    aMsg : TFragBasicMsg;
begin
   ControlCoord := dgMessages.ScreenToControl(mnuListView.PopupPoint);
   NewCell:=dgMessages.MouseToCell(ControlCoord);
   dgMessages.Row:=NewCell.Y;

   acAssembleFragments.Enabled := false;
   fFragFactory := nil;
   for i:=dgMessages.selection.top to dgMessages.selection.bottom do begin
      if Assigned(dgMessages.Objects[0,i]) then begin
         aMsg := TFragBasicMsg.Create(self,TxPLMessage(dgMessages.Objects[0,i]));
         if aMsg.IsValid then
            fFragFactory := TLoggerListener(xPLApplication).FragmentMgr.AddFragment(aMsg)
         else begin
            fFragFactory := nil;
            aMsg.Free;
            break;
         end;
         aMsg.Free;
      end;
   end;
   if Assigned(fFragFactory) then acAssembleFragments.Enabled := fFragFactory.IsCompleted;
end;

procedure TfrmLogger.tvMessagesChange(Sender: TObject; Node: TTreeNode);
var ConfElmts: TConfigurationRecord;
    i:     integer;
    aMenu: tmenuitem;
begin
   if (Node<>nil) and (Node.Data <> nil) then begin
      ConfElmts := TConfigurationRecord(Node.Data);
      acPluginDetail.Enabled := (ConfElmts.Plug_Detail <> nil);
      mnuCommands.Enabled     := acPluginDetail.Enabled;
      if mnuCommands.Enabled then begin
         if ConfElmts.plug_detail <> nil then begin
            {$IFDEF WINDOWS}(* At the time, don't understand why this fails under linux *)
            mnuCommands.Clear;
            for i := 0 to ConfElmts.plug_detail.Commands.Count - 1 do begin
                aMenu := TMenuItem.Create(self);
                aMenu.Caption := ConfElmts.plug_detail.Commands[i].Name;
                aMenu.OnClick := @mnuCommandClick;
                mnuCommands.Add(aMenu);
            end;
            {$ENDIF}
            mnuCommands.Enabled := (mnuCommands.Count > 0);
         end;
      end;
  end;
end;

procedure TfrmLogger.mnuCommandClick(Sender: TObject);
var
  sCommand: string;
  node: TTreeNode;
  ConfElmts: TConfigurationRecord;
  i:    integer;
  aMsg : TxPLMessage;
begin
  sCommand := TMenuItem(Sender).Caption;
  node     := tvMessages.Selected;
  if node.Data = nil then exit;

  ConfElmts := TConfigurationRecord(Node.Data);
  aMsg := TxPLMessage.Create(self);
  with aMsg do   begin
    Body.ResetValues;
    for i := 0 to ConfElmts.plug_detail.Commands.Count - 1 do
      if ConfElmts.plug_detail.Commands[i].Name = sCommand then
        ReadFromJSON(ConfElmts.plug_detail.Commands[i]);
    Target.RawxPL := UpdateFilter;
    Source.Assign(xPLApplication.Adresse);
    TxPLMessageGUI(aMsg).ShowForEdit([boSave, boSend]);
  end;
end;

procedure TfrmLogger.acExportExecute(Sender: TObject);
var I : Integer;
    CSV : TStrings;
    FileName : String;
begin
   saveDialog.Filter      := 'csv file|*.csv';
   saveDialog.DefaultExt  := 'csv';
   saveDialog.FilterIndex := 1;

  if SaveDialog.Execute then Begin
    FileName := SaveDialog.FileName;
    Screen.Cursor := crHourGlass;
    CSV := TStringList.Create;
    Try
      For I := 1 To dgMessages.RowCount - 1 Do CSV.Add(AnsiReplaceText(dgMessages.Rows[I].CommaText,#10,'\n'));
      CSV.SaveToFile(FileName);
    Finally
      CSV.Free;
    End;
  End;
  Screen.Cursor := crDefault;
end;

procedure TfrmLogger.dgMessagesDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var aMsg : TxPLMessage;
    img : TImage;
    s : string;
begin
   if aCol = 0 then begin
      aMsg := TxPLMessage(dgMessages.Objects[0,aRow]);
      if assigned(aMsg) then
         try
            img := TImage.Create(self);
            if FrmLoggerConfig.ckIcons.Checked then s :=aMsg.Schema.Classe
                                              else s := MsgTypeToStr(aMsg.MessageType);
            if LazarusResources.Find(s)<>nil then
            img.Picture.LoadFromLazarusResource(s);
            dgMessages.Canvas.Draw(aRect.Left+2,aRect.Top+2,img.Picture.Graphic);
         finally
            img.free;
         end;
   end;
end;

procedure TfrmLogger.dgMessagesHeaderClick(Sender: TObject; IsColumn: Boolean;   Index: Integer);
begin
   if dgMessages.SortOrder = soAscending then dgMessages.SortOrder := soDescending
                                         else dgMessages.SortOrder := soAscending;
   dgMessages.SortColRow(true,index);
end;

procedure TfrmLogger.dgMessagesSelection(Sender: TObject; aCol, aRow: Integer);
var aMsg : TxPLMessage;
begin
   acShowMessage.Enabled := Assigned(dgMessages.Objects[0,dgMessages.Row]);
   acResend.Enabled      := acShowMessage.Enabled;
   if acShowMessage.Enabled then begin
      aMsg := TxPLMessage(dgMessages.Objects[0,dgMessages.Row]);
      acConversation.Enabled := not ((aMsg.target.IsGeneric) or (aMsg.source.Equals(aMsg.Target)));
      MessageFrame.TheMessage := aMsg;
   end;
end;

initialization // =============================================================
  {$I frm_logger.lrs}
  {$I class.lrs}
  {$I msgtype.lrs}

end.
