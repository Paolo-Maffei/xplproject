unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ActnList, Menus, ComCtrls, Grids, StdCtrls, Buttons, frm_About,
  uxPLMessage, uxPLListener, ExtCtrls,MCheckListBox, XMLPropStorage;

type

  { TFrmMain }

  { TLoggerListener }

  TFrmMain = class(TForm)
    About: TAction;
    acAppLauncher: TAction;
    acAppSettings: TAction;
    ClasseImages: TImageList;
    mnuSendMessage: TMenuItem;
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
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
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
    procedure acAppLauncherExecute(Sender: TObject);
    procedure acAppSettingsExecute(Sender: TObject);
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
    procedure PauseExecute(Sender: TObject);
    procedure PlayExecute(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
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
    procedure AddToTreeview(aMessageNum : integer);
  public
     xPLClient : TxPLListener;
  end;

var
  FrmMain: TFrmMain;

implementation { TFrmLogger =====================================================}
uses frm_xplappslauncher, frm_AppSettings,
     uxPLSchema, uxPLAddress, uxplMsgHeader, uxplcfgitem,
     cRandom, LCLType, ClipBrd, uxPLFilter, cutils, cStrings;

// ===============================================================================
resourcestring
     K_XPL_APP_VERSION_NUMBER = '1.2';
     K_XPL_APP_NAME = 'xPL Logger';
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

  Self.Caption := K_XPL_APP_NAME;
  bConfirmExit := True;

  xPLClient := TxPLListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_NAME, K_XPL_APP_VERSION_NUMBER);
  xPLClient.OnxPLReceived  := @OnMessageReceived;
  xPLClient.PassMyOwnMessages := True;

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

procedure TFrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TFrmMain.acAppLauncherExecute(Sender: TObject);
begin frmAppLauncher.Show; end;

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

procedure TFrmMain.FilterExecute(Sender: TObject);
begin { Nothing to do but the function must be present } end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  xPLClient.destroy;
  Messages.Destroy;
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
    c1,c2,c3 : string;
begin
     aMessage := TxPLMessage.Create ;
     aMessage.Header.Source := xPLClient.Address;
     GetSourceChain(c1,c2,c3);
     aMessage.Header.Target.Tag := TxPLAddress.ComposeAddress(c1,c2,c3);
     aMessage.ShowForEdit([boSave,boSend]) ;
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

procedure TFrmMain.GetSourceChain(var c1: string; var c2: string; var c3: string);
begin
   c1 := '*';
   c2 := '*';
   c3 := '*';

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
var item : TListItem;
    s : array[0..4] of string;
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

        SubItems.Add(IntToStr(aMessageNum));                    // Stores the number of the message in the tv
     end;
end;

function TFrmMain.StatusString : string;
var i,r : extended;
          function DateTimeDiff(Start, Stop : TDateTime) : int64; var TimeStamp : TTimeStamp;
          begin
             TimeStamp := DateTimeToTimeStamp(Stop - Start);
             Dec(TimeStamp.Date, TTimeStamp(DateTimeToTimeStamp(0)).Date);
             Result := (TimeStamp.Date*24*60*60)+(TimeStamp.Time div 1000);
          end;
begin
     i := DateTimeDiff(DtLogStart,Now) / 60;
     if i=0 then exit;

     r := iLoggedMsg / i  ;
     result := 'Logged : ' + IntToStr(iLoggedMsg) +
               ' during '  + TimeToStr(Now-DtLogStart) +
               ' (' + FloatToStr(Int(r)) + ' msg/min)';
end;

procedure TFrmMain.OnMessageReceived(const axPLMessage: TxPLMessage);
var anode1, anode2 : TTreeNode;
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
      if anode2.FindNode(Instance)=nil then tvMessages.Items.AddChild(aNode2,Instance);
   end;

   StatusBar1.Panels[0].Text := StatusString;

   if TxPLFilters.Matches(CurrentTreeFilter,axPLMessage.FilterTag) then
        AddToTreeview(Messages.Count-1);
end;



initialization
  {$I frm_main.lrs}

end.

