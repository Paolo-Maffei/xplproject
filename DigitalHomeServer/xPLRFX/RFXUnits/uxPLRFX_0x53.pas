(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x53;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);

implementation

Uses SysUtils;

(*

Type $53 - Barometric Sensors

Buffer[0] = packetlength = $09;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = id1
Buffer[5] = id2
Buffer[6] = baro1
Buffer[7] = baro2
Buffer[8] = forecast
Buffer[9] = battery_level:4/rssi:4

xPL Schema

sensor.basic
{
  device=baro 0x<hex sensor id>
  type=pressure
  current=<hPa>
  units=hpa
  forecast=sunny|partly cloudy|cloudy|rain
}

sensor.basic
{
  device=baro 0x<hex sensor id>
  type=battery
  current=0-100
}

*)

const
  // Type
  BAROMETER  = $53;

  // Subtype
  BARO1 = $01;
  // TO CHECK : what is subtype here ?

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
  SubTypeArray : array[1..1] of TRFXSubTypeRec =
    ((SubType : BARO1; SubTypeString : 'baro1'));


procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  DeviceID : String;
  SubType : String;
  Pressure : Integer;
  Forecast : String;
  BatteryLevel : Integer;
  xPLMessage : TxPLMessage;
begin
  DeviceID := GetSubTypeString(Buffer[2],SubTypeArray)+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2);
  Pressure := (Buffer[6] shl 8) + Buffer[7];
  case Buffer[8] of
    FC_NOT_AVAILABLE : Forecast := FC_NOT_AVAILABLE_STR;
    FC_SUNNY         : Forecast := FC_SUNNY_STR;
    FC_PARTLY_CLOUDY : Forecast := FC_PARTLY_CLOUDY_STR;
    FC_CLOUDY        : Forecast := FC_CLOUDY_STR;
    FC_RAIN          : Forecast := FC_RAIN_STR;
  end;
  if (Buffer[9] and $0F) = 0 then  // zero out rssi
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
