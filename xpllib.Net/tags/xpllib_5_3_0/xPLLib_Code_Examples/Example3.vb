Imports xPL             ' import xPL namespace for quick access
Imports xPL.xPL_Base    ' import the base to, provides numerous constants and support functions

Module Example3
    Const APPVERSION As String = "1.2.3"      ' will be used to store in the state string
    Dim dev1 As xPLDevice

    Friend Sub Example3()
        dev1 = New xPLDevice
        dev1.VendorID = "tieske"
        dev1.DeviceID = "example3"

        MsgBox("We'll be setting up a device add some stuff and then destroy it and restore it back to its previous state.")

        ' creating an optional item with 1 value
        dev1.ConfigItems.Add("extra1", "default value", xPLConfigTypes.xOption, 1)

        ' alternative method; first create a configitem, then add it. Optional item with 16 values
        Dim ci As New xPLConfigItem("extra2", xPLConfigTypes.xOption, 16)
        ci.Add("value1")
        ci.Add("value2")
        ci.Add("value3")
        dev1.ConfigItems.Add(ci)
        dev1.VersionNumber = "some version number  <=  this will not be restored froma a state!!"

        ' just enable it to go online
        dev1.Enable()

        MsgBox("Created a new device named '" & dev1.Address & "'. Please check your logger app to see it and use a configurator to configure the device. Click OK when ready to continue, we;ll be entering custom data to add to the device.")

        Dim cust As String
        cust = InputBox("Enter value for the 'CustomID' property of your device", "xPL demo", "default CustomID value")
        dev1.CustomID = cust
        cust = InputBox("Enter value for the 'CustomSettings' property of your device", "xPL demo", "default CustomSettings value")
        dev1.CustomSettings = cust

        MsgBox("You provided the following values; " & vbCrLf & "CustomID:  " & dev1.CustomID & vbCrLf & "CustomSettings:  " & dev1.CustomSettings & vbCrLf & _
               vbCrLf & "Click OK to 1) retrieve the device 'state', 2) destroy the device, 3) restore it from the state" & vbCrLf & _
               "(btw: we'll be using '" & APPVERSION & "' as the version of this application.)" & vbCrLf & vbCrLf & _
               "The property 'VersionNumber' will NOT be restored, it will default to the assembly version" & vbCrLf & _
               "       VersionNumber = '" & dev1.VersionNumber & "'")

        ' now get the state from the device
        Dim state As String
        state = dev1.GetState(APPVERSION)
        ' and kill it....
        dev1.Dispose()
        dev1 = Nothing

        MsgBox("All that's left of your device is this: " & vbCrLf & vbCrLf & state)
        Dim e As Boolean

        e = MsgBox("When restoring, we need to check application versions that created the 'state', so we know what to expect in the different settings." & vbCrLf & _
        "          xPLLib version: " & xPL_Base.StatexPLLibVersion(state) & " (xPLLib will handle this one)" & vbCrLf & _
        "          Application version: " & xPL_Base.StateAppVersion(state) & " (this is what the application needs to handle)" & vbCrLf & vbCrLf & _
        "Now let's restore it back into an xPL device. Do you want the 'Enabled' property to be restored as well? (clicking 'NO' will leave the device restored, but not enabled (so offline).", MsgBoxStyle.YesNo) = MsgBoxResult.Yes

        ' restore the device
        dev1 = New xPLDevice(state, e)

        If dev1.Enabled Then
            MsgBox("Your device was restored and is enabled, you should see it in your logger.")
        Else
            MsgBox("Restored it, but not enabled. Click OK to enable it")
            dev1.Enable()
            MsgBox("Enabled it, check your logger!")
        End If

        MsgBox("So the device was restored, you can check that the configuration of tthe device has been restored exactly like it was before " & _
               "as you can see from the following data:" & vbCrLf & _
               "     CustomID:  " & dev1.CustomID & vbCrLf & _
               "     CustomSettings:  " & dev1.CustomSettings & vbCrLf & vbCrLf & _
               "EXCEPT for:" & vbCrLf & _
               "     VersionNumber:  " & dev1.VersionNumber)


        ' Check versions
        If xPL_Base.StateAppVersion(state) = APPVERSION Then
            MsgBox("The restored device was created by the same application version that restored it, so there are no upgrade actions to be taken")

        Else
            ' this piece of code will not be touched in this example, just here to show how to deal with it
            MsgBox("The versions differ!! if you changed stuff, extra ConfigItems, other values in the CustomID or CustomSettings, then this is the place to do some 'upgrade' actions")

        End If
        MsgBox("What's the difference between the 'Application Version' stored in the State and the 'VersionNumber' property of a device?" & vbCrLf & _
                "Because applications can have multiple devices, they do not need to have the same version. The device 'VersionNumber' property " & vbCrLf & _
                "will default to the assembly version of the main application (even after restoring from a state).")

        MsgBox("Done with the example, lets cleanup and exit, click OK")

        ' cleanup, disposing will sent a proper end message
        dev1.Dispose()
        dev1 = Nothing
    End Sub



End Module
