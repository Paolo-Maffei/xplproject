Imports xPL             ' import xPL namespace for quick access
Imports xPL.xPL_Base    ' import the base to, provides numerous constants and support functions

Module Example4
    Dim dev1 As xPLDevice
    Dim dev2 As xPLDevice

    Friend Sub Example4()
        dev1 = New xPLDevice
        dev1.Configurable = False
        dev1.VendorID = "tieske"
        dev1.DeviceID = "example4"
        dev1.InstanceID = "dev1"

        dev2 = New xPLDevice
        dev2.Configurable = False
        dev2.VendorID = "tieske"
        dev2.DeviceID = "example4"
        dev2.InstanceID = "dev2"

        MsgBox("Core stuff: how to send an xPL message, but with xPLLib, its a piece of cake :-)" & vbCrLf & vbCrLf & _
               "For starters, 2 devices have been created, Device1 and Device2 (check your logger " & _
               "to see them). This time they have been set to NOT be configurable" & vbCrLf & vbCrLf & _
               "We'll setup a message and sent it through both devices, but through different methods. Click OK to continue")


        ' Go create a message and set the basics and some keyvalue fields
        Dim msg As New xPLMessage()
        With msg
            .MsgType = xPLMessageTypeEnum.Status
            .Source = dev1.Address  ' we're explcitly setting the source address, this need not be, see next example below
            .Target = "*"
            .Schema = "xpllib.test"
            With .KeyValueList
                .Add("key1", "value1")
                .Add("key2", "value2")
            End With
        End With

        MsgBox("we've now created a simple message that looks like this: " & vbCrLf & vbCrLf & _
        msg.RawxPL & vbCrLf & vbCrLf & _
        "Note that the source address has been set!,  this enables us to call the .Send method of the xPLMessage object. " & _
        "When using this method the xPLDevice will be looked up in the device list of the xPLListener object and send through " & _
        "that device." & vbCrLf & "Lets send it, click OK to continue and watch your logger")

        ' now call the Send method of the MESSAGE object
        msg.Send()

        MsgBox("Message send! Now that was method 1. The alternative method is to send it through a device, in that case " & _
        "there is no need to set the source address as it will be automatically set. To demonstrate this we will now send the " & _
        "same message again, but now through the xPLDevice.Send method of the 2nd device we created." & vbCrLf & _
        "Click OK to continue and watch your logger for the same message, but with a different source address")

        ' In code we don't need to do anything, the existing source address will be overwritten automatically
        dev2.Send(msg)

        MsgBox("Thats how easy it is to send a message. But now a more advanced topic; heartbeat messages. Every device will " & _
        "automatically send heartbeats, this is being handled by the xPLlib. xPLLib allows you to add custom data to " & _
        "these messages." & vbCrLf & vbCrLf & _
        "Click OK to continue and send Heartbeats with a custom value added to it (current time)")

        ' setup the callback to add the custom items
        Dim cbHB As xPLDevice.HBeatItemsCallback
        cbHB = AddressOf hbeatitems
        dev1.xPLGetHBeatItems = AddressOf hbeatitems
        ' send a heartbeat
        dev1.SendHeartbeatMessage()

        ' do again as long as requested
        While MsgBox("Send another heartbeat?", MsgBoxStyle.YesNo) = MsgBoxResult.Yes
            dev1.SendHeartbeatMessage()
        End While


        MsgBox("We're done with the example, lets cleanup and exit, click OK")

        ' cleanup, disposing will sent a proper end message
        dev1.Dispose()
        dev1 = Nothing
        dev2.Dispose()
        dev2 = Nothing
    End Sub

    ' callback method that will add the specific heartbeat items
    Private Function hbeatitems(ByVal xpldev As xPLDevice) As xPLKeyValuePairs
        Dim items As New xPLKeyValuePairs
        items.Add("time", Now.ToString)     ' just add current time
        Return items
    End Function

End Module
