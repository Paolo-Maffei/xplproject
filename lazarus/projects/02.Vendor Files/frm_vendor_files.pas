unit frm_vendor_files;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, ActnList, IdComponent;

type

  { Tfrmvendorfiles }

  Tfrmvendorfiles = class(TForm)
    acAbout: TAction;
    acSelectAll: TAction;
    acDeselect: TAction;
    acInvert: TAction;
    acUpdateList: TAction;
    acDownload: TAction;
    acViewXML: TAction;
    acViewPlugin: TAction;
    ActionList: TActionList;
    acInstalledApps: TAction;
    cbLocations: TComboBox;
    lblUpdated: TLabel;
    Label12: TLabel;
    lvPlugins: TListView;
    MenuItem1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    acQuit: TAction;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    Panel2: TPanel;
    popPluginList: TPopupMenu;
    ProgressBar1: TProgressBar;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    xPLMenu: TPopupMenu;
    procedure acAboutExecute(Sender: TObject);
    procedure acDeselectExecute(Sender: TObject);
    procedure acDownloadExecute(Sender: TObject);
    procedure acInstalledAppsExecute(Sender: TObject);
    procedure acInvertExecute(Sender: TObject);
    procedure acQuitExecute(Sender: TObject);
    procedure acReloadExecute(Sender: TObject);
    procedure acSelectAllExecute(Sender: TObject);
    procedure acUpdateListExecute(Sender: TObject);
    procedure acViewPluginExecute(Sender: TObject);
    procedure acViewXMLExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvPluginsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ToolButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmvendorfiles: Tfrmvendorfiles;

implementation //===============================================================
uses StrUtils,
     frm_about,
     frm_xplappslauncher,
     frm_XMLView,
     frm_plugin_viewer,
     u_xpl_gui_resource,
     u_xpl_application;

const K_UPDATE_STR = 'Updated on %s';
      K_XPL_VENDOR_SEED_LOCATION = 'http://www.xplmonkey.com/downloads/plugins';
      IMG_OK = 45;
      IMG_ERROR = 46;

{ TFrmMain Object =============================================================}
procedure Tfrmvendorfiles.acAboutExecute(Sender: TObject);
begin
   ShowFrmAbout;
end;

procedure Tfrmvendorfiles.acInstalledAppsExecute(Sender: TObject);
begin
   ShowFrmAppLauncher;
end;

procedure Tfrmvendorfiles.acQuitExecute(Sender: TObject);
begin
   Close;
end;

procedure Tfrmvendorfiles.ToolButton1Click(Sender: TObject);
begin
  xPLMenu.PopUp();
end;

procedure Tfrmvendorfiles.FormCreate(Sender: TObject);
begin
   acReloadExecute(self);
   ToolBar.Images := xPLGUIResource.Images;
   xPLMenu.Images := ToolBar.Images;
   lvPlugins.SmallImages := ToolBar.Images;
   lvPlugins.StateImages := ToolBar.Images;
   PopPluginList.Images := ToolBar.Images;
end;

procedure Tfrmvendorfiles.lvPluginsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
   if not Assigned(lvPlugins.Selected) then exit;

   acViewXML.Enabled := lvPlugins.Selected.ImageIndex = IMG_OK;
   acViewPlugin.Enabled := acViewXML.Enabled and (lvPlugins.Selected.SubItems[0] = 'plugin');
end;

procedure Tfrmvendorfiles.acDeselectExecute(Sender: TObject);
var Item : TListItem;
begin
   for Item in lvPlugins.Items do Item.Checked := false;
end;

procedure Tfrmvendorfiles.acSelectAllExecute(Sender: TObject);
var Item : TListItem;
begin
   for Item in lvPlugins.Items do
      if Item.ImageIndex = IMG_OK then Item.Checked := true;
end;

procedure Tfrmvendorfiles.acInvertExecute(Sender: TObject);
var Item : TListItem;
begin
   for Item in lvPlugins.Items do Item.Checked := not Item.Checked;
end;

procedure Tfrmvendorfiles.acReloadExecute(Sender: TObject);
var i : integer;
begin
   lvPlugins.Items.Clear;
   cbLocations.Items.Clear;
   cbLocations.Text := K_XPL_VENDOR_SEED_LOCATION;

   xPLApplication.VendorFile.Load;
   if not xPLApplication.VendorFile.IsValid then exit;

   lblUpdated.Caption := Format(K_UPDATE_STR,[DateTimeToStr(xPLApplication.VendorFile.Updated)]);

   for i:=0 to xPLApplication.VendorFile.Locations.Count-1 do
            cbLocations.Items.Add(xPLApplication.VendorFile.Locations[i].Url);

   for i:=0 to xPLApplication.VendorFile.Plugins.Count-1 do
      with lvPlugins.Items.Add do begin
           Caption := xPLApplication.VendorFile.Plugins[i].Name;
           SubItems.Add(xPLApplication.VendorFile.Plugins[i].Type_);
           SubItems.Add(xPLApplication.VendorFile.Plugins[i].URL);
           if FileExists(xPLApplication.VendorFile.GetPluginFilePath(Caption)) then begin
              SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(xPLApplication.VendorFile.GetPluginFilePath(Caption)))));
              ImageIndex := IMG_OK;
           end else begin
              SubItems.Add('Absent');
              ImageIndex := IMG_ERROR;
           end;
      end;
end;

procedure Tfrmvendorfiles.acDownloadExecute(Sender: TObject);
var i : integer;
begin
   ProgressBar1.Visible := True;
   ProgressBar1.Max := lvPlugIns.Items.Count - 1;
   for i := 0 to ProgressBar1.Max do begin
       ProgressBar1.Position := i;
       with lvPlugins.Items[i] do begin
          application.ProcessMessages;
          if Checked then begin
             SubItems[2]  := IfThen(xPLApplication.VendorFile.UpdatePlugin(Caption),'Success','Error');
             if SubItems[2] = '' then SubItems[2] := 'Done';
             Checked := false;
          end;
       end;
   end;
   ProgressBar1.Visible := False;
end;

procedure Tfrmvendorfiles.acUpdateListExecute(Sender: TObject);
begin
   if xPLApplication.VendorFile.Update(cbLocations.Text) then acReloadExecute(self)
             else Application.MessageBox('Error downloading file','Error',0);
end;

procedure Tfrmvendorfiles.acViewPluginExecute(Sender: TObject);
var s : string;
begin
   if not Assigned(lvPlugins.Selected) then exit;
   s := lvPlugins.Selected.Caption;
   ShowFrmPluginViewer(xPLApplication.VendorFile.GetPluginFilePath(s));
end;

procedure Tfrmvendorfiles.acViewXMLExecute(Sender: TObject);
var s : string;
begin
   if not Assigned(lvPlugins.Selected) then exit;
   s := lvPlugins.Selected.Caption;
   ShowfrmXMLView(xPLApplication.VendorFile.GetPluginFilePath(s));
end;

initialization
  {$I frm_vendor_files.lrs}

end.

