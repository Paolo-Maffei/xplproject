unit u_xpl_rawset;
{==============================================================================
  UnitName      = u_xpl_rawset
  UnitDesc      = Generic class used to hold header message elements
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 1.5  : Added fControlInput property to override read/write controls needed for OPC
 }

{$ifdef fpc}
   {$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , u_xpl_common
     ;

type // TxPLRawSet ============================================================
     TxPLRawSet = class(TInterfacedPersistent, IxPLCommon, IxPLRaw)
     protected
        fRawxPL   : TStringList;
        fMaxSizes : IntArray;
        fOnRawError : TStrParamEvent;
        fControlInput : boolean;
        procedure   Set_RawxPL(const AValue: string);
        function    Get_RawxPL: string;
     public
        constructor Create;
        destructor  Destroy; override;

        procedure   ResetValues;

        procedure   Assign(aRawSet : TPersistent); override;
        function    Equals(const aRawSet : TxPLRawSet) : boolean; reintroduce; overload;
        function    IsValid : boolean;
        function    IsEmpty : boolean;

        function    AsFilter : string; virtual;

        function  Get_Element(AIndex: integer): string; virtual;
        procedure Set_Element(AIndex: integer; const AValue: string); virtual;
        property  ControlInput : boolean read fControlInput write fControlInput;
     published
        property RawxPL : string read Get_RawxPL write Set_RawxPL stored false;
     end;

implementation // =============================================================
uses StrUtils
     ;

// TxPLRawSet =================================================================
constructor TxPLRawSet.Create;
begin
   inherited Create;
   fControlInput := true;
   fRawxPL := TStringList.Create;
   fRawxPL.Delimiter:='.';
   ResetValues;
end;

destructor TxPLRawSet.Destroy;
begin
   fRawxPL.Free;
   inherited Destroy;
end;

procedure TxPLRawSet.ResetValues;
var i,m : integer;

begin
   fRawxPL.Clear;
   if fControlInput
      then m := High(fMaxSizes)
      else m := 0;
   For i := 0 to m do fRawxPL.Add('');
end;

procedure TxPLRawSet.Assign(aRawSet: TPersistent);
begin
  if aRawSet is TxPLRawSet
     then begin
          fRawxPL.Assign(TxPLRawSet(aRawSet).fRawxPL);
          fControlInput := TxPLRawSet(aRawSet).ControlInput;
     end else inherited;
end;

function TxPLRawSet.Equals(const aRawSet: TxPLRawSet): boolean;
begin
   result := fRawxPL.Equals(aRawSet.fRawxPL);
end;

function TxPLRawSet.Get_RawxPL: string;
begin
   if fControlInput then Result := fRawxPL.DelimitedText
                    else Result := fRawxPL[0];
end;

procedure TxPLRawSet.Set_RawxPL(const AValue: string);
var list : TStringList;
    i    : integer;
begin
   ResetValues;
   list := TStringList.Create;
   list.Delimiter := fRawxPL.Delimiter;
   if fControlInput then list.DelimitedText := aValue
                    else list.Text := aValue;

   For i := 0 to Pred(list.count) do Set_Element(i,list[i]);
   list.free;
end;

function TxPLRawSet.IsValid: boolean;
var i : integer;
begin
   if not fControlInput then exit(true);
   Result := fRawxPL.Count <> 0;                                               // At this level, check we have elements
   for i := 0 to Pred(fRawxPL.Count) do
       Result := Result and IsValidxPLIdent(fRawxPL[i])                        // they are valid xPL syntax elements
                        and (length(fRawxPL[i])<=fMaxSizes[i]);                // and conform to max element size
end;

function TxPLRawSet.IsEmpty: boolean;
var i : integer;
begin
   i := Pred(fRawxPL.Count);
   result := true;
   while result and (i>=0) do begin
         result := result and AnsiSameText(fRawxPL[i],'');
         dec(i);
   end;
end;

function TxPLRawSet.AsFilter: string;
var i : integer;
begin
   Result := '';
   for i := 0 to Pred(fRawxPL.Count) do
       Result := Result + IfThen( fRawxPL[i] <> '', fRawxPL[i], '*') + '.';
   Result := AnsiLeftStr(Result,length(Result)-1);                             // drop last '.'
end;

function TxPLRawSet.Get_Element(AIndex: integer): string;
begin
   result := fRawxPL[aIndex];
end;

procedure TxPLRawSet.Set_Element(AIndex: integer; const AValue: string);
begin
   fRawxPL[aIndex] := AnsiLowerCase(aValue);
end;

end.