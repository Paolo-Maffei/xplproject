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

implementation // ==============================================================
uses OpenURLUtil, frm_About;

procedure TfrmPluginDetail.FormShow(Sender: TObject);
begin
   Toolbar3.Images := frmAbout.ilStandardActions;
   edtDescription.Lines.Clear;
   edtDescription.Lines.Add(Configuration.plug_detail.description);
   edtDeviceURL.Text := Configuration.plug_detail.info_url;
   edtStableVersion.Text := Configuration.plug_detail.Version;
   edtVendor.Text        := Configuration.plug_detail.Vendor;
   edtDevice.Text        := Configuration.plug_detail.Device;
   edtPlatform.Text      := Configuration.plug_detail.platform_;
   edtBetaVersion.Text   := Configuration.plug_detail.beta_version;
   edtDownloadURL.Text   := Configuration.plug_detail.download_url;
   edtType.Text          := Configuration.plug_detail.type_;
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

