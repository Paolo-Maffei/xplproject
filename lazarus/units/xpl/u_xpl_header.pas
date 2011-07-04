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
 }

{$ifdef fpc}
{$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses Classes,
     u_xpl_address,
     u_xpl_schema,
     u_xpl_common,
     u_xpl_config;

type TxPLHeader = class(TComponent, IxPLCommon, IxPLRaw)
     private
       fSource  : TxPLAddress;
       fTarget  : TxPLTargetAddress;
       fSchema  : TxPLSchema;
       fMsgType : TxPLMessageType;
       fHop     : integer;

       function  Get_RawxPL : string;
       procedure Set_Hop(const AValue: integer);
       procedure Set_RawxPL(const aRawXPL : string);
       procedure Set_MessageType(const AValue: TxPLMessageType);
       procedure Set_Schema(const AValue: TxPLSchema);
       procedure Set_Source(const AValue: TxPLAddress);
       procedure Set_Target(const AValue: TxPLTargetAddress);
     public
       constructor Create(aOwner : TComponent); overload;
       constructor Create(aOwner : TComponent; const aFilter : string); overload; // Creates a header based on a filter string
       destructor  destroy; override;

       procedure   Assign(aHeader : TPersistent); override;
       function    IsValid : boolean;
       procedure   ResetValues;

       procedure   Reply;
       function    MatchesFilter(aFilterSet : TxPLConfigItem) : boolean;
       function    SourceFilter : string;                                       // Returns a message like a filter string
       function    TargetFilter : string;

       property    RawxPL      : string         read Get_RawxPL write Set_RawxPL;

     published
       property MessageType : TxPLMessageType   read fMsgType   write Set_MessageType;
       property hop         : integer           read fHop       write Set_Hop;
       property source      : TxPLAddress       read fSource    write Set_Source;
       property target      : TxPLTargetAddress read fTarget    write Set_Target;
       property schema      : TxPLSchema        read fSchema    write Set_Schema;
     end;

const K_MSG_HEADER_FORMAT = '%s'#10'{'#10'hop=%u'#10'source=%s'#10'target=%s'#10'}'#10'%s'#10;

implementation //==============================================================
uses SysUtils
     , typinfo
     , uRegExpr
     , StrUtils
     ;

// ============================================================================
const K_RE_HEADER_FORMAT  = '(xpl-(stat|cmnd|trig)).+[{\n](.+)[=](.+)[\n](.+)[=](.+)[\n](.+)[=](.+)[\n][}][\n](.+)';
      K_MSG_HEADER_HOP    = 'hop';
      K_MSG_HEADER_SOURCE = 'source';
      K_MSG_HEADER_TARGET = 'target';
      K_FMT_FILTER        = '%s.%s.%s';

// TxPLHeader Object ==========================================================
constructor TxPLHeader.create(aOwner : TComponent);
begin
   inherited;
   include(fComponentStyle,csSubComponent);

   fSource := TxPLAddress.Create;
   fTarget := TxPLTargetAddress.Create;
   fSchema := TxPLSchema.Create;

   ResetValues;
end;

constructor TxPLHeader.Create(aOwner: TComponent; const aFilter: string);
var  sFlt : TStringList;
begin
   inherited Create(aOwner);

   sFlt := TStringList.Create;
   try
      sFlt.Delimiter := '.';
      sFlt.StrictDelimiter := True;
      sFlt.DelimitedText := aFilter;                                             // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
      fSource := TxPLAddress.Create(sFlt[1],sFlt[2],sFlt[3]);                    // Creates source and target with the same informations
      fTarget := TxPLTargetAddress.Create(fSource);
      MessageType := StrToMsgType(sFlt[0]);
      fSchema := TxPLSchema.Create(sFlt[4],sFlt[5]);
   finally
     sFlt.Free;
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

function TxPLHeader.MatchesFilter(aFilterSet: TxPLConfigItem): boolean;
var i : integer;
begin
   result := (aFilterSet.ValueCount=0);                                         // If no filter present then always pass
   if not result then                                                           // if filters are present
      for i:= 0 to aFilterSet.ValueCount-1 do                                   // check if at least one matches
          result := result or xPLMatches(aFilterSet.ValueAtId(i), SourceFilter);
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
   if IsValid
      then Result := Format( K_MSG_HEADER_FORMAT,
                             [ MsgTypeToStr(MessageType),
                               Hop,
                               Source.RawxPL,
                               Target.RawxPL,
                               Schema.RawxPL ]
                     );
end;

procedure TxPLHeader.Set_Hop(const AValue: integer);
begin                                                                           // Rule of xPL  : hop is <= 9
   if (aValue>=1) and (aValue<=9) then fHop := aValue;
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
var i : integer;
begin
   ResetValues;
   with TRegExpr.Create do try
        Expression := K_RE_HEADER_FORMAT;
        if Exec(AnsiLowerCase(aRawXPL)) then begin
           MessageType := StrToMsgType(Match[1]);
           i := 3;
           while i<=7 do begin
              Case AnsiIndexStr(Match[i],[K_MSG_HEADER_HOP,K_MSG_HEADER_SOURCE,K_MSG_HEADER_TARGET]) of
                   0 : fHop := StrToInt(Match[i+1]);
                   1 : Source.RawxPL := Match[i+1];
                   2 : Target.RawxPL := Match[i+1];
              end;
              inc(i,2);
           end;
           Schema.RawxPL := Match[9];
        end;
   finally Destroy;
   end;
end;

function TxPLHeader.SourceFilter : string;  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
begin
   result := Format(K_FMT_FILTER,[MsgTypeToStr(MessageType),Source.AsFilter,Schema.AsFilter]);
end;

function TxPLHeader.TargetFilter : string;  // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
begin
   result := Format(K_FMT_FILTER,[MsgTypeToStr(MessageType),Target.AsFilter,Schema.AsFilter]);
end;

initialization
   Classes.RegisterClass(TxPLHeader);

end.
