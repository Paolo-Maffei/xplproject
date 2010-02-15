unit frm_networksettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, XMLPropStorage, ExtCtrls, StdCtrls,  Buttons;

type

{ TfrmNetworkSettings }

TfrmNetworkSettings = class(TForm)
  BtnShowDirSelect: TButton;
  edtRootDir: TEdit;
        edtListenTo: TEdit;
        e_BroadCast: TComboBox;
        e_ListenOn: TComboBox;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        rgListenTo: TRadioGroup;
        SelectDirectoryDialog1: TSelectDirectoryDialog;
        StaticText1: TStaticText;
        StaticText2: TStaticText;
        tbOk: TToolButton;
        ToolBar3: TToolBar;
        tbReload: TToolButton;
        ToolButton2: TToolButton;
        ToolButton3: TToolButton;
        tbSave: TToolButton;
        XMLPropStorage: TXMLPropStorage;
        procedure BtnSaveSettingsClick(Sender: TObject);
        procedure BtnShowDirSelectClick(Sender: TObject);
        procedure e_ListenOnChange(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure tbOkClick(Sender: TObject);
        procedure tbReloadClick(Sender: TObject);
     end;

var frmNetworkSettings: TfrmNetworkSettings;

implementation //===============================================================
uses IdStack, frm_Main, uxPLConst, StrUtils, uIPUtils;

//==============================================================================
resourcestring
     K_ALL_IPS_JOCKER       = '*** ALL IP Address ***';
     COMMENT_LINE_1         = 'Your network settings have been saved.'#10#13'Your xPL applications may need to be restarted (including xPL Hub) for changes to take effect.';
     COMMENT_LINE_2         = 'xPL network settings updated';

{ TFrmNetworkSettings Form =====================================================}
procedure TfrmNetworkSettings.tbOkClick(Sender: TObject);
begin Close; end;

procedure TfrmNetworkSettings.e_ListenOnChange(Sender: TObject);                 // Called by all editables fields to toggle
begin tbSave.Enabled:=True; end;                                                 // save button 'on'


procedure TfrmNetworkSettings.FormShow(Sender: TObject);                         // Fills all fields with potential values
var i : integer;
begin
   e_ListenOn.Items.CommaText:= gStack.LocalAddress;                             // If using inet : LocalIP of uIPutils unit
   e_ListenOn.Items.Insert(0,K_ALL_IPS_JOCKER);

   e_BroadCast.Items.Clear;
   e_BroadCast.Items.Add(K_IP_BROADCAST);
   for i:=1 to e_ListenOn.Items.Count-1 do e_BroadCast.Items.Add( MakeBroadCast( e_ListenOn.Items[i]));

   tbReloadClick(self);                                                          // Loads current active values stored in registry
end;

procedure TfrmNetworkSettings.tbReloadClick(Sender: TObject);
begin
   with frmMain.xPLClient.Setting do begin
      e_BroadCast.Text := BroadCastAddress;
      e_ListenOn.Text  := IfThen(ListenOnAll, K_ALL_IPS_JOCKER, ListenOnAddress);

      edtListenTo.Text := '';
      if ListenToAny then
         rgListenTo.ItemIndex := 0
      else
         if ListenToLocal then
            rgListenTo.ItemIndex := 1
         else begin
            rgListenTo.ItemIndex := 2;
            edtListenTo.Text := ListenToAddresses;
         end;
      edtRootDir.Text:= SharedConfigDir;
      tbSave.Enabled := False;                                                   // Will only be enabled if a field changes of value
   end;
end;


procedure TfrmNetworkSettings.BtnSaveSettingsClick(Sender: TObject);
begin
   with frmMain.xPLClient.Setting do begin
        BroadCastAddress := e_BroadCast.text;

        ListenOnAll := (e_ListenOn.Text = K_ALL_IPS_JOCKER);
        if not ListenOnAll then ListenOnAddress := e_ListenOn.Text;

        case rgListenTo.ItemIndex of
           0 : ListenToAny := true;
           1 : ListenToLocal := true;
           2 : ListenToAddresses := edtListenTo.Text;
        end;

        SharedConfigDir := edtRootDir.Text;

        Application.MessageBox(PChar(COMMENT_LINE_1),PChar(caption),0);
        frmMain.xPLClient.LogInfo(COMMENT_LINE_2);
   end;
end;

procedure TfrmNetworkSettings.BtnShowDirSelectClick(Sender: TObject);
begin
   if SelectDirectoryDialog1.Execute then edtRootDir.Text := SelectDirectoryDialog1.FileName;
end;

initialization
  {$I frm_networksettings.lrs}

end.

