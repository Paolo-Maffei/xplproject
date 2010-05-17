unit uxPLSchema;
{==============================================================================
  UnitName      = uxPLSchema
  UnitDesc      = xPL Schema management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : first published version
 0.95 : Regular expression added
 0.96 : Simplification of the class (cut inheritance of TxPLBaseClass)
 0.97 : Usage of uxPLConst
 0.98 : Typing of fClasse and fType variables
 0.99 : Usage of uRegExTools
}
{$mode objfpc}{$H+}
interface

uses uxPLConst;

type

    { TxPLSchema }

    TxPLSchema = class
    private
      fClasse : tsClass;
      fType   : tsType;

      procedure SetClasse(const aValue: TxPLSchemaClasse);
      function  GetClasse: TxPLSchemaClasse;
      function  GetTag: string;
      procedure SetTag   (const aValue: string);
    public
      Constructor Create(const aClasse : tsClass = ''; const aType : tsType = '');

      procedure ResetValues;
      procedure Assign(aSchema : TxPLSchema);

      property Classe         : TxPLSchemaClasse read GetClasse write SetClasse;
      property ClasseAsString : tsClass  read fClasse write fClasse;
      property TypeAsString   : tsType   read fType   write fType;
      property Tag            : string   read GetTag  write SetTag;

      class function IsValid(aSchema : string) : boolean;

    end;

implementation { ========================================================================}
uses StrUtils, SysUtils, uRegExTools;

constructor TxPLSchema.Create(const aClasse : tsClass = ''; const aType : tsType = '');
begin
   inherited Create;
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
   fClasse := aSchema.ClasseAsString;
   fType   := aSchema.TypeAsString;
end;

class function TxPLSchema.IsValid(aSchema: string): boolean;
begin
   RegExpEngine.Expression := K_REGEXPR_SCHEMA;
   result := RegExpEngine.Exec(aSchema);
end;

function TxPLSchema.GetClasse: TxPLSchemaClasse;
begin
   Result := TxPLSchemaClasse(AnsiIndexStr(ClasseAsString,K_XPL_CLASS_DESCRIPTORS));
end;

function TxPLSchema.GetTag: string;
begin
   Result := Format(K_FMT_SCHEMA,[ClasseAsString,TypeAsString]);
end;

procedure TxPLSchema.SetClasse(const AValue: TxPLSchemaClasse);
begin
   if aValue = Classe then exit;
   fClasse := K_XPL_CLASS_DESCRIPTORS[Ord(aValue)];
end;

procedure TxPLSchema.SetTag(const aValue: string);
begin
   RegExpEngine.Expression := K_REGEXPR_SCHEMA;
   if RegExpEngine.Exec(aValue) then begin
      fClasse := RegExpEngine.Match[1];
      fType   := RegExpEngine.Match[2];
   end;
end;

end.

