@echo off
c:\lazarus\fpc\2.2.2\bin\i386-win32\windres.exe --include c:\lazarus\fpc\2.2.2\bin\i386-win32\ -O res -o C:\lazarus\projects\Sender\xpl_sender.res xpl_sender.rc --preprocessor=c:\lazarus\fpc\2.2.2\bin\i386-win32\cpp.exe
if errorlevel 1 goto linkend
SET THEFILE=C:\lazarus\projects\Sender\xpl_sender.exe
echo Linking %THEFILE%
c:\lazarus\fpc\2.2.2\bin\i386-win32\ld.exe -b pe-i386 -m i386pe  --gc-sections   --subsystem windows --entry=_WinMainCRTStartup    -o C:\lazarus\projects\Sender\xpl_sender.exe C:\lazarus\projects\Sender\link.res
if errorlevel 1 goto linkend
c:\lazarus\fpc\2.2.2\bin\i386-win32\postw32.exe --subsystem gui --input C:\lazarus\projects\Sender\xpl_sender.exe --stack 262144
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occured while assembling %THEFILE%
goto end
:linkend
echo An error occured while linking %THEFILE%
:end
