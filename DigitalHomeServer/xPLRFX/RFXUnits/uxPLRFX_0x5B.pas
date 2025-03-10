(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFX_0x5B;

interface

Uses uxPLRFXConst, u_xPL_Message, u_xpl_common, uxPLRFXMessages;

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);

implementation

Uses SysUtils;

(*

Type $5A - Energy usage sensors

Buffer[0] = packetlength = $13;
Buffer[1] = packettype
Buffer[2] = subtype
Buffer[3] = seqnbr
Buffer[4] = id1
Buffer[5] = id2
Buffer[6] = count
Buffer[7] = ch1_high
Buffer[8] = ch1_low
Buffer[9] = ch2_high
Buffer[10] = ch2_low
Buffer[11] = ch3_high
Buffer[12] = ch3_low
Buffer[13] = total1
Buffer[14] = total2
Buffer[15] = total3
Buffer[16] = total4
Buffer[17] = total5
Buffer[18] = total6
Buffer[19] = battery_level:4/rssi:4

xPL Schema

sensor.basic
{
  device=elec4_1 0x<hex sensor id>
  type=current
  current=<ampere>
}

sensor.basic
{
  device=elec4_2 0x<hex sensor id>
  type=current
  current=<ampere>
}

sensor.basic
{
  device=elec4_3 0x<hex sensor id>
  type=current
  current=<ampere>
}

sensor.basic
{
  device=elec4 0x<hex sensor id>
  type=total
  current=<kilowatt>
  units=kw
}

sensor.basic
{
  device=elec4 0x<hex sensor id>
  type=battery
  current=0-100
}


*)

const
  // Type
  CURRENTENERGY  = $5B;

  // Subtype
  ELEC4  = $01;

var
  SubTypeArray : array[1..1] of TRFXSubTypeRec =
    ((SubType : ELEC4; SubTypeString : 'elec4'));

procedure RFX2xPL(Buffer : BytesArray; xPLMessages : TxPLRFXMessages);
var
  SubType : Byte;
  DeviceID : String;
  DeviceID1, DeviceID2, DeviceID3 : String;
  Ampere1, Ampere2, Ampere3 : Extended;
  TempTotal : Int64;
  Total : Extended;
  BatteryLevel : Integer;
  xPLMessage : TxPLMessage;
begin
  SubType := Buffer[2];
  DeviceID := GetSubTypeString(SubType,SubTypeArray)+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2);
  DeviceID1 := GetSubTypeString(SubType,SubTypeArray)+'_1'+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2);
  DeviceID2 := GetSubTypeString(SubType,SubTypeArray)+'_2'+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2);
  DeviceID3 := GetSubTypeString(SubType,SubTypeArray)+'_3'+IntToHex(Buffer[4],2)+IntToHex(Buffer[5],2);
  Ampere1 := ((Buffer[7] shl 8) + Buffer[8]) / 10;
  Ampere2 := ((Buffer[9] shl 8) + Buffer[10]) / 10;
  Ampere3 := ((Buffer[11] shl 8) + Buffer[12]) / 10;
  if Buffer[6] = 0 then  // Only total when count = 0
    begin
      TempTotal := Buffer[16];
      TempTotal := TempTotal+(Buffer[15] shl 8);
      TempTotal := TempTotal+(Buffer[14] shl 16);
      TempTotal := TempTotal+(Buffer[13] shl 24);
      TempTotal := TempTotal+(Int64(Buffer[12]) shl 32);
      TempTotal := TempTotal+(Int64(Buffer[11]) shl 40);
      Total := TempTotal / 223.666;
    end;
  if (Buffer[19] and $0F) = 0 then  // zero out rssi
    BatteryLevel := 0
  else
    BatteryLevel := 100;

  // Create sensor.basic messages
  xPLMessage := TxPLMessage.Create(nil);
  xPLMessage.schema.RawxPL := 'sensor.basic';
  xPLMessage.MessageType := trig;
  xPLMessage.source.RawxPL := XPLSOURCE;
  xPLMessage.target.IsGeneric := True;
  xPLMessage.Body.AddKeyValue('device='+DeviceID1);
  xPLMessage.Body.AddKeyValue('current='+FloatToStr(Ampere1));
  xPLMessage.Body.AddKeyValue('type=current');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;

  xPLMessage := TxPLMessage.Create(nil);
  xPLMessage.schema.RawxPL := 'sensor.basic';
  xPLMessage.MessageType := trig;
  xPLMessage.source.RawxPL := XPLSOURCE;
  xPLMessage.target.IsGeneric := True;
  xPLMessage.Body.AddKeyValue('device='+DeviceID2);
  xPLMessage.Body.AddKeyValue('current='+FloatToStr(Ampere2));
  xPLMessage.Body.AddKeyValue('type=current');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;

  xPLMessage := TxPLMessage.Create(nil);
  xPLMessage.schema.RawxPL := 'sensor.basic';
  xPLMessage.MessageType := trig;
  xPLMessage.source.RawxPL := XPLSOURCE;
  xPLMessage.target.IsGeneric := True;
  xPLMessage.Body.AddKeyValue('device='+DeviceID3);
  xPLMessage.Body.AddKeyValue('current='+FloatToStr(Ampere3));
  xPLMessage.Body.AddKeyValue('type=current');
  xPLMessages.Add(xPLMessage.RawXPL);
  xPLMessage.Free;

  if Buffer[6] = 0 then  // Only total when count = 0
    begin
      xPLMessage := TxPLMessage.Create(nil);
      xPLMessage.schema.RawxPL := 'sensor.basic';
      xPLMessage.MessageType := trig;
      xPLMessage.source.RawxPL := XPLSOURCE;
      xPLMessage.target.IsGeneric := True;
      xPLMessage.Body.AddKeyValue('device='+DeviceID);
      xPLMessage.Body.AddKeyValue('current='+FloatToStrF(Total,ffGeneral,2,20));

      // TO CHECK : how to get the rounding correct in the formatting of Total

      xPLMessage.Body.AddKeyValue('type=total');
      xPLMessage.Body.AddKeyValue('units=kw');
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
