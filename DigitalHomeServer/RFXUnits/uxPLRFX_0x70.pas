(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x70;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);

implementation

Uses SysUtils;

(*

Type $70 - RFXSensor

Buffer[0] = packetlength = $07;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = id
Buffer[5] = msg1
Buffer[6] = msg2
Buffer[7] = filler:4/rssi:4

Test strings :

077000E92802E170
0770000208809650
077002EA2801D870
077001EB28018170

xPL Schema

sensor.basic
{
  device=rfxsensor1 0x<hex sensor id>
  type=temp
  current=<temperature>
  units=c
}

sensor.basic
{
  device=rfxsensor1|rfxsensor2 0x<hex sensor id>
  type=millivolt
  current=<millivolt>
  units=mv
}


*)

const
  // Type
  RFXSENSOR  = $70;

  // Subtype
  RFXSENSOR1  = $00;   // temperature
  RFXSENSOR2  = $01;   // A/D
  RFXSENSOR3  = $02;   // voltage
  RFXSENSOR4  = $03;   // message

var
  SubTypeArray : array[1..4] of TRFXSubTypeRec =
    ((SubType : RFXSENSOR1; SubTypeString : 'rfxsensor1'),
     (SubType : RFXSENSOR2; SubTypeString : 'rfxsensor2'),
     (SubType : RFXSENSOR3; SubTypeString : 'rfxsensor3'),
     (SubType : RFXSENSOR4; SubTypeString : 'rfxsensor4'));

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  DeviceID : String;
  SubType : Byte;
  Temperature : Extended;
  TemperatureSign : String;
  Millivolt : Integer;
  xPLMessage : TxPLMessage;
begin
  SubType := Buffer[2];
  DeviceID := GetSubTypeString(SubType,SubTypeArray)+IntToHex(Buffer[4],2);
  if SubType = RFXSENSOR1 then
    begin
      if Buffer[5] and $80 > 0 then
        TemperatureSign := '-';    // negative value
      Buffer[5] := Buffer[5] and $7F;  // zero out the temperature sign
      Temperature := ((Buffer[5] shl 8) + Buffer[6]) / 100;
    end;
  if (SubType = RFXSENSOR2) or (SubType = RFXSENSOR3) then
    begin
      Millivolt := (Buffer[5] shl 8) + Buffer[6];
    end;

  // Create sensor.basic messages
  if SubType = RFXSENSOR1 then
    begin
      xPLMessage := TxPLMessage.Create(nil);
      xPLMessage.schema.RawxPL := 'sensor.basic';
      xPLMessage.MessageType := trig;
      xPLMessage.source.RawxPL := XPLSOURCE;
      xPLMessage.target.IsGeneric := True;
      xPLMessage.Body.AddKeyValue('device='+DeviceID);
      xPLMessage.Body.AddKeyValue('current='+TemperatureSign+FloatToStr(Temperature));
      xPLMessage.Body.AddKeyValue('type=temp');
      xPLMessage.Body.AddKeyValue('units=c');
      xPLMessages.Add(xPLMessage.RawXPL);
      xPLMessage.Free;
    end;

  if (SubType = RFXSENSOR2) or (SubType = RFXSENSOR3) then
    begin
      xPLMessage := TxPLMessage.Create(nil);
      xPLMessage.schema.RawxPL := 'sensor.basic';
      xPLMessage.MessageType := trig;
      xPLMessage.source.RawxPL := XPLSOURCE;
      xPLMessage.target.IsGeneric := True;
      xPLMessage.Body.AddKeyValue('device='+DeviceID);
      xPLMessage.Body.AddKeyValue('current='+IntToStr(Millivolt));
      xPLMessage.Body.AddKeyValue('type=millivolt');
      xPLMessage.Body.AddKeyValue('units=mv');
      xPLMessages.Add(xPLMessage.RawXPL);
      xPLMessage.Free;
    end;

end;


end.
