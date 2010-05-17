unit uxPLConfig;
{==============================================================================
  UnitName      = uxPLConfig
  UnitVersion   = 0.92
  UnitDesc      = xPL Configuration elements manipulation unit
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Initial full version of this file
 0.92 : Removal of format and descriptions from this unit, they shall be handled from PluginFile
        ==> we make the assumption that provided values have by checked through Regexpr by the configurator tool
 0.93 : Declaration of configuration items is now based on the content of the vendor.xml file
        The AddItem is now moved as private, shouldn't be called by
        Configuration files are now stored in the config directory hold by xplsettings.
 }

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, uxPLConst,  uxPLCfgItem, XmlCfg, DOM, uxPLPluginFile;

type

{ TxPLConfig }

TxPLConfig = class(TComponent)
     private
        fConfigItems : TList;
        fxmlconfig : TXmlConfig;
        fDeviceInVendorFile : TxPLDevice;

        function GetInstance: string;
        function GetInterval: integer;
        function GetItem(Index : integer): TxPLConfigItem;
        function GetItemByStr(s : string): TxPLConfigItem;
        procedure SetInstance(const AValue: string);
        procedure SetInterval(const AValue: integer);

     public
        constructor create(aOwner : TComponent); override;
        destructor  destroy; override;

        procedure AddValue(aItmName, aValue : string);
        procedure SetItem(const aItmName : string; const aValue : string); // : boolean;
        procedure AddItem(const aItmName : string; aConfigType : TxPLConfigType; const aDefaultVal : string = ''; const aMax : integer = 1{; aDesc, aFormat : string});
        procedure AddItem(const aItmName : string; aConfigType : TxPLConfigType; aDesc, aFormat : string; const aMax : integer = 1; const aDefaultVal : string = ''); overload;
        procedure ResetValues;
        procedure Save;

        function Load : boolean;
        function Count : integer;
        function ItemByName(const aName : string) : integer;

        property HBInterval : integer read GetInterval write SetInterval;
        property Instance : string  read GetInstance write SetInstance;
        property Item[Index : integer] : TxPLConfigItem read GetItem; default;
        property ItemName[s : string] : TxPLConfigItem read GetItemByStr;
        property Items : TList read fConfigItems;
        property XmlFile : TXmlConfig read fxmlconfig;
        property DeviceInVendorFile : TxPLDevice read fDeviceInVendorFile;

        procedure ReadFromXML(const aDeviceNode : TDOMNode);
        // Filter specific
        function  FilterCount : integer;

     end;

implementation { =======================================================================}
uses uxPLListener, uxPLClient;

{ TxPLConfig ===========================================================================}
constructor TxPLConfig.create(aOwner : TComponent);
var //device    : TxPLDevice;
    sVendor   : tsVendor;
    sDevice   : tsDevice;
    sInstance : tsInstance;
begin
     inherited Create(aOwner);

     sVendor   := TxPLListener(aOwner).Vendor;
     sDevice   := TxPLListener(aOwner).Device;
     sInstance := TxPLListener(aOwner).Instance;

     fxmlconfig := TXmlConfig.Create(self);
     fXmlConfig.Filename:= TxPLListener(aOwner).Setting.ConfigDirectory + Format(K_FMT_CONFIG_FILE,[sVendor,sDevice]);

     fConfigItems := TList.Create;

     AddItem(K_CONF_NEWCONF , xpl_ctReconf,K_DESC_NEWCONF,K_RE_NEWCONF,1,sInstance);                       // Standard to all xPL apps configuration elements
     AddItem(K_CONF_INTERVAL, xpl_ctReconf,K_DESC_INTERVAL,K_RE_INTERVAL,1,IntToStr(K_XPL_DEFAULT_HBEAT));
     AddItem(K_CONF_FILTER  , xpl_ctOption,K_DESC_FILTER, K_RE_FILTER,K_XPL_CFG_MAX_FILTERS,'');
     AddItem(K_CONF_GROUP   , xpl_ctOption,K_DESC_GROUP, K_RE_GROUP,K_XPL_CFG_MAX_GROUPS,'');

     fDeviceInVendorFile := TxPLListener(aOwner).PluginList.GetDevice(sVendor,sDevice);
     if not Assigned(fDeviceInVendorFile) then TxPLClient(aOwner).LogInfo(K_MSG_ERROR_PLUGIN,[]);
end;

destructor TxPLConfig.destroy;                                    
begin
   if Assigned(fDeviceInVendorFile) then fDeviceInVendorFile.Destroy;
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
    cfg_name, cfg_desc, cfg_frmt : string;
begin
   Child := aDeviceNode.FirstChild;
   while Assigned(Child) do begin
         if Child.NodeName = 'configItem' then begin
            cfg_name   := TDOMElement(Child).GetAttribute('name');
            cfg_desc   := TDOMElement(Child).GetAttribute('description');
            cfg_frmt   := TDOMElement(Child).GetAttribute('format');
            AddItem(cfg_name,xpl_ctConfig,cfg_desc,cfg_frmt);
         end;
         Child := Child.NextSibling;
   end;
   TxPLClient(Owner).LogInfo(K_MSG_OK_PLUGIN,[]);
end;

function TxPLConfig.GetItem(Index : integer): TxPLConfigItem;
begin
   if Index<>-1 then Result := TxPLConfigItem(fConfigItems[Index]);
end;

function TxPLConfig.GetItemByStr(s : string): TxPLConfigItem;
var i : integer;
begin
     i :=  ItemByName(s);
     if i<>-1 then result := Item[ItemByName(s)]
              else result := nil;
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

procedure TxPLConfig.SetItem(const aItmName : string; const aValue : string); // : boolean;
var i : integer;
    s : string;
begin
     //result := false;
     // Basic control on some special configuration items
     s := aValue;
     if aItmName = K_CONF_NEWCONF  then s := AnsiLowerCase(aValue);    // instance name can not be in upper case
     if aItmName = K_CONF_INTERVAL then s := IntToStr(StrToIntDef(aValue,MIN_HBEAT));

     for i := 0 to fConfigItems.Count -1 do
         if Item[i].Key = aItmName then Item[i].SetValue(s); //result := Item[i].SetValue(s);
end;

procedure TxPLConfig.Save;
var i,j : integer;
begin
   for i := 0 to Count-1 do
      for j:= 0 to Item[i].MaxValue -1 do
         fXmlConfig.SetValue(Item[i].Key+'/'+IntToStr(j),Item[i].Values[j]);

   fXmlConfig.Flush;
end;

function TxPLConfig.Load : boolean;
var i,j : integer;
begin
   result := false;

   if not FileExists(fXmlConfig.Filename) then exit;

   for i := 0 to Count-1 do
       for j:= 0 to Item[i].MaxValue -1 do
           Item[i].Values[j] := fXmlConfig.GetValue(Item[i].Key+'/'+IntToStr(j),'');

   result := true;
end;

procedure TxPLConfig.AddItem(const aItmName : string; aConfigType : TxPLConfigType; const aDefaultVal : string; const aMax : integer);
begin
   if ItemName[aItmName] <> nil then                  // a configuration item may be added programmatically
      fConfigItems.Delete(ItemByName(aItmName));      // it must then override any item initiated by the xml file
   fConfigItems.Add(TxPLConfigItem.Create(aItmName,aDefaultVal,aConfigType,aMax));
end;

procedure TxPLConfig.AddItem(const aItmName: string; aConfigType: TxPLConfigType; aDesc, aFormat: string; const aMax : integer = 1; const aDefaultVal : string = '');
begin
   if ItemName[aItmName] <> nil then                  // a configuration item may be added programmatically
      fConfigItems.Delete(ItemByName(aItmName));      // it must then override any item initiated by the xml file
   fConfigItems.Add(TxPLConfigItem.Create(aItmName,aDefaultVal,aConfigType,aDesc,aFormat,aMax));
end;

procedure TxPLConfig.AddValue(aItmName, aValue : string);
var i : integer;
begin
     for i := 0 to fConfigItems.Count -1 do
         if Item[i].Key = aItmName then Item[i].SetValue(aValue);
end;

function TxPLConfig.Count: integer;
begin
   result := -1;
   if Assigned(fConfigItems) then result := fConfigItems.Count;
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

