unit frm_template;

{$mode objfpc}{$H+}
{$r *.lfm}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, ActnList, Menus, XMLPropStorage, Buttons, RTTICtrls,
  u_xPL_Collection, RxAboutDialog;

type { TFrmTemplate ==========================================================}
  TFrmTemplate = class(TForm)
    acAbout: TAction;
    acInstalledApps: TAction;
    acQuit: TAction;
    acCoreConfigure: TAction;
    ActionList: TActionList;
    imgBullet: TImage;
    lblModuleName: TTILabel;
    MnuItem1: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    mnuLaunch: TMenuItem;
    mnuAllApps: TMenuItem;
    mnuNull2: TMenuItem;
    Panel4: TPanel;
    AboutDlg: TRxAboutDialog;
    AppButton: TSpeedButton;
    StatusBar1: TStatusBar;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton9: TToolButton;
    XMLPropStorage: TXMLPropStorage;
    xPLMenu: TPopupMenu;
    AppMenu: TPopupMenu;
    procedure acAboutExecute(Sender: TObject);
    procedure acCoreConfigureExecute(Sender: TObject);
    procedure acInstalledAppsExecute(Sender: TObject);
    procedure acQuitExecute(Sender: TObject);
    procedure AppButtonClick(Sender: TObject);
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

uses frm_xplappslauncher
     , dlg_config
     , lcltype
     , u_xpl_custom_listener
     , u_xpl_application
     , u_xpl_gui_resource
     , Process
     ;

{ TFrmTemplate ===============================================================}
procedure TFrmTemplate.acAboutExecute(Sender: TObject);
const license = 'license.txt';
      readme  = 'readme.txt';
begin
   with AboutDlg do begin
      ApplicationTitle := xPLApplication.AppName;
      if FileExists(license) then LicenseFileName := license;
      if FileExists(readme)  then AdditionalInfo.LoadFromFile(readme);
      Picture.Assign(Application.Icon);
      Execute;
   end;
end;

procedure TFrmTemplate.acCommonToolsExecute(Sender: TObject);
begin
   with TProcess.Create(nil) do try
      Executable := TMenuItem(Sender).Hint;
      Execute;
   finally
      Free;
   end;
end;

procedure TFrmTemplate.acInstalledAppsExecute(Sender: TObject);
begin
   ShowFrmAppLauncher;
end;

procedure TFrmTemplate.acCoreConfigureExecute(Sender: TObject);
begin
   ShowDlgConfig;
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

procedure TFrmTemplate.AppButtonClick(Sender: TObject);
begin
   AppMenu.Popup;
end;

procedure TFrmTemplate.AddSubMenuElmt(const aColl : TxPLCustomCollection; const aName : string);
var item : TxPLCollectionItem;
    path, version, nicename : string;
    aMenu : TMenuItem;
begin
    item := aColl.FindItemName(aName);
    if assigned(item) then begin
       xPLApplication.Settings.GetAppDetail(item.Value,Item.DisplayName,path,version,nicename);
       aMenu := NewItem( nicename,0, false, (xPLApplication.Adresse.Device<>aName),
                         @acCommonToolsExecute, 0, '');
       aMenu.Hint    := path;
       mnuLaunch.Add(aMenu);
    end;
end;

procedure TFrmTemplate.FormCreate(Sender: TObject);
var sl : TxPLCustomCollection;
begin
   ToolBar.Images := xPLGUIResource.Images16;
   xPLMenu.Images := ToolBar.Images;
   AppMenu.Images := ToolBar.Images;
   AppMenu.Items.Clear;

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
   lblModuleName.Visible := (xPLApplication is TxPLCustomListener);            // This control has no meaning for non listener apps

   xPLApplication.OnLogEvent := @OnLogEvent;

   Caption := xPLApplication.AppName;

   sl := xPLApplication.Settings.GetxPLAppList;
      AddSubMenuElmt(sl,'basicset');
      AddSubMenuElmt(sl,'vendfile');
      AddSubMenuElmt(sl,'piedit');
      AddSubMenuElmt(sl,'sender');
      AddSubMenuElmt(sl,'logger');
   sl.Free;

   acCoreConfigure.Visible := (xPLApplication is TxPLCustomListener);
   AppButton.Glyph.Assign(Application.Icon);
end;

procedure TFrmTemplate.OnJoinedEvent;
var picture_index : integer;
begin
   with TxPLCustomListener(xPLApplication) do begin
      if ConnectionStatus = connected then picture_index := K_IMG_RECONNECT
                                      else picture_index := K_IMG_DISCONNECT;
      xPLGUIResource.Images16.GetBitmap(picture_index,imgBullet.Picture.Bitmap);
   end;
end;

procedure TFrmTemplate.OnLogEvent(const aString : string);
begin
   StatusBar1.Panels[1].Text := aString;
end;

end.

