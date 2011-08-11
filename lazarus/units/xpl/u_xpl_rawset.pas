unit u_xpl_rawset;

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
        fMaxSizes : Array of integer;
        fOnRawError : TStrParamEvent;

        procedure   Set_RawxPL(const AValue: string);
        function    Get_RawxPL: string;
     public
        constructor Create;
        destructor  Destroy; override;

        procedure   ResetValues;

        procedure   Assign(aRawSet : TPersistent); override;
        function    Equals(const aRawSet : TxPLRawSet) : boolean; overload;
        function    IsValid : boolean;

        function    AsFilter : string; virtual;

        function  Get_Element(AIndex: integer): string; virtual;
        procedure Set_Element(AIndex: integer; const AValue: string); virtual;
     published
        property RawxPL : string read Get_RawxPL write Set_RawxPL stored false;
     end;

implementation // =============================================================
uses JclStrings
     , StrUtils
     ;

// TxPLRawSet =================================================================
constructor TxPLRawSet.Create;
begin
   inherited Create;
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
var i : integer;
begin
   fRawxPL.Clear;
   For i := 0 to High(fMaxSizes) do fRawxPL.Add('');
end;

procedure TxPLRawSet.Assign(aRawSet: TPersistent);
begin
  if aRawSet is TxPLRawSet
     then fRawxPL.Assign(TxPLRawSet(aRawSet).fRawxPL)
     else inherited;
end;

function TxPLRawSet.Equals(const aRawSet: TxPLRawSet): boolean;
begin
   result := fRawxPL.Equals(aRawSet.fRawxPL);
end;

function TxPLRawSet.Get_RawxPL: string;
begin
   Result := fRawxPL.DelimitedText
end;

procedure TxPLRawSet.Set_RawxPL(const AValue: string);
var list : TStringList;
    i    : integer;
begin
   ResetValues;
   list := TStringList.Create;
   StrTokenToStrings(aValue,fRawxPL.Delimiter,list);
   For i := 0 to Pred(list.count) do Set_Element(i,list[i]);
   list.free;
end;

function TxPLRawSet.IsValid: boolean;
var i : integer;
begin
   Result := fRawxPL.Count <> 0;                                               // At this level, check we have elements
   for i := 0 to Pred(fRawxPL.Count) do
       Result := Result and IsValidxPLIdent(fRawxPL[i])                        // they are valid xPL syntax elements
                        and (length(fRawxPL[i])<=fMaxSizes[i]);                // and conform to max element size
end;

function TxPLRawSet.AsFilter: string;
var i : integer;
begin
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

