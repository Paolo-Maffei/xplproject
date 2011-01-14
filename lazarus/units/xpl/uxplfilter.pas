unit uxPLFilter;
{==============================================================================
  UnitName      = uxPLFilter
  UnitDesc      = xPL Filter management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : first published version
 0.92 : small cosmetic modifications
}

{$mode objfpc}{$H+}

interface

uses SysUtils, uxPLConfig, uxPLConst, uxPLMessage;

type
     TxPLFilters = class
     private
        iFilterIndex : integer;
        iGroupIndex  : integer;
        fConfig : TxPLConfig;
     public
        constructor create(const aConfig : TxPLConfig);
        function FilterCount : integer;
        function GroupCount : integer;
        function CheckGroup(const aTargetName : string) : boolean;
        function MatchesFilters(const aMessage : TxPLMessage) : boolean;

        class function  Matches ( const aFilter , aMessageFilterTag : tsFilter) : boolean;
        class procedure Split   ( const aFilter : tsFilter;         out aMsgType : tsMsgType;
                                  out aVendor  : tsVendor;          out aDevice  : tsDevice;
                                  out aInstance: tsInstance;        out aClasse  : tsClass;
                                  out aType    : tsType);
     end;

implementation // ==============================================================
uses StrUtils,
     cStrings,
     cUtils;

//==============================================================================

class procedure TxPLFilters.Split( const aFilter : tsFilter;         out aMsgType : tsMsgType;
                                   out aVendor   : tsVendor;         out aDevice  : tsDevice;
                                   out aInstance : tsInstance;       out aClasse  : tsClass;
                                   out aType     : tsType);
var  sFlt : stringArray;
begin
     sFlt := StrSplit(aFilter,'.');  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType

     aMsgType := sFlt[0];
     aVendor  := sFlt[1];
     aDevice  := sFlt[2];
     aInstance:= sFlt[3];
     aClasse  := sFlt[4];
     aType    := sFlt[5];
end;

class function TxPLFilters.Matches(const aFilter: tsFilter; const aMessageFilterTag: tsFilter): boolean;
var iFltElement : integer;
    sFlt, sMsg : stringArray;
begin
     result := true;

     sFlt := StrSplit(aFilter ,'.');                                                      // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
     sMsg := StrSplit(aMessageFilterTag,'.');

     For iFltElement := 0 to High(sFlt) do
         if (sFlt[iFltElement]<>'*') then result := result and (sFlt[iFltElement]=sMsg[iFltElement])
end;

{ TxPLFilters }

constructor TxPLFilters.Create(const aConfig : TxPLConfig);
var i : integer;
begin
     fConfig := aConfig;

     for i:=1 to fConfig.ItemCount do begin
        if fConfig.ItemName(i) = K_XPL_CONFIGFILTER then iFilterIndex := i;
        if fConfig.ItemName(i) = K_XPL_CONFIGGROUP then iGroupIndex := i;
     end;
end;

function TxPLFilters.FilterCount  : integer;
begin
   result := fConfig.ValueCount(iFilterIndex);
   if result = 1 then
        if (fConfig.ItemValue(iFilterIndex)='') then result := 0;
end;

function TxPLFilters.GroupCount  : integer;
begin
   result := fConfig.ValueCount(iGroupIndex);
   if result = 1 then
        if (fConfig.ItemValue(iGroupIndex)='') then result := 0;
end;

function TxPLFilters.CheckGroup(const aTargetName: string): boolean;
var   i : integer;
begin
   result := false;
   if not (AnsiLeftStr(aTargetName,length(K_GROUP_NAME_ID)) = K_GROUP_NAME_ID) then exit;         // Should use K_RE_GROUP instead of this

   for i := 1 to GroupCount  do
       if fConfig.ItemValue(iGroupIndex,i) = aTargetName then result := true;
end;

function TxPLFilters.MatchesFilters(const aMessage: TxPLMessage): boolean;
var i : integer;
begin
   result := (FilterCount=0);                                                                    // If no filter present then always pass
   if not result then                                                                            // if filters are present
      for i:= 1 to FilterCount  do                                                               // check if at least one matches
          result := result or Matches(  fConfig.ItemValue(iFilterIndex,i), aMessage.SourceFilterTag);
end;

end.

