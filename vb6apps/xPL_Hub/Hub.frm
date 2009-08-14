VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "mswinsck.ocx"
Begin VB.Form Hub 
   Caption         =   "Hub"
   ClientHeight    =   5115
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4995
   Icon            =   "Hub.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   5115
   ScaleWidth      =   4995
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer tmrxPL 
      Interval        =   20000
      Left            =   960
      Top             =   4440
   End
   Begin MSWinsockLib.Winsock udpHub 
      Left            =   360
      Top             =   4440
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
      Protocol        =   1
   End
   Begin VB.TextBox txtBroadcasts 
      Height          =   4455
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   480
      Width           =   4695
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Center
      Caption         =   "Heartbeat Configs"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   120
      Width           =   4695
   End
   Begin VB.Menu mPopUpSys 
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
Attribute VB_Name = "Hub"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************
'* xPL Hub
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

Private Sub Form_Load()

    Dim f As Integer
    Dim x As Integer
    Dim h As Integer
    Dim LocalIP As String
    Dim strHub As String
    Dim BCastList As String
    
    ' get commands
    InTray = True
    If InStr(1, Command() & " ", "/hide ", vbTextCompare) > 0 Then InTray = False
    
    ' get listener settings and display
    HubIP = GetRegistryValue(&H80000002, "SOFTWARE\\xPL", "BroadcastAddress", "255.255.255.255")
    HubPort = 3865
        
    ' captions
    Me.mPopRestore.Caption = "Hub"
    
    ' load hubs
    If Dir(App.Path & "\hub.cfg") <> "" Then
        f = FreeFile
        Open App.Path & "\hub.cfg" For Input As #f
        While Not EOF(f)
            Line Input #f, strHub
            If strHub <> "" Then
                h = h + 1
                x = InStr(1, strHub, ",", vbBinaryCompare)
                xPL_hubs(h).VDI = Left$(strHub, x - 1)
                strHub = Mid$(strHub, x + 1)
                x = InStr(1, strHub, ",", vbBinaryCompare)
                xPL_hubs(h).Port = Val(Left$(strHub, x - 1))
                strHub = Mid$(strHub, x + 1)
                x = InStr(1, strHub, ",", vbBinaryCompare)
                xPL_hubs(h).Interval = Val(Left$(strHub, x - 1))
                strHub = Mid$(strHub, x + 1)
                x = InStr(1, strHub, ",", vbBinaryCompare)
                xPL_hubs(h).Refreshed = strHub
                xPL_hubs(h).Confirmed = False
                If xPL_hubs(h).Refreshed < DateAdd("n", xPL_hubs(h).Interval + 2, Now) Then
                    xPL_hubs(h).Refreshed = DateAdd("n", xPL_hubs(h).Interval + 2, Now)
                End If
                BCastList = BCastList + xPL_hubs(h).VDI + "  (" + Str$(xPL_hubs(h).Port) + " )" + vbCrLf
            End If
        Wend
        Close #f
        txtBroadcasts = BCastList
    End If

    ' initialise listener port
    LocalIP = udpHub.LocalIP
    udpHub.RemoteHost = HubIP
    udpHub.LocalPort = HubPort
    udpHub.RemotePort = HubPort
    On Error GoTo hubinitfailed
    udpHub.SendData "HELLO" ' needed to get port listening
    On Error GoTo 0
    
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
    End If
    Me.WindowState = vbMinimized
    Exit Sub
    
hubinitfailed:
    On Error GoTo 0
    Call MsgBox("Sorry, Hub FAILED to Initialise. Please check port is not in use!", vbOKOnly + vbCritical, "Hub Init Failure")
    Unload Me
    
End Sub

Private Sub tmrxPL_Timer()

    Dim x As Integer
    Dim BCastList As String
    
    ' get entries to keep
    BCastList = ""
    For x = 1 To MAX_HUBS
        If xPL_hubs(x).Port <> 0 Then
            If xPL_hubs(x).Refreshed < Now() Then
                xPL_hubs(x).Port = 0
            Else
                BCastList = BCastList + xPL_hubs(x).VDI + "  (" + Str$(xPL_hubs(x).Port) + " )" + vbCrLf
            End If
        End If
    Next x
    txtBroadcasts = BCastList
   
End Sub

Private Sub udpHub_DataArrival(ByVal bytesTotal As Long)

    Dim xPL_Input As String
    Dim x As Integer
    Dim Y As Integer
    
    ' get data
    On Error GoTo udpfailed
    Me.udpHub.GetData xPL_Input, vbString
    On Error GoTo 0
    
    ' check message
    If xPL_Extract(xPL_Input) = False Then Exit Sub ' not valid
    
    ' process message
    Call BroadcastMessage(xPL_Input)
    Exit Sub

udpfailed:
    On Error GoTo 0
        
End Sub

Private Sub BroadcastMessage(strMsg As String)

    Dim BCastList As String
    Dim RemoteIP As String
    Dim LocalPortID As Integer
    Dim GotMatch As Boolean
    Dim x As Integer
    Dim Y As Integer
    Dim z As Long
    
    ' check for heartbeat config message for me
    LocalPortID = -1
    If xPL_Message(0).Section = "XPL-STAT" And (Left$(xPL_Message(1).Section, 10) = "CONFIG.APP" Or Left$(xPL_Message(1).Section, 9) = "HBEAT.APP" Or Left$(xPL_Message(1).Section, 9) = "HBEAT.END") Then
        ' it's a heartbeat
        If udpHub.RemoteHostIP = udpHub.LocalIP Then
            ' it's local, but is it really local
            RemoteIP = xPL_GetParam(True, "REMOTE-IP", True)
            If RemoteIP = "" Or RemoteIP = udpHub.LocalIP Then
                z = Val(xPL_GetParam(True, "PORT", False))
                ' is it a config broadcast request?
                If z > 0 Then
                    ' yes, get heartbeat rate
                    Y = Val(xPL_GetParam(True, "INTERVAL", True))
                    If Y < 1 Then Y = 5 ' enforce minimum value of 5
                    ' but have we already got it?
                    BCastList = ""
                    GotMatch = False
                    For x = 1 To MAX_HUBS
                        If xPL_hubs(x).Port = z Then
                            xPL_hubs(x).Refreshed = DateAdd("n", (Y * 2) + 1, Now()) ' twice rate + 1
                            xPL_hubs(x).Interval = Y
                            xPL_hubs(x).VDI = xPL_GetParam(False, "SOURCE", True)
                            xPL_hubs(x).Confirmed = True
                            If xPL_Message(1).Section = "HBEAT.END" Then
                                LocalPortID = x
                            End If
                            GotMatch = True
                        End If
                        If x <> LocalPortID And xPL_hubs(x).Port <> 0 Then BCastList = BCastList + xPL_hubs(x).VDI + "  (" + Str$(xPL_hubs(x).Port) + " )" + vbCrLf
                    Next x
                    If GotMatch = True Then
                        txtBroadcasts = BCastList
                        GoTo heartbeatprocessed
                    End If
                    ' no, so its new
                    For x = 1 To MAX_HUBS
                        If xPL_hubs(x).Port = 0 Then
                            xPL_hubs(x).Refreshed = DateAdd("n", Y * 2, Now())
                            xPL_hubs(x).Interval = Y
                            xPL_hubs(x).VDI = xPL_GetParam(False, "SOURCE", True)
                            xPL_hubs(x).Confirmed = True
                            xPL_hubs(x).Port = z
                            If xPL_Message(1).Section = "HBEAT.END" Then
                                LocalPortID = x
                            Else
                                BCastList = BCastList + xPL_hubs(x).VDI + "  (" + Str$(xPL_hubs(x).Port) + " )" + vbCrLf
                            End If
                            Exit For
                        End If
                    Next x
                    txtBroadcasts = BCastList
                End If
            End If
        End If
    End If
heartbeatprocessed:

    ' hops
    x = InStr(1, strMsg, "hop=", vbTextCompare)
    If x > 0 Then
        ' increment hops
        Y = InStr(x, strMsg, Chr$(10), vbBinaryCompare)
        If Y > 0 Then
            z = Val(Mid$(strMsg, x + 4, Y - (x + 4)))
            z = z + 1
            If z > 10 Then Exit Sub ' too many hops
'            strMsg = Left$(strMsg, x + 3) + Mid$(Str$(z), 2) + Mid$(strMsg, y)
        End If
    End If
    
    ' broadcast on all valid ports
    For x = 1 To MAX_HUBS
        If xPL_hubs(x).Port <> 0 Then
            ' broadcast to all
            udpHub.RemoteHost = udpHub.LocalIP
            udpHub.RemotePort = xPL_hubs(x).Port
            udpHub.SendData strMsg
        End If
    Next x
    If LocalPortID <> -1 Then xPL_hubs(LocalPortID).Port = 0
    udpHub.RemoteHost = HubIP
    udpHub.RemotePort = HubPort
    
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
        
    'this procedure receives the callbacks from the System Tray icon.
    Dim Result As Long
    Dim msg As Long
         
    'the value of X will vary depending upon the scalemode setting
    If Me.ScaleMode = vbPixels Then
        msg = x
    Else
        msg = x / Screen.TwipsPerPixelX
    End If
    Select Case msg
    Case WM_LBUTTONUP        '514 restore form window
        Me.WindowState = vbNormal
        Result = SetForegroundWindow(Me.hwnd)
        Me.Show
    Case WM_LBUTTONDBLCLK    '515 restore form window
        Me.WindowState = vbNormal
        Result = SetForegroundWindow(Me.hwnd)
        Me.Show
    Case WM_RBUTTONUP        '517 display popup menu
        Result = SetForegroundWindow(Me.hwnd)
        Me.PopupMenu Me.mPopUpSys
    End Select
        
End Sub
 
Private Sub Form_Resize()
        
    ' this is necessary to assure that the minimized window is hidden
    If Me.WindowState = vbMinimized Then Me.Hide
    If Me.WindowState <> vbMinimized Then Me.Show
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    
    Dim x As Integer
    Dim f As Integer
    
    ' save hubs
    f = FreeFile
    Open App.Path & "\hub.cfg" For Output As #f
    For x = 1 To MAX_HUBS
        If xPL_hubs(x).Port <> 0 Then Print #1, xPL_hubs(x).VDI & "," & xPL_hubs(x).Port & "," & xPL_hubs(x).Interval & "," & xPL_hubs(x).Refreshed
    Next x
    Close #f
    
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

