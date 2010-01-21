unit uxplglobals;

{$mode objfpc}{$H+}

interface

uses Classes, XMLCfg;

type
    TxPLGlobalChangedEvent = procedure(aValue : string; aOld : string; aNew : string) of object;
    { TxPLGlobalValue }

    TxPLGlobalValue = class
       fName  : string;
       fValue : string;
       fFormer: string;
       fComment : string;
       fModifyTS : TDateTime;
       fCreateTS : TDateTime;
    public
       constructor Create(const aName : string = '');

       procedure WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string); dynamic;
       procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); dynamic;

       function  SetValue(const AValue: string) : boolean;
       procedure SetComment(const aComment : string);
    published
       property Value   : string read fValue;
       property Comment : string read fComment;
       property ModifyTS: TDateTime read fModifyTS;
       property CreateTS: TDateTime read fCreateTS;
    end;

    { TxPLGlobalList }

    TxPLGlobalList = class(TStringList)
    private
       fCfgFile : TXmlConfig;
       fRootPath: string;
    public
       constructor Create;
       procedure SetValue(const aString : string; const aValue: string; const aComment : string = '');
       procedure WriteToXML;
       procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string);
    end;


implementation { TxPLGlobalValue =============================================================}
uses SysUtils;
resourcestring
      // String constants to access stored value in XML file
      K_XML_NAME_PATH    = '/Name';
      K_XML_VALUE_PATH   = '/Value';
      K_XML_FORMER_PATH  = '/Former';
      K_XML_MODIF_PATH   = '/ModifyTS';
      K_XML_CREATE_PATH  = '/CreateTS';
      K_XML_COMMENT_PATH = '/Comment';


function TxPLGlobalValue.SetValue(const AValue: string) : boolean;
begin
  result := (aValue <> fValue);
  if not result then exit;

  fModifyTS := now;
  fFormer:= fValue;
  fValue := aValue;
end;

procedure TxPLGlobalValue.SetComment(const aComment: string);
begin fComment := aComment; end;

constructor TxPLGlobalValue.Create(const aName: string);
begin
  fName     := aName;
  fCreateTS := now;
  fValue    := '';
  fFormer   := '';
  fComment  := '';
end;

procedure TxPLGlobalValue.WriteToXML(const aCfgfile : TXmlConfig; const aRootPath : string);
begin
   with aCfgFile do begin
      SetValue(aRootPath + K_XML_NAME_PATH     , fName);
      SetValue(aRootPath + K_XML_VALUE_PATH    , fValue);
      SetValue(aRootPath + K_XML_FORMER_PATH   , fFormer);
      SetValue(aRootPath + K_XML_MODIF_PATH , DateTimeToStr(fModifyTS));
      SetValue(aRootPath + K_XML_CREATE_PATH , DateTimeToStr(fCreateTS));
      SetValue(aRootPath + K_XML_COMMENT_PATH  , fComment);
   end;
end;

procedure TxPLGlobalValue.ReadFromXML(const aCfgfile: TXmlConfig; const aRootPath: string);
begin
   fName     := aCfgFile.GetValue(aRootPath + K_XML_NAME_PATH, '');
   fValue    := aCfgFile.GetValue(aRootPath + K_XML_VALUE_PATH, '');
   fFormer   := aCfgFile.GetValue(aRootPath + K_XML_FORMER_PATH, '');
   fModifyTS := StrToDateTime(aCfgFile.GetValue(aRootPath + K_XML_MODIF_PATH, ''));
   fCreateTS := StrToDateTime(aCfgFile.GetValue(aRootPath + K_XML_CREATE_PATH, ''));
   fComment  := aCfgFile.GetValue(aRootPath + K_XML_COMMENT_PATH, '');
end;

{ TxPLGlobalList }

constructor TxPLGlobalList.Create;
begin
  inherited Create;
  Duplicates:=dupIgnore;
  Sorted := true;
end;

procedure TxPLGlobalList.WriteToXML;
var i : integer;
begin
    for i:=0 to Count-1 do
        TxPLGlobalValue(Objects[i]).WriteToXML(fCfgfile, fRootPath + '/Global_' + intToStr(i));
    fCfgfile.SetValue(fRootPath + '/GlobalCount', Count);
end;

procedure TxPLGlobalList.ReadFromXML(const aCfgfile: TXmlConfig; const aRootPath: string);
var i,newGlobal : integer;
    aGlobal  : TxPLGlobalValue;
begin
     fCfgFile := aCfgFile;
     fRootPath := aRootPath;
   i := StrToInt(aCfgfile.GetValue(aRootPath +'/GlobalCount', '0')) - 1;
   while i>=0 do begin
       aGlobal := TxPLGlobalValue.Create;
       aGlobal.ReadFromXML(aCfgfile, aRootPath + '/Global_' + intToStr(i));
       newGlobal := Add(aGlobal.fName);
       Objects[newGlobal] := aGlobal;
      dec(i);
   end;
end;

procedure TxPLGlobalList.SetValue(const aString : string; const aValue: string; const aComment : string = '');
var i : integer;
    gv : TxPLGlobalValue;
begin
   i := IndexOf(aString);

   if i=-1 then begin
       i := Add(aString);
       Objects[i] := TxPLGlobalValue.Create(aString);
   end;

   gv := TxPLGlobalValue(Objects[i]);
   gv.SetValue(aValue);
   if aComment<>'' then gv.SetComment(aComment);
end;

end.

