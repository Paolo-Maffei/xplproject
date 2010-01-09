Option Strict On
Imports xPL
Imports xPL.xPL_Base

Public Class AppCore

    Private WithEvents xPLdev As xPL.xPLDevice

    Friend Sub OnStartUp(ByVal el As System.Diagnostics.EventLog)
        ' Add code here to start your service. This method should set things
        ' in motion so your service can do its work.

        ' set xPL event log
        xPLErrorEventLog = el

        LogError("SMS OnStartUp", "Starting service", EventLogEntryType.Information)
        If My.Settings.xPLDevice = "" Then
            ' We're new in town, setup defaults
            SetupDefaults()
            LogError("SMS OnStartUp", "No settings; starting with defaults", EventLogEntryType.Information)
        Else
            ' Get settings and restore xPL device
            Try
                LogError("SMS OnStartUp", "Settings read; starting", EventLogEntryType.Information)
                xPLdev = New xPL.xPLDevice(My.Settings.xPLDevice, False)
                ' now call config changed event handler to propagate settings to the SMSinterface
                ConfigChanged(xPLdev)
            Catch ex As Exception
                ' something is wrong, fallback to defaults
                LogError("SMS OnStartUp", "Restoring settings failed; starting with defaults", EventLogEntryType.Error)
                SetupDefaults()
            End Try
        End If
        ' attach callbacks and event handlers
        SetupHandlers()

        ' Set debug settings according to compiler directives
#If DEBUG Then
        xPLdev.Debug = True
#Else
        xPLdev.Debug=False
#End If

        ' now go online...
        xPLdev.Enabled = True
        LogError("SMS OnStartUp", "Service started", EventLogEntryType.Information)
    End Sub

    Private Sub SetupDefaults()
        Dim ci As xPL.xPLConfigItems
        xPLdev = New xPL.xPLDevice
        xPLdev.VendorID = "tieske"
        xPLdev.DeviceID = "sms"
        xPLdev.InstanceIDType = InstanceCreation.Randomized
        xPLdev.Configurable = True
        xPLdev.MessagePassing = MessagePassingEnum.ToBeHandledOnly
        xPLdev.VersionNumber = "0.1"
        ci = xPLdev.ConfigItems
        ci.Add("urlsend", "http://www.mollie.nl/xml/sms/?username=[[USERNAME]]&password=[[PASSWORD]]&", xPLConfigTypes.xReconf, 3)
        ci("urlsend").Add("originator=xPL%20Project&recipients=[[RECIPIENT]]&message=[[MESSAGE]]")
        ci.Add("lookfor", "<success>true</success>", xPLConfigTypes.xOption, 1)
        ci.Add("lookfors", "yes", xPLConfigTypes.xOption, 1)
        ci.Add("urlcred", "http://www.mollie.nl/xml/credits/?username=[[USERNAME]]&password=[[PASSWORD]]", xPLConfigTypes.xReconf, 3)
        ci.Add("crstart", "<credits>", xPLConfigTypes.xOption, 1)
        ci.Add("crend", "</credits>", xPLConfigTypes.xOption, 1)
    End Sub
    Private Sub SetupHandlers()
        AddHandler xPLdev.xPLConfigDone, AddressOf ConfigChanged
        AddHandler xPLdev.xPLReConfigDone, AddressOf ConfigChanged
        AddHandler xPLdev.xPLMessageReceived, AddressOf MessageReceived
        xPLdev.xPLGetHBeatItems = AddressOf HeartBeat
    End Sub
    Private Sub MessageReceived(ByVal dev As xPLDevice, ByVal e As xPLDevice.xPLEventArgs)
        Dim msg As String
        Dim nmbr As String
        Dim xmsg As xPLMessage
        Try
            ' only handle message if it is directed at me specifically or group
            If e.IsForMe Or e.IsForMeGroup Then
                ' only deal with command types
                If e.XplMsg.MsgType = xPLMessageTypeEnum.Command Then
                    ' only deal with sendmsg.basic schema
                    If e.XplMsg.Schema = "sendmsg.basic" Then
                        ' setup trigger message to sent result when done
                        xmsg = New xPLMessage
                        xmsg.MsgType = xPLMessageTypeEnum.Trigger
                        xmsg.Schema = "sendmsg.confirm"
                        xmsg.Source = dev.Address
                        xmsg.Target = "*"
                        ' extract message and recipient from received message
                        Try
                            msg = Trim(e.XplMsg.KeyValueList("body"))
                        Catch ex As Exception
                            msg = ""
                        End Try
                        Try
                            nmbr = Trim(e.XplMsg.KeyValueList("to"))
                        Catch ex As Exception
                            nmbr = ""
                        End Try
                        ' perform checks and send SMS message
                        If SMSinterface.SMSsend(msg, nmbr) Then
                            ' success in sending
                            xmsg.KeyValueList.Add("status", "success")
                        Else
                            ' sending failed
                            xmsg.KeyValueList.Add("status", "failure")
                            xmsg.KeyValueList.Add("error", Left(xPL_Base.RemoveInvalidxPLchars("xPL SMS app: " & SMSinterface.LastError, XPL_STRING_TYPES.Values), 128))
                        End If
                        ' send trigger message
                        xmsg.Send(dev)
                    End If
                End If
            End If
        Catch ex As Exception
            xPL_Base.LogError("SMS MessageReceived", ex.ToString)
        End Try
    End Sub
    Private Sub ConfigChanged(ByVal dev As xPL.xPLDevice)
        Dim s As String = ""
        Dim n As Integer = 0
        ' get URLs from the three independent configitem values
        s = ""
        For n = 0 To dev.ConfigItems.Item("urlsend").Count - 1
            s += dev.ConfigItems.Item("urlsend").Item(n)
        Next
        SMSinterface.URLmessage = s
        s = ""
        For n = 0 To dev.ConfigItems.Item("urlcred").Count - 1
            s += dev.ConfigItems.Item("urlcred").Item(n)
        Next
        SMSinterface.URLcredits = s

        SMSinterface.LookFor = dev.ConfigItems.Item("lookfor").Item(0)
        Select Case Trim(dev.ConfigItems.Item("lookfors").Item(0).ToLower)
            Case "true", "1", "yes"
                SMSinterface.LookForSuccess = True
                dev.ConfigItems.Item("lookfors").Item(0) = "yes"
            Case "false", "0", "no"
                SMSinterface.LookForSuccess = False
                dev.ConfigItems.Item("lookfors").Item(0) = "no"
        End Select
        SMSinterface.DelimStart = dev.ConfigItems.Item("crstart").Item(0)
        SMSinterface.DelimEnd = dev.ConfigItems.Item("crend").Item(0)
    End Sub

    ' Call back procedure to add custom heartbeat items to the list
    Private Function HeartBeat(ByVal dev As xPL.xPLDevice) As xPL.xPLKeyValuePairs
        Dim kvl As New xPL.xPLKeyValuePairs
        Dim kv As New xPL.xPLKeyValuePair("credits", "")
        ' Get remaining credits
        If SMSinterface.Credits Then
            ' success
            kv.Value = Left(RemoveInvalidxPLchars(SMSinterface.LastCredits, XPL_STRING_TYPES.Values), 80)
            If dev.Debug Then LogError("SMS HeartBeat", "SMS credits; " & SMSinterface.LastCredits, EventLogEntryType.Information)
        Else
            ' failed
            kv.Value = Left(RemoveInvalidxPLchars("Error: " & SMSinterface.LastError, XPL_STRING_TYPES.Values), 80)
            If dev.Debug Then LogError("SMS HeartBeat", "Error retreiving SMS credits; " & SMSinterface.LastError, EventLogEntryType.Error)
        End If
        ' add to value list and return
        kvl.Add(kv)
        Return kvl
    End Function

    Friend Sub OnShutdown()
        ' cleanup handlers and callbacks
        LogError("SMS OnShutDown", "Stopping service", EventLogEntryType.Information)
        If Not xPLdev Is Nothing Then
            xPLdev.xPLGetHBeatItems = Nothing
            RemoveHandler xPLdev.xPLConfigDone, AddressOf ConfigChanged
            RemoveHandler xPLdev.xPLReConfigDone, AddressOf ConfigChanged
            RemoveHandler xPLdev.xPLMessageReceived, AddressOf MessageReceived
            ' Store settings
            My.Settings.xPLDevice = xPLdev.GetState(GetVersionNumber(2))
            My.Settings.Save()
            ' destroy device
            xPLdev.Dispose()
            LogError("SMS OnShutDown", "Service stopped", EventLogEntryType.Information)
        End If
    End Sub

End Class
