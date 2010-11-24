unit frm_xPLCustomEvent;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Buttons, StdCtrls, DbCtrls, EditBtn,   uControls;

type

{ TfrmxPLCustomEvent }

TfrmxPLCustomEvent = class(TForm)
  btnActionList: TButton;
        CheckBox1: TCheckBox;
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
        procedure btnActionListClick(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure sbCancelClick(Sender: TObject);
        procedure sbOkClick(Sender: TObject);
        function ValidateFields : boolean;                 virtual;
        procedure SaveObject;                              virtual;
        procedure LoadObject;                              virtual;
     end;

implementation { TfrmxPLCustomEvent ===========================================}
uses uxPLEvent,
     u_xpl_message_gui,
     frm_xplactionlist;

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
      Description := mmoDescription.Text;
   end;
end;

procedure TfrmxPLCustomEvent.LoadObject;
begin
   with Self.Owner as TxPLSingleEvent do begin
      edtName.Text := Name;
      checkbox1.Checked := Enabled;
      mmoDescription.Text := Description;
   end;
end;

procedure TfrmxPLCustomEvent.FormShow(Sender: TObject);
begin
   LoadObject;
   PageControl1.ActivePage := tsStandardProp;
end;

procedure TfrmxPLCustomEvent.btnActionListClick(Sender: TObject);
begin
   frmActionList.Actions := TxPLSingleEvent(Owner).ActionList;
   frmActionList.ShowModal;
end;

initialization
  {$I frm_xplcustomevent.lrs}

end.

