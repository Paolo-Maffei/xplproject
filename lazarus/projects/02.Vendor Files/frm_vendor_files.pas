unit frm_vendor_files;

{$i xpl.inc}
{$r *.lfm}

interface

uses Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
     Dialogs, ExtCtrls, StdCtrls, ComCtrls, Menus, ActnList, Buttons,
     XMLPropStorage, RTTICtrls, RxAboutDialog, LSControls, frm_template;

type // Tfrmvendorfiles =======================================================
     Tfrmvendorfiles = class(TFrmTemplate)
       acSelectAll: TAction;
       acDeselect: TAction;
       acInvert: TAction;
       acDownload: TAction;
       acUpdateList: TAction;
       acViewXML: TAction;
       cbLocations: TComboBox;
       BtnDownload: TLSBitBtn;
       Label1: TLabel;
       lvPlugins: TListView;
       MenuItem1: TMenuItem;
       MenuItem2: TMenuItem;
       MenuItem3: TMenuItem;
       MenuItem4: TMenuItem;
       MenuItem5: TMenuItem;
       MenuItem6: TMenuItem;
       MenuItem7: TMenuItem;
       ClientZone: TPanel;
       popPluginList: TPopupMenu;
       ProgressBar1: TProgressBar;
       StatusBar: TStatusBar;
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
       procedure lvPluginsItemChecked(Sender: TObject; Item: TListItem);
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

   acViewXML.ImageIndex := K_IMG_TXT;
   acUpdateList.ImageIndex := K_IMG_SYNCHRONIZE;
   SetButtonImage(BtnDownload,acDownload,K_IMG_DOWNLOAD);

   lvPlugins.SmallImages := DlgActions.Images;
   lvPlugins.StateImages := DlgActions.Images;
   PopPluginList.Images  := DlgActions.Images;

   acReloadExecute(self);
   lvPluginsItemChecked(self,nil);
end;

procedure Tfrmvendorfiles.lvPluginsItemChecked(Sender: TObject; Item: TListItem);
   function GetCheckCount : integer;
   var i : integer;
   begin
      Result := 0;
      for i:=0 to lvPlugins.Items.Count - 1 do
      if lvPlugins.Items[i].Checked then
      inc( result );
   end;
begin
   acDownload.Enabled:=(GetCheckCount<>0);
end;

procedure Tfrmvendorfiles.lvPluginsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var plug : TPluginType;
begin
   if not Assigned(lvPlugins.Selected) then exit;
   acViewXML.Enabled := (lvPlugins.Selected.ImageIndex = K_IMG_GREEN_BADGE);

   plug := TPluginType(lvPlugins.Selected.Data);
   StatusBar.Panels[1].Text := plug.Version;
   StatusBar.Panels[3].Text := plug.Info_URL;
   StatusBar.Panels[5].Text := plug.Plugin_URL;
end;

procedure Tfrmvendorfiles.acDeselectExecute(Sender: TObject);
var Item : TListItem;
begin
   for Item in lvPlugins.Items do Item.Checked := false;
   lvPluginsItemChecked(self,nil);
end;

procedure Tfrmvendorfiles.acSelectAllExecute(Sender: TObject);
var Item : TListItem;
begin
   for Item in lvPlugins.Items do Item.Checked := true;
   lvPluginsItemChecked(self,nil);
end;

procedure Tfrmvendorfiles.acInvertExecute(Sender: TObject);
var Item : TListItem;
begin
   for Item in lvPlugins.Items do Item.Checked := not Item.Checked;
   lvPluginsItemChecked(self,nil);
end;

procedure Tfrmvendorfiles.acReloadExecute(Sender: TObject);
var item : TCollectionItem;
    plug : TPluginType;
begin
   lvPlugins.Items.Clear;
   cbLocations.Items.Clear;

   cbLocations.Text := 'http://www.xplproject.org.uk/plugins';                 // At least one default value
   if not xPLApplication.VendorFile.IsValid then exit;

   xPLApplication.Log(etInfo,Format(K_UPDATE_STR,[DateTimeToStr(xPLApplication.VendorFile.UpdatedTS)]));

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
   Screen.Cursor := crHourGlass;
   try
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
   finally
      Screen.Cursor := crDefault;
   end;
end;

procedure Tfrmvendorfiles.acUpdateListExecute(Sender: TObject);
begin
   Screen.Cursor := crHourglass;
   try
   if xPLApplication.VendorFile.Update(cbLocations.Text)
      then acReloadExecute(self)
      else xPLApplication.Log(etWarning,'Error downloading file');
   finally
      Screen.Cursor := crDefault;
   end;
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
