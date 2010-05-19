Option Strict On
Imports xPL
Imports xPL.xPL_Base
Public Class MainForm

    Dim xdev As xPLDevice = Nothing
    Dim hubtmr As Timers.Timer
    Dim xplug As xPLPluginStore
    Dim HubEmbedded As Version = xPLPluginVendor.StrToVersion(My.Settings.BundledHubVersion)
    Dim DiagEmbedded As Version = xPLPluginVendor.StrToVersion(My.Settings.BundledHubVersion)
    Dim HubLatest As Version = New Version(0, 0, 0, 0)
    Dim DiagLatest As Version = New Version(0, 0, 0, 0)

    Private Sub GetLatestVersionInfo()
        Dim frm As xPLPluginUpdateDlgSmall
        If xplug Is Nothing Then xplug = New xPLPluginStore
        If Not xplug.IsLoaded Then
            Try

                ' prepare for update
                frm = New xPLPluginUpdateDlgSmall
                frm.Plugin = xplug
                xplug.LoadPluginStore()
                ' do update
                xplug.UpdatePluginStore()
                frm.ShowDialog()
                ' update finished, collect results
                Try
                    HubLatest = xplug.Devices(My.Settings.IdHub).VersionV
                Catch ex As Exception
                    HubLatest = New Version(0, 0, 0, 0)
                End Try
                Try
                    DiagLatest = xplug.Devices(My.Settings.IdDiag).VersionV
                Catch ex As Exception
                    DiagLatest = New Version(0, 0, 0, 0)
                End Try
            Catch ex As Exception
            End Try
        End If
    End Sub

    Private Sub MainForm_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        ' start up
        If My.Application.CommandLineArgs.Count <> 0 Then
            ' commandline argument, should be proces ID of installer
            Try
                ' get process ID from argument list
                Dim pid As Integer = CInt(My.Application.CommandLineArgs(0))
                If pid <> 0 Then
                    ' get parent process
                    Dim proc As Process = Process.GetProcessById(pid)

                    ' this is required because it is an installer and this application also includes 
                    ' installers of which only one can run at any given time.
                    proc.WaitForExit()  ' wait for parent process to exit.

                End If
            Catch ex As Exception
                ' do nothing
            End Try
        End If

        Me.Icon = xPL.xPL_Base.XPL_Icon
        CheckPort()
        StartHubCheck()
        btnInstallHub.Enabled = False
        btnCheckHub.Enabled = False
    End Sub

    Private Sub btnClose_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click
        If Not hubtmr Is Nothing Then hubtmr.Stop()
        Me.Close()
    End Sub

#Region "Hub check"

    Private Sub btnCheckHub_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCheckHub.Click
        StartHubCheck()
    End Sub

    Dim HubCheckComplete As Boolean = False
    Private Sub StartHubCheck()
        btnCheckHub.Enabled = False
        HubCheckComplete = False
        If Not xdev Is Nothing Then Exit Sub ' check already running
        xdev = New xPLDevice
        Me.lblHubFound.Visible = False
        Me.lblHubNotFound.Visible = False
        Me.lblHubConnecting.Visible = True
        xdev.VendorID = "tieske"
        xdev.DeviceID = "xplcheck"
        xdev.InstanceIDType = InstanceCreation.Randomized
        xdev.Debug = False
        xdev.Configurable = False
        xdev.VersionNumber = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString
        xdev.Enabled = True
        hubtmr = New Timers.Timer
        hubtmr.AutoReset = True
        hubtmr.Interval = 500
        AddHandler hubtmr.Elapsed, AddressOf TimerElapsed
        hubtmr.Start()
    End Sub
    Private Sub EndHubCheck()
        If xdev Is Nothing Then Exit Sub
        hubtmr.Stop()
        RemoveHandler hubtmr.Elapsed, AddressOf TimerElapsed
        hubtmr = Nothing
        xdev.Dispose()
        xdev = Nothing
    End Sub
    Private Sub TimerElapsed(ByVal sender As Object, ByVal e As Timers.ElapsedEventArgs)

        Dim d As New UpdateBarCallback(AddressOf updateBar)
        Dim f As New SetHubStateCallback(AddressOf SetHubState)

        hubtmr.Stop()
        Me.Invoke(d, False) 'increment bar

        ' found something already
        If xdev.Status = xPLDeviceStatus.Online Then
            EndHubCheck()
            Me.Invoke(f, hubState.Found)
            Me.Invoke(d, True) 'reset bar
        End If

        If HubCheckComplete Then
            ' we're complete
            EndHubCheck()
            ' did we find anything?
            If lblHubFound.Visible = False Then
                ' no hub found
                Me.Invoke(f, hubState.NotFound)
            End If
            Me.Invoke(d, True) 'reset bar
        Else
            If Not hubtmr Is Nothing Then hubtmr.Start()
        End If
    End Sub

    Private Delegate Sub UpdateBarCallback(ByVal reset As Boolean)
    Private Sub updateBar(ByVal reset As Boolean)
        If reset Then
            Me.ProgressBar1.Value = 0
        Else
            Me.ProgressBar1.Increment(Me.ProgressBar1.Step)
        End If
        HubCheckComplete = (Me.ProgressBar1.Value = Me.ProgressBar1.Maximum)

    End Sub
    Private Enum hubState
        Found
        NotFound
        Connecting
    End Enum

    Private Delegate Sub SetHubStateCallback(ByVal s As hubState)
    Private Sub SetHubState(ByVal s As hubState)
        If s = hubState.Connecting Then
            Me.lblHubConnecting.Visible = True
            Me.btnInstallHub.Enabled = False
            Me.btnCheckHub.Enabled = False
        Else
            Me.lblHubConnecting.Visible = False
        End If
        If s = hubState.Found Then
            Me.lblHubFound.Visible = True
            Me.btnInstallHub.Enabled = False
            Me.btnCheckHub.Enabled = True
            If Me.lblPortOpen.Visible Then
                MsgBox("Firewall ports are open and an xPL connection with the hub could be established, " & _
                       "so the xPL network connectivity seems fine. You can close the 'xPL Connectivity " & _
                       "check' window.", MsgBoxStyle.Information, "xPL connectivity is ok")
            End If
        Else
            Me.lblHubFound.Visible = False
        End If
        If s = hubState.NotFound Then
            Me.lblHubNotFound.Visible = True
            Me.btnInstallHub.Enabled = True
            Me.btnCheckHub.Enabled = True
        Else
            Me.lblHubNotFound.Visible = False
        End If
    End Sub
#End Region

#Region "Network Port"

    Private Sub CheckPort()
        If IsFWaccessible() Then
            If IsxPLportOpen() Then
                Me.lblPortOpen.Visible = True
                Me.lblPortClosed.Visible = False
                Me.lblPortUnavailable.Visible = False
                Me.btnClosePort.Enabled = True
                Me.btnOpenPort.Enabled = False
            Else
                Me.lblPortOpen.Visible = False
                Me.lblPortClosed.Visible = True
                Me.lblPortUnavailable.Visible = False
                Me.btnClosePort.Enabled = False
                Me.btnOpenPort.Enabled = True
            End If
        Else
            ' Firewall cannot be accessed
            Me.lblPortOpen.Visible = False
            Me.lblPortClosed.Visible = False
            Me.lblPortUnavailable.Visible = True
            Me.btnClosePort.Enabled = False
            Me.btnOpenPort.Enabled = False
        End If
    End Sub

    Private Sub btnCheckPort_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCheckPort.Click
        If IsFWaccessible() Then
            Me.CheckPort()
        Else
            MsgBox("It seems that the Windows Firewall is not available/accessible. The port settings cannot be verified. " & _
                   "If you are using another firewall, then you should configure the xPL port through that application.", _
                   MsgBoxStyle.Information Or MsgBoxStyle.OkOnly, "Firewall inaccessible")
        End If
    End Sub

    Private Sub btnOpenPort_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnOpenPort.Click
        Try
            Firewall.OpenxPLPort()
        Catch ex As Exception
            MsgBox("An error was returned while trying to open the network port; " & ex.Message)
        End Try
        Me.CheckPort()
    End Sub

    Private Sub btnClosePort_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClosePort.Click
        Try
            Firewall.ClosexPLport()
        Catch ex As Exception
            MsgBox("An error was returned while trying to close the network port; " & ex.Message)
        End Try
        Me.CheckPort()
    End Sub
#End Region

    Private Sub btnInstallHub_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnInstallHub.Click
        Dim filename As String = tempPath() & "xplhub.msi"
        Dim proc As New Process
        Dim filename2 As String = tempPath()
        Dim result As MsgBoxResult
        Dim download As Boolean = False
        Dim url As String
        Dim frm As Download

        ' see if there are updates available
        GetLatestVersionInfo()
        If HubLatest > HubEmbedded Then
            ' go ask download new version
            result = MsgBox("The version of the Hub (version " & HubEmbedded.ToString & ") enclosed with this application is " & _
                   "outdated, a newer version (version " & HubLatest.ToString & ") is available." & vbCrLf & vbCrLf & _
                   "Would you like to download and install the newer version? (click No to install the enclosed outdated version)", _
                   MsgBoxStyle.YesNoCancel Or MsgBoxStyle.Question Or MsgBoxStyle.DefaultButton1, _
                   "New version available")
            Select Case result
                Case MsgBoxResult.Cancel : Exit Sub
                Case MsgBoxResult.Yes : download = True
                Case MsgBoxResult.No : download = False
            End Select
        End If
        If download Then
            Try
                ' try downloading
                url = ""
                ' check it to be an MSI or EXE
                url = xplug.Devices(My.Settings.IdHub).URLdownload
                If System.IO.Path.GetExtension(url).ToLower <> ".msi" And _
                   System.IO.Path.GetExtension(url).ToLower <> ".exe" Then
                    ' can't execute downloads
                    ' generate error
                    Dim a As Integer = 0
                    a = CInt(15 / a)
                End If
                ' add filename to temppath
                filename2 += System.IO.Path.GetFileName(url)

                If download Then
                    ' Download file
                    frm = New Download
                    frm.lblMessage.Text = "Downloading Hub version " & HubLatest.ToString & ", please be patient..."
                    frm.Show()
                    frm.Refresh()
                    Threading.Thread.Sleep(500)    ' provide time for form to draw itself
                    My.Computer.Network.DownloadFile(url, filename2)
                    frm.Close()

                    ' update filename to point to downloaded installer
                    filename = filename2
                End If

            Catch
                ' downloading failed....
                If MsgBox("There was an error downloading the newer version, would you like to continue " & _
                          "by installing the enclosed (outdated) Hub?", _
                          MsgBoxStyle.OkCancel Or MsgBoxStyle.Exclamation Or MsgBoxStyle.DefaultButton2, _
                          "Download error") = MsgBoxResult.Cancel Then
                    ' cancel installation
                    Exit Sub
                Else
                    ' use embedded installer anyway
                    download = False
                End If
            End Try
        End If

        If Not download Then
            ' save embedded installer to temp directory
            Resources.SaveResourceToFile(My.Resources.xplhub, filename)
        End If

        proc.StartInfo.FileName = filename
        proc.Start()
        Me.WindowState = FormWindowState.Minimized
        proc.WaitForExit()
        Me.WindowState = FormWindowState.Normal
        Kill(filename)
        btnInstallHub.Enabled = False
        MsgBox("Installing the hub finished, click Ok to restart the check.", MsgBoxStyle.Information Or MsgBoxStyle.OkOnly, "Hub installation")
        btnCheckHub_Click(Nothing, Nothing)
    End Sub

    Private Sub btnInstallDiag_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnInstallDiag.Click
        Dim filename As String = tempPath() & "xpldiag.msi"
        Dim filename2 As String = tempPath()
        Dim proc As New Process
        Dim result As MsgBoxResult
        Dim download As Boolean = False
        Dim url As String
        Dim frm As Download

        ' see if there are updates available
        GetLatestVersionInfo()
        If DiagLatest > DiagEmbedded Then
            ' go ask download new version
            result = MsgBox("The version of xPL Diagnostics (version " & DiagEmbedded.ToString & ") enclosed with this application is " & _
                   "outdated, a newer version (version " & DiagLatest.ToString & ") is available." & vbCrLf & vbCrLf & _
                   "Would you like to download and install the newer version? (click No to install the enclosed outdated version)", _
                   MsgBoxStyle.YesNoCancel Or MsgBoxStyle.Question Or MsgBoxStyle.DefaultButton1, _
                   "New version available")
            Select Case result
                Case MsgBoxResult.Cancel : Exit Sub
                Case MsgBoxResult.Yes : download = True
                Case MsgBoxResult.No : download = False
            End Select
        End If
        If download Then
            Try
                ' try downloading
                url = ""
                ' check it to be an MSI or EXE
                url = xplug.Devices(My.Settings.IdDiag).URLdownload
                If System.IO.Path.GetExtension(url).ToLower <> ".msi" And _
                   System.IO.Path.GetExtension(url).ToLower <> ".exe" Then
                    ' can't execute downloads
                    ' generate error
                    Dim a As Integer = 0
                    a = CInt(15 / a)
                End If
                ' add filename to temppath
                filename2 += System.IO.Path.GetFileName(url)

                If download Then
                    ' Download file
                    frm = New Download
                    frm.lblMessage.Text = "Downloading xPL Diagnostics version " & DiagLatest.ToString & ", please be patient..."
                    frm.Show()
                    frm.Refresh()
                    Threading.Thread.Sleep(500)    ' provide time for form to draw itself
                    My.Computer.Network.DownloadFile(url, filename2)
                    frm.Close()

                    ' update filename to point to downloaded installer
                    filename = filename2
                End If

            Catch
                ' downloading failed....
                If MsgBox("There was an error downloading the newer version, would you like to continue " & _
                          "by installing the enclosed (outdated) xPL Diagnostics?", _
                          MsgBoxStyle.OkCancel Or MsgBoxStyle.Exclamation Or MsgBoxStyle.DefaultButton2, _
                          "Download error") = MsgBoxResult.Cancel Then
                    ' cancel installation
                    Exit Sub
                Else
                    ' use embedded installer anyway
                    download = False
                End If
            End Try
        End If

        If Not download Then
            ' save embedded installer to temp directory
            Resources.SaveResourceToFile(My.Resources.xpldiag, filename)
        End If

        proc.StartInfo.FileName = filename
        proc.Start()
        Me.WindowState = FormWindowState.Minimized
        proc.WaitForExit()
        Me.WindowState = FormWindowState.Normal
        Kill(filename)
        MsgBox("If the installation completed succesfully, you can now start xPL Diagnostics through the startmenu", MsgBoxStyle.Information Or MsgBoxStyle.OkOnly, "xPL Diagnostics")
    End Sub

    Private Sub Button1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button1.Click
        Dim abb As New About
        abb.Icon = XPL_Icon
        About.ShowDialog()
        abb = Nothing
    End Sub
End Class
