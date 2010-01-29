unit uxPLSchema;
{==============================================================================
  UnitName      = uxPLSchema
  UnitVersion   = 0.91
  UnitDesc      = xPL Schema management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : first published version
 0.95 : Regular expression added
 0.96 : Simplification of the class (cut inheritance of TxPLBaseClass)
 0.97 : Usage of uxPLConst
        Dropped usage of RegExp, to heavy for such a simple thing
}
{$mode objfpc}{$H+}
interface

uses uxPLConst;

type
    TxPLSchema = class
    private
      fClasse : string;
      fType   : string;
      //fValidator : TRegExpr;

      function  GetClasse: TxPLSchemaClasse;
      function  GetTag: string;
      procedure SetClasse(const AValue: TxPLSchemaClasse);
      procedure SetClasse(const AValue: string);
      procedure SetTag   (const AValue: string);
      procedure SetType  (const AValue: string);
    public
      property Classe         : TxPLSchemaClasse read GetClasse write SetClasse;
      property ClasseAsString : string read fClasse write SetClasse;
      property TypeAsString   : string read fType   write SetType;
      property Tag            : string read GetTag  write SetTag;

      Constructor Create(const aClasse : string = ''; const aType : string = '');
      //Destructor  Destroy; override;

      //function  IsValid : boolean;
      procedure ResetValues;
    end;

implementation { ==============================================================}
uses StrUtils, SysUtils, cStrings;

constructor TxPLSchema.Create(const aClasse : string = ''; const aType : string = '');
begin
     inherited Create;
     //fValidator  := TRegExpr.Create;
     ClasseAsString := aClasse;
     TypeAsString   := aType;
end;

//destructor TxPLSchema.Destroy;
//begin
//  fValidator.Destroy;
//end;

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

procedure TxPLSchema.SetType(const AValue: string);
begin
     if fType = aValue then exit;
     fType := aValue;
end;

procedure TxPLSchema.SetClasse(const AValue: string);
begin
     if fClasse = aValue then exit;
     fClasse := aValue;
end;

procedure TxPLSchema.SetTag(const AValue: string);
begin
   StrSplitAtChar(aValue,'.',fClasse,fType);
     //fValidator.Expression := K_REGEXPR_SCHEMA;
     //if fValidator.Exec(aValue) then begin
     //   fClasse := fValidator.Match[1];
     //   fType   := fValidator.Match[2];
     //end;
end;


end.

