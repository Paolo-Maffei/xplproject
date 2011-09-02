unit frm_plugindetail; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Buttons, StdCtrls, ActnList, ovcurl, u_xml_plugins, Dlg_Template;

type

  { TfrmPluginDetail }

  TfrmPluginDetail = class(TDlgTemplate)
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
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    edtDeviceDescription: TMemo;
    DeviceInfoURL: TOvcURL;
    DeviceDownloadURL: TOvcURL;
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    Configuration : TDeviceType;
  end; 

Procedure ShowFrmPluginDetail(aConfiguration : TDeviceType);

implementation // ==============================================================
uses u_xpl_gui_resource
     ;

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
   inherited;

   edtDeviceBetaVersion.Text    := Configuration.beta_version;
   edtDeviceDescription.Text    := Configuration.Description;
   edtDevicePlatform.Text       := Configuration.platform_;
   edtDeviceStableVersion.Text  := Configuration.Version;
   edtDeviceType_.Text          := Configuration.type_;
   edtDeviceId.Text             := Configuration.Device;
   edtVendor.Text               := Configuration.Vendor;
   DeviceInfoURL.URL            := Configuration.info_url;
   DeviceDownloadURL.URL        := Configuration.download_url;
end;

initialization
  {$I frm_plugindetail.lrs}

end.

