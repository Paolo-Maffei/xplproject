(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX;

interface

Uses uxPLRFXConst, u_xPL_Message, uxPLRFXMessages,
     uxPLRFX_0x10,
     uxPLRFX_0x11,
     uxPLRFX_0x14,
     uxPLRFX_0x15,
     uxPLRFX_0x18,
     uxPLRFX_0x19,
     uxPLRFX_0x20,
     uxPLRFX_0x28,
     uxPLRFX_0x50,
     uxPLRFX_0x51,
     uxPLRFX_0x52,
     uxPLRFX_0x53,
     uxPLRFX_0x54,
     uxPLRFX_0x55,
     uxPLRFX_0x56,
     uxPLRFX_0x57,
     uxPLRFX_0x58,
     uxPLRFX_0x59,
     uxPLRFX_0x5A,
     uxPLRFX_0x5B,
     uxPLRFX_0x5D,
     uxPLRFX_0x70;

type
  TErrorEvent = procedure(ErrorMsg : String) of object;
  TLogEvent = procedure(LogMsg : String) of object;

  TxPLRFX = class
  private
  public
    OnError : TErrorEvent;
    OnRFXxPLLog : TLogEvent;
    OnxPLRFXLog : TLogEvent;
    constructor Create;
    destructor Destroy; override;
    function RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages) : String;
    procedure xPL2RFX(xPLMessage : TxPLMessage; var Buffer : BytesArray);
  end;

implementation

Uses SysUtils;

constructor TxPLRFX.Create;
begin
  inherited Create;
end;


function TxPLRFX.RFX2xPL(Buffer: BytesArray; xPLMessages : TxPLRFXMessages) : String;
var
  LogString : String;
begin
  LogString := '';
  case Buffer[1] of  // message type is in byte 2
    $10 : begin
            uxPLRFX_0x10.RFX2xPL(Buffer, xPLMessages);
            LogString := x10_DESCRIPTION;
          end;
    $11 : begin
            uxPLRFX_0x11.RFX2xPL(Buffer, xPLMessages);
            LogString := x11_DESCRIPTION;
          end;
    $12 : begin
            LogString := 'Not yet implemented';
          end;
    $13 : begin
            LogString := 'Not yet implemented';
          end;
    $14 : begin
            uxPLRFX_0x14.RFX2xPL(Buffer, xPLMessages);
            LogString := x14_DESCRIPTION;
          end;
    $15 : begin
            uxPLRFX_0x15.RFX2xPL(Buffer, xPLMessages);
            LogString := x15_DESCRIPTION;
          end;
    $19 : begin
            uxPLRFX_0x19.RFX2xPL(Buffer, xPLMessages);
            LogString := x19_DESCRIPTION;
          end;
    $20 : begin
            uxPLRFX_0x20.RFX2xPL(Buffer, xPLMessages);
            LogString := x20_DESCRIPTION;
          end;
    $28 : begin
            uxPLRFX_0x28.RFX2xPL(Buffer, xPLMessages);
            LogString := x28_DESCRIPTION;
          end;
    $30 : begin
            LogString := 'Not yet implemented';
          end;
    $50 : begin
            uxPLRFX_0x50.RFX2xPL(Buffer, xPLMessages);
            LogString := x50_DESCRIPTION;
          end;
    $51 : begin
            uxPLRFX_0x51.RFX2xPL(Buffer, xPLMessages);
            LogString := x51_DESCRIPTION;
          end;
    $52 : begin
            uxPLRFX_0x52.RFX2xPL(Buffer, xPLMessages);
            LogString := x52_DESCRIPTION;
          end;
    $53 : begin
            uxPLRFX_0x53.RFX2xPL(Buffer, xPLMessages);
            LogString := x53_DESCRIPTION;
          end;
    $54 : begin
            uxPLRFX_0x54.RFX2xPL(Buffer, xPLMessages);
            LogString := x54_DESCRIPTION;
          end;
    $55 : begin
            uxPLRFX_0x55.RFX2xPL(Buffer, xPLMessages);
            LogString := x55_DESCRIPTION;
          end;
    $56 : begin
            uxPLRFX_0x56.RFX2xPL(Buffer, xPLMessages);
            LogString := x56_DESCRIPTION;
          end;
    $57 : begin
            uxPLRFX_0x57.RFX2xPL(Buffer, xPLMessages);
            LogString := x57_DESCRIPTION;
          end;
    $58 : begin
            uxPLRFX_0x58.RFX2xPL(Buffer, xPLMessages);
            LogString := x58_DESCRIPTION;
          end;
    $59 : begin
            uxPLRFX_0x59.RFX2xPL(Buffer, xPLMessages);
            LogString := x59_DESCRIPTION;
          end;
    $5A : begin
            uxPLRFX_0x5A.RFX2xPL(Buffer, xPLMessages);
            LogString := x5A_DESCRIPTION;
          end;
    $5B : begin
            uxPLRFX_0x5B.RFX2xPL(Buffer, xPLMessages);
            LogString := x5B_DESCRIPTION;
          end;
    $5D : begin
            uxPLRFX_0x5D.RFX2xPL(Buffer, xPLMessages);
            LogString := x5D_DESCRIPTION;
          end;
    $70 : begin
            uxPLRFX_0x70.RFX2xPL(Buffer, xPLMessages);
            LogString := x70_DESCRIPTION;
          end;
    $71 : begin
            LogString := 'Not yet implemented';
          end;
    $72 : begin
            LogString := 'Not yet implemented';
          end
  else
    Raise Exception.Create('Unknown code');
  end;
  Result := LogString;
end;

procedure TxPLRFX.xPL2RFX(xPLMessage: TxPLMessage; var Buffer: BytesArray);
begin
  // Determine which hardware is addressed
  // 0x10 - Lighting1
  if (CompareText(xPLMessage.schema.RawxPL,'x10.basic') = 0) and
     ((xPLMessage.Body.Strings.IndexOfName('protocol') < 0) or
      (xPLMessage.Body.Strings.IndexOf('protocol=arc') > -1)) then
    uxPLRFX_0x10.xPL2RFX(xPLMessage,Buffer) else

  // 0x11 - Lighting2
  if (CompareText(xPLMessage.schema.RawxPL,'ac.basic') = 0) and
     ((xPLMessage.Body.Strings.IndexOfName('protocol') < 0) or
      (xPLMessage.Body.Strings.IndexOf('protocol=homeasyeu') > -1) or
      (xPLMessage.Body.Strings.IndexOf('protocol=anslut') > -1)) then
    uxPLRFX_0x11.xPL2RFX(xPLMessage, Buffer) else

  // 0x14 - Lightning5
  if (CompareText(xPLMessage.schema.RawxPL,'ac.basic') = 0) and
     ((xPLMessage.Body.Strings.IndexOfName('protocol') < 0) or
      (xPLMessage.Body.Strings.IndexOf('protocol=lwrf') > -1) or
      (xPLMessage.Body.Strings.IndexOf('protocol=emw100') > -1) or
      (xPLMessage.Body.Strings.IndexOf('protocol=bbsb') > -1) or
      (xPLMessage.Body.Strings.IndexOf('protocol=rsl') > -1)) then
    uxPLRFX_0x11.xPL2RFX(xPLMessage, Buffer) else

  // 0x15 - Lightning6
  if (CompareText(xPLMessage.schema.RawxPL,'x10.basic') = 0) and
      (xPLMessage.Body.Strings.IndexOf('protocol=blyss') > -1) then
    uxPLRFX_0x15.xPL2RFX(xPLMessage,Buffer) else

  // 0x18 - Curtain1
  if (CompareText(xPLMessage.schema.RawxPL,'x10.basic') = 0) and
      (xPLMessage.Body.Strings.IndexOf('protocol=harrison') > -1) then
    uxPLRFX_0x18.xPL2RFX(xPLMessage,Buffer) else

  // 0x19 - Blinds1
  if (CompareText(xPLMessage.schema.RawxPL,'control.basic') = 0) and
     ((xPLMessage.Body.Strings.IndexOf('protocol=blinds0') > -1) or
      (xPLMessage.Body.Strings.IndexOf('protocol=blinds1') > -1) or
      (xPLMessage.Body.Strings.IndexOf('protocol=blinds2') > -1) or
      (xPLMessage.Body.Strings.IndexOf('protocol=blinds3') > -1) or
      (xPLMessage.Body.Strings.IndexOf('protocol=blinds4') > -1) or
      (xPLMessage.Body.Strings.IndexOf('protocol=blinds5') > -1)) then
    uxPLRFX_0x19.xPL2RFX(xPLMessage,Buffer) else

  // 0x20 - Security1
  if (CompareText(xPLMessage.schema.RawxPL,'x10.security') = 0) then
    uxPLRFX_0x20.xPL2RFX(xPLMessage,Buffer) else

  // 0x28 - Camera1
  if (CompareText(xPLMessage.schema.RawxPL,'control.basic') = 0) and
     (xPLMessage.Body.Strings.IndexOf('protocol=ninja') > -1) then
    uxPLRFX_0x28.xPL2RFX(xPLMessage,Buffer)
  else
    Raise Exception.Create('Unknown message');
end;

destructor TxPLRFX.Destroy;
begin

end;

end.
