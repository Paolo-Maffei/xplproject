unit u_xpl_fragment_mgr;

// Implementation of fragment management as described here :
//   http://xplproject.org.uk/forums/viewtopic.php?f=2&t=1099&p=7535#p7535

{$ifdef fpc}
   {$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses Classes
     , SysUtils
     , fpc_delphi_compat
     , u_xpl_message
     , u_xpl_address
     , u_xpl_messages
     , u_xpl_collection
     ;

type // TFragmentFactory ======================================================
     TFragmentFactory = class(TxPLCollectionItem)
     private
        fFragList  : TList;
        fUniqueId  : integer;
        fSource    : TxPLAddress;
        fAssembled : TxPLMessage;

        procedure   Fragment(const aMessage : TxPLMessage; const aCounter : integer);
        procedure   AppendFragment(const aFragment : TFragBasicMsg);
        function Get_Assembled: TxPLMessage;
     public
        constructor Create(aOwner: TCollection); override;
        Destructor  Destroy; override;

        function    IsCompleted  : boolean;
        function    ClaimMissing : TFragmentReqMsg;
     published
        property    FragmentList : TList read fFragList;
        property    Source       : TxPLAddress read fSource;
        property    UniqueId     : integer read fUniqueId;
        property    Assembled    : TxPLMessage read Get_Assembled;
     end;

     TFactoryCollection = {$ifdef fpc}specialize{$endif}TxPLCollection<TFragmentFactory>;

     // TFragmentManager ======================================================
     TFragmentManager = class(TComponent)
     private
        fCounter : integer;
        fTimer  : TxPLTimer;
        fFactoryList : TFactoryCollection;

        procedure TimerCheck(Sender : TObject);
        function  FragmentName(const aAddress : TxPLAddress; const aId : integer) : string;
     public
        Constructor Create(const aOwner : TComponent); reintroduce;
        Destructor Destroy; override;
        function    Fragment(const aMessage : TxPLMessage) : TFragmentFactory;
        function    AddFragment (const aMessage : TFragBasicMsg) : TFragmentFactory;
        function    GetFactory(const aFragIdent : string) : TFragmentFactory;
        function    Handle  (const aMessage : TFragmentMsg) : boolean;
        procedure   Reemit  (const aRequest : TFragmentReqMsg);
     end;

// ============================================================================
implementation

uses StrUtils
     , u_xpl_schema
     , u_xpl_sender
     , u_xpl_common
     , u_xpl_application
     , DateUtils
     ;

// TFragmentManager ===========================================================
constructor TFragmentManager.Create(const aOwner : TComponent);
begin
   inherited Create(aOwner);
   fCounter := 0;
   fFactoryList := TFactoryCollection.Create(self);

   fTimer := TxPLApplication(Owner).TimerPool.Add(3*1000,{$ifdef fpc}@{$endif}TimerCheck);
end;

destructor TFragmentManager.Destroy;
begin
   fFactoryList.Free;
   inherited Destroy;
end;

function TFragmentManager.Fragment(const aMessage: TxPLMessage) : TFragmentFactory;
begin
   result := fFactoryList.Add(FragmentName(aMessage.source,fCounter));
   result.Fragment(aMessage,fCounter);
   inc(fCounter);
   fTimer.Enabled := true;
end;

function TFragmentManager.AddFragment(const aMessage: TFragBasicMsg) : TFragmentFactory;
begin
   Result := GetFactory(aMessage.Identifier);
   if Result = nil then
      Result := fFactoryList.Add(aMessage.Identifier);
   Result.AppendFragment(aMessage);

   fTimer.Enabled := true;
end;

function TFragmentManager.GetFactory(const aFragIdent: string ): TFragmentFactory;
begin
   Result := fFactorylist.FindItemName(aFragIdent);
end;

function TFragmentManager.Handle(const aMessage: TFragmentMsg) : boolean;
var Factory : TFragmentFactory;
    Fragbas : TFragBasicMsg;
begin
   Result := false;
   if aMessage is TFragBasicMsg then begin
      FragBas := TFragBasicMsg.Create(self,aMessage);
      if FragBas.IsValid then begin
         Factory := AddFragment(FragBas);
         if Factory.IsCompleted then aMessage.Assign(Factory.Assembled);
         result := true;
      end;
   end
   else if aMessage is TFragmentReqMsg then Reemit(TFragmentReqMsg(aMessage));
end;

procedure TFragmentManager.Reemit(const aRequest: TFragmentReqMsg);
var i, partnum : integer;
    aMsg : TxPLMessage;
    factory : TFragmentFactory;
    msgId : integer;
    parts : IntArray;
begin
   msgId := aRequest.Message;
   if msgId = -1 then exit;

   factory := fFactoryList.FindItemName(FragmentName(aRequest.target,msgId));
   if not Assigned(factory) then exit;

   Parts := aRequest.Parts;
   for i:=Low(Parts) to High(Parts) do begin
       PartNum := Parts[i]-1;
       if partnum < factory.FragmentList.Count then begin
          aMsg := TxPLMessage(factory.FragmentList[partnum]);
          if Assigned(aMsg) then TxPLSender(Owner).Send(aMsg);
       end;
   end;
end;

procedure TFragmentManager.TimerCheck(Sender: TObject);
var aFragment : TCollectionItem;
    ClaimMsg  : TxPLMessage;
begin
   for aFragment in fFactoryList do begin
       if SecondsBetween(now, TxPLCollectionItem(aFragment).CreateTS) > 10 then
                              aFragment.Free else
       if (SecondsBetween(now, TxPLCollectionItem(aFragment).CreateTS) > 3) and
          (not TFragmentFactory(aFragment).IsCompleted) then begin
             ClaimMsg := TFragmentFactory(aFragment).ClaimMissing;
             TxPLSender(Owner).Send(ClaimMsg);
             ClaimMsg.Free;
          end;
   end;
   fTimer.Enabled := (fFactoryList.Count > 0);
end;

function TFragmentManager.FragmentName(const aAddress: TxPLAddress; const aId: integer): string;
begin
   result := AnsiReplaceStr(aAddress.AsFilter,'.','') + IntToStr(aId);
end;

// TFragmentFactory ===========================================================
procedure TFragmentFactory.AppendFragment(const aFragment: TFragBasicMsg);
var i : integer;
begin
   fUniqueId := aFragment.UniqueId;
   if not Assigned(fSource) then fSource := TxPLAddress.Create(aFragment.source);

   if fFragList.Count=0 then
      for i:=1 to aFragment.PartMax do fFragList.Add(nil);                     // Reserve room for all fragments
   fFragList[Pred(aFragment.PartNum)] := aFragment;
end;

function TFragmentFactory.Get_Assembled: TxPLMessage;
var bodycount : integer;
    i : integer;
    aFrag : TFragBasicMsg;
begin
   if IsCompleted then begin
      if not Assigned(fAssembled) then begin
         aFrag := TFragBasicMsg(fFragList[0]);
         //if aFrag.IsValid then begin
            fAssembled := aFrag.ToMessage;
            for i:=1 to Pred(fFragList.Count) do begin
                bodycount := fAssembled.Body.ItemCount;
                fAssembled.Body.Append(TxPLMessage(fFragList[i]).Body);
                fAssembled.Body.DeleteItem(bodycount);
            end;
         //end;
      end;
      result := fAssembled;
   end else result := nil;
end;

procedure TFragmentFactory.Fragment(const aMessage : TxPLMessage; const aCounter : integer);
var i : integer;
    newfrag : TFragBasicMsg;
begin
   fAssembled := TxPLMessage.Create(nil,aMessage.RawxPL);
   fUniqueId  := aCounter;
   fSource    := TxPLAddress.Create(fAssembled.source);
   i := 0;
   while (i< fAssembled.Body.ItemCount) do begin
         NewFrag := TFragBasicMsg.Create(nil,fAssembled,fFragList.count = 0);

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
       newfrag := TFragBasicMsg(fFragList[i]);
       newfrag.PartNum:=i+1;
       newfrag.PartMax:=fFragList.Count;
       newfrag.UniqueId:=fUniqueId;
   end;
end;

function TFragmentFactory.IsCompleted: boolean;
var i : integer;
begin
   result := true;
   for i:=0 to Pred(fFragList.Count) do
       result := result and (fFragList[i]<>nil);
end;

function TFragmentFactory.ClaimMissing : TFragmentReqMsg;
var i : integer;
begin
   Result := TFragmentReqMsg.Create(nil);
   Result.Target.Assign(fSource);
   Result.Message:=fUniqueId;
   for i:= 0 to Pred(fFragList.Count) do
       if fFragList[i]=nil then Result.AddPart(i+1);
end;

constructor TFragmentFactory.Create(aOwner: TCollection);
begin
   inherited Create(aOwner);
   fFragList := TList.Create;
end;

destructor TFragmentFactory.Destroy;
begin
   fFragList.Free;
   if Assigned(fSource)
      then fSource.Free;
   if Assigned(fAssembled)
      then fAssembled.Free;
   inherited;
end;

end.

