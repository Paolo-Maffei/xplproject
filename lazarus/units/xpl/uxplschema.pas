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
}
{$mode objfpc}{$H+}
interface

uses RegExpr;

type
    TxPLSchemaClasse = ( xpl_scHBeat,    xpl_scConfig,  xpl_scAudio,   xpl_scControl,
                         xpl_scDateTime, xpl_scDb,      xpl_scDGuide,  xpl_scCID,
                         xpl_scOSD,      xpl_scRemote,  xpl_scSendMsg, xpl_scSensor,
                         xpl_scTTS,      xpl_scUps,     xpl_scWebCam,  xpl_scX10,
                         xpl_scOther );

    TxPLSchema = class
    private
      fClasse : string;
      fType   : string;
      fValidator : TRegExpr;

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
      Destructor  Destroy; override;

      function  IsValid : boolean;
      procedure ResetValues;
    end;

const K_REGEXPR_SCHEMA_ELEMENT = '([0-9a-z/-]{1,8})';
      K_XPL_CLASS_DESCRIPTORS : Array[0..15] of string = (
                                      'hbeat','config','audio','control','datetime',
                                      'db','dguide','cid','osd','remote','sendmsg',
                                      'sensor','tts','ups','webcam','x10' );

implementation { ==============================================================}
uses StrUtils, SysUtils;

const K_REGEXPR_SCHEMA = K_REGEXPR_SCHEMA_ELEMENT + '\.' + K_REGEXPR_SCHEMA_ELEMENT;

constructor TxPLSchema.Create(const aClasse : string = ''; const aType : string = '');
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
     Result := IfThen (isValid, ClasseAsString + '.' + TypeAsString);
end;

procedure TxPLSchema.SetClasse(const AValue: TxPLSchemaClasse);
begin
     if aValue = Classe then exit;
     ClasseAsString := K_XPL_CLASS_DESCRIPTORS[Ord(aValue)];
end;

function TxPLSchema.IsValid: boolean;
         function Validate(const aValue : string) : boolean;
         begin
              fValidator.Expression := K_REGEXPR_SCHEMA_ELEMENT;
              result := fValidator.Exec(aValue);
         end;
begin
  result := Validate(fType) and Validate(fClasse);
end;

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
     fValidator.Expression := K_REGEXPR_SCHEMA;
     if fValidator.Exec(aValue) then begin
        fClasse := fValidator.Match[1];
        fType   := fValidator.Match[2];
     end;
end;


end.

