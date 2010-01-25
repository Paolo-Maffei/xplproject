program PascalScript;

{ $ i xpl_ps_const.inc}

var EndOfScript : boolean;                                                      // End of program flag

function GlobalChanged( aValue : string; aOld : string; aNew : string) : integer;
var i : integer;
    s : string;
begin
   writeln('Changed ' + aValue);
   
   i := Pos('.sunrise',aValue); 
   if i>0 then begin
      writeln('sunrise trouve');
   end;
end;

procedure StartScript;
begin
   EndOfScript := False;
   writeln('Started');
   xpl.exists('clinique-weather.lapfr005.sunrise',true);
end;

procedure ScriptLoop;
begin
   repeat
   until EndOfScript;
end;

procedure Test;
begin
   writeln('test function launched');
   writeln('This does nothing');
end;

function StopScript : integer;
begin
  // xpl.sendmsg(xpl_mtCmnd,'*','log.basic','log=pascal script stopped');
  writeln('stopped');
end;

function xPLMessageArrived(aMessage : string) : longint;
begin
writeln('hello');

writeln(xpl.MessageKey(0) + '=' + xpl.MessageValue(0));
writeln(xpl.MessageSchema);
writeln(xpl.MessageValueFromKey('request'));
writeln(xpl.Msg_Class);
writeln(xpl.Msg_Sender_Device);
end;

// Main program ================================================================
begin
   StartScript;
   ScriptLoop;
   StopScript;
end.
