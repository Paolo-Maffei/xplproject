unit u_xpl_filter_message;
{==============================================================================
  UnitDesc      = xPL Message management object and function
                  This unit implement strictly conform to specification message
                  structure
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.95 : First Release
 1.0  : Now descendant of TxPLHeader
 }

{$ifdef fpc}
{$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses classes
     , u_xpl_body
     , u_xpl_schema
     , u_xpl_common
     , u_xpl_filter_header
     ;

type { TxPLCustomMessage =====================================================}
     TxPLFilterMessage = class(TxPLFilterHeader, IxPLCommon, IxPLRaw)
     private
        fBody      : TxPLBody;
        function  Get_RawXPL: string;
        procedure Set_RawXPL(const AValue: string);

     public
        constructor Create(const aOwner : TComponent; const aRawxPL : string = ''); reintroduce;

        procedure   Assign(aMessage : TPersistent); override;
        procedure   ResetValues; override;
        function    IsValid      : boolean; override;

     published
        property Body   : TxPLBody read fBody  ;
        property RawXPL : string   read Get_RawXPL  write Set_RawXPL stored false;
     end;

implementation // =============================================================
Uses SysUtils
     , StrUtils
     ;

// TxPLFilterMessage ==========================================================
constructor TxPLFilterMessage.Create(const aOwner : TComponent; const aRawxPL : string = '');
begin
   inherited Create(aOwner);

   fBody := TxPLBody.Create(self);

   if aRawxPL<>'' then RawXPL := aRawXPL;
end;

procedure TxPLFilterMessage.ResetValues;
begin
   inherited;
   if Assigned(Body) then Body.ResetValues;
end;

procedure TxPLFilterMessage.Assign(aMessage: TPersistent);
begin
   if aMessage is TxPLFilterMessage then begin
      fBody.Assign(TxPLFilterMessage(aMessage).Body);                          // Let me do specific part
      inherited Assign(aMessage);
   end else inherited;
end;

function TxPLFilterMessage.Get_RawXPL: string;
begin
   result := inherited RawxPL + Body.RawxPL;
end;

function TxPLFilterMessage.IsValid: boolean;
begin
   result := (inherited IsValid) and (Body.IsValid);
end;

procedure TxPLFilterMessage.Set_RawXPL(const AValue: string);
var LeMessage : string;
    HeadEnd, BodyStart, BodyEnd : integer;
begin
   LeMessage        := AnsiReplaceText(aValue,#13,'');                         // Delete all CR
   HeadEnd          := AnsiPos('}',LeMessage);
   BodyStart        := Succ(PosEx('{',LeMessage,HeadEnd));
   BodyEnd          := LastDelimiter('}',LeMessage);
   inherited RawxPL := AnsiLeftStr(LeMessage,BodyStart-2);
   Body.RawxPL      := Copy(LeMessage,BodyStart,BodyEnd-BodyStart);
end;

initialization // =============================================================
   Classes.RegisterClass(TxPLFilterMessage);

end.
