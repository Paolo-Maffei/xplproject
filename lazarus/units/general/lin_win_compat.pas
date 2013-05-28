unit lin_win_compat;
{Unit holding behaviour differences between linux and windows}


{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     ;

const K_IP_GENERAL_BROADCAST : string = '255.255.255.255';

   procedure GetProxySettings(out bEnabled : boolean; out sServer : string);
   procedure LogInSystem (const EventType : TEventType; const Msg : String);
   function GetMacAddress : string;

implementation // =============================================================
uses {$ifndef fpc}
     windows ,                                                                 // Needed on delphi to define KEY_READ
     {$endif}
     {$ifdef unix}
     SystemLog
     , Process
     , StrUtils
     {$else}
     EventLog
     , Registry
     , IdStack
     {$endif}
     , uIP
     ;

  {$ifndef unix}
var        fEventLog : TEventLog;
     {$endif}

// ============================================================================
function GetMacAddress : string;
{$ifndef mswindows}
var proc : TProcess;
    slOutput : TStringList;
    start : integer;
    s : string;
{$endif}
begin
   Result := '';
{$ifdef mswindows}
   // to define a suitable way to do it in windows
{$else}
   proc := TProcess.Create(nil);
   try
      slOutput := TStringList.Create;
      try
         proc.Executable := 'ifconfig';
         proc.Options := proc.Options + [poWaitOnExit, poUsePipes, poNoConsole,poStderrToOutput];
         proc.Execute;
         slOutput.LoadFromStream(proc.Output);
         for s in slOutput do begin
             Start := Pos('HWaddr',s);
             if Start<>0 then begin
                s := AnsiRightStr(s,Length(s)-(Start+6));
                Start := Pos(' ',s);
                s := AnsiLeftStr(s,Pred(Start));
                result := s;
             end;
         end;
      finally
         slOutput.Free;
      end;
   finally
      proc.Free;
   end;
{$endif}
end;

// ============================================================================
procedure GetProxySettings(out bEnabled: boolean; out sServer: string);
{$ifndef windows}
var sl : TStringList;
    s  : string;
{$endif}
begin
    sServer  := '';
    bEnabled := false;
    {$ifdef windows}
       with TRegistry.Create(KEY_READ) do begin
            RootKey := HKEY_CURRENT_USER;
            if OpenKey('\Software\Microsoft\Windows\CurrentVersion\Internet Settings',False) then begin
               bEnabled := (ReadInteger('ProxyEnable') = 1);
               sServer  := ReadString ('ProxyServer');
            end;
            free;
       end;
    {$else}
       sl := TStringList.Create;
       sl.Delimiter := '/';
       sl.DelimitedText := GetEnvironmentVariable('http_proxy');               // may have http://xx.xx.xx.xx:yy/ as input
       for s in sl do
           if Pos('.',s)<>0 then sServer := s;                                 // Quick & dirty way to extract server ip & port
       sl.free;
       bEnabled := (sServer<>'');
    {$endif}
end;

//=============================================================================
procedure LogInSystem (const EventType : TEventType; const Msg : String);
var logInfo : longint;
begin
{$ifdef unix}
   Case EventType of
        etCustom  : logInfo := LOG_NOTICE;
        etDebug   : logInfo := LOG_DEBUG;
        etInfo    : logInfo := LOG_INFO;
        etWarning : logInfo := LOG_WARNING;
        etError   : logInfo := LOG_ERR;
   end;
   syslog(loginfo,'%s',[pchar(Msg)]);
{$else}
   fEventLog.Log(EventType,Msg);
{$endif}
end;

{$ifdef mswindows}
{$R C:/pp/packages/fcl-base/src/win/fclel.res}                                 // Load resource strings for windows event log
{$endif}

initialization // =============================================================
{$ifdef mswindows}
   fEventLog := TEventLog.Create(nil);
   fEventLog.DefaultEventType:=etInfo;
   fEventLog.LogType:=ltSystem;
   fEventLog.Identification := GetProductName;
   fEventLog.Active:=true;
   fEventlog.RegisterMessageFile('');
{$endif}

finalization // ===============================================================

{$ifdef mswindows}
   fEventLog.Free;
{$endif}

end.