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
    lvApps: TListView;
    tbLaunch: TToolButton;
    ToolBar3: TToolBar;
    procedure FormCreate(Sender: TObject);
    procedure lvAppsDblClick(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure tbLaunchClick(Sender: TObject);
  end;

var frmAppLauncher: TfrmAppLauncher;

implementation { =====================================================================}
uses app_main, Process, uxPLAddress;

procedure TfrmAppLauncher.FormCreate(Sender: TObject);
var sl : TStringList;
    vendor, device, path, version : string;
    i : integer;
begin
     sl := xPLClient.Settings.GetxPLAppList;
     for i := 0 to sl.Count -1 do begin
        TxPLAddress.SplitVD(sl[i],vendor,device);
        if device<>xPLClient.Device then with lvApps.Items.Add do begin
              xPLClient.Settings.GetAppDetail(vendor,device,path,version);
              Caption := device;
              SubItems.Add(vendor);
              SubItems.Add(version);
              SubItems.Add(path);
        end;
     end;
end;

procedure TfrmAppLauncher.lvAppsDblClick(Sender: TObject);
begin
   tbLaunchClick(self);
   QuitExecute(sender);
end;

procedure TfrmAppLauncher.QuitExecute(Sender: TObject);
begin Close; end;

procedure TfrmAppLauncher.tbLaunchClick(Sender: TObject);
begin
   if lvApps.Selected = nil then exit;

   with TProcess.Create(nil) do try
      CommandLine := lvApps.Selected.SubItems[2];
      Execute;
   finally
      Free;
   end;
end;

initialization
   {$I frm_xplappslauncher.lrs}

end.

