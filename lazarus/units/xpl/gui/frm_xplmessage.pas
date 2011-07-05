unit frm_xPLMessage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, StdCtrls,
  ExtCtrls, EditBtn, Menus, ActnList, ComCtrls, Buttons, u_xPL_Message_gui,
  u_xpl_message, frame_message, KHexEditor, SynEdit, SynHighlighterPas,
  v_xplmsg_opendialog, RTTICtrls;

type

  { TfrmxPLMessage }
  TfrmxPLMessage = class(TForm)
    acAbout: TAction;
    acInstalledApps: TAction;
    acLoad: TAction;
    acClose: TAction;
    acQuit: TAction;
    acPaste: TAction;
    ActionList: TActionList;
    ckLoop: TCheckBox;
    ckBody: TCheckBox;
    ckMsgType: TCheckBox;
    ckInstance: TCheckBox;
    ckDevice: TCheckBox;
    acSend: TAction;
    ActionList2: TActionList;
    HexEditor: TKHexEditor;
    Label4: TLabel;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    mnuCopyMessage: TMenuItem;
    mnuCopyAddress: TMenuItem;
    mnuCopyFilter: TMenuItem;
    acSave: TAction;
    PageControl1: TPageControl;
    mmoPSScript: TSynEdit;
    popCommands: TPopupMenu;
    popCopy: TPopupMenu;
    popFunctions: TPopupMenu;
    SynPasSyn1: TSynPasSyn;
    TabSheet1: TTabSheet;
    edtMsgName: TTIEdit;
    FrameMessage: TTMessageFrame;
    tbFunctions: TToolButton;
    ToolButton10: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    tsRaw: TTabSheet;
    tsPSScript: TTabSheet;
    ToolBar: TToolBar;
    tbOk: TToolButton;
    tbCancel: TToolButton;
    ToolButton3: TToolButton;
    SaveMessage: TxPLMsgSaveDialog;
    OpenMessage: TxPLMsgOpenDialog;
    tbCommands: TToolButton;
    xPLMenu: TPopupMenu;

    procedure acAboutExecute(Sender: TObject);
    procedure acInstalledAppsExecute(Sender: TObject);
    procedure acLoadExecute(Sender: TObject);
    procedure acQuitExecute(Sender: TObject);
    procedure ckDeviceChange(Sender: TObject);
    procedure acSendExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuCopyMessageClick(Sender: TObject);
    procedure mnuCopyAddressClick(Sender: TObject);
    procedure mnuCopyFilterClick(Sender: TObject);
    procedure acSaveExecute(Sender: TObject);
    procedure tbCommandsClick(Sender: TObject);
    procedure tbCopyClick(Sender: TObject);
    procedure tbFunctionsClick(Sender: TObject);
    procedure tbOkClick(Sender: TObject);
    procedure tbPasteClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);

  private
    arrCommandes : TList;
    procedure InitPluginsMenu;
    procedure InitFunctionsMenu;
    procedure PluginCommandExecute ( Sender: TObject );
    procedure FunctionExecute( Sender : TObject);
    procedure DisplayMessage;
  public
    buttonOptions : TButtonOptions;
    xPLMessage : TxPLMessage;
  end;

implementation // TFrmxPLMessage ===============================================================
uses frm_about,
     frm_Downloadfile,
     frm_xplappslauncher,
     u_xpl_custom_message,
     clipbrd,
     LCLType,
     cStrings,
     StrUtils,
     typInfo,
     u_xpl_schema,
     u_xpl_common,
     u_xpl_gui_resource,
     u_xpl_application,
     u_xpl_sender,
     u_xml_plugins,
     u_xpl_address,
     u_xpl_header;

// =============================================================================================
function AppendMenu(const aParent : TMenuItem; const aCaption : string) : TMenuItem;
begin
   Result := TMenuItem.Create(aParent);
   Result.Caption := aCaption;
   aParent.Add(result);
end;

// =============================================================================================
procedure TfrmxPLMessage.FormCreate(Sender: TObject);
var aMenu : TMenuItem;
begin

   arrCommandes := TList.Create;
   InitPluginsMenu;
   InitFunctionsMenu;

   aMenu := TMenuItem.Create(self);
   aMenu.Caption := '-';
   xPLMenu.Items.Insert(0,aMenu);

   aMenu := TMenuItem.Create(self);
   aMenu.Action := acPaste;
   xPLMenu.Items.Insert(0,aMenu);

   aMenu := TMenuItem.Create(self);
   aMenu.Caption := 'Copy...';
   aMenu.OnClick := @tbCopyClick;
   xPLMenu.Items.Insert(0,aMenu);

   aMenu := TMenuItem.Create(self);
   aMenu.Caption := '-';
   xPLMenu.Items.Insert(0,aMenu);

   aMenu := TMenuItem.Create(self);
   aMenu.Action := acSave;
   xPLMenu.Items.Insert(0,aMenu);

   aMenu := TMenuItem.Create(self);
   aMenu.Action := acLoad;
   xPLMenu.Items.Insert(0,aMenu);
end;

procedure TfrmxPLMessage.acAboutExecute(Sender: TObject);
begin
   ShowFrmAbout;
end;


procedure TfrmxPLMessage.acInstalledAppsExecute(Sender: TObject);
begin
   ShowFrmAppLauncher;
end;

procedure TfrmxPLMessage.FormDestroy(Sender: TObject);
begin
   arrCommandes.free;
end;

procedure TfrmxPLMessage.InitPluginsMenu;
var aMenu,aSubMenu, aSubSubMenu : TMenuItem;
    Commande: TCommandType;
    plug, item, item2 : TCollectionItem;
    device : TDeviceType;
begin
   if xPLApplication.VendorFile.Plugins <> nil then begin
   for plug in xPLApplication.VendorFile.Plugins do begin
       aMenu := TMenuItem.Create(self);
       popCommands.Items.Insert(0,aMenu);
       aMenu.Caption := TPluginType(plug).Vendor;                              // Get the vendor name as menu entry
       if TPluginType(plug).Present then
       for item in (TPluginType(plug).Devices) do begin
           Device := TDeviceType(item);
           aSubMenu := AppendMenu(aMenu, Device.Id_);
           for item2 in Device.Commands do begin
               commande := TCommandType(item2);
               aSubSubMenu := AppendMenu(aSubMenu,Commande.Name);
               aSubSubMenu.OnClick := @PluginCommandExecute;
               aSubSubMenu.Tag := ArrCommandes.Add(Commande);
           end;
           if aSubMenu.Count = 0 then aSubMenu.Free;
       end;
       if aMenu.Count = 0 then aMenu.Free;
     end;
   end else tbCommands.Enabled:=false;
end;

procedure TfrmxPLMessage.InitFunctionsMenu;
var ch : string;
    aMenu : TMenuItem;
begin
   for ch in K_KEYWORDS do begin
       aMenu := TMenuItem.Create(self);
       popFunctions.Items.Insert(0,aMenu);
       aMenu.Caption := '{SYS::' + ch + '}';
       aMenu.OnClick := @FunctionExecute;
   end;
end;

procedure TfrmxPLMessage.PluginCommandExecute(Sender: TObject);
var Command : TCommandType;
begin
   TabSheet1.SetFocus;                                                            // Ne pas rester dans un controle RTTI, ce qui pose un pb de rafraichissement
   Command := TCommandType(ArrCommandes[TMenuItem(sender).Tag]);
   xPLMessage.ReadFromJSON(Command);
   DisplayMessage;
end;

procedure TfrmxPLMessage.FunctionExecute(Sender: TObject);
var p : integer;
    str : string;
begin
   FrameMessage.edtBody.SetFocus;
   p := FrameMessage.EdtBody.SelStart + FrameMessage.EdtBody.SelLength + 1;
   str := FrameMessage.EdtBody.Text;
   Insert(TMenuItem(sender).Caption, str, p);
   FrameMessage.EdtBody.Text:= str;
   FrameMessage.EdtBody.SelStart := p + Length(TMenuItem(sender).Caption) -1;
end;

procedure TFrmxPLMessage.DisplayMessage;
var Stream : TStringStream;
begin
   with xPLMessage do begin
       if not Source.IsValid then Source.Assign(xPLApplication.Adresse);
       if not Target.IsValid then Target.IsGeneric := true;
       if not Schema.IsValid then Schema.Assign(Schema_ControlBasic);
       if not IsValid        then MessageType := cmnd;
   end;

   if tsRaw.Visible then begin
      Stream := TStringStream.Create('');
//      Stream.Position := 0;
      Stream.WriteString(xPLMessage.RawXPL);
      Stream.Position := 0;
      HexEditor.LoadFromStream(Stream);
      Stream.Free;
   end;

   FrameMessage.TheMessage := xPLMessage;
end;

procedure TfrmxPLMessage.acQuitExecute(Sender: TObject);
begin
   Close;
end;

procedure TfrmxPLMessage.tbCopyClick(Sender: TObject);
begin
   popCopy.PopUp;
end;

procedure TfrmxPLMessage.tbFunctionsClick(Sender: TObject);
begin
   popFunctions.PopUp;
end;

procedure TfrmxPLMessage.ToolButton2Click(Sender: TObject);
begin
   xPLMenu.PopUp;
end;

procedure TfrmxPLMessage.FormShow(Sender: TObject);
begin
   PageControl1.ActivePage := TabSheet1;
   ToolBar.Images := xPLGUIResource.Images;
   xPLMenu.Images := ToolBar.Images;
   acLoad.Visible  := (boLoad in buttonOptions);
   acSave.Visible := (boSave in buttonOptions);
   acPaste.Visible := not edtMsgName.ReadOnly;
   acSend.Visible  := (boSend in buttonOptions);
   ckLoop.Visible  := acSend.Visible;
   tbCommands.Visible := not edtMsgName.ReadOnly;
   tbOk.Visible       := (boOk in buttonOptions);
   tbCancel.Visible   := tbOk.Visible;
   acClose.Visible    := (boClose in buttonOptions);
   acAbout.Visible    := (boAbout in buttonOptions);
   acQuit.Visible     := not tbOk.Visible;
   acInstalledApps.Visible := acQuit.Visible;

   edtMsgName.Link.TIObject := xPLMessage;
   edtMsgName.Link.TIPropertyName := 'MsgName';

   FrameMessage.ReadOnly   := edtMsgName.ReadOnly;

   DisplayMessage;
end;

procedure TfrmxPLMessage.mnuCopyMessageClick(Sender: TObject);
begin
   Clipboard.AsText := xPLMessage.RawxPL;
end;

procedure TfrmxPLMessage.mnuCopyAddressClick(Sender: TObject);
begin
   Clipboard.AsText := xPLMessage.Source.RawxPL;
end;

procedure TfrmxPLMessage.mnuCopyFilterClick(Sender: TObject);
begin
   Clipboard.AsText := xPLMessage.SourceFilter;
end;

procedure TfrmxPLMessage.tbPasteClick(Sender: TObject);
begin
   xPLMessage.RawXPL := ClipBoard.AsText;
   DisplayMessage;
end;

procedure TfrmxPLMessage.acSendExecute(Sender: TObject);
var backAddress : TxPLAddress;
begin
   backAddress := TxPLAddress.Create(xPLApplication.Adresse);
   xPLApplication.Adresse.Assign(xPLMessage.Source);
   repeat
      TxPLSender(xPLApplication).Send(xPLMessage);
      Application.ProcessMessages;
   until not ckLoop.Checked;
   xPLApplication.Adresse.Assign(backAddress);
   backAddress.Free;
end;

procedure TfrmxPLMessage.acSaveExecute(Sender: TObject);
begin
   if SaveMessage.Execute then xPLMessage.SaveToFile(SaveMessage.FileName);
end;

procedure TfrmxPLMessage.tbCommandsClick(Sender: TObject);
begin
   popCommands.PopUp;
end;

procedure TfrmxPLMessage.acLoadExecute(Sender: TObject);
begin
   if not OpenMessage.Execute then exit;
   edtMsgName.SetFocus;
   xPLMessage.LoadFromFile(OpenMessage.FileName);
   DisplayMessage;
end;

procedure TfrmxPLMessage.ckDeviceChange(Sender: TObject);
const
   K_PROC_NAME_TEMPLATE = 'procedure %s_%s_%s_%s(const aMessage : string);';
   K_PROC_CONFIG_TEMPLATE = 'procedure %s_%s_%s_Config();';
   K_PROC_EXPIRED_TEMPLATE = 'procedure %s_%s_%s_Expired();';
   K_PROC_HBEAT_TEMPLATE = 'procedure %s_%s_%s_Heartbeat(const aMessage : string);';
var i : integer;
begin
     mmoPSScript.Lines.Clear;
     mmoPSScript.Lines.Add('// Message handling preformatted procedure');
     mmoPSScript.Lines.Add( StrReplace('xpl-','',
                            Format(K_PROC_NAME_TEMPLATE,[ xPLMessage.Source.Vendor,
                                                          IfThen(ckDevice.checked, xPLMessage.Source.Device,''),
                                                          IfThen(ckInstance.checked, xPLMessage.Source.Instance,''),
                                                          IfThen(ckMsgType.checked, MsgTypeToStr(xPLMessage.MessageType),'')
                                                        ]), false));
     mmoPSScript.Lines.Add('begin');
     if ckBody.Checked then begin
        for i:=0 to xPLMessage.Body.Keys.Count-1 do begin
            mmoPSScript.Lines.Add(
               ifthen(i=0,'    if (',' ') +
               '   (xpl.MessageValueFromKey(''' + xplMessage.Body.Keys[i] + ''') = ''' + xplMessage.Body.Values[i] + ''')' +
               ifthen(i<>xPLMessage.Body.Keys.Count-1,' and ', ') then begin')
            );
        end;
        mmoPSScript.Lines.Add('   end;');
     end;
     mmoPSScript.Lines.Add('end;');

     mmoPSScript.Lines.Add('');
     mmoPSScript.Lines.Add(Format(K_PROC_CONFIG_TEMPLATE,[ xPLMessage.Source.Vendor,
                                                           xPLMessage.Source.Device,
                                                           xPLMessage.Source.Instance ]));
     mmoPSScript.Lines.Add('begin');
     mmoPSScript.Lines.Add('   // Your code here');
     mmoPSScript.Lines.Add('end;');

     mmoPSScript.Lines.Add('');
     mmoPSScript.Lines.Add(Format(K_PROC_EXPIRED_TEMPLATE,[ xPLMessage.Source.Vendor,
                                                           xPLMessage.Source.Device,
                                                           xPLMessage.Source.Instance ]));
     mmoPSScript.Lines.Add('begin');
     mmoPSScript.Lines.Add('   // Your code here');
     mmoPSScript.Lines.Add('end;');

     mmoPSScript.Lines.Add('');
     mmoPSScript.Lines.Add(Format(K_PROC_HBEAT_TEMPLATE,[ xPLMessage.Source.Vendor,
                                                           xPLMessage.Source.Device,
                                                           xPLMessage.Source.Instance ]));
     mmoPSScript.Lines.Add('begin');
     mmoPSScript.Lines.Add('   // Your code here');
     mmoPSScript.Lines.Add('end;');

end;

procedure TfrmxPLMessage.tbOkClick(Sender: TObject);
begin
   Close;
end;

initialization
  {$I frm_xplmessage.lrs}
end.


