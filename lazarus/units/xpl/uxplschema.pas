unit uxPLSchema;
{==============================================================================
  UnitDesc      = xPL Schema object management
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : first published version
 0.95 : Regular expression added
 0.96 : Simplification of the class (cut inheritance of TxPLBaseClass)
 0.97 : Usage of uxPLConst
 0.98 : Typing of fClasse and fType variables
 0.99 : Usage of uRegExTools
 1.00 : Removed usage of symbolic constants
}
{$mode objfpc}{$H+}
interface

type TxPLSchema = class
     private
        fClasse : String;
        fType   : String;

        procedure Set_Tag   (const aValue : string);
        function  Get_Tag : string;
     public
        Constructor Create(const aClasse : string = ''; const aType : string = '');

        procedure ResetValues;
        procedure Assign(aSchema : TxPLSchema);

        property Classe : string read fClasse write fClasse;
        property Type_  : string read fType   write fType;
        property Tag    : string read Get_Tag write Set_Tag;

        class function IsValid(const aSchema : string) : boolean;
        class function FormatTag(const aClasse : string; const aType : string) : string; inline;
    end;

implementation { ========================================================================}
uses SysUtils,
     cStrings,
     uRegExpr,
     uxPLConst;

constructor TxPLSchema.Create(const aClasse : string = ''; const aType : string = '');
begin
   fClasse := aClasse;
   fType   := aType;
end;

procedure TxPLSchema.ResetValues;
begin
   fClasse := '';
   fType   := '';
end;

procedure TxPLSchema.Assign(aSchema: TxPLSchema);
begin
   fClasse := aSchema.Classe;
   fType   := aSchema.Type_;
end;

class function TxPLSchema.IsValid(const aSchema: string): boolean;
begin
   with TRegExpr.Create do try
      Expression := K_REGEXPR_SCHEMA;
      result := Exec(aSchema);
   finally
      Destroy;
   end;
end;

class function TxPLSchema.FormatTag(const aClasse: string; const aType: string): string;
begin
   Result := Format(K_FMT_SCHEMA,[aClasse,aType]);
end;

function TxPLSchema.Get_Tag: string;
begin
   Result := FormatTag(Classe,Type_);
end;

procedure TxPLSchema.Set_Tag(const aValue: string);
begin
   StrSplitAtChar(aValue,K_SCHEMA_SEPARATOR,fClasse,fType);
end;

end.

