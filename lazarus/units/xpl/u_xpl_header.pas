unit u_xPL_Header;
{==============================================================================
  UnitName      = uxPLHeader
  UnitDesc      = xPL Message Header management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.96 : Rawdata passed are no longer transformed to lower case, then Header has
        to lower it
 0.99 : Added usage of uRegExTools
 1.00 : Suppressed usage of uRegExTools to correct bug #FS47
 1.1    Switched schema from Body to Header
        optimizations in SetRawxPL to avoid inutile loops
 1.5  : Added fControlInput property to override read/write controls needed for OPC
 }

{$ifdef fpc}
   {$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses Classes
     , u_xpl_address
     , u_xpl_schema
     , u_xpl_common
     ;

type // TxPLHeader ============================================================
     TxPLHeader = class(TComponent, IxPLCommon, IxPLRaw)
     private
        fSource  : TxPLAddress;
        fTarget  : TxPLTargetAddress;
        fSchema  : TxPLSchema;
        fMsgType : TxPLMessageType;
        fHop     : integer;

        function Get_ControlInput: boolean;
        function  Get_RawxPL : string;
        procedure Set_Hop(const AValue: integer);

        procedure Set_RawxPL(const aRawXPL : string);
        procedure Set_MessageType(const AValue: TxPLMessageType);
        procedure Set_Schema(const AValue: TxPLSchema);
        procedure Set_Source(const AValue: TxPLAddress);
        procedure Set_Target(const AValue: TxPLTargetAddress);
     protected
        procedure MessageTypeFromStr(const aString : string); dynamic;
        function MessageTypeToStr : string; dynamic;
        procedure Set_ControlInput(const AValue: boolean); dynamic;
     public
        constructor Create(aOwner : TComponent; const aFilter : string = ''); reintroduce;
        destructor  Destroy; override;

        procedure   Assign(aHeader : TPersistent); override;
        procedure   ResetValues; dynamic;
        function    IsValid : boolean; dynamic;

        procedure   Reply;
        function    MatchesFilter(aFilterSet : TStringList) : boolean;
        function    SourceFilter : string;                                       // Returns a message like a filter string
        function    TargetFilter : string;
        function    HeaderFilter : string;

        property RawxPL : string read Get_RawxPL write Set_RawxPL;
        property MsgTypeAsStr : string read MessageTypeToStr write MessageTypeFromStr;
        property ControlInput : boolean read Get_ControlInput write Set_ControlInput;
     published
        property MessageType : TxPLMessageType   read fMsgType write Set_MessageType;
        property hop         : integer           read fHop     write Set_Hop;
        property source      : TxPLAddress       read fSource  write Set_Source;
        property target      : TxPLTargetAddress read fTarget  write Set_Target;
        property schema      : TxPLSchema        read fSchema  write Set_Schema;
     end;

implementation //==============================================================
uses SysUtils
     , typinfo
     , StrUtils
     ;

// ============================================================================
const K_FMT_FILTER        = '%s.%s.%s';

// TxPLHeader Object ==========================================================
constructor TxPLHeader.Create(aOwner: TComponent; const aFilter: string = '');
begin
   inherited Create(aOwner);
   include(fComponentStyle,csSubComponent);

   if aFilter <> '' then with TStringList.Create do try
      Delimiter := '.';
      StrictDelimiter := True;
      DelimitedText := aFilter;                                             // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
      fSource := TxPLAddress.Create(Strings[1],Strings[2],Strings[3]);  // Creates source and target with the same informations
      fTarget := TxPLTargetAddress.Create(fSource);
      MsgTypeAsStr := Strings[0];
      fSchema := TxPLSchema.Create(Strings[4],Strings[5]);
      finally
         Free;
   end else begin
      fSource := TxPLAddress.Create;
      fTarget := TxPLTargetAddress.Create;
      fSchema := TxPLSchema.Create;
      ResetValues;
   end;
end;

destructor TxPLHeader.destroy;
begin
   Source.Free;
   Target.Free;
   Schema.Free;
   inherited;
end;

procedure TxPLHeader.Assign(aHeader : TPersistent);
begin
   if aHeader is TxPLHeader then begin
      fSource.Assign(TxPLHeader(aHeader).Source);
      fTarget.Assign(TxPLHeader(aHeader).Target);
      fSchema.Assign(TxPLHeader(aHeader).Schema);
      fMsgType := TxPLHeader(aHeader).MessageType;
      fHop     := TxPLHeader(aHeader).Hop;
   end else inherited;
end;

procedure TxPLHeader.ResetValues;
begin
   Source.ResetValues;
   Target.ResetValues;
   Schema.ResetValues;
   fMsgType := cmnd;
   fHop     := 1;
end;

procedure TxPLHeader.Reply;
begin
   with TxPLTargetAddress.Create(Source) do try
        Source.Assign(Target);
        Target.RawxPL:=RawxPL;
   finally
        Free;
   end;
   MessageType := stat;
end;

function TxPLHeader.MatchesFilter(aFilterSet: TStringList): boolean;
var filter : string;
begin
   result := (aFilterSet.Count = 0);
   if not result then                                                           // if filters are present
      for filter in aFilterSet do                                               // check if at least one matches
          result := result or xPLMatches(filter, SourceFilter);
end;

function TxPLHeader.IsValid: boolean;
begin
   result := Source.IsValid and
             Target.IsValid and
             Schema.IsValid and
             (ord(MessageType)>=0);
end;

function TxPLHeader.Get_RawxPL: string;
begin
   Result := Format( K_MSG_HEADER_FORMAT,
                     [ MsgTypeAsStr, Hop, Source.RawxPL, Target.RawxPL, Schema.RawxPL ]);
end;

function TxPLHeader.Get_ControlInput: boolean;
begin
   result := Source.ControlInput;
end;

procedure TxPLHeader.Set_ControlInput(const AValue: boolean);
begin
   Source.ControlInput := aValue;
   Target.ControlInput := aValue;
   Schema.ControlInput := aValue;
end;

procedure TxPLHeader.Set_Hop(const AValue: integer);
begin                                                                           // Rule of xPL  : hop is <= 9
   if (aValue in [1..9]) then fHop := aValue;
end;

procedure TxPLHeader.Set_MessageType(const AValue: TxPLMessageType);
begin
   if MessageType <> aValue then begin
      if aValue = stat then Target.IsGeneric := True;                           // Rule of xPL : xpl-stat are always broadcast
      fMsgType := aValue;
   end;
end;

procedure TxPLHeader.Set_Schema(const AValue: TxPLSchema);
begin
   fSchema.Assign(aValue);
end;

procedure TxPLHeader.Set_Source(const AValue: TxPLAddress);
begin
   fSource.Assign(aValue);
end;

procedure TxPLHeader.Set_Target(const AValue: TxPLTargetAddress);
begin
   fTarget.Assign(aValue);
end;

procedure TxPLHeader.Set_RawXpl(const aRawXPL : string);
begin
   ResetValues;

   with TStringList.Create do try
        DelimitedText:= AnsiReplaceText(AnsiLowerCase(aRawxPL),#10'}'#10,#10'schema=');
        if Count >= 5 then begin                                                // The message header contains at least enough fields
           MsgTypeAsStr := Strings[0];
           fHop := StrToInt(Values['hop']);
           fSource.RawxPL := Values['source'];
           fTarget.RawxPL := Values['target'];
           fSchema.RawxPL := Values['schema'];
        end;
   finally
        free;
   end;
end;

function TxPLHeader.SourceFilter : string;  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
begin
   result := Format(K_FMT_FILTER,[MsgTypeAsStr,Source.AsFilter,Schema.AsFilter]);
end;

function TxPLHeader.TargetFilter : string;  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
begin
   result := Format(K_FMT_FILTER,[MsgTypeAsStr,Target.AsFilter,Schema.AsFilter]);
end;

function TxPLHeader.HeaderFilter: string;
begin
   result := Format('%s.%s.%s.%s',[MsgTypeAsStr,Source.AsFilter,Target.AsFilter,Schema.AsFilter]);
end;

procedure TxPLHeader.MessageTypeFromStr(const aString: string);
var s : string;
begin
   s := AnsiRightStr(aString, length(aString) - 4);                             // Removes 'xpl-'
   MessageType := TxPLMessageType(GetEnumValue(TypeInfo(TxPLMessageType), s));
end;

function TxPLHeader.MessageTypeToStr: string;
begin
   if MessageType<>any then
      result := 'xpl-' + GetEnumName(TypeInfo(TxPLMessageType),Ord(MessageType))
   else result := '*';
end;

initialization // =============================================================
   Classes.RegisterClass(TxPLHeader);

end.