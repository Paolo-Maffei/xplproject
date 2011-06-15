unit u_xpl_formulas;

{$mode objfpc}{$H+}

interface

uses Classes
     , SysUtils
     , formulaN
     , u_xpl_collection
     ;

type

{ TxPLFormula }

TxPLFormula = class(TxPLCollectionItem)
    private
       fExpression : string;
       function Get_AsBoolean: boolean;
       function Get_AsInteger: integer;
       procedure Set_Expression(const AValue: string);
    public

       procedure Assign(Source: TPersistent);
    published
       property Expression : string read fExpression write Set_Expression;
       property DisplayName;
       property Value;
       property CreateTS;
       property ModifyTS;
       property AsInteger : integer read Get_AsInteger;
       property AsBoolean : boolean read Get_AsBoolean;
    end;

{ TxPLFormulas }
    TxPLCustomFormulas = specialize TxPLCollection<TxPLFormula>;

    TxPLFormulas = class(TxPLCustomFormulas)
       F : TArtFormulaN;
    protected

    public
       Globals : TxPLCustomCollection;
       function Compute(const Expression : string) : string;
       constructor Create(aOwner : TPersistent); reintroduce;
       destructor  Destroy; override;
       //procedure GetVarValue(Vname: string; n: integer; var Val: string; wantnumber: boolean=false);
       procedure Update(Item: TCollectionItem); override;

    end;

(*
TxPLFormulas = class(TCollection)
private
  FOnGlobalChange: TxPLGlobalChangedEvent;
   fOwner: TPersistent;
   FOnFormulaChange: TxPLGlobalChangedEvent;
   procedure SetItems(Index: integer; const AValue: TxPLFormula);


  function GetItems(index: integer): TxPLFormula;

protected
  function GetOwner: TPersistent; override;
public
   constructor Create(aOwner: TPersistent);

   function Add(const aName : string) : TxPLFormula;
   function FindItemName(const aName: string): TxPLFormula;
   function GetItemId(const aName: string): integer;
   property Items[Index: integer]: TxPLFormula Read GetItems Write SetItems; default;

published
   property OnGlobalChange : TxPLGlobalChangedEvent read FOnGlobalChange write fOnGlobalChange;
end;*)

implementation
uses u_xpl_globals
     , uRegExpr
     , StrUtils
     ;

{ TxPLFormulas }

procedure TxPLFormulas.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
    if Item<>nil then
       with TxPLFormula(Item) do
            Value := Compute(Expression)
    else begin
         for Item in self do begin
             TxPLFormula(Item).Value := Compute(TxPLFormula(Item).Expression);
         end;
    end;
end;

function TxPLFormulas.Compute(const Expression: string): string;
var bLoop   : boolean;
    global  : TxPLGlobalValue;
begin
   result := Expression;
   with TRegExpr.Create do begin
       Expression := '{(.*?)}';
       bLoop := Exec(result);
       while bLoop do begin
             Global := TxPLGlobals(Globals).FindItemName(match[1]);
             if Assigned(Global) then result := AnsiReplaceStr(result,match[0],Global.Value);
                bLoop := ExecNext;
       end;
       Free;
   end;
   if result<>'' then
      try
        Result := FloatToStr(F.ComputeStr(result,0,nil,nil));
      Except
        Result := 'Syntax error';
      end;
end;

constructor TxPLFormulas.Create(aOwner: TPersistent);
begin
  inherited Create(aOwner);
  F := TArtFormulaN.Create(nil);
  F.CaseSensitive := false;
//  F.CaseSensitiveString := false;
//  F.ExternGetVar := false;
//  F.NoLeadingZero := false;
//  F.ZeroEmptyString := true;
//  F.GetVarValue := @GetVarValue;
end;

destructor TxPLFormulas.Destroy;
begin
  F.Free;
  inherited Destroy;
end;

(*procedure TxPLFormulas.GetVarValue(Vname: string; n: integer; var Val: string; wantnumber: boolean);
var global : TxPLGlobalValue;
begin
   global := TxPLGlobals(Globals).FindItemName(VName);

   if global<>nil then Val := Global.Value;
end;*)

 { TxPLFormulas =============================================================}

procedure TxPLFormula.Set_Expression(const AValue: string);
begin
  if fExpression=AValue then exit;
  fExpression := aValue;
  Changed(false);
end;

function TxPLFormula.Get_AsInteger: integer;
begin
  result := StrToIntDef(Value,-1);
end;

function TxPLFormula.Get_AsBoolean: boolean;
var i : integer;
begin
   i := AsInteger;
   result := (i=1);
end;

procedure TxPLFormula.Assign(Source: TPersistent);
begin
  if Source is TxPLFormula then begin
     inherited Assign(TxPLGlobalValue(Source));
     fExpression := TxPLFormula(Source).Expression;
  end else inherited Assign(Source);
end;

end.

