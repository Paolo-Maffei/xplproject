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

type TxPLConfigItemType = (config, reconf, option);

   { TxPLCustomConfig }

   TxPLCustomConfig = class(TComponent, IxPLCommon)
   private
      fConfigList    : TConfigListStat;
      fConfigCurrent : TConfigCurrentStat;
      function Get_FilterSet: TStringList;
      function Get_GroupSet: TStringList;
      function Get_Instance: string;
      function Get_Interval: integer;
      procedure SetItemValue(const aItmName : string; const aValue : string);
      procedure  ResetValues;
   public
      Constructor Create(aOwner : TComponent); override;

      function   IsValid : boolean;

      procedure DefineItem(const aName : string; const aType : TxPLConfigItemType; const aMax : integer = 1; const aDefault : string = ''); // : integer;
      function GetItemValue(const aItmName : string) : string;
   published
      property ConfigList    : TConfigListStat  read fConfigList;
      property CurrentConfig : TConfigCurrentStat  read fConfigCurrent;
      property Instance      : string    read Get_Instance                                   stored false;
      property Interval      : integer   read Get_Interval                                   stored false;
      property FilterSet     : TStringList read Get_FilterSet stored false;
      property GroupSet      : TStringList read Get_GroupSet stored false;
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

   fConfigList := TConfigListStat.Create(self);
   fConfigCurrent := TConfigCurrentStat.Create(self);
   fConfigCurrent.newconf := TxPLAddress.InitInstanceByDefault;
   fConfigCurrent.interval := K_XPL_DEFAULT_HBEAT;
end;

function TxPLCustomConfig.Get_FilterSet: TStringList;
begin
   result := fConfigCurrent.filters;
end;

function TxPLCustomConfig.Get_GroupSet: TStringList;
begin
   result := fConfigCurrent.Groups;
end;

function TxPLCustomConfig.GetItemValue(const aItmName: string): string;
begin
   result := fConfigCurrent.Body.GetValueByKey(aItmName,'');
end;

function TxPLCustomConfig.Get_Instance: string;
begin
   result := fConfigCurrent.newconf;
end;

function TxPLCustomConfig.Get_Interval: integer;
begin
   result := fConfigCurrent.interval;
end;

function TxPLCustomConfig.IsValid: boolean;
var i : integer;
    s : string;
begin
   result := true;
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
   if aMax <> 1 then s := '[' + IntToStr(aMax) + ']' else s := '';
   fConfigList.Body.AddKeyValuePairs([GetEnumName(TypeInfo(TxPLConfigItemType),Ord(aType))],[aName + s]);
   fConfigCurrent.Body.SetValueByKey(aName,aDefault);
end;

procedure TxPLCustomConfig.SetItemValue(const aItmName : string; const aValue : string);
var s : string;
begin
   case AnsiIndexStr(aItmName,[K_CONF_NEWCONF,K_CONF_INTERVAL]) of              // Basic control on some special configuration items
        0 : s := AnsiLowerCase(aValue);                                         // instance name can not be in upper case
        1 : s := IntToStr(StrToIntDef(aValue,MIN_HBEAT));
        else s := aValue;
   end;
   fConfigCurrent.Body.SetValueByKey(aItmName,s);
end;

procedure TxPLCustomConfig.ResetValues;
var i : integer;
begin
  fConfigCurrent.Body.ResetValues;
  for i:=0 to Pred(fConfigList.Body.ItemCount) do
     fConfigCurrent.Body.AddKeyValue(fConfigList.ItemName(i)+'=')
end;

initialization
   Classes.RegisterClass(TxPLCustomConfig);

end.

