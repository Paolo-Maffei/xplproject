unit frm_vendor_files;

{$mode objfpc}{$H+}
{$r *.lfm}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, ActnList, Buttons, RTTICtrls,
  XMLPropStorage{%H-}, IdComponent, frm_template, RxAboutDialog{%H-};

type

  { Tfrmvendorfiles }

  Tfrmvendorfiles = class(TFrmTemplate)
    acSelectAll: TAction;
    acDeselect: TAction;
    acInvert: TAction;
    acUpdateList: TAction;
    acDownload: TAction;
    acViewXML: TAction;
    cbLocations: TComboBox;
    lblUpdated: TLabel;
    Label12: TLabel;
    lvPlugins: TListView;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    Panel2: TPanel;
    popPluginList: TPopupMenu;
    ProgressBar1: TProgressBar;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure acDeselectExecute(Sender: TObject);
    procedure acDownloadExecute(Sender: TObject);
    procedure acInvertExecute(Sender: TObject);
    procedure acReloadExecute(Sender: TObject);
    procedure acSelectAllExecute(Sender: TObject);
    procedure acUpdateListExecute(Sender: TObject);
    procedure acViewXMLExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvPluginsSelectItem(Sender: TObject; {%H-}Item: TListItem; {%H-}Selected: Boolean);

  end; 

var frmvendorfiles: Tfrmvendorfiles;

implementation //==============================================================
uses StrUtils
     , frm_XMLView
     , u_xml_plugins
     , u_xpl_gui_resource
     , u_xpl_application
     ;

// ============================================================================
const K_UPDATE_STR = 'plugins.xml updated on %s';

// TFrmMain Object ============================================================
procedure Tfrmvendorfiles.FormCreate(Sender: TObject);
begin
   inherited;

   lvPlugins.SmallImages := ToolBar.Images;
   lvPlugins.StateImages := ToolBar.Images;
   PopPluginList.Images  := ToolBar.Images;

   acReloadExecute(self);
end;

procedure Tfrmvendorfiles.lvPluginsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var plug : TPluginType;
begin
   if not Assigned(lvPlugins.Selected) then exit;

   acViewXML.Enabled := (lvPlugins.Selected.ImageIndex = K_IMG_GREEN_BADGE);

   plug := TPluginType(lvPlugins.Selected.Data);
   StatusBar1.Panels[0].Text := 'Version : '     + plug.Version;
   StatusBar1.Panels[1].Text := 'Info : '     + plug.Info_URL;
   StatusBar1.Panels[2].Text := 'Plugin URL : ' + plug.Plugin_URL;
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
      //if Item.ImageIndex = K_IMG_GREEN_BADGE then
      Item.Checked := true;
end;

procedure Tfrmvendorfiles.acInvertExecute(Sender: TObject);
var Item : TListItem;
begin
   for Item in lvPlugins.Items do Item.Checked := not Item.Checked;
end;

procedure Tfrmvendorfiles.acReloadExecute(Sender: TObject);
var item : TCollectionItem;
    plug : TPluginType;
begin
   lvPlugins.Items.Clear;
   cbLocations.Items.Clear;

   xPLApplication.VendorFile.Load;
   cbLocations.Text := 'http://www.xplproject.org.uk/plugins';                 // At least one default value
   if not xPLApplication.VendorFile.IsValid then exit;

   lblUpdated.Caption := Format(K_UPDATE_STR,[DateTimeToStr(xPLApplication.VendorFile.UpdatedTS)]);

   for item in xPLApplication.VendorFile.Locations do
           cbLocations.Items.Add(TLocationType(item).Url);

   if cbLocations.Text='' then
      if cbLocations.Items.Count >0 then cbLocations.Text := cbLocations.Items[0];

   for item in xPLApplication.VendorFile.Plugins do begin
       with lvPlugins.Items.Add do begin
           plug := TPluginType(item);
           caption := plug.Name;
           subitems.DelimitedText:= Format('%s,%s',[plug.Type_,plug.URL]);
           if plug.present then begin
              SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(plug.FileName))));
              ImageIndex := K_IMG_GREEN_BADGE;
           end else begin
              SubItems.Add('Missing');
              ImageIndex := K_IMG_RED_BADGE;
           end;
           Data := plug;
       end;
   end;
end;

procedure Tfrmvendorfiles.acDownloadExecute(Sender: TObject);
var i : integer;
    plug : TPluginType;
begin
   ProgressBar1.Visible := True;
   ProgressBar1.Max := lvPlugIns.Items.Count - 1;
   for i := 0 to ProgressBar1.Max do begin
       ProgressBar1.Position := i;
       with lvPlugins.Items[i] do begin
          application.ProcessMessages;
          if Checked then begin
             plug := TPluginType(lvPlugins.Items[i].Data);
             SubItems[2] := IfThen( Plug.Update,'Success','Error');;
             if SubItems[2] = '' then SubItems[2] := 'Done';
             Checked := false;
          end;
       end;
   end;
   ProgressBar1.Visible := False;
   acReloadExecute(self);
end;

procedure Tfrmvendorfiles.acUpdateListExecute(Sender: TObject);
begin
   if xPLApplication.VendorFile.Update(cbLocations.Text)
      then acReloadExecute(self)
      else xPLApplication.Log(etWarning,'Error downloading file');
end;

procedure Tfrmvendorfiles.acViewXMLExecute(Sender: TObject);
var plug : TPluginType;
begin
   if Assigned(lvPlugins.Selected) then begin
      plug := TPluginType(lvPlugins.Selected.Data);
      ShowFrmXMLView(plug.FileName);
   end;
end;

end.

