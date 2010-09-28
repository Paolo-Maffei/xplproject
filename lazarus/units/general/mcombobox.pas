unit MComboBox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls;

type TMComboBox = class(TComboBox)
   private
       fRegExpr : string;
       fValid   : boolean;

       procedure SetRegExpr(const AValue: string);
       procedure SetValid(const AValue: boolean);
   public
       constructor create(aOwner : TComponent); override;
       property IsValid : boolean read fValid  write SetValid;
       procedure EditingDone; override;
   published
       property RegExpr : string read fRegExpr write SetRegExpr;
   end;

   procedure Register;

implementation
uses uRegExpr,Graphics;

procedure Register;
begin
  RegisterComponents('Clinique',[TMComboBox]);
end;

procedure TMComboBox.SetRegExpr(const AValue: string);
begin
  if aValue = fRegExpr then exit;
  fRegExpr := aValue;
end;

procedure TMComboBox.EditingDone;
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

procedure TMComboBox.SetValid(const AValue: boolean);
begin
  fValid := aValue;
  if fValid then Self.Color := clWindow else Self.Color := clRed;
end;

constructor TMComboBox.create(aOwner : TComponent);
begin
  inherited;
  RegExpr := '';
end;

end.

