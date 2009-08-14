Imports xpllib

Public Class VFDDriver

    'Global Vars
    Public xPLLog As New Logger
    Public WithEvents xPLEngine As New XplListener("wmute", "xplvfd")

    Public LogLevel As Integer = Logger.LogLevel.AppWarn

    Public NumVFDDevices As Integer = 1
    Public VFDDevices As New Collection()


    Protected Overrides Sub OnStart(ByVal args() As String)

        'Log Startup Time 
        SaveRegSetting("StartupTime", Now.ToString)
        xPLLog.CurrentLogLevel = 2
        xPLLog.StartLogging()

        If getRegSetting("NumDevices") = "" Then  'new install, set defaults in registry
            xPLLog.AddLogEntry(Logger.LogLevel.AppWarn, "No Configuration Found, creating default Registry Entries")
            SaveRegSetting("NumDevices", "1")
            SaveRegSetting("LogLevel", "2")
            SaveRegSetting("\\VFD1\\PortName", "COM1")
            SaveRegSetting("\\VFD1\\BaudRate", "19200")
            SaveRegSetting("\\VFD1\\Parity", "Even")
            SaveRegSetting("\\VFD1\\DataBits", "8")
            SaveRegSetting("\\VFD1\\StopBits", "1")
            SaveRegSetting("\\VFD1\\Handshake", "None")
            SaveRegSetting("\\VFD1\\Zone", "zone1")
        Else
            For deviceNumber As Integer = 1 To NumVFDDevices
                Dim DisplayDevice As New VFDDevice
                Dim PortLabel As String = "\\VFD" & Str(deviceNumber)
                DisplayDevice.ZoneLabel = getRegSetting(PortLabel & "\\Zone")
                Dim PortSettings As New VFDDevice.PortSettings
                With PortSettings
                    .PortName = getRegSetting(PortLabel & "\\PortName")
                    .BaudRate = getRegSetting(PortLabel & "\\BaudRate")
                    .Parity = getRegSetting(PortLabel & "\\Parity")
                    .DataBits = getRegSetting(PortLabel & "\\DataBits")
                    .StopBits = getRegSetting(PortLabel & "\\StopBits")
                    .Handshake = getRegSetting(PortLabel & "\\Handshake")
                End With
                DisplayDevice.VFDPortConfig = PortSettings
                DisplayDevice.InitVFDDevice()

                VFDDevices.Add(DisplayDevice)
            Next
        End If

        xPLEngine.Filters.Add(New XplListener.XplFilter(xpllib.XplMessageTypes.Command, "*", "*", "*", "osd", "*"))
        xPLEngine.Listen()

    End Sub

    Private Sub HandleMessage(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs) Handles xPLEngine.XplMessageReceived

        Dim strOSDCommand As String = e.XplMsg.GetKeyValue("command")
        Dim strOSDText As String = e.XplMsg.GetKeyValue("text")
        Dim strOSDDelay As String = e.XplMsg.GetKeyValue("delay")
        Dim strOSDZone As String = e.XplMsg.GetKeyValue("zone")

        For Each ActiveDisplay As VFDDevice In VFDDevices
            If ActiveDisplay.ExclusiveUser = "" Or ActiveDisplay.ExclusiveUser = e.XplMsg.SourceTag Then
                Select Case strOSDCommand
                    Case "clear"
                        If strOSDZone = "" Or strOSDZone = "*" Or strOSDZone = ActiveDisplay.ZoneLabel Then
                            ActiveDisplay.ClearDevice()
                            xPLLog.AddLogEntry(Logger.LogLevel.AppInfo, "Zone: " & strOSDZone & " was cleared")
                        End If

                    Case "write"
                        If strOSDZone = "" Or strOSDZone = "*" Or strOSDZone = ActiveDisplay.ZoneLabel Then
                            ActiveDisplay.WriteMessage(CleanOSDText(strOSDText))
                            xPLLog.AddLogEntry(Logger.LogLevel.AppInfo, "Message Sent to Zone: " & strOSDZone)
                        End If

                    Case "exclusive"
                        If strOSDZone = "" Or strOSDZone = "*" Or strOSDZone = ActiveDisplay.ZoneLabel Then
                            ActiveDisplay.ClearDevice()
                            ActiveDisplay.ExclusiveUser = e.XplMsg.SourceTag
                            xPLLog.AddLogEntry(Logger.LogLevel.AppInfo, "Zone: " & strOSDZone & " was locked by device: " & e.XplMsg.SourceTag)
                        End If

                    Case "release"
                        If strOSDZone = "" Or strOSDZone = "*" Or strOSDZone = ActiveDisplay.ZoneLabel Then
                            ActiveDisplay.ClearDevice()
                            ActiveDisplay.ExclusiveUser = ""
                            xPLLog.AddLogEntry(Logger.LogLevel.AppInfo, "Zone: " & strOSDZone & " was released")
                        End If

                    Case Else

                        xPLLog.AddLogEntry(Logger.LogLevel.AppWarn, "An unrecognised command: " & strOSDCommand & " was received (and ignored)")
                End Select
            End If
        Next
    End Sub

    Protected Overrides Sub OnStop()
        xPLLog.StopLogging()
        xPLEngine.Dispose()

    End Sub

    Private Function CleanOSDText(ByVal strInput As String) As String
        Dim x As Integer
        Dim strOutput As String

        strOutput = ""
        For x = 1 To Len(strInput)
            If Mid(strInput, x, 2) = "\n" Then
                strOutput = strOutput & Chr(&HA) & Chr(&HD)
                x = x + 1
            Else
                strOutput = strOutput & Mid(strInput, x, 1)
            End If
        Next
        CleanOSDText = strOutput
    End Function

End Class
