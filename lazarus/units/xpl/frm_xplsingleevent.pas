unit frm_xPLSingleEvent;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Buttons, StdCtrls, Calendar, DbCtrls, EditBtn, jdcalendar,frm_xPLCustomEvent;

type

    { TfrmxPLSingleEvent }

    TfrmxPLSingleEvent = class(TfrmxPLCustomEvent)
        Calendar1: TCalendar;
        Label4: TLabel;

        function ValidateFields : boolean;         override;
        procedure SaveObject;                      override;
        procedure LoadObject;                      override;
     end;

implementation { TfrmxPLSingleEvent ===========================================}
uses uxPLSingleEvent;

function TfrmxPLSingleEvent.ValidateFields: boolean;
begin
  Result:=inherited ValidateFields and
          ((calendar1.datetime + TimePanel.time) > now)
end;

procedure TfrmxPLSingleEvent.SaveObject;
begin
  inherited SaveObject;
  with Self.Owner as TxPLSingleEvent do begin
       Next := calendar1.datetime + TimePanel.Time;
       Description := mmoDescription.Text;
  end;
end;

procedure TfrmxPLSingleEvent.LoadObject;
begin
  inherited LoadObject;
  with Self.Owner as TxPLSingleEvent do begin
       timepanel.time := next;
       calendar1.datetime := Next;
  end;
end;

initialization
  {$I frm_xplsingleevent.lrs}

end.

