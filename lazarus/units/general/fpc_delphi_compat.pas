unit fpc_delphi_compat;

{Unit holding behaviour differences between fpc and delphi}

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
    function GetCommonAppDataPath : string;

type TxPLTimer = class( {$ifdef fpc}TfpTimer {$else}TTimer {$endif});
     {$ifndef fpc}                                                              // This is declared only for delphi versions
        TEventType = (etCustom,etInfo,etWarning,etError,etDebug);
     {$endif}

implementation // ==============================================================
Uses Classes
     , SysUtils
     , StrUtils
     {$ifdef fpc}
        , vInfo
        , LSUtils
        {$ifdef mswindows}
           , Windirs
        {$endif}
     {$else}
     , JvVersionInfo
     , jclPEImage
     , SHFolder
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
   Assert(length(result)>0,'InternalName in Version Info is missing');
end;

function GetVendor: string;
begin
   result := VersionInfo.CompanyName;
   Assert(length(result)>0,'CompanyName in Version Info is missing');
end;

function GetVersion: string;
begin
   result := VersionInfo.FileVersion;
   Assert(length(result)>0,'FileVersion in Version Info is missing');
end;

function GetProductName : string;
begin
   result := VersionInfo.ProductName;
   Assert(length(result)>0,'ProductName in Version Info is missing');
end;

function GetMacAddress: string;
begin
   result := {$ifdef fpc}
                AnsiLowerCase(AnsiReplaceStr(LSGetMacAddress,'-',''));
             {$else}
                '00abcdef';
                // Missing code to define for delphi environment
             {$endif}
end;

function GetCommonAppDataPath : string;
{$ifndef fpc}
var path : array[0..255] of Char;
{$endif}
begin
   {$ifdef fpc}
      {$ifdef mswindows}
      result := GetWindowsSpecialDir(CSIDL_COMMON_APPDATA);
      {$else}
      result := GetAppConfigDir(false);
      result := LeftStr(result,length(result)-length(ApplicationName)-1);
      {$endif}
   {$else}
      SHGetFolderPath(0,CSIDL_COMMON_APPDATA,0,SHGFP_TYPE_CURRENT,@path[0]);
      result := IncludeTrailingPathDelimiter(path);
   {$endif}
end;

initialization // =============================================================
   VersionInfo := {$ifdef fpc}
                     TVersionInfo.Create;
                  {$else}
                     TJvVersionInfo.Create(ParamStr(0));
                  {$endif}

finalization // ===============================================================
   VersionInfo.Free;

end.
