unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  ComCtrls, Menus, ActnList, ExtCtrls, StdCtrls, Grids, EditBtn, uxPLMessage,
  v_msgbody_stringgrid, v_xplmsg_opendialog, MEdit,
  v_msgtype_radio, v_class_combo, Buttons;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    acInstalledApps: TAction;
    MenuItem11: TMenuItem;
    ViewLog: TAction;
    Copy: TAction;
    Image1: TImage;
    ClasseImages: TImageList;
    edtSource: TMedit;
    edtTarget: TMedit;
    edt_Type: TMedit;
    MenuItem10: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MsgGrid: TBodyMessageGrid;
    Paste: TAction;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MenuItem13: TMenuItem;
    Send: TAction;
    Clear: TAction;
    Load: TAction;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    Save: TAction;
    Quit: TAction;
    About: TAction;
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    OpenDialog: TxPLMsgOpenDialog;
    SaveDialog: TxPLMsgSaveDialog;
    radMsgType: TxPLMsgTypeRadio;
    cbClasse: TxPLClassCombo;
    procedure AboutExecute(Sender: TObject);
    procedure acInstalledAppsExecute(Sender: TObject);
    procedure cbClasseEditingDone(Sender: TObject);

    procedure ClearExecute(Sender: TObject);
    procedure CopyExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoadExecute(Sender: TObject);
    procedure PasteExecute(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure SaveExecute(Sender: TObject);
    procedure SendExecute(Sender: TObject);
    procedure ViewLogExecute(Sender: TObject);

  private
    filename : string;
    arrCommandes : TStringList;
    procedure InitPluginsMenu;
    function Screen2Object(aMess : TxPLMessage) : boolean;
    procedure Object2Screen(aMess : TxPLMessage);
    procedure Setfilename(aName : string);
    procedure PluginCommandExecute ( Sender: TObject );
  end;

var  frmMain: TfrmMain;

implementation //======================================================================================
uses frm_about, uxPLAddress, cUtils, LCLType, clipbrd, frm_logviewer, u_xpl_sender,
     StrUtils, frm_xplAppsLauncher, uxPLConst, app_main, u_xml_xplplugin;

// FrmMain ===========================================================================================
procedure TfrmMain.FormCreate(Sender: TObject);
begin
   xPLClient := TxPLSender.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER);
   arrCommandes := TStringList.Create;
   SetFileName('');
   OpenDialog.InitialDir := GetCurrentDir;
   SaveDialog.InitialDir := OpenDialog.InitialDir;

   InitPluginsMenu;

   edt_Type.RegExpr  := K_REGEXPR_SCHEMA_ELEMENT;    // No specialized component a this time
   edtSource.RegExpr := K_REGEXPR_ADDRESS;
   edtTarget.RegExpr := K_REGEXPR_TARGET;

   ClearExecute(self);
   edtSource.Text := TxPLAddress.ComposeAddress(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE, TxPLAddress.HostNmInstance);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  arrCommandes.Destroy;
  xPLClient.Destroy;
end;

procedure TfrmMain.SetFileName(aName : string);
begin
  filename := aName;
  self.Caption := iif(length(filename)=0,xPLClient.AppName ,filename);
end;

procedure TfrmMain.ClearExecute(Sender: TObject);
begin
  radMsgType.ItemIndex := K_MSG_TYPE_CMND;
  edtSource.Text := '';
  MsgGrid.Clear;
  edtTarget.Text := '';
  cbClasse.Text := '';
  edt_Type.Text := '';
end;

procedure TfrmMain.cbClasseEditingDone(Sender: TObject);
begin
  if cbClasse.ItemIndex<>-1 then
     ClasseImages.GetBitmap( AnsiIndexStr(cbClasse.Text,K_XPL_CLASS_DESCRIPTORS),
                             Image1.Picture.Bitmap);
end;

procedure TfrmMain.PasteExecute(Sender: TObject);
begin
   SendMsg.RawxPL := ClipBoard.AsText;
   if SendMsg.IsValid then
      Object2Screen(SendMsg)
   else
      xPLClient.LogWarn('Tried to paste badly formatted string from clipboard',[]);
end;

procedure TfrmMain.CopyExecute(Sender: TObject);
begin
   if Screen2Object(SendMsg) then
      ClipBoard.AsText:=SendMsg.RawxPL
end;

procedure TfrmMain.SendExecute(Sender: TObject);
begin
   If Screen2Object(SendMsg) then begin
      xPLClient.Send(SendMsg);
//      SendMsg.Send;
      xPLClient.LogInfo('Message sent : %s' ,[SendMsg.RawxPL]);
   end;
end;

function TfrmMain.Screen2Object(aMess : TxPLMessage) : boolean;
var sError : string;
begin
   sError := '';
   aMess.ResetValues;
   aMess.MessageType := radMsgType.ItemIndex;
   If not TxPLAddress.IsValid(edtSource.Text) then sError += ' Source field'#10#13 else aMess.Source.Tag  := edtSource.Text;
   If not TxPLTargetAddress.IsValid(edtTarget.Text) then sError += ' Target field'#10#13 else aMess.Target.Tag  := edtTarget.Text;
   aMess.Schema.Classe := cbClasse.Text;
   aMess.Schema.Type_  := edt_Type.Text;
   xPLClient.Address.Tag:=edtSource.Text;

   result := (sError='');
   if not result then begin
      sError := 'Error in the :'#10#13 + sError;
      Application.MessageBox(PChar(sError),'Error',1);
      exit;
   end;
   MsgGrid.CopyTo(aMess.Body);
end;

procedure TfrmMain.Object2Screen(aMess : TxPLMessage);
begin
   radMsgType.ItemIndex := aMess.MessageType;
   edtSource.Text       := aMess.Source.Tag;
   edtTarget.Text       := aMess.Target.Tag;
   cbClasse.Text        := aMess.Schema.Classe;
   edt_Type.Text        := aMess.Schema.Type_;
   MsgGrid.Assign(aMess.Body);
end;

{= Load and Save management functions  ==========================================}
procedure TfrmMain.SaveExecute(Sender: TObject);
begin
  if length(filename)>0 then saveDialog.FileName := filename;
  if (Screen2Object(SendMsg) and saveDialog.Execute) then begin
          SendMsg.Name := saveDialog.FileName;
          SendMsg.SaveToFile(saveDialog.FileName);
          xPLClient.LogInfo('Message saved : ' + SendMsg.Name,[]);
     end;
end;

procedure TfrmMain.LoadExecute(Sender: TObject);
begin
   if not OpenDialog.Execute then exit;
   ClearExecute(self);
   SetFileName(opendialog.filename);

   if SendMsg.LoadFromFile(FileName) then begin
      Object2Screen(SendMsg);
      xPLClient.LogInfo('Message loaded : %s' , [FileName]);
   end else
      xPLClient.LogWarn('Error reading xpl message file in %s',[FileName]);
end;

{= Plug-ins management functions ================================================}
procedure TFrmMain.PluginCommandExecute ( Sender: TObject );
var aMessage : TxPLMessage;
    asender : string;
    Commande : TXMLCommandType;
begin
   Commande := TXMLCommandType( arrCommandes.Objects[arrCommandes.IndexOf(IntToStr(TMenuItem(sender).Tag))]);

   aMessage := TxPLMessage.create;
   aMessage.ReadFromXML(Commande);
   asender := edtSource.Caption;                                                // Preserve current sender value
   Object2Screen(aMessage);
   edtSource.Caption := asender;
   aMessage.Destroy;
end;

procedure TFrmMain.InitPluginsMenu;
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
       MenuItem8.Insert(0,aMenu);
       aMenu.Caption := PluginList.Plugins[cptPlugs].Vendor;                    // Get the vendor name as menu entry
       VendorFile := PluginList.VendorFile(aMenu.Caption);
       if assigned(VendorFile) then begin
          for i:=0 to VendorFile.Count-1 do begin
            aSubMenu := AppendMenu(aMenu, VendorFile[i].Id);
            for j:=0 to VendorFile[i].Commands.Count - 1 do begin
                Commande := VendorFile[i].Commands[j];
                aSubSubMenu := AppendMenu(aSubMenu, Commande.Name);
                aSubSubMenu.OnClick := @PluginCommandExecute;
                aSubSubMenu.Tag := arrCommandes.count + 1;
                ArrCommandes.AddObject(IntToStr(aSubSubMenu.Tag),Commande);

            end;
            if aSubMenu.Count=0 then aSubMenu.Free;                             // Eliminates empty sub menus
          end;
       end;
       if aMenu.Count = 0 then aMenu.Free;
     end;
end;
{================================================================================}
procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.acInstalledAppsExecute(Sender: TObject);
begin frmAppLauncher.ShowModal; end;

procedure TfrmMain.ViewLogExecute(Sender: TObject);
begin frmLogViewer.ShowModal; end;

procedure TfrmMain.QuitExecute(Sender: TObject);
begin Close; end;

initialization
  {$I frm_main.lrs}

end.

