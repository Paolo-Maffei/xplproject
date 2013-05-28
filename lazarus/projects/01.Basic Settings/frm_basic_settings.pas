unit frm_basic_settings;

{$mode objfpc}{$H+}
{$R *.lfm}

interface

uses Classes, SysUtils, RTTICtrls, LSControls, LResources, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ComCtrls, Menus, ActnList,
  Buttons, frm_template;

type { TfrmBasicSettings =====================================================}
     TfrmBasicSettings = class(TFrmTemplate)
        btnSave: TLSBitBtn;
        FrmAcSave: TAction;
        FrmAcReload: TAction;
        cbListenTo: TComboBox;
        edtListenTo: TEdit;
        e_BroadCast: TComboBox;
        e_ListenOn: TComboBox;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        MenuItem1: TMenuItem;
        MenuItem2: TMenuItem;
        StaticText1: TStaticText;
        StaticText2: TStaticText;
        ToolButton2: TToolButton;
        ToolButton3: TToolButton;
        procedure acReloadExecute(Sender: TObject);
        procedure acSaveSettingsExecute(Sender: TObject);
        procedure cbListenToChange(Sender: TObject);
        procedure e_ListenOnChange(Sender: TObject);
        procedure FormCreate(Sender: TObject);
     end;

var frmBasicSettings: TfrmBasicSettings;

implementation //==============================================================
uses StrUtils
     , u_xpl_gui_resource
     , u_xpl_application
     , lin_win_compat
     , uIP
     ;

// ============================================================================

const K_ALL_IPS_JOCKER       = '*** ALL IP Addresses ***';
      COMMENT_LINE           = 'Your network settings have been saved.'#10#13+
                               #10#13'Note that your computer should use a fixed IP Address'#10#13+
                               #10#13'Linux users : changes will be available when quitting the application'#10#13;

// TFrmMain Object =============================================================
procedure TfrmBasicSettings.FormCreate(Sender: TObject);
begin
   inherited;
   FrmAcReload.ImageIndex := K_IMG_REFRESH;
   SetButtonImage(BtnSave,FrmAcSave,K_IMG_DOCUMENT_SAVE);
   acReloadExecute(self);
end;

procedure TfrmBasicSettings.acReloadExecute(Sender: TObject);
var AddObj : TIPAddress;
begin
   e_ListenOn.Items.Clear;

   e_ListenOn.Items.Clear;
   e_BroadCast.Items.Clear;
   e_BroadCast.Items.Add(K_IP_GENERAL_BROADCAST);
   for AddObj in LocalIPAddresses do begin
        e_ListenOn.Items.Add(AddObj.Address);
        e_BroadCast.Items.Add(AddObj.BroadCast);
   end;

   e_ListenOn.Items.Insert(0,K_ALL_IPS_JOCKER);

   with xPLApplication.Settings do begin
      e_BroadCast.Text := BroadCastAddress;
      e_ListenOn.Text  := IfThen(ListenOnAll, K_ALL_IPS_JOCKER, ListenOnAddress);

      edtListenTo.Text := '';
      if ListenToAny then
         cbListenTo.ItemIndex := 0
      else
         if ListenToLocal then
            cbListenTo.ItemIndex := 1
         else begin
            cbListenTo.ItemIndex := 2;
            edtListenTo.Text := ListenToAddresses;
         end;
      cbListenToChange(self);
   end;
   FrmAcSave.Enabled := false;
end;

procedure TfrmBasicSettings.acSaveSettingsExecute(Sender: TObject);
begin
   with xPLApplication.Settings do begin
        BroadCastAddress := e_BroadCast.text;
        ListenOnAll := (e_ListenOn.Text = K_ALL_IPS_JOCKER);
        if not ListenOnAll then ListenOnAddress := e_ListenOn.Text;

        case cbListenTo.ItemIndex of
             0 : ListenToAny := true;
             1 : ListenToLocal := true;
             2 : ListenToAddresses := edtListenTo.Text;
        end;
        ShowMessage(COMMENT_LINE);
        InitComponent;                                                         // Reload the xPLApplication settings
   end;
end;

procedure TfrmBasicSettings.cbListenToChange(Sender: TObject);
begin
   edtListenTo.Visible := (cbListenTo.ItemIndex = 2);
   if edtListenTo.Visible then edtListenTo.SetFocus;
end;

procedure TfrmBasicSettings.e_ListenOnChange(Sender: TObject);
var IPA  : TIPAddress;
begin
   FrmAcSave.Enabled := true;
   IPA := LocalIPAddresses.GetByIP(e_ListenOn.Text);
   if Assigned(IPA) then
      e_BroadCast.Text := IPA.BroadCast;
end;

end.
