unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  ComCtrls, Menus, ActnList, ExtCtrls, StdCtrls, Grids, EditBtn, uxPLMessage,
  v_msgbody_stringgrid, v_xplmsg_opendialog,
  v_msgtype_radio, v_class_combo, MEdit, uxPLClient,Buttons;


type

  { TfrmMain }

  TfrmMain = class(TForm)
    acInstalledApps: TAction;
    Image1: TImage;
    ClasseImages: TImageList;
    edtSource: TMedit;
    edtTarget: TMedit;
    edt_Type: TMedit;
    MenuItem10: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MsgGrid: TBodyMessageGrid;
    Paste: TAction;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MenuItem11: TMenuItem;
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
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton8: TToolButton;
    OpenDialog: TxPLMsgOpenDialog;
    SaveDialog: TxPLMsgSaveDialog;
    radMsgType: TxPLMsgTypeRadio;
    cbClasse: TxPLClassCombo;
    procedure AboutExecute(Sender: TObject);
    procedure acInstalledAppsExecute(Sender: TObject);
    procedure cbClasseEditingDone(Sender: TObject);

    procedure ClearExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoadExecute(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure PasteExecute(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure SaveExecute(Sender: TObject);
    procedure SendExecute(Sender: TObject);

  private
    filename : string;
    arrCommandes : TStringList;
    procedure InitPluginsMenu;
    function Screen2Object(aMess : TxPLMessage) : boolean;
    procedure Object2Screen(aMess : TxPLMessage);
    procedure Setfilename(aName : string);
    procedure PluginCommandExecute ( Sender: TObject );
  public
    xPLClient : TxPLClient;
  end;

var  frmMain: TfrmMain;

implementation //===============================================================
uses frm_about, frm_xpllogviewer, uxPLAddress, cUtils, LCLType, clipbrd, DOM,
     StrUtils, frm_xplAppsLauncher, uxPLConst, u_xml_xplplugin;

resourcestring //===============================================================
     K_XPL_APP_VERSION_NUMBER = '1.5.1';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'sender';

// FrmMain =====================================================================
procedure TfrmMain.FormCreate(Sender: TObject);
begin
   xPLClient := TxPLClient.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER);
   arrCommandes := TStringList.Create;
   SetFileName('');
   OpenDialog.InitialDir := GetCurrentDir;
   SaveDialog.InitialDir := OpenDialog.InitialDir;

   InitPluginsMenu;

   edt_Type.RegExpr  := K_REGEXPR_SCHEMA_ELEMENT;                               // No specialized component a this time
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
var aMessage : TxPLMessage;
begin
   aMessage := TxPLMessage.create(Clipboard.AsText);
   if aMessage.IsValid then
      Object2Screen(aMessage)
   else
      Application.MessageBox('Badly formated string for input','Error',MB_OK + MB_ICONERROR);
   aMessage.Destroy;
end;

procedure TfrmMain.SendExecute(Sender: TObject);
var aMessage : TxPLMessage;
begin
   aMessage := TxPLMessage.Create;
   If Screen2Object(aMessage) then begin
      aMessage.Send;
      xPLClient.LogInfo('Message sent : ' + aMessage.Header.RawxPL,[]);
   end;
end;

function TfrmMain.Screen2Object(aMess : TxPLMessage) : boolean;
var sError : string;
begin
   sError := '';

   aMess.MessageType := radMsgType.ItemIndex;
   aMess.Source.Tag  := edtSource.Text;
   aMess.Target.Tag  := edtTarget.Text;
   aMess.Schema.ClasseAsString := cbClasse.Text;
   aMess.Schema.TypeAsString   := edt_Type.Text;

   if not aMess.Source.IsValid then sError := sError + ' Source field'#10#13;
   if not aMess.Target.IsValid then sError := sError + ' Target field'#10#13;

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
   cbClasse.Text        := aMess.Schema.ClasseAsString;
   edt_Type.Text        := aMess.Schema.TypeAsString;
   MsgGrid.Assign(aMess.Body);
end;

{= Load and Save management functions  ========================================}
procedure TfrmMain.SaveExecute(Sender: TObject);
var aMessage : TxPLMessage;
begin
  if length(filename)>0 then saveDialog.FileName := filename;
  aMessage := TxPLMessage.Create;
  if (Screen2Object(aMessage) and saveDialog.Execute) then begin
          aMessage.Name := saveDialog.FileName;
          aMessage.SaveToFile(saveDialog.FileName);
          xPLClient.LogInfo('Message saved : ' + aMessage.Name,[]);
     end;
  aMessage.Destroy;
end;

procedure TfrmMain.LoadExecute(Sender: TObject);
var aMessage : TxPLMessage;
begin
   if not OpenDialog.Execute then exit;

   ClearExecute(self);
   SetFileName(opendialog.filename);

   aMessage := TxPLMessage.Create;
   if aMessage.LoadFromFile(FileName) then begin
      Object2Screen(aMessage);
      xPLClient.LogInfo('Message loaded : %s',[FileName]);
   end else
      Application.MessageBox('Error reading xpl message file','Error',MB_OK + MB_ICONERROR);
   aMessage.Destroy;
end;

procedure TfrmMain.MenuItem10Click(Sender: TObject);
begin
   frmlogviewer.showmodal;
end;

{= Plug-ins management functions ==============================================}
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
{==============================================================================}

procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.acInstalledAppsExecute(Sender: TObject);
begin frmAppLauncher.ShowModal; end;

procedure TfrmMain.QuitExecute(Sender: TObject);
begin Close; end;

initialization
  {$I frm_main.lrs}

end.

