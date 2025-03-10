unit fpc_delphi_compat;

{Unit holding behaviour differences between fpc and delphi}
{$i xpl.inc}

interface

uses {$ifdef fpc}
        vInfo,
        {$ifdef mswindows}
        fpTimer
        {$else}
        fpTimer13012
        {$endif}
     {$else}
     ExtCtrls,
     JvVersionInfo
     {$endif}
    ;

    function BuildDate  : string;
    function GetDevice  : string;
    function GetVendor  : string;
    function GetVersion : string;
    function GetProductName : string;
    function GetMacAddress : string;
    function GetCommonAppDataPath : string;
    function HostName : string;

type {$ifdef fpc}
        TxPLTimer = class(TFPTimer);
        TxPLVersionInfo = class(TVersionInfo);
     {$else}                                                              // This is declared only for delphi versions
        TxPLTimer = class(TTimer);
        TEventType = (etCustom,etInfo,etWarning,etError,etDebug);
        TxPLVersionInfo = class(TJvVersionInfo);
     {$endif}

var VersionInfo        : TxPLVersionInfo;

implementation // ==============================================================
Uses Classes
     , SysUtils
     , lin_win_compat
     , StrUtils
     , uIP
     {$ifdef mswindows}
     , IdStack
     {$else}
     , Unix
     {$endif}
     {$ifdef fpc}
        {$ifdef mswindows}
           , Windirs
           , DynLibs
        {$endif}
     {$else}
     , jclPEImage
     , SHFolder
     {$endif}
     ;

// ============================================================================
function HostName : string;
begin
   {$ifdef mswindows}
   TIdStack.IncUsage;
   try
       Result := GStack.HostName;
   finally
       TIdStack.DecUsage;
   end;
   {$else}
   Result := GetHostName;
   {$endif}
   Result := AnsiLowerCase(Result);
end;

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
   if LocalIPAddresses.Count = 0 then Raise Exception.Create('No network card detected');
   Result := AnsiLowerCase(AnsiReplaceStr(LocalIPAddresses.Items[0].HWAddr,':',''));
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
      {$endif}
   {$else}
      SHGetFolderPath(0,CSIDL_COMMON_APPDATA,0,SHGFP_TYPE_CURRENT,@path[0]);
      result := IncludeTrailingPathDelimiter(path);
   {$endif}
end;

initialization // =============================================================
   VersionInfo := TxPLVersionInfo.Create{$ifndef fpc}(ParamStr(0)){$endif};

finalization // ===============================================================
   VersionInfo.Free;

end.
