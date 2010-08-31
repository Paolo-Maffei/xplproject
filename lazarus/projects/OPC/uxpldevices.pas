unit uxpldevices;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TDeviceRecord }

  TDeviceRecord = class
     fDeviceName : string;
     interval   : integer;
     expires    : TDateTime;
     suspended  : char;
     configtype : char;
     configdone : char;
     waiting    : char;
     config_current: string;
     config_list   : string;
  end;


implementation //========================================================================


end.

