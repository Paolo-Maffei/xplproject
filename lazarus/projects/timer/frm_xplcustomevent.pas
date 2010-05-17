unit frm_xPLCustomEvent;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Buttons, StdCtrls, DbCtrls, EditBtn,   uControls;

type

{ TfrmxPLCustomEvent }

TfrmxPLCustomEvent = class(TForm)
  BtnDisplay: TButton;
        CheckBox1: TCheckBox;
        ckPerso: TCheckBox;
        Edit1: TEdit;
        edtName: TEdit;
        Label5: TLabel;
        Label3: TLabel;
        mmoDescription: TMemo;
        PageControl1: TPageControl;
        sbOk: TSpeedButton;
        sbCancel: TSpeedButton;
        tsStandardProp: TTabSheet;
        tsAdvancedProp: TTabSheet;
        ToolBar2: TToolBar;
        TimePanel: TxPLTimePanel;
        procedure BtnDisplayClick(Sender: TObject);
        procedure ckPersoChange(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure sbCancelClick(Sender: TObject);
        procedure sbOkClick(Sender: TObject);
        function ValidateFields : boolean;                 virtual;
        procedure SaveObject;                              virtual;
        procedure LoadObject;                              virtual;
     end;

implementation { TfrmxPLCustomEvent ===========================================}
uses uxPLEvent, uxPLMessage;

procedure TfrmxPLCustomEvent.BtnDisplayClick(Sender: TObject);
var aMessage : TxPLMessage;
begin
   if edit1.Text <>'' then begin
      aMessage := TxPLMessage.Create(edit1.Text);
      aMessage.Edit;
      aMessage.Destroy ;
   end;
end;

procedure TfrmxPLCustomEvent.ckPersoChange(Sender: TObject);
var aMessage : TxPLMessage;
begin
   aMessage := TxPLMessage.Create;
   if edit1.caption = '' then begin
      if aMessage.SelectFile then begin
         edit1.caption := aMessage.RawXPL;
         aMessage.Edit;
      end;
      aMessage.Destroy;
   end;
end;

procedure TfrmxPLCustomEvent.sbCancelClick(Sender: TObject);
begin
   Close;
   ModalResult := mrCancel;
end;

procedure TfrmxPLCustomEvent.sbOkClick(Sender: TObject);
begin
   if ValidateFields then begin
      SaveObject;
      Close;
      ModalResult := mrOk;
   end;
end;

function TfrmxPLCustomEvent.ValidateFields: boolean;
begin
   result := length(edtname.text)>0;
end;

procedure TfrmxPLCustomEvent.SaveObject;
begin
   with Self.Owner as TxPLSingleEvent do begin
      Name := edtName.Text;
      Enabled := checkbox1.Checked;
      if ckPerso.Checked then MessageToFire := edit1.Text
                         else MessageToFire := '';
      Description := mmoDescription.Text;
   end;
end;

procedure TfrmxPLCustomEvent.LoadObject;
begin
   with Self.Owner as TxPLSingleEvent do begin
      edtName.Text := Name;
      checkbox1.Checked := Enabled;
      edit1.Caption := MessageToFire;
      ckPerso.Checked := length(edit1.Caption)>0;
      mmoDescription.Text := Description;
   end;
end;

procedure TfrmxPLCustomEvent.FormShow(Sender: TObject);
begin
   LoadObject;
   PageControl1.ActivePage := tsStandardProp;
end;

initialization
  {$I frm_xplcustomevent.lrs}

end.

