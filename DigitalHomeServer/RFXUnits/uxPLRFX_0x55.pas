(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x55;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);

implementation

Uses SysUtils;

(*

Type $55 - Rain sensors

Buffer[0]  = packetlength = $0B;
Buffer[1]  = packettype
Buffer[2]  = subtype
Buffer[3]  = seqnbr
Buffer[4]  = id1
Buffer[5]  = id2
Buffer[6]  = rainratehigh
Buffer[7]  = rainratelow
Buffer[8]  = raintotal1   // high byte
Buffer[9]  = raintotal2
Buffer[10] = raintotal3   // low byte
Buffer[11] = battery_level:4/rssi:4

Test strings :

0B550217B6000000004D3C69

xPL Schema

sensor.basic
{
  device=(rain1-rain6) 0x<hex sensor id>
  type=rainrate
  current=<mm/hr>
  unit=mmh
}

sensor.basic
{
  device=(rain1-rain6) 0x<hex sensor id>
  type=raintotal
  current=<mm>
  unit=mm
}

sensor.basic
{
  device=(rain1-rain6) 0x<hex sensor id>
  type=battery
  current=0-100
}

*)

const
  // Type
  RAIN  = $55;

  // Subtype
  RAIN1  = $01;
  RAIN2  = $02;
  RAIN3  = $03;
  RAIN4  = $04;
  RAIN5  = $05;
  RAIN6  = $06;

var
  SubTypeArray : array[1..6] of TRFXSubTypeRec =
    ((SubType : RAIN1; SubTypeString : 'rain1'),
     (SubType : RAIN2; SubTypeString : 'rain2'),
     (SubType : RAIN3; SubTypeString : 'rain3'),
     (SubType : RAIN4; SubTypeString : 'rain4'),
     (SubType : RAIN5; SubTypeString : 'rain5'),
     (SubType : RAIN6; SubTypeString : 'rain6'));


procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  DeviceID : String;
  SubType : Byte;
  RainRate : Integer;
  RainTotal : Extended;
  BatteryLevel : Integer;
  xPLMessage : TxPLMessage;
begin
  SubType := Buffer[2];
  DeviceID := GetSubTypeString(SubType,SubTypeArray)+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2);
  RainRate := (Buffer[6] shl 8) + Buffer[7];
  if SubType = RAIN2 then
    RainRate := RainRate div 100;

  if SubType <> RAIN6 then
    RainTotal := ((Buffer[8] shl 16) + (Buffer[9] shl 8) + Buffer[10]) / 10
  else
    ;      // TO CHECK : how does this flipcounter work ?

  if (Buffer[11] and $0F) = 0 then  // zero out rssi
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
  xPLMessage.Body.AddKeyValue('current='+IntToStr(RainRate));
  xPLMessage.Body.AddKeyValue('units=mmh');
  xPLMessage.Body.AddKeyValue('type=rainrate');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;

  xPLMessage := TxPLMessage.Create(nil);
  xPLMessage.schema.RawxPL := 'sensor.basic';
  xPLMessage.MessageType := trig;
  xPLMessage.source.RawxPL := XPLSOURCE;
  xPLMessage.target.IsGeneric := True;
  xPLMessage.Body.AddKeyValue('device='+DeviceID);
  xPLMessage.Body.AddKeyValue('current='+FloatToStr(RainTotal));
  xPLMessage.Body.AddKeyValue('units=mm');
  xPLMessage.Body.AddKeyValue('type=raintotal');
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
