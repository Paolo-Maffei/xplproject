unit lin_win_compat;
{Unit holding behaviour differences between linux and windows}


{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses SysUtils;

   procedure GetProxySettings(out bEnabled : boolean; out sServer : string);
   procedure SystemLog (const EventType : TEventType; const Msg : String);

implementation // =============================================================
uses Registry
     , Classes
     , fpc_delphi_compat
     {$ifndef fpc}
     , windows                                                                 // Needed on delphi to define KEY_READ
     {$endif}
     {$ifdef unix}
     , IdSysLog
     , IdSysLogMessage
     {$else}
     , EventLog
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
           if Pos('.',s)<>0 then fProxyServer := s;                            // Quick & dirty way to extract server ip & port
       sl.free;
       bEnabled := (fProxyServer<>'');
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
