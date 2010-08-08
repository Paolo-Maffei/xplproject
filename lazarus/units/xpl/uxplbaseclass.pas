unit uxPLBaseClass;
{==============================================================================
  UnitName      = uxplbaseclass
  UnitDesc      = a foundation class used to enable loading, storing of self parameters
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.98 : String constants removed to uxPLConst
        Removed requirement of cStrings units
 }

{$mode objfpc}{$H+}

interface

uses Classes, DOM, RegExpr;

type

{ TxPLBaseClass }

TxPLBaseClass = class(TComponent)
     private
       function GetCount: integer;
     protected
        fClassName : string;
        fFormatString : string;
        fRegExpString : string;

        fItmNames  : TStringList;
        fItmValues : TStringList;
        fRegExpr   : TStringList;

        Validator  : TRegExpr;

        function  GetTag: string;                                       virtual;
        procedure SetTag(const AValue: string);                         virtual;
        procedure SetString(const AIndex: integer; const AValue: string);
        function  GetString(const AIndex: integer) : string;            virtual;

     public
        constructor Create; virtual;
        destructor  destroy; override;

        property  Tag : string read GetTag write SetTag;
        property  Items : TStringList read fItmValues;
        property  Keys  : TStringList read fItmNames;
        property  ItemCount : integer read GetCount;

        procedure ResetValues;
        procedure ResetAll;
        procedure Assign(aBaseClass : TxPLBaseClass); virtual;

        function  AppendItem(const aName : string; const aReg : string) : integer;
        procedure DeleteItem(const aIndex : integer);
        function  Equals(aBaseClass : TxPLBaseClass) : boolean; virtual;
        function  IsValid : boolean; virtual;
        function  WriteToXML(aParent : TDOMNode; aDoc : TXMLDocument) : TDOMNode; virtual;
        function  ReadFromXML(aParent : TDOMNode) : TDOMNode;
    end;

implementation { ==============================================================}
uses SysUtils, StrUtils;

constructor TxPLBaseClass.Create;
begin
     fClassName := 'xPLBaseClass';
     fItmValues := TStringList.Create;
     fItmNames  := TStringList.Create;
     fRegExpr   := TStringList.Create;
     Validator  := TRegExpr.Create;
     fFormatString := '';
     fRegExpString := '';
end;

destructor TxPLBaseClass.destroy;
begin
     fItmValues.Destroy;
     fItmNames.Destroy;
     fRegExpr.Destroy;
     Validator.Free;
end;

function TxPLBaseClass.AppendItem(const aName : string; const aReg : string) : integer;
begin
     fItmNames.Add(aName);
     result := fItmNames.Count-1;
     fItmValues.Add('');
     fRegExpr.Add(aReg);
end;

procedure TxPLBaseClass.DeleteItem(const aIndex: integer);
begin
   fItmNames.Delete(aIndex);
   fItmValues.Delete(aIndex);
end;

function TxPLBaseClass.GetCount: integer;
begin result := fItmNames.Count; end;

function TxPLBaseClass.GetTag: string;
var s : string;
    i : integer;
begin
     s := fFormatString;
     for i:=0 to ItemCount-1 do s := AnsiReplaceStr(s,'%'+IntToStr(i),fItmValues[i]);
     result := s;
end;

procedure TxPLBaseClass.SetTag(const aValue : string);
var i : integer;
s : string;
begin
     Validator.Expression := fRegExpString;
     if Validator. Exec(aValue) then
        for i:= 1 to ItemCount do begin
            s := Validator.Match[i];
           fItmValues[i-1] := s;
        end;
end;


procedure TxPLBaseClass.SetString(const AIndex: integer; const AValue: string);
begin
     if (not (aIndex < ItemCount)) or (aValue = fItmValues[aIndex]) then exit;

     Validator.Expression := fRegExpr[aIndex];
     if Validator.Exec(aValue) then
        fItmValues[aIndex] := Validator.Match[1]
     else
        Raise Exception.Create(('Invalid value for ' + fItmNames[aIndex] + ' : '+ aValue))
end;

function TxPLBaseClass.GetString(const aIndex: integer): string;
begin
     if (aIndex < ItemCount) then result := fItmValues[aIndex]
                             else result := '';
end;

function TxPLBaseClass.IsValid: boolean;
//var i : integer;
begin
     result := true;                                            // Controling validness of an Item solely on its size
//     for i:=0 to fItmValues.Count-1 do                        // isn't the good solution
//         if (length(fItmValues[i])=0) then result := false;
end;

procedure TxPLBaseClass.ResetValues;
var i : integer;
begin
     for i:=0 to fItmValues.Count-1 do fItmValues[i] := '';
end;

procedure TxPLBaseClass.ResetAll;
begin
     fItmValues.Clear;
     fItmNames.Clear;
     fRegExpr.Clear;
end;

procedure TxPLBaseClass.Assign(aBaseClass: TxPLBaseClass);
var i : integer;
begin
     ResetAll;
     for i:=0 to aBaseClass.ItemCount-1 do begin
         AppendItem(aBaseClass.fItmNames[i], aBaseClass.fRegExpr[i]);
         fItmValues[i] := aBaseClass.fItmValues[i];
     end;
end;

function TxPLBaseClass.Equals(aBaseClass: TxPLBaseClass) : boolean;
var i : integer;
begin
     result := true;
     for i:=0 to fItmValues.Count-1 do
         if fItmValues[i]<>aBaseClass.fItmValues[i] then result := false;
end;

function TxPLBaseClass.WriteToXML(aParent: TDOMNode; aDoc: TXMLDocument) : TDOMNode;
var aNode,EltsNode : TDOMNode;
    i  : integer;
begin
     aNode := aDoc.CreateElement(fClassName);
     for i := 0 to fItmValues.Count-1 do begin
         EltsNode := aDoc.CreateElement(fItmNames[i]);
         aNode.AppendChild(EltsNode);
         TDOMElement(EltsNode).SetAttribute('regexpr',fRegExpr[i]);
         EltsNode.AppendChild(aDoc.CreateTextNode(fItmValues[i]));
     end;
     aParent.AppendChild(aNode);
     result := aNode;
end;

function TxPLBaseClass.ReadFromXML(aParent: TDOMNode): TDOMNode;
var NodeElts : TDomNodeList;
    i : integer;
    Reg : string;
begin
     result := aParent.FindNode(fClassName);
     if result = nil then exit;

     NodeElts := result.GetChildNodes;
     for i:=0 to NodeElts.Count-1 do begin
         if (fItmNames.Count - NodeElts.Count) < 0 then begin
            Reg := TDomElement(NodeElts[i]).GetAttribute('regexpr');
            AppendItem(NodeElts[i].NodeName,reg);             // if the object is initiated via xml flow
         end;
         fItmValues[i] := NodeElts[i].ChildNodes[0].NodeValue;
     end;
end;
end.

