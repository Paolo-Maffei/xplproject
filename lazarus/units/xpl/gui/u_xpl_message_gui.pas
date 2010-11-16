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
  Classes,
  SysUtils,
  uxPLMessage;

type TButtonOption = (
                boLoad,
                boSave,
                boCopy,
                boSend);
     TButtonOptions = set of TButtonOption;

     TxPLMessageGUI = class(TxPLMessage)
        public
           function  Edit : boolean;     dynamic;
           procedure Show(options : TButtonOptions);
           procedure ShowForEdit(options : TButtonOptions);
           function  SelectFile : boolean;
     end;

implementation { ==============================================================}
uses frm_xPLMessage,
     v_xplmsg_opendialog,
     Controls;

procedure TxPLMessageGUI.ShowForEdit(options : TButtonOptions);
begin
   with TfrmxPLMessage.Create(self) do try
        buttonOptions := options;
        mmoMessage.ReadOnly := false;
        Show;
   finally
   end;
end;

function TxPLMessageGUI.Edit : boolean;
begin
   with TfrmxPLMessage.Create(self) do try
        result := (ShowModal = mrOk);
   finally
        Destroy;
   end;
end;

procedure TxPLMessageGUI.Show(options : TButtonOptions);
begin
   with TfrmxPLMessage.Create(self) do try
        buttonOptions := options;
        Show;
   finally
   end;
end;

function TxPLMessageGUI.SelectFile: boolean;
begin
   with TxPLMsgOpenDialog.create(self) do try
        result := Execute;
        if result then LoadFromFile(FileName);
   finally
        Destroy;
   end;
end;


end.

