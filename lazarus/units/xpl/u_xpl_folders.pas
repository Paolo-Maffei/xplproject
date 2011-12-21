unit u_xpl_folders;
{==============================================================================
  UnitDesc      = xPL Registry and Global Settings management unit
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : added GetSharedConfigDir function
 0.93 : modification on common xPL directory function for windows/linux compatibility
 0.95 : added configuration store directory
 Rev 256 : Transfer of strictly confined string constant from uxPLConst here
 }

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes,
     SysUtils,
     u_xpl_address;

type // TxPLFolders ===========================================================
     TxPLFolders  = class
     private
        fAdresse : TxPLAddress;
     public
        constructor Create(const axPLAddress : TxPLAddress);
        function SharedDir : string;                                           // Something like c:\programdata\xPL\
        function PluginDir : string;                                           // In the xPL root, directory where plugin are stored
        function DeviceDir(const aVendor : string = ''; const aDevice : string = '') : string;  // something like c:\programdata\xPL\vendor\appli\
     end;

implementation // =============================================================

uses fpc_delphi_compat
     , StrUtils
     ;

const K_XPL_SETTINGS_SUBDIR_PLUG   = 'Plugins';

// TxPLFolders ================================================================
constructor TxPLFolders.Create(const axPLAddress: TxPLAddress);
begin
   inherited Create;
   fAdresse := axPLAddress;
end;

function TxPLFolders.SharedDir: string;
begin
   result := IncludeTrailingPathDelimiter( GetCommonAppDataPath
                                         {$ifdef mswindows} + 'xPL' {$endif}
                                         );
   ForceDirectories(result);
end;

function TxPLFolders.PluginDir: string;                                  // returns something like c:\program data\xPL\Plugins\
begin
   result := IncludeTrailingPathDelimiter(SharedDir + K_XPL_SETTINGS_SUBDIR_PLUG);
   ForceDirectories(result);
end;

function TxPLFolders.DeviceDir(const aVendor : string = ''; const aDevice : string = '') : string;
begin
   result := IncludeTrailingPathDelimiter(SharedDir + IfThen(aVendor<>'',aVendor,fAdresse.Vendor));
   ForceDirectories(result);

   result := IncludeTrailingPathDelimiter(result + IfThen(aDevice<>'',aDevice,fAdresse.Device));
   ForceDirectories(result);
end;

end.

