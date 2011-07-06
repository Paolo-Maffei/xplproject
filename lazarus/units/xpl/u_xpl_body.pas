unit u_xpl_body;
{==============================================================================
  UnitName      = uxplmsgbody
  UnitDesc      = xPL Message Body management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 Rawdata passed are not transformed to lower case, Body lowers body item keys
 but not body item values.

 0.98 : Added method to clean empty body elements ('value=')
 1.02 : Added auto cut / reassemble of long body variable into multiple lines
 1.03 : Added AddKeyValuePairs
 1.04 : Class renamed TxPLBody
}

{$ifdef fpc}
   {$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , u_xpl_common
     ;

type // TxPLBody ==============================================================
     TxPLBody = class(TComponent, IxPLCommon, IxPLRaw)
        private
           fKeys,
           fValues,
           fStrings : TStringList;

           procedure AddKeyValuePair(const aKey, aValue : string);              // This one moved to private because of creation of AddKeyValuePairs
           procedure DeleteItem(const aIndex : integer);
           function  AppendItem(const aName : string) : integer;
           function GetCount: integer; inline;
           function  CheckKey(const aKey : string) : boolean;
           function  CheckValue(const aValue : string) : boolean;

           function  Get_RawxPL : string;
           function Get_Strings: TStringList;
           procedure Set_Keys(const AValue: TStringList);
           procedure Set_RawxPL(const AValue: string);
           procedure Set_Strings(const AValue: TStringList);
           procedure Set_Values(const AValue: TStringList);
        public
           constructor Create(aOwner : TComponent); override;
           destructor  Destroy; override;

           procedure Assign(Source : TPersistent); override;
           function  IsValid : boolean;
           procedure ResetValues;

           procedure CleanEmptyValues;

           procedure AddKeyValuePairs(const aKeys, aValues : TStringList); overload;
           procedure AddKeyValuePairs(const aKeys, aValues : Array of string); overload;
           procedure AddKeyValue(const aKeyValuePair : string);
           function  GetValueByKey(const aKeyValue: string; const aDefVal : string = '') : string;
           procedure SetValueByKey(const aKeyValue, aDefVal : string);

           property ItemCount : integer     read GetCount;
        published
           property Keys      : TStringList read fKeys       write Set_Keys;
           property Values    : TStringList read fValues     write Set_Values;
           property RawxPL    : string      read Get_RawxPL  write Set_RawxPL  stored false;
           property Strings   : TStringList read Get_Strings write Set_Strings stored false;
        end;

implementation // =============================================================
uses sysutils
     , strutils
     , uxPLConst
     ;

type StringArray = Array of string;

// ============================================================================
const MAX_KEY_LEN   = 16;                                                       // xPL Rule : http://xplproject.org.uk/wiki/index.php?title=XPL_Specification_Document
      MAX_VALUE_LEN = 128;                                                      // xPL Rule : http://xplproject.org.uk/wiki/index.php?title=XPL_Specification_Document

//=============================================================================
function StrCutBySize(const aString : string; const size : integer) : StringArray;
var c,i : integer;
    s   : string;
begin
   c := Succ(Pred(length(aString)) div size);
   SetLength(Result,c);
   i := 0;
   while ( i < c ) do begin
      s := AnsiMidStr(aString, i*size+1, size);
      Result[i] := s;
      inc(i);
   end;
end;

// TxPLBody ===================================================================
constructor TxPLBody.Create(aOwner : TComponent);
begin
   inherited;
   include(fComponentStyle,csSubComponent);

   fKeys   := TStringList.Create;
   fValues := TStringList.Create;
end;

destructor TxPLBody.destroy;
begin
   fValues.Free;
   fKeys.Free;
   if Assigned(fStrings) then fStrings.Free;

   inherited;
end;

function TxPLBody.GetCount: integer;
begin
   result := fKeys.Count;
end;

function TxPLBody.CheckKey(const aKey: string): boolean;
begin
   result := IsValidxPLIdent(aKey) and (length(aKey)<=MAX_KEY_LEN);
end;

function TxPLBody.CheckValue(const aValue: string): boolean;
begin
   result := length(aValue) <= MAX_VALUE_LEN;
end;

procedure TxPLBody.ResetValues;
begin
   Keys.Clear;
   Values.Clear;
end;

procedure TxPLBody.DeleteItem(const aIndex: integer);
begin
   Keys.Delete(aIndex);
   Values.Delete(aIndex);
end;

function TxPLBody.AppendItem(const aName : string) : integer;
begin
   result := Keys.Add(aName);
   Values.Add('');
end;

procedure TxPLBody.Set_Values(const AValue: TStringList);
var i : integer;
begin
   for i := 0 to aValue.Count-1 do
      if not CheckValue(aValue[i]) then exit;

   Values.Assign(aValue);
end;

procedure TxPLBody.Set_Keys(const AValue: TStringList);
var i : integer;
begin
   for i := 0 to aValue.Count-1 do
       if not CheckKey(aValue[i]) then exit;

   Keys.Assign(aValue);
end;

procedure TxPLBody.Assign(Source : TPersistent);
begin
   if Source is TxPLBody then begin
      Keys.Assign(TxPLBody(Source).Keys);
      Values.Assign(TxPLBody(Source).Values);
   end else inherited;
end;

function TxPLBody.IsValid: boolean;
begin
   result := Values.Count > 0;
end;

procedure TxPLBody.CleanEmptyValues;
var i : integer;
begin
   i := 0;
   while i<ItemCount do
         if Values[i]='' then DeleteItem(i) else inc(i);
end;

function TxPLBody.Get_RawxPL: string;
var i : integer;
begin
   result := '';

   for i:= 0 to ItemCount-1 do begin
       result := Result + Keys[i] + '=';
       if i<Values.Count then result := Result + Values[i];
       result := Result + #10;
   end;
   result := Format(K_MSG_BODY_FORMAT,[result]);
end;

function TxPLBody.Get_Strings: TStringList;
begin
   if not Assigned(fStrings) then fStrings := TStringList.Create;
   fStrings.Text:=AnsiReplaceStr(RawxPl,#10,#13);
   result := fStrings;
end;

procedure TxPLBody.Set_Strings(const AValue: TStringList);
begin
   RawxPL := AnsiReplaceStr(aValue.Text,#13,#10);
end;

function TxPLBody.GetValueByKey(const aKeyValue: string; const aDefVal : string = '') : string;
var c,i : integer;
begin
   i := Keys.IndexOf(aKeyValue);
   if i>=0 then begin
                result := Values[i];
                for c:=i+1 to Keys.Count-1 do                                  // 1.02 : iterate through other parameters
                    if Keys[c]=aKeyValue then result := Result + Values[c]     // to find other lines with the same key
           end
           else result := aDefVal;
end;

procedure TxPLBody.SetValueByKey(const aKeyValue, aDefVal : string);
var i : integer;
begin
   if not CheckValue(aDefVal) then exit;

   i := Keys.IndexOf(aKeyValue);
   if i>=0 then Values[i] := aDefVal;
end;

procedure TxPLBody.AddKeyValuePairs(const aKeys, aValues : TStringList);
var i : integer;
begin
   for i := 0 to aKeys.Count-1 do AddKeyValuePair(aKeys[i],aValues[i]);
end;

procedure TxPLBody.AddKeyValuePairs(const aKeys, aValues: array of string);
var i : integer;
begin
   for i := Low(aKeys) to High(aKeys) do AddKeyValuePair(aKeys[i],aValues[i]);
end;

procedure TxPLBody.AddKeyValuePair(const aKey, aValue: string);
var i,c : integer;
    s : StringArray;
begin
   if not CheckKey(aKey) then exit;

   s := StrCutBySize(aValue,MAX_VALUE_LEN);
   for c:=low(s) to high(s) do begin                                            // 1.02 : iterate till we reach the end
      i := AppendItem(aKey);                                                    // of a string potentially longueur than 128 char
      Values[i] := s[c];
   end;
end;

procedure TxPLBody.AddKeyValue(const aKeyValuePair: string);
var i : integer;
begin
   i := AnsiPos(K_BODY_ELMT_DELIMITER,aKeyValuePair);
   if i <> 0 then AddKeyValuePair( AnsiLowerCase(Copy(aKeyValuePair,0,i-1)) ,
                                   Copy(aKeyValuePair,i+1,length(aKeyValuePair)-i + 1));
end;

procedure TxPLBody.Set_RawxPL(const AValue: string);
var sl : tstringlist;
    ch : string;
begin
   ResetValues;
   sl := TStringList.Create;
   sl.Delimiter:=#10;                                                          // use LF as delimiter
   sl.StrictDelimiter := true;
   sl.DelimitedText:=AnsiReplaceStr(aValue,#13,'');                            // get rid of CR
//   sl.Delete(0);                                                               // Drop leading {
//   sl.Delete(Pred(sl.count));                                                  // Drop trailing }
   for ch in sl do if (length(ch)>0) then AddKeyValue(ch);
   sl.free;
end;

initialization
   Classes.RegisterClass(TxPLBody);

end.

