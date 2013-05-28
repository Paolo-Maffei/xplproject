unit frm_XMLView;

{$mode objfpc}{$H+}
{$r *.lfm}

interface

uses Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  ActnList, ExtCtrls, SynHighlighterXML, SynEdit, SynHighlighterAny,
  LSControls, dlg_template;

type // TfrmXMLView ===========================================================
     TfrmXMLView = class(TDlgTemplate)
        DlgAcSave: TAction;
        BtnSave: TLSBitBtn;
        SynEdit: TSynEdit;
        SynXMLSyn: TSynXMLSyn;
        procedure DlgAcSaveExecute(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure SynEditChange(Sender: TObject);
     private
        filePath : string;
     end;

     procedure ShowFrmXMLView(const aFileName : string; const ReadOnly : boolean = true);
     procedure ShowFrmXMLView(const aStringList : TStringList); overload;

implementation // =============================================================

uses u_xpl_gui_resource
     ;

var frmXMLView: TfrmXMLView;

// ============================================================================
procedure ShowFrmXMLView(const aFileName: string; const ReadOnly : boolean = true);
begin
   if not Assigned(FrmXMLView) then Application.CreateForm(TFrmXMLView,FrmXMLView);
   FrmXMLView.FilePath := aFileName;
   FrmXMLView.SynEdit.ReadOnly := ReadOnly;
   FrmXMLView.ShowModal;
end;

procedure ShowFrmXMLView(const aStringList: TStringList);
begin
   if not Assigned(FrmXMLView) then Application.CreateForm(TFrmXMLView,FrmXMLView);
   FrmXMLView.SynEdit.Lines.Assign(aStringList);
   FrmXMLView.ShowModal;
end;

// ============================================================================
procedure TfrmXMLView.FormCreate(Sender: TObject);
begin
   inherited;
   DlgAcSave.ImageIndex := K_IMG_DOCUMENT_SAVE;
end;

procedure TfrmXMLView.FormShow(Sender: TObject);
begin
   inherited;
   Caption := FilePath;
   DlgAcSave.Visible := not FrmXMLView.SynEdit.ReadOnly;
   DlgAcSave.Enabled := false;
   if FilePath<>'' then SynEdit.Lines.LoadFromFile(filepath);
end;

procedure TfrmXMLView.DlgAcSaveExecute(Sender: TObject);
begin
   SynEdit.Lines.SaveToFile(filepath);
   DlgAcSave.Enabled := false;
end;

procedure TfrmXMLView.SynEditChange(Sender: TObject);
begin
   DlgAcSave.Enabled := True;
end;

end.
