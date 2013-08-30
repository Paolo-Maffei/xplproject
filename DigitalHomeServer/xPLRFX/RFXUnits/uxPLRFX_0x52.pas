(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x52;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);

implementation

Uses SysUtils;

(*

Type $52 - Temperature/Humidity Sensors

Buffer[0] = packetlength = $0A;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = id1
Buffer[5] = id2
Buffer[6] = temperaturehigh:7/temperaturesign:1
Buffer[7] = temperaturelow
Buffer[8] = humidity
Buffer[9] = humidity_status
Buffer[10] = battery_level:4/rssi:4

Test strings :

0A520211700200A72D0089
0A5205D42F000082590379

xPL Schema

sensor.basic
{
  device=(th1-th10) 0x<hex sensor id>
  type=temp
  current=<degrees celsius>
  units=c
}

sensor.basic
{
  device=(th1-th10) 0x<hex sensor id>
  type=humidity
  current=(0-100)
  description=normal|comfort|dry|wet
}

sensor.basic
{
  device=(th1-th10) 0x<hex sensor id>
  type=battery
  current=0-100
}

*)

const
  // Type
  TEMPHUM  = $52;

  // Subtype
  TH1  = $01;   //
  TH2  = $02;
  TH3  = $03;
  TH4  = $04;
  TH5  = $05;
  TH6  = $06;
  TH7  = $07;
  TH8  = $08;
  TH9  = $09;
  TH10 = $0A;

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
  SubTypeArray : array[1..10] of TRFXSubTypeRec =
    ((SubType : TH1; SubTypeString : 'th1'),
     (SubType : TH2; SubTypeString : 'th2'),
     (SubType : TH3; SubTypeString : 'th3'),
     (SubType : TH4; SubTypeString : 'th4'),
     (SubType : TH5; SubTypeString : 'th5'),
     (SubType : TH6; SubTypeString : 'th6'),
     (SubType : TH7; SubTypeString : 'th7'),
     (SubType : TH8; SubTypeString : 'th8'),
     (SubType : TH9; SubTypeString : 'th9'),
     (SubType : TH10; SubTypeString : 'th10'));

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  DeviceID : String;
  SubType : String;
  Temperature : Extended;
  TemperatureSign : String;
  Humidity : Integer;
  Status : String;
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
  if (Buffer[10] and $0F) = 0 then  // zero out rssi
    BatteryLevel := 0
  else
    BatteryLevel := 100;

  // Create sensor.basic message for the temperature
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
  xPLMessage.Body.AddKeyValue('current='+IntToStr(BatteryLevel));
  xPLMessage.Body.AddKeyValue('type=battery');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;

end;


end.
