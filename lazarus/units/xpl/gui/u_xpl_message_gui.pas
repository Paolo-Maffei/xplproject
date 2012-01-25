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
  u_xpl_Message;

type TButtonOption = (
                boLoad,
                boSave,
                boCopy,
                boSend,
                boClose,
                boOk,
                boAbout);
     TButtonOptions = set of TButtonOption;

     { TxPLMessageGUI }

     TxPLMessageGUI = class(TxPLMessage)
        public
           function  Edit : boolean;     dynamic;
           procedure Show(options : TButtonOptions);
           procedure ShowForEdit(const options : TButtonOptions; const bModal : boolean = false; const bAdvancedMode : boolean = true);
           function  SelectFile : boolean;
     end;

implementation { ==============================================================}
uses frm_xPLMessage
     , v_xplmsg_opendialog
     , Controls
     , Forms
     ;

procedure TxPLMessageGUI.ShowForEdit(const options: TButtonOptions; const bModal: boolean; const bAdvancedMode : boolean = true);
begin
   with TfrmxPLMessage.Create(Application) do try
        xPLMessage := self;
        buttonOptions := options;
        edtMsgName.ReadOnly := false;
        tsRaw.TabVisible := bAdvancedMode;
        tsPSScript.TabVisible := tsRaw.Visible;
        if bModal then ShowModal else Show;
   finally
   end;
end;

function TxPLMessageGUI.Edit : boolean;
begin
   with TfrmxPLMessage.Create(Application) do try
        xPLMessage := self;
        result := (ShowModal = mrOk);
   finally
        Destroy;
   end;
end;

procedure TxPLMessageGUI.Show(options : TButtonOptions);
begin
   with TfrmxPLMessage.Create(Application) do try
        xPLMessage := self;
        buttonOptions := options;
        Show;
   finally
   end;
end;

function TxPLMessageGUI.SelectFile: boolean;
begin
   with TxPLMsgOpenDialog.create(Application) do try
        result := Execute;
        if result then LoadFromFile(FileName);
   finally
        Destroy;
   end;
end;


end.

