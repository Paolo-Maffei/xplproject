unit frm_collection_item;
{==============================================================================
  UnitName      = frm_collection_item
 ==============================================================================
}

{$mode objfpc}{$H+}

interface

uses Forms,
     Classes,
     Buttons,
     Controls,
     ExtCtrls,
     StdCtrls,
     LResources,
     ComCtrls,
     u_xpl_collection,
     ActnList, RTTICtrls;

type

{ TfrmCollIItem }

TfrmCollIItem = class(TForm)
        ActionList: TActionList;
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        lblVendor: TLabel;
        lblBuildDate: TLabel;
        acClose: TAction;
        tbLaunch: TToolButton;
        tieDisplayName: TTIEdit;
        tieValue: TTIEdit;
        tieComment: TTIEdit;
        tieCreateTS: TTILabel;
        tieModifyTs: TTILabel;
        ToolBar: TToolBar;
        ToolButton2: TToolButton;
        procedure acCloseExecute(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
     end;

     procedure ShowFrmCollIItem(aItem : TxPLCollectionItem);

implementation // ==============================================================
uses SysUtils
     , Graphics
     , u_xpl_gui_resource
     ;

var  frmCollIItem: TfrmCollIItem;

procedure ShowFrmCollIItem(aItem: TxPLCollectionItem);
begin
   if not Assigned(frmCollIItem) then Application.CreateForm(TfrmCollIItem, frmCollIItem);

   frmCollIItem.tieDisplayName.Link.TIObject := aItem;
   frmCollIItem.tieDisplayName.Link.TIPropertyName := 'DisplayName';

   frmCollIItem.tieValue.Link.TIObject       := aItem;
   frmCollIItem.tieValue.Link.TIPropertyName := 'Value';

   frmCollIItem.tieComment.Link.TIObject     := aItem;
   frmCollIItem.tieComment.Link.TIPropertyName := 'Comment';

   frmCollIItem.tieCreateTS.Link.TIObject    := aItem;
   frmCollIItem.tieCreateTS.Link.TIPropertyName := 'CreateTS';

   frmCollIItem.tieModifyTs.Link.TIObject    := aItem;
   frmCollIItem.tieModifyTs.Link.TIPropertyName := 'ModifyTS';

   frmCollIItem.ShowModal;
end;

// =============================================================================
procedure TfrmCollIItem.FormCreate(Sender: TObject);
begin
   Toolbar.Images     := xPLGUIResource.Images;
end;

procedure TfrmCollIItem.FormShow(Sender: TObject);
begin
end;

procedure TfrmCollIItem.acCloseExecute(Sender: TObject);
begin
   Close;
end;

initialization // ==============================================================
{$I frm_collection_item.lrs}

end.
