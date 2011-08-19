unit frm_xplappslauncher;
{==============================================================================
  UnitName      = frm_xplappslauncher
  UnitDesc      = Standard xPL / Lazarus About box - shared by all projects
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 1.0 : Added code to avoid presenting myself in the list of applications to launch
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, ComCtrls, ActnList, Buttons;

type

  { TfrmAppLauncher }

  TfrmAppLauncher = class(TForm)
    acClose: TAction;
    acLaunch: TAction;
    ActionList: TActionList;
    lvApps: TListView;
    tbClose: TToolButton;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure acCloseExecute(Sender: TObject);
    procedure acLaunchExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvAppsDblClick(Sender: TObject);
  end;

  procedure ShowFrmAppLauncher;

var frmAppLauncher: TfrmAppLauncher;

implementation { =====================================================================}
uses Process
     , u_xpl_address
     , u_xpl_application
     , u_xpl_gui_resource
     , u_xpl_collection
     ;

procedure ShowFrmAppLauncher;
begin
   if not Assigned(frmAppLauncher) then
      Application.CreateForm(TFrmAppLauncher, frmAppLauncher);
   frmAppLauncher.ShowModal;
end;

// Form procedures ============================================================
procedure TfrmAppLauncher.FormShow(Sender: TObject);
var sl : TxPLCustomCollection;
    path, version, nicename : string;
    i : integer;
begin
   Toolbar.Images := xPLGUIResource.Images;
   lvApps.Items.Clear;
   sl  := xPLApplication.Settings.GetxPLAppList;
   for i := 0 to sl.Count -1 do begin
       xPLApplication.Settings.GetAppDetail(sl.Items[i].Value,sl.Items[i].DisplayName,path,version, nicename);
       if path <> Application.ExeName then with lvApps.Items.Add do begin     // Avoid presenting myself in the app list
            Caption := NiceName; //sl[i].DisplayName;
            SubItems.DelimitedText:= Sl[i].Value + ',' + version + ',' + path;
       end;
   end;
   sl.Free;
end;

procedure TfrmAppLauncher.acLaunchExecute(Sender: TObject);
begin
   if lvApps.Selected = nil then exit;

   with TProcess.Create(nil) do try
      Executable := lvApps.Selected.SubItems[2];
      Execute;
   finally
      Free;
   end;
end;

procedure TfrmAppLauncher.acCloseExecute(Sender: TObject);
begin
   Close;
end;

procedure TfrmAppLauncher.lvAppsDblClick(Sender: TObject);
begin
   acLaunchExecute(self);
   acCloseExecute(sender);
end;


initialization
   {$I frm_xplappslauncher.lrs}

end.

