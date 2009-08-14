This is a DLL to send an xPL message

You need to register the xPL_ASP.dll using regsvr32

squtil.dll just needs to be placed in windows\system32 folder

A sample asp segment for use is:

<%
Set Objxplasp = Server.CreateObject("xPL_ASP.xPLASP")
objxplasp.send "xpl-cmnd","*","x10.basic","device=D11\ncommand=off"
Set objxplasp = Nothing
%>

The xPL message type will default to xpl-cmnd if ""
The xPL Target will default to * if ""
The xPL Schema will default to x10.basic if ""
The xPL Message must be at least 3 characters long

Use \n for line breaks in message body
To use \n in a message use \\n