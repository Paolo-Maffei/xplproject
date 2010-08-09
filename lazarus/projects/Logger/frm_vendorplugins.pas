unit frm_vendorplugins;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, XMLPropStorage, ExtCtrls, StdCtrls, Buttons, ActnList,
  uxPLVendorFile, Menus;

type

{ TfrmVendorPlugins }

TfrmVendorPlugins = class(TForm)
        cbLocations: TComboBox;
        Label1: TLabel;
        lvPlugins: TListView;
        MenuItem1: TMenuItem;
        MenuItem4: TMenuItem;
        MenuItem6: TMenuItem;
        Panel1: TPanel;
        PopupMenu1: TPopupMenu;
        ProgressBar1: TProgressBar;
        sbUpdateSeed: TSpeedButton;
        SpeedButton3: TSpeedButton;
        tbOk: TToolButton;
        ToolBar3: TToolBar;
        XMLPropStorage: TXMLPropStorage;
        procedure DownloadSelectedExecute(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure InvertSelectionExecute(Sender: TObject);
        procedure SelectAllExecute(Sender: TObject);
        procedure tbOkClick(Sender: TObject);
        procedure UnselectAllExecute(Sender: TObject);
        procedure UpdateSeedExecute(Sender: TObject);
     private
        VendorSeed   : TxPLVendorSeedFile;
        procedure LoadVendorSettings;
     end;

var frmVendorPlugins: TfrmVendorPlugins;

implementation //====================================================================================
uses frm_main, StrUtils, uxPLConst;

procedure TfrmVendorPlugins.tbOkClick(Sender: TObject);
begin Close; end;

procedure TfrmVendorPlugins.DownloadSelectedExecute(Sender: TObject);
var i : integer;
begin
   ProgressBar1.Visible := True;
   ProgressBar1.Max := lvPlugIns.Items.Count - 1;
   for i := 0 to ProgressBar1.Max do begin
       ProgressBar1.Position := i;
       with lvPlugins.Items[i] do begin
          application.ProcessMessages;
          if Checked then SubItems[3]  := IfThen(VendorSeed.UpdatePlugin(Caption),'Done','Error');
       end;
   end;
   ProgressBar1.Visible := False;
end;

procedure TfrmVendorPlugins.FormShow(Sender: TObject);
begin
  VendorSeed := frmMain.xPLClient.PluginList;
  LoadVendorSettings;
end;

procedure TfrmVendorPlugins.InvertSelectionExecute(Sender: TObject);
var i : integer;
begin
     for i := 0 to lvPlugins.Items.Count - 1 do lvPlugIns.Items[i].Checked := not lvPlugIns.Items[i].Checked;
end;

procedure TfrmVendorPlugins.SelectAllExecute(Sender: TObject);
var i : integer;
begin
     for i := 0 to lvPlugins.Items.Count - 1 do lvPlugIns.Items[i].Checked := true;
end;

procedure TfrmVendorPlugins.UnselectAllExecute(Sender: TObject);
var i : integer;
begin
     for i := 0 to lvPlugins.Items.Count - 1 do lvPlugIns.Items[i].Checked := false;
end;

procedure TfrmVendorPlugins.UpdateSeedExecute(Sender: TObject);
begin
   VendorSeed.Update(cbLocations.Text);
   frmMain.xPLClient.LogInfo('Seed file ' + Panel1.Caption,[]);
   LoadVendorSettings;
end;

procedure TfrmVendorPlugins.LoadVendorSettings;
var i : integer;

begin
   if not FileExists(VendorSeed.Name) then exit;

   Panel1.Caption := 'Updated on '+ DateTimeToStr(VendorSeed.Updated);

   cbLocations.Items.Clear ;
   cbLocations.Items.AddStrings(VendorSeed.Locations);
   cbLocations.Text := K_XPL_VENDOR_SEED_LOCATION;                     // Default site to use

   lvPlugins.Items.Clear ;
   for i:=0 to VendorSeed.Plugins.Count-1 do
      with lvPlugins.Items.Add do begin
           Caption := VendorSeed.Plugins[i];
           SubItems.Add(VendorSeed.PluginDescription(Caption));
           SubItems.Add(VendorSeed.PluginType       (Caption));
           SubItems.Add(VendorSeed.PluginURL        (Caption));
           SubItems.Add('');
      end;
end;


initialization
  {$I frm_vendorplugins.lrs}

end.

