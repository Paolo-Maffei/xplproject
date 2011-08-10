Option Explicit On
Imports xPL
Imports xPL.xPL_Base

Public Class Example5
    ' create the device when the form is created
    Private WithEvents dev As xPLDevice

    ' setup on form loading
    Private Sub Example5_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        dev = New xPLDevice
        dev.VendorID = "tieske"
        dev.DeviceID = "example5"
        dev.MessagePassing = MessagePassingEnum.ToBeHandledOnly Or MessagePassingEnum.PassWhileAwaitingConfig
        AddHandler dev.xPLStatusChange, AddressOf StatusChange
        AddHandler dev.xPLMessageReceived, AddressOf MessageReceived
        lbStatus.Items.Add("Stopped")
        btnScanNetwork.Enabled = False
        btnSendHeartBeatRequest.Enabled = False
        UpdatePassingDisplay()
    End Sub

    ' cleanup on exit
    Private Sub Example5_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        RemoveHandler dev.xPLStatusChange, AddressOf StatusChange
        RemoveHandler dev.xPLMessageReceived, AddressOf MessageReceived
        dev.Dispose()
    End Sub

    Private Sub btnStartStop_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnStartStop.Click
        If btnStartStop.Text = "Start" Then
            dev.Enable()
            btnStartStop.Text = "Stop"
            btnScanNetwork.Enabled = True
            btnSendHeartBeatRequest.Enabled = True
        Else
            dev.Disable()
            btnStartStop.Text = "Start"
            btnScanNetwork.Enabled = False
            btnSendHeartBeatRequest.Enabled = False
        End If
    End Sub

    Private Delegate Sub UpdStat(ByVal prevState As xPLDeviceStatus, ByVal newState As xPLDeviceStatus)
    Private Sub StatusChange(ByVal xpldev As xPLDevice, ByVal prevState As xPLDeviceStatus, ByVal newState As xPLDeviceStatus)
        Dim x As UpdStat = AddressOf UpdateStatus
        If Me.InvokeRequired Then
            Me.Invoke(x, prevState, newState)
        Else
            UpdateStatus(prevState, newState)
        End If
    End Sub
    Private Sub UpdateStatus(ByVal prevState As xPLDeviceStatus, ByVal newState As xPLDeviceStatus)
        Dim sOld As String = ""
        Dim sNew As String = ""
        Select Case prevState
            Case xPLDeviceStatus.Offline
                sOld = "Offline"
            Case xPLDeviceStatus.Connecting
                sOld = "Connecting"
            Case xPLDeviceStatus.Online
                sOld = "Online"
        End Select
        Select Case newState
            Case xPLDeviceStatus.Offline
                sNew = "Offline"
            Case xPLDeviceStatus.Connecting
                sNew = "Connecting"
            Case xPLDeviceStatus.Online
                sNew = "Online"
        End Select
        lbStatus.Items.Add(sOld & " -> " & sNew)
    End Sub

    Private Delegate Sub MsgReceived(ByVal e As xPLDevice.xPLEventArgs)
    Private Sub MessageReceived(ByVal xpldev As xPLDevice, ByVal e As xPLDevice.xPLEventArgs)
        Dim x As MsgReceived = AddressOf UpdateMsgReceived
        If Me.InvokeRequired Then
            Me.Invoke(x, e)
        Else
            UpdateMsgReceived(e)
        End If
    End Sub
    Private Sub UpdateMsgReceived(ByVal e As xPLDevice.xPLEventArgs)
        Dim s() As String = e.XplMsg.RawxPL.Split(CType(xPL_Base.XPL_LF, Char))
        Dim l As String
        lbLog.Items.Add("Message from: " & e.XplMsg.Source)
        For n As Integer = 0 To CInt(IIf(UBound(s) > 7, UBound(s), 7))
            Select Case n
                Case 0 : l = "   ForMe         : " & e.IsForMe
                Case 1 : l = "   ForMeSpecific : " & e.IsForMeSpecific
                Case 2 : l = "   ForMeBroadcast: " & e.IsForMeBroadcast
                Case 3 : l = "   ForMeGroup    : " & e.IsForMeGroup
                Case 4 : l = "   FilterMatch   : " & e.IsFilterMatch
                Case 5 : l = "   Config        : " & e.IsConfig
                Case 6 : l = "   HeartBeat     : " & e.IsHeartbeat
                Case 7 : l = "   MyEcho        : " & e.IsMyEcho
                Case Else : l = ""
            End Select
            l = Microsoft.VisualBasic.Left(l & "                                   ", 30)
            If n <= UBound(s) Then
                l = l & s(n)
            End If
            lbLog.Items.Add(l)
        Next
    End Sub
#Region "MessagePassing"

    Private AlreadyUpdating As Boolean = False

    Private Sub UpdatePassing(ByVal checked As Boolean, ByVal value As xPL_Base.MessagePassingEnum)
        If Not AlreadyUpdating Then
            If checked Then
                dev.MessagePassing = dev.MessagePassing Or value
            Else
                dev.MessagePassing = CType((dev.MessagePassing Or value) - value, xPL_Base.MessagePassingEnum)
            End If
            Call UpdatePassingDisplay()
        End If
    End Sub

    Private Sub UpdatePassingDisplay()
        If Not AlreadyUpdating Then
            AlreadyUpdating = True
            chkAll.Checked = (MessagePassingEnum.All Or dev.MessagePassing) = dev.MessagePassing
            chkDoNotApplyFilters.Checked = (MessagePassingEnum.DoNotApplyFilters Or dev.MessagePassing) = dev.MessagePassing
            chkPassMyConfigStuff.Checked = (MessagePassingEnum.PassMyConfigStuff Or dev.MessagePassing) = dev.MessagePassing
            chkPassMyHeartbeatStuff.Checked = (MessagePassingEnum.PassMyHeartbeatStuff Or dev.MessagePassing) = dev.MessagePassing
            chkPassMyOwnEcho.Checked = (MessagePassingEnum.PassMyOwnEcho Or dev.MessagePassing) = dev.MessagePassing
            chkPassOthersConfig.Checked = (MessagePassingEnum.PassOthersConfig Or dev.MessagePassing) = dev.MessagePassing
            chkPassOthersHeartbeats.Checked = (MessagePassingEnum.PassOthersHeartbeats Or dev.MessagePassing) = dev.MessagePassing
            chkPassWhileAwaitingConfig.Checked = (MessagePassingEnum.PassWhileAwaitingConfig Or dev.MessagePassing) = dev.MessagePassing
            chkToBeHandledOnly.Checked = (MessagePassingEnum.ToBeHandledOnly Or dev.MessagePassing) = dev.MessagePassing
            AlreadyUpdating = False
        End If
    End Sub

    Private Sub chkAll_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkAll.CheckedChanged
        UpdatePassing(chkAll.Checked, MessagePassingEnum.All)
    End Sub
    Private Sub chkToBeHandledOnly_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkToBeHandledOnly.CheckedChanged
        UpdatePassing(chkToBeHandledOnly.Checked, MessagePassingEnum.ToBeHandledOnly)
    End Sub
    Private Sub chkPassWhileAwaitingConfig_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkPassWhileAwaitingConfig.CheckedChanged
        UpdatePassing(chkPassWhileAwaitingConfig.Checked, MessagePassingEnum.PassWhileAwaitingConfig)
    End Sub
    Private Sub chkDoNotApplyFilters_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkDoNotApplyFilters.CheckedChanged
        UpdatePassing(chkDoNotApplyFilters.Checked, MessagePassingEnum.DoNotApplyFilters)
    End Sub
    Private Sub chkPassMyHeartbeatStuff_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkPassMyHeartbeatStuff.CheckedChanged
        UpdatePassing(chkPassMyHeartbeatStuff.Checked, MessagePassingEnum.PassMyHeartbeatStuff)
    End Sub
    Private Sub chkPassMyConfigStuff_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkPassMyConfigStuff.CheckedChanged
        UpdatePassing(chkPassMyConfigStuff.Checked, MessagePassingEnum.PassMyConfigStuff)
    End Sub
    Private Sub chkPassMyOwnEcho_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkPassMyOwnEcho.CheckedChanged
        UpdatePassing(chkPassMyOwnEcho.Checked, MessagePassingEnum.PassMyOwnEcho)
    End Sub
    Private Sub chkPassOthersHeartbeats_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkPassOthersHeartbeats.CheckedChanged
        UpdatePassing(chkPassOthersHeartbeats.Checked, MessagePassingEnum.PassOthersHeartbeats)
    End Sub
    Private Sub chkPassOthersConfig_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkPassOthersConfig.CheckedChanged
        UpdatePassing(chkPassOthersConfig.Checked, MessagePassingEnum.PassOthersConfig)
    End Sub

#End Region

    Private Sub btnSendHeartBeatRequest_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSendHeartBeatRequest.Click
        xPLNetwork.RequestHeartbeat(dev)
    End Sub

    Private Sub btnScanNetwork_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnScanNetwork.Click
        If Not xPLNetwork.ScanASyncRunning Then
            xPLNetwork.Reset()
            xPLNetwork.ScanASync(dev)
        Else
            MsgBox("Scan is still running, please wait until completed (takes appr 10-15 seconds)")
        End If
    End Sub

    Private Sub ButtonClear_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonClear.Click
        lbLog.Items.Clear()
    End Sub
End Class