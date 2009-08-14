VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "MSWINSCK.OCX"
Begin VB.UserControl xPLCtl 
   CanGetFocus     =   0   'False
   ClientHeight    =   720
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   720
   InvisibleAtRuntime=   -1  'True
   Picture         =   "xPLCtl.ctx":0000
   ScaleHeight     =   720
   ScaleWidth      =   720
   ToolboxBitmap   =   "xPLCtl.ctx":1B42
   Begin VB.Timer xPLTmr 
      Enabled         =   0   'False
      Interval        =   60000
      Left            =   120
      Top             =   240
   End
   Begin MSWinsockLib.Winsock udpxPL 
      Left            =   0
      Top             =   0
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
      Protocol        =   1
   End
End
Attribute VB_Name = "xPLCtl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'**************************************
'* xPL OCX
'*
'* Copyright (C) 2005 Ian Lowe
'* http://www.xplproject.org.uk
'* Based on work
'*
'* Copyright (C) 2003 Tony Tofts
'* http://www.xplhal.com
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
'**************************************
'* As a special exception, the copyright holders of this library give you
'* permission to link this library with independent modules to produce an
'* executable, regardless of the license terms of these independent
'* modules, and to copy and distribute the resulting executable under
'* terms of your choice, provided that you also meet, for each linked
'* independent module, the terms and conditions of the license of that
'* module. An independent module is a module which is not derived from
'* or based on this library. If you modify this library, you may extend
'* this exception to your version of the library, but you are not
'* obligated to do so. If you do not wish to do so, delete this
'* exception statement from your version.
'**************************************

Option Explicit

Public Type xPLMsg
    xPLType As String
    Hop As Integer
    source As String
    Target As String
    Schema As String
    NamePairs As Integer
    Names() As String
    Values() As String
    Raw As String
End Type

Public Event Received(Message As xPLMsg)
Public Event Config(Item As String, value As String, Occurance As Integer)
Public Event Configured(source As String)
Public Event xPLRX(Msg As String)
Public Event xPLTX(Msg As String)
Public Event JoinedxPLNetwork(HBeatCount As Integer)

Public Function Initialise(source As String, WaitForConfig As Boolean, Interval As Long) As Boolean

    Dim chkSource As xPL_SourceType
    
    ' check
    Initialise = False
    xPL_Source = xPLSourceChk(source)
    If xPL_Source.Valid = False Then Exit Function
    xPL_Source.OldInstance = xPL_Source.Instance
    If Interval < 5 Then Interval = 5
    If Interval > 30 Then Interval = 30
    xPL_Interval = Interval
    Select Case WaitForConfig
    Case True
        xPL_HBeat = "config.app"
        xPL_Configured = False
        xPL_Counter = 1
    Case False
        xPL_HBeat = "hbeat.app"
        xPL_Configured = True
        xPL_Counter = 1
    End Select
    
    ' udp
    xPL_Port = 50000
    
    ' get broadcast from registry
    xPL_BCast = GetRegistryValue(&H80000002, "SOFTWARE\xPL", "BroadcastAddress", "255.255.255.255")
    
    ' define standard source
    xPL_SourceCount = 0
    ReDim xPL_Sources(xPL_SourceCount)
    xPL_Sources(0) = "*." + xPL_Source.Vendor + "." + xPL_Source.Device + "." + xPL_Source.Instance + ".*.*"
    
    ' define standard configurable items
    xPL_ConfigCount = 4
    ReDim xPL_Configs(xPL_ConfigCount)
    xPL_Configs(1).Item = "NEWCONF"
    xPL_Configs(1).Type = "RECONF"
    If xPL_HBeat = "hbeat.app" Then xPL_Configs(1).Type = "OPTION"
    xPL_Configs(1).Number = 1
    ReDim xPL_Configs(1).value(1)
    xPL_Configs(1).value(1) = xPL_Source.Instance
    ReDim xPL_Configs(1).Default(1)
    xPL_Configs(1).Default(1) = xPL_Source.Instance
    
    xPL_Configs(2).Item = "INTERVAL"
    xPL_Configs(2).Type = "RECONF"
    xPL_Configs(2).Number = 1
    ReDim xPL_Configs(2).value(1)
    xPL_Configs(2).value(1) = xPL_Interval
    ReDim xPL_Configs(2).Default(1)
    xPL_Configs(2).Default(1) = xPL_Interval
    
    xPL_Configs(3).Item = "GROUP"
    xPL_Configs(3).Type = "OPTION"
    xPL_Configs(3).Number = 16
    ReDim xPL_Configs(3).value(0)
    ReDim xPL_Configs(3).Default(16)
    
    xPL_Configs(4).Item = "FILTER"
    xPL_Configs(4).Type = "OPTION"
    xPL_Configs(4).Number = 16
    ReDim xPL_Configs(4).value(0)
    ReDim xPL_Configs(4).Default(16)
    
    ' list default configs
    xPL_ConfigList = "#NEWCONF#INTERVAL#GROUP#FILTER#"
    
    ' define my target and groups
    xPL_TargetCount = 0
    ReDim xPL_Targets(xPL_TargetCount)
    xPL_Targets(0) = UCase(xPL_Source.Vendor + "-" + xPL_Source.Device + "." + xPL_Source.Instance)
    
    ' source
    Initialise = True
    xPL_PreInitDone = True
    
End Function

Public Function Start() As Boolean
    
    Dim TryPort As Boolean
    
    ' initialise
    Start = False
    If xPL_PreInitDone = False Then Exit Function
    
    ' get stored port, if available
    xPL_Port = GetRegistryValueNum(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.Instance, "\xPLHubPort", 50000)
    If xPL_Port < 50000 Or xPL_Port > 59999 Then xPL_Port = 50000
    If xPL_Port <> 50000 Then TryPort = True
    
    ' udp
    udpxPL.Protocol = sckUDPProtocol
    udpxPL.RemoteHost = xPL_BCast
    udpxPL.RemotePort = 3865
    udpxPL.LocalPort = xPL_Port
resumeinit:
    On Error GoTo initfailed
    udpxPL.SendData "HELLO"
    On Error GoTo 0
itwasok:
    xPL_IP = udpxPL.LocalIP

    ' store hub port and retrieve settings if configured
    If UCase(Left$(xPL_HBeat, 7)) <> "CONFIG." Then
        ' store
        Call CheckRegistry
        Call SetRegistryValue(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.Instance, "xPLHubPort", xPL_Port)
    End If
    
    ' retrieve existing configs if available
    Call LoadxPL
    
    ' initial heartbeat
    Call xPLHeartBeat
    
    ' Heartbeat every 3 seconds for first 90 seconds (ie, first 30 heartbeats)
    ' until we have joined the network, then drop to normal rate.
    xPLTmr.Interval = 3000
    xPL_HBeatCount = 1
    xPL_JoinedNetwork = False
    
    ' start hbeat
    Start = True
    xPLTmr.Enabled = True
    Exit Function
    
initfailed:
    If Err = 126 Then
        On Error GoTo 0
        GoTo itwasok
    End If
    If Err = 10048 Then
        On Error GoTo 0
        If xPL_Port < 59999 Then
            xPL_Port = xPL_Port + 1
            If TryPort = True Then
                xPL_Port = 50000
                TryPort = False
            End If
            udpxPL.LocalPort = xPL_Port
            Resume resumeinit
        End If
    End If
    On Error GoTo 0

End Function

Private Sub udpxPL_DataArrival(ByVal bytesTotal As Long)
    
    Dim xPL_Input As String
    Dim MsgType As String
    Dim Hop As Integer
    Dim source As xPL_SourceType
    Dim chkTarget As xPL_SourceType
    Dim Target As String
    Dim Schema As String
    Dim strMsg As String
    Dim strInstance As String
    Dim strCfgList As String
    Dim usrConfig As Boolean
    Dim e As xPLCtl.xPLMsg
    Dim c As Integer
    Dim d As Integer
    Dim w As Integer
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    
    ' get data
    On Error GoTo udpfailed
    udpxPL.GetData xPL_Input, vbString
    On Error GoTo 0
    
    ' check i should be running
    If xPL_Source.Valid = False Then Exit Sub ' ignore
    
    ' validate
    If xPL_Extract(xPL_Input) = False Then Exit Sub ' not valid

    ' get message vendor, device, instance, class, type
    MsgType = xPL_Message(0).Section
    Hop = xPL_GetParam(False, "HOP", True)
    source = xPLSourceChk(xPL_GetParam(False, "SOURCE", False))
    If source.Valid = False Then Exit Sub ' not valid
    Target = xPL_GetParam(False, "TARGET", False)
    If Target <> "*" Then
        chkTarget = xPLSourceChk(xPL_GetParam(False, "TARGET", False))
        If chkTarget.Valid = False Then Exit Sub ' not valid
    End If
    Schema = xPL_Message(1).Section
    If xPLSchemaChk(Schema) = False Then Exit Sub ' not valid

    ' If I sent it, we have joined the network (my messages are being relayed by the hub)
    If UCase("*." + source.Vendor + "." + source.Device + "." + source.Instance + ".*.*") Like UCase(xPL_Sources(0)) Then
        If xPL_JoinedNetwork Then
           Exit Sub
        Else
           xPL_JoinedNetwork = True
           xPLTmr.Interval = 60000 'reset to 1 heartbeat a minute
           RaiseEvent JoinedxPLNetwork(xPL_HBeatCount)
           Exit Sub
        End If
    End If
    
    ' check for hbeat.request
    If UCase(Left$(Schema, 6)) = "HBEAT." And UCase(MsgType) = "XPL-CMND" Then
        If UCase(Schema) = "HBEAT.REQUEST" Then
            'okay, send a heartbeat
            xPL_Counter = 1
            Call xPLHeartBeat
        End If
    End If
    
    ' check for config information
    If UCase(Left$(Schema, 7)) = "CONFIG." And UCase(MsgType) = "XPL-CMND" Then
        If UCase(Schema) = "CONFIG.RESPONSE" Then
            ' config packet, but is it for me
            If UCase(Target) = UCase(xPL_Source.Vendor + "-" + xPL_Source.Device + "." + xPL_Source.Instance) Then
                For z = 1 To xPL_ConfigCount
                    xPL_Configs(z).ConfCount = 0
                Next z
                For y = 0 To xPL_Message(1).DC
                    If InStr(1, xPL_ConfigList, "#" + UCase(xPL_Message(1).Details(y).Name) + "#", vbBinaryCompare) > 0 Then
                        ' config is for me
                        For z = 1 To xPL_ConfigCount
                            If xPL_Configs(z).Item = UCase(xPL_Message(1).Details(y).Name) Then
                                d = z
                                z = xPL_ConfigCount
                            End If
                        Next z
                        Select Case UCase(xPL_Message(1).Details(y).Name)
                        Case "NEWCONF"
                            strInstance = Trim(xPL_Message(1).Details(y).value)
                            If Len(strInstance) = 0 Then strInstance = xPL_Configs(1).Default(1)
                            If Len(strInstance) > 0 And Len(strInstance) < 17 Then
                                ' got correct length instance, check characters
                                w = 0
                                For x = 1 To Len(strInstance)
                                    Select Case UCase(Mid$(strInstance, x, 1))
                                    Case "A" To "Z", "0" To "9"
                                    Case Else
                                        w = 1
                                    End Select
                                Next x
                                ' update instance & target if valid
                                If w = 0 Then
                                    xPL_Source.Instance = strInstance
                                    xPL_Targets(0) = UCase(xPL_Source.Vendor + "-" + xPL_Source.Device + "." + xPL_Source.Instance)
                                    xPL_Sources(0) = UCase("*." + xPL_Source.Vendor + "." + xPL_Source.Device + "." + xPL_Source.Instance + ".*.*")
                                    xPL_Configs(1).value(1) = xPL_Source.Instance
                                End If
                            End If
                        Case "INTERVAL"
                            xPL_Interval = Val(Trim(xPL_Message(1).Details(y).value))
                            If xPL_Interval = 0 Then xPL_Interval = Val(xPL_Configs(2).Default(1))
                            If xPL_Interval <= 5 Then xPL_Interval = 5
                            If xPL_Interval > 30 Then xPL_Interval = 30
                            xPL_Configs(2).value(1) = xPL_Interval
'                            Call KillTimer(0, nID)
'                            Call xPLHeartBeat
'                            nID = SetTimer(0, 0, xPL_Interval * 60000, AddressOf fTimerCallBack)
                        Case "GROUP"
                            If Left$(UCase(Trim(xPL_Message(1).Details(y).value)), 10) = "XPL-GROUP." Then
                                If xPL_Configs(3).ConfCount = 0 Then
                                    ' first
                                    xPL_TargetCount = 1
                                    ReDim Preserve xPL_Targets(xPL_TargetCount)
                                    xPL_Targets(xPL_TargetCount) = UCase(Trim(xPL_Message(1).Details(y).value))
                                    xPL_Configs(3).ConfCount = xPL_Configs(3).ConfCount + 1
                                    ReDim xPL_Configs(3).value(1)
                                    xPL_Configs(3).value(1) = xPL_Targets(1)
                                Else
                                    ' others
                                    If xPL_TargetCount + 1 <= xPL_Configs(d).Number Then
                                        xPL_TargetCount = xPL_TargetCount + 1
                                        ReDim Preserve xPL_Targets(xPL_TargetCount)
                                        xPL_Targets(xPL_TargetCount) = UCase(Trim(xPL_Message(1).Details(y).value))
                                        xPL_Configs(3).ConfCount = xPL_Configs(3).ConfCount + 1
                                        ReDim Preserve xPL_Configs(3).value(xPL_TargetCount)
                                        xPL_Configs(3).value(1) = xPL_Targets(xPL_TargetCount)
                                    End If
                                End If
                            End If
                            If UCase(Trim(xPL_Message(1).Details(y).value)) = "" Then
                                ' clear
                                xPL_TargetCount = 0
                                ReDim Preserve xPL_Targets(0)
                                ReDim xPL_Configs(3).value(0)
                                xPL_Configs(3).ConfCount = 0
                                For c = 1 To xPL_Configs(3).Number
                                    If xPL_Configs(3).Default(c) <> "" Then
                                        xPL_Configs(3).ConfCount = c
                                        ReDim Preserve xPL_Configs(3).value(c)
                                        xPL_Configs(3).value(c) = xPL_Configs(3).Default(c)
                                        xPL_TargetCount = xPL_TargetCount + 1
                                        ReDim Preserve xPL_Targets(xPL_TargetCount)
                                        xPL_Targets(xPL_TargetCount) = UCase(xPL_Configs(3).Default(c))
                                    Else
                                        c = xPL_Configs(3).Number
                                    End If
                                Next c
                            End If
                        Case "FILTER"
                            If UCase(Trim(xPL_Message(1).Details(y).value)) = "" Then
                                ' clear
                                xPL_SourceCount = 0
                                ReDim Preserve xPL_Sources(0)
                                ReDim xPL_Configs(4).value(0)
                                xPL_Configs(4).ConfCount = 0
                                For c = 1 To xPL_Configs(4).Number
                                    If xPL_Configs(4).Default(c) <> "" Then
                                        xPL_Configs(4).ConfCount = c
                                        ReDim Preserve xPL_Configs(4).value(c)
                                        xPL_Configs(4).value(c) = xPL_Configs(4).Default(c)
                                        xPL_SourceCount = xPL_SourceCount + 1
                                        ReDim Preserve xPL_Sources(xPL_SourceCount)
                                        xPL_Sources(xPL_SourceCount) = UCase(xPL_Configs(4).Default(c))
                                    Else
                                        c = xPL_Configs(4).Number
                                    End If
                                Next c
                            Else
                                If xPL_Configs(4).ConfCount = 0 Then
                                    ' first
                                    xPL_SourceCount = 1
                                    ReDim Preserve xPL_Sources(xPL_SourceCount)
                                    xPL_Sources(xPL_SourceCount) = UCase(Trim(xPL_Message(1).Details(y).value))
                                    xPL_Configs(4).ConfCount = xPL_Configs(4).ConfCount + 1
                                    ReDim xPL_Configs(4).value(1)
                                    xPL_Configs(4).value(1) = xPL_Sources(1)
                                Else
                                    ' others
                                    If xPL_SourceCount + 1 <= xPL_Configs(d).Number Then
                                        xPL_SourceCount = xPL_SourceCount + 1
                                        ReDim Preserve xPL_Sources(xPL_SourceCount)
                                        xPL_Sources(xPL_SourceCount) = UCase(Trim(xPL_Message(1).Details(y).value))
                                        xPL_Configs(4).ConfCount = xPL_Configs(4).ConfCount + 1
                                        ReDim Preserve xPL_Configs(4).value(xPL_SourceCount)
                                        xPL_Configs(4).value(xPL_SourceCount) = xPL_Sources(xPL_SourceCount)
                                    End If
                                End If
                            End If
                        Case Else ' user
                            usrConfig = False
                            If xPL_HBeat = "config.app" Then
                                usrConfig = True
                            Else
                                If xPL_Configs(d).Type <> "CONFIG" Then
                                    usrConfig = True
                                End If
                            End If
                            If usrConfig = True Then
                                usrConfig = False
                                If xPL_Configs(d).Number > 1 Then
                                    If UCase(Trim(xPL_Message(1).Details(y).value)) = "" Then
                                        ' clear
                                        ReDim xPL_Configs(d).value(0)
                                        xPL_Configs(d).ConfCount = 0
                                        For c = 1 To xPL_Configs(d).Number
                                            If xPL_Configs(d).Default(c) <> "" Then
                                                xPL_Configs(d).ConfCount = c
                                                ReDim Preserve xPL_Configs(d).value(c)
                                                xPL_Configs(d).value(c) = xPL_Configs(d).Default(c)
                                            Else
                                                c = xPL_Configs(d).Number
                                            End If
                                        Next c
                                    Else
                                        If xPL_Configs(d).ConfCount = 0 Then
                                            xPL_Configs(d).ConfCount = xPL_Configs(d).ConfCount + 1
                                            ReDim xPL_Configs(d).value(1)
                                            xPL_Configs(d).value(1) = Trim(xPL_Message(1).Details(y).value)
                                            usrConfig = True
                                        Else
                                            If xPL_Configs(d).ConfCount + 1 <= xPL_Configs(d).Number Then
                                                xPL_Configs(d).ConfCount = xPL_Configs(d).ConfCount + 1
                                                ReDim Preserve xPL_Configs(d).value(xPL_Configs(d).ConfCount)
                                                xPL_Configs(d).value(xPL_Configs(d).ConfCount) = Trim(xPL_Message(1).Details(y).value)
                                                usrConfig = True
                                            End If
                                        End If
                                    End If
                                Else
                                    ReDim Preserve xPL_Configs(d).value(1)
                                    xPL_Configs(d).value(1) = Trim(xPL_Message(1).Details(y).value)
                                    If xPL_Configs(d).value(1) = "" Then xPL_Configs(d).value(1) = xPL_Configs(d).Default(1)
                                    usrConfig = True
                                End If
                            End If
                            If usrConfig = True Then
                                RaiseEvent Config(xPL_Message(1).Details(y).Name, Trim(xPL_Message(1).Details(y).value), xPL_Configs(d).ConfCount)
                            End If
                        End Select
                    End If
                Next y
                xPL_HBeat = "hbeat.app"
                xPL_Configured = True
                xPL_Counter = 1
                Call xPLHeartBeat
                RaiseEvent Configured(LCase(xPL_Source.Vendor) + "-" + LCase(xPL_Source.Device) + "." + LCase(xPL_Source.Instance))
                Call SavexPL
                strCfgList = ""
                For x = 1 To xPL_ConfigCount
                    For z = 1 To UBound(xPL_Configs(x).value)
                        If Len(xPL_Configs(x).value(z)) > 0 Then
                            strCfgList = strCfgList + xPL_Configs(x).Item + "=" + Trim(xPL_Configs(x).value(z)) + Chr$(10)
                        End If
                    Next z
                Next x
                Call xPLSendXplMsg("xpl-stat", "*", "config.current", strCfgList, False)
            End If
        End If
        ' config request
        If UCase(Schema) = "CONFIG.LIST" Then
            ' config list request, but is it for me
            If UCase(Target) = UCase(xPL_Source.Vendor + "-" + xPL_Source.Device + "." + xPL_Source.Instance) Then
                ' check command
                If UCase(xPL_GetParam(True, "COMMAND", True)) = "REQUEST" Then
                    ' build config list
                    strCfgList = ""
                    For x = 1 To xPL_ConfigCount
                        strCfgList = strCfgList + xPL_Configs(x).Type + "=" + xPL_Configs(x).Item
                        If xPL_Configs(x).Number > 1 Then strCfgList = strCfgList + "[" + Mid$(Str$(xPL_Configs(x).Number), 2) + "]"
                        strCfgList = strCfgList + Chr$(10)
                    Next x
                    Call xPLSendXplMsg("xpl-stat", "*", "config.list", strCfgList, False)
                End If
            End If
        End If
        ' config current
        If UCase(Schema) = "CONFIG.CURRENT" Then
            ' config list request, but is it for me
            If UCase(Target) = UCase(xPL_Source.Vendor + "-" + xPL_Source.Device + "." + xPL_Source.Instance) Then
                ' check command
                If UCase(xPL_GetParam(True, "COMMAND", True)) = "REQUEST" Then
                    ' build config list
                    strCfgList = ""
                    For x = 1 To xPL_ConfigCount
                        For z = 1 To UBound(xPL_Configs(x).value)
                            strCfgList = strCfgList + xPL_Configs(x).Item + "=" + xPL_Configs(x).value(z) + Chr$(10)
                        Next z
                        If UBound(xPL_Configs(x).value) = 0 Then
                            strCfgList = strCfgList + xPL_Configs(x).Item + "=" + Chr$(10)
                        End If
                    Next x
                    Call xPLSendXplMsg("xpl-stat", "*", "config.current", strCfgList, False)
                End If
            End If
        End If
    End If
    
    ' ignore message if still in config state
    If xPL_Configured = False Then Exit Sub ' ignore
    If Left$(UCase(xPL_HBeat), 7) = "CONFIG." Then Exit Sub

    ' check pass thru's
    If UCase(Left$(Schema, 6)) = "HBEAT." And xPL_PassHBEAT = False Then Exit Sub
    If UCase(Left$(Schema, 7)) = "CONFIG." And xPL_PassCONFIG = False Then Exit Sub

    ' check if message is targetted
    If Target <> "*" Then
        ' is it at me
        For x = 0 To xPL_TargetCount
            If UCase(Target) = xPL_Targets(x) Then
                If x = 0 Then
                    GoTo processmessage ' got target match
                Else
                    GoTo checkmessage ' got a secondary match, pass to filters
                End If
            End If
        Next x
        ' reject targetted message not for me
        If xPL_PassNOMATCH = False Then Exit Sub
    End If
checkmessage:
    ' check message is correct source(s) and instance(s) etc
    For x = 1 To xPL_SourceCount
        If UCase(MsgType + "." + source.Vendor + "." + source.Device + "." + source.Instance + "." + Schema) Like xPL_Sources(x) Then GoTo processmessage ' got match
    Next x
    Exit Sub ' no match
    
processmessage:
    ' raise event here
    e.xPLType = MsgType
    e.Hop = Hop
    e.source = source.Vendor + "-" + source.Device + "." + source.Instance
    e.Target = Target
    e.Schema = Schema
    e.NamePairs = xPL_Message(1).DC + 1
    ReDim e.Names(e.NamePairs)
    ReDim e.Values(e.NamePairs)
    For x = 0 To xPL_Message(1).DC
        e.Names(x) = xPL_Message(1).Details(x).Name
        e.Values(x) = xPL_Message(1).Details(x).value
    Next x
    e.Raw = xPL_Input
    RaiseEvent Received(e)
    RaiseEvent xPLRX(xPL_Input)
    
    ' done
    Exit Sub

udpfailed:
    On Error GoTo 0

End Sub

Public Function SendXplMsg(MsgType As String, Target As String, Schema As String, Message As String) As Boolean

    Dim strMsg As String
    
    ' send message
    strMsg = xPLSendXplMsg(MsgType, Target, Schema, Message, False)
    If strMsg = "" Then
        SendXplMsg = False
    Else
        SendXplMsg = True
        RaiseEvent xPLTX(strMsg)
    End If
        
End Function

Private Function xPLSendXplMsg(MsgType As String, Target As String, Schema As String, Message As String, IsRaw As Boolean) As String

    Dim xPLMessage As String
    Dim chkTarget As xPL_SourceType
    Dim x As Integer
    
    ' validate message
    xPLSendXplMsg = ""
    
    ' check source
    If xPL_Source.Valid = False Then Exit Function
    
    ' check for raw
    If IsRaw = False Then
    
        ' check command type
        If MsgType = "" Then MsgType = "xpl-cmnd"
        MsgType = LCase(MsgType)
        If LCase(MsgType) <> "xpl-cmnd" And LCase(MsgType) <> "xpl-trig" And LCase(MsgType) <> "xpl-stat" Then Exit Function
        
        ' check target
        If Target = "" Or Target = "*" Then
            ' broadcast
            Target = "*"
        Else
            ' validate
            chkTarget = xPLSourceChk(Target)
            If chkTarget.Valid = False Then Exit Function
        End If
        Target = LCase(Target)
        
        ' check schema
        If Schema = "" Then Exit Function
        If xPLSchemaChk(Schema) = False Then Exit Function
        Schema = LCase(Schema)
        
        ' check message
        If Right$(Message, 1) <> Chr$(10) Then Message = Message + Chr$(10)
        If xPLMessageChk(Message) = False Then Exit Function
        Message = xPLMessageToLower(Message)
        
        ' build message
        xPLMessage = MsgType & Chr$(10) & "{" & Chr$(10)
        xPLMessage = xPLMessage & "hop=1" & Chr$(10)
        xPLMessage = xPLMessage & "source=" & LCase(xPL_Source.Vendor) & "-" & LCase(xPL_Source.Device) & "." & LCase(xPL_Source.Instance) & Chr$(10)
        xPLMessage = xPLMessage & "target=" & Target & Chr$(10)
        xPLMessage = xPLMessage & "}" & Chr$(10)
        xPLMessage = xPLMessage & Schema & Chr$(10) & "{" & Chr$(10)
        If Right$(Message, 1) <> Chr$(10) Then Message = Message + Chr$(10)
        xPLMessage = xPLMessage & Message
        xPLMessage = xPLMessage & "}" & Chr$(10)
    Else
        ' raw
        xPLMessage = Message
    End If
    
    ' send
    udpxPL.RemoteHost = xPL_BCast
    udpxPL.RemotePort = 3865
    On Error GoTo sendfailed
    udpxPL.SendData xPLMessage
    On Error GoTo 0
sendwasok:
    xPLSendXplMsg = xPLMessage
    Exit Function
    
sendfailed:
    If Err = 126 Then
        On Error GoTo 0
        GoTo sendwasok
    End If
    On Error GoTo 0
    
End Function

Public Property Get StatusSchema() As String
    
    ' return status schema
    StatusSchema = xPL_StatusSchema
    
End Property

Public Property Let StatusSchema(ByVal Schema As String)

    ' set status schema
    If xPLSchemaChk(Schema) = True Then xPL_StatusSchema = Schema
    
End Property

Public Property Get StatusMsg() As String
    
    ' return status message
    StatusMsg = xPL_StatusMsg
    
End Property

Public Property Let StatusMsg(ByVal Message As String)
    
    ' set status message
    If xPLMessageChk(Message) = True Then xPL_StatusMsg = Message
    
End Property

Public Function GroupsAdd(GroupName As String) As Boolean

    Dim g As xPL_SourceType
    
    ' check group
    GroupsAdd = False
    If UCase(Left$(GroupName, 10)) <> "XPL-GROUP." Then Exit Function
    g = xPLSourceChk(GroupName)
    If g.Valid = False Then Exit Function
    
    ' add group
    If xPL_SourceCount + 1 > xPL_Configs(3).Number Then Exit Function
    xPL_TargetCount = xPL_TargetCount + 1
    ReDim Preserve xPL_Targets(xPL_TargetCount)
    xPL_Targets(xPL_TargetCount) = UCase(GroupName)
    ReDim Preserve xPL_Configs(3).value(xPL_TargetCount)
    xPL_Configs(3).value(xPL_TargetCount) = UCase(GroupName)
    xPL_Configs(3).Default(xPL_TargetCount) = UCase(GroupName)
    GroupsAdd = True
    
End Function

Public Sub GroupsClear()
    
    ' clear groups
    xPL_TargetCount = 0
    ReDim Preserve xPL_Targets(xPL_TargetCount)
    ReDim xPL_Configs(3).value(0)
    
End Sub

Public Function FiltersAdd(Filter As String) As Boolean

    ' add filter
    FiltersAdd = False
    If xPL_SourceCount + 1 > xPL_Configs(4).Number Then Exit Function
    xPL_SourceCount = xPL_SourceCount + 1
    ReDim Preserve xPL_Sources(xPL_SourceCount)
    xPL_Sources(xPL_SourceCount) = UCase(Filter)
    ReDim Preserve xPL_Configs(4).value(xPL_SourceCount)
    xPL_Configs(4).value(xPL_SourceCount) = UCase(Filter)
    xPL_Configs(4).Default(xPL_SourceCount) = UCase(Filter)
    FiltersAdd = True

End Function

Public Sub FiltersClear()
    
    ' clear filters
    xPL_SourceCount = 0
    ReDim Preserve xPL_Sources(xPL_SourceCount)
    ReDim xPL_Configs(4).value(0)
    
End Sub

Public Function ConfigsAdd(Item As String, Style As String, Number As Integer) As Boolean

    ' check
    ConfigsAdd = False
    If Item = "" Then Exit Function
    If Len(Item) > 16 Then Exit Function
    If UCase(Style) <> "CONFIG" And UCase(Style) <> "RECONF" And UCase(Style) <> "OPTION" Then Exit Function
    
    ' add config
    If Number < 1 Then Number = 1
    xPL_ConfigCount = xPL_ConfigCount + 1
    ReDim Preserve xPL_Configs(xPL_ConfigCount)
    xPL_Configs(xPL_ConfigCount).Item = UCase(Item)
    xPL_Configs(xPL_ConfigCount).Type = UCase(Style)
    xPL_Configs(xPL_ConfigCount).Number = Number
    If Number > 1 Then
        ReDim xPL_Configs(xPL_ConfigCount).value(0)
    Else
        ReDim xPL_Configs(xPL_ConfigCount).value(1)
    End If
    ReDim xPL_Configs(xPL_ConfigCount).Default(Number)
    xPL_ConfigList = xPL_ConfigList + xPL_Configs(xPL_ConfigCount).Item + "#"
    ConfigsAdd = True
    
End Function

Public Sub ConfigClear(Item As String)

    Dim x As Integer
    Dim y As Integer
    
    ' clear config item
    y = 0
    For x = 5 To xPL_ConfigCount
        If xPL_Configs(x).Item = UCase(Item) Then y = x
    Next x
    If y = 0 Then Exit Sub
    If xPL_Configs(y).Number = 1 Then Exit Sub
    xPL_Configs(y).Number = 0
    ReDim xPL_Configs(y).value(0)
    
End Sub

Public Sub SendConfig()

    Dim strCfgList As String
    Dim x As Integer
    Dim z As Integer
    
    ' send config.current
    strCfgList = ""
    For x = 1 To xPL_ConfigCount
        For z = 1 To UBound(xPL_Configs(x).value)
            strCfgList = strCfgList + xPL_Configs(x).Item + "=" + xPL_Configs(x).value(z) + Chr$(10)
        Next z
        If UBound(xPL_Configs(x).value) = 0 Then
            strCfgList = strCfgList + xPL_Configs(x).Item + "=" + Chr$(10)
        End If
    Next x
    Call xPLSendXplMsg("xpl-stat", "*", "config.current", strCfgList, False)

End Sub

Public Property Get AppVersion() As String
    
    ' return targeted
    AppVersion = App_Version
    
End Property

Public Property Let AppVersion(ByVal AppVersion As String)

    ' set targeted
    App_Version = AppVersion
    
End Property


Public Property Get PassNOMATCH() As Boolean
    
    ' return targeted
    PassNOMATCH = xPL_PassNOMATCH
    
End Property

Public Property Let PassNOMATCH(ByVal PassThru As Boolean)

    ' set targeted
    xPL_PassNOMATCH = PassThru
    
End Property

Public Property Get PassHBEAT() As Boolean

    ' return pass heartbeat
    PassHBEAT = xPL_PassHBEAT
    
End Property

Public Property Let PassHBEAT(ByVal PassThru As Boolean)

    ' set pass heartbeat
    xPL_PassHBEAT = PassThru
    
End Property

Public Property Get PassCONFIG() As Boolean

    ' return pass config
    PassCONFIG = xPL_PassCONFIG

End Property

Public Property Let PassCONFIG(ByVal PassThru As Boolean)

    ' set pass config
    xPL_PassCONFIG = PassThru
    
End Property

' function to send a raw message
Public Function SendxPLRaw(RawMsg As String) As Boolean
    
    ' send raw
    SendxPLRaw = False
    If xPLSendXplMsg("", "", "", RawMsg, True) <> "" Then SendxPLRaw = True

End Function

' function to extract raw message
Public Function xPLExtract(RawMsg As String) As xPLMsg
    
    Dim MsgType As String
    Dim Hop As Integer
    Dim source As xPL_SourceType
    Dim chkTarget As xPL_SourceType
    Dim Target As String
    Dim Schema As String
    Dim strMsg As String
    Dim strInstance As String
    Dim x As Integer
    
    ' return message
    Call xPL_Extract(RawMsg)
    MsgType = xPL_Message(0).Section
    Hop = xPL_GetParam(False, "HOP", True)
    source = xPLSourceChk(xPL_GetParam(False, "SOURCE", False))
    If source.Valid = False Then Exit Function ' not valid
    Target = xPL_GetParam(False, "TARGET", False)
    If Target <> "*" Then
        chkTarget = xPLSourceChk(xPL_GetParam(False, "TARGET", False))
        If chkTarget.Valid = False Then Exit Function ' not valid
    End If
    If UBound(xPL_Message) < 1 Then Exit Function
    Schema = xPL_Message(1).Section
    If xPLSchemaChk(Schema) = False Then Exit Function ' not valid
    xPLExtract.xPLType = MsgType
    xPLExtract.Hop = Hop
    xPLExtract.source = source.Vendor + "-" + source.Device + "." + source.Instance
    xPLExtract.Target = Target
    xPLExtract.Schema = Schema
    xPLExtract.NamePairs = xPL_Message(1).DC + 1
    ReDim xPLExtract.Names(xPLExtract.NamePairs)
    ReDim xPLExtract.Values(xPLExtract.NamePairs)
    For x = 0 To xPL_Message(1).DC
        xPLExtract.Names(x) = xPL_Message(1).Details(x).Name
        xPLExtract.Values(x) = xPL_Message(1).Details(x).value
    Next x
    
End Function

' heartbeat routine
Private Sub xPLHeartBeat()

    Dim xPLHBeatMsg As String
    
    ' check hearbeat
    xPL_Counter = xPL_Counter - 1
    If xPL_Counter > 0 Then Exit Sub
    
    ' send heartbeat
rebuildheartbeat:
    xPLHBeatMsg = "interval=" + Mid$(Str$(xPL_Interval), 2) & Chr$(10)
    xPLHBeatMsg = xPLHBeatMsg & "port=" & Mid$(Str$(xPL_Port), 2) & Chr$(10)
    xPLHBeatMsg = xPLHBeatMsg & "remote-ip=" & xPL_IP & Chr$(10)
    
    'Still in Config Mode
    If UCase(Left$(xPL_HBeat, 7)) <> "CONFIG." Then
        If xPL_StatusSchema <> "" And xPL_StatusMsg <> "" Then
            xPLHBeatMsg = xPLHBeatMsg & "schema=" & xPL_StatusSchema & Chr$(10)
            xPLHBeatMsg = xPLHBeatMsg & xPL_StatusMsg
            If Right$(xPLHBeatMsg, 1) <> Chr$(10) Then xPLHBeatMsg = xPLHBeatMsg & Chr$(10)
        End If
    End If
    
    'Add Application Version Tag (if not set by developer, use the OCX version)
    If App_Version <> "" Then
       xPLHBeatMsg = xPLHBeatMsg & "version=" & App_Version & Chr$(10)
    Else
       xPLHBeatMsg = xPLHBeatMsg & "version=" & App.Major & "." & App.Minor & "." & App.Revision & Chr$(10)
    End If

'Debug Stuff
'
'    xPLHBeatMsg = xPLHBeatMsg & "debug=" & Str(xPL_HBeatCount) & Chr$(10)
'
'    If xPL_JoinedNetwork Then
'       xPLHBeatMsg = xPLHBeatMsg & "joined=true" & Chr$(10)
'    Else
'       xPLHBeatMsg = xPLHBeatMsg & "joined=true" & Chr$(10)
'    End If
    
    ' send
    Call xPLSendXplMsg("xpl-stat", "*", xPL_HBeat, xPLHBeatMsg, False)

    ' if we have sent 30 fast heartbeats (90 seconds have passed with no hub)
    ' then drop back to 1 heartbeat a minute
    If xPL_JoinedNetwork = False Then
       If xPL_HBeatCount < 30 Then
          xPL_HBeatCount = xPL_HBeatCount + 1
       Else
          xPLTmr.Interval = 60000
       End If
    End If
    
    ' reset time
    Select Case LCase(xPL_HBeat)
    Case "config.app"
        xPL_Counter = 1
    Case "hbeat.app"
        xPL_Counter = xPL_Interval
    End Select
    
End Sub


Private Sub UserControl_Terminate()

    ' raise terminating beat
    xPLTmr.Enabled = False
    If Left$(xPL_HBeat, 7) = "config." Then
        xPL_HBeat = "config.end"
    Else
        xPL_HBeat = "hbeat.end"
    End If
    xPL_Counter = 1
    Call xPLHeartBeat
    
End Sub

Private Sub xPLTmr_Timer()
    
    ' raise hearbeat
    Call xPLHeartBeat
    
End Sub

Public Property Get Configs(ByVal Item As String, Optional ByVal Occurance As Integer) As String
    
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    
    ' returns value of a config item
    For x = 1 To xPL_ConfigCount
        If xPL_Configs(x).Item = UCase(Trim(Item)) Then
            y = x
            x = xPL_ConfigCount
        End If
    Next x
    If Occurance > UBound(xPL_Configs(y).value) Then
        Configs = ""
        Exit Property
    End If
    z = 1
    If y > 0 Then
        If Occurance > 1 And Occurance <= UBound(xPL_Configs(y).value) Then z = Occurance
        If UBound(xPL_Configs(y).value) > 0 Then
            Configs = xPL_Configs(y).value(z)
        End If
    End If
    
End Property

Public Property Let Configs(ByVal Item As String, Optional ByVal Occurance As Integer, ByVal NewValue As String)

    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    
    ' sets value of a config item
    For x = 1 To xPL_ConfigCount
        If xPL_Configs(x).Item = UCase(Trim(Item)) Then
            y = x
            x = xPL_ConfigCount
        End If
    Next x
    z = 1
    If y > 4 Then
        If Occurance > 1 And Occurance <= xPL_Configs(y).Number Then z = Occurance
'        If Occurance > 1 And Occurance <= UBound(xPL_Configs(y).value) Then z = Occurance
        If z > UBound(xPL_Configs(y).value) Then
            If z <= xPL_Configs(y).Number Then
                ReDim Preserve xPL_Configs(y).value(z)
                xPL_Configs(y).value(z) = NewValue
                xPL_Configs(y).Default(z) = NewValue
            End If
        Else
            xPL_Configs(y).value(z) = NewValue
            xPL_Configs(y).Default(z) = NewValue
        End If
    End If

End Property

Public Property Get IPAddress() As Variant

    ' return ip address
    IPAddress = udpxPL.LocalIP
    
End Property

Public Property Get Hostname() As Variant

    ' return hostname
    Hostname = udpxPL.LocalHostName
    
End Property

' load xpl from registry
Private Sub LoadxPL()

    Dim x As Integer
    Dim y As Integer
    
    ' check settings
    If CheckRegistryKey(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.Instance) = True Then
        ' set hbeat
        x = InStr(1, xPL_HBeat, ".", vbBinaryCompare)
        xPL_HBeat = "hbeat" + Mid$(xPL_HBeat, x)
    Else
        ' no settings
        Exit Sub
    End If
    
    ' load settings
    For x = 1 To xPL_ConfigCount
        If xPL_Configs(x).Number = 1 Then
            ' single item
            xPL_Configs(x).value(1) = GetRegistryValue(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.Instance, xPL_Configs(x).Item, xPL_Configs(x).value(1))
            Select Case UCase(xPL_Configs(x).Item)
            Case "NEWCONF", "INTERVAL", "GROUP", "FILTER"
            Case Else
                RaiseEvent Config(xPL_Configs(x).Item, Trim(xPL_Configs(x).value(1)), xPL_Configs(x).Number)
            End Select
        Else
            ' multi item
            ReDim xPL_Configs(x).value(xPL_Configs(x).Number)
            For y = 1 To xPL_Configs(x).Number
                xPL_Configs(x).value(y) = GetRegistryValue(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.Instance, xPL_Configs(x).Item & y, "$$$")
                If xPL_Configs(x).value(y) = "$$$" Then
                    ReDim Preserve xPL_Configs(x).value(y - 1)
                    Exit For
                Else
                    Select Case UCase(xPL_Configs(x).Item)
                    Case "NEWCONF", "INTERVAL", "GROUP", "FILTER"
                    Case Else
                            RaiseEvent Config(xPL_Configs(x).Item, Trim(xPL_Configs(x).value(y)), y)
                    End Select
                End If
            Next y
        End If
    Next x
        
    ' flag
    xPL_Configured = True
    RaiseEvent Configured(LCase(xPL_Source.Vendor) & "-" & LCase(xPL_Source.Device) & "." & LCase(xPL_Source.Instance))

End Sub

Private Function xPLMessageToLower(Message As String) As String

    Dim l As Integer
    Dim x As Integer
    Dim y As Integer
    Dim msgTmp As String
    
    ' validate
    msgTmp = Message
    While msgTmp <> ""
        x = InStr(1, msgTmp, "=", vbBinaryCompare)
        xPLMessageToLower = xPLMessageToLower & LCase(Left$(msgTmp, x))
        msgTmp = Mid$(msgTmp, x + 1)
        x = InStr(1, msgTmp, Chr$(10), vbBinaryCompare)
        xPLMessageToLower = xPLMessageToLower & Left$(msgTmp, x)
        msgTmp = Mid$(msgTmp, x + 1)
    Wend
    
End Function
