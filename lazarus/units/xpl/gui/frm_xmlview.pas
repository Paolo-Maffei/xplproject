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
    ToolBar3: TToolBar;
    procedure FormShow(Sender: TObject);
    procedure tbLaunchClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    filePath : string;
  end; 

var
  frmXMLView: TfrmXMLView;

implementation
uses frm_about;

{ TfrmXMLView }

procedure TfrmXMLView.tbLaunchClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmXMLView.FormShow(Sender: TObject);
begin
   ToolBar3.Images := frmabout.ilStandardActions;
   Caption := FilePath;
   SynEdit1.Lines.LoadFromFile(filepath);
end;

initialization
  {$I frm_xmlview.lrs}

end.

