unit u_xpl_collection;

{$ifdef fpc}
   { $ mode objfpc}{$H+}
   {$mode delphi}
{$endif}

interface

uses
  Classes, SysUtils;

type

   { TxPLCollectionItem }

   TxPLCollectionItem = class(TCollectionItem)
   protected
       fDisplayName : string;
       fCreateTS    : TDateTime;
       fModifyTS    : TDateTime;
       fValue       : string;
       fComment     : string;

       procedure Set_Value(const AValue: string); virtual;
   public
       constructor Create(aOwner: TCollection); override;
       procedure Assign(Source: TPersistent);   reintroduce; dynamic;

       function GetDisplayName: string; override;
       procedure SetDisplayName(const Value: string); override;
   published
       property DisplayName : string    read GetDisplayName write SetDisplayName;
       property CreateTS    : TDateTime read fCreateTS      write fCreateTS;
       property ModifyTS    : TDateTime read fModifyTS      write fModifyTS;
       property Value       : string    read fValue         write Set_Value;
       property Comment     : string    read fComment       write fComment;
   end;

   TxPLCollection<T {$ifndef fpc}: TxPLCollectionItem{$endif}> = class(TCollection)
      private
          fOwner : TPersistent;
          procedure Set_Items(Index : integer; const aValue : T);
          function  Get_Items(Index : integer) : T;
      protected
          function GetOwner : TPersistent; override;
      public
          constructor Create(aOwner : TPersistent);

          function    Add(const aName : string) : T;
          function    FindItemName(const aName : string) : T;
          function    GetItemID(const aName : string) : integer;
          property    Items[Index : integer] : T read Get_Items write Set_Items; default;
      end;

   TxPLCustomCollection = TxPLCollection<TxPLCollectionItem>;

implementation // =============================================================
uses StrUtils
     ;

// ============================================================================
function IsValidName(const Ident: string): boolean;
var i, len: integer;
begin
   result := false;
   len := length(Ident);
   if len <> 0 then begin
      result := Ident[1] in ['a'..'z','A'..'Z'];
      i := 1;
      while (result) and (i < len) do begin
         inc(i);
         result := result and (Ident[i] in ['a'..'z', '0'..'9','A'..'Z','.','-']);
      end ;
   end ;
end ;

{ TxPLCollectionItem }

function TxPLCollectionItem.GetDisplayName: string;
begin
   Result:=fDisplayName;
end;

procedure TxPLCollectionItem.SetDisplayName(const Value: string);
var ci : TCollectionItem;
begin
   if (fDisplayName<>Value) then begin                                         // Ensure that the name doesn't already
      if not IsValidName(Value) then Raise Exception.CreateFmt('Invalid name : ''%s''',[Value])
      else begin
         for ci in Collection do if ci.DisplayName = Value then
             Raise Exception.CreateFmt('Duplicate name : ''%s''',[Value]);        // exists in the parent collection - can't
         fDisplayName:=Value;                                                     // use directly TxPLCollection.GetItemID as this is a generic class
         Changed(false);
      end;
   end;
end;

procedure TxPLCollectionItem.Set_Value(const AValue: string);
begin
   if aValue = fValue then exit;
   fModifyTS := now;
   fValue:=AValue;
   Changed(false);
end;

constructor TxPLCollectionItem.Create(aOwner: TCollection);
begin
  inherited Create(aOwner);
  fCreateTS := now;
  fModifyTS := fCreateTS;
end;

procedure TxPLCollectionItem.Assign(Source: TPersistent);
begin
   inherited Assign(Source);
   if Source is TxPLCollectionItem then begin
      fDisplayName := TxPLCollectionItem(Source).DisplayName;
      fModifyTS    := TxPLCollectionItem(Source).ModifyTS;
   end;
end;

constructor TxPLCollection<T>.Create(aOwner : TPersistent);
begin
   inherited Create(T);
   fOwner := aOwner;
end;

function TxPLCollection<T>.GetOwner : TPersistent;
begin
   Result := fOwner;
end;

function TxPLCollection<T>.Get_Items(index : integer) : T;
begin
   Result := T(inherited Items[index]);
end;

Procedure TxPLCollection<T>.Set_Items(Index : integer; const aValue : T);
begin
   Items[index] := aValue;
end;

Function TxPLCollection<T>.Add(const aName : string) : T;
var i : integer;
    s : string;
begin
   i := GetItemId(aName);
   if i = -1 then begin
      Result := T(inherited Add);
      i := Count;
      repeat
         s := 'Item' + IntToStr(i);
         inc(i);
      until GetItemId(s)=-1;
      Result.DisplayName := IfThen(aName<>'',aName,s);
   end
   else
      Result := Get_Items(i);
end;

Function TxPLCollection<T>.FindItemName(const aName : string) : T;
var i : longint;
begin
   for i:=0 to Count-1 do begin
       Result := T(items[i]);
       if AnsiCompareText(Result.DisplayName,aName)=0 then exit;
   end;
   Result := {$ifdef fpc}nil{$else}Default(T){$endif};
end;

function TxPLCollection<T>.GetItemId(const aName: string): integer;
begin
   for Result := 0 to Count - 1 do
       if T(items[Result]).DisplayName = aName then exit;
   Result := -1;
end;

initialization
   Classes.RegisterClass(TxPLCollectionItem);
//   Classes.RegisterClass(TxPLCollection);
end.

