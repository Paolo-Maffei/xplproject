(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x30;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common;

procedure RFX2xPL(Buffer : BytesArray; xPLMessage : TxPLMessage);
procedure xPL2RFX(aMessage : TxPLMessage; var Buffer : BytesArray);

implementation

(*

Type $30 - Remote Control and IR - ATI, Medion, PC Remote

Buffer[0] = packetlength = $06;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = id
Buffer[5] = cmnd
Buffer[6] = toggle:1/cmdtype:3/rssi:4

Test strings :

063000040F0D82
0630000E000D80
063001060F0D72
063001070F0D73
0630040B000D81
0630040C000D80

xPL Schema

remote.basic
{
  keys=0x<hex keycode>
  device=pc|ati|medion   (0x0-0xf)
}

TO CHECK : how to determine hex channel in xPL message (device attribute) ??

*)

const
  // Packet Length
  PACKETLENGTH        = $06;

  // Type
  REMOTECONTROLIR     = $30;

  // Subtype
  ATI_REMOTE_WONDER      = $00;
  ATI_REMOTE_WONDER_PLUS = $01;
  MEDION_REMOTE          = $02;
  X10_PC_REMOTE          = $03;
  ATI_REMOTE_WONDER_II   = $04;


procedure RFX2xPL(Buffer : BytesArray; xPLMessage : TxPLMessage);
begin

end;

procedure xPL2RFX(aMessage : TxPLMessage; var Buffer : BytesArray);
begin

end;

end.
