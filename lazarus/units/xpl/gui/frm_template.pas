unit frm_template;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, ActnList, Menus, XMLPropStorage, RTTICtrls, u_xPL_Collection;

type { TFrmTemplate ==========================================================}
  TFrmTemplate = class(TForm)
    acAbout: TAction;
    acInstalledApps: TAction;
    acLogViewer: TAction;
    acQuit: TAction;
    ActionList: TActionList;
    imgBullet: TImage;
    lblModuleName: TTILabel;
    mnuNull1: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    mnuLaunch: TMenuItem;
    mnuAllApps: TMenuItem;
    mnuNull2: TMenuItem;
    MenuItem7: TMenuItem;
    Panel4: TPanel;
    StatusBar1: TStatusBar;
    ToolBar: TToolBar;
    ToolButton10: TToolButton;
    ToolButton9: TToolButton;
    XMLPropStorage: TXMLPropStorage;
    xPLMenu: TPopupMenu;
    procedure acAboutExecute(Sender: TObject);
    procedure acInstalledAppsExecute(Sender: TObject);
    procedure acLogViewerExecute(Sender: TObject);
    procedure acQuitExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
  private
    procedure acCommonToolsExecute(Sender : TObject);
    procedure AddSubMenuElmt(const aColl : TxPLCustomCollection; const aName : string);
  public
    procedure OnJoinedEvent; virtual;
    procedure OnLogEvent(const aString : string); virtual;
  end; 

var FrmTemplate: TFrmTemplate;

implementation // =============================================================

uses frm_logviewer
     , frm_about
     , frm_xplappslauncher
     , lcltype
     , u_xpl_listener
     , u_xpl_application
     , u_xpl_gui_resource
     , u_xpl_custom_listener
     , StrUtils
     , Process
     ;

{ TFrmTemplate ===============================================================}
procedure TFrmTemplate.acAboutExecute(Sender: TObject);
begin
   ShowFrmAbout;
end;

procedure TFrmTemplate.acCommonToolsExecute(Sender: TObject);
begin
     with TProcess.Create(nil) do try
          CommandLine := TMenuItem(Sender).Hint;
          Execute;
     finally
        Free;
     end;
end;

procedure TFrmTemplate.acInstalledAppsExecute(Sender: TObject);
begin
   ShowFrmAppLauncher;
end;

procedure TFrmTemplate.acLogViewerExecute(Sender: TObject);
begin
   ShowFrmLogViewer;
end;

procedure TFrmTemplate.acQuitExecute(Sender: TObject);
begin
   Close;
end;

procedure TFrmTemplate.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
   CanClose := (Application.MessageBox('Do you want to quit ?', 'Confirm', MB_YESNO) = idYes)
end;

procedure TFrmTemplate.ToolButton9Click(Sender: TObject);
begin
   xPLMenu.PopUp;
end;

procedure TFrmTemplate.AddSubMenuElmt(const aColl : TxPLCustomCollection; const aName : string);
var item : TxPLCollectionItem;
    path, version, nicename : string;
    aMenu : TMenuItem;
begin
    item := aColl.FindItemName(aName);
    if assigned(item) and (xPLApplication.Adresse.Device<>aName) then begin
       xPLApplication.Settings.GetAppDetail(item.Value,Item.DisplayName,path,version,nicename);
       aMenu := TMenuItem.Create(self);
       aMenu.Caption := nicename;
       aMenu.OnClick := @acCommonToolsExecute;
       aMenu.Hint    := path;
       mnuLaunch.Add(aMenu);
    end;
end;

procedure TFrmTemplate.FormCreate(Sender: TObject);
var sl : TxPLCustomCollection;
begin
   ToolBar.Images := xPLGUIResource.Images;
   xPLMenu.Images := ToolBar.Images;
   XMLPropStorage.FileName := xPLApplication.Folders.DeviceDir + 'settings.xml';
   XMLPropStorage.Restore;

   imgBullet.Parent := StatusBar1;
   imgBullet.Center := true;
   imgBullet.Width  := StatusBar1.Panels[0].Width;
   imgBullet.Height := StatusBar1.Panels[0].Width;

   lblModuleName.Link.TIObject := xPLApplication.Adresse;
   lblModuleName.Link.TIPropertyName:= 'RawxPL';

   if xPLApplication is TxPLCustomListener then
      TxPLCustomListener(xPLApplication).OnxPLJoinedNet := @OnJoinedEvent;

   xPLApplication.OnLogEvent := @OnLogEvent;

   Caption := xPLApplication.AppName;

   sl := xPLApplication.Settings.GetxPLAppList;
   AddSubMenuElmt(sl,'basicset');
   AddSubMenuElmt(sl,'vendfile');
   AddSubMenuElmt(sl,'piedit');
   AddSubMenuElmt(sl,'sender');
   sl.Free;
end;

procedure TFrmTemplate.OnJoinedEvent;
begin
   with TxPLListener(xPLApplication) do
      imgBullet.Picture.LoadFromLazarusResource(IfThen(ConnectionStatus = connected, K_IMG_RECONNECT, K_IMG_DISCONNECT));
end;

procedure TFrmTemplate.OnLogEvent(const aString : string);
begin
   StatusBar1.Panels[1].Text := aString;
end;

// ============================================================================
initialization
  {$I frm_template.lrs}

end.

