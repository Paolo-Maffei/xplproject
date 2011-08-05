Imports xPL             ' import xPL namespace for quick access
Imports xPL.xPL_Base    ' import the base to, provides numerous constants and support functions

Module Example2
    Dim WithEvents dev1 As xPLDevice

    Friend Sub Example2()
        dev1 = New xPLDevice
        dev1.VendorID = "tieske"
        dev1.DeviceID = "example2"

        MsgBox("We'll be creating some simple xPL devices, and make them configurable with some extra items. Also the event for configuration is used in this sample.")

        ' Add event for configuration and reconfiguration
        AddHandler dev1.xPLConfigDone, AddressOf ConfigHandler
        AddHandler dev1.xPLReConfigDone, AddressOf ConfigHandler

        ' creating an optional item with 1 value
        dev1.ConfigItems.Add("extra1", "default value", xPLConfigTypes.xOption, 1)

        ' alternative method; first create a configitem, then add it. Optional item with 16 values
        Dim ci As New xPLConfigItem("extra2", xPLConfigTypes.xOption, 16)
        ci.Add("value1")
        ci.Add("value2")
        ci.Add("value3")
        dev1.ConfigItems.Add(ci)

        ' just enable it to go online
        dev1.Enable()

        MsgBox("Created a new device named '" & dev1.Address & "'. Please check your logger app to see it and use a configurator to configure the device. Whether or not a device has been configured can be checked through the 'Configured' property.")


        ' now wait for user to configure device. This can be checked through the 'Configured' property
        Dim cancel As Boolean = False
        Dim t As Date
        While Not cancel
            ' wait for 5 seconds, or the device being configured
            t = DateAdd(DateInterval.Second, 5, Now())
            While Now() < t And dev1.Configured = False
                ' let time pass by....
                Threading.Thread.Sleep(200)
            End While

            If Not dev1.Configured Then
                ' inform user
                cancel = MsgBox("You haven't yet configured device '" & dev1.Address & "'. Please configure it and click Retry, or click Cancel", MsgBoxStyle.RetryCancel) = MsgBoxResult.Cancel
            Else
                cancel = True ' exit loop
            End If
        End While

        If dev1.Configured Then
            MsgBox("You succesfully configured the device!")
        Else
            MsgBox("You cancelled configuration of the device")
        End If

        Call ShowConfig()

        ' cleanup, disposing will sent a proper end message
        dev1.Dispose()
        dev1 = Nothing
        MsgBox("Devices have been cleaned up.")
    End Sub

    Private Sub ShowConfig()
        Dim m As String
        m = "Device has been configured as follows;" & vbCrLf & _
            "      Address   : " & dev1.Address & vbCrLf & _
            "      Configured: " & dev1.Configured & vbCrLf & vbCrLf & _
            "Regular Config Items " & vbCrLf & _
            "   newconf : " & dev1.ConfigItems.conf_Newconf & vbCrLf & _
            "   interval: " & dev1.ConfigItems.conf_IntervalInMin & vbCrLf & _
            "   nr of groups: " & dev1.ConfigItems.conf_Group.Count & vbCrLf & _
            "   nr of filters: " & dev1.ConfigItems.conf_Filter.Count & vbCrLf & vbCrLf & _
            "Custom Config Items: " & vbCrLf & _
            dev1.ConfigItems.Item("extra1").ToString & vbCrLf & _
            dev1.ConfigItems.Item("extra2").ToString
        MsgBox(m)

    End Sub


    ' the eventhandler for the configuration events
    Private Sub ConfigHandler(ByVal xpldev As xPL.xPLDevice)
        MsgBox("This is the eventhandler for the 'ConfigDone' and 'ReConfigDone' events. It was triggered because you configured (or reconfigured) the device!")
    End Sub

End Module
