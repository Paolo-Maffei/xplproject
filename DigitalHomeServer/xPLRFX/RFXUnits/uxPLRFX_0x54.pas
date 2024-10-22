(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x54;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);

implementation

Uses SysUtils;

(*

Type $54 - Temperature/Humidity/Barometric sensors

Buffer[0] = packetlength = $0D;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = id1
Buffer[5] = id2
Buffer[6] = temperaturehigh:7/temperaturesign:1
Buffer[7] = temperaturelow
Buffer[8] = humidity
Buffer[9] = humidity_status
Buffer[10] = baro1
Buffer[11] = baro2
Buffer[12] = forecast
Buffer[13] = battery_level:4/rssi:4

Test strings :

0D54020EE90000C9270203E70439

xPL Schema

sensor.basic
{
  device=(thb1-thb2) 0x<hex sensor id>
  type=temp
  current=<degrees celsius>
  units=c
}

sensor.basic
{
  device=(thb1-thb2) 0x<hex sensor id>
  type=humidity
  current=(0-100)
  description=normal|comfort|dry|wet
}

sensor.basic
{
  device=(thb1-thb2) 0x<hex sensor id>
  type=pressure
  current=<hPa>
  units=hpa
  forecast=sunny|partly cloudy|cloudy|rain
}

sensor.basic
{
  device=(thb1-thb2) 0x<hex sensor id>
  type=battery
  current=0-100
}

*)

const
  // Type
  TEMPHUMBARO  = $54;

  // Subtype
  THB1  = $01;
  THB2  = $02;

  // Humidity status
  HUM_NORMAL  = $00;
  HUM_COMFORT = $01;
  HUM_DRY     = $02;
  HUM_WET     = $03;

  // Humidity status strings
  HUM_NORMAL_STR  = 'normal';
  HUM_COMFORT_STR = 'comfort';
  HUM_DRY_STR     = 'dry';
  HUM_WET_STR     = 'wet';

  // Forecast
  FC_NOT_AVAILABLE = $00;
  FC_SUNNY         = $01;
  FC_PARTLY_CLOUDY = $02;
  FC_CLOUDY        = $03;
  FC_RAIN          = $04;

  // Forecast strings
  FC_NOT_AVAILABLE_STR = '';
  FC_SUNNY_STR         = 'sunny';
  FC_PARTLY_CLOUDY_STR = 'partly cloudy';
  FC_CLOUDY_STR        = 'cloudy';
  FC_RAIN_STR          = 'rain';

var
  SubTypeArray : array[1..2] of TRFXSubTypeRec =
    ((SubType : THB1; SubTypeString : 'thb1'),
     (SubType : THB2; SubTypeString : 'thb2'));

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  DeviceID : String;
  SubType : String;
  Temperature : Extended;
  TemperatureSign : String;
  Humidity : Integer;
  Status : String;
  Pressure : Integer;
  Forecast : String;
  BatteryLevel : Integer;
  xPLMessage : TxPLMessage;
begin
  DeviceID := GetSubTypeString(Buffer[2],SubTypeArray)+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2);

  if Buffer[6] and $80 > 0 then
    TemperatureSign := '-';    // negative value
  Buffer[6] := Buffer[6] and $7F;  // zero out the temperature sign
  Temperature := ((Buffer[6] shl 8) + Buffer[7]) / 10;


  Humidity := Buffer[8];
  case Buffer[9] of
    HUM_NORMAL  : Status := HUM_NORMAL_STR;
    HUM_COMFORT : Status := HUM_COMFORT_STR;
    HUM_DRY     : Status := HUM_DRY_STR;
    HUM_WET     : Status := HUM_WET_STR;
  end;

  Pressure := (Buffer[10] shl 8) + Buffer[11];
  case Buffer[12] of
    FC_NOT_AVAILABLE : Forecast := FC_NOT_AVAILABLE_STR;
    FC_SUNNY         : Forecast := FC_SUNNY_STR;
    FC_PARTLY_CLOUDY : Forecast := FC_PARTLY_CLOUDY_STR;
    FC_CLOUDY        : Forecast := FC_CLOUDY_STR;
    FC_RAIN          : Forecast := FC_RAIN_STR;
  end;
  if (Buffer[13] and $0F) = 0 then  // zero out rssi
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
  xPLMessage.Body.AddKeyValue('current='+IntToStr(Humidity));
  xPLMessage.Body.AddKeyValue('description='+Status);
  xPLMessage.Body.AddKeyValue('type=humidity');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;

  xPLMessage := TxPLMessage.Create(nil);
  xPLMessage.schema.RawxPL := 'sensor.basic';
  xPLMessage.MessageType := trig;
  xPLMessage.source.RawxPL := XPLSOURCE;
  xPLMessage.target.IsGeneric := True;
  xPLMessage.Body.AddKeyValue('device='+DeviceID);
  xPLMessage.Body.AddKeyValue('pressure='+IntToStr(Pressure));
  xPLMessage.Body.AddKeyValue('forecast='+Forecast);
  xPLMessage.Body.AddKeyValue('type=pressure');
  xPLMEssage.Body.AddKeyValue('units=hpa');
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
