unit uIPutils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


Const K_IP_GENERAL_BROADCAST : string = '255.255.255.255';

//function LocalIP: string;
//function LocalIPs : TStringList;
function MakeBroadCast(aAddress : string) : string;


implementation
uses      {$IFDEF UNIX} inet, sockets, {$ENDIF}
          {$IFDEF WINDOWS} winsock,    {$ENDIF}
          cStrings;

{function LocalIPs : TStringList;
begin
     Result := TStringList.Create;
     Result.Delimiter:= ',';
     Result.DelimitedText:= LocalIP;
end;}

{function LocalIP: string;
type
   TaPInAddr = array [0..10] of PInAddr;
   PaPInAddr = ^TaPInAddr;
var
    phe: PHostEnt;
    pptr: PaPInAddr;
    Buffer: array [0..63] of char;
    i: Integer;
    GInitData: TWSADATA;

begin
    WSAStartup($101, GInitData);
    Result := '';
    GetHostName(Buffer, SizeOf(Buffer));
    phe :=GetHostByName(buffer);
    if phe = nil then Exit;
    pptr := PaPInAddr(Phe^.h_addr_list);
    i := 0;
    while pptr^[i] <> nil do
    begin
      result += StrPas(inet_ntoa(pptr^[i]^)) + ',';
      Inc(i);
    end;
    setlength(result,length(result)-1);         // cut last trailing ','
    WSACleanup;
end;}

function MakeBroadCast(aAddress : string) : string;   // transforms a.b.c.d in a.b.c.255
var pos : integer;
begin
   pos := PosCharRev('.', aAddress);
   result := CopyLeft(aAddress,pos);
   result += '255';
end;

end.

