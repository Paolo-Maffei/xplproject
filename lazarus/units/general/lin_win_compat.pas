unit lin_win_compat;
{Unit holding behaviour differences between linux and windows}


{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     ;

   procedure GetProxySettings(out bEnabled : boolean; out sServer : string);
   procedure SystemLog (const EventType : TEventType; const Msg : String);
   function  IPAddresses : TStringList;

implementation // =============================================================
uses fpc_delphi_compat
     {$ifndef fpc}
     , windows                                                                 // Needed on delphi to define KEY_READ
     {$endif}
     {$ifdef unix}
     , IdSysLog
     , IdSysLogMessage
     , Process
     , StrUtils
     {$else}
     , EventLog
     , Registry
     , IdStack
     {$endif}
     ;

var  {$ifdef unix}
        fIdSysLog: TIdSysLog;
        fIdSysLogMessage : TIdSysLogMessage;
     {$else}
        fEventLog : TEventLog;
     {$endif}

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
procedure SystemLog (const EventType : TEventType; const Msg : String);
begin
{$ifdef unix}
   fIdSysLogMessage.Msg.Text := GetDevice + ':' + Msg;
   Case EventType of
        etInfo    : fIdSysLogMessage.Severity := slInformational;
        etWarning : fIdSysLogMessage.Severity := slWarning;
        etError   : fIdSysLogMessage.Severity := slError;
   end;
   fIdSysLog.SendLogMessage(fIdSysLogMessage);
{$else}
   fEventLog.Log(EventType,Msg);
{$endif}
end;

{$ifdef mswindows}
{$R C:/pp/packages/fcl-base/src/win/fclel.res}                                 // Load resource strings for windows event log
{$endif}

// ============================================================================
function IPAddresses : TStringList;
{$ifndef mswindows}
var proc : TProcess;
    slOutput : TStringList;
    start : integer;
    s : string;
{$endif}
begin
{$ifdef mswindows}
   TIdStack.IncUsage;
   result := TStringList(GStack.LocalAddresses);
{$else}
   proc := TProcess.Create(nil);
   try
      slOutput := TStringList.Create;
      result   := TStringList.Create;
      try
         proc.CommandLine := 'ifconfig';
         proc.Options := proc.Options + [poWaitOnExit, poUsePipes, poNoConsole,poStderrToOutput];
         proc.Execute;
         slOutput.LoadFromStream(proc.Output);
         for s in slOutput do begin
             Start := Pos('inet adr',s);
             if Start<>0 then begin
                s := AnsiRightStr(s,Length(s)-(Start+8));
                Start := Pos(' ',s);
                s := AnsiLeftStr(s,Pred(Start));
                Result.Add(s);
             end;
         end;
      finally
         FreeAndNil(slOutput);
      end;
   finally
      FreeAndNil(proc);
   end;
{$endif}
   if result.Count = 0 then result.Add('127.0.0.1');
end;

initialization // =============================================================
{$ifdef unix}
   fIdSysLog := nil;
   fIdSysLog := TIdSysLog.Create(nil);
   fIdSysLog.Port := 514;
   fIdSysLog.Host := '127.0.0.1';
   fIdSysLog.Active := True;
   fIdSysLogMessage := TIdSysLogMessage.Create(nil);
{$else}
   fEventLog := TEventLog.Create(nil);
   fEventLog.DefaultEventType:=etInfo;
   fEventLog.LogType:=ltSystem;
   fEventLog.Identification := GetProductName;
   fEventLog.Active:=true;
   fEventlog.RegisterMessageFile('');
{$endif}

finalization
{$ifdef unix}
   fIdSysLogMessage.Free;
   fIdSysLog.Free;
{$else}
   fEventLog.Free;
{$endif}

end.
