Option Strict On
Imports xPL
Imports xPL.xPL_Base

Public Class MainInterface

    Friend xPLDev As xPL.xPLDevice

#Region "Opening and closing the form"
    Private Sub MainInterface_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        ' set form icon
        Me.Icon = XPL_Icon
        ' set object handlers and rescan network
        AddHandler xPLDev.xPLStatusChange, AddressOf StatusChange
        AddHandler xPL.xPLNetwork.xPLDeviceFound, AddressOf DeviceChange
        AddHandler xPL.xPLNetwork.xPLDeviceLost, AddressOf DeviceChange
        xPL.xPLNetwork.Reset()
        xPL.xPLNetwork.RequestHeartbeat(xPLDev)
    End Sub

    Private Sub MainInterface_FormClosed() Handles MyBase.FormClosed
        RemoveHandler xPLDev.xPLStatusChange, AddressOf StatusChange
        RemoveHandler xPL.xPLNetwork.xPLDeviceFound, AddressOf DeviceChange
        RemoveHandler xPL.xPLNetwork.xPLDeviceLost, AddressOf DeviceChange
    End Sub
#End Region

#Region "Buttons"
    Private Sub btnClose_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click
        Me.Close()
    End Sub

    Private Sub btnSearch_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSearch.Click
        xPL.xPLNetwork.Reset()
        Me.lbSMSDevices.Items.Clear()
        xPL.xPLNetwork.RequestHeartbeat(xPLDev)
    End Sub

    Private Sub btnConfigure_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnConfigure.Click
        'go configure device
        Dim addr As xPL.xPLAddress
        Try
            addr = New xPL.xPLAddress(xPL.xPL_Base.xPLAddressType.Source, CStr(lbSMSDevices.SelectedItem))
            ' go configure single device
            MainModule.ConfigureDevice(addr)
        Catch ex As Exception
            MsgBox("Please select an xPL Device to configure from the list", MsgBoxStyle.Information)
        End Try
    End Sub
#End Region

    Private Sub DeviceChange(ByVal e As xPL.xPLNetwork.xPLNetworkEventArgs)
        ' go update device list
        Dim found As Boolean = False
        If e.ExtDevice.Address.Vendor = "tieske" And _
           e.ExtDevice.Address.Device = "sms" Then
            ' found a device to send through
            If e.ExtDevice.Ended Or e.ExtDevice.TimedOut Then
                ' device was lost from the network
                found = False

            Else
                ' device was found on the network
                found = True

            End If
        End If
        ' if we have a device to send through, then enable send button
        If lbSMSDevices.InvokeRequired Then
            Dim d As New UpdateListSafe(AddressOf UpdateList)
            Me.Invoke(d, e.ExtDevice.Address.ToString, found)

        Else
            UpdateList(e.ExtDevice.Address.ToString, found)
        End If
    End Sub
    Delegate Sub UpdateListSafe(ByVal addr As String, ByVal found As Boolean)
    Private Sub UpdateList(ByVal addr As String, ByVal found As Boolean)
        If lbSMSDevices.Items.IndexOf(addr) = -1 Then
            ' not in the list
            If found Then lbSMSDevices.Items.Add(addr)
        Else
            ' already in list
            If Not found Then lbSMSDevices.Items.Remove(addr)
        End If
        btnConfigure.Enabled = (lbSMSDevices.Items.Count > 0)
    End Sub
    Private Sub StatusChange(ByVal xpldev As xPLDevice, ByVal prev As xPLDeviceStatus, ByVal curr As xPLDeviceStatus)
        If curr = xPLDeviceStatus.Online Then
            ' moved to online status, reset network and request device heartbeats
            xPLNetwork.Reset()
            xPLNetwork.RequestHeartbeat(xpldev)
        End If
    End Sub

    Private Sub lbSMSDevices_DoubleClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lbSMSDevices.DoubleClick
        btnConfigure_Click(Nothing, Nothing)
    End Sub
End Class