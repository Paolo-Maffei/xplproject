unit frm_xPLRecurEvent;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Buttons, StdCtrls, DbCtrls, EditBtn,
  ExtCtrls, CheckLst, Spin, frm_xPLSingleEvent, uControls;

type

{ TfrmxPLRecurEvent }

TfrmxPLRecurEvent = class(TfrmxPLSingleEvent)
        btnWorkDays: TButton;
        btnWeekEnd: TButton;
        BtnAllWeek: TButton;
        ckWeekMap: TCheckListBox;
        ckAllDay: TCheckBox;
        intervallabel: TLabel;
        Label7: TLabel;
        Label8: TLabel;
        TabBook: TNotebook;
        pgDay: TPage;
        pgWeek: TPage;
        randomlabel: TLabel;
        Label2: TLabel;
        Label6: TLabel;
    lblRepeat: TLabel;
    leDayRecurrence: TSpinEdit;
    rbDaily: TRadioButton;
    rbWeekly: TRadioButton;
    RadioGroup1: TRadioGroup;
    leInterval: TSpinEdit;
    leRandomize: TSpinEdit;
    EndTimePanel: TxPLTimePanel;
    procedure BtnAllWeekClick(Sender: TObject);
    procedure btnWeekEndClick(Sender: TObject);
    procedure btnWorkDaysClick(Sender: TObject);
    procedure ckAllDayClick(Sender: TObject);
    procedure leIntervalChange(Sender: TObject);
    procedure leRandomizeChange(Sender: TObject);
    procedure rbDailyChange(Sender: TObject);

   function ValidateFields : boolean;         override;
   procedure SaveObject;                      override;
   procedure LoadObject;                      override;
  end;

implementation { TfrmxPLRecurEvent ============================================}
uses DateUtils, cRandom, uxPLEvent;
{==============================================================================}

procedure TfrmxPLRecurEvent.leIntervalChange(Sender: TObject);
begin
 //  leRandomize.MaxValue := leInterval.Value div 2 - 1;
   intervallabel.Caption := 'seconds (' + IntToStr((StrToInt(leInterval.Text) div 60)) + ' minutes)';  // FS#27
end;

procedure TfrmxPLRecurEvent.leRandomizeChange(Sender: TObject);
begin
   randomlabel.Caption := 'seconds (' + IntToStr((StrToInt(leRandomize.Text) div 60)) + ' minutes)';   // FS#27
end;

procedure TfrmxPLRecurEvent.rbDailyChange(Sender: TObject);
begin
  if rbDaily.Checked then begin
     tabBook.ActivePage := 'pgDay';
     lblRepeat.Caption := 'day';
  end;
  if rbWeekly.Checked then begin
     tabBook.ActivePage := 'pgWeek';
     lblRepeat.Caption := 'week';
  end;
end;

procedure TfrmxPLRecurEvent.ckAllDayClick(Sender: TObject);
begin
  if ckAllDay.Checked then begin
    timepanel.time := 0;
    EndTimePanel.Time   := RecodeTime(EndTimePanel.Time,23,59,59,0);
  end;
  timepanel.Enabled := not ckAllDay.Checked;
  EndTimePanel.Enabled := timepanel.Enabled;
end;

procedure TfrmxPLRecurEvent.btnWorkDaysClick(Sender: TObject);
var i : integer;
begin
     for i := 0 to 4 do ckWeekMap.Checked[i] := true;
     for i := 5 to 6 do ckWeekMap.Checked[i] := false;
end;

procedure TfrmxPLRecurEvent.btnWeekEndClick(Sender: TObject);
var i : integer;
begin
     for i := 0 to 4 do ckWeekMap.Checked[i] := false;
     for i := 5 to 6 do ckWeekMap.Checked[i] := true;
end;

procedure TfrmxPLRecurEvent.BtnAllWeekClick(Sender: TObject);
var i : integer;
begin
     for i := 0 to 6 do ckWeekMap.Checked[i] := true;
end;

function TfrmxPLRecurEvent.ValidateFields: boolean;
begin
   result := length(edtname.text)>0;
end;

procedure TfrmxPLRecurEvent.SaveObject;
var i : integer;
begin
  inherited SaveObject;
  with Self.Owner as TxPLRecurEvent do begin
     if rbDaily.Checked   then RecurrenceType := er_Daily;
     if rbWeekly.Checked  then RecurrenceType := er_Weekly;
     DayRecurrence := leDayRecurrence.Value;
     Random        := leRandomize.Value;
     Interval      := leInterval.Value;

     StartInDay := TimePanel.time;
     StopInDay  := EndTimePanel.Time;

     for i:=1 to 7 do if ckWeekMap.Checked[i-1] then WeekMap[i]:='1' else WeekMap[i]:='0';
     if WeekMap='0000000' then WeekMap:='1111111'; // Must not be empty
   end;
end;

procedure TfrmxPLRecurEvent.LoadObject;
var i : integer;
begin
  inherited LoadObject;
  // We assume that my owner is an Event
  with Self.Owner as TxPLRecurEvent do begin
       TimePanel.Time :=  StartInDay;
       EndTimePanel.Time   :=  StopInDay;
       leDayRecurrence.Value := DayRecurrence;
       leRandomize.Value := Random;
       leInterval.Value  := Interval;
       case RecurrenceType of
            er_Daily   : rbDaily.Checked := True;
            er_Weekly  : rbWeekly.Checked := True;
       end;
       For i:=1 to 7 do ckWeekMap.Checked[i-1] := (WeekMap[i] = '1');

       rbDailyChange(self);
   end;
   leRandomizeChange(nil);                                                                          // FS#27
   leIntervalChange(nil);                                                                           // FS#27
end;

initialization
  {$I frm_xplRecurEvent.lrs}

end.

