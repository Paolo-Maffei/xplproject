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
}
{$mode objfpc}{$H+}
interface

uses uxPLConst, RegExpr;

type
    TxPLSchema = class
    private
      fClasse : tsClass;
      fType   : tsType;
      fValidator : TRegExpr;

      function  GetClasse: TxPLSchemaClasse;
      function  GetTag: string;
      procedure SetClasse(const AValue: TxPLSchemaClasse);
      procedure SetClasse(const AValue: tsClass);
      procedure SetTag   (const AValue: string);
      procedure SetType  (const AValue: tsType);
    public
      property Classe         : TxPLSchemaClasse read GetClasse write SetClasse;
      property ClasseAsString : tsClass read fClasse write SetClasse;
      property TypeAsString   : tsType read fType   write SetType;
      property Tag            : string read GetTag  write SetTag;

      Constructor Create(const aClasse : tsClass = ''; const aType : tsType = '');
      Destructor  Destroy; override;

      //function  IsValid : boolean;
      procedure ResetValues;
    end;

implementation { ==============================================================}
uses StrUtils, SysUtils;

constructor TxPLSchema.Create(const aClasse : tsClass = ''; const aType : tsType = '');
begin
     inherited Create;
     fValidator  := TRegExpr.Create;
     ClasseAsString := aClasse;
     TypeAsString   := aType;
end;

destructor TxPLSchema.Destroy;
begin
  fValidator.Destroy;
end;

procedure TxPLSchema.ResetValues;
begin
  ClasseAsString := '';
  TypeAsString := '';
end;

function TxPLSchema.GetClasse: TxPLSchemaClasse;
begin
     Result := TxPLSchemaClasse(AnsiIndexStr(ClasseAsString,K_XPL_CLASS_DESCRIPTORS));
end;

function TxPLSchema.GetTag: string;
begin
//     Result := IfThen (isValid, Format(K_FMT_SCHEMA,[ClasseAsString,TypeAsString]));
   Result := Format(K_FMT_SCHEMA,[ClasseAsString,TypeAsString]);
end;

procedure TxPLSchema.SetClasse(const AValue: TxPLSchemaClasse);
begin
     if aValue = Classe then exit;
     ClasseAsString := K_XPL_CLASS_DESCRIPTORS[Ord(aValue)];
end;

{function TxPLSchema.IsValid: boolean;
         function Validate(const aValue : string) : boolean;
         begin
              fValidator.Expression := K_REGEXPR_SCHEMA_ELEMENT;
              result := fValidator.Exec(aValue);
         end;
begin
  result := Validate(fType) and Validate(fClasse);
end;}

procedure TxPLSchema.SetType(const AValue: tsType);
begin
     if fType = aValue then exit;
     fType := aValue;
end;

procedure TxPLSchema.SetClasse(const AValue: tsClass);
begin
     if fClasse = aValue then exit;
     fClasse := aValue;
end;

procedure TxPLSchema.SetTag(const AValue: string);
begin
   fValidator.Expression := K_REGEXPR_SCHEMA;
   if fValidator.Exec(aValue) then begin
      fClasse := fValidator.Match[1];
      fType   := fValidator.Match[2];
   end;
end;


end.

