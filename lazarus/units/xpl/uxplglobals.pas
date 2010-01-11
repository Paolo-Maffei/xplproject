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
       fModifyTS : TDateTime;
       fCreateTS : TDateTime;
    public
       constructor Create(const aName : string = '');

       procedure WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string); dynamic;
       procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); dynamic;

       function SetValue(const AValue: string) : boolean;
    published
       property Value : string read fValue;

    end;


implementation { TxPLGlobalValue =============================================================}
uses SysUtils;

function TxPLGlobalValue.SetValue(const AValue: string) : boolean;
begin
  result := (aValue <> fValue);
  if not result then exit;

  fModifyTS := now;
  fFormer:= fValue;
  fValue := aValue;
end;

constructor TxPLGlobalValue.Create(const aName: string);
begin
  fName := aName;
  fCreateTS := now;
  fValue := '';
  fFormer:= '';
end;

procedure TxPLGlobalValue.WriteToXML(const aCfgfile: TXmlConfig; const aRootPath: string);
begin
   with aCfgFile do begin
      SetValue(aRootPath + '/Name'     , fName);
      SetValue(aRootPath + '/Value'    , fValue);
      SetValue(aRootPath + '/Former'   , fFormer);
      SetValue(aRootPath + '/ModifyTS' , DateTimeToStr(fModifyTS));
      SetValue(aRootPath + '/CreateTS' , DateTimeToStr(fCreateTS));
   end;
end;

procedure TxPLGlobalValue.ReadFromXML(const aCfgfile: TXmlConfig; const aRootPath: string);
begin
   fName     := aCfgFile.GetValue(aRootPath + '/Name', '');
   fValue    := aCfgFile.GetValue(aRootPath + '/Value', '');
   fFormer   := aCfgFile.GetValue(aRootPath + '/Former', '');
   fModifyTS := StrToDateTime(aCfgFile.GetValue(aRootPath + '/ModifyTS', ''));
   fCreateTS := StrToDateTime(aCfgFile.GetValue(aRootPath + '/CreateTS', ''));
end;

end.

