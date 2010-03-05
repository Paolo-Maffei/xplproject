unit frm_xplappslauncher;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ActnList, Buttons, XMLPropStorage;

type

  { TfrmAppLauncher }

  TfrmAppLauncher = class(TForm)
    lvApps: TListView;
    tbLaunch: TToolButton;
    ToolBar3: TToolBar;
    XMLPropStorage: TXMLPropStorage;
    procedure FormCreate(Sender: TObject);
    procedure LaunchExecute(Sender: TObject);
    procedure lvAppsDblClick(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure tbLaunchClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var frmAppLauncher: TfrmAppLauncher;

implementation { TfrmAppLauncher ==============================================}
uses frm_main,  Process;

procedure TfrmAppLauncher.FormCreate(Sender: TObject);
var sl : TStringList;
    i : integer;
begin
     sl := frmMain.xPLClient.Setting.GetxPLAppList;
     for i := 0 to sl.Count -1 do begin
         {item := lvApps.Items.Add;
         frmMain.xPLClient.Setting.GetxPLAppDetail(sl[i],path,version);
         item.Caption := sl[i];
         item.SubItems.Add(version);
         item.SubItems.Add(path);}
     end;
end;

procedure TfrmAppLauncher.LaunchExecute(Sender: TObject);
var AProcess: TProcess;
begin
     if lvApps.Selected = nil then exit;

     AProcess := TProcess.Create(nil);
     AProcess.CommandLine := lvApps.Selected.SubItems[1];
     AProcess.Execute;
     AProcess.Free;
end;

procedure TfrmAppLauncher.lvAppsDblClick(Sender: TObject);
begin
     LaunchExecute(self);
end;

procedure TfrmAppLauncher.QuitExecute(Sender: TObject);
begin Close; end;

procedure TfrmAppLauncher.tbLaunchClick(Sender: TObject);
var AProcess: TProcess;
begin
     if lvApps.Selected = nil then exit;

     AProcess := TProcess.Create(nil);
     AProcess.CommandLine := lvApps.Selected.SubItems[1];
     AProcess.Execute;
     AProcess.Free;
end;

initialization
  {$I frm_xplappslauncher.lrs}

end.

