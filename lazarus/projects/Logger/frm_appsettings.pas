unit frm_appsettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, XMLPropStorage, StdCtrls, Buttons;

type

  { TfrmAppSettings }

  TfrmAppSettings = class(TForm)
    ckIcons: TCheckBox;
    ckShowPreview: TCheckBox;
    Label1: TLabel;
    ListBox1: TListBox;
    ToolBar3: TToolBar;
    tbOk: TToolButton;
    UpDown1: TUpDown;
    XMLPropStorage: TXMLPropStorage;
    procedure tbOkClick(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmAppSettings: TfrmAppSettings;

implementation
uses frm_about;

{ TfrmAppSettings }

procedure TfrmAppSettings.tbOkClick(Sender: TObject);
begin
  close;
end;



procedure TfrmAppSettings.UpDown1Click(Sender: TObject; Button: TUDBtnType);
var CurrIndex, LastIndex: Integer;
begin
   with ListBox1 do
   case Button of
      btNext : if ItemIndex > 0 then begin
                  CurrIndex := ItemIndex;
                  Items.Move(ItemIndex, (CurrIndex - 1));
                  ItemIndex := CurrIndex - 1;
               end;
      btPrev : begin
                  CurrIndex := ItemIndex;
                  LastIndex := Items.Count;
                  if ItemIndex <> -1 then begin
                    if CurrIndex + 1 < LastIndex then begin
                       Items.Move(ItemIndex, (CurrIndex + 1));
                       ItemIndex := CurrIndex + 1;
                    end;
                  end;
               end;
   end;
end;

initialization
  {$I frm_appsettings.lrs}

end.
