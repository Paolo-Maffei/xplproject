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
 1.01 : Added default value initialisation
        Renamed Tag property to RawxPL
}
{$mode objfpc}{$H+}
interface

type TxPLSchema = class
     private
        fClasse : String;
        fType   : String;

        procedure Set_RawxPL (const aValue : string);
        function  Get_RawxPL : string;
     public
        Constructor Create(const aClasse : string = ''; const aType : string = '');

        procedure ResetValues;
        procedure Assign(aSchema : TxPLSchema);

        property Classe : string read fClasse    write fClasse;
        property Type_  : string read fType      write fType;
        property RawxPL : string read Get_RawxPL write Set_RawxPL;

        class function IsValid(const aSchema : string) : boolean;
        class function FormatRawxPL(const aClasse : string; const aType : string) : string; inline;
    end;

implementation { ========================================================================}
uses SysUtils,
     cStrings,
     uRegExpr,
     uxPLConst;

constructor TxPLSchema.Create(const aClasse : string = ''; const aType : string = '');
begin
   ResetValues;
   if aClasse<>'' then fClasse := aClasse;
   if aType<>'' then   fType   := aType;
end;

procedure TxPLSchema.ResetValues;
begin
   RawxPL := K_SCHEMA_CONTROL_BASIC;
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

class function TxPLSchema.FormatRawxPL(const aClasse: string; const aType: string): string;
begin
   Result := Format(K_FMT_SCHEMA,[aClasse,aType]);
end;

function TxPLSchema.Get_RawxPL: string;
begin
   Result := FormatRawxPL(Classe,Type_);
end;

procedure TxPLSchema.Set_RawxPL(const aValue: string);
begin
   StrSplitAtChar(aValue,K_SCHEMA_SEPARATOR,fClasse,fType);
end;

end.

