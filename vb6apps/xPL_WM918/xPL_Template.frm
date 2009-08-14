VERSION 5.00
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "MSCOMM32.OCX"
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xPL.ocx"
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "mswinsck.ocx"
Begin VB.Form xPL_Template 
   Caption         =   "xPL Template"
   ClientHeight    =   6990
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   5070
   Icon            =   "xPL_Template.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   6990
   ScaleWidth      =   5070
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin MSWinsockLib.Winsock udpWeather 
      Left            =   4320
      Top             =   4800
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
      Protocol        =   1
      LocalPort       =   60135
   End
   Begin xPL.xPLCtl xPLSys 
      Left            =   720
      Top             =   120
      _ExtentX        =   1296
      _ExtentY        =   1508
   End
   Begin VB.Timer xPLTimer 
      Enabled         =   0   'False
      Left            =   4080
      Top             =   0
   End
   Begin MSCommLib.MSComm xPLCOM 
      Left            =   3000
      Top             =   120
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
   End
   Begin VB.TextBox txtMsg 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   6375
      Index           =   1
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   1
      Top             =   480
      Width           =   4815
   End
   Begin VB.TextBox txtMsg 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   4215
      Index           =   0
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   720
      Visible         =   0   'False
      Width           =   3735
   End
   Begin VB.Label lblxPL 
      Alignment       =   2  'Center
      Caption         =   "xPL Tx"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Index           =   1
      Left            =   120
      TabIndex        =   3
      Top             =   120
      Width           =   4815
   End
   Begin VB.Label lblxPL 
      Alignment       =   2  'Center
      Caption         =   "xPL Rx"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Index           =   0
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Visible         =   0   'False
      Width           =   3735
   End
   Begin VB.Menu mPopupSys 
      Caption         =   "&SysTray"
      Visible         =   0   'False
      Begin VB.Menu mPopRestore 
         Caption         =   "&Restore"
      End
      Begin VB.Menu mPopExit 
         Caption         =   "&Exit"
      End
   End
End
Attribute VB_Name = "xPL_Template"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************
'* xPL WM-918
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

Option Explicit

Private Sub udpWeather_DataArrival(ByVal bytesTotal As Long)

    Dim xPLCOMCmd As String
    
    ' process
    On Error GoTo udpfailed
    udpWeather.GetData xPLCOMCmd, vbString
    On Error GoTo 0
    
    ' check
    If xPLSys.Configs("FREEWXIP") = "" Then Exit Sub

    ' process input @@@
trynext:
    If Len(xPLCOMCmd) > 0 Then
        Select Case Hex(Asc(Left$(xPLCOMCmd, 1)))
        Case "8F"
            If Len(xPLCOMCmd) > 34 Then
                If CheckSum(Left$(xPLCOMCmd, 35)) = True Then
                    Weather.Time_Humidity = Left$(xPLCOMCmd, 35)
                    Call AlarmUpdate(1)
                End If
                xPLCOMCmd = Mid$(xPLCOMCmd, 36)
                GoTo trynext
            End If
        Case "9F"
            If Len(xPLCOMCmd) > 33 Then
                If CheckSum(Left$(xPLCOMCmd, 34)) = True Then
                    Weather.Temperature = Left$(xPLCOMCmd, 34)
                    Call AlarmUpdate(2)
                End If
                xPLCOMCmd = Mid$(xPLCOMCmd, 35)
                GoTo trynext
            End If
        Case "AF"
            If Len(xPLCOMCmd) > 30 Then
                If CheckSum(Left$(xPLCOMCmd, 31)) = True Then
                    Weather.Barometer_Dew = Left$(xPLCOMCmd, 31)
                    Call AlarmUpdate(3)
                End If
                xPLCOMCmd = Mid$(xPLCOMCmd, 32)
                GoTo trynext
            End If
        Case "BF"
            If Len(xPLCOMCmd) > 13 Then
                If CheckSum(Left$(xPLCOMCmd, 14)) = True Then
                    Weather.Rain = Left$(xPLCOMCmd, 14)
                    Call AlarmUpdate(4)
                End If
                xPLCOMCmd = Mid$(xPLCOMCmd, 15)
                GoTo trynext
            End If
        Case "CF"
            If Len(xPLCOMCmd) > 26 Then
                If CheckSum(Left$(xPLCOMCmd, 27)) = True Then
                    Weather.Wind_General = Left$(xPLCOMCmd, 27)
                    Call AlarmUpdate(5)
                End If
                xPLCOMCmd = Mid$(xPLCOMCmd, 28)
                GoTo trynext
            End If
        Case Else
            xPLCOMCmd = Mid$(xPLCOMCmd, 2)
            GoTo trynext
        End Select
    End If
    
udpfailed:
    On Error GoTo 0
    
End Sub


' process message
Private Sub xPLSys_Received(Msg As xPL.xPLMsg)

    Dim strMsg As String
    Dim x As Integer
    
    ' check
    If xPL_Ready = False Then Exit Sub
    
    ' pass to com device
    If xPL_COMPassThru = True Then
        ' add stx/etx and build message
        strMsg = Chr$(2) & Msg.xPLType & Chr$(10) & "{" & Chr$(10)
        If Msg.Hop + 1 > 10 Then Exit Sub ' too many hops
        strMsg = strMsg & "hop=" & Msg.Hop + 1 & Chr$(10)
        strMsg = strMsg & "source=" & Msg.Source & Chr$(10)
        strMsg = strMsg & "target=" & Msg.Target & Chr$(10)
        strMsg = strMsg & "}" & Chr$(10)
        strMsg = strMsg & Msg.Schema & Chr$(10) & "{" & Chr$(10)
        For x = 0 To Msg.NamePairs - 1
            strMsg = strMsg & LCase(Msg.Names(x)) & "=" & Msg.Values(x) & Chr$(10)
        Next x
        strMsg = strMsg & "}" & Chr$(10) & Chr$(3)
        On Error Resume Next
        xPLCOM.RTSEnable = False
        xPLCOM.Output = strMsg
        xPLCOM.RTSEnable = True
        On Error GoTo 0
        ' display tx message
        Call xPL_Display(1, strMsg)
        Exit Sub
    End If
    
    ' process message here @@@
    Select Case UCase(xPL_GetParam(Msg, "COMMAND", True))
    Case "CURRENT"
        Call WeatherCurrent
    Case "HI"
        Call WeatherHi
    Case "LO"
        Call WeatherLo
    Case "RAIN"
        Call WeatherRain
    End Select
    
End Sub

' process config item
Private Sub xPLSys_Config(Item As String, Value As String, Number As Integer)

    ' process config items @@@
    Select Case UCase(Item)
'    Case "LATITUDE"
'        config_latitude = Value
    End Select
   
End Sub

' configuration process complete
Private Sub xPLSys_Configured(Source As String)
    
    Dim F As Integer
    
    ' update source and title
    xPL_Source = Source
    Me.Caption = xPL_Title + " " + xPL_Source
    If InTray = True And IconInit = True Then
        Shell_NotifyIcon NIM_DELETE, nid
        Me.mPopRestore.Caption = xPL_Source
        Me.mPopupSys.Caption = xPL_Source
        nid.szTip = Me.Caption & vbNullChar
        Shell_NotifyIcon NIM_ADD, nid
    End If
    F = FreeFile
    Open App.Path + "\source.cfg" For Output As #F
    Print #F, xPL_Source
    Close #F
    
    ' application specific processing @@@
    Me.xPLTimer.Interval = 60000
    Me.xPLTimer.Enabled = True
    
    ' configure port
    If xPLSys.Configs("FREEWXIP") = "" Then
        On Error Resume Next
        xPLCOM.PortOpen = False
        On Error GoTo 0
        On Error GoTo openportfails
        xPLCOM.Settings = xPLSys.Configs("BAUD") + "," + LCase(Left$(xPLSys.Configs("PARITY"), 1)) + "," + xPLSys.Configs("DATABITS") + "," + xPLSys.Configs("STOPBITS")
        xPLCOM.DTREnable = False
        If UCase(xPLSys.Configs("DTRENABLE")) = "Y" Then xPLCOM.DTREnable = True
        xPLCOM.RTSEnable = False
        If UCase(xPLSys.Configs("RTSENABLE")) = "Y" Then xPLCOM.RTSEnable = True
        Select Case UCase(xPLSys.Configs("FLOWCONTROL"))
        Case "X"
            xPLCOM.Handshaking = comXOnXoff
        Case "H"
            xPLCOM.Handshaking = comRTS
        Case "N"
            xPLCOM.Handshaking = comNone
        End Select
        xPLCOM.RThreshold = 1 ' receive all
        xPLCOM.InputMode = comInputModeText ' always text
        xPLCOM.CommPort = Val(xPLSys.Configs("COMPORT")) ' port no
        On Error GoTo 0
    Else
        On Error Resume Next
        xPLCOM.PortOpen = False
        On Error GoTo 0
        On Error GoTo openportfails
        udpWeather.Protocol = sckUDPProtocol
        udpWeather.RemoteHost = xPLSys.Configs("FREEWXIP")
        udpWeather.RemotePort = 60135
        udpWeather.LocalPort = 60135
        On Error GoTo 0
    End If
    
    ' further application specific processing @@@
    
    
    ' flag as configured
    xPL_Ready = True
    
    ' open port
    If xPLSys.Configs("FREEWXIP") = "" Then
        On Error GoTo openportfails
        xPLCOM.PortOpen = True
        On Error GoTo 0
    Else
        On Error Resume Next
        udpWeather.SendData "HELLO"
        On Error GoTo 0
    End If
    Exit Sub
    
openportfails:
    On Error GoTo 0
        
End Sub

Private Sub xPLCOM_OnComm()

    Static xPLCOMCmd As String
    Dim strMsg As String
    Dim Msg As xPL.xPLMsg
    Dim w As Integer
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    
    Dim strCheckSum As String
    
    ' get data
    If xPLCOM.CommEvent <> comEvReceive Then Exit Sub
lookformoredata:
    If xPLCOM.InBufferCount = 0 Then Exit Sub ' no data
    xPLCOM.InputLen = xPLCOM.InBufferCount
    xPLCOMCmd = xPLCOMCmd + xPLCOM.Input
            
    ' process pass thru
    If xPL_COMPassThru = True Then
        ' looking for xPL message
lookfornextmsg:
        While Left$(xPLCOMCmd, 1) <> Chr$(2) And Len(xPLCOMCmd) > 0
            xPLCOMCmd = Mid$(xPLCOMCmd, 2)
        Wend
        If Len(xPLCOMCmd) = 0 Then GoTo lookformoredata ' no data
        w = InStr(1, xPLCOMCmd, Chr$(3), vbBinaryCompare)
        If w = 0 Then GoTo lookformoredata ' incomplete message, wait
        strMsg = Left$(xPLCOMCmd, w)
        xPLCOMCmd = Mid$(xPLCOMCmd, w + 1)
        ' check I didn't send it
        strMsg = Mid$(strMsg, 2)
        strMsg = Left$(strMsg, Len(strMsg) - 1)
        ' unpack it
        Msg = xPLSys.xPLExtract(strMsg)
        If Msg.NamePairs = 0 Then Exit Sub ' not valid
        If xPL_GetParam(Msg, "SOURCE", True) = UCase(xPL_Source) Then
            Exit Sub ' not interested in talking to myself
        End If
        ' build message
        strMsg = Msg.xPLType & Chr$(10) & "{" & Chr$(10)
        If Msg.Hop + 1 > 10 Then Exit Sub ' too many hops
        strMsg = strMsg & "hop=" & Msg.Hop + 1 & Chr$(10)
        strMsg = strMsg & "source=" & Msg.Source & Chr$(10)
        strMsg = strMsg & "target=" & Msg.Target & Chr$(10)
        strMsg = strMsg & "}" & Chr$(10)
        strMsg = strMsg & Msg.Schema & Chr$(10) & "{" & Chr$(10)
        For x = 0 To Msg.NamePairs - 1
            strMsg = strMsg & LCase(Msg.Names(x)) & "=" & Msg.Values(x) & Chr$(10)
        Next x
        strMsg = strMsg & "}" & Chr$(10)
        ' send it
        xPLSys.SendxPLRaw (strMsg)
        ' display it
        Call xPL_Display(0, Chr$(2) & strMsg & Chr$(3))
        GoTo lookfornextmsg
    End If
                
    ' process input @@@
trynext:
    If Len(xPLCOMCmd) > 0 Then
        Select Case Hex(Asc(Left$(xPLCOMCmd, 1)))
        Case "8F"
            If Len(xPLCOMCmd) > 34 Then
                If CheckSum(Left$(xPLCOMCmd, 35)) = True Then
                    Weather.Time_Humidity = Left$(xPLCOMCmd, 35)
                    Call AlarmUpdate(1)
                End If
                xPLCOMCmd = Mid$(xPLCOMCmd, 36)
                GoTo trynext
            End If
        Case "9F"
            If Len(xPLCOMCmd) > 33 Then
                If CheckSum(Left$(xPLCOMCmd, 34)) = True Then
                    Weather.Temperature = Left$(xPLCOMCmd, 34)
                    Call AlarmUpdate(2)
                End If
                xPLCOMCmd = Mid$(xPLCOMCmd, 35)
                GoTo trynext
            End If
        Case "AF"
            If Len(xPLCOMCmd) > 30 Then
                If CheckSum(Left$(xPLCOMCmd, 31)) = True Then
                    Weather.Barometer_Dew = Left$(xPLCOMCmd, 31)
                    Call AlarmUpdate(3)
                End If
                xPLCOMCmd = Mid$(xPLCOMCmd, 32)
                GoTo trynext
            End If
        Case "BF"
            If Len(xPLCOMCmd) > 13 Then
                If CheckSum(Left$(xPLCOMCmd, 14)) = True Then
                    Weather.Rain = Left$(xPLCOMCmd, 14)
                    Call AlarmUpdate(4)
                End If
                xPLCOMCmd = Mid$(xPLCOMCmd, 15)
                GoTo trynext
            End If
        Case "CF"
            If Len(xPLCOMCmd) > 26 Then
                If CheckSum(Left$(xPLCOMCmd, 27)) = True Then
                    Weather.Wind_General = Left$(xPLCOMCmd, 27)
                    Call AlarmUpdate(5)
                End If
                xPLCOMCmd = Mid$(xPLCOMCmd, 28)
                GoTo trynext
            End If
        Case Else
            xPLCOMCmd = Mid$(xPLCOMCmd, 2)
            GoTo trynext
        End Select
    End If
        
End Sub

Private Sub AlarmUpdate(WhichGroup As Integer)

    ' update alarms
    Select Case WhichGroup
    Case 1 ' time/humidity
        Alarms.Time_Set = GetBits(Weather.Time_Humidity, 34, 8)
        If Alarms.Time_Set = True Then
            Alarms.Time_Hour = GetValue(Weather.Time_Humidity, 8, 0, 255)
            Alarms.Time_Minute = GetValue(Weather.Time_Humidity, 7, 0, 255)
        End If
        
        Alarms.Humidity_In_Set = GetBits(Weather.Time_Humidity, 34, 192)
        If Alarms.Humidity_In_Set = True Then
            Alarms.Humidity_In_Hi = Val(Format(GetValue(Weather.Time_Humidity, 19, 0, 255), "#0"))
            Alarms.Humidity_In_Lo = Val(Format(GetValue(Weather.Time_Humidity, 20, 0, 255), "#0"))
        End If
        Alarms.Humidity_In_Current = Val(Format(GetValue(Weather.Time_Humidity, 9, 0, 255), "#0"))
        
        Alarms.Humidity_Out_Set = GetBits(Weather.Time_Humidity, 34, 48)
        If Alarms.Humidity_Out_Set = True Then
            Alarms.Humidity_Out_Hi = Val(Format(GetValue(Weather.Time_Humidity, 31, 0, 255), "#0"))
            Alarms.Humidity_Out_Lo = Val(Format(GetValue(Weather.Time_Humidity, 32, 0, 255), "#0"))
        End If
        Alarms.Humidity_Out_Current = Val(Format(GetValue(Weather.Time_Humidity, 21, 0, 255), "#0"))
        
    Case 2 ' temperature
        Alarms.Temp_In_Set = GetBits(Weather.Temperature, 33, 192)
        If Alarms.Temp_In_Set = True Then
            Alarms.Temp_In_Hi = Int(Round((Val(Format(GetValue(Weather.Temperature, 14, 0, 31) * 10 + GetValue(Weather.Temperature, 13, 2, 255), "#0")) - 32) / 1.8))
            Alarms.Temp_In_Lo = Int(Round((Val(Format(GetValue(Weather.Temperature, 16, 0, 1) * 100 + GetValue(Weather.Temperature, 15, 0, 255), "#0")) - 32) / 1.8))
        End If
        If GetBits(Weather.Temperature, 3, 8) = True Then
            Alarms.Temp_In_Current = -Val(Format((GetValue(Weather.Temperature, 3, 0, 7) * 100 + GetValue(Weather.Temperature, 2, 0, 255)) * 0.1, "#0.0"))
        Else
            Alarms.Temp_In_Current = Val(Format((GetValue(Weather.Temperature, 3, 0, 7) * 100 + GetValue(Weather.Temperature, 2, 0, 255)) * 0.1, "#0.0"))
        End If
        
        Alarms.Temp_Out_Set = GetBits(Weather.Temperature, 33, 48)
        If Alarms.Temp_Out_Set = True Then
            If GetBits(Weather.Temperature, 29, 128) = True Then
                Alarms.Temp_Out_Hi = -Int(Round((Val(Format(GetValue(Weather.Temperature, 29, 0, 31) * 10 + GetValue(Weather.Temperature, 28, 2, 255), "#0")) + 32) / 1.8))
            Else
                Alarms.Temp_Out_Hi = Int(Round((Val(Format(GetValue(Weather.Temperature, 29, 0, 31) * 10 + GetValue(Weather.Temperature, 28, 2, 255), "#0")) - 32) / 1.8))
            End If
            If GetBits(Weather.Temperature, 31, 8) = True Then
                Alarms.Temp_Out_Lo = -Int(Round((Val(Format(GetValue(Weather.Temperature, 31, 0, 1) * 100 + GetValue(Weather.Temperature, 30, 0, 255), "#0")) + 32) / 1.8))
            Else
                Alarms.Temp_Out_Lo = Int(Round((Val(Format(GetValue(Weather.Temperature, 31, 0, 1) * 100 + GetValue(Weather.Temperature, 30, 0, 255), "#0")) - 32) / 1.8))
            End If
        End If
        If GetBits(Weather.Temperature, 18, 8) = True Then
            Alarms.Temp_Out_Current = -Val(Format((GetValue(Weather.Temperature, 18, 0, 7) * 100 + GetValue(Weather.Temperature, 17, 0, 255)) * 0.1, "#0.0"))
        Else
            Alarms.Temp_Out_Current = Val(Format((GetValue(Weather.Temperature, 18, 0, 7) * 100 + GetValue(Weather.Temperature, 17, 0, 255)) * 0.1, "#0.0"))
        End If
        
    Case 3 ' barometer/dew
        Alarms.Barometer_Set = GetBits(Weather.Barometer_Dew, 30, 128)
        If Alarms.Barometer_Set = True Then
            Alarms.Barometer = Val(Format(GetValue(Weather.Barometer_Dew, 30, 1, 255) + 1, "#0"))
        End If
        Alarms.Barometer_Current = Val(Format(GetValue(Weather.Barometer_Dew, 3, 0, 255) * 100 + GetValue(Weather.Barometer_Dew, 2, 0, 255), "#0"))
        
        Alarms.Dewpt_Set = GetBits(Weather.Barometer_Dew, 30, 96)
        If Alarms.Dewpt_Set = True Then
            Alarms.Dewpt_In = Val(Format(GetValue(Weather.Barometer_Dew, 18, 1, 255) + 1, "0#"))
            Alarms.Dewpt_Out = Val(Format(GetValue(Weather.Barometer_Dew, 18, 2, 255) + 1, "0#"))
        End If
        Alarms.Dewpt_In_Current = Val(Format(GetValue(Weather.Barometer_Dew, 8, 0, 255), "#0"))
        Alarms.Dewpt_Out_Current = Val(Format(GetValue(Weather.Barometer_Dew, 19, 0, 255), "#0"))
        
    Case 4 ' rain
        Alarms.Rain_Set = GetBits(Weather.Rain, 13, 16)
        If Alarms.Rain_Set = True Then
            Alarms.Rain = Val(Format(GetValue(Weather.Rain, 13, 1, 255) * 100 + GetValue(Weather.Rain, 12, 0, 255), "#0.0"))
        End If
        Alarms.Rain_Current = Val(Format(GetValue(Weather.Rain, 3, 1, 255) * 100 + GetValue(Weather.Rain, 2, 0, 255), "#0"))
        
    Case 5 ' wind/general
        Alarms.Wind_Set = GetBits(Weather.Wind_General, 26, 4)
        If Alarms.Wind_Set = True Then
            Alarms.Wind = Val(Format(GetValue(Weather.Wind_General, 15, 0, 31) * 10 + GetValue(Weather.Wind_General, 14, 2, 255), "#0"))
        End If
        Alarms.Wind_Current = Val(Format(((GetValue(Weather.Wind_General, 3, 1, 255) * 100 + GetValue(Weather.Wind_General, 2, 0, 255)) * 0.2) * 2.24, "#0.0"))
        
        Alarms.Chill_Set = GetBits(Weather.Wind_General, 26, 2)
        If Alarms.Chill_Set = True Then
            If GetBits(Weather.Wind_General, 24, 8) = True Then
                Alarms.Chill = -Int(Round((Val(Format(GetValue(Weather.Wind_General, 24, 1, 1) * 100 + GetValue(Weather.Wind_General, 23, 0, 255), "#0")) + 32) / 1.8))
            Else
                Alarms.Chill = Int(Round((Val(Format(GetValue(Weather.Wind_General, 24, 1, 1) * 100 + GetValue(Weather.Wind_General, 23, 0, 255), "#0")) - 32) / 1.8))
            End If
        End If
        If GetBits(Weather.Wind_General, 22, 32) = True Then
            Alarms.Chill_Current = -Val(Format(GetValue(Weather.Wind_General, 17, 0, 255), "#0"))
        Else
            Alarms.Chill_Current = Val(Format(GetValue(Weather.Wind_General, 17, 0, 255), "#0"))
        End If
        
        Alarms.Power_Battery = GetBits(Weather.Wind_General, 24, 4)
        Alarms.Power_Low = GetBits(Weather.Wind_General, 24, 8)
        
    End Select
    
End Sub

Private Function CheckSum(WhatSum As String) As Boolean

    Dim x As Integer
    Dim c As Long
CheckSum = True
Exit Function
    ' get total
    For x = 1 To Len(WhatSum) - 1
        c = c + Asc(WhatSum)
    Next x
    CheckSum = False
    If Right$(Hex(c), 2) = Hex(Asc(Right$(WhatSum, 1))) Then
        CheckSum = True
    End If
    
End Function

' display message received - remove if display not required @@@
'Private Sub xPLSys_xPLRX(Msg As String)
    
    ' display message
 '   Call xPL_Display(0, Msg)
    
'End Sub

' display message sent - remove if display not required @@@
Private Sub xPLSys_xPLTX(Msg As String)
    
    ' display message
    Call xPL_Display(1, Msg)
    
End Sub

' initial startup sequence
Private Sub Form_Load()

    Dim x As Integer
    
    ' initialise
    InTray = True
    If InStr(1, Command() & " ", "/hide ", vbTextCompare) > 0 Then InTray = False
    xPL_Source = "TONYT-WM918" ' set vendor-device here @@@
    If Dir(App.Path + "\source.cfg") <> "" Then
        x = FreeFile
        Open App.Path + "\source.cfg" For Input As #x
        Input #x, xPL_Source
        Close #x
    Else
        xPL_Source = xPL_Source & "." & xPL_BuildInstance(xPLSys.HostName)
        x = FreeFile
        Open App.Path + "\source.cfg" For Output As #x
        Print #x, xPL_Source
        Close #x
    End If
    xPL_WaitForConfig = True ' set to false if config not required (not recommended) @@@
    xPL_COMPassThru = False ' indicate if message should be passed straight thru @@@
    xPL_Ready = False
    xPL_Title = "xPL WM-918 Weather Station" ' application title @@@
    Me.Caption = xPL_Title + " " + xPL_Source
    Me.lblxPL(0) = "xPL RX" ' receive box label @@@
    Me.lblxPL(1) = "xPL TX" ' receive box label @@@
    Me.mPopRestore.Caption = xPL_Source
    
    ' pre initialise
    If xPLSys.Initialise(xPL_Source, xPL_WaitForConfig, 5) = False Then
        ' failed to pre-initialise
        Call MsgBox("Sorry, unable to initialise xPL sub-system.", vbCritical + vbOKOnly, "xPL Init Failed")
        Unload Me
        Exit Sub
    End If
    
    ' add extra configs (set config/reconf/option as needed) @@@
    Call xPLSys.ConfigsAdd("COMPORT", "RECONF", 1)
    Call xPLSys.ConfigsAdd("FREEWXIP", "OPTION", 1)
'    Call xPLSys.ConfigsAdd("BAUD", "OPTION", 1)
'    Call xPLSys.ConfigsAdd("DATABITS", "OPTION", 1)
'    Call xPLSys.ConfigsAdd("PARITY", "OPTION", 1)
'    Call xPLSys.ConfigsAdd("STOPBITS", "OPTION", 1)
'    Call xPLSys.ConfigsAdd("FLOWCONTROL", "OPTION", 1)
'    Call xPLSys.ConfigsAdd("RTSENABLE", "OPTION", 1)
'    Call xPLSys.ConfigsAdd("DTRENABLE", "OPTION", 1)
    ' some app's may only need comport, as rest may be known fixed settings
'    Call xPLSys.ConfigsAdd("LATITUDE","OPTION")
'    etc

    ' add default extra config values if possible @@@
    xPLSys.Configs("COMPORT") = "1"
    xPLSys.Configs("FREEWXIP") = ""
    xPLSys.Configs("BAUD") = "9600"
    xPLSys.Configs("DATABITS") = "8"
    xPLSys.Configs("PARITY") = "N"
    xPLSys.Configs("STOPBITS") = "1"
    xPLSys.Configs("FLOWCONTROL") = "N"
    xPLSys.Configs("RTSENABLE") = "Y"
    xPLSys.Configs("DTRENABLE") = "Y"
'    etc

    ' add default filters @@@
'    Call xPLSys.FiltersAdd("*.*.*.*.*.*")
    ' etc
    
    ' add default groups (not recommended) @@@
'    Call xPLSys.GroupsAdd("MYGROUP")
    ' etc
    
    ' set up other options @@@
    xPLSys.PassCONFIG = False
    xPLSys.PassHBEAT = False
    xPLSys.PassNOMATCH = False
    xPLSys.StatusSchema = "" ' schema for status in heartbeat
    xPLSys.StatusMsg = "" ' message for status in heartbeat
    
    ' initialise other stuff here prior to start @@@
    
    ' initialise xPL
    If xPLSys.Start = False Then
        ' failed to initialise
        Call MsgBox("Sorry, unable to start xPL sub-system.", vbCritical + vbOKOnly, "xPL Start Failed")
        Unload Me
        Exit Sub
    End If
    
    ' initialise other stuff here after start @@@
    
    ' for icon tray form must be fully visible before calling Shell_NotifyIcon
    Me.Show
    Me.Refresh
    If InTray = True Then
        With nid
            .cbSize = Len(nid)
            .hwnd = Me.hwnd
            .uId = vbNull
            .uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
            .uCallBackMessage = WM_MOUSEMOVE
            .hIcon = Me.Icon
            .szTip = Me.Caption & vbNullChar
        End With
        Shell_NotifyIcon NIM_ADD, nid
        IconInit = True
    End If
    Me.WindowState = vbMinimized
    
    ' flag as configured
    If xPL_WaitForConfig = False Then xPL_Ready = True
    
End Sub

' routine to display xPL message in rx/tx status boxes
Private Sub xPL_Display(intDisplay As Integer, strMsg As String)

    Dim x As Integer

    ' display message
    txtMsg(intDisplay) = Format(Now(), "dd/mm/yy hh:mm:ss") + vbCrLf + vbCrLf
    For x = 1 To Len(strMsg)
        Select Case Mid$(strMsg, x, 1)
        Case Chr$(10)
            txtMsg(intDisplay) = txtMsg(intDisplay) + vbCrLf
        Case Chr$(2)
            txtMsg(intDisplay) = txtMsg(intDisplay) + "<STX>"
        Case Chr$(3)
            txtMsg(intDisplay) = txtMsg(intDisplay) + "<ETX>"
        Case Else
            txtMsg(intDisplay) = txtMsg(intDisplay) + Mid$(strMsg, x, 1)
        End Select
    Next x
    
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
        
    'this procedure receives the callbacks from the System Tray icon.
    Dim Result As Long
    Dim Msg As Long
         
    'the value of X will vary depending upon the scalemode setting
    If Me.ScaleMode = vbPixels Then
        Msg = x
    Else
        Msg = x / Screen.TwipsPerPixelX
    End If
    Select Case Msg
    Case WM_LBUTTONUP        '514 restore form window
        Me.WindowState = vbNormal
        Result = SetForegroundWindow(Me.hwnd)
        On Error Resume Next
        Me.Show
        On Error GoTo 0
    Case WM_LBUTTONDBLCLK    '515 restore form window
        Me.WindowState = vbNormal
        Result = SetForegroundWindow(Me.hwnd)
        On Error Resume Next
        Me.Show
        On Error GoTo 0
    Case WM_RBUTTONUP        '517 display popup menu
        Result = SetForegroundWindow(Me.hwnd)
        Me.PopupMenu Me.mPopupSys
    End Select
        
End Sub
 
Private Sub Form_Resize()
        
    ' this is necessary to assure that the minimized window is hidden
    If Me.WindowState = vbMinimized Then Me.Hide
    If Me.WindowState <> vbMinimized Then Me.Show
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    
    ' close com port, if open
    On Error Resume Next
    xPLCOM.PortOpen = False
    On Error GoTo 0
    
    ' tidy up stuff here @@@
     
     
    ' this removes the icon from the system tray
    If InTray = True Then Shell_NotifyIcon NIM_DELETE, nid
    
End Sub
 
Private Sub mPopExit_click()
         
    ' called when user clicks the popup menu Exit command
    Unload Me
        
End Sub
 
Private Sub mPopRestore_click()
    
    Dim Result As Long
    
    ' called when the user clicks the popup menu Restore command
    Me.WindowState = vbNormal
    Result = SetForegroundWindow(Me.hwnd)
    Me.Show
    
End Sub

' routine to send current weather at 60 second intervals
Private Sub xPLTimer_Timer()
    
    ' send current status
    Call WeatherCurrent
    Call CheckAlarms
End Sub

' routine to check alarms
Private Sub CheckAlarms()

    ' check alarms
    If Alarms.Barometer_Set = True Then
        If Alarms.Barometer_Current <= Alarms.Barometer Then
            Call SendAlarm("BAROMETER")
        End If
    End If
    If Alarms.Chill_Set = True Then
        If Alarms.Chill_Current <= Alarms.Chill Then
            Call SendAlarm("WINDCHILL")
        End If
    End If
    If Alarms.Dewpt_Set = True Then
        If Alarms.Dewpt_In_Current <= Alarms.Dewpt_In Then
            Call SendAlarm("DEWPOINT_IN")
        End If
        If Alarms.Dewpt_Out_Current <= Alarms.Dewpt_Out Then
            Call SendAlarm("DEWPOINT_OUT")
        End If
    End If
    If Alarms.Humidity_In_Set = True Then
        If Alarms.Humidity_In_Current >= Alarms.Humidity_In_Hi Then
            Call SendAlarm("HUMIDITY_IN_HI")
        End If
        If Alarms.Humidity_In_Current <= Alarms.Humidity_In_Lo Then
            Call SendAlarm("HUMIDITY_IN_LO")
        End If
    End If
    If Alarms.Humidity_Out_Set = True Then
        If Alarms.Humidity_Out_Current >= Alarms.Humidity_Out_Hi Then
            Call SendAlarm("HUMIDITY_OUT_HI")
        End If
        If Alarms.Humidity_Out_Current <= Alarms.Humidity_Out_Lo Then
            Call SendAlarm("HUMIDITY_OUT_LO")
        End If
    End If
    If Alarms.Power_Battery = True Then Call SendAlarm("ON_BATTERY")
    If Alarms.Power_Low = True Then Call SendAlarm("LOW_BATTERY")
    If Alarms.Rain_Set = True Then
        If Alarms.Rain_Current >= Alarms.Rain Then
            Call SendAlarm("RAIN")
        End If
    End If
    If Alarms.Temp_In_Set = True Then
        If Alarms.Temp_In_Current >= Alarms.Temp_In_Hi Then
            Call SendAlarm("TEMP_IN_HI")
        End If
        If Alarms.Temp_In_Current <= Alarms.Temp_In_Lo Then
            Call SendAlarm("TEMP_IN_LO")
        End If
    End If
    If Alarms.Temp_Out_Set = True Then
        If Alarms.Temp_Out_Current >= Alarms.Temp_Out_Hi Then
            Call SendAlarm("TEMP_OUT_HI")
        End If
        If Alarms.Temp_Out_Current <= Alarms.Temp_Out_Lo Then
            Call SendAlarm("TEMP_OUT_LO")
        End If
    End If
    If Alarms.Time_Set = True Then
        If Hour(Now) = Alarms.Time_Hour And Minute(Now) = Alarms.Time_Minute Then
            Call SendAlarm("TIME")
        End If
    End If
    If Alarms.Wind_Set = True Then
        If Alarms.Wind_Current >= Alarms.Wind Then
            Call SendAlarm("WIND")
        End If
    End If
        
End Sub

' routine to send alarm
Private Sub SendAlarm(WhatAlarm As String)
    
    ' send
    Call xPLSys.SendXplMsg("xpl-trig", "*", "weather.alarm", "alarm=" & WhatAlarm)
    
End Sub

' routine to send current weather
Private Sub WeatherCurrent()

    Dim strMsg As String

    ' create xpl message for time/humidity
    If Weather.Time_Humidity <> "" Then
        ' DateTime = yyyymmddhhmmss
        strMsg = strMsg + "datetime=" & Mid$(Str$(Year(Now)), 2) & Format(GetValue(Weather.Time_Humidity, 6, 1, 255), "00") & Format(GetValue(Weather.Time_Humidity, 5, 0, 255), "00") & Format(GetValue(Weather.Time_Humidity, 4, 0, 255), "00") & Format(GetValue(Weather.Time_Humidity, 3, 0, 255), "00") & Format(GetValue(Weather.Time_Humidity, 2, 0, 255), "00") & Chr$(10)
        ' humidityin = 0
        If Hex(Asc(Mid$(Weather.Time_Humidity, 9, 1))) <> "EE" Then
            strMsg = strMsg + "humidityin=" & Format(GetValue(Weather.Time_Humidity, 9, 0, 255), "#0") & "%" & Chr$(10)
        End If
        ' humidityout = 0
        If Hex(Asc(Mid$(Weather.Time_Humidity, 21, 1))) <> "EE" Then
            strMsg = strMsg + "humidityout=" & Format(GetValue(Weather.Time_Humidity, 21, 0, 255), "#0") & "%" & Chr$(10)
        End If
    End If
    If Weather.Temperature <> "" Then
        ' tempin=0.0C
        If Hex(Asc(Mid$(Weather.Temperature, 2, 1))) <> "EE" Then
            strMsg = strMsg + "tempin="
            If GetBits(Weather.Temperature, 3, 8) = True Then
                strMsg = strMsg + "-"
            Else
                strMsg = strMsg + "+"
            End If
            strMsg = strMsg & Format((GetValue(Weather.Temperature, 3, 0, 7) * 100 + GetValue(Weather.Temperature, 2, 0, 255)) * 0.1, "#0.0") & Chr(10)
        End If
        ' tempout=0.0C
        If Hex(Asc(Mid$(Weather.Temperature, 17, 1))) <> "EE" Then
            strMsg = strMsg + "tempout="
            If GetBits(Weather.Temperature, 18, 8) = True Then
                strMsg = strMsg + "-"
            Else
                strMsg = strMsg + "+"
            End If
            strMsg = strMsg & Format((GetValue(Weather.Temperature, 18, 0, 7) * 100 + GetValue(Weather.Temperature, 17, 0, 255)) * 0.1, "#0.0") & Chr(10)
        End If
    End If
    If Weather.Barometer_Dew <> "" Then
        ' dewptin=0C
        If Hex(Asc(Mid$(Weather.Barometer_Dew, 8, 1))) <> "EE" Then
            strMsg = strMsg + "dewptin=" & Format(GetValue(Weather.Barometer_Dew, 8, 0, 255), "#0") & Chr$(10)
        End If
        ' dewptout=0C
        If Hex(Asc(Mid$(Weather.Barometer_Dew, 19, 1))) <> "EE" Then
            strMsg = strMsg + "dewptout=" & Format(GetValue(Weather.Barometer_Dew, 19, 0, 255), "#0") & Chr$(10)
        End If
    End If
    If Weather.Wind_General <> "" Then
        ' windgustspeed=0.0mph
        If Hex(Asc(Mid$(Weather.Wind_General, 2, 1))) <> "EE" Then
            strMsg = strMsg & "windgustspeed=" & Format(((GetValue(Weather.Wind_General, 3, 1, 255) * 100 + GetValue(Weather.Wind_General, 2, 0, 255)) * 0.2) * 2.24, "#0.0") & "mph" & Chr(10)
        End If
        ' windgustdir = 0
        If Hex(Asc(Mid$(Weather.Wind_General, 4, 1))) <> "EE" Then
            strMsg = strMsg & "windgustdir=" & Format((GetValue(Weather.Wind_General, 4, 0, 255) * 10 + GetValue(Weather.Wind_General, 3, 2, 255)), "#0") & Chr(10)
        End If
        ' windavgspeed=0.0mph
        If Hex(Asc(Mid$(Weather.Wind_General, 5, 1))) <> "EE" Then
            strMsg = strMsg & "windavgspeed=" & Format(((GetValue(Weather.Wind_General, 6, 1, 255) * 100 + GetValue(Weather.Wind_General, 5, 0, 255)) * 0.1) * 2.24, "#0.0") & "mph" & Chr(10)
        End If
        ' windavgdir = 0
        If Hex(Asc(Mid$(Weather.Wind_General, 7, 1))) <> "EE" Then
            strMsg = strMsg & "windavgdir=" & Format((GetValue(Weather.Wind_General, 7, 0, 255) * 10 + GetValue(Weather.Wind_General, 6, 2, 255)), "#0") & Chr(10)
        End If
        ' windchill=0C
        If Hex(Asc(Mid$(Weather.Wind_General, 17, 1))) <> "EE" Then
            strMsg = strMsg + "windchill="
            If GetBits(Weather.Wind_General, 22, 32) = True Then
                strMsg = strMsg + "-"
            Else
                strMsg = strMsg + "+"
            End If
            strMsg = strMsg & Format(GetValue(Weather.Wind_General, 17, 0, 255), "#0") & Chr(10)
        End If
    End If
    If Weather.Rain <> "" Then
        ' rainrate=0mm
        If Hex(Asc(Mid$(Weather.Rain, 2, 1))) <> "EE" Then
            strMsg = strMsg + "rainrate=" & Format(GetValue(Weather.Rain, 3, 1, 255) * 100 + GetValue(Weather.Rain, 2, 0, 255), "#0") & "mm" & Chr(10)
        End If
    End If
    If Weather.Barometer_Dew <> "" Then
        ' barometer=0mb
        If Hex(Asc(Mid$(Weather.Rain, 2, 1))) <> "EE" Then
            strMsg = strMsg + "barometer=" & Format(GetValue(Weather.Barometer_Dew, 3, 0, 255) * 100 + GetValue(Weather.Barometer_Dew, 2, 0, 255), "#0") & "mb" & Chr(10)
        End If
        ' baromtrend=rising Or steady Or falling
        If GetBits(Weather.Barometer_Dew, 7, 16) = True Then strMsg = strMsg & "baromtrend=rising" & Chr(10)
        If GetBits(Weather.Barometer_Dew, 7, 32) = True Then strMsg = strMsg & "baromtrend=steady" & Chr(10)
        If GetBits(Weather.Barometer_Dew, 7, 64) = True Then strMsg = strMsg & "baromtrend=falling" & Chr(10)
        ' barompredict=sunny Or cloudy Or partly Or Rain
        If GetBits(Weather.Barometer_Dew, 7, 1) = True Then strMsg = strMsg & "barompredict=sunny" & Chr(10)
        If GetBits(Weather.Barometer_Dew, 7, 2) = True Then strMsg = strMsg & "barompredict=cloudy" & Chr(10)
        If GetBits(Weather.Barometer_Dew, 7, 4) = True Then strMsg = strMsg & "barompredict=partly" & Chr(10)
        If GetBits(Weather.Barometer_Dew, 7, 8) = True Then strMsg = strMsg & "barompredict=rain" & Chr(10)
    End If
    Call xPLSys.SendXplMsg("xpl-stat", "*", "weather.current", strMsg)
    
End Sub

' routine to send lo weather
Private Sub WeatherLo()
    
    Dim strMsg As String

    ' build weather.lo
    If Weather.Time_Humidity <> "" Then
        ' humidityin = 0% & humidityinat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Time_Humidity, 9, 1))) <> "EE" Then
            strMsg = strMsg + "humidityin=" & Format(GetValue(Weather.Time_Humidity, 15, 1, 255) * 10 + GetValue(Weather.Time_Humidity, 14, 2, 255), "#0") & "%" & Chr$(10)
            strMsg = strMsg + "humidityinat=" & Format(GetValue(Weather.Time_Humidity, 18, 2, 255), "00") & Format(GetValue(Weather.Time_Humidity, 18, 1, 255) * 10 + GetValue(Weather.Time_Humidity, 17, 2, 255), "00") & Format(GetValue(Weather.Time_Humidity, 17, 1, 255) * 10 + GetValue(Weather.Time_Humidity, 16, 2, 255), "00") & Format(GetValue(Weather.Time_Humidity, 16, 1, 255) * 10 + GetValue(Weather.Time_Humidity, 15, 2, 255), "00") & Chr$(10)
        End If
        ' humidityout = 0% & humidityoutat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Time_Humidity, 21, 1))) <> "EE" Then
            strMsg = strMsg + "humidityout=" & Format(GetValue(Weather.Time_Humidity, 27, 1, 255) * 10 + GetValue(Weather.Time_Humidity, 26, 2, 255), "#0") & "%" & Chr$(10)
            strMsg = strMsg + "humidityoutat=" & Format(GetValue(Weather.Time_Humidity, 30, 2, 255), "00") & Format(GetValue(Weather.Time_Humidity, 30, 1, 255) * 10 + GetValue(Weather.Time_Humidity, 29, 2, 255), "00") & Format(GetValue(Weather.Time_Humidity, 29, 1, 255) * 10 + GetValue(Weather.Time_Humidity, 28, 2, 255), "00") & Format(GetValue(Weather.Time_Humidity, 28, 1, 255) * 10 + GetValue(Weather.Time_Humidity, 27, 2, 255), "00") & Chr$(10)
        End If
    End If
    If Weather.Temperature <> "" Then
        ' tempin=0C & tempinat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Temperature, 2, 1))) <> "EE" Then
            strMsg = strMsg + "tempin="
            If GetBits(Weather.Temperature, 4, 128) = True Then
                strMsg = strMsg + "-"
            Else
                strMsg = strMsg + "+"
            End If
            strMsg = strMsg & Format((GetValue(Weather.Temperature, 9, 0, 127) * 10 + GetValue(Weather.Temperature, 8, 2, 255)) * 0.1, "#0.0") & Chr(10)
            strMsg = strMsg + "tempinat=" & Format(GetValue(Weather.Temperature, 13, 1, 255), "00") & Format(GetValue(Weather.Temperature, 12, 0, 255), "00") & Format(GetValue(Weather.Temperature, 11, 0, 255), "00") & Format(GetValue(Weather.Temperature, 10, 0, 255), "00") & Chr$(10)
        End If
        ' tempout=0C & tempoutat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Temperature, 17, 1))) <> "EE" Then
            strMsg = strMsg + "tempout="
            If GetBits(Weather.Temperature, 24, 128) = True Then
                strMsg = strMsg + "-"
            Else
                strMsg = strMsg + "+"
            End If
            strMsg = strMsg & Format((GetValue(Weather.Temperature, 24, 0, 127) * 10 + GetValue(Weather.Temperature, 23, 2, 255)) * 0.1, "#0.0") & Chr(10)
            strMsg = strMsg + "tempoutat=" & Format(GetValue(Weather.Temperature, 28, 1, 255), "00") & Format(GetValue(Weather.Temperature, 27, 0, 255), "00") & Format(GetValue(Weather.Temperature, 26, 0, 255), "00") & Format(GetValue(Weather.Temperature, 25, 0, 255), "00") & Chr$(10)
        End If
    End If
    If Weather.Barometer_Dew <> "" Then
        ' dewptin=0C & dewptinat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Barometer_Dew, 8, 1))) <> "EE" Then
            strMsg = strMsg & "dewptin=" & Format(GetValue(Weather.Barometer_Dew, 14, 1, 255) * 10 + GetValue(Weather.Barometer_Dew, 13, 2, 255), "#0") & Chr(10)
            strMsg = strMsg + "dewptinat=" & Format(GetValue(Weather.Barometer_Dew, 17, 2, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 17, 1, 255) * 10 + GetValue(Weather.Barometer_Dew, 16, 2, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 16, 1, 255) * 10 + GetValue(Weather.Barometer_Dew, 15, 2, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 15, 1, 255) * 10 + GetValue(Weather.Barometer_Dew, 14, 2, 255), "00") & Chr$(10)
        End If
        ' dewptout=0C & dewptoutat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Barometer_Dew, 19, 1))) <> "EE" Then
            strMsg = strMsg & "dewptout=" & Format(GetValue(Weather.Barometer_Dew, 25, 1, 255) * 10 + GetValue(Weather.Barometer_Dew, 24, 2, 255), "#0") & Chr(10)
            strMsg = strMsg + "dewptoutat=" & Format(GetValue(Weather.Barometer_Dew, 28, 2, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 28, 1, 255) * 10 + GetValue(Weather.Barometer_Dew, 27, 2, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 27, 1, 255) * 10 + GetValue(Weather.Barometer_Dew, 26, 2, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 26, 1, 255) * 10 + GetValue(Weather.Barometer_Dew, 25, 2, 255), "00") & Chr$(10)
        End If
    End If
    If Weather.Wind_General <> "" Then
        ' windchill=0C & windchillat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Wind_General, 18, 1))) <> "EE" Then
            strMsg = strMsg & "windchill=" & Format(GetValue(Weather.Wind_General, 18, 0, 255), "#0") & Chr(10)
            strMsg = strMsg + "windchillat=" & Format(GetValue(Weather.Wind_General, 22, 1, 255), "00") & Format(GetValue(Weather.Wind_General, 21, 0, 255), "00") & Format(GetValue(Weather.Wind_General, 20, 0, 255), "00") & Format(GetValue(Weather.Wind_General, 19, 0, 255), "00") & Chr$(10)
        End If
    End If
    Call xPLSys.SendXplMsg("xpl-stat", "*", "weather.lo", strMsg)
    
End Sub

' routine to send hi weather
Private Sub WeatherHi()

    Dim strMsg As String

    ' build weather.hi
    If Weather.Time_Humidity <> "" Then
        ' humidityin = 0% & humidityinat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Time_Humidity, 9, 1))) <> "EE" Then
            strMsg = strMsg + "humidityin=" & Format(GetValue(Weather.Time_Humidity, 10, 0, 255), "#0") & "%" & Chr$(10)
            strMsg = strMsg + "humidityinat=" & Format(GetValue(Weather.Time_Humidity, 14, 1, 255), "00") & Format(GetValue(Weather.Time_Humidity, 13, 0, 255), "00") & Format(GetValue(Weather.Time_Humidity, 12, 0, 255), "00") & Format(GetValue(Weather.Time_Humidity, 11, 0, 255), "00") & Chr$(10)
        End If
        ' humidityout = 0% & humidityoutat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Time_Humidity, 21, 1))) <> "EE" Then
            strMsg = strMsg + "humidityout=" & Format(GetValue(Weather.Time_Humidity, 22, 0, 255), "#0") & "%" & Chr$(10)
            strMsg = strMsg + "humidityoutat=" & Format(GetValue(Weather.Time_Humidity, 26, 1, 255), "00") & Format(GetValue(Weather.Time_Humidity, 25, 0, 255), "00") & Format(GetValue(Weather.Time_Humidity, 24, 0, 255), "00") & Format(GetValue(Weather.Time_Humidity, 23, 0, 255), "00") & Chr$(10)
        End If
    End If
    If Weather.Temperature <> "" Then
        ' tempin=0C & tempinat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Temperature, 2, 1))) <> "EE" Then
            strMsg = strMsg + "tempin="
            If GetBits(Weather.Temperature, 4, 128) = True Then
                strMsg = strMsg + "-"
            Else
                strMsg = strMsg + "+"
            End If
            strMsg = strMsg & Format((GetValue(Weather.Temperature, 4, 0, 127) * 10 + GetValue(Weather.Temperature, 3, 2, 255)) * 0.1, "#0.0") & Chr(10)
            strMsg = strMsg + "tempinat=" & Format(GetValue(Weather.Temperature, 8, 1, 255), "00") & Format(GetValue(Weather.Temperature, 7, 0, 255), "00") & Format(GetValue(Weather.Temperature, 6, 0, 255), "00") & Format(GetValue(Weather.Temperature, 5, 0, 255), "00") & Chr$(10)
        End If
        ' tempout=0C & tempoutat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Temperature, 17, 1))) <> "EE" Then
            strMsg = strMsg + "tempout="
            If GetBits(Weather.Temperature, 19, 128) = True Then
                strMsg = strMsg + "-"
            Else
                strMsg = strMsg + "+"
            End If
            strMsg = strMsg & Format((GetValue(Weather.Temperature, 19, 0, 127) * 10 + GetValue(Weather.Temperature, 18, 2, 255)) * 0.1, "#0.0") & Chr(10)
            strMsg = strMsg + "tempoutat=" & Format(GetValue(Weather.Temperature, 23, 1, 255), "00") & Format(GetValue(Weather.Temperature, 22, 0, 255), "00") & Format(GetValue(Weather.Temperature, 21, 0, 255), "00") & Format(GetValue(Weather.Temperature, 20, 0, 255), "00") & Chr$(10)
        End If
    End If
    If Weather.Barometer_Dew <> "" Then
        ' dewptin=0C & dewptinat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Barometer_Dew, 8, 1))) <> "EE" Then
            strMsg = strMsg & "dewptin=" & Format(GetValue(Weather.Barometer_Dew, 9, 0, 255), "#0") & Chr(10)
            strMsg = strMsg + "dewptinat=" & Format(GetValue(Weather.Barometer_Dew, 13, 1, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 12, 0, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 11, 0, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 10, 0, 255), "00") & Chr$(10)
        End If
        ' dewptout=0C & dewptoutat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Barometer_Dew, 19, 1))) <> "EE" Then
            strMsg = strMsg & "dewptout=" & Format(GetValue(Weather.Barometer_Dew, 20, 0, 255), "#0") & Chr(10)
            strMsg = strMsg + "dewptoutat=" & Format(GetValue(Weather.Barometer_Dew, 24, 1, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 23, 0, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 22, 0, 255), "00") & Format(GetValue(Weather.Barometer_Dew, 21, 0, 255), "00") & Chr$(10)
        End If
    End If
    If Weather.Wind_General <> "" Then
        ' windspeed=0.0mph & winddir=0 & windat=mmddhhmm
        If Hex(Asc(Mid$(Weather.Wind_General, 8, 1))) <> "EE" Then
            strMsg = strMsg & "windspeed=" & Format(((GetValue(Weather.Wind_General, 9, 1, 255) * 100 + GetValue(Weather.Wind_General, 8, 0, 255)) * 0.1) * 2.24, "#0.0") & "mph" & Chr(10)
            strMsg = strMsg & "winddir=" & Format((GetValue(Weather.Wind_General, 10, 0, 255) * 10 + GetValue(Weather.Wind_General, 9, 2, 255)), "#0") & Chr(10)
            strMsg = strMsg + "windat=" & Format(GetValue(Weather.Wind_General, 14, 1, 255), "00") & Format(GetValue(Weather.Wind_General, 13, 0, 255), "00") & Format(GetValue(Weather.Wind_General, 12, 0, 255), "00") & Format(GetValue(Weather.Wind_General, 11, 0, 255), "00") & Chr$(10)
        End If
    End If
    Call xPLSys.SendXplMsg("xpl-stat", "*", "weather.hi", strMsg)
        
End Sub

' routine to send rain weather
Private Sub WeatherRain()

    Dim strMsg As String
    
    ' build weather.rain
    If Weather.Rain = "" Then Exit Sub
    If Hex(Asc(Mid$(Weather.Rain, 2, 1))) = "EE" Then Exit Sub
        
    ' rainrate=0mm
    strMsg = strMsg + "rainrate=" & Format(GetValue(Weather.Rain, 3, 1, 255) * 100 + GetValue(Weather.Rain, 2, 0, 255), "#0") & "mm" & Chr(10)
    
    ' rainyesterday=0mm
    strMsg = strMsg + "rainyesterday=" & Format(GetValue(Weather.Rain, 5, 0, 255) * 100 + GetValue(Weather.Rain, 4, 0, 255), "#0") & "mm" & Chr(10)
    
    ' raintotal=0mm
    strMsg = strMsg + "raintotal=" & Format(GetValue(Weather.Rain, 7, 0, 255) * 100 + GetValue(Weather.Rain, 6, 0, 255), "#0") & "mm" & Chr(10)
    
    ' rainreset=mmddhhmm
     strMsg = strMsg + "datetime=" & Format(GetValue(Weather.Rain, 11, 1, 255), "00") & Format(GetValue(Weather.Rain, 10, 0, 255), "00") & Format(GetValue(Weather.Rain, 9, 0, 255), "00") & Format(GetValue(Weather.Rain, 8, 0, 255), "00") & Chr$(10)
    
    ' send
    Call xPLSys.SendXplMsg("xpl-stat", "*", "weather.rain", strMsg)
    
End Sub

Private Function GetBits(WhatValue As String, WhatByte As Integer, WhatBits As Integer) As Boolean

    Dim x As Integer
    
    ' get bits
    x = Asc(Mid$(WhatValue, WhatByte, 1))
    GetBits = False
    If (x And WhatBits) = WhatBits Then GetBits = True
    
End Function

Private Function GetValue(WhatValue As String, WhatByte As Integer, WhatType As Integer, WhatMask As Integer) As Integer

    Dim x As String
    Dim h As String
    Dim l As String
    Dim ih As Integer
    Dim il As Integer
    
    ' get value
    x = Hex(Asc(Mid$(WhatValue, WhatByte, 1)) And WhatMask)
    If Len(x) = 1 Then x = "0" & x
    l = Right$(x, 1)
    h = Left$(x, 1)
    Select Case l
    Case "A" To "E"
        il = Asc(l) - 55
    Case Else
        il = Val(l)
    End Select
    Select Case h
    Case "A" To "E"
        ih = Asc(h) - 55
    Case Else
        ih = Val(h)
    End Select
    Select Case WhatType
    Case 0
        GetValue = ih * 10 + il
    Case 1
        GetValue = il
    Case 2
        GetValue = ih
    End Select
    
End Function
