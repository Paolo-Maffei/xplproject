Imports OpenSource.UPnP
Imports xPL
Imports xPL.xPL_Base
Imports System.Xml

Public Class MainForm

    Private WithEvents cp As UPnPSmartControlPoint
    Private CacheTime As Integer = 900
    Private xset As String

#Region "Form startup and shutdown"

    Private Sub Form1_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' Load xPL devices first, do not enable them
        xPLListener.RestoreFromState(My.Settings.xPLDevices, False)
        ' cleanup just to be sure
        Select Case xPLListener.Count
            Case 0
                ' Need to create a new one
                Dim dev As New xPLDevice
                dev.VendorID = "tieske"
                dev.DeviceID = "upnp"
                dev.InstanceIDType = InstanceCreation.HostNameBased
                dev.Configurable = False
                dev.MessagePassing = dev.MessagePassing Or MessagePassingEnum.PassWhileAwaitingConfig
                LogMessage("New xPLDevice created; " & dev.Address & " (status: " & CStr(IIf(dev.Configured, "configured", "unconfigured")) & ")")
            Case 1
                ' This is ok.
                LogMessage("Existing xPLDevice restarted; " & xPLListener.Device(0).Address & " (status: " & CStr(IIf(xPLListener.Device(0).Configured, "configured", "unconfigured")) & ")")
            Case Is > 1
                ' delete the too many devices
                For n As Integer = xPLListener.Count - 1 To 1 Step -1
                    xPLListener.Device(n).Dispose()
                Next
                LogMessage("Existing xPLDevice restarted; " & xPLListener.Device(0).Address & " (status: " & CStr(IIf(xPLListener.Device(0).Configured, "configured", "unconfigured")) & ")")
        End Select
        Proxy.xPLDevice = xPLListener.Device(0)
        Proxy.xPLDevice.Enable()
        ' Now enable UPnP control point, devices will be found
        cp = New UPnPSmartControlPoint
        ' configure form
        Me.Icon = XPL_Icon
        LogMessage("UPnP-2-xPL gateway started")
        ' read settings
        Me.tbLogLines.Text = My.Settings.LogLines.ToString
        If My.Settings.StartMinimized Then
            Me.WindowState = FormWindowState.Minimized
            Me.ShowInTaskbar = False
        End If
    End Sub

    Private Sub Form1_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        ' make sure we properly stop everything
        ' store current xPL devices and stop xPL devices
        My.Settings.xPLDevices = xPLListener.GetState(xPL_Base.GetVersionNumber(2))
        xPLListener.Shutdown()
        ' stop UPnP control point and dispose
        cp = Nothing
    End Sub

#End Region

#Region "Logger functionality"

    Private LogLock As New Object
    Private Sub lmgo(ByVal message As String)
        SyncLock LogLock
            ' replace control chars to proper line separators
            message = message.Replace(vbCrLf, Chr(0))
            message = message.Replace(vbLf, Chr(0))
            message = message.Replace(vbCr, Chr(0))
            ' make an array of lines
            Dim s() As String = message.Split(Chr(0))
            Dim i As Integer
            ' add lines to the log
            Dim t As Date = Now()
            Dim ts As String = t.ToString("HH:mm:ss.fff")
            For Each message In s
                i = lbLog.Items.Add(ts & " " & message)
                lbLog.SelectedIndex = i
                ' limit list to configured number of items
                While lbLog.Items.Count > My.Settings.LogLines
                    lbLog.Items.RemoveAt(0)
                End While
            Next
        End SyncLock
    End Sub
    Private Delegate Sub lmgod(ByVal message As String)
    Private lmgods As lmgod = AddressOf lmgo
    Private Sub LogMessage(ByVal message As String)
        If lbLog.InvokeRequired Then
            Me.Invoke(lmgods, message)
        Else
            lmgo(message)
        End If
    End Sub
#End Region

#Region "Device handling"

    Private Sub AddDevice(ByVal sender As OpenSource.UPnP.UPnPSmartControlPoint, _
                      ByVal device As OpenSource.UPnP.UPnPDevice _
                      ) Handles cp.OnAddedDevice
        Proxy.AddDevice(device, AddressOf LogMessage)
    End Sub

    Private Sub RemDevice(ByVal sender As OpenSource.UPnP.UPnPSmartControlPoint, _
                      ByVal device As OpenSource.UPnP.UPnPDevice _
                      ) Handles cp.OnRemovedDevice
        Proxy.RemoveDevice(device)
    End Sub
#End Region

#Region "Interface elements"

    Private Sub chkStartMinimized_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkStartMinimized.CheckedChanged
        My.Settings.StartMinimized = chkStartMinimized.Checked
    End Sub

    Private Sub btnCopyToClipboard_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCopyToClipboard.Click
        Dim sb As New System.Text.StringBuilder
        For Each s As String In lbLog.Items
            sb.Append(s & vbCrLf)
        Next
        Clipboard.SetText(sb.ToString, TextDataFormat.UnicodeText)
    End Sub

    Private Sub ShowLogToolStripMenuItem_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles ShowLogToolStripMenuItem.Click
        Me.ShowInTaskbar = True
        Me.WindowState = FormWindowState.Normal
        Me.Visible = True
    End Sub

    Private Sub btnClose_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click
        Me.ShowInTaskbar = False
        Me.Visible = False
    End Sub

    Private Sub btnDebug_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnDebug.Click
        OpenSource.Utilities.EventLogger.Enabled = True
        OpenSource.Utilities.EventLogger.ShowAll = True
        OpenSource.Utilities.InstanceTracker.Display()
    End Sub

    Private Sub ExitToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ExitToolStripMenuItem.Click
        Me.Close()
    End Sub

    Private Sub TaskBarIcon_DoubleClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles TaskBarIcon.DoubleClick
        Me.ShowLogToolStripMenuItem_Click(Nothing, Nothing)
    End Sub

    Dim frmAbout As About
    Private Sub AboutToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles AboutToolStripMenuItem.Click
        If frmAbout Is Nothing Then
            frmAbout = New About
            frmAbout.ShowDialog()
            frmAbout = Nothing
        Else
            frmAbout.Show()
        End If
    End Sub

    Private Sub tbLogLines_LostFocus(ByVal sender As Object, ByVal e As System.EventArgs) Handles tbLogLines.LostFocus
        Dim l As Long = Int(Val(tbLogLines.Text))
        If l < 20 Then l = 20
        If l > 20000 Then l = 20000
        tbLogLines.Text = l.ToString
        My.Settings.LogLines = l
    End Sub

    Private Sub btnClear_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClear.Click
        lbLog.Items.Clear()
    End Sub

#End Region

End Class
