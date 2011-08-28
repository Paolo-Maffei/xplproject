Imports OpenSource.UPnP
Imports xPL
Imports xPL.xPL_Base
Imports System.Xml

' TODO: use sub Main to start and hide window initially
' TODO: protect log function with lock
' TODO: add more logging

Public Class MainForm

    Private WithEvents cp As UPnPSmartControlPoint
    Private CacheTime As Integer = 900
    Private xset As String

#Region "Form startup and shutdown"

    Private Sub Form1_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' Load xPL devices first, do not enable them
        xPLListener.RestoreFromState(My.Settings.xPLDevices, False)
        ' Now enable UPnP control point, devices will be found
        cp = New UPnPSmartControlPoint
        ' configure form
        Me.Icon = XPL_Icon
        LogMessage("UPnP-2-xPL gateway started")
        ' read settings
        If My.Settings.StartMinimized Then Me.WindowState = FormWindowState.Minimized
        Me.tbLogLines.Text = My.Settings.LogLines.ToString
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

    Private Sub lmgo(ByVal message As String)
        ' replace control chars to proper line separators
        message = message.Replace(vbCrLf, Chr(0))
        message = message.Replace(vbLf, Chr(0))
        message = message.Replace(vbCr, Chr(0))
        message = message.Replace(Chr(0), vbCrLf)
        ' make an array of lines
        Dim s() As String = message.Split(vbCrLf)
        Dim i As Integer
        ' add lines to the log
        For Each message In s
            i = lbLog.Items.Add(message)
            lbLog.SelectedIndex = i
            ' limit list to 150 items
            While lbLog.Items.Count > My.Settings.LogLines
                lbLog.Items.RemoveAt(0)
            End While
        Next
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

    Private Sub chkStartMinimized_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkStartMinimized.CheckedChanged
        My.Settings.StartMinimized = chkStartMinimized.Checked
    End Sub

    Private Sub tbLogLines_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles tbLogLines.TextChanged
        ' make sure its a valid positive number
        Dim l As Long = Int(Val(tbLogLines.Text))
        If l < 0 Then l = l * -1
        If tbLogLines.Text <> l.ToString Then
            tbLogLines.Text = l.ToString
        End If
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
        Me.Visible = True
    End Sub

    Private Sub btnClose_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click
        Me.Visible = False
    End Sub

    Private Sub ExitToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ExitToolStripMenuItem.Click
        Me.Close()
    End Sub

    Private Sub TaskBarIcon_DoubleClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles TaskBarIcon.DoubleClick
        Me.ShowLogToolStripMenuItem_Click(Nothing, Nothing)
    End Sub
End Class
