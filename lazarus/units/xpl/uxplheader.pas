unit uxPLHeader;
{==============================================================================
  UnitName      = uxPLHeader
  UnitDesc      = xPL Message Header management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.96 : Rawdata passed are no longer transformed to lower case, then Header has
        to lower it
 0.97 : Added Assign method
 0.98 : String constants removed to uxPLConst
 0.99 : Added usage of uRegExTools
        Simplification of the class fMsgType became of type tsMsgType (string)
        avoiding multiple tanstyping
        Renamed the class from TxPLMsgHeader to TxPLHeader
 1.00 : Suppressed usage of uRegExTools to correct bug #FS47
 1.1    Switched schema from Body to Header
        optimizations in SetRawxPL to avoid inutile loops
 }
{$mode objfpc}{$H+}

interface

uses uxPLAddress,
     uxPLConst,
     uxPLSchema;

type { TxPLHeader }

     TxPLHeader = class
     private
       fSource  : TxPLAddress;
       fTarget  : TxPLTargetAddress;
       fSchema  : TxPLSchema;
       fMsgType : tsMsgType;
       fHop     : integer;

       function  GetRawxPL : string;
       procedure SetRawxPL(const aRawXPL : string);
       procedure SetMessageType(const AValue: tsMsgType);
     public
       property MessageType : tsMsgType         read fMsgType  write SetMessageType;
       property Source      : TxPLAddress       read fSource   write fSource;
       property Target      : TxPLTargetAddress read fTarget;
       property Hop         : integer           read fHop      write fHop;
       property RawxPL      : string            read GetRawxPL write SetRawxPL;
       property Schema      : TxPLSchema        read fSchema;
       constructor Create;
       destructor  destroy; override;
       procedure Assign(const aHeader : TxPLHeader); overload;

       procedure ResetValues;

       function IsValid : boolean;
//       procedure ReadFromTable(const id : integer; const tbHeader : string);
(*       procedure WriteToXML (const aAction : TXMLxplActionType);
       procedure ReadFromXML(const aAction : TXMLxplActionType); overload;
       procedure ReadFromXML(const aCom : TXMLCommandType); overload;*)

       class function MsgTypeAsOrdinal(const aMsgType : tsMsgType) : integer;
     end;


implementation {=========================================================================}
uses SysUtils,
     Classes,
     uRegExpr,
     StrUtils;

{ TxPLHeader Object =====================================================================}
constructor TxPLHeader.create;
begin
   fSource := TxPLAddress.Create;
   fTarget := TxPLTargetAddress.Create;
   fSchema := TxPLSchema.Create;
   ResetValues;
end;

destructor TxPLHeader.destroy;
begin
   Source.Destroy;
   Target.Destroy;
   Schema.Destroy;
end;

procedure TxPLHeader.Assign(const aHeader: TxPLHeader);
begin
   Source.Assign(aHeader.Source);
   Target.Assign(aHeader.Target);
   Schema.Assign(aHeader.Schema);
   MessageType := aHeader.MessageType;
   Hop         := aHeader.Hop;
end;

procedure TxPLHeader.ResetValues;
begin
   Source.ResetValues;
   Target.ResetValues;
   Schema.ResetValues;
   fMsgType := K_MSG_TYPE_CMND;
   fHop     := 1;
end;

function TxPLHeader.IsValid: boolean;                                           // This test is by design not
begin                                                                           // targetted to test Source.RawxPL
   result := TxPLTargetAddress.IsValid(Target.RawxPL) and                       // because this field will always be filled
             TxPLSchema.IsValid(Schema.RawxPL) and                              // by the xPLClient of the application
             (MsgTypeAsOrdinal(MessageType) <> -1);
end;

(*procedure TxPLHeader.ReadFromXML(const aAction : TXMLxplActionType);
begin
   MessageType   := aAction.Msg_Type;
   Target.RawxPL := aAction.Msg_Target;
   Source.RawxPL := aAction.Msg_Source;
   Schema.RawxPL := aAction.Msg_Schema;
end;

procedure TxPLHeader.ReadFromXML(const aCom: TXMLCommandType);
begin
   MessageType   := K_MSG_TYPE_HEAD + aCom.msg_type;
   Target.RawxPL := K_MSG_TARGET_ANY;
   Schema.RawxPL := aCom.msg_schema;
end;*)

class function TxPLHeader.MsgTypeAsOrdinal(const aMsgType: tsMsgType): integer;
begin
   Result := AnsiIndexStr(aMsgType,[K_MSG_TYPE_TRIG,K_MSG_TYPE_STAT,K_MSG_TYPE_CMND]);
end;

(*procedure TxPLHeader.WriteToXML(const aAction : TXMLxplActionType);
begin
   aAction.Msg_Type   := MessageType;
   aAction.Msg_Target := Target.RawxPL;
   aAction.Msg_Source := Source.RawxPL;
   aAction.Msg_Schema := Schema.RawxPL;
end;*)

function TxPLHeader.GetRawxPL: string;
begin
   Result := IfThen( IsValid ,
                     Format(K_MSG_HEADER_FORMAT,[MessageType,Hop,Source.RawxPL,Target.RawxPL,Schema.RawxPL]));
end;

procedure TxPLHeader.SetMessageType(const AValue: tsMsgType);
begin
   if MessageType = aValue then exit;
   if aValue = K_MSG_TYPE_STAT then Target.IsGeneric := True;                   // Rule of XPL : xpl-stat are always broadcast
   fMsgType := aValue;
end;

procedure TxPLHeader.SetRawXpl(const aRawXPL : string);
var i : integer;
begin
   ResetValues;
   with TRegExpr.Create do try
        Expression := K_RE_HEADER_FORMAT;
        if Exec(AnsiLowerCase(aRawXPL)) then begin
           MessageType := Match[1];
           i := 3;
           while i<=7 do begin
              Case AnsiIndexStr(Match[i],[K_MSG_HEADER_HOP,K_MSG_HEADER_SOURCE,K_MSG_HEADER_TARGET]) of
                   0 : fHop := StrToInt(Match[i+1]);
                   1 : Source.RawxPL := Match[i+1];
                   2 : Target.RawxPL := Match[i+1];
              end;
              i += 2;
           end;
           Schema.RawxPL := Match[9];
        end;
   finally Destroy;
   end;
end;

end.

