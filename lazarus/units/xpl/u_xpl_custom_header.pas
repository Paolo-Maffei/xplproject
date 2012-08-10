unit u_xPL_Custom_Header;
{==============================================================================
  UnitName      = uxPLCustomHeader
  UnitDesc      = Abstract class common to filter header and message header
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
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

type

{ TxPLCustomHeader }

 TxPLCustomHeader = class(TComponent, IxPLCommon, IxPLRaw)
     protected
        fSource  : TxPLAddress;
        fTarget  : TxPLTargetAddress;
        fSchema  : TxPLSchema;
        fMsgType : TxPLMessageType;
        fHop     : integer;

        procedure Set_Schema(const AValue: TxPLSchema);
        procedure Set_Source(const AValue: TxPLAddress);
        procedure Set_Target(const AValue: TxPLTargetAddress);
        procedure Set_RawxPL(const aRawXPL : string);
        procedure Set_MessageType(const AValue: TxPLMessageType); dynamic;

        function Get_RawxPL: string; virtual; abstract;
        procedure MessageTypeFromStr(const aString : string); dynamic;
        function MessageTypeToStr : string; dynamic;
        procedure AssignProps(const aHeader : TPersistent); virtual; abstract;

     public
        constructor Create(aOwner : TComponent; const aFilter : string = ''); reintroduce;
        destructor  Destroy; override;
        function    IsValid : boolean; dynamic;
        procedure   ResetValues; dynamic;
        procedure   Assign(aHeader : TPersistent); override;

        property RawxPL : string            read Get_RawxPL write Set_RawxPL;
        property MsgTypeAsStr : string read MessageTypeToStr write MessageTypeFromStr;
     published
        property MessageType : TxPLMessageType read fMsgType write Set_MessageType;
        property source : TxPLAddress       read fSource    write Set_Source;
        property target : TxPLTargetAddress read fTarget    write Set_Target;
        property schema : TxPLSchema        read fSchema    write Set_Schema;
     end;

implementation //==============================================================
uses SysUtils
     , typinfo
     , StrUtils
     ;

// TxPLCustomHeader  ==========================================================
constructor TxPLCustomHeader.Create(aOwner: TComponent; const aFilter: string = '');
begin
   inherited Create(aOwner);
   include(fComponentStyle,csSubComponent);

   if aFilter <> '' then
      with TStringList.Create do try
         Delimiter := '.';
         StrictDelimiter := True;
         DelimitedText := aFilter;                                             // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType
         fSource := TxPLAddress.Create(Strings[1],Strings[2],Strings[3]);            // Creates source and target with the same informations
         fTarget := TxPLTargetAddress.Create(fSource);
         MessageTypeFromStr(Strings[0]);
         fSchema := TxPLSchema.Create(Strings[4],Strings[5]);
      finally
         Free;
      end
   else begin
      fSource := TxPLAddress.Create;
      fTarget := TxPLTargetAddress.Create;
      fSchema := TxPLSchema.Create;
      ResetValues;
   end;
end;

destructor TxPLCustomHeader.destroy;
begin
   Source.Free;
   Target.Free;
   Schema.Free;
   inherited;
end;

procedure TxPLCustomHeader.MessageTypeFromStr(const aString: string);
var s : string;
begin
   s := AnsiRightStr(aString, length(aString) - 4);                             // Removes 'xpl-'
   MessageType := TxPLMessageType(GetEnumValue(TypeInfo(TxPLMessageType), s));
end;

function TxPLCustomHeader.MessageTypeToStr: string;
begin
   result := 'xpl-' + GetEnumName(TypeInfo(TxPLMessageType),Ord(MessageType));
end;

procedure TxPLCustomHeader.Set_Schema(const AValue: TxPLSchema);
begin
   fSchema.Assign(aValue);
end;

procedure TxPLCustomHeader.Set_Source(const AValue: TxPLAddress);
begin
   fSource.Assign(aValue);
end;

procedure TxPLCustomHeader.Set_Target(const AValue: TxPLTargetAddress);
begin
   fTarget.Assign(aValue);
end;

procedure TxPLCustomHeader.Set_RawXpl(const aRawXPL : string);
var i : integer;
    s : string;
begin
   ResetValues;

   with TStringList.Create do try
        DelimitedText:= AnsiReplaceText(AnsiLowerCase(aRawxPL),'}'#10,'schema=');
        MessageType := StrToMsgType(Strings[0]);
        fHop := StrToInt(Values['hop']);
        fSource.RawxPL := Values['source'];
        fTarget.RawxPL := Values['target'];
        fSchema.RawxPL := Values['schema'];     // => essayer SetStrProp
   finally
        free;
   end;
   with TStringList.Create do try
        s := AnsiLowerCase(aRawxPL);
        s := AnsiReplaceText(s,'xpl-','messagetype=');
        s := AnsiReplaceText(s,'}'#10,'schema=');
        DelimitedText := s;
//        DelimitedText:= AnsiReplaceText(AnsiLowerCase(aRawxPL),'}'#10,'schema=');
        for i:= 0 to Pred(Count) do begin
            s := names[i];
            if s<>'' then
               SetStrProp(self,Names[i],Values[Names[i]]);

        end;
//        MessageType := StrToMsgType(Strings[0]);
//        fHop := StrToInt(Values['hop']);
//        fSource.RawxPL := Values['source'];
//        fTarget.RawxPL := Values['target'];
//        fSchema.RawxPL := Values['schema'];     // => essayer SetStrProp
   finally
        free;
   end;
end;

function TxPLCustomHeader.IsValid: boolean;
begin
   result := Source.IsValid and
             Target.IsValid and
             Schema.IsValid and
             (ord(MessageType)>=0);
end;

procedure TxPLCustomHeader.ResetValues;
begin
   Source.ResetValues;
   Target.ResetValues;
   Schema.ResetValues;
   Ord(fMsgType) := 0;
end;

procedure TxPLCustomHeader.Assign(aHeader : TPersistent);
begin
   if aHeader is TxPLCustomHeader then begin
      fSource.Assign(TxPLCustomHeader(aHeader).Source);
      fTarget.Assign(TxPLCustomHeader(aHeader).Target);
      fSchema.Assign(TxPLCustomHeader(aHeader).Schema);
      AssignProps(aHeader);
   end else inherited;
end;

procedure TxPLCustomHeader.Set_MessageType(const AValue: TxPLMessageType);
begin
   if MessageType <> aValue then
      fMsgType := aValue;
end;


end.

