unit uxplmsgheader;
{==============================================================================
  UnitName      = uxplmsgheader
  UnitDesc      = xPL Message Header management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Added XMLWrite and Read Methods, Source and Target Addresses
 0.95 : Modified XML read and Write format to be closer to other vendors
 0.96 : Rawdata passed are no longer transformed to lower case, then Header has to lower it
 0.97 : Added Assign method
 0.98 : String constants removed to uxPLConst
 }
{$mode objfpc}{$H+}

interface

uses uxPLAddress, DOM, uxPLConst;

type { TxPLMsgHeader }

     TxPLMsgHeader = class
     private
       fSource  : TxPLAddress;
       fTarget  : TxPLTargetAddress;
       fMsgType : TxPLMessageType;
       fHop     : integer;

       function  GetRawxPL : string;
       procedure SetRawxPL(aRawXPL : string);

     public
       property MessageType : TxPLMessageType   read fMsgType  write fMsgType;
       property Source      : TxPLAddress       read fSource   write fSource;
       property Target      : TxPLTargetAddress read fTarget;
       property Hop         : integer           read fHop      write fHop;
       property RawxPL      : string            read GetRawxPL write SetRawxPL;

       constructor Create;
       destructor  destroy; override;
       procedure Assign(const aHeader : TxPLMsgHeader); overload;

       procedure ResetValues;

       function MessageTypeAsString : string;
       function IsValid : boolean;

       procedure WriteToXML(aParent : TDOMNode);
       procedure ReadFromXML(aParent : TDOMNode);

       class function MsgType2String(const aMsgType: TxPLMessageType): string;
       class function String2MsgType(const aCmnd: string): TxPLMessageType;
     end;


implementation {===============================================================}
uses SysUtils, Classes, RegExpr;

const K_MESSAGE_TYPE_DESCRIPTORS : Array[0..3] of string = ( K_MSG_TYPE_TRIG,K_MSG_TYPE_STAT,K_MSG_TYPE_CMND,K_MSG_TYPE_ANY);

{ General Helper function =====================================================}
class function TxPLMsgHeader.String2MsgType(const aCmnd: string): TxPLMessageType;
var i : TxPLMessageType;
begin
     result := xpl_mtNone;
     for i:= xpl_mtTrig to xpl_mtAny do                                         // There's no descriptor for mtNone
         if AnsiPos(aCmnd,K_MESSAGE_TYPE_DESCRIPTORS[Ord(i)])<>0 then result := i;
end;

class function TxPLMsgHeader.MsgType2String(const aMsgType: TxPLMessageType): string;
begin 
     result := K_MESSAGE_TYPE_DESCRIPTORS[Ord(aMsgType)];
end;

{ TxPLMsgHeader Object ======================================================}

constructor TxPLMsgHeader.create;
begin
  fSource := TxPLAddress.Create;
  fTarget := TxPLTargetAddress.Create;

  ResetValues;
end;

destructor TxPLMsgHeader.destroy;
begin
  Source.Destroy;
  Target.Destroy;
end;

procedure TxPLMsgHeader.Assign(const aHeader: TxPLMsgHeader);
begin
     Source.Assign(aHeader.Source);
     Target.Assign(aHeader.Target);
     MessageType := aHeader.MessageType;
     Hop := aHeader.Hop;
end;

procedure TxPLMsgHeader.ResetValues;
begin
  Source.ResetValues;
  Target.ResetValues;

  fMsgType := xpl_mtCmnd;
  fHop := 1;
end;

function TxPLMsgHeader.MessageTypeAsString : string;
begin
   result := K_MESSAGE_TYPE_DESCRIPTORS[Ord(fMsgType)];
end;

function TxPLMsgHeader.IsValid: boolean;
begin
     result := (
               Source.IsValid and
               Target.IsValid and
               ((MessageType = xpl_mtTrig) or (MessageType = xpl_mtStat) or (MessageType = xpl_mtCmnd))
            )
end;

procedure TxPLMsgHeader.ReadFromXML(aParent : TDOMNode);
begin
     MessageType := String2MsgType(TDOMElement(aParent).GetAttribute('msg_type'));
     fSource.ReadFromXML(aParent);
     fTarget.ReadFromXML(aParent);
end;

procedure TxPLMsgHeader.WriteToXML(aParent : TDOMNode);
begin
     TDOMElement(aParent).SetAttribute('msg_type',MessageTypeAsString);
     fSource.WriteToXML(aParent);
     fTarget.WriteToXML(aParent);
end;

function TxPLMsgHeader.GetRawxPL: string;
begin
     If IsValid
        then result := Format(K_MSG_HEADER_FORMAT,[MessageTypeAsString,Hop,Source.Tag,Target.Tag])
        else result := '';
end;

procedure TxPLMsgHeader.SetRawXpl(aRawXPL : string);
var i : integer;
begin
     ResetValues;
     with TRegExpr.Create do try
          Expression := K_RE_HEADER_FORMAT;
          if Exec(AnsiLowerCase(aRawXPL)) then begin
             MessageType := String2MsgType(Match[1]);
             for i:= 3 to 7 do begin
                 if Match[i] = K_MSG_HEADER_HOP    then fHop := StrToInt(Match[i+1]);
                 if Match[i] = K_MSG_HEADER_SOURCE then Source.Tag := Match[i+1];
                 if Match[i] = K_MSG_HEADER_TARGET then Target.Tag := Match[i+1];
             end;
          end;   
          finally free;
     end;
end;

end.

