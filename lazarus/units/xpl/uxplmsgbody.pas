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
 }
{$mode objfpc}{$H+}

interface

uses uxPLSchema, Classes, DOM, uxPLBaseClass;

type

    { TxPLMsgBody }

    TxPLMsgBody = class(TxPLBaseClass)
    private
       fSchema : txPLSchema;
       // *** Items declared to the helper class ***
       //fLabels : TStringList;
       //fOptions: TStringList;
       //fVisCond: TStringList;
       //fOpLabels : TStringList;
       // ***
       function GetRawxPL : string;
       procedure SetTag(const AValue: string); virtual;
     public
       property Keys     : TStringList read fItmNames;
       property Values   : TStringList read fItmValues;
       property Schema   : TxPLSchema  read FSchema;

       //property Labels   : TStringList read fLabels;
       //property Options  : TStringList read FOptions;
       //property VisCond  : TStringList read FVisCond;
       //property OpLabels : TStringList read FOpLabels;

       property RawxPL   : string      read GetRawxPL write setTag;

       constructor create; override;
       destructor  destroy; override;

       procedure ResetValues;
       procedure Assign(const aBody : TxPLMsgBody); overload;
       function  IsValid : boolean; override;

//       procedure AddKeyValuePair(const aKey : string; aValue: string);
       procedure AddKeyValuePair(const aKey : string; aValue: string); //aLabel : string = ''; aOption : string = ''; aVisCond : string = ''; aOpLabel : string = ''; aRegExp : string = '(.*)'); overload;

       procedure AddKeyValue(const aKeyValuePair: string);
       function  GetValueByKey(const aKeyValue: string; aDefVal : string = '') : string;

       procedure WriteToXML(const aParent : TDOMNode; const aDoc : TXMLDocument); overload;
       procedure ReadFromXML(const aParent : TDOMNode);

       // Standard described bodies ===========================================
       procedure Format_HbeatApp   (const aInterval : string; const aPort : string; const aIP : string);
       procedure Format_SensorBasic(const aDevice : string; const aType : string; const aCurrent : string);
     end;

     { TxPLMsgBodyHelper }
     {
     TxPLMsgBodyHelper = class(TxPLMsgBody)
     public
       constructor create; override;
       destructor  destroy; override;
       procedure ResetValues; overload;
       procedure Assign(const aBody : TxPLMsgBodyHelper); overload;
       procedure ReadFromXML(const aParent : TDOMNode);
     end;}

implementation {===============================================================}
uses cStrings, sysutils, cUtils, RegExpr, uxPLConst;

constructor TxPLMsgBody.create;
begin
     inherited Create;
     fClassName := 'xPLBody';

     fSchema := TxPLSchema.Create;
     //fLabels := TStringList.Create;
     //fOptions:= TStringList.Create;
     //fVisCond:= TStringList.Create;
     //fOpLabels := TStringList.Create;
end;

destructor TxPLMsgBody.destroy;
begin
     Schema.Destroy;
//     Labels.Destroy;
//     Options.Destroy;
//     VisCond.Destroy;
//     OpLabels.Destroy;
     inherited;
end;

function TxPLMsgBody.IsValid: boolean;
begin result := Schema.IsValid; end;

procedure TxPLMsgBody.ResetValues;
begin
  inherited ResetAll;
  Schema.ResetValues;
//  Labels.Clear;
//  Options.Clear;
//  OpLabels.Clear;
//  VisCond.Clear;
end;

procedure TxPLMsgBody.Assign(const aBody: TxPLMsgBody);
begin
  inherited Assign(TxPLBaseClass(aBody));
  fSchema := aBody.Schema;

{  for i:=0 to aBody.ItemCount-1 do begin
      fLabels.Add(aBody.Labels[i]);
      fOptions.Add(aBody.Options[i]);
      fVisCond.Add(aBody.VisCond[i]);
      fOpLabels.Add(aBody.VisCond[i]);
  end;}
end;

function TxPLMsgBody.GetRawxPL: string;
var i : integer;
begin
   result := '';
   if Schema.IsValid then result := Schema.Tag;
   result += #10'{'#10;
//    result := Schema.Tag + #10'{'#10;

    for i:= 0 to ItemCount-1 do result += fItmNames[i] + '=' + fItmValues[i] + #10;

    result += ('}'#10);
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

procedure TxPLMsgBody.AddKeyValuePair(const aKey: string; aValue: string);
//  aLabel: string; aOption: string; aVisCond: string; aOpLabel: string;
//  aRegExp: string);
var i : integer;
begin
     if aKey = '' then exit;
     i := AppendItem(aKey,'(.*)');
     fItmValues[i] := aValue;
//  fLabels.Add(aLabel);
//  fOptions.Add(aOption);
//  fVisCond.Add(aVisCond);
//  fOpLabels.Add(aOpLabel);

end;

procedure TxPLMsgBody.AddKeyValue(const aKeyValuePair: string);
var left, right : string;
begin
     left := '';
     right := '';
     StrSplitAtChar(aKeyValuePair,'=',left,right);
     AddKeyValuePair(AnsiLowerCase(left),right);
end;

procedure TxPLMsgBody.WriteToXML(const aParent: TDOMNode; const aDoc: TXMLDocument);
var EltsNode : TDOMNode;
    i : integer;
begin
     TDOMElement(aParent).SetAttribute('msg_schema',Schema.Tag);
     for i := 0 to ItemCount-1 do begin
         EltsNode := aDoc.CreateElement('element');
         aParent.AppendChild(EltsNode);
         TDOMElement(EltsNode).SetAttribute('name',Self.Keys[i]);
         TDOMElement(EltsNode).SetAttribute('value',Self.Values[i]);
     end;
end;

procedure TxPLMsgBody.ReadFromXML(const aParent: TDOMNode);
var value, key : string;
    Child,OpNode : TDOMNode;
//    sviscond, sregexpr, descr,
    defval, sOptions, sLabels : string;

begin
{     Schema.Tag := TDOMElement(aParent).GetAttribute('msg_schema');
     Child := TDOMElement(aParent).FirstChild;
     while Assigned(Child) do begin
           if Child.NodeName = 'element' then begin
              key := TDOMElement(Child).GetAttribute('name');
              value := TDOMElement(Child).GetAttribute('value');
              AddKeyValuePair(key, value);
           end;
           Child := Child.NextSibling;
     end;}
     Schema.Tag := TDOMElement(aParent).GetAttribute('msg_schema');
     Child := TDOMElement(aParent).FirstChild;
     while Assigned(Child) do begin
           if Child.NodeName = 'element' then begin
              key := TDOMElement(Child).GetAttribute('name');
              value := TDOMElement(Child).GetAttribute('value');
              defval := TDOMElement(Child).GetAttribute('default');
//              descr  := TDOMElement(Child).GetAttribute('label');
              if ((value='') and (defval<>'')) then value := defval;
              sOptions := '';
              sLabels  := '';
//              sRegExpr := '(.*)';              // default regexpr
              OpNode := TDOMElement(Child).FirstChild;
              while Assigned(OpNode) do begin
                    if OpNode.NodeName = 'choices' then begin
                       OpNode := TDOMElement(OpNode).FirstChild;
                    end;
                    if OpNode.NodeName = 'option' then begin
                       sOptions := '|' + TDOMElement(OpNode).GetAttribute('value') + '|,' + sOptions ;
                       sLabels  := '|' + TDOMElement(OpNode).GetAttribute('label') + '|,' + sLabels;
                    end;
                    if OpNode.NodeName = 'regexp' then begin
//                       sRegExpr := TDomElement(OpNode).FirstChild.NodeValue;
                    end;
                    OpNode := OpNode.NextSibling;
              end;
//              sviscond := '';
//              if TDOMElement(Child).GetAttribute('conditional-visibility') <> '' then begin
//                 sviscond := TDOMElement(Child).GetAttribute('conditional-visibility');
//              end;
              AddKeyValuePair(key, value); //, descr, sOptions,sviscond, sLabels, sRegExpr);
           end;
           Child := Child.NextSibling;
     end;

end;

procedure TxPLMsgBody.SetTag(const AValue: string);
var i : integer;
    s : string;
    arrStr : StringArray;
begin
     ResetValues;
     with TRegExpr.Create do try
     Expression := K_RE_BODY_FORMAT;
          if Exec(aValue) then begin
             Schema.Tag := AnsiLowerCase(Match[1]);
             s := Match[2];
             arrStr := StrSplit(s,#10);
             for i:=0 to High(arrStr) do
                 if arrStr[i]<>'' then AddKeyValue(arrStr[i]);
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

{ TxPLMsgBodyHelper }
{

procedure TxPLMsgBodyHelper.Assign(const aBody: TxPLMsgBodyHelper);
begin
end;

procedure TxPLMsgBodyHelper.AddKeyValuePair(const aKey: string; aValue: string;
  aLabel: string; aOption: string; aVisCond: string; aOpLabel: string;
  aRegExp: string);
begin
  inherited AddKeyValuePair(aKey,aValue);
end;

procedure TxPLMsgBodyHelper.ReadFromXML(const aParent: TDOMNode);
begin
end;}

end.

