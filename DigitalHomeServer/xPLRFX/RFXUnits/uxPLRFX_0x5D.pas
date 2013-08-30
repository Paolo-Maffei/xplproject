(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x5D;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);

implementation

Uses SysUtils;

(*

Type $5D - Weighting scale

Buffer[0] = packetlength = $08;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = id1
Buffer[5] = id2
Buffer[6] = weighthigh
Buffer[7] = weightlow
Buffer[8] = battery_level:4/rssi:4

xPL Schema

sensor.basic
{
  device=weight1|weight2 0x<hex sensor id>
  type=weight
  current=<kg>
  units=kg
}

sensor.basic
{
  device=weight1|weight2 0x<hex sensor id>
  type=battery
  current=0-100
}

*)

const
  // Type
  WEIGHTING  = $5B;

  // Subtype
  WEIGHT1  = $01;
  WEIGHT2  = $02;

var
  SubTypeArray : array[1..2] of TRFXSubTypeRec =
    ((SubType : WEIGHT1; SubTypeString : 'weight1'),
     (SubType : WEIGHT2; SubTypeString : 'weight2'));

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  DeviceID : String;
  SubType : byte;
  Weight : Extended;
  BatteryLevel : Integer;
  xPLMessage : TxPLMessage;
begin
  SubType := Buffer[2];
  DeviceID := GetSubTypeString(SubType,SubTypeArray)+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2);
  Weight := ((Buffer[6] shl 8) + Buffer[7]) / 10;
  if (Buffer[8] and $0F) = 0 then  // zero out rssi
    BatteryLevel := 0
  else
    BatteryLevel := 100;

  // Create sensor.basic messages
  xPLMessage := TxPLMessage.Create(nil);
  xPLMessage.schema.RawxPL := 'sensor.basic';
  xPLMessage.MessageType := trig;
  xPLMessage.source.RawxPL := XPLSOURCE;
  xPLMessage.target.IsGeneric := True;
  xPLMessage.Body.AddKeyValue('device='+DeviceID);
  xPLMessage.Body.AddKeyValue('current='+FloatToStr(Weight));
  xPLMessage.Body.AddKeyValue('type=weight');
  xPLMessage.Body.AddKeyValue('units=kg');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;

  xPLMessage := TxPLMessage.Create(nil);
  xPLMessage.schema.RawxPL := 'sensor.basic';
  xPLMessage.MessageType := trig;
  xPLMessage.source.RawxPL := XPLSOURCE;
  xPLMessage.target.IsGeneric := True;
  xPLMessage.Body.AddKeyValue('device='+DeviceID);
  xPLMessage.Body.AddKeyValue('current='+IntToStr(BatteryLevel));
  xPLMessage.Body.AddKeyValue('type=battery');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;
end;

end.
