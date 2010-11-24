unit u_xpl_event_gui;

{$mode objfpc}{$H+}

interface

uses Classes,
     SysUtils,
     uxPLEvent;

type TxPLSingleEventGUI = class(TxPLSingleEvent)
           function  Edit : boolean;     dynamic;
     end;

     TxPLRecurEventGUI = class(TxPLRecurEvent)
           function  Edit : boolean;     dynamic;
     end;

implementation // ==============================================================
uses Controls,
     frm_xPLRecurEvent,
     frm_xPLSingleEvent;

function TxPLSingleEventGUI.Edit: boolean;
var aForm : TfrmxPLSingleEvent;
begin
     aForm := TfrmxPLSingleEvent.Create(self);
     result := (aForm.ShowModal = mrOk);
     if result then WriteToXML;
     aForm.Destroy;
end;

function TxPLRecurEventGUI.Edit: boolean;
var aForm : TfrmxPLRecurEvent;
begin
     aForm := TfrmxPLRecurEvent.Create(self);
     result := (aForm.ShowModal = mrOk);
     if result then WriteToXML;
     if result then begin
        Next := 0;                                                                        // FS#27 Reset next run time to force recompute
        Check(false);                                                                     // FS#29 False added to avoid launch of the event when creating it
     end;
     aForm.Destroy;
end;

end.

