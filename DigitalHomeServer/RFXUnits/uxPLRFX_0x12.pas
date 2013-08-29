(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x12;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common;

procedure RFX2xPL(Buffer : BytesArray; xPLMessage : TxPLMessage);
procedure xPL2RFX(aMessage : TxPLMessage; var Buffer : BytesArray);

implementation

(*

Type $12 - Lighting3 - Koppla

Buffer[0] = packetlength = $08;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = system                                          // Housecode
Buffer[5] = channel8_1    (bit 8 7 6 5 4 3 2  1)            // Unitcode
Buffer[6] = channel10_9   (bit x x x x x x 10 9)
Buffer[7] = cmnd
Buffer[8] = battery:4/rssi:4

Test Strings :

0B11000600109B520B000080

xPL Schema

x10.basic
{
  device=<housecode[unitcode]
  command=on|off|dim|bright|preset
  [level=1-9]
  protocol=koppla
}

*)

const
  // Packet Length
  PACKETLENGTH  = $08;
  // Type
  LIGHTING3     = $12;

  // Subtype
  IKEAKOPPLA       = $00;

  // Commands
  COMMAND_BRIGHT   = 'bright';
  COMMAND_ON       = 'on';
  COMMAND_DIM      = 'dim';
  COMMAND_OFF      = 'off';

  //  TO CHECK  ?? COMMAND_PROGRAM ??

var
  // Lookup table for commands
  RFXCommandArray : array[1..4] of TRFXCommandRec =
    ((RFXCode : $00; xPLCommand : COMMAND_BRIGHT),
     (RFXCode : $08; xPLCommand : COMMAND_DIM),
     (RFXCode : $10; xPLCommand : COMMAND_ON),
     (RFXCode : $1A; xPLCommand : COMMAND_OFF));

procedure RFX2xPL(Buffer : BytesArray; xPLMessage : TxPLMessage);
begin

end;

procedure xPL2RFX(aMessage : TxPLMessage; var Buffer : BytesArray);
begin

end;

end.
