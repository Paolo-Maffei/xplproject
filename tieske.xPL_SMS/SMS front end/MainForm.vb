Option Strict On
Imports xPL
Imports xPL.xPL_Base
Imports Microsoft

Public Class frmFrontEnd
    Private xDev As xPLDevice
    Private SendThrough As New ArrayList

    Private Sub SetupDefaults()
        xDev = New xPLDevice
        xDev.Configurable = True
        xDev.VendorID = "tieske"
        xDev.DeviceID = "smsfront"
        xDev.InstanceIDType = InstanceCreation.HostNameBased
        xDev.InstanceID = VisualBasic.Left(RemoveInvalidxPLchars(Environment.UserName & xDev.InstanceID, XPL_STRING_TYPES.OtherElements), 16)
    End Sub
    Private Sub SetupHandlers()
        AddHandler xPLNetwork.xPLDeviceFound, AddressOf DeviceUpdate
        AddHandler xPLNetwork.xPLDeviceLost, AddressOf DeviceUpdate
        AddHandler xDev.xPLStatusChange, AddressOf StatusChange
    End Sub
    Private Sub frmFrontEnd_Shown(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Shown
        ' Add code here to start your service. This method should set things
        ' in motion so your service can do its work.

        ' set form icon
        Me.Icon = xPL.xPL_Base.XPL_Icon

        If My.Settings.xPLDevice <> "" Then
            ' Get settings and restore xPL device
            Try
                xDev = New xPL.xPLDevice(My.Settings.xPLDevice, False)
                ' now call config changed event handler to propagate settings to the SMSinterface
                'ConfigChanged(xDev)
            Catch ex As Exception
                ' something is wrong, fallback to defaults
                My.Settings.xPLDevice = ""
            End Try
        End If

        If My.Settings.xPLDevice = "" Then
            ' We're new in town, setup defaults
            SetupDefaults()
        End If

        ' attach callbacks and event handlers
        SetupHandlers()

        ' now go online...
        xDev.Enabled = True
    End Sub
    Private Sub frmFrontEnd_FormClosed() Handles MyBase.FormClosed
        ' cleanup handlers and callbacks
        If Not xDev Is Nothing Then
            AddHandler xPLNetwork.xPLDeviceFound, AddressOf DeviceUpdate
            AddHandler xPLNetwork.xPLDeviceLost, AddressOf DeviceUpdate
            AddHandler xDev.xPLStatusChange, AddressOf StatusChange
            ' Store settings
            My.Settings.xPLDevice = xPL.xPLListener.GetState(GetVersionNumber(2))
            My.Settings.Save()
            ' destroy device
            xDev.Dispose()
            ' leave this world
        End If
    End Sub
    Private Sub DeviceUpdate(ByVal e As xPLNetwork.xPLNetworkEventArgs)
        If e.ExtDevice.Address.Vendor = "tieske" And _
           e.ExtDevice.Address.Device = "sms" Then
            ' found a device to send through
            If e.ExtDevice.Ended Or e.ExtDevice.TimedOut Then
                ' device was lost from the network
                If SendThrough.IndexOf(e.ExtDevice.Address.ToString) <> -1 Then
                    SendThrough.Remove(e.ExtDevice.Address.ToString)
                End If
            Else
                ' device was found on the network
                If SendThrough.IndexOf(e.ExtDevice.Address.ToString) = -1 Then
                    SendThrough.Add(e.ExtDevice.Address.ToString)
                End If
            End If
        End If
        ' if we have a device to send through, then enable send button
        If btnSend.InvokeRequired Then
            Dim d As New SendButtonSafe(AddressOf SendButton)
            Me.Invoke(d, (SendThrough.Count > 0))

        Else
            SendButton(SendThrough.Count > 0)
        End If
    End Sub
    Delegate Sub SendButtonSafe(ByVal enab As Boolean)
    Private Sub SendButton(ByVal enab As Boolean)
        Me.btnSend.Enabled = enab
    End Sub
    Private Sub StatusChange(ByVal xpldev As xPLDevice, ByVal prev As xPLDeviceStatus, ByVal curr As xPLDeviceStatus)
        If curr = xPLDeviceStatus.Online Then
            ' moved to online status, reset network and request device heartbeats
            xPLNetwork.Reset()
            SendThrough.Clear()
            xPLNetwork.RequestHeartbeat(xDev)
        End If
    End Sub
    Private Sub btnSend_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSend.Click
        Dim msg As xPLMessage
        Dim MsgText As String
        Dim Recip As String
        ' Check recipient, and cleanup
        If Trim(Me.tbRecipient.Text) = "" Then
            MsgBox("Please enter a recipient for the message.")
            Me.tbRecipient.Focus()
            Exit Sub
        Else
            Recip = tbRecipient.Text
            Recip = RemoveInvalidxPLchars(Trim(Recip), XPL_STRING_TYPES.Values)
        End If
        ' Check message, and cleanup
        If Trim(Me.tbMessage.Text) = "" Then
            MsgBox("Please enter a message.")
            Me.tbMessage.Focus()
            Exit Sub
        Else
            MsgText = Me.tbMessage.Text
            MsgText = MsgText.Replace(vbCrLf, " ")
            MsgText = RemoveInvalidxPLchars(Trim(MsgText), XPL_STRING_TYPES.Values)
            If Me.tbMessage.Text <> MsgText Then
                Me.tbMessage.Text = MsgText
                If MsgBox("The message contained invalid characters. The message that will be sent is: " & vbCrLf & vbCrLf & _
                   MsgText & vbCrLf & vbCrLf & "Would you like to continue sending the message?", _
                   MsgBoxStyle.OkCancel Or MsgBoxStyle.DefaultButton1 Or MsgBoxStyle.Question, "Invalid characters") = MsgBoxResult.Cancel Then
                    ' don't sent
                    Exit Sub
                End If
            End If
        End If
        msg = New xPLMessage
        msg.Source = xDev.Address
        msg.Target = CStr(SendThrough(0))
        msg.MsgType = xPLMessageTypeEnum.Command
        msg.Schema = "sendmsg.basic"
        msg.KeyValueList.Add("body", MsgText)
        msg.KeyValueList.Add("to", Recip)
        msg.Send()
        Me.tbMessage.Focus()
        Me.tbMessage.SelectAll()
        MsgBox("Message '" & Me.tbMessage.Text & "' has been sent to '" & Me.tbRecipient.Text & "'!", MsgBoxStyle.Information)
    End Sub
End Class
