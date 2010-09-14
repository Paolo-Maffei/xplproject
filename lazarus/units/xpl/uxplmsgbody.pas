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
 }
{$mode objfpc}{$H+}

interface

uses uxPLSchema, Classes, uxPLBaseClass, u_xml_xpldeterminator;

type

   { TxPLMsgBody }

    TxPLMsgBody = class(TxPLBaseClass)
    private
//      fItmNames: TStringList;
//      fItmValues: TStringList;
       fSchema : txPLSchema;
       function GetRawxPL : string;
       procedure SetTag(const AValue: string); override;
     public
       property Keys     : TStringList read fItmNames;
       property Values   : TStringList read fItmValues;
       property Schema   : TxPLSchema  read FSchema;

       property RawxPL   : string      read GetRawxPL write setTag;

       constructor create; override;
       destructor  destroy; override;

       procedure ResetValues;
       procedure CleanEmptyValues;
       procedure Assign(const aBody : TxPLMsgBody); overload;

       procedure AddKeyValuePair(const aKey : string; const aValue : string);

       procedure AddKeyValue(const aKeyValuePair : string);
       function  GetValueByKey(const aKeyValue: string; aDefVal : string = '') : string;

       procedure WriteToXML(aAction : TXMLxplActionType);
       procedure ReadFromXML(aAction : TXMLxplActionType);

       // Standard described bodies ===========================================
       procedure Format_HbeatApp   (const aInterval : string; const aPort : string; const aIP : string);
       procedure Format_SensorBasic(const aDevice : string; const aType : string; const aCurrent : string);

     end;

implementation {===============================================================}
uses cStrings, sysutils, uRegExpr, uxPLConst, uRegExTools;

constructor TxPLMsgBody.create;
begin
     inherited Create;
     fClassName := 'xPLBody';

     fSchema := TxPLSchema.Create;
end;

destructor TxPLMsgBody.destroy;
begin
     Schema.Destroy;
     inherited;
end;

procedure TxPLMsgBody.ResetValues;
begin
  inherited ResetAll;
  Schema.ResetValues;
end;

procedure TxPLMsgBody.CleanEmptyValues;
var i : integer;
begin
   i := 0;
   while i<ItemCount do
      if Values[i]='' then DeleteItem(i) else inc(i);
end;

procedure TxPLMsgBody.Assign(const aBody: TxPLMsgBody);
begin
  inherited Assign(TxPLBaseClass(aBody));
  fSchema := aBody.Schema;
end;

function TxPLMsgBody.GetRawxPL: string;
const BodyLineFmt = '%s=%s'#10;
var i : integer;
begin
   result := '';
   if TxPLSchema.IsValid(Schema.Tag) then begin
      for i:= 0 to ItemCount-1 do result += Format(BodyLineFmt,[fItmNames[i],fItmValues[i]]);
      result := Format(K_MSG_BODY_FORMAT,[Schema.Tag,result]);
    end;
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

procedure TxPLMsgBody.WriteToXML(aAction : TXMLxplActionType);
var i : integer;
begin
   aAction.Msg_Schema:=Schema.Tag;
   with aAction.xplActions do
        for i:= 0 to ItemCount-1 do
            AddElement(intToStr(i)).Expression := Keys[i]+'='+Values[i];
end;

procedure TxPLMsgBody.ReadFromXML(aAction : TXMLxplActionType);
var i : integer;
    Actions : TXMLxplActionParamsType;
begin
   Schema.Tag := aAction.Msg_Schema;
   Actions := aAction.xplActions;
   for i := 0 to Actions.Count-1 do
       self.AddKeyValue(Actions.Element[i].Expression);
end;

procedure TxPLMsgBody.SetTag(const AValue: string);
begin
   ResetValues;
   with TRegExpr.Create do try
        Expression := K_RE_BODY_FORMAT;
        if Exec(StrRemoveChar(aValue,#13)) then begin
           Schema.Tag := AnsiLowerCase(Match[1]);
           Expression := K_RE_BODY_LINE;
           Exec(Match[2]);
           repeat
                 AddKeyValue(Match[1]);
           until not ExecNext;
        end;
        finally free;
     end;
end;

// Standard defined bodies ===============================================================
procedure TxPLMsgBody.Format_HbeatApp(const aInterval : string; const aPort : string; const aIP : string);
begin
   ResetAll;
   Schema.Tag := K_SCHEMA_HBEAT_APP;
   AddKeyValuePair(K_HBEAT_ME_INTERVAL,aInterval);
   AddKeyValuePair(K_HBEAT_ME_PORT    ,aPort);
   AddKeyValuePair(K_HBEAT_ME_REMOTEIP,aIP);
end;

procedure TxPLMsgBody.Format_SensorBasic(const aDevice : string; const aType : string; const aCurrent : string);
begin
   ResetAll;
   Schema.Tag := K_SCHEMA_SENSOR_BASIC;
   AddKeyValuePair('device' ,aDevice);
   AddKeyValuePair('type'   ,aType);
   AddKeyValuePair('current',aCurrent);
end;

end.

