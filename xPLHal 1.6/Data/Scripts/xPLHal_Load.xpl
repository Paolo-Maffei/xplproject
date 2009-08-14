' xPLHal Load

Sub xPLHal_Load()


	' flag xplhal load 
	sys.value("Loaded") = now
	
	' set current period from globals
	sys.setting("Period")=sys.value("Period")

	' set current mode from globals
	sys.setting("Mode")=sys.value("Mode")

	' request actual current period
	mymsg="command=status" & chr(10) & "Query=DAWNDUSK"
	call xpl.sendmsg("XPL-CMND","TONYT-DAWNDUSK.DAWNDUSK","DAWNDUSK.REQUEST",mymsg)

	' load timed events
	call sys.recurringevent("00:01","23:59",15,0,"YYYYYYY","SAVESYSTEM","","XPLHALBACKUP",True)

	' initialise xplhal settings
	if sys.value("XPLHAL")=True then 
		call xPLHal_PowerFail()
	else
		sys.value("XPLHAL")=True	
	end if
	
End Sub

sub SaveSystem()

	' save globals
	call sys.saveglobals()

	' save x10 cache
	call x10.save()

	' save events
	call sys.saveevents()

End Sub

sub xPLHal_PowerFail()


end sub

