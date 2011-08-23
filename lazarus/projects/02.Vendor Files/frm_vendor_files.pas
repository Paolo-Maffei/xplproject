unit frm_vendor_files;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, ActnList, XMLPropStorage, RTTICtrls,
  IdComponent, frm_template;

type

  { Tfrmvendorfiles }

  Tfrmvendorfiles = class(TFrmTemplate)
    acSelectAll: TAction;
    acDeselect: TAction;
    acInvert: TAction;
    acPlugInfo: TAction;
    acUpdateList: TAction;
    acDownload: TAction;
    acViewXML: TAction;
    ActionList2: TActionList;
    cbLocations: TComboBox;
    lblUpdated: TLabel;
    Label12: TLabel;
    lvPlugins: TListView;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem8: TMenuItem;
    Panel2: TPanel;
    popPluginList: TPopupMenu;
    ProgressBar1: TProgressBar;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    procedure acDeselectExecute(Sender: TObject);
    procedure acDownloadExecute(Sender: TObject);
    procedure acInvertExecute(Sender: TObject);
    procedure acPlugInfoExecute(Sender: TObject);
    procedure acReloadExecute(Sender: TObject);
    procedure acSelectAllExecute(Sender: TObject);
    procedure acUpdateListExecute(Sender: TObject);
    procedure acViewXMLExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvPluginsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);

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
const K_UPDATE_STR = 'Updated on %s';

// TFrmMain Object ============================================================
procedure Tfrmvendorfiles.FormCreate(Sender: TObject);
begin
   inherited;

   lvPlugins.SmallImages := ToolBar.Images;
   lvPlugins.StateImages := ToolBar.Images;
   PopPluginList.Images  := ToolBar.Images;
   lblModuleName.Visible := False;

   acReloadExecute(self);
end;

procedure Tfrmvendorfiles.lvPluginsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
   if not Assigned(lvPlugins.Selected) then exit;

   acViewXML.Enabled := lvPlugins.Selected.ImageIndex = K_IMG_GREEN_BADGE;
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
      if Item.ImageIndex = K_IMG_GREEN_BADGE then Item.Checked := true;
end;

procedure Tfrmvendorfiles.acInvertExecute(Sender: TObject);
var Item : TListItem;
begin
   for Item in lvPlugins.Items do Item.Checked := not Item.Checked;
end;

procedure Tfrmvendorfiles.acPlugInfoExecute(Sender: TObject);
var plug : TPluginType;
    s    : string;
begin
   if Assigned(lvPlugins.Selected) then begin
      plug := TPluginType(lvPlugins.Selected.Data);
      s := 'Info URL : ' + plug.Info_URL + #13#10;
      s := s + 'Version : ' + plug.Version + #13#10;
      s := s + 'Plugin URL : ' + plug.Plugin_URL;

      Application.MessageBox(PChar(s),'Plugin information',1);
   end;
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
           plug := TPluginTYpe(item);
           caption := plug.Name;
           subitems.DelimitedText:= Format('%s,%s',[plug.Type_,plug.URL]);
           if plug.present then begin
              SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(plug.FileName))));
              ImageIndex := K_IMG_GREEN_BADGE;
           end else begin
              SubItems.Add('Absent');
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
end;

procedure Tfrmvendorfiles.acUpdateListExecute(Sender: TObject);
begin
   if xPLApplication.VendorFile.Update(cbLocations.Text) then acReloadExecute(self)
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

initialization
  {$I frm_vendor_files.lrs}

end.

