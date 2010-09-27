unit frm_xplappslauncher;

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
uses app_main, Process, cStrings, uxPLAdress;

procedure TfrmAppLauncher.FormCreate(Sender: TObject);
var sl : TStringList;
    vendor, device, path, version : string;
    i : integer;
begin
     sl := xPLClient.Settings.GetxPLAppList;
     for i := 0 to sl.Count -1 do
        with lvApps.Items.Add do begin
//           StrSplitAtChar(sl[i],'-',vendor,device,false);
           xPLAdress.SplitVD(sl[i],vendor,device);
           xPLClient.Settings.GetAppDetail(vendor,device,path,version);
           Caption := device;
           SubItems.Add(vendor);
           SubItems.Add(version);
           SubItems.Add(path);
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
var AProcess: TProcess;
begin
     if lvApps.Selected = nil then exit;

     AProcess := TProcess.Create(nil);
     AProcess.CommandLine := lvApps.Selected.SubItems[2];
     AProcess.Execute;
     AProcess.Free;
end;

initialization
  {$I frm_xplappslauncher.lrs}

end.

