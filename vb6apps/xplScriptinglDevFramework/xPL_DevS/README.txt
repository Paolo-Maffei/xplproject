xPL App Title: xPLDevS

This is a VB6 based framework for developing xPL based applications

Requires xPL OCX

It also supports vb scripting

It uses a file in the application folder called script.xpl

It contains 2 subs

sub incoming(msg)
end sub

sub outgoing(msg)
end sub

Use standard vbscript commands and the following extensions:

xpl.GetParamCount(msg) 
returns count of parameters in body

xpl.GetParamName(msg,index)
returns name of param by index in body

xpl.GetParamValue(msg,index,trim)
returns value of param by index in body

xpl.GetParam(msg,param,trim)
returns value of param by param 
and also supports {Schema}, {msgtype}

xpl.SendMsg(msgtype,target,schema,msgbody)
sends an xpl message
e.g. 
msg="SPEECH=Hello World" & chr(10) & "VOICE=audrey"
xpl.sendmsg("xpl-cmnd","*","TTS.BASIC",msg)


