Imports OpenSource.UPnP
Imports xPL
Imports xPL.xPL_Base
Imports System.Xml



Public Class MainForm

    Const APPVERSION = "0"

    Private WithEvents cp As UPnPSmartControlPoint
    Private CacheTime As Integer = 900
    Private xset As String


#Region "Form related stuff"

    Private Sub Form1_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' Load xPL devices first, do not enable them
        'My.Settings.xPLDevices = ""
        xPLListener.RestoreFromState(My.Settings.xPLDevices, False)
        ' Now enable UPnP control point, devices will be found
        cp = New UPnPSmartControlPoint
        ' configure form
        Me.Icon = XPL_Icon
        LogMessage("UPnP-2-xPL gateway started")
    End Sub

    Private Sub Form1_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        ' make sure we properly stop everything
        ' store current xPL devices and stop xPL devices
        My.Settings.xPLDevices = xPLListener.GetState(APPVERSION)
        xPLListener.Shutdown()
        ' stop UPnP control point and dispose
        cp = Nothing
    End Sub

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
            While lbLog.Items.Count > 150
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

End Class
