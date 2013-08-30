(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit uxPLRFXConst;

interface

const
  XPLSOURCE = 'xplrfx';

  x10_DESCRIPTION = '0x10 - ARC, ELRO, Waveman, EMW200, IMPULS, RisingSun, Philips, Energenie 18';
  x11_DESCRIPTION = '0x11 - AC, HomeEasy EU, ANSLUT';
  x12_DESCRIPTION = '0x12 - Koppla';
  x13_DESCRIPTION = '0x13 - PT2262';
  x14_DESCRIPTION = '0x14 - LightwaveRF, Siemens, EMW100, BBSB, MDREMOTE, RSL2';
  x15_DESCRIPTION = '0x15 - Blyss';
  x18_DESCRIPTION = '0x18 - Harrison';
  x19_DESCRIPTION = '0x19 - RollerTrol, Hasta, A-OK, Raex, Media Mount';
  x20_DESCRIPTION = '0x20 - X10, KD101, Visonic, Meiantech';
  x28_DESCRIPTION = '0x28 - X10 Ninja/Robocam';
  x30_DESCRIPTION = '0x30 - ATI, Medion, PC Remote';
  x40_DESCRIPTION = '0x40 - Digimax';
  x41_DESCRIPTION = '0x41 - HomeEasy HE105, RTS10';
  x42_DESCRIPTION = '0x42 - Mertik-Maxitrol G6R-H4T1 / G6R-H4TB';
  x50_DESCRIPTION = '0x50 - Temperature Sensors';
  x51_DESCRIPTION = '0x51 - Humidity sensors';
  x52_DESCRIPTION = '0x52 - Temperature and humidity sensors';
  x53_DESCRIPTION = '0x53 - Barometric sensors';
  x54_DESCRIPTION = '0x54 - Temperature, humidity and barometric sensors';
  x55_DESCRIPTION = '0x55 - Rain Sensors';
  x56_DESCRIPTION = '0x56 - Wind Sensors ';
  x57_DESCRIPTION = '0x57 - UV Sensors';
  x58_DESCRIPTION = '0x58 - Date and Time';
  x59_DESCRIPTION = '0x59 - Current Sensors';
  x5A_DESCRIPTION = '0x5A - Energy Usage Sensors';
  x5B_DESCRIPTION = '0x5B - Current + Energy Sensors';
  x5D_DESCRIPTION = '0x5D - Weighting Scale';
  x70_DESCRIPTION = '0x70 - RFXsensor';
  x71_DESCRIPTION = '0x71 - RFXMeter';
  x72_DESCRIPTION = '0x72 - FS20';


type
  BytesArray = array[0..39] of Byte;    // Must be static array, not dynamic !!

  TRFXCommandRec = record
    RFXCode    : Byte;
    xPLCommand : String;
  end;

  TRFXSubTypeRec = record
    SubType       : Byte;
    SubTypeString : String;
  end;

  TRFXCommandArray = array of TRFXCommandRec;

function GetRFXCode(xPLCommand : String; const RFXCommandArray : array of TRFXCommandRec) : Byte;
function GetxPLCommand(RFXCode : Byte; const RFXCommandArray : array of TRFXCommandRec) : String;
function GetSubTypeString(ST : Byte; const RFXSubTypeArray : array of TRFXSubTypeRec) : String;
function GetSubTypeFromString(Str : String; const RFXSubTypeArray : array of TRFXSubTypeRec) : Byte;
function HexToBytes(Str : String) : BytesArray;
function BytesArrayToStr(Buffer : BytesArray) : String;
procedure OpenLog;
procedure CloseLog;
procedure Log(const Str : String);
procedure ResetBuffer(var Buffer : BytesArray);

implementation

Uses SysUtils;

var
  F : TextFile;

function GetxPLCommand(RFXCode : Byte; const RFXCommandArray : array of TRFXCommandRec) : String;
var
  i : Integer;
begin
  // By default, return empty string
  Result := '';
  // Go through the table, and find the RFXCode
  for i := Low(RFXCommandArray) to High(RFXCommandArray) do
    if RFXCommandArray[i].RFXCode = RFXCode then
      begin
        Result := RFXCommandArray[i].xPLCommand;
        Break;
      end;
end;

function GetRFXCode(xPLCommand : String; const RFXCommandArray : array of TRFXCommandRec) : Byte;
var
  i : Integer;
begin
  // By default, return error code
  Result := $FF;
  // Go through the table, and find the xPLCommand
  for i := Low(RFXCommandArray) to High(RFXCommandArray) do
    if CompareText(RFXCommandArray[i].xPLCommand, xPLCommand) = 0 then
      begin
        Result := RFXCommandArray[i].RFXCode;
        Break;
      end;
end;

function GetSubTypeString(ST : Byte; const RFXSubTypeArray : array of TRFXSubTypeRec) : String;
var
  i : Integer;
begin
  // By default, return empty string
  Result := '';
  // Go through the table, and find the RFXCode
  for i := Low(RFXSubTypeArray) to High(RFXSubTypeArray) do
    if RFXSubTypeArray[i].SubType = ST then
      begin
        Result := RFXSubTypeArray[i].SubTypeString;
        Break;
      end;
end;

function GetSubTypeFromString(Str : String; const RFXSubtypeArray : array of TRFXSubTypeRec) : Byte;
var
  i : Integer;
begin
  Result := $FF;
  for i := Low(RFXSubTypeArray) to High(RFXSubTypeArray) do
    if CompareText(RFXSubTypeArray[i].SubTypeString, Str) = 0 then
      begin
        Result := RFXSubTypeArray[i].SubType;
        Break;
      end;
end;

function HexToBytes(Str : String) : BytesArray;
var
  i : Integer;
  SubStr : String;
begin
  //SetLength(Result,Length(Str) div 2);
  ResetBuffer(Result);
  for i := 0 to (Length(Str) div 2)-1 do
    begin
      SubStr := Copy(Str,1,2);
      Str := Copy(Str,3,Length(Str));
      Result[i] := StrToInt('$'+SubStr);
    end;
end;

function BytesArrayToStr(Buffer : BytesArray) : String;
var
  i : Integer;
begin
  for i := 0 to Length(Buffer)-1 do
    Result := Result + IntToHex(Buffer[i],2);
end;

procedure OpenLog;
begin
  AssignFile(F,ExtractFilePath(ParamStr(0))+'xPLRFX.log');
  Rewrite(F);
end;

procedure CloseLog;
begin
  CloseFile(F);
end;

procedure Log(const Str : String);
begin
  Writeln(F,Str);
end;

procedure ResetBuffer(var Buffer : BytesArray);
var
  i : Integer;
begin
  // Set all bytes to 0
  for i := Low(Buffer) to High(Buffer) do
    Buffer[i] := $00;
end;

end.
