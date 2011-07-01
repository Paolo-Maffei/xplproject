unit frm_plugindetail; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Buttons, StdCtrls, u_xml_plugins;

type

  { TfrmPluginDetail }

  TfrmPluginDetail = class(TForm)
    DBText1: TLabel;
    DBText2: TLabel;
    edtVendor: TEdit;
    edtDeviceId: TEdit;
    edtDevicePlatform: TEdit;
    edtDeviceStableVersion: TEdit;
    edtDeviceBetaVersion: TEdit;
    edtDeviceType_: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    edtDeviceDownloadURL: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edtDeviceInfoURL: TLabel;
    Label9: TLabel;
    edtDeviceDescription: TMemo;
    tbOk2: TToolButton;
    ToolBar: TToolBar;
    procedure edtDeviceDownloadURLClick(Sender: TObject);
    procedure edtDeviceInfoURLClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbOk2Click(Sender: TObject);
  private
    { private declarations }
  public
    Configuration : TDeviceType;
  end; 

Procedure ShowFrmPluginDetail(aConfiguration : TDeviceType);

implementation // ==============================================================
uses OpenURLUtil,
     u_xpl_gui_resource;

var  frmPluginDetail: TfrmPluginDetail;

// =============================================================================

procedure ShowFrmPluginDetail(aConfiguration: TDeviceType);
begin
   if not Assigned(frmPluginDetail) then
      Application.CreateForm(TfrmPluginDetail, frmPluginDetail);
   frmPluginDetail.Configuration := aConfiguration;
   frmPluginDetail.ShowModal;
end;

// =============================================================================

procedure TfrmPluginDetail.FormShow(Sender: TObject);
begin
   Toolbar.Images := xPLGUIResource.Images;
   edtDeviceBetaVersion.Text    := Configuration.beta_version;
   edtDeviceDescription.Text    := Configuration.Description;
   edtDeviceInfoURL.Caption     := Configuration.info_url;
   edtDeviceDownloadURL.Caption := Configuration.download_url;
   edtDevicePlatform.Text       := Configuration.platform_;
   edtDeviceStableVersion.Text  := Configuration.Version;
   edtDeviceType_.Text          := Configuration.type_;
   edtDeviceId.Text             := Configuration.Device;
   edtVendor.Text               := Configuration.Vendor;
end;

procedure TfrmPluginDetail.tbOk2Click(Sender: TObject);
begin
   Close;
end;

procedure TfrmPluginDetail.edtDeviceInfoURLClick(Sender: TObject);
begin
   OpenURL(edtDeviceInfoURL.Caption);
end;

procedure TfrmPluginDetail.edtDeviceDownloadURLClick(Sender: TObject);
begin
   OpenURL(edtDeviceDownloadURL.Caption);
end;

initialization
  {$I frm_plugindetail.lrs}

end.

