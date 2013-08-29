(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x14;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
procedure xPL2RFX(aMessage : TxPLMessage; var Buffer : BytesArray);

implementation

Uses SysUtils;

(*

Type $14 - Lighting5 - LightwaveRF, Siemens, EMW100, BBSB, MDREMOTE, RSL2

Buffer[0] = packetlength = $0A;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = id1
Buffer[5] = id2
Buffer[6] = id3
Buffer[7] = unitcode
Buffer[8] = cmnd
Buffer[9] = level
Buffer[10] = filler:4/rssi:4

xPL Schema

ac.basic
{
  address=(0x1-0x3fffffff)
  unit=(0-15)|group
  command=on|off|all_lights_on|all_lights_off
  [level=(0-15)]
  protocol=lwrf|emw100|bbsb|rsl
}

TO CHECK : what with the other LightwaveRF codes ?
TO CHECK : what with MDREMOTE ?

*)

const
  // Packet length
  PACKETLENGTH  = $0A;

  // Type
  LIGHTING5     = $14;

  // Subtype
  LIGHTWAVERF  = $00;
  EMW100       = $01;
  BBSB         = $02;
  MDREMOTELED  = $03;
  RSL          = $04;

  // Commands for LightwaveRF, EMW100, BBSB and RSL
  COMMAND_OFF      = 'off';
  COMMAND_ON       = 'on';
  COMMAND_GROUPOFF = 'group off';
  COMMAND_LEARN    = 'learn';
  COMMAND_GROUPON  = 'group on';
  COMMAND_MOOD1    = 'mood1';
  COMMAND_MOOD2    = 'mood2';
  COMMAND_MOOD3    = 'mood3';
  COMMAND_MOOD4    = 'mood4';
  COMMAND_MOOD5    = 'mood5';
  COMMAND_UNLOCK   = 'unlock';
  COMMAND_LOCK     = 'lock';
  COMMAND_ALL_LOCK = 'all_lock';
  COMMAND_CLOSE    = 'close';
  COMMAND_STOP     = 'stop';
  COMMAND_OPEN     = 'open';
  COMMAND_SETLEVEL = 'set_level';

  // Commands for MDRemote
  COMMAND_POWER     = 'power';
  COMMAND_LIGHT     = 'light';
  COMMAND_BRIGHT    = 'bright';
  COMMAND_DIM       = 'dim';
  COMMAND_100PCT    = '100pct';
  COMMAND_50PCT     = '50pct';
  COMMAND_25PCT     = '25pct';
  COMMAND_MODEPLUS  = 'modeplus';
  COMMAND_SPEEDMIN  = 'speedmin';
  COMMAND_SPEEDPLUS = 'speedplus';
  COMMAND_MODEMIN   = 'modemin';

var
  // Lookup table for commands for LightWaveRF
  RFXCommandArrayLWRF : array[1..15] of TRFXCommandRec =
    ((RFXCode : $00; xPLCommand : COMMAND_OFF),
     (RFXCode : $01; xPLCommand : COMMAND_ON),
     (RFXCode : $02; xPLCommand : COMMAND_GROUPOFF),
     (RFXCode : $03; xPLCommand : COMMAND_MOOD1),
     (RFXCode : $04; xPLCommand : COMMAND_MOOD2),
     (RFXCode : $05; xPLCommand : COMMAND_MOOD3),
     (RFXCode : $06; xPLCommand : COMMAND_MOOD4),
     (RFXCode : $07; xPLCommand : COMMAND_MOOD5),
     (RFXCode : $0A; xPLCommand : COMMAND_UNLOCK),
     (RFXCode : $0B; xPLCommand : COMMAND_LOCK),
     (RFXCode : $0C; xPLCommand : COMMAND_ALL_LOCK),
     (RFXCode : $0D; xPLCommand : COMMAND_CLOSE),
     (RFXCode : $0E; xPLCommand : COMMAND_STOP),
     (RFXCode : $0F; xPLCommand : COMMAND_OPEN),
     (RFXCode : $10; xPLCommand : COMMAND_SETLEVEL)
    );

  RFXCommandArrayEMW100 : array[1..3] of TRFXCommandRec =
    ((RFXCode : $00; xPLCommand : COMMAND_OFF),
     (RFXCode : $01; xPLCommand : COMMAND_ON),
     (RFXCode : $02; xPLCommand : COMMAND_LEARN)
    );

  RFXCommandArrayBBSB_RSL : array[1..4] of TRFXCommandRec =
    ((RFXCode : $00; xPLCommand : COMMAND_OFF),
     (RFXCode : $01; xPLCommand : COMMAND_ON),
     (RFXCode : $02; xPLCommand : COMMAND_GROUPOFF),
     (RFXCode : $03; xPLCommand : COMMAND_GROUPON)
    );

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  SubType : Byte;
  Address : String;
  UnitCode : String;
  Command : String;
  Level : Integer;
  xPLMessage : TxPLMessage;
begin
  SubType := Buffer[2];
  Address := '0x'+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2)+IntToHex(Buffer[6],2);
  UnitCode := IntToStr(Buffer[7]);
  Case SubType of
    LIGHTWAVERF : Command := GetxPLCommand(Buffer[8], RFXCommandArrayLWRF);
    EMW100      : Command := GetxPLCommand(Buffer[8], RFXCommandArrayEMW100);
    BBSB, RSL   : Command := GetxPLCommand(Buffer[8], RFXCommandArrayBBSB_RSL);
  End;
  if SubType = LIGHTWAVERF then
    Level := Buffer[9];
  // Only on, off, group on, group off are supported
  if (Command = COMMAND_ON) or (Command = COMMAND_OFF) or (Command = COMMAND_GROUPON) or (Command = COMMAND_GROUPOFF) then
    begin
      // Create ac.basic message
      xPLMessage := TxPLMessage.Create(nil);
      xPLMessage.schema.RawxPL := 'ac.basic';
      xPLMessage.MessageType := trig;
      xPLMessage.source.RawxPL := XPLSOURCE;
      xPLMessage.target.IsGeneric := True;
      xPLMessage.Body.AddKeyValue('address='+Address);
      xPLMessage.Body.AddKeyValue('unit='+UnitCode);
      xPLMessage.Body.AddKeyValue('command='+Command);
      case SubType of
        LIGHTWAVERF : xPLMessage.Body.AddKeyValue('protocol=lwrf');
        EMW100      : xPLMessage.Body.AddKeyValue('protocol=emw100');
        BBSB        : xPLMessage.Body.AddKeyValue('protocol=bbsb');
        RSL         : xPLMessage.Body.AddKeyValue('protocol=rsl');
      end;
      xPLMessages.Add(xPLMessage.RawXPL);
    end;
end;

procedure xPL2RFX(aMessage : TxPLMessage; var Buffer : BytesArray);
begin
  ResetBuffer(Buffer);
  Buffer[0] := PACKETLENGTH;
  Buffer[1] := LIGHTING5;  // Type
  // Subtype
  if aMessage.Body.Strings.IndexOf('protocol=lwrf') > -1 then
    Buffer[2] := LIGHTWAVERF else
  if aMessage.Body.Strings.IndexOf('protocol=emw100') > -1 then
    Buffer[2] := EMW100 else
  if aMessage.Body.Strings.IndexOf('protocol=bbsb') > -1 then
    Buffer[2] := BBSB;
  // Copy the address
  Buffer[4] := StrToInt('$'+Copy(aMessage.Body.Strings.Values['address'],3,2));
  Buffer[5] := StrToInt('$'+Copy(aMessage.Body.Strings.Values['address'],5,2));
  Buffer[6] := StrToInt('$'+Copy(aMessage.Body.Strings.Values['address'],7,2));
  Buffer[7] := StrToInt(aMessage.Body.Strings.Values['unit']);
  case Buffer[2] of
    LIGHTWAVERF : GetRFXCode(aMessage.Body.Strings.Values['address'],RFXCommandArrayLWRF);
    EMW100      : GetRFXCode(aMessage.Body.Strings.Values['address'],RFXCommandArrayEMW100);
    BBSB, RSL   : GetRFXCode(aMessage.Body.Strings.Values['address'],RFXCommandArrayBBSB_RSL);
  end;
  if aMessage.Body.Strings.IndexOfName('level') > -1 then
    Buffer[9] := StrToInt(aMessage.Body.Strings.Values['level']);
end;

end.
