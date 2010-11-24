unit frm_xplTimer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Buttons, StdCtrls, ExtCtrls, Spin;

type

{ TfrmxPLTimer }

TfrmxPLTimer = class(TForm)
        cbRange: TComboBox;
        cbMode: TComboBox;
        edtName: TEdit;
        edtTarget: TEdit;
        ImageList1: TImageList;
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        Label6: TLabel;
        sbCancel: TSpeedButton;
        sbOk: TSpeedButton;
        seDuration: TSpinEdit;
        seFrequence: TSpinEdit;
        ToolBar2: TToolBar;
        procedure cbModeChange(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure sbCancelClick(Sender: TObject);
        procedure sbOkClick(Sender: TObject);
     end;


implementation { TxPLTimer ====================================================}
uses uxPLTimer,
     frm_xplactionlist;

{ TfrmxPLTimer ================================================================}
procedure TfrmxPLTimer.FormShow(Sender: TObject);
var aTimer : TxPLTimer;
begin
   aTimer := TxPLTimer(Self.Owner);
   with aTimer do begin                                        // We assume that my owner is a Timer
      edtTarget.Text := Target;
      cbRange.Text := Range;
      seDuration.Value := Remaining;
      seFrequence.Value := Frequency;
      edtName.Text := aTimer.TimerName;
      cbRange.Text := aTimer.Range;
      cbMode.Text  := aTimer.Mode;
   end;
   cbModeChange(self);
end;

procedure TfrmxPLTimer.cbModeChange(Sender: TObject);
begin
   seFrequence.Enabled := (cbMode.Text = 'recurrent');
   seDuration.Enabled  := (cbMode.Text = 'descending');
end;

procedure TfrmxPLTimer.sbCancelClick(Sender: TObject);
begin
   Close;
   ModalResult := mrCancel;
end;

procedure TfrmxPLTimer.sbOkClick(Sender: TObject);
begin
   if not seFrequence.Enabled then seFrequence.Value :=0;
   if not seDuration.Enabled then seDuration.Value :=0;

   TxPLTimer(Owner).Init(edtName.Text,edtTarget.Text,cbRange.Text,seDuration.Text ,seFrequence.Text);

   Close;
   ModalResult := mrOk;
end;

initialization
 {$I frm_xpltimer.lrs}

end.

