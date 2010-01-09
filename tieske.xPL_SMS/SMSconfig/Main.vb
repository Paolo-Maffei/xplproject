Option Strict On
Imports xPL
Imports xPL.xPL_Base

Module MainModule
    Public Const cVENDOR As String = "tieske"           ' vendor to be used for devices and configurator
    Public Const cDEVICE As String = "sms"              ' devices to configure
    Public Const cCONFDEVICE As String = "smsconf"     ' device used to configure, ID will be randomized
    Friend xPLdev As xPLDevice

    Sub Main()
        Dim Args() As String = GetCommandLineArgs()
        Dim Addr As xPLAddress = Nothing
        Dim MainI As MainInterface = Nothing
        ' setup device
        xPLdev = New xPLDevice
        xPLdev.Configurable = False
        xPLdev.VendorID = cVENDOR
        xPLdev.DeviceID = cCONFDEVICE
        xPLdev.InstanceIDType = InstanceCreation.Randomized
        xPLdev.MessagePassing = MessagePassingEnum.All

        ' check command line for adresses to configure
        For Each s As String In Args
            Try
                Addr = New xPLAddress(xPL_Base.xPLAddressType.Target, s)
                If Addr.Vendor = cVENDOR And Addr.Device = cDEVICE Then
                    ' found a commandline parameter that matches the vendor and device settings
                    Exit For
                Else
                    ' not what we're looking for
                    Addr = Nothing
                End If
            Catch ex As Exception
            End Try
        Next

        ' bring device online
        xPLdev.Enabled = True

        ' if no address was on the commandline, then scan for devices now
        If Not Addr Is Nothing Then
            ' Address on the commandline, go configure individual device
            ConfigureDevice(Addr)
        Else
            ' No address was provided, go list devices on main interface and let user decide what to configure
            MainI = New MainInterface
            MainI.xpldev = xPLdev
            MainI.ShowDialog()
        End If
        xPLdev.Enabled = False
        xPLdev.Dispose()

    End Sub

    Private Function GetCommandLineArgs() As String()
        ' Declare variables.
        Dim separators As String = " "
        Dim commands As String = Microsoft.VisualBasic.Interaction.Command()
        Dim args() As String = commands.Split(separators.ToCharArray)
        Return args
    End Function

#Region "Configure individual device"
    Dim LookForAddress As String = ""
    Dim ConfigCurrent As xPL.xPLMessage = Nothing
    Dim ConfigList As xPL.xPLMessage = Nothing

    Friend Sub ConfigureDevice(ByVal addr As xPL.xPLAddress)
        Dim prog As New ScanProgress
        Dim n As Integer
        Dim ui As UnitInterface
        LookForAddress = addr.ToString
        ConfigCurrent = Nothing
        ' add handler to catch messages coming in
        AddHandler xPLdev.xPLMessageReceived, AddressOf FindConfig
        ' Show progress dialog
        prog.ProgressBar.Minimum = 0
        prog.ProgressBar.Maximum = 100
        prog.ProgressBar.Step = 1
        prog.Show()
        ' Send info requests
        xPLNetwork.RequestConfigList(xPLdev, addr.ToString)
        Threading.Thread.Sleep(100)
        xPLNetwork.RequestConfigCurrent(xPLdev, addr.ToString)

        ' run for 10 seconds
        For n = 1 To 100
            Threading.Thread.Sleep(100)
            If (Not ConfigCurrent Is Nothing) And (Not configlist Is Nothing) Then
                ' A message was returned, stop scanning
                Exit For
            End If
            prog.ProgressBar.PerformStep()
        Next
        ' close window, remove handlers
        prog.Close()
        prog = Nothing
        RemoveHandler xPLdev.xPLMessageReceived, AddressOf FindConfig

        If ConfigCurrent Is Nothing Then
            ' show message of failure
            MsgBox("Device " & addr.ToString & " did not respond to the request for configuration information.", MsgBoxStyle.Exclamation)
        Else
            ' show configuration interface
            ui = New UnitInterface
            ui.configcurrent = ConfigCurrent
            ui.ConfigList = ConfigList
            ui.xdev = xPLdev
            ui.ShowDialog()
            ui = Nothing
        End If
    End Sub

    Private Sub FindConfig(ByVal xpldev As xPL.xPLDevice, ByVal e As xPL.xPLDevice.xPLEventArgs)
        If e.XplMsg.MsgType = xPLMessageTypeEnum.Status And e.XplMsg.Source = LookForAddress Then
            ' found one thats a status message for the target device
            Select Case e.XplMsg.Schema
                Case "config.current"
                    ConfigCurrent = e.XplMsg
                Case "config.list"
                    ConfigList = e.XplMsg
                Case Else
                    ' do nothing, not correct schema
            End Select
        End If
    End Sub
#End Region

End Module
