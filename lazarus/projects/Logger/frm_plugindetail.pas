unit frm_plugindetail; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Buttons, StdCtrls, frm_main;

type

  { TfrmPluginDetail }

  TfrmPluginDetail = class(TForm)
    edtVendor: TEdit;
    edtDevice: TEdit;
    edtType: TEdit;
    edtPlatform: TEdit;
    edtStableVersion: TEdit;
    edtBetaVersion: TEdit;
    edtDeviceURL: TEdit;
    edtDownloadURL: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    edtDescription: TMemo;
    tbOk2: TToolButton;
    ToolBar3: TToolBar;
    ToolButton2: TToolButton;
    procedure edtDeviceURLClick(Sender: TObject);
    procedure edtDownloadURLClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbOk2Click(Sender: TObject);
  private
    { private declarations }
  public
    Configuration : TConfigurationRecord;
  end; 

var
  frmPluginDetail: TfrmPluginDetail;

implementation
uses OpenURLUtil;

{ TfrmPluginDetail }

procedure TfrmPluginDetail.FormShow(Sender: TObject);
begin
     edtDescription.Lines.Clear;
     edtDescription.Lines.Add(Configuration.plug_detail.description);
     edtDeviceURL.Text := Configuration.plug_detail.InfoURL;
     edtStableVersion.Text := Configuration.plug_detail.Version;
     edtVendor.Text        := Configuration.plug_detail.VendorTag;
     edtDevice.Text        := Configuration.plug_detail.Name;
     edtPlatform.Text      := Configuration.plug_detail.Platforme;
     edtBetaVersion.Text   := Configuration.plug_detail.BetaVersion;
     edtDownloadURL.Text   := Configuration.plug_detail.DownloadURL;
     edtType.Text          := Configuration.plug_detail.AppType;
end;

procedure TfrmPluginDetail.tbOk2Click(Sender: TObject);
begin
   Close;
end;

procedure TfrmPluginDetail.edtDeviceURLClick(Sender: TObject);
begin
   OpenURL(edtDeviceURL.Text);
end;

procedure TfrmPluginDetail.edtDownloadURLClick(Sender: TObject);
begin
   OpenURL(edtDownloadURL.Text);
end;

initialization
  {$I frm_plugindetail.lrs}

end.

