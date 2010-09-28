unit MEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Graphics;

type

{ TMedit }

TMedit = class(TEdit)
   private
       fRegExpr : string;
       fValid   : boolean;
       fStrict  : boolean;

       procedure SetRegExpr(const AValue: string);
       procedure SetValid(const AValue: boolean);
   public
       constructor create(aOwner : TComponent); override;
       property IsValid : boolean read fValid  write SetValid;
       procedure EditingDone; override;
   published
       property RegExpr : string read fRegExpr write SetRegExpr;
       property RegStrict : boolean read fStrict write fStrict;
   end;

   procedure Register;

implementation
uses uRegExpr;

procedure Register;
begin
  RegisterComponents('Clinique',[TMEdit]);
end;

procedure TMedit.SetRegExpr(const AValue: string);
begin
  if aValue = fRegExpr then exit;
  fRegExpr := aValue;
end;

procedure TMedit.EditingDone;
begin
  inherited;

  if RegExpr='' then exit;
  with TRegExpr.Create do try
       Expression := RegExpr;
       if RegStrict then Expression := '^' + Expression + '$';
       IsValid := Exec(Text);
  finally
       free;
  end;
end;

procedure TMedit.SetValid(const AValue: boolean);
begin
  fValid := aValue;
  if fValid then Self.Color := clWindow else Self.Color := clRed;
end;

constructor TMedit.create(aOwner : TComponent);
begin
  inherited;
  RegExpr := '';
  fStrict := True;
end;

end.

