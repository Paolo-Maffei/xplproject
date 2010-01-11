unit uxPLConfig;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, uxPLCfgItem,  XmlCfg, DOM;
Const K_XPL_DEFAULT_HBEAT = 5;

type

{ TxPLConfig }

TxPLConfig = class(TComponent)
     private
        fConfigItems : TList;
        fxmlconfig : TXmlConfig;

        function GetInstance: string;
        function GetInterval: integer;
        function GetItem(Index : integer): TxPLConfigItem;
        function GetItemByStr(s : string): TxPLConfigItem;
        procedure SetInstance(const AValue: string);
        procedure SetInterval(const AValue: integer);

     public
        constructor create(aOwner : TComponent); override;
        destructor  destroy; override;

        procedure AddItem(aItmName, aDefaultVal : string; aConfigType : TxPLConfigType; aMax : integer; aDesc, aFormat : string);
        procedure AddValue(aItmName, aValue : string);
        function SetItem(const aItmName : string; const aValue : string) : boolean;

        procedure Save(anIdentifier : string);
        function Load(anIdentifier : string) : boolean;
        function Count : integer;
        function ItemByName(const aName : string) : integer;
       procedure ResetValues;
        property HBInterval : integer read GetInterval write SetInterval;
        property Instance : string  read GetInstance write SetInstance;
        property Item[Index : integer] : TxPLConfigItem read GetItem; default;
        property ItemName[s : string] : TxPLConfigItem read GetItemByStr;
        property Items : TList read fConfigItems;
        property XmlFile : TXmlConfig read fxmlconfig;

        procedure ReadFromXML(const aDeviceNode : TDOMNode);
        // Filter specific
        function  FilterCount : integer;

     end;

implementation { =======================================================================}

resourcestring
      K_CONF_NEWCONF = 'newconf';
      K_DESC_NEWCONF = 'Enter the name that will be used to identify this device on the xPL network';
      K_FMT_NEWCONF  = '^[A-Za-z0-9]{1,16}$';
      K_CONF_INTERVAL= 'interval';
      K_DESC_INTERVAL= 'Specify the number of minutes between heartbeat messages. The value should be between 5 and 9.';
      K_FMT_INTERVAL = '^[56789]{1}$';
      K_CONF_FILTER  = 'filter';
      K_DESC_FILTER  = '';
      K_FMT_FILTER   = '';
      K_CONF_GROUP   = 'group';
      K_DESC_GROUP   = '';
      K_FMT_GROUP    = '^xpl-group\.[a-z0-9]{1,16}$';

const K_XPL_CFG_MAX_FILTERS = 16;
      K_XPL_CFG_MAX_GROUPS  = 16;
      MIN_HBEAT     : Integer = 5;
      MAX_HBEAT     : Integer = 9;


{ TxPLConfig ===========================================================================}
constructor TxPLConfig.create(aOwner : TComponent);
begin
     inherited Create(aOwner);
     fxmlconfig := TXmlConfig.Create(self);
     fConfigItems := TList.Create;

     AddItem(K_CONF_NEWCONF ,''                      , xpl_ctReconf,1,K_DESC_NEWCONF,K_FMT_NEWCONF);
     AddItem(K_CONF_INTERVAL,IntToStr(K_XPL_DEFAULT_HBEAT), xpl_ctReconf,1,K_DESC_INTERVAL,K_FMT_INTERVAL);
     AddItem(K_CONF_FILTER  ,''                      , xpl_ctOption,K_XPL_CFG_MAX_FILTERS,K_DESC_FILTER,K_FMT_FILTER);
     AddItem(K_CONF_GROUP   ,''                      , xpl_ctOption,K_XPL_CFG_MAX_GROUPS,K_DESC_GROUP,K_FMT_GROUP);
end;

destructor TxPLConfig.destroy;                                    
begin                                                                                      
     fConfigItems.Destroy ;
     fxmlconfig.destroy;
     inherited destroy;
end;

procedure TxPLConfig.ResetValues;
var i : integer;
begin
     for i := 0 to Items.Count-1 do Item[i].Clear;
end;

procedure TxPLConfig.ReadFromXML(const aDeviceNode: TDOMNode);
var Child : TDOMNode;
    cfg_name, cfg_desc, cfg_format : string;
begin
   Child := aDeviceNode.FirstChild;
   while Assigned(Child) do begin
         if Child.NodeName = 'configItem' then begin
            cfg_name   := TDOMElement(Child).GetAttribute('name');
            cfg_desc   := TDOMElement(Child).GetAttribute('description');
            cfg_format := TDOMElement(Child).GetAttribute('format');
            AddItem(cfg_name,'',xpl_ctOption,1,cfg_desc,cfg_format);
         end;
         Child := Child.NextSibling;
   end;
end;

function TxPLConfig.GetItem(Index : integer): TxPLConfigItem;
begin Result := TxPLConfigItem(fConfigItems[Index]); end;

function TxPLConfig.GetItemByStr(s : string): TxPLConfigItem;
begin
     result := Item[ItemByName(s)];
end;

procedure TxPLConfig.SetInstance(const AValue: string);
begin SetItem(K_CONF_NEWCONF,aValue); end;

procedure TxPLConfig.SetInterval(const AValue: integer);
begin
     if HBInterval=aValue then exit;

     if ((aValue>=MIN_HBEAT) and (aValue<=MAX_HBEAT)) then
        SetItem(K_CONF_INTERVAL,IntToStr(aValue))
end;

function TxPLConfig.GetInterval: integer;
var i : integer;
begin
     for i := 0 to fConfigItems.Count -1 do
         if Item[i].Key = K_CONF_INTERVAL then result := StrToInt(Item[i].Value);
end;

function TxPLConfig.GetInstance: string;
var i : integer;
begin
     for i := 0 to fConfigItems.Count -1 do
         if Item[i].Key = K_CONF_NEWCONF then result := Item[i].Value;
end;

function TxPLConfig.SetItem(const aItmName : string; const aValue : string) : boolean;
var i : integer;
    s : string;
begin
     result := false;
     // Basic control on some special configuration items
     s := aValue;
     if aItmName = K_CONF_NEWCONF  then s := AnsiLowerCase(aValue);    // instance name can not be in upper case
     if aItmName = K_CONF_INTERVAL then s := IntToStr(StrToIntDef(aValue,MIN_HBEAT));

     for i := 0 to fConfigItems.Count -1 do
         if Item[i].Key = aItmName then result := Item[i].SetValue(s);
end;

procedure TxPLConfig.Save(anIdentifier : string);
var filename  : string;
    i,j : integer;
begin
     filename := 'xpl_' + anIdentifier + '.xml';
     filename := GetCurrentDir + '\' + filename;
     fXmlConfig.Filename:= filename;

     for i := 0 to Count-1 do begin
        for j:= 0 to Item[i].MaxValue -1 do begin;
            fXmlConfig.SetValue(Item[i].Key+'/'+IntToStr(j),Item[i].Values[j]);

        end;
     end;
     fXmlConfig.Flush;
end;

function TxPLConfig.Load(anIdentifier : string) : boolean;
var filename  : string;
    i,j : integer;
begin
   result := false;

   filename := 'xpl_' + anIdentifier + '.xml';
   filename := GetCurrentDir + '\' + filename;

   if FileExists(filename) then begin
        fXmlConfig.Filename:= filename;

        for i := 0 to Count-1 do begin
           for j:= 0 to Item[i].MaxValue -1 do begin;
            Item[i].Values[j] := fXmlConfig.GetValue(Item[i].Key+'/'+IntToStr(j),'');
           end;
        end;
        result := true;
    end;
end;

procedure TxPLConfig.AddItem(aItmName, aDefaultVal: string;
  aConfigType: TxPLConfigType; aMax: integer; aDesc, aFormat: string);
begin
     fConfigItems.Add(TxPLConfigItem.Create(aItmName,aDefaultVal,aConfigType,aMax,aDesc,aFormat));
end;

procedure TxPLConfig.AddValue(aItmName, aValue : string);
var i : integer;
begin
     for i := 0 to fConfigItems.Count -1 do
         if Item[i].Key = aItmName then Item[i].SetValue(aValue);
end;

function TxPLConfig.Count: integer;
begin
     result := fConfigItems.Count;
end;

function TxPLConfig.ItemByName(const aName : string) : integer;
var i : integer;
begin
     result := -1;
     for i:=0 to fConfigItems.Count-1 do
         if Item[i].Key = aName then result := i;
end;


// Filter specific members =========================================================
function TxPLConfig.FilterCount  : integer;
var i : integer;
begin
     for i := 0 to fConfigItems.Count -1 do
         if Item[i].Key = K_CONF_FILTER then result := Item[i].ValueCount;
end;
       
end.

