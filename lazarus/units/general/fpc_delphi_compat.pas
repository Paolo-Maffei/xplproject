unit fpc_delphi_compat;

{Unit holding behaviour differences between fpc and delphi}
{$mode delphi}

interface

uses {$ifdef fpc}
        vInfo,
        {$ifdef mswindows}
        fpTimer in 'C:/pp/packages/fcl-base/src/fptimer.pp'
        {$else}
        fpTimer in '/usr/share/fpcsrc/packages/fcl-base/src/fptimer.pp'
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

type {$ifdef fpc}
        TxPLTimer = class(TfpTimer);
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
     , u_xpl_common
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

function GetMacAddress: string;                                                // This code comes from LSUtils (lazsolutions)
const CLSUtilsFormatMACMask = '%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x';                // and have been extracted because original package
{$IFDEF MSWINDOWS}                                                             // implies uses of Windows, thus creating dependency
type                                                                           // on gui application
  TCreateGUIDFunction = function(AGUID: PGUID): LongInt; stdcall;
{$ENDIF}
var
  VGUID1, VGUID2: TGUID;
{$IFDEF MSWINDOWS}
  VLibHandle: TLibHandle;
  VCreateGUIDFunction: TCreateGUIDFunction;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  VLibHandle := LoadLibrary('rpcrt4.dll');
  try
    if VLibHandle <> NilHandle then
    begin
      VCreateGUIDFunction := TCreateGUIDFunction(GetProcedureAddress(VLibHandle,
        'UuidCreateSequential'));
      if Assigned(VCreateGUIDFunction) then
{$ENDIF}
        if (
{$IFDEF UNIX}
          CreateGUID
{$ENDIF}
{$IFDEF MSWINDOWS}
          VCreateGUIDFunction
{$ENDIF}
          ({$IFDEF MSWINDOWS}@{$ENDIF}VGUID1) = 0) and (
{$IFDEF UNIX}
          CreateGUID
{$ENDIF}
{$IFDEF MSWINDOWS}
          VCreateGUIDFunction
{$ENDIF}
          ({$IFDEF MSWINDOWS}@{$ENDIF}VGUID2) = 0) and
          (VGUID1.D4[2] = VGUID2.D4[2]) and (VGUID1.D4[3] = VGUID2.D4[3]) and
          (VGUID1.D4[4] = VGUID2.D4[4]) and (VGUID1.D4[5] = VGUID2.D4[5]) and
          (VGUID1.D4[6] = VGUID2.D4[6]) and (VGUID1.D4[7] = VGUID2.D4[7]) then
            Result := Format(CLSUtilsFormatMACMask, [VGUID1.D4[2], VGUID1.D4[3],
                        VGUID1.D4[4], VGUID1.D4[5], VGUID1.D4[6], VGUID1.D4[7]]);
{$IFDEF MSWINDOWS}
    end;
  finally
    UnloadLibrary(VLibHandle);
  end;
{$ENDIF}
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
{$ifdef fpc}
   OnGetVendorName      := @GetVendorNameEvent;                                // These functions are not known of Delphi and
   OnGetApplicationName := @GetApplicationEvent;                               // are present here for linux behaviour consistency
   VersionInfo          := TxPLVersionInfo.Create;
{$else}
   VersionInfo          := TxPLVersionInfo.Create(ParamStr(0));
{$endif}

finalization // ===============================================================
   VersionInfo.Free;

end.

