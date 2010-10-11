unit uxplmsgbody;
{==============================================================================
  UnitName      = uxplmsgbody
  UnitDesc      = xPL Message Body management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Added XMLWrite and read method
 0.95 : Modified XML read / write format
 0.96 : Rawdata passed are no longer transformed to lower case, then Body lowers schema, type and body item keys but not body item values
 0.97 : Use of uxPLConst
 0.98 : Added method to clean empty body elements ('value=')
 0.99 : Switched local type of xml writing to use u_xml_xpldeterminator
 1.01 : Switched schema from Body to Header
}
{$mode objfpc}{$H+}

interface

uses Classes,
     uxPLBaseClass,
     u_xml_xpldeterminator,
     u_xml_xplplugin;

type

   { TxPLMsgBody }

    TxPLMsgBody = class(TxPLBaseClass)
    private
//      fItmNames: TStringList;
//      fItmValues: TStringList;
       function GetRawxPL : string;
       procedure SetTag(const AValue: string); //override;
     public
       property Keys     : TStringList read fItmNames;
       property Values   : TStringList read fItmValues;
       property RawxPL   : string      read GetRawxPL write setTag;

//       constructor create; override;

       procedure ResetValues;
       procedure CleanEmptyValues;
//       procedure Assign(const aBody : TxPLMsgBody); overload;

       procedure AddKeyValuePair(const aKey : string; const aValue : string);

       procedure AddKeyValue(const aKeyValuePair : string);
       function  GetValueByKey(const aKeyValue: string; aDefVal : string = '') : string;

       procedure WriteToXML (const aAction : TXMLxplActionType);
       procedure ReadFromXML(const aAction : TXMLxplActionType); overload;
       procedure ReadFromXML(const aCom    : TXMLCommandType  ); overload;
     end;

implementation {===============================================================}
uses cStrings, sysutils, uRegExpr, uxPLConst;

{constructor TxPLMsgBody.create;
begin
     inherited Create;
     fClassName := 'xPLBody';
end;}

procedure TxPLMsgBody.ResetValues;
begin
  inherited ResetAll;
//  Schema.ResetValues;
end;

procedure TxPLMsgBody.CleanEmptyValues;
var i : integer;
begin
   i := 0;
   while i<ItemCount do
      if Values[i]='' then DeleteItem(i) else inc(i);
end;

{procedure TxPLMsgBody.Assign(const aBody: TxPLMsgBody);
begin
  inherited Assign(TxPLBaseClass(aBody));
end;}

function TxPLMsgBody.GetRawxPL: string;
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
function TxPLMsgBody.GetValueByKey(const aKeyValue: string; aDefVal : string = '') : string;
var i : integer;
begin
     i := Keys.IndexOf(aKeyValue);
     if i>=0 then result := Values[i]
             else result := aDefVal;
end;

procedure TxPLMsgBody.AddKeyValuePair(const aKey: string; const aValue: string);
var i : integer;
begin
     if aKey = '' then exit;
     i := AppendItem(aKey,'(.*)');
     fItmValues[i] := aValue;
end;

procedure TxPLMsgBody.AddKeyValue(const aKeyValuePair: string);
var left, right : string;
begin
     if  AnsiPos('=',aKeyValuePair) = 0  then exit;
     left := '';
     right := '';
     StrSplitAtChar(aKeyValuePair,'=',left,right);
     AddKeyValuePair(AnsiLowerCase(left),right);
end;

procedure TxPLMsgBody.WriteToXML(const aAction : TXMLxplActionType);
var i : integer;
begin
   with aAction.xplActions do
        for i:= 0 to ItemCount-1 do
            AddElement(intToStr(i)).Expression := Keys[i]+'='+Values[i];
end;

procedure TxPLMsgBody.ReadFromXML(const aAction : TXMLxplActionType);
var i : integer;
    Actions : TXMLxplActionParamsType;
begin
   Actions := aAction.xplActions;
   for i := 0 to Actions.Count-1 do
       AddKeyValue(Actions.Element[i].Expression);
end;

procedure TxPLMsgBody.ReadFromXML(const aCom: TXMLCommandType);
var i : integer;
begin
   for i := 0 to aCom.elements.Count-1 do
       AddKeyValuePair(aCom.Elements[i].Name, aCom.Elements[i].default_);
end;

procedure TxPLMsgBody.SetTag(const AValue: string);
begin
   ResetValues;
   with TRegExpr.Create do try
        Expression := K_RE_BODY_FORMAT;
        if Exec(StrRemoveChar(aValue,#13)) then begin
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

