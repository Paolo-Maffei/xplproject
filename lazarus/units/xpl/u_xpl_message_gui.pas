unit u_xpl_message_GUI;
{==============================================================================
  UnitName      = u_xpl_message_GUI
  UnitVersion   = 0.91
  UnitDesc      = xPL Message GUI management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Forked from version 0.96 of uxplmessage, handling all user interface
        functions
 }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uxPLMessage;

type
  TButtonOption = (
                boLoad,
                boSave,
                boCopy,
                boSend);
  TButtonOptions = set of TButtonOption;

     TxPLMessageGUI = class(TxPLMessage)
     public
        function    Edit : boolean;     dynamic;
        procedure   Show(options : TButtonOptions);
        procedure   ShowForEdit(options : TButtonOptions);
        function    SelectFile : boolean;
     end;

implementation { ==============================================================}
uses frm_xPLMessage,
     v_xplmsg_opendialog,
     Controls;



procedure TxPLMessageGUI.ShowForEdit(options : TButtonOptions);
var aForm : TfrmxPLMessage;
begin
     aForm := TfrmxPLMessage.Create(self);
     aForm.buttonOptions := options;
     aForm.mmoMessage.ReadOnly := false;
     aForm.Show;
end;

function TxPLMessageGUI.Edit : boolean;
var aForm : TfrmxPLMessage;
begin
    aForm := TfrmxPLMessage.Create(self);
    result := (aForm.ShowModal = mrOk);
    aForm.Destroy;
end;

procedure TxPLMessageGUI.Show(options : TButtonOptions);
var aForm : TfrmxPLMessage;
begin
    aForm := TfrmxPLMessage.Create(self);
    aForm.buttonOptions := options;
    aForm.Show;
end;

function TxPLMessageGUI.SelectFile: boolean;
var OpenDialog: TxPLMsgOpenDialog;
begin
     OpenDialog:=TxPLMsgOpenDialog.create(self);
     result := OpenDialog.Execute;
     if result then LoadFromFile(OpenDialog.FileName);
     OpenDialog.Destroy;
end;


end.

