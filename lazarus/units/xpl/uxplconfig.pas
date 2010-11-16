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
 0.94 : Added ability to avoid need to load config
 0.95 : Cutted inheritance from TComponent
 0.96 : Added use of u_xmlxplplugin
 0.97 : Dropped uxplCfgItem, replaced by u_xml_config
 }

{$mode objfpc}{$H+}

interface

uses Classes,
     SysUtils,
     uxPLConst,
     u_xml_config,
     u_xml_xplplugin;

type

{ TxPLConfig }

  TxPLConfig = class
     private
        fconfigfile : TXMLxplconfigFile;
        fDeviceInVendorFile : TXMLDeviceType;

        function GetItem(Index : integer): TXMLConfigItemType;
        function GetItemByStr(s : string): TXMLConfigItemType;
        procedure AddValue(const elmt : TXMLConfigItemType; const aValue : string);
     public
        constructor create(const aOwner : TObject; const bConfigNeeded : boolean = true);
        destructor  destroy; override;

        procedure SetItem(const aItmName : string; const aValue : string); // : boolean;
        procedure AddItem(const aItmName, aConfigType : string; aDesc, aFormat : string; const aMax : integer = 1; const aDefaultVal : string = ''); overload;
        procedure ResetValues;
        procedure Save;

        function Count : integer;

        property Item[Index : integer] : TXMLConfigItemType read GetItem; default;
        property ItemName[s : string] : TXMLConfigItemType read GetItemByStr;
        property DeviceInVendorFile : TXMLDeviceType read fDeviceInVendorFile;
        property ConfigFile : TXMLxplConfigFile read fConfigFile;
        procedure ReadFromXML(const aDeviceType : TXMLDeviceType);
        // Filter specific
        function  FilterCount : integer;
        function IsValid : boolean;
     end;

implementation { =======================================================================}
uses uxPLListener,
     StrUtils,
     uxPLAddress,
     uRegExpr;

{ TxPLConfig ===========================================================================}
constructor TxPLConfig.create(const aOwner : TObject; const bConfigNeeded : boolean = true);
begin
   with TxPLListener(aOwner) do begin
      fConfigFile   := TXMLxplconfigFile.Create(Settings.ConfigDirectory + Format(K_FMT_CONFIG_FILE,[Vendor,Device]));

      AddItem(K_CONF_NEWCONF , K_XPL_CT_RECONF, K_DESC_NEWCONF , K_RE_NEWCONF , 1, IfThen(bConfigNeeded,TxPLAddress.RandomInstance,TxPLAddress.HostNmInstance));                       // Standard to all xPL apps configuration elements
      AddItem(K_CONF_INTERVAL, K_XPL_CT_RECONF, K_DESC_INTERVAL, K_RE_INTERVAL, 1, IntToStr(K_XPL_DEFAULT_HBEAT));
      AddItem(K_CONF_FILTER  , K_XPL_CT_OPTION, K_DESC_FILTER  , K_RE_FILTER  , K_XPL_CFG_MAX_FILTERS,'');
      AddItem(K_CONF_GROUP   , K_XPL_CT_OPTION, K_DESC_GROUP   , K_RE_GROUP   , K_XPL_CFG_MAX_GROUPS,'');
      fDeviceInVendorFile := PluginList.GetDevice(Vendor,Device);
      if not Assigned(fDeviceInVendorFile) then LogInfo(K_MSG_ERROR_PLUGIN,[]);

   end;
end;

destructor TxPLConfig.destroy;                                    
begin
   if Assigned(fDeviceInVendorFile) then fDeviceInVendorFile.Destroy;
   fConfigFile.Destroy;
end;

procedure TxPLConfig.ResetValues;
var i : integer;
begin
   for i := 0 to fConfigFile.Count-1 do fConfigFile.Element[i].Values.EmptyList;
end;

procedure TxPLConfig.ReadFromXML(const aDeviceType : TXMLDeviceType);
var i : integer;
begin
   for i:=0 to aDeviceType.ConfigItems.Count-1 do
      AddItem( aDeviceType.ConfigItems[i].name, K_XPL_CT_CONFIG, aDeviceType.ConfigItems[i].description, aDeviceType.ConfigItems[i].format );
end;

function TxPLConfig.GetItem(Index : integer): TXMLConfigItemType;
begin
   if Index<>-1 then Result := fConfigFile[Index];
end;

function TxPLConfig.GetItemByStr(s : string): TXMLConfigItemType;
var i : integer;
begin
   result := nil;
   for i:=0 to fConfigFile.Count-1 do
       if fConfigFile[i].Name = s then result := fConfigFile[i];
end;

procedure TxPLConfig.SetItem(const aItmName : string; const aValue : string);
var s : string;
    elmt : TXMLConfigItemType;
begin
     case AnsiIndexStr(aItmName,[K_CONF_NEWCONF,K_CONF_INTERVAL]) of             // Basic control on some special configuration items
        0 : s := AnsiLowerCase(aValue);                                         // instance name can not be in upper case
        1 : s := IntToStr(StrToIntDef(aValue,MIN_HBEAT));
        else s := aValue;
     end;

     elmt := fConfigFile.ElementByName[aItmName];
     if elmt<>nil then AddValue(elmt,s);
end;

procedure TxPLConfig.Save;
begin
   fConfigFile.Save;
end;

procedure TxPLConfig.AddValue(const elmt: TXMLConfigItemType; const aValue : string);
var i,j : integer;
    bAlreadyPresent : boolean;
begin
   if aValue = '' then exit;
   i := elmt.Values.Count;
   if i = 0 then elmt.Values.AddElement(aValue) else begin
      bAlreadyPresent := False;
      for j:=0 to i-1 do if elmt.Values[j].Value = aValue then bAlreadyPresent := True;
      if not bAlreadyPresent then begin
         if i < elmt.MaxValue then elmt.Values.AddElement(aValue)
                              else elmt.Values[elmt.MaxValue-1].Value := aValue;
      end;
   end;
end;

procedure TxPLConfig.AddItem(const aItmName: string; const aConfigType: string; aDesc, aFormat: string; const aMax : integer = 1; const aDefaultVal : string = '');
var elmt : TXMLConfigItemType;
begin
//   if ItemName[aItmName] <> nil then                  // a configuration item may be added programmatically
//      fConfigItems.Delete(ItemByName(aItmName));      // it must then override any item initiated by the xml file
//   fConfigItems.Add(TxPLConfigItem.Create(aItmName,aDefaultVal,aConfigType,aDesc,aFormat,aMax));

   if fConfigFile.ElementByName[aItmName] <> nil then exit;

   elmt := fConfigFile.AddElement(aItmName);
   elmt.ConfigType  := aConfigType;
   elmt.description := aDesc;
   elmt.Format      := aFormat;
   elmt.MaxValue    := aMax;
   AddValue(elmt, aDefaultVal);
end;

function TxPLConfig.Count: integer;
begin
   result := fConfigFile.Count;
end;


// Filter specific members =========================================================
function TxPLConfig.FilterCount  : integer;
var i : integer;
begin
     for i := 0 to fConfigFile.Count-1 do
         if fConfigFile[i].Name = K_CONF_FILTER then result := fConfigFile[i].Values.Count;
end;

function TxPLConfig.IsValid : boolean;
   function test(const aReg, aValue : string) : boolean;
   begin
      with TRegExpr.Create do begin
         Expression := aReg;
         Result := Exec(aValue);
      end;
   end;

var i,j : integer;
    reg,ct,value : string;
    elmt : TXMLConfigItemType;
begin
   result := true;
   for i:=0 to fConfigFile.Count-1 do begin
       elmt:= fConfigFile[i];
       reg := elmt.Format;                                                                 // Get his validation format
       ct  := elmt.ConfigType;                                                             // And his config type
       if (ct <> K_XPL_CT_OPTION) and (elmt.Values.Count = 0) then result := false else    // If it is not optional and no value given then its wrong else
          if reg<>'' then                                                                  // if a formatting rule has been provided
             for j:=0 to elmt.Values.Count-1 do                                            // test every value against his format
                 result := result and test(Reg,elmt.Values[j].Value)
   end;
end;

end.

