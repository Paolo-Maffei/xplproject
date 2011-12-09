unit app_basic_settings_common;

{$mode objfpc}{$H+}

interface

const K_ALL_IPS_JOCKER       = '*** ALL IP Addresses ***';
      COMMENT_LINE           = 'Your network settings have been saved.'#10#13+
                               #10#13'Note that your computer should use a fixed IP Address'#10#13;
      K_IP_GENERAL_BROADCAST : string = '255.255.255.255';

function MakeBroadCast(const aAddress : string) : string;                      // transforms a.b.c.d in a.b.c.255

implementation
uses SysUtils
     ;
//==============================================================================
function MakeBroadCast(const aAddress : string) : string;                      // transforms a.b.c.d in a.b.c.255
begin
   result := LeftStr(aAddress,LastDelimiter('.',aAddress)) + '255';
end;

end.

