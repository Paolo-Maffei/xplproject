unit frm_XMLView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, SynHighlighterXML, SynEdit, SynHighlighterAny;

type

  { TfrmXMLView }

  TfrmXMLView = class(TForm)
    SynEdit1: TSynEdit;
    SynXMLSyn1: TSynXMLSyn;
    tbLaunch: TToolButton;
    ToolBar: TToolBar;
    procedure FormShow(Sender: TObject);
    procedure tbLaunchClick(Sender: TObject);
  private
    { private declarations }
    filePath : string;
  public
    { public declarations }

  end;

  procedure ShowFrmXMLView(const aFileName : string);

var frmXMLView: TfrmXMLView;

implementation
uses u_xpl_gui_resource;

procedure ShowFrmXMLView(const aFileName: string);
begin
  if not Assigned(FrmXMLView) then Application.CreateForm(TFrmXMLView,FrmXMLView);
  FrmXMLView.FilePath := aFileName;
  FrmXMLView.ShowModal;
end;

procedure TfrmXMLView.tbLaunchClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmXMLView.FormShow(Sender: TObject);
begin
   ToolBar.Images := xPLGUIResource.Images;
   Caption := FilePath;
   SynEdit1.Lines.LoadFromFile(filepath);
end;

initialization
  {$I frm_xmlview.lrs}

end.

