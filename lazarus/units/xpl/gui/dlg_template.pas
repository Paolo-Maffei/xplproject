unit dlg_template;
{==============================================================================
  UnitName      = dlg_template
  UnitDesc      = Ancestor for most of the Dialog boxes in the project
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
}

{$mode objfpc}{$H+}
{$r *.lfm}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, ComCtrls, ActnList, Buttons;

type // TDlgTemplate ==========================================================
     TDlgTemplate = class(TForm)
        DlgacClose: TAction;
        DlgActions: TActionList;
        DlgtbClose: TToolButton;
        DlgToolbar: TToolBar;
        DlgSeparator: TToolButton;
        procedure DlgacCloseExecute(Sender: TObject);
        procedure FormCreate(Sender: TObject);
     end;

implementation //==============================================================
uses u_xpl_gui_resource
     ;

// Form procedures ============================================================
procedure TDlgTemplate.DlgacCloseExecute(Sender: TObject);
begin
   Close;
end;

procedure TDlgTemplate.FormCreate(Sender: TObject);
begin
   inherited;
   DlgToolbar.Images := xPLGUIResource.Images16;
end;

end.
