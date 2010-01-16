Option Explicit On
Imports xPL
Imports xPL.xPL_Base
Public Class MainForm

    Dim xdev As xPLDevice = Nothing
    Dim hubtmr As Timers.Timer

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
        If IsxPLportOpen() Then
            Me.lblPortOpen.Visible = True
            Me.lblPortClosed.Visible = False
            Me.btnClosePort.Enabled = True
            Me.btnOpenPort.Enabled = False
        Else
            Me.lblPortOpen.Visible = False
            Me.lblPortClosed.Visible = True
            Me.btnClosePort.Enabled = False
            Me.btnOpenPort.Enabled = True
        End If
    End Sub

    Private Sub btnCheckPort_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCheckPort.Click
        Me.CheckPort()
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
        Resources.SaveResourceToFile(My.Resources.xplhub, filename)
        Dim proc As New Process
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
        Resources.SaveResourceToFile(My.Resources.xpldiag, filename)
        Dim proc As New Process
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
