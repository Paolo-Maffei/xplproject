unit uRegExTools;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, RegExpr;

const K_RE_FRENCH_PHONE = '\d\d \d\d \d\d \d\d \d\d';                              // French phone number, formatted : 01 02 03 04 05
      K_RE_IP_ADDRESS   = '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}';        // Simply formed IP v4 Address : 192.168.1.1
      K_RE_MAC_ADDRESS  = '([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])';  // Network card mac address
      K_RE_LATITUDE     = '([0-8][0-9]|[9][0])\.([0-9][0-9])\.([0-9][0-9])([NS]|[ns])';
      K_RE_LONGITUDE    = '([01][0-7]|[00][0-9][0-9]|[1][8][0])\.([0-9][0-9])\.([0-9][0-9])([EW]|[ew])';

var   RegExpEngine : TRegExpr;

implementation

initialization
   RegExpEngine := TRegExpr.Create;

finalization
   RegExpEngine.Free;

end.

