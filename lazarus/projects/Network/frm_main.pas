unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,  Menus, ActnList,
  Buttons, Grids, uxPLClient, IdDayTime;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    About: TAction;
    BtnShowDirSelect: TButton;
    BtnShowDirSelect1: TButton;
    cbISO639: TComboBox;
    cbMeasure: TComboBox;
    cbLocations: TComboBox;
    cbISO3166: TComboBox;
    edtHTTPPort: TEdit;
    edtHTTPProxy: TEdit;
    edtRootDir: TEdit;
    edtWebDir: TEdit;
    IdDayTime1: TIdDayTime;
    InstalledApps: TAction;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label9: TLabel;
    lvPlugins: TListView;
    MenuItem1: TMenuItem;
    mnuDeselectAll: TMenuItem;
    MenuItem10: TMenuItem;
    mnuInvertSelect: TMenuItem;
    mnuSelectAll: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem7: TMenuItem;
    mnuViewXML: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    popPluginList: TPopupMenu;
    ProgressBar1: TProgressBar;
    rgProxy: TRadioGroup;
    SelectAll: TAction;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StaticText2: TStaticText;
    tsAdanced: TTabSheet;
    tbReload: TToolButton;
    ToolBar1: TToolBar;
    tbSave: TToolButton;
    tbUpdateSeed: TToolButton;
    tbDownload: TToolButton;
    UnselectAll: TAction;
    InvertSelection: TAction;
    UpdateSeed: TAction;
    DownloadSelected: TAction;
    ActionList1: TActionList;
    e_BroadCast: TComboBox;
    e_ListenOn: TComboBox;
    edtListenTo: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    PageControl1: TPageControl;
    Quit: TAction;
    rgListenTo: TRadioGroup;
    SaveSettings: TAction;
    StaticText1: TStaticText;
    tsBasic: TTabSheet;
    tsVendor: TTabSheet;
    procedure AboutExecute(Sender: TObject);
    procedure BtnShowDirSelect1Click(Sender: TObject);
    procedure BtnShowDirSelectClick(Sender: TObject);
    procedure DownloadSelectedExecute(Sender: TObject);
    procedure e_ListenOnChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ViewXML(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure PageControl1PageChanged(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure SaveSettingsExecute(Sender: TObject);

    procedure LoadVendorSettings;
    procedure LoadNetworkSettings;

    procedure Select_Do( Sender: TObject );
    procedure Select_Undo( Sender: TObject );
    procedure Select_Invert( Sender: TObject );
    procedure tbReloadClick(Sender: TObject);

    procedure UpdateSeedExecute(Sender: TObject);
  end;

var  FrmMain: TFrmMain;

implementation //===============================================================
uses SysUtils, 
     StrUtils, 
     IdStack, 
     app_main,
     {$IFDEF unix}pwhostname, {$ENDIF}
     frm_about, 
     uxPLConst,
     u_xml_iso_3166,
     u_xml_iso_639,
     frm_logviewer, 
     frm_xplappslauncher, 
     frm_XMLView,
     frm_plugin_viewer;
//==============================================================================
const K_ALL_IPS_JOCKER       = '*** ALL IP Address ***';
      K_IP_GENERAL_BROADCAST : string = '255.255.255.255';
      COMMENT_LINE_1         = 'Your network settings have been saved.'#10#13;
      COMMENT_LINE_2         = #10#13'Note that your computer should use a fixed IP Address'#10#13;
//==============================================================================
function MakeBroadCast(aAddress : string) : string;                             // transforms a.b.c.d in a.b.c.255
begin
   result := LeftStr(aAddress,LastDelimiter('.',aAddress)) + '255';
end;

{ TFrmMain Object =============================================================}
procedure TFrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TFrmMain.BtnShowDirSelect1Click(Sender: TObject);
begin if SelectDirectoryDialog1.Execute then edtWebDir.Text := SelectDirectoryDialog1.FileName; end;

procedure TFrmMain.QuitExecute(Sender: TObject);
begin Close; end;

procedure TFrmMain.MenuItem7Click(Sender: TObject);
begin frmLogViewer.Show; end;

procedure TFrmMain.MenuItem8Click(Sender: TObject);
begin frmAppLauncher.Show; end;

procedure TFrmMain.BtnShowDirSelectClick(Sender: TObject);
begin if SelectDirectoryDialog1.Execute then edtRootDir.Text := SelectDirectoryDialog1.FileName; end;

procedure TFrmMain.FormCreate(Sender: TObject);
var i,max : integer;
    s : string;
    child3166 : TXMLISO3166Type;
    child639 : TXMLISO639Type;
begin
  xPLClient    := TxPLClient.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER);
  Self.Caption := xPLClient.AppName;

  // Network Settings Part ===========================================
  {$IFDEF WINDOWS}
  e_ListenOn.Items.CommaText:= gStack.LocalAddress;
  {$ELSE}
  e_ListenOn.Items.Add(iNetSelfAddr);
  {$ENDIF}
  e_ListenOn.Items.Insert(0,K_ALL_IPS_JOCKER);

  e_BroadCast.Items.Clear;
  e_BroadCast.Items.Add(K_IP_GENERAL_BROADCAST);
  for i:=1 to e_ListenOn.Items.Count-1 do e_BroadCast.Items.Add( MakeBroadCast( e_ListenOn.Items[i]));

  tbReloadClick(self);                                                             // Loads current active values stored in registry
  PageControl1.ActivePage := tsBasic;
  PageControl1PageChanged(self);

  max := ISO3166File.Count;
  for i:=0 to max-1 do begin
      child3166 := ISO3166File[i];
      cbISO3166.Items.Add(child3166.name);
  end;

  max := ISO639File.Count;
  for i:=0 to max-1 do begin
      child639 := ISO639File[i];
      cbISO639.Items.Add(Child639.name);
  end;

  s := xPLClient.Settings.ReadKeyString(K_SET_COUNTRY);
  child3166 := ISO3166File.ElementByName[s];
  if child3166<>nil then cbISO3166.Text := child3166.name;

  s := xPLClient.Settings.ReadKeyString(K_SET_LANGUAGE);
  child639 := ISO639File.ElementByName[s];
  if child639<>nil then cbISO639.Text := child639.name;

  cbMeasure.Text := xPLClient.Settings.ReadKeyString(K_SET_UNITSYSTEM);
  edtWebDir.Text := xPLClient.Settings.ReadKeyString(K_SET_WEBDIR);
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
   xPLClient.Destroy;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  Toolbar1.Images := frmAbout.ilStandardActions;
end;

procedure TFrmMain.ViewXML(Sender: TObject);
var s : string;
begin
   if lvPlugins.Selected = nil then exit;
   s := lvPlugins.Selected.Caption;
   if s = 'xPL Schema Collection' then begin                                       // Handle this specific special case
      frmXMLView.FilePath := xPLClient.PluginList.GetPluginFilePath(s);
      frmXMLView.Show;
   end else begin
      frmPluginViewer.FilePath := xPLClient.PluginList.GetPluginFilePath(s);
      frmPluginViewer.Show;
   end;
end;

procedure TFrmMain.PageControl1PageChanged(Sender: TObject);
begin
   tbReload.Visible := not (PageControl1.ActivePage = tsVendor);                   // Adapt visibility of toolbar buttons to
   tbSave.Visible   := tbReload.Visible;                                           // the context of the current active page
   tbUpdateSeed.Visible := not tbReload.Visible;
   tbDownload.Visible   := tbUpdateSeed.Visible;
end;

procedure TFrmMain.Select_Do(Sender: TObject);
var i : integer;
begin
   for i := 0 to lvPlugins.Items.Count - 1 do lvPlugIns.Items[i].Checked := true;
end;

procedure TFrmMain.Select_Undo(Sender: TObject);
var i : integer;
begin
   for i := 0 to lvPlugins.Items.Count - 1 do lvPlugIns.Items[i].Checked := false;
end;

procedure TFrmMain.Select_Invert(Sender: TObject);
var i : integer;
begin
   for i := 0 to lvPlugins.Items.Count - 1 do lvPlugIns.Items[i].Checked := not lvPlugIns.Items[i].Checked;
end;

procedure TFrmMain.tbReloadClick(Sender: TObject);
begin
  LoadNetworkSettings;
  LoadVendorSettings;
end;

procedure TFrmMain.LoadVendorSettings;
var i : integer;
begin
   cbLocations.Items.Clear ;
   for i:=0 to xPLClient.PluginList.Locations.Count-1 do
            cbLocations.Items.Add(xPLClient.PluginList.Locations[i].Url);
   cbLocations.Text := K_XPL_VENDOR_SEED_LOCATION;                              // Default site to use

   if not FileExists(xPLClient.PluginList.Name) then exit;
   xPLClient.PluginList.Load;

   lvPlugins.Items.Clear;

   for i:=0 to xPLClient.PluginList.Plugins.Count-1 do
      with lvPlugins.Items.Add do begin
           Caption := xPLClient.PluginList.Plugins[i].Name;
           SubItems.Add(xPLClient.PluginList.Plugins[i].Type_);
           SubItems.Add(xPLClient.PluginList.Plugins[i].URL);
           SubItems.Add('');
      end;

   Panel1.Caption := 'Updated on '+ DateTimeToStr(xPLClient.PluginList.Updated);
end;

procedure TFrmMain.LoadNetworkSettings;
begin
    with xPLClient.Settings do begin
      e_BroadCast.Text := BroadCastAddress;
      e_ListenOn.Text  := IfThen(ListenOnAll, K_ALL_IPS_JOCKER, ListenOnAddress);

      edtListenTo.Text := '';
      if ListenToAny then
         rgListenTo.ItemIndex := 0
      else
         if ListenToLocal then
            rgListenTo.ItemIndex := 1
         else begin
            rgListenTo.ItemIndex := 2;
            edtListenTo.Text := ListenToAddresses;
         end;
      edtRootDir.Text:= SharedConfigDir;
      if UseProxy then rgProxy.ItemIndex := 1 else rgProxy.ItemIndex := 0;
      edtHttpPort.Text := HttpProxPort;
      edtHttpProxy.Text := HttpProxSrvr;

      tbSave.Enabled := False;                                                            // Will only be enabled if a field changes of value
   end;
end;

procedure TFrmMain.UpdateSeedExecute(Sender: TObject);
begin
   Screen.Cursor  := crHourGlass;
   xPLClient.PluginList.Update(cbLocations.Text);
   xPLClient.LogInfo('Seed file %s',[Panel1.Caption]);
   LoadVendorSettings;
   Screen.Cursor := crDefault;
end;

procedure TFrmMain.DownloadSelectedExecute(Sender: TObject);
var i : integer;
begin
   ProgressBar1.Visible := True;
   ProgressBar1.Max := lvPlugIns.Items.Count - 1;
   for i := 0 to ProgressBar1.Max do begin
       ProgressBar1.Position := i;
       with lvPlugins.Items[i] do begin
          application.ProcessMessages;
          if Checked then SubItems[2]  := IfThen(xPLClient.PluginList.UpdatePlugin(Caption),'Done','Error');
       end;
   end;
   ProgressBar1.Visible := False;
end;

procedure TFrmMain.e_ListenOnChange(Sender: TObject);                                     // Called by all editables fields to toggle
begin tbSave.Enabled:=True; end;                                                          // save button 'on'

procedure TFrmMain.SaveSettingsExecute(Sender: TObject);
var child3166 : TXMLISO3166Type;
    child639  : TXMLISO639Type;
begin
   with xPLClient.Settings do begin
        BroadCastAddress := e_BroadCast.text;

        ListenOnAll := (e_ListenOn.Text = K_ALL_IPS_JOCKER);
        if not ListenOnAll then ListenOnAddress := e_ListenOn.Text;

        case rgListenTo.ItemIndex of
           0 : ListenToAny := true;
           1 : ListenToLocal := true;
           2 : ListenToAddresses := edtListenTo.Text;
        end;

        UseProxy := (rgProxy.ItemIndex = 1);
        HttpProxPort := edtHttpPort.Text;
        HttpProxSrvr := edtHttpProxy.Text;

        SharedConfigDir := edtRootDir.Text;

        child3166 := ISO3166File[cbIso3166.ItemIndex];
        if (child3166<>nil) then xPLClient.Settings.WriteKeyString(K_SET_COUNTRY,child3166.alpha_2_code);

        child639 := ISO639File[cbIso639.ItemIndex];
        if (child639<>nil) then xPLClient.Settings.WriteKeyString(K_SET_LANGUAGE,child639.iso_639_1_code);

        xPLClient.Settings.WriteKeyString(K_SET_UNITSYSTEM,cbMeasure.Text);
        xPLClient.Settings.WriteKeyString(K_SET_WEBDIR,edtWebDir.Text);

        xPLClient.LogWarn(COMMENT_LINE_1,[]);
        xPLClient.LogInfo(COMMENT_LINE_2,[]);

   end;
end;

initialization
  {$I frm_main.lrs}

end.

