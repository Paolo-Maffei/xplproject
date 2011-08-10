unit u_xpl_custom_message;
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
     , u_xpl_header
     , u_xpl_address
     , u_xpl_body
     , u_xpl_schema
     , u_xpl_common
     ;

type { TxPLCustomMessage =====================================================}
     TxPLCustomMessage = class(TxPLHeader, IxPLCommon, IxPLRaw)
     private
        fBody      : TxPLBody;
        fTimeStamp : TDateTime;
        function  Get_RawXPL: string;
        function  Get_Size: integer;
        procedure Set_RawXPL(const AValue: string);

     public
        constructor Create(aOwner : TComponent; const aRawxPL : string = ''); reintroduce;

        procedure   Assign(aMessage : TPersistent); override;
        procedure   ResetValues;
        function    IsLifeSign   : boolean; inline;
        function    IsValid      : boolean; override;
        function    MustFragment : boolean;

     published
        property Body   : TxPLBody read fBody  ;
        property RawXPL : string   read Get_RawXPL  write Set_RawXPL stored false;
        property TimeStamp : TDateTime read fTimeStamp write fTimeStamp;
        property Size   : integer  read Get_Size;
     end;

implementation // =============================================================
Uses SysUtils
     , StrUtils
     , u_xpl_udp_socket
     ;

// TxPLCustomMessage ==========================================================
constructor TxPLCustomMessage.Create(aOwner : TComponent; const aRawxPL : string = '');
begin
   inherited Create(aOwner);

   fBody   := TxPLBody.Create(self);
   fTimeStamp := now;

   if aRawxPL<>'' then RawXPL := aRawXPL;
end;

procedure TxPLCustomMessage.ResetValues;
begin
   inherited;
   Body.ResetValues;
   TimeStamp := 0;
end;

function TxPLCustomMessage.IsLifeSign: boolean;
begin
   result := ( MessageType = stat) and
             ( Schema.IsConfig or Schema.IsHBeat )
end;

procedure TxPLCustomMessage.Assign(aMessage: TPersistent);
begin
   if aMessage is TxPLCustomMessage then begin
      fBody.Assign(TxPLCustomMessage(aMessage).Body);                          // Let me do specific part
      fTimeStamp := TxPLCustomMessage(aMessage).TimeStamp;
   end;
   inherited;                                                                  // and ancestor do the rest
end;

function TxPLCustomMessage.Get_RawXPL: string;
begin
   result := inherited RawxPL + Body.RawxPL;
end;

function TxPLCustomMessage.Get_Size: integer;
begin
   result := length(RawxPL);
end;

function TxPLCustomMessage.IsValid: boolean;
begin
   result := (inherited IsValid) and (Body.IsValid);
end;

function TxPLCustomMessage.MustFragment: boolean;
begin
   result := (Size > XPL_MAX_MSG_SIZE);
end;

procedure TxPLCustomMessage.Set_RawXPL(const AValue: string);
var LeMessage : string;
    HeadEnd, BodyStart, BodyEnd : integer;
begin
   LeMessage        := AnsiReplaceText(aValue,#13,'');                            // Delete all CR
   HeadEnd          := AnsiPos('}',LeMessage);
   BodyStart        := Succ(PosEx('{',LeMessage,HeadEnd));
   BodyEnd          := LastDelimiter('}',LeMessage);
   inherited RawxPL := AnsiLeftStr(LeMessage,BodyStart-2);
   Body.RawxPL      := Copy(LeMessage,BodyStart,BodyEnd-BodyStart);
end;


initialization // =============================================================
   Classes.RegisterClass(TxPLCustomMessage);

end.
