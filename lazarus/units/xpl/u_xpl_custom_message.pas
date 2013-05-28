unit u_xpl_custom_message;
{==============================================================================
  UnitDesc      = xPL Message management object and function
                  This unit implement strictly conform to specification message
                  structure
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.95 : First Release
 1.0  : Now descendant of TxPLHeader
 1.5  : Added fControlInput property to override read/write controls needed for OPC
 }

{$ifdef fpc}
{$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses classes
     , u_xpl_body
     , u_xpl_schema
     , u_xpl_common
     , u_xpl_header
     ;

type { TxPLCustomMessage =====================================================}
     TxPLCustomMessage = class(TxPLHeader, IxPLCommon, IxPLRaw)
     private
        fBody      : TxPLBody;
        fTimeStamp : TDateTime;
        function  Get_RawXPL: string;
        function  Get_Size: integer;
        procedure Set_RawXPL(const AValue: string);
     protected
        procedure Set_ControlInput(const AValue: boolean); override;
     public
        constructor Create(const aOwner : TComponent; const aRawxPL : string = ''); reintroduce;

        procedure   Assign(aMessage : TPersistent); override;
        procedure   AssignHeader(aMessage : TxPLCustomMessage);
        procedure   ResetValues; //override;
        function    IsLifeSign   : boolean; inline;
        function    IsValid      : boolean; override;
        function    MustFragment : boolean;

        procedure LoadFromFile(const aFileName : string);
        procedure SaveToFile(const aFileName : string);
     published
        property Body   : TxPLBody read fBody  ;
        property RawXPL : string   read Get_RawXPL  write Set_RawXPL stored false;
        property TimeStamp : TDateTime read fTimeStamp write fTimeStamp;
        property Size   : integer  read Get_Size;
     end;
     PxPLCustomMessage = ^TxPLCustomMessage;

implementation // =============================================================
Uses SysUtils
     , StrUtils
     ;

// TxPLCustomMessage ==========================================================
constructor TxPLCustomMessage.Create(const aOwner : TComponent; const aRawxPL : string = '');
begin
   inherited Create(aOwner);

   fBody := TxPLBody.Create(self);
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
             ( Schema.IsConfig or Schema.IsHBeat ) and
             ( Schema.Type_ = 'app' );
end;

procedure TxPLCustomMessage.Assign(aMessage: TPersistent);
begin
   if aMessage is TxPLCustomMessage then begin
      fBody.Assign(TxPLCustomMessage(aMessage).Body);                          // Let me do specific part
      AssignHeader(TxPLCustomMessage(aMessage));
   end else inherited;
end;

procedure TxPLCustomMessage.AssignHeader(aMessage: TxPLCustomMessage);
begin
   fTimeStamp := aMessage.TimeStamp;
   inherited Assign(aMessage);
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
   LeMessage        := AnsiReplaceText(aValue,#13,'');                         // Delete all CR
   HeadEnd          := AnsiPos(#10'}',LeMessage) + 1;
   BodyStart        := Succ(PosEx('{'#10,LeMessage,HeadEnd));
   BodyEnd          := LastDelimiter('}',LeMessage);
   inherited RawxPL := AnsiLeftStr(LeMessage,BodyStart-2);
   Body.RawxPL      := Copy(LeMessage,BodyStart,BodyEnd-BodyStart);
end;

procedure TxPLCustomMessage.Set_ControlInput(const AValue: boolean);
begin
   inherited Set_ControlInput(AValue);
   Body.ControlInput := aValue;
end;

procedure TxPLCustomMessage.SaveToFile(const aFileName: string);
begin
   StreamObjectToFile(aFileName, self);
end;

procedure TxPLCustomMessage.LoadFromFile(const aFileName: string);
begin
   ReadObjectFromFile(aFileName, self);
end;

initialization // =============================================================
   Classes.RegisterClass(TxPLCustomMessage);

end.