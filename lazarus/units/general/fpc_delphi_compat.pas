unit fpc_delphi_compat;

{Unit older behaviour differences between fpc and delphi}

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
function GetMacAddress : string;

type TxPLTimer = class( {$ifdef fpc}TfpTimer {$else}TTimer {$endif});

implementation // =============================================================
Uses Classes
     , SysUtils
     , StrUtils
     {$ifdef fpc}
     , vInfo
     , LSUtils
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
   Assert(length(result)>0,'Version Info are missing');
end;

function GetVendor: string;
begin
   result := VersionInfo.CompanyName;
   Assert(length(result)>0,'Version Info are missing');
end;

function GetVersion: string;
begin
   result := VersionInfo.FileVersion;
   Assert(length(result)>0,'Version Info are missing');
end;

function GetProductName : string;
begin
   result := VersionInfo.ProductName;
   Assert(length(result)>0,'Version Info are missing');
end;

function GetMacAddress: string;
begin
   result := {$ifdef fpc}
                AnsiLowerCase(AnsiReplaceStr(LSGetMacAddress,'-',''));
             {$else}
                Assert(false,'Code missing for Delphi');
                // Missing code to define for delphi environment
             {$endif}
end;

initialization
   VersionInfo := {$ifdef fpc}
                     TVersionInfo.Create;
                  {$else}
                     VersionInfo := TJvVersionInfo.Create(ParamStr(0));
                  {$endif}

finalization
   VersionInfo.Free;

end.

