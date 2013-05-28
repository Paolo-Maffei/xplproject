unit v_msgbody_stringgrid;
{==============================================================================
  UnitName      = v_msgbody_stringgrid
  UnitVersion   = 0.91
  UnitDesc      = StringGrid specialized in body parameters handling
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 }

{$mode objfpc}{$H+}

interface

uses   Classes, SysUtils, LCLProc, LCLType, LCLIntf,
  FPCanvas, Controls, GraphType, Graphics, Forms, MStringGrid,
  StdCtrls, LResources, Buttons, Grids, Menus, u_xpl_body;

type

     { TBodyMessageGrid }

     TBodyMessageGrid = class(TMStringGrid)
     private
        fComboEdit : TComboBox;
        fPossibleKey : TStringList;
//        fPossibleVal : TStringList;
        fReferencedBody : TxPLBody;
//        fModeMenu       : TMenuItem;
        procedure AfterRowChanged(Sender: TObject; ARow: Integer);
        procedure fComboEditEditingDone(Sender: TObject);
        function GetIsValid: boolean;
     public
        constructor create(aOwner : TComponent); override;
        destructor  destroy; override;

        procedure Clear;

        procedure SelectEditor; override;
        procedure EditingDone;  override;

        procedure NewLine(aKey, aValue : string);
        procedure NewLine(aLine : string);
        procedure Assign(aBody   : TxPLBody); overload;
        procedure CopyTo(aBody   : TxPLBody);
        function  GetKey(aRow : integer) : string;
        function  GetValue(aRow : integer) : string;
        function  GetKeyValuePair(aRow : integer) : string;

        property  PossibleKeys : TStringList read FPossibleKey;
//        property  PossibleVals : TStringList read FPossibleVal;
        property  IsValid      : boolean     read GetIsValid;
     end;

procedure Register;

implementation

const
//      K_sg_LAB_COL = 1;
      K_sg_KEY_COL = 0;
      K_sg_VAL_COL = 2;
//      K_sg_VLAB_COL = 5;

{resourcestring
	sExpertMode = '&Expert Mode';
        sBasicMode  = '&Basic Mode';}

procedure Register;
begin
  RegisterComponents('xPL Components',[TBodyMessageGrid]);
end;

{ TBodyMessageGrid }
constructor TBodyMessageGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

//  fModeMenu := AppendMenu(sBasicMode,@ModeToggle);

  Options := Options + [goColSizing, goEditing,goTabs];
  Options := Options - [goVertLine,  goRangeSelect];
  OnRowsChanged := @AfterRowChanged;
  Width := 300;
  Clear;

  fComboEdit := TCombobox.Create(self);
  fComboEdit.OnEditingDone := @fComboEditEditingDone;
  fComboEdit.Visible := false;
  fPossibleKey := TStringList.Create;
  fPossibleKey.Sorted := true;
  fPossibleKey.Duplicates := dupIgnore;
//  fPossibleVal := TStringList.Create;
//  fPossibleVal.Sorted := true;
//  fPossibleVal.Duplicates := dupIgnore;
end;

destructor TBodyMessageGrid.Destroy;
begin
//  fModeMenu.Free;
  fPossibleKey.Free;
//  fPossibleVal.Free;
  fComboEdit.Free;
  inherited;
end;

procedure TBodyMessageGrid.AfterRowChanged(Sender: TObject; ARow: Integer);
begin
     if aRow = 0 then exit;
     if Cells[K_sg_KEY_COL+1,aRow]<>'=' then Cells[K_sg_KEY_COL+1,aRow]:='=';
end;

procedure TBodyMessageGrid.fComboEditEditingDone(Sender: TObject);
//var //sCurrentKey, sCurrentVal : string;
    //sConditionalField,sVisCondition : string;
    //field, condition : string;
    //bVisible : boolean;
    //i,j : integer;
begin
   if Cells[Col,Row]<>fComboEdit.Text then begin
      Cells[Col,Row]:=fComboEdit.Text;
      //***

        if not assigned(fReferencedBody) then exit;

  //sCurrentKey := Cells[K_sg_KEY_COL,Row];
  //sCurrentVal := Cells[K_sg_VAL_COL,Row];
  // Search for other fields having a visibility condition upon current key value
//  for i:=0 to fReferencedBody.ItemCount-1 do begin
//      sVisCondition := fReferencedBody.VisCond[i];
//      sConditionalField := fReferencedBody.Keys[i];
{      if sVisCondition <> '' then begin                         // is there a visibility condition ?
         field := '';
         condition := '';
         StrSplitAtChar(sVisCondition,'=',field,condition);
         if field=sCurrentKey then begin                        // if yes, doest it apply on the value of current key
            bVisible := True;
            with TRegExpr.Create do try
                 Expression := condition;
                 bVisible := Exec(sCurrentVal);
                          for j:=1 to RowCount-1 do begin
                              if Cells[K_sg_KEY_COL,j]= sConditionalField then begin
                                 if bVisible then RowHeights[j]:=15 else RowHeights[j]:=0;
                              end;
                          end;
                 finally free;
            end;
         end;
      end;}
//  end;

      //***
   end;
end;

function TBodyMessageGrid.GetIsValid: boolean;
begin
  result := True;                     // no control on this for the moment / Todo : control that
end;

procedure TBodyMessageGrid.Clear;
begin
  inherited Clear;

  Clean;
  RowCount := 2;
//  ColCount := 6;
  ColCount := 3;
  FixedRows := 1;
//  FixedCols := 1;
   FixedCols := 0;

//  Cells[0,0] := '*';
//  Cells[K_sg_LAB_COL,0] := 'Labels';
  Cells[K_sg_KEY_COL,0] := 'Keys';
  Cells[K_sg_VAL_COL,0] := 'Values';
//  Cells[K_sg_VLAB_COL,0] := 'Desc';
  ColWidths[0]  :=  15;
//  ColWidths[K_sg_LAB_COL]  :=  0;
  ColWidths[K_sg_KEY_COL]  :=  150;
  ColWidths[K_sg_KEY_COL+1]:=  15;
  ColWidths[K_sg_VAL_COL]  :=  150;
//  ColWidths[K_sg_VLAB_COL] := 105;
  NewLine('','');
end;

procedure TBodyMessageGrid.NewLine(aKey, aValue : string);
var i : integer;
begin
   i := RowCount-1;

   if ( (i=0) or (length( Cells[K_sg_KEY_COL,i] + Cells[K_sg_VAL_COL,i]) > 0) ) then begin
      inc(i);
      RowCount := i+1;
   end;

   Cells[K_sg_KEY_COL  ,i] := aKey;
   Cells[K_sg_KEY_COL+1,i] := '=';
   Cells[K_sg_VAL_COL  ,i] := aValue;
end;

procedure TBodyMessageGrid.NewLine(aLine : string);
var sl : TStringList;
begin
   sl := TStringList.Create;
   sl.Delimiter := '=';
   sl.DelimitedText := aLine;
   NewLine(sl[0],sl[1]);
   sl.Free;
end;

procedure TBodyMessageGrid.Assign(aBody: TxPLBody);
var i : integer;
begin
     Clear;
     fReferencedBody := aBody;
     for i:=0 to Pred(aBody.ItemCount) do
         NewLine(aBody.Keys[i],aBody.Values[i]);
end;

procedure TBodyMessageGrid.CopyTo(aBody: TxPLBody);
var i : integer;
    ch : string;
begin
     for i:=1 to RowCount - 1 do begin
         ch := GetKeyValuePair(i);
         if ch<>'' then aBody.AddKeyValue(ch);
     end;
end;

function TBodyMessageGrid.GetKey(aRow: integer): string;
begin
  result := Cells[K_sg_KEY_COL,aRow];
end;

function TBodyMessageGrid.GetValue(aRow: integer): string;
begin
  result := Cells[K_sg_VAL_COL,aRow];
end;

function TBodyMessageGrid.GetKeyValuePair(aRow: integer): string;
begin
     result := GetKey(aRow);
     if result<>'' then result := result + '=' + GetValue(aRow);
end;

procedure TBodyMessageGrid.SelectEditor;
begin
     inherited;
     if assigned(fReferencedBody) then begin
{        if fReferencedBody.ItemCount > Row-1 then begin
//           fPossibleVal.Delimiter:= ',';
//           fPossibleVal.QuoteChar:= '|';
//           fPossibleVal.DelimitedText:= fReferencedBody.OpLabels[Row-1];
        end else begin
            fPossibleVal.Clear;
        end;}
     end;
     if not ((Col = K_sg_KEY_COL) or (Col = K_sg_VAL_COL)) then Editor := nil;
     if (Col = K_sg_VAL_COL) then begin
{        if Assigned(fPossibleVal) then begin
           if fPossibleVal.Count>0 then begin
              fComboEdit.Items := fPossibleVal;
              fComboEdit.BoundsRect := CellRect(Col,Row);
              Editor := fComboEdit;
              fComboEdit.Text := Cells[Col,Row];
           end;
        end;}
     end;
     if (Col = K_sg_KEY_COL) then begin
        if Assigned(fPossibleKEY) then begin
           if fPossibleKEY.Count>0 then begin
              fComboEdit.Items := fPossibleKEY;
              fComboEdit.BoundsRect := CellRect(Col,Row);
              Editor := fComboEdit;
              fComboEdit.Text := Cells[Col,Row];
           end;
        end;
     end;
end;

procedure TBodyMessageGrid.EditingDone;

begin
  inherited EditingDone;

end;

{procedure TBodyMessageGrid.ModeToggle(Sender: TObject);
var i : integer;
begin
     if fModeMenu.Caption = sExpertMode then begin
        fModeMenu.Caption := sBasicMode
     end else begin
        fModeMenu.Caption := sExpertMode
     end;
     i := ColWidths[K_sg_KEY_COL];
     ColWidths[K_sg_KEY_COL]:= ColWidths[K_sg_LAB_COL];
     ColWidths[K_sg_LAB_COL]:= i;

     if ColWidths[K_sg_KEY_COL]>0 then ColWidths[K_sg_KEY_COL+1] := 15
                                  else ColWidths[K_sg_KEY_COL+1] := 0;
end;}

end.
