(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x18;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common;

// transmitter only
procedure xPL2RFX(aMessage : TxPLMessage; var Buffer : BytesArray);

implementation

Uses SysUtils;

(*

Type $18 - Curtain1 - Harrison

Buffer[0] = packetlength = $07;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = housecode
Buffer[5] = unitcode
Buffer[6] = cmnd
Buffer[7] = battery_level:4/rssi:4

xPL Schema

x10.basic
{
  device=<housecode[unitcode]
  command=on|off
  protocol=harrison
}

TO CHECK : no support for stop and program commands ??
TO CHECK : how to handle transmitter-only in DHS ??

*)

const
  // Packet Length
  PACKETLENGTH = $07;

  // Type
  CURTAIN1     = $18;

  // Subtype
  HARRISON         = $00;

  // Commands
  COMMAND_OFF      = 'off';
  COMMAND_ON       = 'on';

var
  // Lookup table for commands
  RFXCommandArray : array[1..2] of TRFXCommandRec =
    ((RFXCode : $00; xPLCommand : COMMAND_ON),
     (RFXCode : $01; xPLCommand : COMMAND_OFF));


procedure xPL2RFX(aMessage : TxPLMessage; var Buffer : BytesArray);
begin
  ResetBuffer(Buffer);
  Buffer[0] := PACKETLENGTH;
  Buffer[1] := CURTAIN1;  // Type
  Buffer[2] := HARRISON;
  // Split the device attribute in housecode and unitcode
  Buffer[4] := Ord(aMessage.Body.Strings.Values['device'][1]);
  Buffer[5] := StrToInt(Copy(aMessage.Body.Strings.Values['device'],2,Length(aMessage.Body.Strings.Values['device'])));
  // Command
  Buffer[6] := GetRFXCode(aMessage.Body.Strings.Values['command'],RFXCommandArray);

  Buffer[7] := $0;
end;

end.
