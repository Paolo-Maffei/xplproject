unit frm_xplTimer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Buttons, StdCtrls, ExtCtrls, RTTICtrls, RTTIGrids,
  u_xpl_timer;

type

{ TfrmxPLTimer }

    TfrmxPLTimer = class(TForm)
      Label1: TLabel;
      lblMode: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Label5: TLabel;
        Label6: TLabel;
        sbOk: TSpeedButton;
        tiStart: TTILabel;
        tiStatus: TTIComboBox;
        tiMode: TTIComboBox;
        tiName: TTIEdit;
        tiDuration: TTISpinEdit;
        tiFrequence: TTISpinEdit;
        ToolBar2: TToolBar;
        procedure FormShow(Sender: TObject);
        procedure sbOkClick(Sender: TObject);
        procedure tiModeChange(Sender: TObject);
      private
        Timer : TxPLTimer;
     end;

    function ShowFrmxPLTimer(const aTimer : TxPLTImer) : boolean;


implementation { TxPLTimer ====================================================}

function ShowFrmxPLTimer(const aTimer: TxPLTImer) : boolean;
var form : TFrmxPLTimer;
begin
   form := TFrmxPLTimer.Create(nil);
   form.Timer := aTimer;
   result := form.ShowModal = mrOk;
   form.Destroy;
end;

{ TfrmxPLTimer ================================================================}
procedure TfrmxPLTimer.FormShow(Sender: TObject);
begin
   tiName.Link.TIObject := Timer;
   tiDuration.Link.TIObject := Timer;
   tiFrequence.Link.TIObject := Timer;
   tiMode.Link.TIObject := Timer;
   tiStatus.Link.TIObject := Timer;
   tiName.Link.TIPropertyName:='displayname';
   tiduration.link.tipropertyname := 'remaining';
   tifrequence.link.tipropertyname := 'frequence';
   tiStatus.link.tipropertyname := 'status';
   timode.link.tipropertyname := 'mode';
   tiStart.link.tiObject := Timer;
   tiStart.Link.tipropertyname := 'start_time';
   tiModeChange(self);
end;

procedure TfrmxPLTimer.sbOkClick(Sender: TObject);
begin
   Close;
   ModalResult := mrOk;
end;

procedure TfrmxPLTimer.tiModeChange(Sender: TObject);
begin
   tiFrequence.Enabled := (tiMode.Text = 'recurrent');
   tiDuration.Enabled  := (tiMode.Text = 'descending');
end;

initialization
 {$I frm_xpltimer.lrs}

end.

