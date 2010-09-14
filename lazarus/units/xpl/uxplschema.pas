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
 Rev 256 : Removed usage of symbolic constants
}
{$mode objfpc}{$H+}
interface

uses uxPLConst;

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

        class function IsValid(aSchema : string) : boolean;
    end;

implementation { ========================================================================}
uses SysUtils, cStrings, uRegExTools;

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

class function TxPLSchema.IsValid(aSchema: string): boolean;
begin
   RegExpEngine.Expression := K_REGEXPR_SCHEMA;
   result := RegExpEngine.Exec(aSchema);
end;

function TxPLSchema.Get_Tag: string;
begin
   Result := Format(K_FMT_SCHEMA,[Classe,Type_]);
end;

procedure TxPLSchema.Set_Tag(const aValue: string);
begin
   StrSplitAtChar(aValue,K_SCHEMA_SEPARATOR,fClasse,fType);
end;

end.

