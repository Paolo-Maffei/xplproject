unit fpc_delphi_compat;

{Unit with functions and classes not found in Delphi}

interface

uses {$ifdef fpc}
     fpTimer
     {$else}
     ExtCtrls
     {$endif}
    ;

function BuildDate  : string;
function GetDevice  : string;
function GetVendor  : string;
function GetVersion : string;
function GetProductName : string;

type TxPLTimer = class( {$ifdef fpc}TfpTimer {$else}TTimer {$endif});

implementation // =============================================================
Uses Classes
     , SysUtils
     {$ifdef fpc}
     , vInfo
     {$else}
     , JvVersionInfo
     , jclPEImage
     {$endif}
     ;

var VersionInfo : {$ifdef fpc}TVersionInfo{$else}TJvVersionInfo{$endif};

// ============================================================================
function BuildDate: string;
begin
   result :=
   {$ifdef fpc}
      {$I %date%};
   {$else}
      DateToStr(PeReadLinkerTimeStamp(ParamStr(0)));
   {$endif}
end;

function GetDevice: string;
begin
   result := VersionInfo.InternalName;
end;

function GetVendor: string;
begin
   result := VersionInfo.CompanyName;
end;

function GetVersion: string;
begin
   result := VersionInfo.FileVersion;
end;

function GetProductName : string;
begin
   result := VersionInfo.ProductName;
end;

initialization
   {$ifdef fpc}
      VersionInfo := TVersionInfo.Create;
   {$else}
      VersionInfo := TJvVersionInfo.Create(ParamStr(0));
   {$endif}

finalization
   VersionInfo.Free;

end.
