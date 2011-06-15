unit u_xpl_cache_manager;

{$mode objfpc}

interface

uses Classes
     , SysUtils
     , u_xpl_globals
     , u_xpl_message
     , u_xml_cachemanager
     ;

type

{ TxPLCacheManager }

TxPLCacheManager = class(TObject)
     private
       fGlobals : TxPLCustomGlobals;
       fCacheManager : TXMLCacheManagerType;
     public
       constructor Create(const aDirectory : string; const aGlobalList : TxPLCustomGlobals);
       destructor  Destroy; override;

       function    Process(const aMessage : TxPLMessage) : boolean;
     end;

implementation

uses uRegExpr
     , StrUtils
     , u_xpl_common
     ;

{ TxPLCacheManager }

constructor TxPLCacheManager.Create(const aDirectory : string; const aGlobalList: TxPLCustomGlobals);
begin
   inherited Create;
   fCacheManager := InitCacheManager(aDirectory);
   fGlobals := aGlobalList;
end;

destructor TxPLCacheManager.Destroy;
begin
   fCacheManager.Free;
   inherited Destroy;
end;

function TxPLCacheManager.Process(const aMessage: TxPLMessage) : boolean;
   function ReplaceVariable(const aPrefix : string) : string;
   var variable : string;
       modified : string;
       i : integer;
       bLoop : boolean;
   begin
      result := aPrefix;
      with TRegExpr.Create do begin
           Expression := '{(.*?)}';
           bLoop := Exec(result);
           while bLoop do begin
                 variable := match[1];
                 modified := variable[1];
                 for i := 1 to length(variable) do begin
                     modified += '.';
                     modified += variable[i];
                 end;
                 modified := AnsiReplaceStr(modified,'V',aMessage.Source.Vendor);
                 modified := AnsiReplaceStr(modified,'D',aMessage.Source.Device);
                 modified := AnsiReplaceStr(modified,'I',aMessage.Source.Instance);
                 result := AnsiReplaceStr(result,match[0],modified);
                 bLoop := ExecNext;
           end;
           Free;
      end;
   end;

var s,value,cacheprefix, tagname,header, cachedobjectname : string;
    global : TxPLGlobalValue;
    i,j,k : integer;
begin
  result := false;
  Header := aMessage.SourceFilter;
  for i := 0 to fCacheManager.Count - 1 do begin
      s := fCacheManager[i].Filter;
      if XPLMatches(s,Header) then begin
         cacheprefix := ReplaceVariable(fCacheManager[i].CachePrefix);
         for j:=0 to fCacheManager[i].Fields.Count-1 do begin
             tagname := fCacheManager[i].Fields[j].XplTagName;
             cachedobjectname := fCacheManager[i].Fields[j].CacheObjectName;
             if cachedobjectname = '*' then begin
                for k:=0 to aMessage.Body.Keys.Count-1 do begin
                    Global := fGlobals.Add(cacheprefix + '.' + aMessage.Body.Keys[k]);
                    Global.Value := aMessage.Body.Values[k];
                    result := true;
                end;
             end else begin
                Value :=  aMessage.Body.GetValueByKey(tagname);
                if Value <>'' then begin
                Global := fGlobals.Add( cacheprefix + '.' + cachedobjectname);
                Global.Value := Value;
                result := true;
             end;
             end;
         end;
      end;
  end;
end;

// L'ancien système de caching
//for i := 0 to fxPLCacheManager.Count-1 do
//    if TxPLFilters.Matches(fxPLCacheManager.Filter(i),axPLMessage.FilterTag) then
//       for j := 0 to fxPLCacheManager.CachedCount(i) - 1 do begin
//           aValue := fxPLCacheManager.CachedItem(i,j);
//           if aValue = '*' then begin                                                  // Handle all items contained in the message
//               for k := 0 to axPLMessage.Body.Keys.Count-1 do
//                  Value( fxPLCacheManager.ComposeCachedName(i,axPLMessage.Body.Keys[k], axPLMessage.Source), axPLMessage.Body.Values[k]);
//           end else begin                                                              // Handle only this item
//               k := axPLMessage.Body.Keys.IndexOf(aValue);
//               Value( fxPLCacheManager.ComposeCachedName(i,fxPLCacheManager.CachedName(i,j), axPLMessage.Source), axPLMessage.Body.Values[k]);
//           end;
//       end;

end.

