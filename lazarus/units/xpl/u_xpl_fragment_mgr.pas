unit u_xpl_fragment_mgr;

// Implementation of fragment management as described here :
//   http://xplproject.org.uk/forums/viewtopic.php?f=2&t=1099&p=7535#p7535

{$ifdef fpc}
   {$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses Classes
     , SysUtils
     , u_xpl_custom_message
     , u_xpl_address
     , fpc_delphi_compat
     , u_xpl_collection
     ;

type // TFragmentFactory ======================================================
     TFragmentFactory = class(TxPLCollectionItem)
     private
        fFragList  : TList;
        fUniqueId  : integer;
        fSource    : TxPLAddress;
        fAssembled : TxPLCustomMessage;

        procedure   Fragment(const aMessage : TxPLCustomMessage; const aCounter : integer);
        procedure   Combine (const aMessage : TxPLCustomMessage);
        function Get_Assembled: TxPLCustomMessage;
     public
        constructor Create(aOwner: TCollection); override;
        Destructor  Destroy; override;

        function    IsCompleted  : boolean;
     published
        property    FragmentList : TList read fFragList;
        property    Source       : TxPLAddress read fSource;
        property    UniqueId     : integer read fUniqueId;
        property    Assembled    : TxPLCustomMessage read Get_Assembled;
     end;

     TFactoryCollection = specialize TxPLCollection<TFragmentFactory>;

     // TFragmentManager ======================================================
     TFragmentManager = class(TComponent)
     private
        fCounter : integer;
        fTimer    : TxPLTimer;
        fFactoryList : TFactoryCollection;

        procedure TimerCheck(Sender : TObject);
        function  FragmentName(const aAddress : TxPLAddress; const aId : integer) : string;
     public
        Constructor Create(const aOwner : TComponent);
        function    Fragment(const aMessage : TxPLCustomMessage) : TFragmentFactory;
        function    Combine (const aMessage : TxPLCustomMessage) : TFragmentFactory;
     end;

// ============================================================================
implementation

uses StrUtils
     , u_xpl_schema
     , jclStrings
     , DateUtils
     ;

// TFragmentManager ===========================================================
constructor TFragmentManager.Create(const aOwner : TComponent);
begin
   inherited;
   fCounter := 0;
   fFactoryList := TFactoryCollection.Create(self);
   fTimer   := TxPLTimer.Create(self);
   fTimer.Interval := 3 * 1000;
   fTimer.OnTimer  := {$ifdef fpc}@{$endif}TimerCheck;
end;

function TFragmentManager.Fragment(const aMessage: TxPLCustomMessage) : TFragmentFactory;
begin
   result := fFactoryList.Add(FragmentName(aMessage.source,fCounter));
   result.Fragment(aMessage,fCounter);
   inc(fCounter);
   fTimer.Enabled := true;
end;

function TFragmentManager.Combine(const aMessage: TxPLCustomMessage) : TFragmentFactory;
var fragid : integer;
    partid : string;
    list   : TStringList;
begin
   Result := nil;
   if aMessage.Schema.IsFragment then begin
      partid := AnsiReplaceStr(aMessage.Body.GetValueByKey('partid'),':','/');
      list := TStringList.Create;
      StrTokenToStrings(partid,'/',list);
      fragid  := StrToInt(list[2]);
      list.Free;

      Result := fFactoryList.FindItemName(FragmentName(aMessage.Source,fragid));
      if Result = nil then
         Result := fFactoryList.Add(FragmentName(aMessage.Source,FragId));
      result.Combine(aMessage);
   end;
end;

procedure TFragmentManager.TimerCheck(Sender: TObject);
var aFragment : TCollectionItem;
begin
   for aFragment in fFactoryList do begin
       if SecondsBetween(now, TxPLCollectionItem(aFragment).CreateTS) > 10 then begin
          aFragment.Free;
       end;
   end;
   fTimer.Enabled := (fFactoryList.Count > 0);
end;

function TFragmentManager.FragmentName(const aAddress: TxPLAddress; const aId: integer): string;
begin
   result := AnsiReplaceStr(aAddress.AsFilter,'.','') + IntToStr(aId);
end;

// TFragmentFactory ===========================================================
procedure TFragmentFactory.Combine(const aMessage: TxPLCustomMessage);
var i, maxfrag, fragnum : integer;
    partid : string;
    list   : TStringList;
begin
   partid := AnsiReplaceStr(aMessage.Body.GetValueByKey('partid'),':','/');
   list := TStringList.Create;
   StrTokenToStrings(partid,'/',list);
   fragnum := StrToInt(list[0]);
   maxfrag := StrToInt(list[1]);
   fUniqueId := StrToInt(list[2]);
   list.Free;

   if fFragList.Count=0 then
      for i:=0 to pred(maxfrag) do fFragList.Add(nil);                     // Reserve room for all fragments
   if fFragList[pred(fragnum)]=nil then fFragList[pred(fragnum)] := TxPLCustomMessage.Create(nil,aMessage.RawXPL);
end;

function TFragmentFactory.Get_Assembled: TxPLCustomMessage;
var bodycount : integer;
    i : integer;
begin
   if IsCompleted then begin
      if not Assigned(fAssembled) then begin
         fAssembled := TxPLCustomMessage.Create(nil);
         fAssembled.Assign(TxPLCustomMessage(fFragList[0]));
         fAssembled.schema.RawxPL:=TxPLCustomMessage(fFragList[0]).Body.GetValueByKey('schema');
         fAssembled.Body.DeleteItem(0);
         fAssembled.Body.DeleteItem(0);
         for i:=1 to Pred(fFragList.Count) do begin
             bodycount := fAssembled.Body.ItemCount;
             fAssembled.Body.Append(TxPLCustomMessage(fFragList[i]).Body);
             fAssembled.Body.DeleteItem(bodycount);
         end;
      end;
      result := fAssembled;
   end;
end;

procedure TFragmentFactory.Fragment(const aMessage : TxPLCustomMessage; const aCounter : integer);
var i : integer;
    newfrag : TxPLCustomMessage;
begin
   fAssembled := TxPLCustomMessage.Create(nil,aMessage.RawxPL);
   fUniqueId := aCounter;
   fSource   := TxPLAddress.Create(fAssembled.source);
   i := 0;
   while (i< fAssembled.Body.ItemCount) do begin
         newfrag := TxPLCustomMessage.Create(nil);
         newfrag.AssignHeader(fAssembled);
         newfrag.schema.assign(Schema_FragBasic);
         newfrag.body.addkeyvaluepairs(['partid'],['%d/%d:%d']);
         if fFragList.count = 0 then
            newfrag.body.addkeyvaluepairs(['schema'],[fAssembled.Schema.RawxPL]);

         while (i<fAssembled.Body.ItemCount) and (not newfrag.mustfragment) do begin
               newfrag.Body.AddKeyValuePairs([fAssembled.Body.Keys[i]],[fAssembled.Body.Values[i]]);
               inc(i);
         end;

         if newfrag.mustfragment then begin
            newfrag.Body.DeleteItem(newfrag.body.itemcount-1);
            dec(i);
         end;

            fFragList.Add(newfrag);
   end;

   for i:=0 to Pred(fFragList.count) do begin
       newfrag := TxPLCustomMessage(fFragList[i]);
       newfrag.body.Values[0] := Format(newfrag.body.Values[0],[i+1,fFragList.count,fUniqueId]);
   end;
end;

function TFragmentFactory.IsCompleted: boolean;
var i : integer;
begin
   result := true;
   for i:=0 to Pred(fFragList.Count) do
       result := result and (fFragList[i]<>nil);
end;

constructor TFragmentFactory.Create(aOwner: TCollection);
begin
   inherited Create(aOwner);
   fFragList := TList.Create;
end;

destructor TFragmentFactory.Destroy;
begin
   fFragList.Free;
   if Assigned(fSource) then fSource.Free;
   inherited;
end;

end.

