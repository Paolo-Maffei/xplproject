' shared x10 scripts

' send x10 xpl message
sub SendX10(devices, command, level)

	' build x10 xpl message
	if right(devices,1)<>"," then devices=devices+","
	strmsg=""
	while instr(devices,",")
		x=instr(devices,",")
		device=left(devices,x-1)		
		strmsg=strmsg+device+","
		devices=mid(devices,x+1)
	wend
	if strmsg="" then exit sub
	strmsg="Device="+left(strmsg,len(strmsg)-1)+chr(10)
	strmsg=strmsg+"Command="+ucase(command)+chr(10)

	' send x10 xpl message
	call xpl.sendmsg("","","X10.BASIC",strmsg)

end sub

