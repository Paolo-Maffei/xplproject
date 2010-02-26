dim message
dim target
dim objArgs
Dim WshShell

' Message to be shown
message = "When the build is complete the 'KeyPath' must be removed from the MergeModule before it can " & _
		"be used. If you don't, then everytime the application (that uses this mergemodule) is being " & _
		"started, the windows installer popsup and starts a repair action (based upon the 'KeyPath'). " & _
		"To remove the KeyPath, edit the final .msm file in Orca (Orca is a tool thats available in " & _
		"Windows SDK, free download from Microsoft)." & vbcrlf & _
		"  - Open the .MSM file with Orca" & vbcrlf & _
		"  - On the left hand side click the table 'Component'" & vbcrlf & _
		"  - On the right hand side, the table will now show a single row, " & vbcrlf & _
		"    with one column named 'KeyPath'" & vbcrlf & _
		"  - Select the row, and edit the value under 'KeyPath', remove" & vbcrlf & _
		"    the value (empty)" & vbcrlf & _
		"  - Save the file and exit." & vbcrlf & _
		"After this update the .MSM merge module is ready for distribution. Follow the instructions in the readme " & _
		"file on how to integrate the merge module into your application." & vbcrlf &  vbcrlf & vbcrlf & _
		"Click Ok to open the Merge Module in Orca (the Orca application MUST be installed for this to work)"

' Get commandline arguments
Set objArgs = WScript.Arguments
if objArgs.count=1 then
	' only execute if there is exactly 1 argument
	target = objArgs(0)

	' Display message
	result = MsgBox (message, vbOkOnly + vbInformation, "Manual action required...")

	' Start target
	Set WshShell = WScript.CreateObject("WScript.Shell")
    WshShell.Run """" & target & """"

end if


