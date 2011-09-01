unit frm_XMLView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, SynHighlighterXML, SynEdit, SynHighlighterAny, dlg_template;

type

  { TfrmXMLView }

  TfrmXMLView = class(TDlgTemplate)
    SynEdit1: TSynEdit;
    SynXMLSyn1: TSynXMLSyn;
    procedure FormShow(Sender: TObject);
  private
    filePath : string;
  end;

  procedure ShowFrmXMLView(const aFileName : string);

var frmXMLView: TfrmXMLView;

implementation // =============================================================

uses u_xpl_gui_resource
     ;

// ============================================================================
procedure ShowFrmXMLView(const aFileName: string);
begin
  if not Assigned(FrmXMLView) then Application.CreateForm(TFrmXMLView,FrmXMLView);
  FrmXMLView.FilePath := aFileName;
  FrmXMLView.ShowModal;
end;

procedure TfrmXMLView.FormShow(Sender: TObject);
begin
   inherited;
   Caption := FilePath;
   SynEdit1.Lines.LoadFromFile(filepath);
end;

// ============================================================================
initialization
  {$I frm_xmlview.lrs}

end.

