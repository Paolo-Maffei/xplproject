unit uxPLHeader;
{==============================================================================
  UnitName      = uxPLHeader
  UnitDesc      = xPL Message Header management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Added XMLWrite and Read Methods, Source and Target Addresses
 0.95 : Modified XML read and Write format to be closer to other vendors
 0.96 : Rawdata passed are no longer transformed to lower case, then Header has
        to lower it
 0.97 : Added Assign method
 0.98 : String constants removed to uxPLConst
 0.99 : Added usage of uRegExTools
        Simplification of the class fMsgType became of type tsMsgType (string)
        avoiding multiple tanstyping
        Renamed the class from TxPLMsgHeader to TxPLHeader
 1.00 : Suppressed usage of uRegExTools to correct bug #FS47
 Rev 256 : Replaced string constants with u_xml string constants
         Switched local type of xml writing to use u_xml_xpldeterminator
 }
{$mode objfpc}{$H+}

interface

uses uxPLAddress,
     uxPLConst,
     u_xml_xpldeterminator;

type { TxPLHeader }

     TxPLHeader = class
     private
       fSource  : TxPLAddress;
       fTarget  : TxPLTargetAddress;
       fMsgType : tsMsgType;
       fHop     : integer;

       function  GetRawxPL : string;
       procedure SetRawxPL(aRawXPL : string);
       procedure SetMessageType(const AValue: tsMsgType);
     public
       property MessageType : tsMsgType         read fMsgType  write SetMessageType;
       property Source      : TxPLAddress       read fSource   write fSource;
       property Target      : TxPLTargetAddress read fTarget;
       property Hop         : integer           read fHop      write fHop;
       property RawxPL      : string            read GetRawxPL write SetRawxPL;

       constructor Create;
       destructor  destroy; override;
       procedure Assign(const aHeader : TxPLHeader); overload;

       procedure ResetValues;

       function IsValid : boolean;

       procedure WriteToXML(aAction : TXMLxplActionType);
       procedure ReadFromXML(aAction : TXMLxplActionType);

       class function MsgTypeAsOrdinal(const aMsgType : tsMsgType) : integer;
     end;


implementation {=========================================================================}
uses SysUtils, Classes, uRegExpr, StrUtils;

{ TxPLHeader Object =====================================================================}
constructor TxPLHeader.create;
begin
   fSource := TxPLAddress.Create;
   fTarget := TxPLTargetAddress.Create;

end;

destructor TxPLHeader.destroy;
begin
   Source.Destroy;
   Target.Destroy;
end;

procedure TxPLHeader.Assign(const aHeader: TxPLHeader);
begin
   Source.Assign(aHeader.Source);
   Target.Assign(aHeader.Target);
   MessageType := aHeader.MessageType;
   Hop := aHeader.Hop;
end;

procedure TxPLHeader.ResetValues;
begin
   Source.ResetValues;
   Target.ResetValues;

   fMsgType := K_MSG_TYPE_CMND;
   fHop := 1;
end;

function TxPLHeader.IsValid: boolean;
begin
   result := (
             Source.IsValid and
             Target.IsValid and
             (MsgTypeAsOrdinal(MessageType) <> -1)
            )
end;

procedure TxPLHeader.ReadFromXML(aAction : TXMLxplActionType);
var mt : string;
begin
   mt := aAction.Msg_Type;
   if not AnsiContainsStr(mt,K_MSG_TYPE_HEAD) then mt := K_MSG_TYPE_HEAD + mt;            // In vendor plugin file 'xpl-stat' is written 'stat'
   MessageType := mt;                                                                     // then keep same code for both origins
   Target.Tag  := aAction.Msg_Target;
   Source.Tag  := aAction.Msg_Source;
end;

class function TxPLHeader.MsgTypeAsOrdinal(const aMsgType: tsMsgType): integer;
begin
   Result := AnsiIndexStr(aMsgType,[K_MSG_TYPE_TRIG,K_MSG_TYPE_STAT,K_MSG_TYPE_CMND]);
end;

procedure TxPLHeader.WriteToXML(aAction : TXMLxplActionType);
begin
   aAction.Msg_Type:=MessageType;
   aAction.Msg_Target:=Target.Tag;
   aAction.Msg_Source:=Source.Tag;
end;

function TxPLHeader.GetRawxPL: string;
begin
   If IsValid
      then result := Format(K_MSG_HEADER_FORMAT,[MessageType,Hop,Source.Tag,Target.Tag])
      else result := '';
end;

procedure TxPLHeader.SetMessageType(const AValue: tsMsgType);
begin
   if MessageType = aValue then exit;
   if aValue = K_MSG_TYPE_STAT then Target.Tag := K_MSG_TARGET_ANY;                                // Rule of XPL : xpl-stat are always broadcast
   fMsgType := aValue;
end;

procedure TxPLHeader.SetRawXpl(aRawXPL : string);
var i : integer;
begin
   ResetValues;
   with TRegExpr.Create do try
        Expression := K_RE_HEADER_FORMAT;
        if Exec(AnsiLowerCase(aRawXPL)) then begin
           MessageType := Match[1];
           for i:= 3 to 7 do begin
               if Match[i] = K_MSG_HEADER_HOP    then fHop := StrToInt(Match[i+1]);
               if Match[i] = K_MSG_HEADER_SOURCE then Source.Tag := Match[i+1];
               if Match[i] = K_MSG_HEADER_TARGET then Target.Tag := Match[i+1];
           end;
        end;
   finally Destroy;
   end;
end;

end.

