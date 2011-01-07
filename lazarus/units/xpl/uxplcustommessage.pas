unit uxplcustommessage;
{==============================================================================
  UnitName      = uxplcustommessage
  UnitDesc      = xPL Message management object and function
                  This unit implement strictly conform to specification message
                  structure
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.95 : First Release
 }
{$mode objfpc}{$H+}

interface

uses classes,
     uxPLHeader,
     uxPLAddress,
     uxPLMsgBody,
     uxPLSchema;

type

     { TxPLCustomMessage }

     TxPLCustomMessage = class
     private
        fHeader       : TxPLHeader;
        fBody         : TxPLBody;

        function  GetRawXPL: string;
        procedure SetRawXPL(const AValue: string);
     public
        property Header       : TxPLHeader        read fHeader;
        property Body         : TxPLBody          read fBody;
        property RawXPL       : string            read GetRawXPL        write SetRawXPL        ;
        property MessageType  : string            read fHeader.fMsgType write fHeader.fMsgType ;
        property Source       : TxPLAddress       read fHeader.fSource  write fHeader.fSource  ;
        property Target       : TxPLTargetAddress read fHeader.fTarget  write fHeader.fTarget  ;
        property Schema       : TxPLSchema        read fHeader.fSchema  write fHeader.fSchema  ;

        procedure ResetValues;

        constructor create(const aRawxPL : string = ''); overload;
        destructor  Destroy; override;
        procedure   Assign(const aMessage : TxPLCustomMessage); overload;

        function IsValid : boolean;
     end;

implementation // =============================================================
Uses uxPLConst,
     uRegExpr,
     StrUtils;
(*Uses SysUtils,
     uRegExpr,
     cStrings,
     cUtils;*)

// TxPLCustomMessage =================================================================
constructor TxPLCustomMessage.Create(const aRawxPL : string = '');
begin
   fHeader := TxPLHeader.Create;
   fBody   := TxPLBody.Create;
   if aRawxPL<>'' then RawXPL := aRawXPL;
end;

procedure TxPLCustomMessage.ResetValues;
begin
   Header.ResetValues;
   Body.ResetValues;
end;

destructor TxPLCustomMessage.Destroy;
begin
   Header.Free;
   Body.Free;
end;

procedure TxPLCustomMessage.Assign(const aMessage: TxPLCustomMessage);
begin
  Header.Assign(aMessage.Header);
  Body.Assign(aMessage.Body);
end;

function TxPLCustomMessage.GetRawXPL: string;
begin
   result := Header.RawxPL + Body.RawxPL;
end;

function TxPLCustomMessage.IsValid: boolean;
begin
   result := (Header.IsValid) and (Body.IsValid)
end;

procedure TxPLCustomMessage.SetRawXPL(const AValue: string);
begin
   with TRegExpr.Create do try
      Expression := K_RE_MESSAGE;
//      if Exec (StrRemoveChar(aValue,#13)) then begin
      if Exec( AnsiReplaceStr(aValue,#13,'')) then begin

         Header.RawXPL := Match[1];
         Body.RawXPL   := Match[3];
      end;
      finally Free;
   end;
end;

end.
