' xPLHal Unload

Sub xPLHal_UnLoad()

	' flag xplhal unload 
	sys.value("UnLoaded") = now
	
	' safely closed
	sys.value("XPLHAL")=False

End Sub

