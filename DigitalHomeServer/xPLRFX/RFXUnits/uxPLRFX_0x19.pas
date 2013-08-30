(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x19;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
procedure xPL2RFX(aMessage : TxPLMessage; var Buffer : BytesArray);

implementation

Uses SysUtils;

(*

Type $19 - Blinds1 - RollerTrol, Hasta, A-OK, Raex, Media Mount

Buffer[0] = packetlength = $09;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = id1
Buffer[5] = id2
Buffer[6] = id3
Buffer[7] = unitcode
Buffer[8] = cmnd
Buffer[9] = battery_level:4/rssi:4

Test Strings :

0919040600A21B010280


xPL Schema

control.basic
{
  device=0x000001-0xffffff
  unit=0-15|all
  current=open|close|stop|confirm_pair|set_limit|set_lower_limit|delete_limits|change_direction|left|right
  protocol=<blinds0-blinds5>
}


*)

const
  // Packet length
  PACKETLENGTH     = $09;

  // Type
  BLINDS1          = $19;

  // Subtype
  BLINDST0         = $00; // Rollertrol, Hasta new
  BLINDST1         = $01; // Hasta old
  BLINDST2         = $02; // A-OK RF01
  BLINDST3         = $03; // A-OK AC114
  BLINDST4         = $04; // Raex YR1326
  BLINDST5         = $05; // Media Mount

  // Commands
  COMMAND_OPEN             = 'open';
  COMMAND_CLOSE            = 'close';
  COMMAND_STOP             = 'stop';
  COMMAND_CONFIRM          = 'confirm_pair';
  COMMAND_SET_LIMIT        = 'set_limit';
  COMMAND_SET_LOWER_LIMIT  = 'set_lower_limit';
  COMMAND_DELETE_LIMITS    = 'delete_limits';
  COMMAND_CHANGE_DIRECTION = 'change_direction';
  COMMAND_LEFT             = 'left';
  COMMAND_RIGHT            = 'right';

var
  // Lookup table for commands
  RFXCommandArray : array[1..10] of TRFXCommandRec =
    ((RFXCode : $00; xPLCommand : COMMAND_OPEN),
     (RFXCode : $01; xPLCommand : COMMAND_CLOSE),
     (RFXCode : $02; xPLCommand : COMMAND_STOP),
     (RFXCode : $03; xPLCommand : COMMAND_CONFIRM),
     (RFXCode : $04; xPLCommand : COMMAND_SET_LIMIT),
     (RFXCode : $05; xPLCommand : COMMAND_SET_LOWER_LIMIT),
     (RFXCode : $06; xPLCommand : COMMAND_DELETE_LIMITS),
     (RFXCode : $07; xPLCommand : COMMAND_CHANGE_DIRECTION),
     (RFXCode : $08; xPLCommand : COMMAND_LEFT),
     (RFXCode : $09; xPLCommand : COMMAND_RIGHT)
     );

  SubTypeArray : array[1..6] of TRFXSubTypeRec =
    ((SubType : BLINDST0; SubTypeString : 'blindst0'),
     (SubType : BLINDST1; SubTypeString : 'blindst1'),
     (SubType : BLINDST2; SubTypeString : 'blindst2'),
     (SubType : BLINDST3; SubTypeString : 'blindst3'),
     (SubType : BLINDST4; SubTypeString : 'blindst4'),
     (SubType : BLINDST5; SubTypeString : 'blindst5'));


procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  DeviceID : String;
  Current : String;
  UnitCode : Integer;
  xPLMessage : TxPLMessage;
begin
  DeviceID := '0x'+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2)+IntToHex(Buffer[6],2);
  Current := GetxPLCommand(Buffer[8],RFXCommandArray);
  UnitCode := Buffer[7];

  // Create control.basic message
  xPLMessage := TxPLMessage.Create(nil);
  xPLMessage.schema.RawxPL := 'control.basic';
  xPLMessage.MessageType := trig;
  xPLMessage.source.RawxPL := XPLSOURCE;
  xPLMessage.target.IsGeneric := True;
  xPLMessage.Body.AddKeyValue('device='+DeviceID);
  xPLMessage.Body.AddKeyValue('current='+current);
  if UnitCode = $10 then
    xPLMessage.Body.AddKeyValue('unit=all')
  else
    xPLMessage.Body.AddKeyValue('unit='+IntToStr(UnitCode));
  xPLMessage.Body.AddKeyValue('protocol='+GetSubTypeString(Buffer[2],SubTypeArray));
  xPLMessages.Add(xPLMessage.RawXPL);
end;

procedure xPL2RFX(aMessage : TxPLMessage; var Buffer : BytesArray);
begin
  ResetBuffer(Buffer);
  Buffer[0] := PACKETLENGTH;
  Buffer[1] := BLINDS1;  // Type
  Buffer[2] := GetSubTypeFromString(aMessage.Body.Strings.Values['protocol'],SubTypeArray);
  Buffer[4] := StrToInt('$'+Copy(aMessage.Body.Strings.Values['device'],3,2));
  Buffer[5] := StrToInt('$'+Copy(aMessage.Body.Strings.Values['device'],5,2));
  Buffer[6] := StrToInt('$'+Copy(aMessage.Body.Strings.Values['device'],7,2));
  if CompareText(aMessage.Body.Strings.Values['unit'],'all') = 0 then
    Buffer[7] := $10
  else
    Buffer[7] := StrToInt(aMessage.Body.Strings.Values['unit']);
  Buffer[8] := GetRFXCode(aMessage.Body.Strings.Values['current'],RFXCommandArray);
end;

end.
