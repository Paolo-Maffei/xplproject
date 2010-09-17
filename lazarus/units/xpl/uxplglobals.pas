unit uxplglobals;
{==============================================================================
  UnitName      = uxplglobals
  UnitDesc      = xPL Global variable handling
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
  0.90 : Initial version
  0.91 : Added Expirency capability
  0.92 : Added On change Event
  Rev 236 : major changes to use u_xml_globals instead of self defined XML procedures
}

{$mode objfpc}{$H+}

interface

uses Classes,  u_xml_globals, DOM, uxPLSettings, DeCAL, fpTimer;

type

    TxPLGlobalChangedEvent = procedure(const aValue : string; const aNew : string; const aOld : string) of object;

    { TxPLGlobalValue }

    TxPLGlobalValue = class
    private
       fName  : string;
       fValue : string;
       fFormer: string;
       fComment : string;
       fModifyTS : TDateTime;
       fCreateTS : TDateTime;
       fExpireTS : TDateTime;
       fExpires : boolean;
       fXMLGlobal : TXMLGlobalType;
    public
//       constructor Create(const aName : string = '');
//       constructor CreateEx(const aName : string; const aValue : string = '');
       constructor Create(const aName : string; const aDefaultValue : string; const aXMLGlobal : TXMLGlobalType);
       constructor Create(const aXMLGlobal : TXMLGlobalType);

       function  SetValue(const AValue: string; const ExpireOn : TDateTime = 0; bForceUpdate : boolean = false) : boolean;
       procedure GetFromXML(const aXMLGlobal : TXMLGlobalType);
       procedure PutToXML;

    private
       procedure Delete;
       function GetAsBoolean: boolean;
    published
       property Value   : string read fValue;
       property Comment : string read fComment write fComment;
       property Former  : string read fFormer;
       property Name    : string read fName;
       property ModifyTS: TDateTime read fModifyTS;
       property CreateTS: TDateTime read fCreateTS;
       property ExpireTS: TDateTime read fExpireTS;
       property Expires : boolean read fExpires;
       property AsBoolean : boolean read GetAsBoolean;
    end;

    { TxPLGlobalList }

    TxPLGlobalList = class(DMAP)
    private
       Iter : DIterator;
       fTimer   : TfpTimer;
       fCacheFile : string;
       fDocument : TXMLDocument;
       procedure OnTimer(aSender : TObject);
       procedure ReadFromXML;
    public
       constructor Create(const aBaseDir : string);
       destructor  Destroy; override;
       procedure SetValue(const aString : string; const aValue: string; const aComment : string = '');
       function  GetValue(const aString : string) : string;
       OnGlobalChange : TxPLGlobalChangedEvent;
       procedure LISTGLOBALS(const aListe : TStringList);
       procedure LISTDEVICES(const aListe : TStringList; const aStatus : string);
       procedure GETDEVCONFIG(const aListe : TStringList; const aName : string);
       procedure Delete(const aString : string);
       procedure AddGlobal(const aName : string; const aDefault : string='');
    end;




implementation { TxPLGlobalValue =============================================================}
uses SysUtils, XMLRead, XMLWrite, u_xml, cStrings, StrUtils;
const K_CACHEFILE_NAME = 'object_cache.xml';
var fGlobalsFile : TXMLglobalsType;
    globalliste : TxPLGlobalList;

//constructor TxPLGlobalValue.Create(const aName: string);
constructor TxPLGlobalValue.Create(const aName : string; const aDefaultValue : string; const aXMLGlobal : TXMLGlobalType);
begin
  fName      := aName;
  fCreateTS  := now;
  fExpires   := false;
  fXMLGlobal := aXMLGlobal;
  SetValue(aDefaultValue,0, true);         // Force update for initialization of values
//  fXMLGlobal := fGlobalsFile.AddElement(fName);
//  PutToXML;
end;

//constructor TxPLGlobalValue.CreateEx(const aName: string; const aValue: string);
//begin
//  Create(aName);
//  SetValue(aValue);
//end;

constructor TxPLGlobalValue.Create(const aXMLGlobal : TXMLGlobalType);
begin
  fXMLGlobal := aXMLGlobal;
  GetFromXML(aXMLGlobal);
end;

function TxPLGlobalValue.SetValue(const AValue: string; const ExpireOn : TDateTime = 0; bForceUpdate : boolean = false) : boolean;
begin
  result := (aValue <> fValue);
  if not (result or bForceUpdate) then exit;

  fModifyTS := now;
  fExpires  := (ExpireOn<>0);
  fExpireTS := ExpireOn;
  fFormer   := fValue;
  fValue    := aValue;
  PutToXML;
end;

procedure TxPLGlobalValue.GetFromXML(const aXMLGlobal: TXMLGlobalType);
begin
  fName      := fXMLGlobal.Name;
  fValue     := fXMLGlobal.Value;
  fModifyTS  := fXMLGlobal.LastUpdate;
  fExpires   := fXMLGlobal.Expires;
  fCreateTS  := fXMLGlobal.CreateTS;
  fFormer    := fXMLGlobal.Former;
  fComment   := fXMLGlobal.Comment;
  fExpireTS  := fXMLGlobal.ExpireTS;
end;

procedure TxPLGlobalValue.PutToXML;
begin
  fXMLGlobal.LastUpdate := fModifyTS;
  fXMLGlobal.Expires    := fExpires;
  fXMLGlobal.ExpireTS   := fExpireTS;
  fXMLGlobal.Former     := fFormer;
  fXMLGlobal.Value      := fValue;
  fXMLGlobal.CreateTS   := fCreateTS;
end;

procedure TxPLGlobalValue.Delete;
begin
  if Assigned(fXMLGlobal) then fXMLGlobal.Remove;
end;

function TxPLGlobalValue.GetAsBoolean: boolean;
var temp : string;
begin
   temp := AnsilowerCase(Value);
   result := ((temp='y') or (temp='true') or (temp='yes'));
end;

{ TxPLGlobalList ======================================================================================}
constructor TxPLGlobalList.Create(const aBaseDir : string);
begin
  inherited Create;

  fCacheFile := aBasedir + K_CACHEFILE_NAME;
  fDocument := TXMLDocument.Create;

  if not FileExists(fCacheFile) then begin                                               // Handles creation of the file if it is
     fDocument.AppendChild(fDocument.CreateElement(K_XML_STR_Global));                   // not present
     WriteXMLFile(fDocument,fCacheFile);
  end;

  ReadXMLFile(fDocument,fCacheFile);
  fGlobalsFile := TXMLglobalsType.Create(fDocument, K_XML_STR_Global);

  fTimer := TfpTimer.Create(nil);
  fTimer.OnTimer:= @OnTimer;
  fTimer.Enabled:= True;
  fTimer.Interval:=1000;                                                                  // Tick every second
  ReadFromXML;
  globalliste := self;

end;

destructor TxPLGlobalList.Destroy;
begin
  WriteXMLFile(fDocument,fCacheFile);
  fGlobalsfile.destroy;
  fDocument.destroy;

  fTimer.Destroy;
  inherited;
end;

procedure TxPLGlobalList.SetValue(const aString : string; const aValue: string; const aComment : string = '');
var global : TxPLGlobalValue;
begin
   if AtEnd(locate([aString])) then AddGlobal(aString);

   Iter := locate([aString]);
   global := GetObject(iter) as TxPLGlobalValue;
   if global.SetValue(aValue) and Assigned(OnGlobalChange) then OnGlobalChange(aString,aValue,global.Former);
   if Length(aComment) >0 then global.Comment := aComment;
end;

procedure TxPLGlobalList.OnTimer(aSender: TObject);                                                                            // In Hal v2 - a value flagged to expire
var global : TxPLGlobalValue;                                                                                                  // will be automatically deleted
begin                                                                                                                          { TODO : Gérer le système d'expiration automatique au bout de 15mn }                                                                                                 // 15 minutes after creation
   Iter := start;
   While iterateOver(iter) do Begin
      global := GetObject(iter) as TxPLGlobalValue;
      if global.Expires and (global.ExpireTS<now) then begin
         removeAt(iter);
         global.destroy;
      end;
   end;
end;

function TxPLGlobalList.GetValue(const aString: string): string;
var i : integer;
begin
   Iter := locate([aString]);
   if not AtEnd(Iter) then result := TxPLGlobalValue(GetObject(iter)).Value;
end;

function IsDevice(ptr: Pointer; const obj: DObject): Boolean;
var global : TxPLGlobalValue;
begin
   global := AsObject(obj) as TxPLGlobalValue;
   Result := (StrMatchLeft(global.Name,'device.')) and (StrMatchRight(global.Name,'.vdi'))
end;

function IsWaitingConfig(ptr: Pointer; const obj: DObject): Boolean;
var global : TxPLGlobalValue;
   iter2 : DIterator;
   vdi : string;
begin
   Result := IsDevice(ptr,obj);
   if not result then exit;

   global := AsObject(obj) as TxPLGlobalValue;
   vdi := global.value;

   Iter2 := globalliste.locate(['device.'+ vdi + '.waitingconfig']);
   if not atEnd(Iter2) then begin
      Global := GetObject(Iter2) as TxPLGlobalValue;
      result := Global.AsBoolean;
   end else result := false;
end;

function IsConfigured(ptr: Pointer; const obj: DObject): Boolean;
var global : TxPLGlobalValue;
   iter2 : DIterator;
   vdi : string;
begin
   Result := IsDevice(ptr,obj);
   if not result then exit;

   global := AsObject(obj) as TxPLGlobalValue;
   vdi := global.value;

   Iter2 := globalliste.locate(['device.'+ vdi + '.configdone']);
   if not atEnd(Iter2) then begin
      Global := GetObject(Iter2) as TxPLGlobalValue;
      result := Global.AsBoolean;
   end else result := false;
end;

function IsMissingConf(ptr: Pointer; const obj: DObject): Boolean;
var global : TxPLGlobalValue;
   iter2 : DIterator;
   vdi : string;
begin
   Result := IsDevice(ptr,obj);
   if not result then exit;

   global := AsObject(obj) as TxPLGlobalValue;
   vdi := global.value;

   Iter2 := globalliste.locate(['device.'+ vdi + '.configmissing']);
   if not atEnd(Iter2) then begin
      Global := GetObject(Iter2) as TxPLGlobalValue;
      result := Global.AsBoolean;
   end else result := false;
end;

function IsConfig(ptr: Pointer; const obj: DObject): Boolean;
var global : TxPLGlobalValue;
begin
   global := AsObject(obj) as TxPLGlobalValue;
   Result := (StrMatchLeft(global.Name,'config.'))
end;

function IsGlobal(ptr: Pointer; const obj: DObject): Boolean;
begin
   Result := not (IsConfig(ptr,obj)) and not (IsDevice(ptr,obj))
end;


procedure TxPLGlobalList.LISTGLOBALS(const aListe: TStringList);                                        // will be automatically deleted
var global : TxPLGlobalValue;
    globales : DArray;
begin                                                                                                                          { TODO : Gérer le système d'expiration automatique au bout de 15mn }                                                                                                 // 15 minutes after creation
   globales := Darray.create;
   filter(self,globales,MakeTest(@IsGlobal));
   Iter := globales.start;
   While iterateOver(iter) do Begin
      global := GetObject(iter) as TxPLGlobalValue;
      aListe.Add(global.name + '=' + global.value);
   end;
   globales.destroy;
end;

procedure TxPLGlobalList.LISTDEVICES(const aListe: TStringList; const aStatus: string);
var global : TxPLGlobalValue;
    globales : DArray;
    vdi : string;
    iter2 : DIterator;
    chaine : string;
begin
   globales := Darray.create;
   Case AnsiIndexStr(aStatus,['AWAITINGCONFIG','CONFIGURED','MISSINGCONFIG']) of
        0 : filter(self,globales,MakeTest(@IsWaitingConfig));
        1 : filter(self,globales,MakeTest(@IsConfigured));
        2 : filter(self,globales,MakeTest(@IsMissingConf));
   end;

   Iter := globales.start;
   While iterateOver(iter) do Begin
      chaine := '';
      global := GetObject(iter) as TxPLGlobalValue;
      vdi := global.value;
      chaine += vdi + #9;

      Iter2 := locate(['device.'+ vdi + '.expires']);
      if not atEnd(Iter2) then begin
         Global := GetObject(Iter2) as TxPLGlobalValue;
         chaine += global.Value + #9
      end else chaine += ''#9;

      Iter2 := locate(['device.'+ vdi + '.interval']);
      if not atEnd(Iter2) then begin
         Global := GetObject(Iter2) as TxPLGlobalValue;
         chaine += global.Value + #9
      end else chaine += ''#9;

      Iter2 := locate(['device.'+ vdi + '.suspended']);
      if not atEnd(Iter2) then begin
         Global := GetObject(Iter2) as TxPLGlobalValue;
         chaine += global.Value + #9
      end else chaine += ''#9;

      Iter2 := locate(['device.'+ vdi + '.configtype']);
      if not atEnd(Iter2) then begin
         Global := GetObject(Iter2) as TxPLGlobalValue;
         chaine += global.Value + #9
      end else chaine += ''#9;

      Iter2 := locate(['device.'+ vdi + '.waiting']);
      if not atEnd(Iter2) then begin
         Global := GetObject(Iter2) as TxPLGlobalValue;
         chaine += global.Value + #9
      end else chaine += ''#9;

      aliste.Add(chaine);
   end;
   globales.destroy;
end;




procedure TxPLGlobalList.GETDEVCONFIG(const aListe: TStringList; const aName: string);
var global : TxPLGlobalValue;
    globales : DArray;

function IsConfigElement(ptr: Pointer; const obj: DObject): Boolean;
var global : TxPLGlobalValue;
begin
   global := AsObject(obj) as TxPLGlobalValue;

   Result := (StrMatchLeft(global.Name,'config.'))
end;

begin                                                                                                                          { TODO : Gérer le système d'expiration automatique au bout de 15mn }                                                                                                 // 15 minutes after creation
   globales := Darray.create;
//   filter(self,globales,MakeTest(@IsConfigElement));
   Iter := globales.start;
   While iterateOver(iter) do Begin
      global := GetObject(iter) as TxPLGlobalValue;
      aListe.Add(global.name + '=' + global.value);
   end;
   globales.destroy;
{   Iter := Devices.locate([aRequested]);
   if not atEnd(Iter) then begin
      SetToValue(iter);
      with getObject(iter) as TDeviceRecord do begin
         Body1 := TxPLMsgBody.Create;
         Body2 := TxPLMsgBody.Create;
         Body1.RawxPL:=config_current;
         Body2.RawxPL:=config_list;
               for i := 0 to Body1.ItemCount-1 do begin
                   for j:=0 to Body2.ItemCount-1 do begin
                      if AnsiLeftStr(Body2.Values[j],Length(Body1.Keys[i])) = Body1.Keys[i] then begin
                         chaine := Body2.Keys[j];
                         retour := StrBetweenChar(Body2.Values[j],'[',']');
                      end;
                   end;
                   aListe.Add(Format('%s'#9'%s'#9'%s',[Body1.Keys[i],chaine,retour]));
               end;
         Body1.Destroy;
         Body2.Destroy;
      end;
   end;}
end;

procedure TxPLGlobalList.Delete(const aString: string);
var global : TxPLGlobalValue;
begin
   Iter := locate([aString]);
   if not AtEnd(Iter) then begin
      global := GetObject(iter) as TxPLGlobalValue;
         removeAt(iter);
         global.destroy;
   end;
end;

procedure TxPLGlobalList.AddGlobal(const aName : string; const aDefault : string='');
begin
   if atEnd(locate([aName])) then
     inherited putPair( [ aName,
                          TxPLGlobalValue.Create(aName, aDefault,fGlobalsFile.AddElement(aName))
                          ]);
end;

procedure TxPLGlobalList.ReadFromXML;
var i : integer;
    aGlobal : TxPLGlobalValue;
begin
   for i:=0 to fGlobalsFile.Count-1 do begin
       aGlobal := TxPLGlobalValue.Create(fGlobalsFile[i]);
       PutPair( [ aGlobal.Name, aGlobal ]);

   end;
end;


end.

