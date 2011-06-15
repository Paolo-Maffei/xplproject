unit u_xpl_globals;
{==============================================================================
  UnitName      = uxplglobals
  UnitDesc      = xPL Global variable handling
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
  0.90 : Initial version
  0.91 : Added Expirency capability
  0.92 : Added On change Event
}

{$mode objfpc}{$H+}

interface

uses Classes
     , fpTimer
     , u_xpl_collection
     , u_xpl_formulas
     ;

type

    TxPLGlobalChangedEvent = procedure(const aValue : string; const aNew : string; const aOld : string) of object;
    TGlobalVariableName = string;

    { TxPLGlobalValue }
    TxPLGlobalValue = class(TxPLCollectionItem)
    private
       fFormer    : string;
       fExpireTS  : TDateTime;

       procedure Set_Value(const AValue: string); override;
    public
       Formulas : TxPLFormulas;
       constructor Create(aOwner: TCollection); override;
       procedure Assign(Source: TPersistent);
    private
       function Get_Expires: boolean;
       procedure Set_Expires(const AValue: boolean);

    published
       property DisplayName;
       property CreateTS;
       property Value;
       property Comment;
       property Expires  : boolean   read Get_Expires write Set_Expires stored false;
       property ModifyTS;
       property ExpireTS : TDateTime read fExpireTS   write fExpireTS;
       property Former   : string    read fFormer     write fFormer;
    end;

    { TxPLGlobals }
    TxPLCustomGlobals = specialize TxPLCollection<TxPLGlobalValue>;

    TxPLGlobals = class(TxPLCustomGlobals)
    private
       FOnGlobalChange: TxPLGlobalChangedEvent;
       procedure Update(Item: TCollectionItem); override;
    public
       Formulas : TxPLFormulas;
    published
       property OnGlobalChange : TxPLGlobalChangedEvent read FOnGlobalChange write fOnGlobalChange;
    end;

implementation { TxPLGlobalValue =============================================================}
uses StrUtils
     , SysUtils;

// ============================================================================
constructor TxPLGlobalValue.Create(aOwner: TCollection);
begin
  inherited Create(aOwner);
  fValue := '';
  fExpireTS := 0;
  fFormer := '';
end;

procedure TxPLGlobalValue.Set_Value(const AValue: string);
begin
   if aValue<>Value then fFormer := fValue;
   inherited Set_Value(aValue);
end;

procedure TxPLGlobalValue.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  if Source is TxPLGlobalValue then begin
     fValue       := TxPLGlobalValue(Source).Value;
     fComment     := TxPLGlobalValue(Source).Comment;
     fCreateTS    := TxPLGlobalValue(Source).CreateTS;
     fExpireTS    := TxPLGlobalValue(Source).ExpireTS;
     fFormer      := TxPLGlobalValue(Source).Former;
  end;
end;

function TxPLGlobalValue.Get_Expires: boolean;
begin
   result := not (fExpireTS = 0);
end;

procedure TxPLGlobalValue.Set_Expires(const AValue: boolean);
begin
   if aValue then fExpireTS := now + 10000
             else fExpireTS := 0;

end;

procedure TxPLGlobals.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Item is TxPLGlobalValue then begin
  with TxPLGlobalValue(Item) do begin
//     if Assigned(Formulas) then Formulas.Update(nil);
     if Assigned(OnGlobalChange) and (Value<>Former) then
          OnGlobalChange(displayname,Value,Former);
  end;
  end;
end;



{ TxPLGlobalList ======================================================================================}
(*

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
         *)

end.

