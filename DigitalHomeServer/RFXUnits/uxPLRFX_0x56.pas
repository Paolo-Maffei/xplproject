(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x56;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);

implementation

Uses SysUtils;

(*

Type $56 - Wind sensors

Buffer[0]  = packetlength = $10;
Buffer[1]  = packettype
Buffer[2]  = subtype
Buffer[3]  = seqnbr
Buffer[4]  = id1
Buffer[5]  = id2
Buffer[6]  = directionhigh
Buffer[7]  = directionlow
Buffer[8]  = av_speedhigh
Buffer[9]  = av_speedlow
Buffer[10] = gusthigh
Buffer[11] = gustlow
Buffer[12] = temperaturehigh:7/temperaturesign:1
Buffer[13] = temperaturelow
Buffer[14] = chillhigh:7/chillsign:1
Buffer[15] = chillow
Buffer[16] = battery_level:4/rssi:4

Test strings :

105601122F000087000000140049000079

xPL Schema

sensor.basic
{
  device=(wind1-wind6) 0x<hex sensor id>
  type=gust
  current=<m/sec>
  unit=mps
}

sensor.basic
{
  device=(wind1-wind6) 0x<hex sensor id>
  type=average_speed
  current=<m/sec>
  unit=mps
}

sensor.basic
{
  device=(wind1-wind6) 0x<hex sensor id>
  type=direction
  current=0-359
}

sensor.basic
{
  device=(wind1-wind6) 0x<hex sensor id>
  type=temp
  current=<degrees celsius>
  units=c
}

sensor.basic
{
  device=(wind1-wind6) 0x<hex sensor id>
  type=chill
  current=<degrees celsius>
  units=c
}

sensor.basic
{
  device=(wind1-wind6) 0x<hex sensor id>
  type=battery
  current=0-100
}

TO CHECK : what exactly is chill temperature ?

*)

const
  // Type
  WIND  = $56;

  // Subtype
  WIND1  = $01;
  WIND2  = $02;
  WIND3  = $03;
  WIND4  = $04;
  WIND5  = $05;
  WIND6  = $06;

var
  SubTypeArray : array[1..6] of TRFXSubTypeRec =
    ((SubType : WIND1; SubTypeString : 'wind1'),
     (SubType : WIND2; SubTypeString : 'wind2'),
     (SubType : WIND3; SubTypeString : 'wind3'),
     (SubType : WIND4; SubTypeString : 'wind4'),
     (SubType : WIND5; SubTypeString : 'wind5'),
     (SubType : WIND6; SubTypeString : 'wind6'));


procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  SubType : Byte;
  DeviceID : String;
  Direction : Integer;
  AverageSpeed : Extended;
  Gust : Extended;
  Temperature : Extended;
  TemperatureSign : String;
  Chill : Extended;
  ChillSign : String;
  BatteryLevel : Integer;
  xPLMessage : TxPLMessage;
begin
  SubType := Buffer[2];
  DeviceID := GetSubTypeString(SubType,SubTypeArray)+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2);
  Direction := (Buffer[6] shl 8) + Buffer[7];
  if SubType <> WIND5 then
    AverageSpeed := ((Buffer[8] shl 8) + Buffer[9]) / 10;
  Gust := ((Buffer[10] shl 8) + Buffer[11]) / 10;
  if SubType = WIND4 then
    begin
      if Buffer[12] and $80 > 0 then
        TemperatureSign := '-';    // negative value
      Buffer[12] := Buffer[12] and $7F;  // zero out the temperature sign
      Temperature := ((Buffer[12] shl 8) + Buffer[13]) / 10;

      if Buffer[14] and $80 > 0 then
        ChillSign := '-';    // negative value
      Buffer[14] := Buffer[14] and $7F;  // zero out the temperature sign
      Chill := ((Buffer[14] shl 8) + Buffer[15]) / 10;
    end;

  if (Buffer[16] and $0F) = 0 then  // zero out rssi
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
  xPLMessage.Body.AddKeyValue('current='+FloatToStr(Gust));
  xPLMessage.Body.AddKeyValue('units=mps');
  xPLMessage.Body.AddKeyValue('type=gust');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;

  if SubType <> WIND5 then
    begin
      xPLMessage := TxPLMessage.Create(nil);
      xPLMessage.schema.RawxPL := 'sensor.basic';
      xPLMessage.MessageType := trig;
      xPLMessage.source.RawxPL := XPLSOURCE;
      xPLMessage.target.IsGeneric := True;
      xPLMessage.Body.AddKeyValue('device='+DeviceID);
      xPLMessage.Body.AddKeyValue('current='+FloatToStr(AverageSpeed));
      xPLMessage.Body.AddKeyValue('units=mps');
      xPLMessage.Body.AddKeyValue('type=average_speed');
      xPLMessages.Add(xPLMessage.RawXPL);
      xPLMessage.Free;
    end;

  xPLMessage := TxPLMessage.Create(nil);
  xPLMessage.schema.RawxPL := 'sensor.basic';
  xPLMessage.MessageType := trig;
  xPLMessage.source.RawxPL := XPLSOURCE;
  xPLMessage.target.IsGeneric := True;
  xPLMessage.Body.AddKeyValue('device='+DeviceID);
  xPLMessage.Body.AddKeyValue('current='+IntToStr(Direction));
  xPLMessage.Body.AddKeyValue('type=direction');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;

  if SubType = WIND4 then
    begin
      xPLMessage := TxPLMessage.Create(nil);
      xPLMessage.schema.RawxPL := 'sensor.basic';
      xPLMessage.MessageType := trig;
      xPLMessage.source.RawxPL := XPLSOURCE;
      xPLMessage.target.IsGeneric := True;
      xPLMessage.Body.AddKeyValue('device='+DeviceID);
      xPLMessage.Body.AddKeyValue('current='+TemperatureSign+FloatToStr(Temperature));
      xPLMessage.Body.AddKeyValue('units=c');
      xPLMessage.Body.AddKeyValue('type=temperature');
      xPLMessages.Add(xPLMessage.RawXPL);
      xPLMessage.Free;

      xPLMessage := TxPLMessage.Create(nil);
      xPLMessage.schema.RawxPL := 'sensor.basic';
      xPLMessage.MessageType := trig;
      xPLMessage.source.RawxPL := XPLSOURCE;
      xPLMessage.target.IsGeneric := True;
      xPLMessage.Body.AddKeyValue('device='+DeviceID);
      xPLMessage.Body.AddKeyValue('current='+ChillSign+FloatToStr(Chill));
      xPLMessage.Body.AddKeyValue('units=c');
      xPLMessage.Body.AddKeyValue('type=chill');
      xPLMessages.Add(xPLMessage.RawXPL);
      xPLMessage.Free;
    end;

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
