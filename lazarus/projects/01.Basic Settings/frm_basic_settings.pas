unit frm_basic_settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, ActnList, RTTICtrls, frm_template;

type { TfrmBasicSettings =====================================================}
     TfrmBasicSettings = class(TFrmTemplate)
        acReload: TAction;
        ActionList2: TActionList;
        cbListenTo: TComboBox;
        edtListenTo: TEdit;
        e_BroadCast: TComboBox;
        e_ListenOn: TComboBox;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        acSaveSettings: TAction;
        StaticText1: TStaticText;
        StaticText2: TStaticText;
        tbReload: TToolButton;
        tbSave: TToolButton;
        procedure acReloadExecute(Sender: TObject);
        procedure acSaveSettingsExecute(Sender: TObject);
        procedure FormCreate(Sender: TObject);
     end;

var frmBasicSettings: TfrmBasicSettings;

implementation //===============================================================
uses StrUtils
     , frm_about
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
      ERROR_LINE             = 'You do not have enough rights to write in the registry';

//==============================================================================
function MakeBroadCast(aAddress : string) : string;                             // transforms a.b.c.d in a.b.c.255
begin
   result := LeftStr(aAddress,LastDelimiter('.',aAddress)) + '255';
end;

{ TFrmMain Object =============================================================}
procedure TfrmBasicSettings.FormCreate(Sender: TObject);
begin
   inherited;
   lblModuleName.Visible := false;                                             // These controls, inherited from frm_template
   StatusBar1.Visible    := false;                                             // has no meaning for this app
   acReloadExecute(self);
end;

procedure TfrmBasicSettings.acReloadExecute(Sender: TObject);
var ch : string;
begin
   e_ListenOn.Items.Assign(LocalAddresses);                                     // This procedure also retrieves IPv6
   //i := e_ListenOn.Items.Count-1;                                               // Addresses, then I have to clean
   //while (i>=0) do begin                                                        // the list to present only IPv4 addresses
   //   if not IsIP(e_ListenOn.Items[i]) then e_ListenOn.Items.Delete(i);
   //   dec(i);
   //end;

   e_BroadCast.Items.Clear;
   e_BroadCast.Items.Add(K_IP_GENERAL_BROADCAST);

   for ch in e_ListenOn.Items do e_BroadCast.Items.Add( MakeBroadCast ( ch ));

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
   end;
end;

procedure TfrmBasicSettings.acSaveSettingsExecute(Sender: TObject);
begin
   with xPLApplication.Settings do begin
        BroadCastAddress := e_BroadCast.text;
        if RightsError then begin
              xPLApplication.Log(etWarning,ERROR_LINE);
              acReloadExecute(self);
           end else begin
                ListenOnAll := (e_ListenOn.Text = K_ALL_IPS_JOCKER);
                if not ListenOnAll then ListenOnAddress := e_ListenOn.Text;

                case cbListenTo.ItemIndex of
                     0 : ListenToAny := true;
                     1 : ListenToLocal := true;
                     2 : ListenToAddresses := edtListenTo.Text;
                end;

                Application.MessageBox(COMMENT_LINE,'Information',0);
           end;
   end;
end;

initialization // =============================================================
  {$I frm_basic_settings.lrs}

end.

