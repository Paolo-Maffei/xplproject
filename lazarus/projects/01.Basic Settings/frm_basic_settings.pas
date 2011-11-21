unit frm_basic_settings;

{$mode objfpc}{$H+}
{$R *.lfm}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, ActnList, Buttons, XMLPropStorage{%H-},
  RTTICtrls, frm_template, RxAboutDialog{%H-};

type { TfrmBasicSettings =====================================================}
     TfrmBasicSettings = class(TFrmTemplate)
        acReload: TAction;
        cbListenTo: TComboBox;
        edtListenTo: TEdit;
        e_BroadCast: TComboBox;
        e_ListenOn: TComboBox;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        acSaveSettings: TAction;
        MenuItem1: TMenuItem;
        MenuItem2: TMenuItem;
        StaticText1: TStaticText;
        StaticText2: TStaticText;
        ToolButton2: TToolButton;
        ToolButton3: TToolButton;
        procedure acReloadExecute(Sender: TObject);
        procedure acSaveSettingsExecute(Sender: TObject);
        procedure cbListenToChange(Sender: TObject);
        procedure FormCreate(Sender: TObject);
     end;

var frmBasicSettings: TfrmBasicSettings;

implementation //===============================================================
uses StrUtils
     , frm_xplappslauncher
     , u_xpl_gui_resource
     , u_xpl_application
     , u_xpl_common
     ;

//==============================================================================
const K_ALL_IPS_JOCKER       = '*** ALL IP Addresses ***';
      K_IP_GENERAL_BROADCAST : string = '255.255.255.255';
      COMMENT_LINE           = 'Your network settings have been saved.'#10#13+
                               #10#13'Note that your computer should use a fixed IP Address'#10#13;

//==============================================================================
function MakeBroadCast(const aAddress : string) : string;                      // transforms a.b.c.d in a.b.c.255
begin
   result := LeftStr(aAddress,LastDelimiter('.',aAddress)) + '255';
end;

// TFrmMain Object =============================================================
procedure TfrmBasicSettings.FormCreate(Sender: TObject);
begin
   inherited;
   acReloadExecute(self);
end;

procedure TfrmBasicSettings.acReloadExecute(Sender: TObject);
var address : string;

begin
   e_ListenOn.Items.Assign(LocalAddresses);

   e_BroadCast.Items.Clear;
   e_BroadCast.Items.Add(K_IP_GENERAL_BROADCAST);

   for address in e_ListenOn.Items do e_BroadCast.Items.Add( MakeBroadCast ( address ));

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

end.

