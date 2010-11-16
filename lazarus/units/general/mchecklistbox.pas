unit MCheckListBox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, CheckLst, Menus;

type

{ TMCheckListBox }

     TMCheckListBox = class(TCheckListBox)
        FPopup	      : TPopupMenu;
	FSelectAll    : TMenuItem;
	FDeSelectAll  : TMenuItem;
        FInvertSelect : TMenuItem;

     public
        constructor Create(AOwner: TComponent); override;
        destructor  destroy; override;

	procedure   SetCheckedAll  ( Sender: TObject );
	procedure   SetUnCheckedAll( Sender: TObject );
        procedure   SetInvertSelect( Sender: TObject );
     end;

     procedure Register;

implementation

resourcestring
	sFCapSelAll   = '&Select All';
	sFCapDeselAll = '&Deselect All';
        sFInvert      = '&Invert selection';

procedure Register;
begin
	RegisterComponents('xPL Components', [TMCheckListBox]);
end;

constructor TMCheckListBox.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FPopUp := TPopupMenu.Create( self );

   FSelectAll           := TMenuItem.Create( FPopUp );
   FSelectAll.Caption   := sFCapSelAll;
   FSelectAll.OnClick 	:= @SetCheckedAll;

   FDeSelectAll         := TMenuItem.Create( FPopUp );
   FDeSelectAll.Caption := sFCapDeselAll;
   FDeSelectAll.OnClick := @SetUnCheckedAll;

   FInvertSelect         := TMenuItem.Create( FPopUp );
   FInvertSelect.Caption := sfInvert;
   FInvertSelect.OnClick := @SetInvertSelect;


   FPopUp.Items.Add(FSelectAll );
   FPopUp.Items.Add(FDeSelectAll );
   FPopUp.Items.Add(FInvertSelect);

   PopupMenu := FPopUp;
   Font.Size := 10;
end;

destructor TMCheckListBox.destroy;
begin
   FSelectAll.Free;
   FDeSelectAll.Free;
   FInvertSelect.Free;
   FPopup.Free;
   inherited destroy;
end;

procedure TMCheckListBox.SetCheckedAll( Sender : TObject );
var i:integer;
begin
   for i:=0 to Items.Count -1 do Checked[i]:= true;
end;

procedure TMCheckListBox.SetUnCheckedAll( Sender: TObject );
var i : integer;
begin
   for i:=0 to Items.Count-1 do Checked[i] := false;
end;

procedure TMCheckListBox.SetInvertSelect(Sender: TObject);
var i : integer;
begin
   for i:=0 to Items.Count-1 do Checked[i] := not Checked[i];
end;

end.

