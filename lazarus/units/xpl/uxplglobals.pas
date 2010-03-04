unit uxplglobals;
{==============================================================================
  UnitName      = uxplglobals
  UnitDesc      = xPL Global variable handling
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
  0.90 : Initial version
  0.91 : Added Expirency capability
}

{$mode objfpc}{$H+}

interface

uses Classes, XMLCfg, ExtCtrls;

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
       fExpireTS : TDateTime;
    public
       constructor Create(const aName : string = '');

       procedure WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string); dynamic;
       procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); dynamic;

       function  SetValue(const AValue: string; const ExpireOn : TDateTime = 0) : boolean;
       procedure SetComment(const aComment : string);
    published
       property Value   : string read fValue;
       property Comment : string read fComment;
       property ModifyTS: TDateTime read fModifyTS;
       property CreateTS: TDateTime read fCreateTS;
       property ExpireTS: TDateTime read fExpireTS;
    end;

    { TxPLGlobalList }

    TxPLGlobalList = class(TStringList)
    private
       fCfgFile : TXmlConfig;
       fRootPath: string;
       fTimer   : TTimer;

       procedure OnTimer(aSender : TObject);
    public
       constructor Create;
       destructor  Destroy;
       procedure SetValue(const aString : string; const aValue: string; const aComment : string = '');
       function  GetValue(const i : integer) : string;
       function  GetValue(const aString : string) : string;
       function  Item(const i : integer) : TxPLGlobalValue;
       procedure Delete(const aString : string); overload;
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
      K_XML_EXPIRE_PATH  = '/ExpireTS';
      K_XML_COMMENT_PATH = '/Comment';


function TxPLGlobalValue.SetValue(const AValue: string; const ExpireOn : TDateTime = 0) : boolean;
begin
  result := (aValue <> fValue);
  if not result then exit;

  fModifyTS := now;
  if ExpireOn=0 then fExpireTS := fCreateTS-1 else fExpireTS := ExpireOn;
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
  fExpireTS := fCreateTS - 1;
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
      SetValue(aRootPath + K_XML_EXPIRE_PATH  , DateTimeToStr(fExpireTS));
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
   fExpireTS := StrToDateTime(aCfgFile.GetValue(aRootPath + K_XML_EXPIRE_PATH, DateTimeToStr(fCreateTS-1)));
end;

{ TxPLGlobalList }

procedure TxPLGlobalList.OnTimer(aSender: TObject);
var i : integer;
    global : TxPLGlobalValue;
begin
   if Count=0 then exit;
   i := 0;
   repeat
      global := Item(i);
      if global.ExpireTS<now then begin
         if global.ExpireTS > global.CreateTS then delete(i) else inc(i);
      end else inc(i);
   until i>=Count;
end;

constructor TxPLGlobalList.Create;
begin
  inherited Create;
  Duplicates:=dupIgnore;
  Sorted := true;
  fTimer := TTimer.Create(nil);
  fTimer.OnTimer:= @OnTimer;
  fTimer.Enabled:= True;
  fTimer.Interval:=1000;                                                                  // Time every second
end;

destructor TxPLGlobalList.Destroy;
begin
  WriteToXML;                                                                             // Save values before destroying
  fTimer.Destroy;
  inherited;
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

function TxPLGlobalList.GetValue(const i: integer): string;
begin
  result := TxPLGlobalValue(Objects[i]).Value;
end;

function TxPLGlobalList.GetValue(const aString: string): string;
var i : integer;
begin
  i := IndexOf(aString);
  if i<>-1 then result := GetValue(i);
end;

function TxPLGlobalList.Item(const i : integer): TxPLGlobalValue;
begin
   result := nil;
   if i<count then result := TxPLGlobalValue(Objects[i]);
end;

procedure TxPLGlobalList.Delete(const aString: string);
var i : integer;
begin
     i := IndexOf(aString);
     if i=-1 then exit;
     inherited Delete(i);
end;

end.

