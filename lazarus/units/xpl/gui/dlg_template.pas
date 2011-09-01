unit dlg_template;
{==============================================================================
  UnitName      = dlg_templat
  UnitDesc      = Ancestor for most of the Dialog boxes in the project
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, ComCtrls, ActnList, Buttons;

type

  { TDlgTemplate }

  TDlgTemplate = class(TForm)
    DlgacClose: TAction;
    DlgActions: TActionList;
    DlgtbClose: TToolButton;
    DlgToolbar: TToolBar;
    DlgSeparator: TToolButton;
    procedure DlgacCloseExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

implementation //==============================================================
uses u_xpl_gui_resource
     ;

// Form procedures ============================================================
procedure TDlgTemplate.FormShow(Sender: TObject);
begin
   DlgToolbar.Images := xPLGUIResource.Images;
end;

procedure TDlgTemplate.DlgacCloseExecute(Sender: TObject);
begin
   Close;
end;

// ============================================================================
initialization
   {$I dlg_template.lrs}

end.

