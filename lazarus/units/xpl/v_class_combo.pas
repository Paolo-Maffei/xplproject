unit v_class_combo;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils,StdCtrls;

type TxPLClassCombo = class(TCombobox)
     private
       fRegExpr : string;
       fValid   : boolean;

       procedure SetRegExpr(const AValue: string);
       procedure EditingDone; override;
       procedure SetValid(const AValue: boolean);
     public
       constructor create(aOwner : TComponent); override;

       property IsValid : boolean read fValid  write SetValid;
     published
       property RegExpr : string read fRegExpr write SetRegExpr;
     end;

     procedure Register;

implementation
uses uxPLConst, RegExpr, Graphics;

procedure Register;
begin
  RegisterComponents('xPL Components',[TxPLClassCombo]);
end;

constructor TxPLClassCombo.create(aOwner: TComponent);
var s: tstringlist;
    i : integer;
begin
    inherited create(aOwner);
    RegExpr := '^' + K_REGEXPR_SCHEMA_ELEMENT + '$';
    Items.Add('');

    s := tstringlist.create;
    s.Sorted := true;

    for i:=low(K_XPL_CLASS_DESCRIPTORS) to high(K_XPL_CLASS_DESCRIPTORS) do
                               S.Add(K_XPL_CLASS_DESCRIPTORS[i]);

    Items.AddStrings(s);
    s.Destroy;
end;

procedure TxPLClassCombo.SetRegExpr(const AValue: string);
begin
  if aValue = fRegExpr then exit;
  fRegExpr := aValue;
end;

procedure TxPLClassCombo.EditingDone;
begin
  inherited;

  if RegExpr='' then exit;
  with TRegExpr.Create do try
       Expression := RegExpr;
       IsValid := Exec(Text);
  finally
       free;
  end;
end;

procedure TxPLClassCombo.SetValid(const AValue: boolean);
begin
  fValid := aValue;
  if fValid then Self.Color := clWindow else Self.Color := clRed;
end;

end.

