unit frm_xPLMessage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  StdCtrls, ExtCtrls, EditBtn, Grids, Menus, ActnList, ComCtrls, Buttons, u_xPL_Message_gui, uxplmessage,
  KHexEditor, SynEdit, SynHighlighterPas, v_xplmsg_opendialog;

type

  { TfrmxPLMessage }
  TfrmxPLMessage = class(TForm)
    acLoad: TAction;
    acClose: TAction;
    ckBody: TCheckBox;
    ckMsgType: TCheckBox;
    ckInstance: TCheckBox;
    ckDevice: TCheckBox;
    ClasseImages: TImageList;
    DoSend: TAction;
    ActionList2: TActionList;
    edtName: TEdit;
    HexEditor: TKHexEditor;
    Image1: TImage;
    Label4: TLabel;
    mnuCopyMessage: TMenuItem;
    mnuCopyAddress: TMenuItem;
    mnuCopyFilter: TMenuItem;
    mmoMessage: TMemo;
    MsgCopy: TAction;
    MsgSave: TAction;
    PageControl1: TPageControl;
    mmoPSScript: TSynEdit;
    popCommands: TPopupMenu;
    popCopy: TPopupMenu;
    SynPasSyn1: TSynPasSyn;
    TabSheet1: TTabSheet;
    tbPaste: TToolButton;
    tbAbout: TToolButton;
    ToolButton10: TToolButton;
    ToolButton2: TToolButton;
    ToolButton6: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    tsRaw: TTabSheet;
    tsPSScript: TTabSheet;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    tbOk: TToolButton;
    tbCancel: TToolButton;
    tbCopy: TToolButton;
    ToolButton3: TToolButton;
    ToolButton5: TToolButton;
    SaveMessage: TxPLMsgSaveDialog;
    OpenMessage: TxPLMsgOpenDialog;
    ToolButton7: TToolButton;
    tbCommands: TToolButton;

    procedure acCloseExecute(Sender: TObject);
    procedure acLoadExecute(Sender: TObject);
    procedure ckDeviceChange(Sender: TObject);
    procedure DoSendExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuCopyMessageClick(Sender: TObject);
    procedure mnuCopyAddressClick(Sender: TObject);
    procedure mnuCopyFilterClick(Sender: TObject);

    procedure mmoMessageExit(Sender: TObject);
    procedure MsgCopyExecute(Sender: TObject);
    procedure MsgSaveExecute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure tbAboutClick(Sender: TObject);
    procedure tbOkClick(Sender: TObject);
    procedure tbPasteClick(Sender: TObject);

  private
    Stream     : TStringStream;
    xPLMessage : TxPLMessage;
    arrCommandes : TList;
    procedure InitPluginsMenu;
    procedure PluginCommandExecute ( Sender: TObject );
    procedure DisplayMessage;
  public
    buttonOptions : TButtonOptions;
  end;

implementation // TFrmxPLMessage ===============================================================
uses frm_About,
     app_main,
     clipbrd,
     LCLType,
     cStrings,
     StrUtils,
     uxPLConst,
     u_xml_xplplugin;

// =============================================================================================
procedure TfrmxPLMessage.FormCreate(Sender: TObject);
begin
   Stream       := TStringStream.Create('');
   arrCommandes := TList.Create;
   InitPluginsMenu;
end;

procedure TfrmxPLMessage.FormShow(Sender: TObject);
begin
   xPLMessage := TxPLMessage(Owner);
   PageControl1.ActivePage := TabSheet1;
   ToolBar3.Images := frmAbout.ilStandardActions;
   acLoad.Visible  := (boLoad in buttonOptions);
   MsgSave.Visible := (boSave in buttonOptions);
   MsgCopy.Visible := (boCopy in buttonOptions);
   tbPaste.Visible := not mmoMessage.ReadOnly;
   DoSend.Visible  := (boSend in buttonOptions);
   tbCommands.Visible := not mmoMessage.ReadOnly;
   tbOk.Visible       := (boOk in buttonOptions);
   tbCancel.Visible   := tbOk.Visible;
   acClose.Visible    := (boClose in buttonOptions);
   tbAbout.Visible    := (boAbout in buttonOptions);
   edtName.ReadOnly   := mmoMessage.ReadOnly;
   DisplayMessage;
end;

procedure TfrmxPLMessage.FormDestroy(Sender: TObject);
begin
   arrCommandes.Destroy;
   Stream.Destroy;
end;

procedure TfrmxPLMessage.DoSendExecute(Sender: TObject);
begin
   mmoMessageExit(sender);
   xPLClient.Address.Assign(xPLMessage.Header.Source);
   xPLClient.Send(xPLMessage);
end;

procedure TfrmxPLMessage.acLoadExecute(Sender: TObject);
begin
   if not OpenMessage.Execute then exit;

   xPLMessage.LoadFromFile(OpenMessage.FileName);
   DisplayMessage;
end;

procedure TfrmxPLMessage.acCloseExecute(Sender: TObject);
begin
   Close;
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
                            Format(K_PROC_NAME_TEMPLATE,[ xPLMessage.Header.Source.Vendor,
                                                          IfThen(ckDevice.checked, xPLMessage.Header.Source.Device,''),
                                                          IfThen(ckInstance.checked, xPLMessage.Header.Source.Instance,''),
                                                          IfThen(ckMsgType.checked, xPLMessage.Header.MessageType,'')
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
     mmoPSScript.Lines.Add(Format(K_PROC_CONFIG_TEMPLATE,[ xPLMessage.Header.Source.Vendor,
                                                           xPLMessage.Header.Source.Device,
                                                           xPLMessage.Header.Source.Instance ]));
     mmoPSScript.Lines.Add('begin');
     mmoPSScript.Lines.Add('   // Your code here');
     mmoPSScript.Lines.Add('end;');

     mmoPSScript.Lines.Add('');
     mmoPSScript.Lines.Add(Format(K_PROC_EXPIRED_TEMPLATE,[ xPLMessage.Header.Source.Vendor,
                                                           xPLMessage.Header.Source.Device,
                                                           xPLMessage.Header.Source.Instance ]));
     mmoPSScript.Lines.Add('begin');
     mmoPSScript.Lines.Add('   // Your code here');
     mmoPSScript.Lines.Add('end;');

     mmoPSScript.Lines.Add('');
     mmoPSScript.Lines.Add(Format(K_PROC_HBEAT_TEMPLATE,[ xPLMessage.Header.Source.Vendor,
                                                           xPLMessage.Header.Source.Device,
                                                           xPLMessage.Header.Source.Instance ]));
     mmoPSScript.Lines.Add('begin');
     mmoPSScript.Lines.Add('   // Your code here');
     mmoPSScript.Lines.Add('end;');

end;

procedure TFrmxPLMessage.DisplayMessage;
begin
   mmoMessage.Lines.Clear;
   mmoMessage.Lines.AddStrings(xPLMessage.Strings);

   Stream.Position := 0;
   Stream.WriteString(xPLMessage.RawXPL);
   Stream.Position := 0;
   HexEditor.LoadFromStream(Stream);

   edtName.Text := xPLMessage.Name;

   ClasseImages.GetBitmap( AnsiIndexStr(xPLMessage.Header.Schema.Classe,K_XPL_CLASS_DESCRIPTORS),
                           Image1.Picture.Bitmap);
end;

procedure TfrmxPLMessage.InitPluginsMenu;
function AppendMenu(const aParent : TMenuItem; const aCaption : string) : TMenuItem;
begin
     Result := TMenuItem.Create(aParent);
     Result.Caption := aCaption;
     aParent.Add(result);
end;

var aMenu,aSubMenu, aSubSubMenu : TMenuItem;
    cptPlugs,i,j : integer;
    VendorFile : TXMLxplpluginType;
    Commande: TXMLCommandType;
begin
   for cptPlugs :=0 to xPLClient.PluginList.Plugins.Count-1 do with xPLClient do begin
       aMenu := TMenuItem.Create(self);
       popCommands.Items.Insert(0,aMenu);
       aMenu.Caption := PluginList.Plugins[cptPlugs].Vendor;                    // Get the vendor name as menu entry
       VendorFile := PluginList.VendorFile(aMenu.Caption);
       if assigned(VendorFile) then begin
          for i:=0 to VendorFile.Count-1 do begin
            aSubMenu := AppendMenu(aMenu, VendorFile[i].Id);
            for j:=0 to VendorFile[i].Commands.Count - 1 do begin
                Commande := VendorFile[i].Commands[j];
                aSubSubMenu := AppendMenu(aSubMenu, Commande.Name);
                aSubSubMenu.OnClick := @PluginCommandExecute;
                aSubSubMenu.Tag := ArrCommandes.Add(Commande);
            end;
            if aSubMenu.Count=0 then aSubMenu.Free;                             // Eliminates empty sub menus
          end;
       end;
       if aMenu.Count = 0 then aMenu.Free;
     end;
end;

procedure TfrmxPLMessage.PluginCommandExecute(Sender: TObject);
var Commande : TXMLCommandType;
begin
   Commande := TXMLCommandType(ArrCommandes[TMenuItem(sender).Tag]);
   xPLMessage.ReadFromXML(Commande);
   DisplayMessage;
end;

procedure TfrmxPLMessage.mnuCopyMessageClick(Sender: TObject);
begin
   mmoMessageExit(sender);
   Clipboard.AsText := xPLMessage.RawxPL;
end;

procedure TfrmxPLMessage.mnuCopyAddressClick(Sender: TObject);
begin
   mmoMessageExit(sender);
   Clipboard.AsText := xPLMessage.Source.RawxPL;
end;

procedure TfrmxPLMessage.mnuCopyFilterClick(Sender: TObject);
begin
   mmoMessageExit(sender);
   Clipboard.AsText := xPLMessage.SourceFilterTag;
end;

procedure TfrmxPLMessage.mmoMessageExit(Sender: TObject);
begin
   if not mmoMessage.Modified then exit;
   xPLMessage.Strings := TStringList(mmoMessage.Lines);
   DisplayMessage;
end;

procedure TfrmxPLMessage.MsgCopyExecute(Sender: TObject);
begin
   mmoMessageExit(sender);
   Clipboard.AsText := TxPLMessage(Owner).RawxPL;
end;

procedure TfrmxPLMessage.MsgSaveExecute(Sender: TObject);
begin
   mmoMessageExit(sender);
   if SaveMessage.Execute then xPLMessage.SaveToFile(SaveMessage.FileName);
end;

procedure TfrmxPLMessage.PageControl1Change(Sender: TObject);
begin
   mmoMessageExit(sender);
end;

procedure TfrmxPLMessage.tbAboutClick(Sender: TObject);
begin
   frmAbout.ShowModal;
end;

procedure TfrmxPLMessage.tbOkClick(Sender: TObject);
begin
   xPLMessage.Strings := TStringList(mmoMessage.Lines);
   xPLMessage.Name:=edtName.Text;
   Close;
end;

procedure TfrmxPLMessage.tbPasteClick(Sender: TObject);
begin
   xPLMessage.RawXPL := ClipBoard.AsText;
   DisplayMessage;
end;

initialization
  {$I frm_xplmessage.lrs}

end.


