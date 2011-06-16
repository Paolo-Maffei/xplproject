unit frm_template;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, ActnList, Menus, XMLPropStorage, RTTICtrls;

type { TFrmTemplate ==========================================================}
  TFrmTemplate = class(TForm)
    acAbout: TAction;
    acInstalledApps: TAction;
    acLogViewer: TAction;
    acQuit: TAction;
    acBasicSet: TAction;
    ActionList: TActionList;
    imgBullet: TImage;
    lblModuleName: TTILabel;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem7: TMenuItem;
    Panel4: TPanel;
    StatusBar1: TStatusBar;
    ToolBar: TToolBar;
    ToolButton10: TToolButton;
    ToolButton9: TToolButton;
    XMLPropStorage: TXMLPropStorage;
    xPLMenu: TPopupMenu;
    procedure acAboutExecute(Sender: TObject);
    procedure acBasicSetExecute(Sender: TObject);
    procedure acInstalledAppsExecute(Sender: TObject);
    procedure acLogViewerExecute(Sender: TObject);
    procedure acQuitExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
  private
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
     , u_xpl_settings
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

procedure TFrmTemplate.acBasicSetExecute(Sender: TObject);                     // Launch the BasicSet app
begin                                                                          // from the xPL menu
   with TProcess.Create(nil) do try
      CommandLine := acBasicSet.Hint;
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

procedure TFrmTemplate.FormCreate(Sender: TObject);
var sl : TAppCollection;
    i  : integer;
    aMenu : TMenuItem;
    path,version : string;
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

   TxPLCustomListener(xPLApplication).OnxPLJoinedNet := @OnJoinedEvent;
   xPLApplication.OnLogEvent := @OnLogEvent;

   Caption := xPLApplication.AppName;

   sl := xPLApplication.Settings.GetxPLAppList;
   if sl.Find('basicset',i) then begin
      xPLApplication.Settings.GetAppDetail(sl.Data[i].Vendor,sl.Keys[i],path,version);
      aMenu := TMenuItem.Create(self);
      aMenu.Action := acBasicSet;
      acBasicSet.Hint:=path;
      xPLMenu.Items.Insert(0,aMenu);
   end;
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

