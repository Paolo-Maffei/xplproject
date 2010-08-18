Imports xPL             ' import xPL namespace for quick access
Imports xPL.xPL_Base    ' import the base to, provides numerous constants and support functions

Module Example1
    Dim dev1 As xPLDevice
    Dim dev2 As xPLDevice
    Dim dev3 As xPLDevice

    Friend Sub Example1()
        dev1 = New xPLDevice
        dev2 = New xPLDevice
        dev3 = New xPLDevice

        MsgBox("We'll be creating some simple xPL devices, with different names, please start your xPL logger")
        ' don't set anything, just enable it to go online
        dev1.Enable()
        MsgBox("First device was created using a randomized InstanceID, this is the default setting." & vbCrLf & _
               "xPL address: " & dev1.Address & vbCrLf & vbCrLf & "The following device will get a specifically set Vendor and Device ID, and a Instance ID based on the host computers name.")
        ' the second one, set the ID's and make it hostname based
        dev2.VendorID = "tieske"
        dev2.DeviceID = "testapp"
        dev2.InstanceIDType = InstanceCreation.HostNameBased
        dev2.Enable()
        MsgBox("Check your logger, you now have added: " & dev2.Address & vbCrLf & vbCrLf & "The next one will show how to create a device with a specifically set InstanceID")
        ' this time also set the instance id
        dev3.VendorID = "tieske"
        dev3.DeviceID = "testapp"
        dev3.InstanceID = "totallymine"
        dev3.Enable()
        MsgBox("The last one (" & dev3.Address & ") has been created. The example has finished, click OK to clean up.")

        ' cleanup, disposing will sent a proper end message
        dev1.Dispose()
        dev2.Dispose()
        dev3.Dispose()

        dev1 = Nothing
        dev2 = Nothing
        dev3 = Nothing

        MsgBox("Devices have been cleaned up.")
    End Sub
End Module
