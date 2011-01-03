unit uxplmsgbody;
{==============================================================================
  UnitName      = uxplmsgbody
  UnitDesc      = xPL Message Body management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.96 : Rawdata passed are no longer transformed to lower case, then Body lowers
        schema, type and body item keys but not body item values
 0.97 : Use of uxPLConst
 0.98 : Added method to clean empty body elements ('value=')
 1.01 : Switched schema from Body to Header
 1.02 : Added auto cut / reassemble of long body variable into multiple lines
        Removed usage of cStrings
 1.03 : Added AddKeyValuePairs
 1.04 : Class renamed TxPLBody
}
{$mode objfpc}{$H+}

interface

uses Classes,
     uxPLBaseClass;

type TxPLBody = class(TxPLBaseClass)
        private
           function GetRawxPL : string;
           procedure SetRawxPL(const AValue: string);
           procedure AddKeyValuePair(const aKey, aValue : string);              // This one moved to private because of creation of AddKeyValuePairs
        public
           property Keys     : TStringList read fItmNames;
           property Values   : TStringList read fItmValues;
           property RawxPL   : string      read GetRawxPL write SetRawxPL;

           procedure ResetValues;
           procedure CleanEmptyValues;

           procedure AddKeyValuePairs(const aKeys, aValues : array of string);
           procedure AddKeyValue(const aKeyValuePair : string);
           function  GetValueByKey(const aKeyValue: string; const aDefVal : string = '') : string;
           procedure SetValueByKey(const aKeyValue, aDefVal : string);
//           procedure ReadFromTable(const id : integer; const tbBody : string);
(*           procedure WriteToXML (const aAction : TXMLxplActionType);
           procedure ReadFromXML(const aAction : TXMLxplActionType); overload;
           procedure ReadFromXML(const aCom    : TXMLCommandType  ); overload;*)
        end;

implementation {===============================================================}
uses sysutils,
     strutils,
     uRegExpr,
     uxPLConst;

type StringArray = Array of string;

//==============================================================================
function StrCutBySize(const aString : string; const size : integer) : StringArray;
var c,i : integer;
    s   : string;
begin
   c := length(aString) div size + 1;
   SetLength(Result,c);
   i := 0;
   while ( i < c ) do begin
      s := AnsiMidStr(aString, i*size+1, size);
      Result[i] := s;
      inc(i);
   end;
end;

// TxPLBody ================================================================
procedure TxPLBody.ResetValues;
begin
   inherited ResetAll;
end;

procedure TxPLBody.CleanEmptyValues;
var i : integer;
begin
   i := 0;
   while i<ItemCount do
      if Values[i]='' then DeleteItem(i) else inc(i);
end;

function TxPLBody.GetRawxPL: string;
const BodyLineFmt = '%s=%s'#10;
var i : integer;
begin
   result := '';
   for i:= 0 to ItemCount-1 do result += Format(BodyLineFmt,[fItmNames[i],fItmValues[i]]);
   result := Format(K_MSG_BODY_FORMAT,[result]);
end;

{------------------------------------------------------------------------
 GetValueByKey :
   Retrieves the value of a body element, based on the name of its key.
   If the name is not found.
   IN  :  aKeyValue : name of the searched key
          aDefVal   : value returned if not found
   OUT : found value or default value
 ------------------------------------------------------------------------}
function TxPLBody.GetValueByKey(const aKeyValue: string; const aDefVal : string = '') : string;
var c,i : integer;
begin
   i := Keys.IndexOf(aKeyValue);
   if i>=0 then begin
                result := Values[i];
                for c:=i+1 to Keys.Count-1 do                                   // 1.02 : iterate through other parameters
                    if Keys[c]=aKeyValue then result += Values[c]               // to find other lines with the same key
           end
           else result := aDefVal;
end;

procedure TxPLBody.SetValueByKey(const aKeyValue, aDefVal : string);
var i : integer;
begin
   i := Keys.IndexOf(aKeyValue);
   if i>=0 then Values[i] := aDefVal;
end;


procedure TxPLBody.AddKeyValuePairs(const aKeys, aValues : Array of string);
var i : integer;
begin
   for i := low(aKeys) to High(aKeys) do AddKeyValuePair(aKeys[i],aValues[i]);
end;

procedure TxPLBody.AddKeyValuePair(const aKey: string; const aValue: string);
var i,c : integer;
    s : StringArray;
begin
   if aKey = '' then exit;
   s := StrCutBySize(aValue,K_BODY_ELMT_VALUE_MAX_LEN);
   for c:=low(s) to high(s) do begin                                            // 1.02 : iterate till we reach the end
      i := AppendItem(aKey,'(.*)');                                             // of a string potentially longueur than 128 char
      fItmValues[i] := s[c];
   end;
end;

procedure TxPLBody.AddKeyValue(const aKeyValuePair: string);
var i : integer;
begin
   i := AnsiPos(K_BODY_ELMT_DELIMITER,aKeyValuePair);
   if i <> 0 then AddKeyValuePair( AnsiLowerCase(Copy(aKeyValuePair,0,i-1)) ,
                                   Copy(aKeyValuePair,i+1,length(aKeyValuePair)-i + 1));
end;

(*procedure TxPLBody.WriteToXML(const aAction : TXMLxplActionType);
var i : integer;
begin
   for i:= 0 to ItemCount-1 do
       aAction.xplActions.AddElement(intToStr(i)).Expression := Keys[i] + K_BODY_ELMT_DELIMITER + Values[i];
end;

procedure TxPLBody.ReadFromXML(const aAction : TXMLxplActionType);
var i : integer;
begin
   for i := 0 to aAction.xplActions.Count-1 do
       AddKeyValue(aAction.xplActions.Element[i].Expression);
end;

procedure TxPLBody.ReadFromXML(const aCom: TXMLCommandType);
var i : integer;
begin
   for i := 0 to aCom.elements.Count-1 do
       AddKeyValuePair(aCom.Elements[i].Name, aCom.Elements[i].default_);
end;*)

procedure TxPLBody.SetRawxPL(const AValue: string);
begin
   ResetValues;
   with TRegExpr.Create do try
        Expression := K_RE_BODY_FORMAT;
        if Exec(AnsiReplaceStr(aValue,#13,'')) then begin
           Expression := K_RE_BODY_LINE;
           Exec(Match[1]);
           repeat
                 AddKeyValue(Match[1]);
           until not ExecNext;
        end;
        finally free;
     end;
end;

end.

