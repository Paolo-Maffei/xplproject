unit frm_template;

{$mode objfpc}{$H+}
{$r *.lfm}

interface

uses Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
     ExtCtrls, ActnList, Menus, Buttons, StdCtrls, RTTICtrls, LSControls,
     u_xPL_Collection, RxAboutDialog, Dlg_Template;

type // TFrmTemplate ==========================================================
     TFrmTemplate = class(TDlgTemplate)
        acAbout: TAction;
        acInstalledApps: TAction;
        acCoreConfigure: TAction;
        acAppConfigure: TAction;
        lblLog: TLabel;
        lblModuleName: TTILabel;
        AppMenu: TMenuItem;
        FormMenu: TMainMenu;
        imgStatus: TLSImage;
        mnuCoreConfigure: TMenuItem;
        mnuAppConfigure: TMenuItem;
        xPLMenu: TMenuItem;
        mnuConfigure: TMenuItem;
        mnuAbout: TMenuItem;
        mnuNull4: TMenuItem;
        mnuNull3: TMenuItem;
        mnuClose: TMenuItem;
        mnuLaunch: TMenuItem;
        mnuAllApps: TMenuItem;
        mnuNull2: TMenuItem;
        AboutDlg: TRxAboutDialog;
        procedure acAboutExecute(Sender: TObject);
        procedure acCoreConfigureExecute(Sender: TObject);
        procedure acInstalledAppsExecute(Sender: TObject);
        procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
     private
        procedure acCommonToolsExecute(Sender : TObject);
        procedure AddSubMenuElmt(const aColl : TxPLCustomCollection; const aName : string);
     public
        procedure OnJoinedEvent; virtual;
        procedure OnLogEvent(const aString : string); virtual;
     end;

implementation // =============================================================

uses frm_xplappslauncher
     , dlg_config
     , lcltype
     , u_xpl_gui_resource
     , u_xpl_custom_listener
     , u_xpl_application
     , u_xpl_heart_beater
     , u_xpl_settings
     , Process
     ;

// TFrmTemplate ===============================================================
procedure TFrmTemplate.FormCreate(Sender: TObject);
var sl : TxPLCustomCollection;
begin
   inherited;

   FormMenu.Images := DlgActions.Images;
   ImgStatus.Images := DlgActions.Images;
   ImgStatus.ImageIndex := K_IMG_XPL;

   lblModuleName.Link.TIObject := xPLApplication.Adresse;
   lblModuleName.Link.TIPropertyName:= 'RawxPL';

   xPLApplication.OnLogEvent := @OnLogEvent;

   Caption := xPLApplication.AppName;

   sl := TxPLRegistrySettings(xPLApplication.Settings).GetxPLAppList;
      AddSubMenuElmt(sl,'basicset');
      AddSubMenuElmt(sl,'vendfile');
      AddSubMenuElmt(sl,'piedit');
      AddSubMenuElmt(sl,'sender');
      AddSubMenuElmt(sl,'logger');
   sl.Free;

   acCoreConfigure.Visible := (xPLApplication is TxPLCustomListener);
   lblModuleName.Visible := acCoreConfigure.Visible;                           // This control has no meaning for non listener apps
   if acCoreConfigure.Visible then begin
      acCoreConfigure.ImageIndex := K_IMG_PREFERENCE;
      TxPLCustomListener(xPLApplication).OnxPLJoinedNet := @OnJoinedEvent;
   end;
end;

procedure TFrmTemplate.FormShow(Sender: TObject);
begin
   inherited;
   acAppConfigure.Visible := Assigned(acAppConfigure.OnExecute);
   mnuConfigure.Visible := acAppConfigure.Visible or acCoreConfigure.Visible;
end;

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

procedure TFrmTemplate.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
   CanClose := (Application.MessageBox('Do you want to quit ?', 'Confirm', MB_YESNO) = idYes)
end;

procedure TFrmTemplate.AddSubMenuElmt(const aColl : TxPLCustomCollection; const aName : string);
var item : TxPLCollectionItem;
    path, version, nicename : string;
    aMenu : TMenuItem;
begin
    item := aColl.FindItemName(aName);
    if assigned(item) then begin
       TxPLRegistrySettings(xPLApplication.Settings).GetAppDetail(item.Value,Item.DisplayName,path,version,nicename);
       aMenu := NewItem( nicename,0, false, (xPLApplication.Adresse.Device<>aName),
                         @acCommonToolsExecute, 0, '');
       aMenu.Hint    := path;
       mnuLaunch.Add(aMenu);
    end;
end;

procedure TFrmTemplate.OnJoinedEvent;
begin
   if TxPLCustomListener(xPLApplication).ConnectionStatus = connected
      then imgStatus.ImageIndex := K_IMG_RECONNECT
      else imgStatus.ImageIndex := K_IMG_DISCONNECT;
end;

procedure TFrmTemplate.OnLogEvent(const aString : string);
begin
   LblLog.Caption := aString;
end;

end.
