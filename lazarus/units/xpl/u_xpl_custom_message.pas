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
{$mode objfpc}{$H+}{$M+}

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
        fBody     : TxPLBody;
        fTimeStamp: TDateTime;
        function  Get_RawXPL: string;
        procedure Set_RawXPL(const AValue: string);

     public
        constructor Create(aOwner : TComponent; const aRawxPL : string = ''); reintroduce;

        procedure   Assign(aMessage : TPersistent); override;
        function    IsValid : boolean;
        procedure   ResetValues;
        function    IsLifeSign : boolean; inline;

     published
        property Body   : TxPLBody read fBody  ;
        property RawXPL : string   read Get_RawXPL  write Set_RawXPL stored false;
        property TimeStamp : TDateTime read fTimeStamp write fTimeStamp;
     end;

implementation // =============================================================
Uses SysUtils
     , StrUtils
     , JclStrings
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
   result := (MessageType = stat) and (
               Schema.Equals(Schema_ConfigApp) or
               Schema.Equals(Schema_HBeatApp)  or
               Schema.Equals(Schema_HBeatEnd)
             )
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

function TxPLCustomMessage.IsValid: boolean;
begin
   result := (inherited IsValid) and (Body.IsValid)
end;

procedure TxPLCustomMessage.Set_RawXPL(const AValue: string);
var LeMessage : string;
    BodyStart : integer;
begin
   LeMessage     := StrRemoveChars(aValue,[NativeCarriageReturn]);             // Supprime les CR
   BodyStart     := StrLastPos('{',LeMessage) - 1;                             // Recherche la position du début du body
   inherited RawxPL := AnsiLeftStr (LeMessage,BodyStart-1);                    // Transmets la partie gauche en supprimant le dernier #10
   Body.RawxPL   := AnsiRightStr(LeMessage, Length(LeMessage) - BodyStart);    // Transmets la partie droite
end;

initialization
   Classes.RegisterClass(TxPLCustomMessage);

end.