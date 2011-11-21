unit u_xpl_config;

{$ifdef fpc}
{$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses Classes
     , SysUtils
     , u_xpl_common
     , u_xpl_body
     , u_xpl_messages
     ;

type //TxPLCustomConfig = class;
     TxPLConfigItemType = (config, reconf, option);

     { TxPLConfigItem }
     //TxPLConfigItem = class(TxPLCollectionItem)
     //private
     //   fItmType : TxPLConfigItemType;
     //   fValues  : TStringList;
     //   fItmMax  : integer;
     //public
     //   constructor Create(AOwner:TCollection);override;
     //   destructor  Destroy; override;
     //
     //   procedure   Assign(Source:TPersistent);override;
     //   function    IsValid : boolean;
     //   procedure   ResetValues;
     //
     //   function    ItemMaxAsString : string;
     //   function    ValueCount : integer;
     //   function    ValueAtId(const aIdx : integer) : string;
     //   procedure   AddValue(const aValue : string);
     //   procedure   AddValues(const aValArray : Array of String);
     //published
     //   property ItemDefault : string             read fValue   write fValue;
     //   property ItemMax     : integer            read fItmMax  write fItmMax;
     //   property ItemType    : TxPLConfigItemType read fItmType write fItmType;
     //   property Values      : TStringList        read fValues  write fValues;
     //end;

   //TxPLConfigItems = {$ifdef fpc}specialize{$endif} TxPLCollection<TxPLConfigItem>;

   { TxPLCustomConfig }

   TxPLCustomConfig = class(TComponent, IxPLCommon)
   private
      fConfigList    : TConfigListStat;
      fConfigCurrent : TConfigCurrentStat;
      //fConfigItems : TxPLConfigItems;
      //function Get_ConfigList: TxPLBody;
      //function Get_CurrentConfig: TConfigCurrentStat;
      function Get_FilterSet: TStringList;
      function Get_GroupSet: TStringList;
      function Get_Instance: string;
      function Get_Interval: integer;
      //procedure Set_ConfigList(const AValue: TxPLBody);
      //procedure Set_CurrentConfig(const aMsg : TConfigCurrentStat);
      //procedure Set_ConfigItems(aValuesList : TxPLConfigItems);
      procedure SetItemValue(const aItmName : string; const aValue : string);
      procedure  ResetValues;
   public
      Constructor Create(aOwner : TComponent); override;
      //Destructor  Destroy; override;

      function   IsValid : boolean;

      procedure DefineItem(const aName : string; const aType : TxPLConfigItemType; const aMax : integer = 1; const aDefault : string = ''); // : integer;
      function GetItemValue(const aItmName : string) : string;
//      procedure SetConfigList(const aBody : TxPLBody);
   published
      //property ConfigItems   : TxPLConfigItems read fConfigItems write Set_ConfigItems;
      property ConfigList    : TConfigListStat  read fConfigList; //Get_ConfigList     {write Set_ConfigList }     stored false;
      property CurrentConfig : TConfigCurrentStat  read fConfigCurrent; //Get_CurrentConfig  write Set_CurrentConfig     stored false;
      property Instance      : string    read Get_Instance                                   stored false;
      property Interval      : integer   read Get_Interval                                   stored false;
      property FilterSet     : TStringList read Get_FilterSet stored false; //TxPLConfigItem read Get_FilterSet                             stored false;
      property GroupSet      : TStringList read Get_GroupSet stored false; //TxPLConfigItem read Get_GroupSet                              stored false;
   end;

implementation {===============================================================}
uses uxPLconst
     , StrUtils
     , typinfo
     , u_xpl_address
     ;

{ TxPLCustomConfig ============================================================}
constructor TxPLCustomConfig.Create(aOwner: TComponent);
begin
   inherited Create(aOwner);
   include(fComponentStyle,csSubComponent);

   //fConfigItems := TxPLConfigItems.Create(self);
   //fConfigList := TxPLBody.Create(self);
   fConfigList    := TConfigListStat.Create(self);
   fConfigCurrent := TConfigCurrentStat.Create(self);
   fConfigCurrent.newconf := TxPLAddress.InitInstanceByDefault;
   fConfigCurrent.interval:=K_XPL_DEFAULT_HBEAT;
   //DefineItem(K_CONF_NEWCONF , reconf, 1, TxPLAddress.InitInstanceByDefault);
   //DefineItem(K_CONF_INTERVAL, option, 1, IntToStr(K_XPL_DEFAULT_HBEAT));       // Do not change the order of these elements
   //DefineItem(K_CONF_FILTER  , option, K_XPL_CFG_MAX_FILTERS);
   //DefineItem(K_CONF_GROUP   , option, K_XPL_CFG_MAX_GROUPS );


end;

//procedure TxPLCustomConfig.Set_ConfigItems(aValuesList: TxPLConfigItems);
//begin
//   ConfigItems.Assign(aValuesList);
//end;

//procedure TxPLCustomConfig.Set_ConfigList(const AValue: TxPLBody);
//var i,maxval : integer;
//    s,nom : string;
//    sl : TStringList;
//    conftype : TxPLConfigItemType;
//begin
//   ConfigItems.Clear;
//   for i:=0 to aValue.ItemCount-1 do begin
//       sl := TStringList.Create;
//       s := AnsiReplaceStr(aValue.Values[i],']','[');
//       sl.Delimiter := '[';
//       sl.DelimitedText := s;
//       nom    := sl[0];
//       if sl.Count > 1 then maxval := StrToInt(sl[1]);
//                       else maxval := 1;
//       conftype := TxPLConfigItemType(GetEnumValue(TypeInfo(TxPLConfigItemType), aValue.Keys[i]));
//       DefineItem(nom, conftype ,maxval);
//       sl.Free;
//   end;
//end;

//procedure TxPLCustomConfig.SetConfigList(const aBody: TxPLBody);
//begin
//   fConfigList.Assign(aBody);
//end;


//function TxPLCustomConfig.Get_ConfigList: TxPLBody;                             // Builds a body message following
//var i : integer;                                                                // xPL recommandations in
//    keys, vals : TStringList;                                                   // http://xplproject.org.uk/wiki/index.php?title=XPL_Specification_Document
//begin
////   result := TxPLBody.Create(self);
//   result := fConfigList;
//   result.ResetValues;
//   Keys   := TStringList.Create;
//   Vals   := TStringList.Create;
//   for i := 0 to ConfigItems.Count-1 do begin
//       Keys.Add(GetEnumName(TypeInfo(TxPLConfigItemType),Ord(ConfigItems[i].ItemType)));
//       Vals.Add(ConfigItems[i].DisplayName + ConfigItems[i].ItemMaxAsString);
//   end;
//   Result.AddKeyValuePairs(Keys,Vals);
//   Keys.Free;
//   Vals.Free;
//end;

//function TxPLCustomConfig.Get_CurrentConfig: TConfigCurrentStat;                          // Builds a body message following
//var i,j : integer;                                                              // xPL recommandations in for config.current message
//    keys, vals : TStringList;                                                   // http://xplproject.org.uk/wiki/index.php?title=XPL_Specification_Document
//begin
//   result := TConfigCurrentStat.Create(self);
//   Keys := TStringList.Create;
//   Vals := TStringList.Create;
//   for i := 0 to ConfigItems.Count-1 do begin
//      if ConfigItems[i].ValueCount = 0 then begin
//         Keys.Add(ConfigItems[i].DisplayName);
//         Vals.Add(ConfigItems[i].ItemDefault);
//      end else
//      for j:= 0 to ConfigItems[i].ValueCount-1 do begin
//          Keys.Add(ConfigItems[i].DisplayName);
//          Vals.Add(ConfigItems[i].ValueAtId(j));
//      end;
//   end;
//   Result.Body.ResetValues;
//   Result.Body.AddKeyValuePairs(Keys,Vals);
//   Keys.Free;
//   Vals.Free;
//end;

function TxPLCustomConfig.Get_FilterSet: TStringList; //TxPLConfigItem;
begin
   result := fConfigCurrent.filters;
end;

function TxPLCustomConfig.Get_GroupSet: TStringList; //TxPLConfigItem;
begin
   result := fConfigCurrent.Groups;
end;

function TxPLCustomConfig.GetItemValue(const aItmName: string): string;
//var cfg : TxPLConfigItem;
begin
   //result := '';
   //cfg := ConfigItems.FindItemName(aItmName);
   //if cfg <> nil then begin
   //   if Cfg.ValueCount = 0 then result := Cfg.ItemDefault
   //                         else result := Cfg.ValueAtId(0);
   //end;
   result := fConfigCurrent.Body.GetValueByKey(aItmName,'');
end;

function TxPLCustomConfig.Get_Instance: string;
begin
//   result := IfThen(ConfigItems[0].ValueCount=0,ConfigItems[0].ItemDefault,ConfigItems[0].ValueAtId(0));
   result := fConfigCurrent.newconf;
end;

function TxPLCustomConfig.Get_Interval: integer;
begin
//   result := StrToInt(IfThen(ConfigItems[1].ValueCount=0,ConfigItems[1].ItemDefault,ConfigItems[1].ValueAtId(0)));
   result := fConfigCurrent.interval;
end;

//destructor TxPLCustomConfig.Destroy;
//begin
////   fConfigItems.Free;
//   inherited Destroy;
//end;

function TxPLCustomConfig.IsValid: boolean;
var i : integer;
    s : string;
begin
   result := true;
//   for i:=0 to ConfigItems.Count-1 do result := result and ConfigItems[i].IsValid;
   for i:=0 to Pred(fConfigList.Body.ItemCount) do begin
      if fConfigList.Body.Keys[i]<>'option' then begin
         s := fConfigList.Body.Values[i];
         result := result and (fConfigCurrent.Body.GetValueByKey(s,'')<>'');
      end;
   end;
end;

procedure TxPLCustomConfig.DefineItem(const aName : string; const aType : TxPLConfigItemType; const aMax : integer = 1; const aDefault : string = ''); // : integer;
var s : string;
begin
   //with ConfigItems.Add(aName) do begin
   //     ItemType    := aType;
   //     ItemMax     := aMax;
   //     ItemDefault := aDefault;
   //end;
   //result := ConfigItems.Count-1;
   if aMax <> 1 then s := '[' + IntToStr(aMax) + ']' else s := '';
   fConfigList.Body.AddKeyValuePairs([GetEnumName(TypeInfo(TxPLConfigItemType),Ord(aType))],[aName + s]);
   fConfigCurrent.Body.SetValueByKey(aName,aDefault);
   //result := fConfigList.Body.ItemCount - 1;
end;

procedure TxPLCustomConfig.SetItemValue(const aItmName : string; const aValue : string);
var s : string;
//    ci : TxPLConfigItem;
begin
//   ci := ConfigItems.FindItemName(aItmName);
//   if ci = nil then exit;

   case AnsiIndexStr(aItmName,[K_CONF_NEWCONF,K_CONF_INTERVAL]) of              // Basic control on some special configuration items
        0 : s := AnsiLowerCase(aValue);                                         // instance name can not be in upper case
        1 : s := IntToStr(StrToIntDef(aValue,MIN_HBEAT));
        else s := aValue;
   end;
   fConfigCurrent.Body.SetValueByKey(aItmName,s);
//   ci.AddValue(s);                                                              // The collectionitem will handle details of adding, replacing...
end;

//procedure TxPLCustomConfig.Set_CurrentConfig(const aMsg : TConfigCurrentStat);            // Set configuration elements coming from config.response message
//var i : integer;
//begin
//  ResetValues;
//  for i:= 0 to aBody.Body.ItemCount-1 do
//     SetItemValue(AnsiLowerCase(aBody.Body.Keys[i]),aBody.Body.Values[i]);
//end;

procedure TxPLCustomConfig.ResetValues;
var i : integer;
//    s,nom : string;
//    sl : tstringlist;
begin
//   for i:=0 to ConfigItems.Count-1 do ConfigItems[i].ResetValues;
  fConfigCurrent.Body.ResetValues;
  for i:=0 to Pred(fConfigList.Body.ItemCount) do //begin
//     sl := TStringList.Create;
//     s := AnsiReplaceStr(fConfigList.Body.Values[i],']','[');
//     sl.Delimiter := '[';
//     sl.DelimitedText := s;
//     nom    := sl[0];
//     sl.free;
     fConfigCurrent.Body.AddKeyValue(fConfigList.ItemName(i)+'=')
//  end;
end;

{ TxPLConfigItem =====================================================================}
//constructor TxPLConfigItem.Create(AOwner: TCollection);
//begin
//   inherited Create(AOwner);
//   fValues := TStringList.Create;
//   fValues.Duplicates := dupIgnore;
//   fValues.Sorted     := true;
//   ResetValues;
//end;

//destructor TxPLConfigItem.Destroy;
//begin
//   fValues.Free;
//   inherited Destroy;
//end;
//
//procedure TxPLConfigItem.ResetValues;
//begin
//   fValues.Clear;
//end;
//
//function TxPLConfigItem.ItemMaxAsString: string;
//begin
//   Result := '';
//   if ItemMax<>1 then result := '[' + IntToStr(ItemMax) + ']';
//end;
//
//function TxPLConfigItem.ValueCount: integer;
//begin
//   result := fValues.Count;
//end;
//
//function TxPLConfigItem.ValueAtId(const aIdx: integer): string;
//begin
//   result := '';
//   if aIdx < ValueCount then result := fValues[aIdx];
//end;
//
//procedure TxPLConfigItem.AddValue(const aValue: string);
//begin
//   if (aValue<>'') and (fValues.IndexOf(aValue)=-1) then begin                                     // The value is already present then don't change anything
//      if ValueCount < ItemMax
//         then fValues.Add(aValue)
//         else fValues[ItemMax-1] := aValue;
//   end;
//end;
//
//procedure TxPLConfigItem.AddValues(const aValArray: array of String);
//var s : string;
//begin
//   for s in aValArray do AddValue(s);
//end;
//
//procedure TxPLConfigItem.Assign(Source: TPersistent);
//begin
//  if Source is TxPLConfigItem then begin
//       fItmType := TxPLConfigItem(Source).ItemType;
//       fValue := TxPLConfigItem(Source).ItemDefault;
//       fItmMax  := TxPLConfigItem(Source).ItemMax;
//       fValues.Assign(TxPLConfigItem(Source).fValues);
//  end;
//  inherited Assign(source);
//end;
//
//function TxPLConfigItem.IsValid: boolean;
//begin
//   result :=  (fItmType = option) or
//              (ValueCount > 0)    or
//              (ItemDefault<>'');
//end;


initialization
   //Classes.RegisterClass(TxPLConfigItem);
   //Classes.RegisterClass(TxPLConfigItems);
   Classes.RegisterClass(TxPLCustomConfig);

end.

