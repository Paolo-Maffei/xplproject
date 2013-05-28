unit frm_xplappslauncher;
{==============================================================================
  UnitName      = frm_xplappslauncher
  UnitDesc      = Standard xPL apps launching box
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 1.0 : Added code to avoid presenting myself in the list of applications to launch
}

{$mode objfpc}{$H+}
{$r *.lfm}

interface

uses Classes, SysUtils, LSControls, LResources, Forms, Controls, Graphics,
     ComCtrls, ActnList, Buttons, ExtCtrls, dlg_template;

type // TfrmAppLauncher =======================================================
     TfrmAppLauncher = class(TDlgTemplate)
        FrmAcLaunch: TAction;
        DlgTbLaunch: TLSBitBtn;
        lvApps: TListView;
        procedure DlgTbLaunchClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
     end;

     procedure ShowFrmAppLauncher;

implementation //==============================================================
uses Process
     , FileUtil
     , Dialogs
     , u_xpl_application
     , u_xpl_collection
     , u_xpl_gui_resource
     ;

var frmAppLauncher: TfrmAppLauncher;

// ============================================================================
procedure ShowFrmAppLauncher;
begin
   if not Assigned(frmAppLauncher) then
      Application.CreateForm(TFrmAppLauncher, frmAppLauncher);
   frmAppLauncher.ShowModal;
end;

// Form procedures ============================================================
procedure TfrmAppLauncher.FormCreate(Sender: TObject);
begin
   inherited;
   SetButtonImage(DlgTbLaunch,FrmAcLaunch,K_IMG_MENU_RUN);
end;

procedure TfrmAppLauncher.FormShow(Sender: TObject);
var sl : TxPLCustomCollection;
    path, version, nicename : string;
    i : integer;
begin
   inherited;

   lvApps.Items.Clear;
   sl  := xPLApplication.Settings.GetxPLAppList;
   for i := 0 to sl.Count -1 do begin
       xPLApplication.Settings.GetAppDetail(sl.Items[i].Value,sl.Items[i].DisplayName,path,version, nicename);
       if path <> Application.ExeName then with lvApps.Items.Add do begin     // Avoid presenting myself in the app list
            if NiceName<>'' then Caption := NiceName
                            else Caption := sl[i].DisplayName;
            SubItems.DelimitedText:= Sl[i].Value + ',' + version + ',' + path;
       end;
   end;
   sl.Free;
end;

procedure TfrmAppLauncher.DlgTbLaunchClick(Sender: TObject);
var filename : string;
begin
   if lvApps.Selected = nil then exit;
   filename := lvApps.Selected.SubItems[2];

   if FileExists(filename) then
      with TProcess.Create(nil) do try
           Executable := filename;
           Execute;
      finally
           Free;
           DlgTbClose.Click;
      end
   else
      ShowMessage('File not found : ' + FileName);
end;

end.
