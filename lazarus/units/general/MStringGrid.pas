unit MStringGrid;

{ TMStringGrid allows rows to be appended, deleted and inserted at runtime

  To append a row to the bottom of the grid
  	- move to the last row and press Down Arrow
  To delete the current row
  	- press Ctrl+Del
  To insert a row at the current row position
  	- press Ctrl+Ins

	TMStringGrid is placed in the public domain.
	Condition Of Use: You are on your own, don't look to me to save you.

	Update A:
		TMStringGrid.RowOptions has been updated to include [roAllowKeys] in
		response to a person wanting to enable/disable the RowOptions functionality
		when using DrawCell with programmer-drawn header and footer rows.

		The OnRowAppend, OnRowInsert and OnRowDelete events alluded to in the
		original version have also been implemented.

		I have also removed my default RowCount & ColCount settings from Create as
		it threw a few people off when they set these properties at design-time.

	John McCarten
	1 November 1999

	If you have anything else you may want shoved in
	(you write, I write - same, same) I can be contacted at

		john@apollo-group.co.nz



	Installing into D4 Pro.

	1. Create a new package or open an existing one
	2. Add MStringGrid.pas as Unit
	3. Compile package
	4. Install if necessary

	By default MStringGrid will install on the Samples palette - this
	can be changed with the RegisterComponents method further down.

	I don't use any other D versions so installing into them is for you
	to sort out.
}

interface

uses
	SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Grids, Menus;

type
	TMStringGridRowOptions = set of (roAllowAppend, roAllowDelete, roAllowInsert, roAllowKeys);

	TMStringGridRowsChangedEvent = procedure (Sender: TObject; ARow: Integer) of object;

	TMStringGridRowAppendEvent = procedure (Sender: TObject; ARow: Integer; var CanAppend: Boolean) of object;
	TMStringGridRowInsertEvent = procedure (Sender: TObject; ARow: Integer; var CanInsert: Boolean) of object;
	TMStringGridRowDeleteEvent = procedure (Sender: TObject; ARow: Integer; var CanDelete: Boolean) of object;

{ TMStringGrid }

TMStringGrid = class(TStringGrid)
	private
	        FInsertMnu  : TMenuItem;
	        FDeleteMnu  : TMenuItem;
                FAppendMnu  : TMenuItem;
		FRowOptions : TMStringGridRowOptions;

		FRowsChanged: TMStringGridRowsChangedEvent;

		FRowAppend: TMStringGridRowAppendEvent;
		FRowDelete: TMStringGridRowDeleteEvent;
		FRowInsert: TMStringGridRowInsertEvent;

	protected
                FPopup	    : TPopupMenu;
		procedure KeyDown (var Key: Word; Shift: TShiftState); override;
                function AppendMenu(aCaption : string; aProc : TNotifyEvent ) : TMenuItem;
	public
		constructor Create(AOwner: TComponent); override;
                destructor  destroy; override;
		procedure RowAppend( Sender: TObject );
		procedure RowDelete( Sender: TObject );
		procedure RowInsert( Sender: TObject );
		{ RowAppend, RowDelete and RowInsert are public to let me manipulate the
			grid in response to menu and toolbar button actions.
		}
//                procedure LoadContent(cfg: TXMLConfig);
	published
		property RowOptions: TMStringGridRowOptions read FRowOptions write FRowOptions;
		{ RowOptions allows me to control user append, insert and delete actions depending
			on the state of the grid and/or the row that the user is currently in.
		}
		property OnRowsChanged: TMStringGridRowsChangedEvent read FRowsChanged write FRowsChanged;
		{ OnRowsChanged fires when the number of rows in the grid change }

		property OnRowAppend: TMStringGridRowAppendEvent read FRowAppend write FRowAppend;
		property OnRowDelete: TMStringGridRowDeleteEvent read FRowDelete write FRowDelete;
		property OnRowInsert: TMStringGridRowInsertEvent read FRowInsert write FRowInsert;
		{ These events fire when the appropriate method is called.  in your program
			you can cancel the keyboard action if the user is in the wrong row
			ie: programmer-drawn header or footer rows.
		}

	end;

procedure Register;

implementation

resourcestring
	sDeleteLine = '&Delete current row';
	sInsertLine = '&Insert row';
        sAppendLine = '&Append row';

procedure Register;
begin
	RegisterComponents('xPL Components', [TMStringGrid]);
end;

function TMStringGrid.AppendMenu(aCaption : string; aProc : TNotifyEvent ) : TMenuItem;
begin
   Result := TMenuItem.Create( FPopUp );
   Result.Caption := aCaption;
   Result.OnClick := aProc;
   FPopup.Items.Add(Result);
end;



constructor TMStringGrid.Create(AOwner: TComponent);
begin
     inherited;
     FRowOptions := [roAllowAppend, roAllowDelete, roAllowInsert, roAllowKeys];
     Options := Options + [goColSizing];

     FPopUp := TPopupMenu.Create( self );
     PopupMenu := FPopUp;

     FDeleteMnu := AppendMenu(sDeleteLine,@RowDelete);
     FAppendMnu := AppendMenu(sAppendLine,@RowAppend);
     FInsertMnu := AppendMenu(sInsertLine,@RowInsert);
end;

destructor TMStringGrid.Destroy;
begin
     FInsertMnu.Free;
     FAppendMnu.Free;
     FDeleteMnu.Free;
     FPopup.Free;
     inherited;
end;


procedure TMStringGrid.KeyDown (var Key: Word; Shift: TShiftState);
const
	MVK_APPEND = $28;
	MVK_DELETE = $2E;
	MVK_INSERT = $2D;
	{ virtual key constants have been prefixed with MVK_ to avoid
		any conflicts with standard VK_ assignments. You can change
		these key assignments to whatever.
	}
begin
	if roAllowKeys in FRowOptions then
	begin
		if (Row = RowCount-1) and (Key = MVK_APPEND) then
			RowAppend(self);

		if (ssCtrl in Shift) and (Key = MVK_DELETE) then
			RowDelete(self);

		if (ssCtrl in Shift) and (Key = MVK_INSERT) then
			RowInsert(self);
	end;

	inherited;
end;


//procedure TMStringGrid.LoadContent(cfg: TXMLConfig);
//var version : integer;
//    k : integer;
//begin
//    Version:=cfg.GetValue('grid/version',-1);
//    k:=cfg.getValue('grid/content/cells/cellcount', 0);
//    if k>0 then RowCount := k div ColCount;
//    BeginUpdate;
//    inherited LoadContent(Cfg, Version);
//    EndUpdate;
//end;


procedure TMStringGrid.RowAppend( Sender: TObject );
var
	IsOK: Boolean;
	ColIndex: Integer;
begin
	{ append row if allowed }
	if roAllowAppend in FRowOptions then
	begin
		IsOK := True;

		{ raise OnRowAppend event }
		if Assigned(FRowAppend) then
			FRowAppend(Self, Row, IsOK);

		{ action Append if IsOK }
		if IsOK then
		begin
			{ append new row to bottom of grid }
			RowCount := RowCount + 1;

			{ set current row to new row }
			Row := RowCount - 1;

			{ blank new row - some interesting effects if you don't}
			for ColIndex := 0 to ColCount-1 do
				Cells[ColIndex, Row] := '';

			{ raise OnRowsChanged event - return current row }
			if Assigned(FRowsChanged) then
				FRowsChanged(Self, Row);
		end;
	end;
end;


procedure TMStringGrid.RowDelete( Sender: TObject );
var
	IsOK: Boolean;
	ColIndex,
	RowIndex: Integer;
begin
	{ delete row if allowed }
	{ don't allow deletion of 1st row when only one row }
	if (roAllowDelete in FRowOptions) and (RowCount > 1) then
	begin
		IsOK := True;

		{ raise OnRowDelete event }
		if Assigned(FRowDelete) then
			FRowDelete(Self, Row, IsOK);

		{ action Delete if IsOK }
		if IsOK then
		begin
			{ move cells data from next to last rows up one - overwriting current row}
			for RowIndex := Row to RowCount-2 do
				for ColIndex := 0 to ColCount-1 do
					Cells[ColIndex, RowIndex] := Cells[ColIndex, RowIndex+1];

			{ delete last row }
			RowCount := RowCount - 1;

			{ raise OnRowsChanged event - return current row}
			if Assigned(FRowsChanged) then
				FRowsChanged(Self, Row);
		end;
	end;
end;


procedure TMStringGrid.RowInsert( Sender: TObject );
var
	IsOK: Boolean;
	ColIndex,
	RowIndex: Integer;
begin
	{ insert row if allowed }
	if roAllowInsert in FRowOptions then
	begin
		IsOK := True;

		{ raise OnRowInsert event }
		if Assigned(FRowInsert) then
			FRowInsert(Self, Row, IsOK);

		{ action Insert if IsOK }
		if IsOK then
		begin
			{ append new row to bottom of grid }
			RowCount := RowCount + 1;

			{ move cells data from current to old last rows down one }
			for RowIndex := RowCount-1 downto Row+1 do
				for ColIndex := 0 to ColCount-1 do
					Cells[ColIndex, RowIndex] := Cells[ColIndex, RowIndex-1];

			{ blank current row - effectively the newly inserted row}
			for ColIndex := 0 to ColCount-1 do
				Cells[ColIndex, Row] := '';

			{ raise OnRowsChanged event - return current row}
			if Assigned(FRowsChanged) then
				FRowsChanged(Self, Row);
		end;
	end;
end;


end.


