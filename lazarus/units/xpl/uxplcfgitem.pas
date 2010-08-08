unit uxplcfgitem;
{==============================================================================
  UnitName      = uxplcfgitem
  UnitVersion   = 0.92
  UnitDesc      = xPL Configuration Element Management Object
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.92 : Removal of format and descriptions from this unit, they shall be handled from PluginFile
 0.93 : Usage of uxPLConst
}
{$mode objfpc}{$H+}
interface

uses Classes, uxPLConst;

Type TxPLConfigItem = class
        private
           fKey         : string;
           fDescription : string;
           fFormat      : string;
           fMaxValue    : integer;
           fConfigType  : TxPLConfigType;
           fValues      : TStringList;

           function GetConfigTypeAsString: string;
           function GetMaxValueAsString: string;
           function GetValueCount: integer;
           procedure SetMaxValue(aValue : integer);
           function GetValue   : string;
           function CheckValid(aValue : string) : boolean;
        public
           constructor create(const aKey : string; const aValue : string; aCT : TxPLConfigType; const aMax : integer = 1);
           constructor create(const aKey : string; const aValue : string; aCT : TxPLConfigType; aDescription , aFormat : string; const aMax : integer = 1 ); overload;
           destructor  destroy; override;

           procedure Clear;

           property MaxValueAsString : string read GetMaxValueAsString;
           property ValueCount : integer read GetValueCount;
           property Value    : string  read GetValue;
           property Values   : TStringList read fValues;

           property Key         : string  read fKey;
           property Description : string  read fDescription;
           property Format      : string  read fFormat;
           property MaxValue    : integer read fMaxValue write SetMaxValue;

           property ConfigTypeAsString : string read GetConfigTypeAsString;
           function SetValue(aValue : string) : boolean;
           function AsInteger : integer;
        end;

implementation { TxPLConfigItem ==================================================================}
uses SysUtils, RegExpr;

{ ================================================================================================}
constructor TxPLConfigItem.Create(const aKey : string; const aValue : string; aCT : TxPLConfigType; const aMax : integer = 1{; aDescription , aFormat : string});
begin
     fKey := aKey;
     fConfigType := aCT;
     fValues := TStringList.Create;
     fValues.Duplicates := dupIgnore;
     fDescription := '';
     fFormat      := '';
     MaxValue := aMax;
     SetValue(aValue);
end;

constructor TxPLConfigItem.create(const aKey: string; const aValue: string; aCT: TxPLConfigType; aDescription, aFormat: string; const aMax: integer );
begin
     Create(aKey,aValue,aCT,aMax);
     fDescription := aDescription;
     fFormat      := aFormat;
end;

destructor TxPLConfigItem.destroy;
begin
     fValues.Destroy;
end;

procedure TxPLConfigItem.SetMaxValue(aValue: integer);
var i : integer;
begin
  if (fMaxValue = aValue) or (aValue < 1) then exit;

  fMaxValue := aValue;
  for i:=0 to MaxValue-1 do fValues.Add('');
end;

procedure TxPLConfigItem.Clear;
var i : integer;
begin
     for i:=0 to MaxValue-1 do Values[i]:='';
end;

function TxPLConfigItem.GetMaxValueAsString: string;
begin
  result := '';
  if MaxValue<>1 then result := '[' + IntToStr(MaxValue) + ']';
end;

function TxPLConfigItem.GetValueCount: integer;
var i : integer;
begin
     i := 0;
     repeat
           inc(i);
     until ((i>= MaxValue) or (Values[i]='')) ;

     result := i;
end;

function TxPLConfigItem.GetConfigTypeAsString: string;
begin result := K_XPL_CONFIGOPTIONS[Ord(fConfigType)]; end;

function TxPLConfigItem.GetValue: string;
begin result := fValues[0]; end;

function TxPLConfigItem.AsInteger: integer;
begin result := StrToInt(Value); end;

function TxPLConfigItem.SetValue(aValue: string) : boolean;
var i : integer;
begin
     Result := True;
     if Value=aValue then exit;

     Result := CheckValid(aValue);
     if not Result then exit;

     if MaxValue = 1 then fValues[0] := aValue
                  else begin
                       if fValues.IndexOf(aValue)=-1 then begin
                          i := ValueCount;
                          if (i = 1) and (fValues[0]='') then i:=0;
                          fValues[i] := aValue;
                       end;
                  end;
end;

function TxPLConfigItem.CheckValid(aValue : string) : boolean;
begin
   result := true;
   if not (fFormat<>'') then exit;

   with TRegExpr.Create do
        try
           Expression := fFormat;
           result := Exec(aValue);
        finally
           free;
   end;
end;


end.

