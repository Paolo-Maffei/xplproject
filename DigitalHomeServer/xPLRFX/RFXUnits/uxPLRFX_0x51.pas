(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x51;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);

implementation

Uses SysUtils;

(*

Type $51 - Humidity Sensors

Buffer[0] = packetlength = $08;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = id1
Buffer[5] = id2
Buffer[6] = humidity
Buffer[7] = humidity_status
Buffer[8] = battery_level:4/rssi:4

Test strings :

085101027700360189

xPL Schema

sensor.basic
{
  device=(hum1-hum2) 0x<hex sensor id>
  type=humidity
  current=(0-100)
  description=normal|comfort|dry|wet
}

sensor.basic
{
  device=(hum1-hum2) 0x<hex sensor id>
  type=battery
  current=0-100
}

*)

const
  // Type
  HUMIDITY  = $51;

  // Subtype
  HUM1  = $01;
  HUM2  = $02;

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

var
  SubTypeArray : array[1..2] of TRFXSubTypeRec =
    ((SubType : HUM1; SubTypeString : 'hum1'),
     (SubType : HUM2; SubTypeString : 'hum2'));


procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  DeviceID : String;
  SubType : String;
  Humidity : Integer;
  Status : String;
  BatteryLevel : Integer;
  xPLMessage : TxPLMessage;
begin
  DeviceID := GetSubTypeString(Buffer[2],SubTypeArray)+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2);
  Humidity := Buffer[6];
  case Buffer[7] of
    HUM_NORMAL  : Status := HUM_NORMAL_STR;
    HUM_COMFORT : Status := HUM_COMFORT_STR;
    HUM_DRY     : Status := HUM_DRY_STR;
    HUM_WET     : Status := HUM_WET_STR;
  end;
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
  xPLMessage.Body.AddKeyValue('current='+IntToStr(BatteryLevel));
  xPLMessage.Body.AddKeyValue('type=battery');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;


end;

end.
