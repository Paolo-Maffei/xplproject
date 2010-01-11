unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  ComCtrls, Menus, ActnList, ExtCtrls, StdCtrls, Grids, EditBtn, uxPLMessage, uxPLSettings,
  v_msgbody_stringgrid, v_xplmsg_opendialog, uxPLPluginFile,
  v_msgtype_radio, v_class_combo, MComboBox, MEdit, Buttons;


type

  { TfrmMain }

  TfrmMain = class(TForm)
    Image1: TImage;
    ClasseImages: TImageList;
    Label5: TLabel;
    edtSource: TMedit;
    edtTarget: TMedit;
    edt_Type: TMedit;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    mmoDescription: TMemo;
    MenuItem8: TMenuItem;
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
    ImageList1: TImageList;
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
    procedure cbClasseEditingDone(Sender: TObject);
//    procedure cbTypeEditingDone(Sender: TObject);
    procedure ClearExecute(Sender: TObject);
//    procedure EnableCHelperExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelperExecute(Sender: TObject);
    procedure LoadExecute(Sender: TObject);
    procedure PasteExecute(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure SaveExecute(Sender: TObject);
    procedure SendExecute(Sender: TObject);
//    procedure BtnSourceClick(Sender: TObject);
  private
    fMessage : TxPLMessage;
    fPluginList  : TxPLPluginList;
    filename : string;
    procedure InitPluginsMenu;
    function Screen2Object : boolean;
    procedure Object2Screen;
    procedure Setfilename(aName : string);
    procedure PluginCommandExecute ( Sender: TObject );
  end;

var  frmMain: TfrmMain;

Const
     K_XPL_APP_VERSION_NUMBER : string = '0.9.9';
     K_XPL_APP_VERSION_DATE   : string = '2009/06/03';
     K_XPL_APP_NAME = 'xPL Sender';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'sender';

implementation //======================================================================================
uses frm_about, frm_helper, uxPLAddress, uxPLMsgHeader, uxPLSchema, cUtils, LCLType, clipbrd, DOM,
     StrUtils;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  fPluginList := TxPLPluginList.Create;

  fMessage  := TxPLMessage.Create;

  SetFileName('');
  OpenDialog.InitialDir := GetCurrentDir;
  SaveDialog.InitialDir := OpenDialog.InitialDir;

  InitPluginsMenu;

  edt_Type.RegExpr    := K_REGEXPR_TYPE;    // No specialized component a this time
  edtSource.RegExpr := K_REGEXPR_ADDRESS;
  edtTarget.RegExpr := K_REGEXPR_TARGET;

  ClearExecute(self);
  edtSource.Text := TxPLAddress.ComposeAddress(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE, TxPLAddress.RandomInstance);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  fMessage.Destroy;
  fPluginList.Destroy;
end;

procedure TfrmMain.SetFileName(aName : string);
begin
  filename := aName;
  self.Caption := iif(length(filename)=0,K_XPL_APP_NAME,filename);
end;

procedure TfrmMain.ClearExecute(Sender: TObject);
begin
  radMsgType.ItemIndex := xpl_mtCmnd;
  edtSource.Text := '';
  MsgGrid.Clear;
  edtTarget.Text := '';
  cbClasse.Text := '';
  edt_Type.Text := '';
  mmoDescription.Text := '';
end;

procedure TfrmMain.cbClasseEditingDone(Sender: TObject);
//var i : integer;
//    s : tstringlist;
//    sav : string;
begin
     if cbClasse.ItemIndex<>-1 then
        ClasseImages.GetBitmap( AnsiIndexStr(cbClasse.Text,K_XPL_CLASS_DESCRIPTORS),
                                Image1.Picture.Bitmap);

{        if EnableCHelper.Checked then begin
           sav := cbType.Text;
           s := tstringlist.create;
           s.sorted := true;
           s.duplicates := dupignore;
           for i := 0 to frmhelper.xplCommands.RowCount-1 do begin
              if frmhelper.xplCommands.cells[0,i] = cbClasse.Text then s.Add(frmhelper.xplCommands.Cells[1,i]);
           end;

           cbType.Items.Clear;
           cbType.Items.AddStrings(s);
           cbType.Text := sav;

           s.destroy;
        end;}
end;

{procedure TfrmMain.cbTypeEditingDone(Sender: TObject);
var i : integer;
begin
{     if not EnableCHelper.Checked then exit;

     if cbType.Items.IndexOf(cbType.Text)<>-1 then begin
        MsgGrid.Clear;
        for i := 0 to frmhelper.xplCommands.RowCount-1 do begin
            if ((frmhelper.xplCommands.cells[0,i] = cbClasse.Text) and
                (frmhelper.xplCommands.cells[1,i] = cbType.Text))
            then MsgGrid.NewLine(frmhelper.xplCommands.cells[2,i],frmhelper.xplCommands.cells[3,i]);
        end;
     end;}
end;}

procedure TfrmMain.PasteExecute(Sender: TObject);
var s : string;
begin
     s := Clipboard.AsText;
     fMessage.ResetValues ;
     fMessage.RawXpl := s;
     if fMessage.IsValid then begin
        Object2Screen;
     end else
         Application.MessageBox('Badly formated string for input','Error',MB_OK + MB_ICONERROR);
end;

procedure TfrmMain.SendExecute(Sender: TObject);
begin
   fMessage.ResetValues;
   If Screen2Object then fMessage.Send;
end;

function TfrmMain.Screen2Object: boolean;
begin
   result := false;

   fMessage.MessageType := radMsgType.ItemIndex;
   fMessage.Source.Tag  := edtSource.Text;
   if not fMessage.Source.IsValid then begin
      Application.MessageBox('Error in the source field','Error',1);
      exit;
   end;

   fMessage.Target.Tag := edtTarget.Text;
   if not fMessage.Target.IsValid then begin
      Application.MessageBox('Error in the target field','Error',1);
      exit;
   end;

   fMessage.Schema.ClasseAsString := cbClasse.Text;
   fMessage.Schema.TypeAsString   := edt_Type.Text;
   if not fMessage.Schema.IsValid then begin
      Application.MessageBox('Error in the schema field','Error',1);
      exit;
   end;

   MsgGrid.CopyTo(fMessage.Body);

   fMessage.Description := mmoDescription.Text;
   result := true;
end;

procedure TfrmMain.Object2Screen;
begin
   radMsgType.ItemIndex := fMessage.MessageType;
   edtSource.Text       := fMessage.Source.Tag;
   edtTarget.Text       := fMessage.Target.Tag;
   cbClasse.Text        := fMessage.Schema.ClasseAsString;
   edt_Type.Text          := fMessage.Schema.TypeAsString;
   MsgGrid.Assign(fMessage.Body);
   mmoDescription.Text := fMessage.Description;
end;

{= Load and Save management functions  ==========================================}

procedure TfrmMain.SaveExecute(Sender: TObject);
begin
  fMessage.ResetValues;
  if length(filename)>0 then saveDialog.FileName := filename;

  if (Screen2Object and saveDialog.Execute) then begin
          fMessage.Name := saveDialog.FileName;
          fMessage.SaveToFile(saveDialog.FileName);
     end;
end;

procedure TfrmMain.LoadExecute(Sender: TObject);
begin
   if not OpenDialog.Execute then exit;

   ClearExecute(self);
   SetFileName(opendialog.filename);

   if fMessage.LoadFromFile(FileName) then begin
      Object2Screen;
   end else
      Application.MessageBox('Error reading xpl message file','Error',MB_OK + MB_ICONERROR);
end;


{= Plug-ins management functions ================================================}
procedure TFrmMain.PluginCommandExecute ( Sender: TObject );
var aMenu : TMenuItem;
    command, device, vendor : string;
    aPlugin : TxPLPluginFile;
    plugid : integer;
    CommandNode : TDomNode;
begin
     aMenu := TMenuItem(Sender);
     command := aMenu.Caption;
     device  := aMenu.Parent.Caption;
     vendor  := aMenu.Parent.Parent.Caption;
     plugid := fPluginList.Plugin.IndexOf(vendor);
     if plugid<>-1 then begin
        aPlugIn := TxPLPluginFile(fPluginList.Plugin.Objects[plugid]);
        CommandNode := aPlugIn.Command(device,command);
        if CommandNode<>nil then begin
           fMessage.ResetValues;
           fMessage.ReadFromXML(CommandNode);
           Object2Screen;
        end;
     end;
end;

procedure TFrmMain.InitPluginsMenu;
function AppendMenu(const aParent : TMenuItem; const aCaption : string) : TMenuItem;
begin
     Result := TMenuItem.Create(aParent);
     Result.Caption := aCaption;
     aParent.Add(result);
end;

var aMenu,aSubMenu, aSubSubMenu : TMenuItem;
    aPlugin : TxPLPluginFile;
    aListe, Commands : TStringList;
    cptPlugs,i,j : integer;
begin
     for cptPlugs:=0 to fPluginList.Count-1 do begin
         aPlugin := TxPLPluginFile(fPluginList.Plugin.Objects[cptPlugs]);
         aMenu := TMenuItem.Create(self);
         aMenu.Caption := aPlugin.VendorTag;
         MenuItem8.Insert(0,aMenu);
         aListe := TStringList.Create;
         aListe.AddStrings(aPlugin.DeviceList);
              for i:=0 to aListe.Count-1 do begin                                 // Loop on devices
                  aSubMenu := AppendMenu(aMenu, aListe[i]);
                  Commands := aPlugin.Commands(aListe[i]);
                  for j:= 0 to Commands.Count-1 do begin
                      aSubSubMenu := AppendMenu(aSubMenu, Commands[j]);
                      aSubSubMenu.OnClick := @PluginCommandExecute;
                  end;
                  Commands.Destroy;
                  if aSubMenu.Count=0 then aSubMenu.Free;                         // Eliminates empty sub menus
              end;
         aListe.Destroy;
         if aMenu.Count = 0 then aMenu.Free;
     end;
end;
{================================================================================}

procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

//procedure TfrmMain.BtnSourceClick(Sender: TObject);
//begin edtSource.Caption := sDefaultSourceName; end;

//procedure TfrmMain.EnableCHelperExecute(Sender: TObject);
//begin EnableCHelper.Checked := not EnableCHelper.Checked; end;

procedure TfrmMain.HelperExecute(Sender: TObject);
begin   frmhelper.showmodal; end;

procedure TfrmMain.QuitExecute(Sender: TObject);
begin Close; end;

initialization
  {$I frm_main.lrs}

end.

