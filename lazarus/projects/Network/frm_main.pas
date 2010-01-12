unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,  Menus, ActnList,
  Buttons, Grids, uxPLClient, uxPLVendorFile,XMLPropStorage, IdDayTime;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    About: TAction;
    cbLocations: TComboBox;
    IdDayTime1: TIdDayTime;
    InstalledApps: TAction;
    MenuItem1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    SelectAll: TAction;
    sgDirectories: TStringGrid;
    TabSheet4: TTabSheet;
    UnselectAll: TAction;
    InvertSelection: TAction;
    Panel1: TPanel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    StatusBar1: TStatusBar;
    UpdateSeed: TAction;
    DownloadSelected: TAction;
    ActionList1: TActionList;
    e_BroadCast: TComboBox;
    e_ListenOn: TComboBox;
    edtListenTo: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    lvPlugins: TListView;
    MainMenu1: TMainMenu;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    PageControl1: TPageControl;
    Quit: TAction;
    rgListenTo: TRadioGroup;
    SaveSettings: TAction;
    SpeedButton1: TSpeedButton;
    StaticText1: TStaticText;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    XMLPropStorage1: TXMLPropStorage;
    procedure AboutExecute(Sender: TObject);
    procedure DownloadSelectedExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure InstalledAppsExecute(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure SaveSettingsExecute(Sender: TObject);

    procedure LoadVendorSettings;
    procedure LoadNetworkSettings;

    procedure Select_Do( Sender: TObject );
    procedure Select_Undo( Sender: TObject );
    procedure Select_Invert( Sender: TObject );

    procedure UpdateSeedExecute(Sender: TObject);
  private
    VendorSeed   : TxPLVendorSeedFile;
  public
    xPLClient : TxPLClient;
  end;

var  FrmMain: TFrmMain;

implementation //===============================================================
uses StrUtils, SysUtils, IdStack, uIPutils, IdHTTP,
     frm_xplAppsLauncher, frm_about;
//==============================================================================
resourcestring
     // Shared xPL Library resources =======================
     K_XPL_APP_VERSION_NUMBER = '1.2';
     K_XPL_APP_NAME           = 'xPL Network Config';

     // Specific to this appresources ======================
     K_ALL_IPS_JOCKER       = '*** ALL IP Address ***';
     COMMENT_LINE_1         = 'Your network settings have been saved.'#10#13;
     COMMENT_LINE_2         = #10#13'Note that your computer should use a fixed IP Address'#10#13;
     COMMENT_LINE_3         = 'Your xPL applications may need to be restarted for changes to take effect.';

{ TFrmMain Object =============================================================}
procedure TFrmMain.InstalledAppsExecute(Sender: TObject);
begin frmAppLauncher.ShowModal; end;

procedure TFrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TFrmMain.QuitExecute(Sender: TObject);
begin Close; end;

procedure TFrmMain.FormCreate(Sender: TObject);
var i : integer;
begin
  Self.Caption := K_XPL_APP_NAME;

  xPLClient    := TxPLClient.Create(self,K_XPL_APP_NAME,K_XPL_APP_VERSION_NUMBER);

  VendorSeed := TxPLVendorSeedFile.Create(xPLClient.Setting);

  // Network Settings Part ===========================================
  e_ListenOn.Items.CommaText:= gStack.LocalAddress;                   // If using inet : LocalIP of uIPutils unit
  e_ListenOn.Items.Insert(0,K_ALL_IPS_JOCKER);

  e_BroadCast.Items.Add(K_IP_GENERAL_BROADCAST);
  for i:=1 to e_ListenOn.Items.Count-1 do
      e_BroadCast.Items.Add( MakeBroadCast( e_ListenOn.Items[i]));

  LoadNetworkSettings;

  // Vendor settings Part ============================================
  LoadVendorSettings;

end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
   xPLClient.Destroy;
   VendorSeed.Destroy;
end;

procedure TFrmMain.LoadNetworkSettings;
begin
   sgDirectories.Cells[1,0] := xPLClient.Setting.SharedConfigDir;
   sgDirectories.Cells[1,1] := xPLClient.Setting.PluginDirectory;
   sgDirectories.Cells[1,2] := xPLClient.Setting.LoggingDirectory;
   sgDirectories.Cells[1,3] := xPLClient.Setting.ConfigDirectory;

   e_BroadCast.Text := xPLClient.setting.BroadCastAddress;

   e_ListenOn.Text := IfThen( xPLClient.Setting.ListenOnAll, K_ALL_IPS_JOCKER, xPLClient.Setting.ListenOnAddress);

   edtListenTo.Text := '';
   if xPLClient.setting.ListenToAny then
      rgListenTo.ItemIndex := 0
   else
       if xPLClient.setting.ListenToLocal then
          rgListenTo.ItemIndex := 1
       else begin
           rgListenTo.ItemIndex := 2;
           edtListenTo.Text := xPLClient.setting.ListenToAddresses;
       end;
end;

procedure TFrmMain.LoadVendorSettings;
var item     : TListItem;
    i : integer;
begin
   if not FileExists(VendorSeed.Name) then exit;

   Panel1.Caption := 'Updated on '+ DateTimeToStr(VendorSeed.Updated);

   cbLocations.Items.Clear ;
   cbLocations.Items.AddStrings(VendorSeed.Locations);

   lvPlugins.Items.Clear ;
   for i:=0 to VendorSeed.Plugins.Count-1 do begin
       item := lvPlugins.Items.Add;
       item.Caption := VendorSeed.Plugins[i];
       item.SubItems.Add(VendorSeed.GetPluginValue(item.Caption,'description'));
       item.SubItems.Add('');
       item.Data := VendorSeed.Plugins.Objects[i];
   end;
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

procedure TFrmMain.UpdateSeedExecute(Sender: TObject);
begin
   if cbLocations.Text<>'' then VendorSeed.Update(cbLocations.Text) else VendorSeed.Update;
   xPLClient.LogInfo('Seed file ' + Panel1.Caption);
   LoadVendorSettings;
end;

procedure TFrmMain.DownloadSelectedExecute(Sender: TObject);
var i : integer;
begin
   for i := 0 to lvPlugIns.Items.Count - 1 do
       with lvPlugins.Items[i] do begin
          application.ProcessMessages;
          if Checked then SubItems[1]  := IfThen(VendorSeed.UpdatePlugin(Caption),'Done','Error');
       end;
end;


procedure TFrmMain.SaveSettingsExecute(Sender: TObject);
var sCommentaire : string;
    s : string;
begin
     sCommentaire := COMMENT_LINE_1;

     xPLClient.setting.BroadCastAddress := e_BroadCast.text;

     s := e_ListenOn.Text;
     xPLClient.Setting.ListenOnAll := (s = K_ALL_IPS_JOCKER);
     if not xPLClient.Setting.ListenOnAll then begin
        xPLClient.Setting.ListenOnAddress := s;
        sCommentaire += COMMENT_LINE_2;
     end;

     case rgListenTo.ItemIndex of
        0 : xPLClient.setting.ListenToAny := true;
        1 : xPLClient.setting.ListenToLocal := true;
        2 : xPLClient.setting.ListenToAddresses := edtListenTo.Text;
     end;

   sCommentaire += COMMENT_LINE_3;

   Application.MessageBox(PChar(sCommentaire),PChar(caption),0);
   xPLClient.LogInfo(sCommentaire);
end;

initialization
  {$I frm_main.lrs}

end.

