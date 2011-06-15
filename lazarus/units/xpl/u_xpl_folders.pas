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
{$mode objfpc}{$H+}

interface

uses Classes,
     SysUtils,
     u_xpl_address;

type // TxPLCustomFolders =====================================================
     TxPLCustomFolders  = class
     private
        fAdresse : TxPLAddress;
     public
        constructor Create(const axPLAddress : TxPLAddress);
        function SharedDir : string;                                           // Something like c:\programdata\xPL\
        function PluginDir : string;                                           // In the xPL root, directory where plugin are stored
        function DeviceDir(aVendor : string = ''; aDevice : string = '') : string; inline; // something like c:\programdata\xPL\vendor\appli\
     end;

implementation // ==============================================================

const K_XPL_SETTINGS_SUBDIR_PLUG   = 'Plugins';

  // ===========================================================================
procedure EnsureDirectoryExists(const aDirectoryName: string);
begin
   if not DirectoryExists(aDirectoryName) then
      CreateDir(aDirectoryName);
end;

// TxPLCustomFolders ===========================================================
constructor TxPLCustomFolders.Create(const axPLAddress: TxPLAddress);
begin
   inherited Create;
   fAdresse  := axPLAddress;
end;


function TxPLCustomFolders.SharedDir: string;
begin
   result := GetAppConfigDir(true);                                             // returns something like c:\program files\xPL\
   EnsureDirectoryExists( SharedDir );                                          // 1.1.1 Correction
end;

function TxPLCustomFolders.PluginDir: string;
begin
   result := SharedDir + K_XPL_SETTINGS_SUBDIR_PLUG + DirectorySeparator;       // returns something like c:\program files\xPL\Plugins\
   EnsureDirectoryExists( PluginDir );                                          // 1.1.1 Correction
end;

function TxPLCustomFolders.DeviceDir(aVendor : string = ''; aDevice : string = '') : string;
begin
   if aVendor = '' then aVendor := fAdresse.Vendor;
   if aDevice = '' then aDevice := fAdresse.Device;
   result := SharedDir + aVendor + DirectorySeparator;
   EnsureDirectoryExists(result);
   result := result + aDevice + DirectorySeparator;
   EnsureDirectoryExists( result );
end;

end.

