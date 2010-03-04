unit uxPLFilter;
{==============================================================================
  UnitName      = uxPLFilter
  UnitDesc      = xPL Filter management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : first published version
}

{$mode objfpc}{$H+}

interface

uses SysUtils, uxPLConfig, uxPLMsgHeader, uxPLConst, uxPLMessage;

type
     TxPLFilters = class
     private
        iFilterIndex : integer;
        iGroupIndex  : integer;
        fConfig : TxPLConfig;
     public
        constructor create(aConfig : TxPLConfig);
        function FilterCount : integer;
        function GroupCount : integer;
        function CheckGroup(aTargetName : string) : boolean;
        function MatchesFilters(aMessage : TxPLMessage) : boolean;

        class function  Matches ( const aFilter : tsFilter; const aMessageFilterTag : tsFilter) : boolean;
        class procedure Split   ( const aFilter : tsFilter;           out aMsgType : TxPLMessageType;
                                  out aVendor  : tsVendor;          out aDevice  : tsDevice;
                                  out aInstance: tsInstance;        out aClasse  : tsClass;
                                  out aType    : tsType);
     end;

implementation // ==============================================================
uses StrUtils, cStrings, cUtils;
//==============================================================================

class procedure TxPLFilters.Split( const aFilter : tsFilter;         out aMsgType : TxPLMessageType;
                                   out aVendor   : tsVendor;         out aDevice  : tsDevice;
                                   out aInstance : tsInstance;       out aClasse  : tsClass;
                                   out aType     : tsType);
var  sFlt : stringArray;
begin
     sFlt := StrSplit(aFilter,'.');  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType

     aMsgType := TxPLMsgHeader.String2MsgType(sFlt[0]);
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

constructor TxPLFilters.Create(aConfig : TxPLConfig);
begin
     fConfig := aConfig;

     iFilterIndex := -1;
     repeat
           inc(iFilterIndex);
     until fConfig.Item[iFilterIndex].Key = 'filter';

     iGroupIndex := -1;
     repeat
           inc(iGroupIndex);
     until fConfig.Item[iGroupIndex].Key = 'group';
end;

function TxPLFilters.FilterCount  : integer;
begin
     result := fConfig.Item[iFilterIndex].ValueCount;
     if result = 1 then
        if (fConfig.Item[iFilterIndex].Values[0]='') then result := 0;

end;

function TxPLFilters.GroupCount  : integer;
begin result := fConfig.Item[iGroupIndex].ValueCount; end;

function TxPLFilters.CheckGroup(aTargetName: string): boolean;
const K_GROUP_NAME_ID = 'xpl-group.';
var   i : integer;
begin
     result := false;
     if not (AnsiLeftStr(aTargetName,length(K_GROUP_NAME_ID)) = K_GROUP_NAME_ID) then exit;
     for i := 0 to GroupCount -1 do
         if fConfig.Item[iGroupIndex].Values[i] = aTargetName then result := true;
end;

function TxPLFilters.MatchesFilters(aMessage: TxPLMessage): boolean;
var i : integer;
begin
     result := true;
     for i:= 0 to FilterCount -1 do
         result := result and Matches(  fConfig.Item[iFilterIndex].Values[i],
                                        aMessage.FilterTag);
end;

end.

