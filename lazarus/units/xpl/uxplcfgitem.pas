unit uxplcfgitem;
{==============================================================================
  UnitName      = uxplcfgitem
  UnitVersion   = 0.9
  UnitDesc      = xPL Configuration Element Management Object
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================}
{$mode objfpc}{$H+}
interface

uses Classes;

Type TxPLConfigType = (xpl_ctConfig, xpl_ctReconf, xpl_ctOption);

     { TxPLConfigItem }

     TxPLConfigItem = class
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
           constructor create(aKey,aValue : string; aCT : TxPLConfigType; aMax : integer; aDescription , aFormat : string);
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

const K_REGEXPR_CFG_KEY   = '^([_a-z\d]{1,16})$';

implementation { TxPLConfigItem ==================================================================}
uses SysUtils, RegExpr;

const K_XPL_CONFIGOPTIONS : Array[0..2] of string = ('config','reconf','option');

{ ================================================================================================}
constructor TxPLConfigItem.Create(aKey,aValue : string; aCT : TxPLConfigType; aMax : integer; aDescription , aFormat : string);
var bConformKey : boolean;
begin
     with TRegExpr.Create do begin
          try
             Expression := K_REGEXPR_CFG_KEY;
             bConformKey := Exec(aKey);
          finally
             free;
          end;
     end;
     if not bConformKey then Raise Exception.CreateFmt('Invalid configuration key format : ''%s''', [aKey]);

     fKey := aKey;
     fConfigType := aCT;
     fValues := TStringList.Create;
     fValues.Duplicates := dupIgnore;
     fDescription := aDescription;
     fFormat      := aFormat;
     MaxValue := aMax;
     SetValue(aValue);
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

