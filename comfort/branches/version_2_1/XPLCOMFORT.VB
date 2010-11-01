'* xPL Comfort UCM Gateway Service
'*
'* Copyright (C) 2003 Ian Lowe
'* http://www.xplproject.org.uk
'*
'* Based upon prior work Copyright (C) 2003 John Bent
'* http://www.xpl.myby.co.uk
'*
'* This program is free software; you can redistribute it and/or
'* modify it under the terms of the GNU General Public License
'* as published by the Free Software Foundation; either version 2
'* of the License, or (at your option) any later version.
'* 
'* This program is distributed in the hope that it will be useful,
'* but WITHOUT ANY WARRANTY; without even the implied warranty of
'* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'* GNU General Public License for more details.
'*
'* You should have received a copy of the GNU General Public License
'* along with this program; if not, write to the Free Software
'* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
'*
Option Strict On

Public Class xplcomfort
    Inherits System.ServiceProcess.ServiceBase

    Private WithEvents myXplListener As xpllib.XplListener
    Private WithEvents UCM As clsUCM

    Private Structure x10Command
        Dim HouseCode As String
        Dim DeviceCode As String
        Dim Command As Short
        Dim Level As Short
        Dim Data2 As Short
    End Structure

    Private Const X10_SELECT As Integer = -1
    Private Const X10_ALL_UNITS_OFF As Integer = 0
    Private Const X10_ALL_LIGHTS_ON As Integer = 1
    Private Const X10_ON As Integer = 2
    Private Const X10_OFF As Integer = 3
    Private Const X10_DIM As Integer = 4
    Private Const X10_BRIGHT As Integer = 5
    Private Const X10_ALL_LIGHTS_OFF As Integer = 6
    Private Const X10_EXTENDED_CODE As Integer = 7
    Private Const X10_HAIL_REQUEST As Integer = 8
    Private Const X10_HAIL_ACK As Integer = 9
    Private Const X10_PRESET_DIM_1 As Integer = 10
    Private Const X10_PRESET_DIM_2 As Integer = 11
    Private Const X10_X_DATA_XFER As Integer = 12
    Private Const X10_STATUS_ON As Integer = 13
    Private Const X10_STATUS_OFF As Integer = 14
    Private Const X10_STATUS_REQUEST As Integer = 15


#Region " Component Designer generated code "

    Public Sub New()
        MyBase.New()

        ' This call is required by the Component Designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call

    End Sub

    'UserService overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    ' The main entry point for the process
    <MTAThread()> _
      Shared Sub Main()
        Dim ServicesToRun() As System.ServiceProcess.ServiceBase

        ' More than one NT Service may run within the same process. To add
        ' another service to this process, change the following line to
        ' create a second service object. For example,
        '
        ServicesToRun = New System.ServiceProcess.ServiceBase() {New xplcomfort}

        System.ServiceProcess.ServiceBase.Run(ServicesToRun)

    End Sub

    'Required by the Component Designer
    Private components As System.ComponentModel.IContainer

    ' NOTE: The following procedure is required by the Component Designer
    ' It can be modified using the Component Designer.  
    ' Do not modify it using the code editor.

    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        '
        'xplcomfort
        '
        Me.ServiceName = "XPLCOMFORT"

    End Sub

#End Region

    Protected Overrides Sub OnStop()
        ' Shut down everything
        Try
            myXplListener.SaveState()
            myXplListener = Nothing
        Catch ex As Exception
            If Not EventLog Is Nothing Then
                EventLog.WriteEntry("Error while closing down: " & ex.ToString())
            End If
        End Try
    End Sub

    Protected Overrides Sub OnStart(ByVal args() As String)
        ' Initialise the XPL listener
        Try
            myXplListener = New xpllib.XplListener("wmute-comfort", 1)

            ' Add supported remote config items
            myXplListener.ConfigItems.Add("comport", "1")
            myXplListener.ConfigItems.Add("pincode", "1234")

            If myXplListener.AwaitingConfiguration Then
                myXplListener.Filters.Add(New xpllib.XplListener.XplFilter(xpllib.XplMessageTypes.Command, "*", "*", "*", "x10", "*"))
            End If

            myXplListener.Listen()
        Catch ex As Exception
            If Not EventLog Is Nothing Then
                EventLog.WriteEntry("XPL initialisation failed: " & ex.ToString())
            End If
        End Try

        ' Probe the UCM, and Initialise serial Comms
        InitUCM()
    End Sub

    Private Sub UCM_X10Event(ByVal sender As Object, ByVal devices As String, ByVal housecode As String, ByVal functionCode As Integer, ByVal extra As Integer, ByVal data2 As Integer) Handles UCM.X10Event
        Try
            Dim xPLMsg As String
            Dim UseDevices As Boolean
            Dim UseLevel As Boolean
            Dim strLevel As String
            Dim x As Integer

            ' broadcast x10 event
            UseDevices = False
            UseLevel = False
            Select Case functionCode
                Case X10_ON
                    xPLMsg = "Command=ON" + Chr(10)
                    UseDevices = True
                Case X10_OFF
                    xPLMsg = "Command=OFF" + Chr(10)
                    UseDevices = True
                Case X10_STATUS_REQUEST
                    xPLMsg = "Command=STATUS" & vbLf
                    UseDevices = True
                Case X10_STATUS_ON
                    xPLMsg = "Command=STATUS_ON" & vbLf
                    UseDevices = True
                Case X10_STATUS_OFF
                    xPLMsg = "Command=STATUS_OFF" & vbLf
                    UseDevices = True
                Case X10_DIM
                    xPLMsg = "Command=DIM" + Chr(10)
                    If Val(extra) > 0 Then
                        strLevel = "Level=" & Val(extra) & Chr(10)
                        UseLevel = True
                    End If
                    xPLMsg &= "House=" & housecode & vbLf
                Case X10_BRIGHT
                    xPLMsg = "Command=BRIGHT" + Chr(10)
                    If extra > 0 Then
                        strLevel = "Level=" & Val(extra) & Chr(10)
                        UseLevel = True
                    End If
                    xPLMsg &= "House=" & housecode & vbLf
                Case X10_ALL_LIGHTS_ON
                    xPLMsg = "Command=ALL_LIGHTS_ON" + Chr(10)
                    xPLMsg = xPLMsg + "House=" + housecode + Chr(10)
                Case X10_ALL_LIGHTS_OFF
                    xPLMsg = "Command=ALL_LIGHTS_OFF" + Chr(10)
                    xPLMsg = xPLMsg + "House=" + housecode + Chr(10)
                Case X10_ALL_UNITS_OFF
                    xPLMsg = "Command=ALL_UNITS_OFF" + Chr(10)
                    xPLMsg = xPLMsg + "House=" + housecode + Chr(10)
                Case X10_EXTENDED_CODE
                    xPLMsg = "Command=EXTENDED" & vbLf
                    UseDevices = True
            End Select

            ' devices
            If UseDevices = True Then
                devices = devices.Trim()
                devices = devices.Replace(" ", ",")
                If Len(devices) < 2 Then Exit Sub ' not valid
                xPLMsg = xPLMsg + "Device=" + devices + Chr(10)
            End If

            ' level
            If UseLevel = True Then xPLMsg = xPLMsg + strLevel

            ' send message            
            If sender Is Nothing Then
                myXplListener.SendMessage("xpl-trig", "*", "x10.confirm", xPLMsg)
            Else
                myXplListener.SendMessage("xpl-trig", "*", "x10.basic", xPLMsg)
            End If
        Catch ex As Exception
            If Not EventLog Is Nothing Then
                EventLog.WriteEntry("UCM_X10Event failed with the error: " & ex.ToString())
            End If
        End Try
    End Sub

    Private Sub myXplListener_XplMessageReceived(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs) Handles myXplListener.XplMessageReceived
        ' If not an x10 message, exit
        If Not e.XplMsg.XPL_Msg(1).Section.ToLower.StartsWith("x10.") Then
            Exit Sub
        End If
        Try
            Dim X10Msg As x10Command
            Dim X10_Cmd As String
            Dim strDevices As String, strHouses As String, strDevice As String
            Dim x As Integer, y As Integer
            Dim lstDevices(16) As String
            X10_Cmd = e.XplMsg.GetParam(1, "command")
            X10Msg.Level = 0
            Select Case UCase(X10_Cmd)
                Case "SELECT"
                    X10Msg.Command = X10_SELECT
                Case "ALL_UNITS_OFF"
                    X10Msg.Command = X10_ALL_UNITS_OFF
                Case "ALL_LIGHTS_ON"
                    X10Msg.Command = X10_ALL_LIGHTS_ON
                Case "ON"
                    X10Msg.Command = X10_ON
                Case "OFF"
                    X10Msg.Command = X10_OFF
                Case "DIM"
                    X10Msg.Command = X10_DIM
                    X10Msg.Level = CShort(e.XplMsg.GetParam(1, "LEVEL"))
                    If X10Msg.Level < 0 Then X10Msg.Level = 0
                    If X10Msg.Level > 100 Then X10Msg.Level = 100
                Case "BRIGHT"
                    X10Msg.Command = X10_BRIGHT
                    X10Msg.Level = CShort(e.XplMsg.GetParam(1, "LEVEL"))
                    If X10Msg.Level < 0 Then X10Msg.Level = 0
                    If X10Msg.Level > 100 Then X10Msg.Level = 100
                Case "ALL_LIGHTS_OFF"
                    X10Msg.Command = X10_ALL_LIGHTS_OFF
                Case "EXTENDED"
                    X10Msg.Command = X10_EXTENDED_CODE
                    X10Msg.Level = CShort(e.XplMsg.GetParam(1, "data1"))
                    X10Msg.Data2 = CShort(e.XplMsg.GetParam(1, "data2"))
                Case "STATUS"
                    X10Msg.Command = X10_STATUS_REQUEST
                Case Else
                    ' Message unrecognised
                    EventLog.WriteEntry("An unrecognised X10 message type was received.")
                    Exit Sub
            End Select
            ' process
            strDevices = e.XplMsg.GetParam(1, "DEVICE").ToUpper().Trim()
            strHouses = e.XplMsg.GetParam(1, "HOUSE").ToUpper().Trim()
            If strDevices <> "" And strHouses <> "" Then Exit Sub ' not valid
            If strDevices = "" And strHouses = "" Then Exit Sub ' not valid            
            If strHouses <> "" Then
                ' process by house, all commands support this except select                
                If X10Msg.Command = X10_SELECT Then Exit Sub ' not valid for house
                For y = 1 To strHouses.Length()
                    If Mid$(strHouses, y, 1) >= "A" And Mid$(strHouses, y, 1) <= "P" Then
                        X10Msg.HouseCode = Mid$(strHouses, y, 1)
                        X10Msg.DeviceCode = ""
                        X10Send(X10Msg)
                    End If
                Next y
            Else
                ' extract device list
                If strDevices.Substring(strDevices.Length - 1, 1) <> "," Then strDevices = strDevices + ","
                While strDevices <> ""
                    y = InStr(1, strDevices, ",", vbBinaryCompare)
                    strDevice = strDevices.Substring(0, y - 1)
                    strDevices = Mid$(strDevices, y + 1)
                    If Len(strDevice) < 4 Then
                        If strDevice.Substring(0, 1) >= "A" And strDevice.Substring(0, 1) <= "P" Then
                            If Val(Mid$(strDevice, 2)) >= 1 And Val(Mid$(strDevice, 2)) <= 16 Then
                                ' got valid device
                                y = Asc(strDevice.Substring(0, 1)) - 64
                                lstDevices(y) = lstDevices(y) + "+" & Val(Mid$(strDevice, 2))
                            End If
                        End If
                    End If
                End While
                ' validate command allows device & excecute per housecode                
                For y = 1 To 16
                    If lstDevices(y) <> "" Then
                        lstDevices(y) = Mid$(lstDevices(y), 2)
                        Select Case X10Msg.Command
                            Case X10_SELECT, X10_ON, X10_OFF, X10_DIM, X10_BRIGHT, X10_EXTENDED_CODE, X10_STATUS_REQUEST
                                X10Msg.HouseCode = Chr(64 + y)
                                X10Msg.DeviceCode = lstDevices(y)
                                Call X10Send(X10Msg)
                            Case Else
                                ' not supported for device
                        End Select
                    End If
                Next y
            End If
        Catch ex As Exception
            If Not EventLog Is Nothing Then
                EventLog.WriteEntry("Failed to process request to send X10 command: " & ex.ToString())
            End If
        End Try
    End Sub

    Private Sub X10Send(ByVal X10Msg As x10Command)
        Try
            Dim xPLMsg As String

            ' send messages & xpl trigger confirmation
            Select Case X10Msg.Command
                Case X10_SELECT, X10_ON, X10_OFF, X10_EXTENDED_CODE, X10_STATUS_REQUEST
                    UCM.Exec(X10Msg.HouseCode, X10Msg.DeviceCode, X10Msg.Command, 0, X10Msg.Level, X10Msg.Data2)
                    Call UCM_X10Event(Nothing, X10Msg.HouseCode & X10Msg.DeviceCode, X10Msg.HouseCode, X10Msg.Command, 0, 0)
                Case X10_DIM, X10_BRIGHT
                    UCM.Exec(X10Msg.HouseCode, X10Msg.DeviceCode, X10Msg.Command, X10Msg.Level, CShort(0), 0)
                    Call UCM_X10Event(Nothing, X10Msg.HouseCode & X10Msg.DeviceCode, X10Msg.HouseCode, X10Msg.Command, X10Msg.Level, X10Msg.Data2)
                Case Else
                    UCM.Exec(X10Msg.HouseCode, "", X10Msg.Command, CShort(0), CShort(0), 0)
                    Call UCM_X10Event(Nothing, "", X10Msg.HouseCode, X10Msg.Command, 0, 0)
            End Select
        Catch ex As Exception
            If Not EventLog Is Nothing Then
                EventLog.WriteEntry("X10Send failed. Housecode=" & X10Msg.HouseCode & ", device=" & X10Msg.DeviceCode & ", command=" & X10Msg.Command & ". Exception was: " & ex.ToString())
            End If
        End Try
    End Sub

    Private Sub InitUCM()
        Try
            Dim ret As Integer
            UCM = New clsUCM
            UCM.comPort = "COM" & myXplListener.ConfigItems.Item("comport") & ":"
            ret = UCM.Init
            Select Case ret
                Case 0 ' UCM found OK
                    If Not EventLog Is Nothing Then
                        EventLog.WriteEntry("Comfort UCM successfully initialised on " & UCM.comPort.ToString() & ".")
                    End If
                Case 1 ' UCM not found
                    If Not EventLog Is Nothing Then
                        EventLog.WriteEntry("No Comfort UCM was found on COM" & UCM.comPort.ToString() & ".")
                    End If
                    Exit Sub
                Case Else ' COM port error
                    If Not EventLog Is Nothing Then
                        EventLog.WriteEntry("COM port error " & ret.ToString() & " on COM" & UCM.comPort.ToString() & ".")
                    End If
                    Exit Sub
            End Select
        Catch ex As Exception
            If Not EventLog Is Nothing Then
                EventLog.WriteEntry("Comfort UCM initialisation failed: " & ex.ToString())
            End If
        End Try
    End Sub

End Class
