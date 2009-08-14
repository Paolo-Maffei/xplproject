VERSION 5.00
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xPL.ocx"
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "mswinsck.ocx"
Begin VB.Form xPL_Template 
   Caption         =   "xPL Template"
   ClientHeight    =   5175
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   7950
   Icon            =   "xPL_Template.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   5175
   ScaleWidth      =   7950
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin xPL.xPLCtl xPLSys 
      Left            =   3120
      Top             =   360
      _ExtentX        =   1720
      _ExtentY        =   1508
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
      Height          =   4455
      Index           =   1
      Left            =   4080
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   1
      Top             =   480
      Width           =   3735
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
      Height          =   4455
      Index           =   0
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   480
      Width           =   3735
   End
   Begin MSWinsockLib.Winsock udpBridge 
      Left            =   480
      Top             =   120
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
      Protocol        =   1
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
      Height          =   615
      Index           =   1
      Left            =   4080
      TabIndex        =   3
      Top             =   120
      Width           =   3735
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
'* xPL Framework
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

' lines marked @@@ are application specific and will/may need amending

' this framework has a function for extracting a single name/value pair value
' xPL_GetParam(Msg As xPL.xPLMsg, strName As String, WithStrip As Boolean) As Variant
' Msg is the received message
' strName is the name/value pair name required
' WithStrip is True/False to specify if value should be trimmed
' Returns a variant data type

' simple example of sending a message and having it displayed in tx textbox
'    myMsg = "device=a1,a2" + Chr$(10) + "command=on"
'    Call SendXplMsg("XPL-CMND", "*", "X10.BASIC", myMsg)

' to include status info in heartbeat message
' use xPLSys.StatusSchema = "<class>.<type>" to set schema type
' use xPLSys.StatusMsg = "<xpl message body>" to set status info
' to disable, set either or both to ""

' for further information please refer to the readme.txt file for xPLocx

Option Explicit

' process message
Private Sub xPLSys_Received(Msg As xPLMsg)

    Dim xPL_Input As String
    Dim x As Integer
    Dim z As Integer
    
    ' check
    If xPL_Ready = False Then Exit Sub
    
    ' process message here @@@
    xPL_Input = Msg.Raw
    If xPL_CheckCache(oMD5.MD5(xPL_Input)) = True Then Exit Sub  ' ignore
    
    ' hops
    x = InStr(1, xPL_Input, "hop=", vbTextCompare)
    z = Val(Mid$(xPL_Input, x + 4, 1))
    z = z + 1
    If z > 9 Then Exit Sub ' too many hops
    Mid$(xPL_Input, x + 4, 1) = Mid$(Str$(z), 2, 1)
            
    ' add to the message cache
    Call xPL_AddToCache(oMD5.MD5(xPL_Input))
    
   ' Encrypt the message for transit over the Public Internet
    xPL_Input = oBlowfish.EncryptString(xPL_Input, xPLSys.Configs("ENCRYPTION"), False)
    udpBridge.SendData xPL_Input
    Call xPL_Display(1, Msg.Raw)
    
End Sub

' process config item
Private Sub xPLSys_Config(Item As String, Value As String, Occurance As Integer)

    ' process config items @@@
    ' IF you want to use your own variables
    ' OR you want to take some action
    Select Case UCase(Item)
    End Select
    
End Sub

' configuration process complete
Private Sub xPLSys_Configured(Source As String)
    
    Dim f As Integer
    
    ' update source and title
    xPL_Source = Source
    Me.Caption = xPL_Title + " " + xPL_Source
    If InTray = True Then
        Shell_NotifyIcon NIM_DELETE, nid
        Me.mPopRestore.Caption = xPL_Source
        Me.mPopupSys.Caption = xPL_Source
        nid.szTip = Me.Caption & vbNullChar
        Shell_NotifyIcon NIM_ADD, nid
    End If
    f = FreeFile
    Open App.Path + "\source.cfg" For Output As #f
    Print #f, xPL_Source
    Close #f
    
    ' application specific processing @@@
    ' e.g. do calculations, set com ports etc etc
        
    If Val(xPLSys.Configs("LOCALPORT")) = 0 Then Exit Sub
    If xPLSys.Configs("REMOTEIP") = "" Then Exit Sub
    If Val(xPLSys.Configs("REMOTEPORT")) = 0 Then Exit Sub
    On Error GoTo udpsetfailed
    udpBridge.LocalPort = xPLSys.Configs("LOCALPORT")
    udpBridge.RemoteHost = xPLSys.Configs("REMOTEIP")
    udpBridge.RemotePort = xPLSys.Configs("REMOTEPORT")
    udpBridge.SendData "HI"
    On Error GoTo 0
    
    ' good config
    f = FreeFile
    Open App.Path + "\bridge.ini" For Output As #f
    Print #f, "localport=" & Trim(xPLSys.Configs("LOCALPORT"))
    Print #f, "remoteip=" & Trim(xPLSys.Configs("LOCALPORT"))
    Print #f, "remoteport=" & Trim(xPLSys.Configs("LOCALPORT"))
    Close #f
    
    ' flag as configured
    xPL_Ready = True

udpsetfailed:
    On Error GoTo 0
    
End Sub

' display message received - remove if display not required @@@
Private Sub xPLSys_xPLRX(Msg As String)
    
    ' display message
'    Call xPL_Display(0, Msg)
    
End Sub

' display message sent - remove if display not required @@@
Private Sub xPLSys_xPLTX(Msg As String)
    
    ' display message
 '   Call xPL_Display(1, Msg)
    
End Sub

' initial startup sequence
Private Sub Form_Load()

    Dim iniline As String
    Dim x As Integer
    
    ' initialise
    InTray = True
    If InStr(1, Command() & " ", "/hide ", vbTextCompare) > 0 Then InTray = False
    xPL_Source = "XPL-BRIDGE" ' set vendor-device here @@@
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
    xPL_Ready = False
    xPL_Title = "xPL Bridge" ' application title @@@
    Me.Caption = xPL_Title + " " + xPL_Source
    Me.lblxPL(0) = "Bridge RX" ' receive box label @@@
    Me.lblxPL(1) = "Bridge TX" ' receive box label @@@
    Me.mPopRestore.Caption = xPL_Source
    
    ' find ini file
    xPL_Blowfish = "secretpassword"
    If Dir(App.Path + "\bridge.ini") <> "" Then
        x = FreeFile()
        Open App.Path + "\bridge.ini" For Input As #x
        While Not EOF(x)
            Input #x, iniline
            iniline = Trim(iniline)
            If LCase(Left$(iniline, 10)) = "localport=" Then xPL_BridgeLocal = Val(Mid$(iniline, 11))
            If LCase(Left$(iniline, 9)) = "remoteip=" Then xPL_BridgeIP = Trim(Mid$(iniline, 10))
            If LCase(Left$(iniline, 11)) = "remoteport=" Then xPL_BridgeRemote = Val(Mid$(iniline, 12))
            If LCase(Left$(iniline, 11)) = "encryption=" Then xPL_Blowfish = Trim(Mid$(iniline, 12))
        Wend
        Close #x
        If xPL_BridgeLocal <> 0 And xPL_BridgeIP <> "" And xPL_BridgeRemote <> 0 And xPL_Blowfish <> "" Then
            xPL_WaitForConfig = False
        End If
    End If
    
    ' pre initialise
    If xPLSys.Initialise(xPL_Source, xPL_WaitForConfig, 5) = False Then
        ' failed to pre-initialise
        Call MsgBox("Sorry, unable to initialise xPL sub-system.", vbCritical + vbOKOnly, "xPL Init Failed")
        Unload Me
        Exit Sub
    End If
    
    ' add extra configs (set config/reconf/option as needed) @@@
    Call xPLSys.ConfigsAdd("LOCALPORT", "RECONF", 1)
    Call xPLSys.ConfigsAdd("REMOTEIP", "RECONF", 1)
    Call xPLSys.ConfigsAdd("REMOTEPORT", "RECONF", 1)
    Call xPLSys.ConfigsAdd("ENCRYPTION", "OPTION", 1)

    ' add default extra config values if possible @@@
    xPLSys.Configs("LOCALPORT") = xPL_BridgeLocal
    xPLSys.Configs("REMOTEIP") = xPL_BridgeIP
    xPLSys.Configs("REMOTEPORT") = xPL_BridgeRemote
    xPLSys.Configs("ENCRYPTION") = xPL_Blowfish
    
    ' add default filters @@@
    Call xPLSys.FiltersAdd("*.*.*.*.*.*")
    ' etc
    
    ' add default groups (not recommended) @@@
'    Call xPLSys.GroupsAdd("MYGROUP")
    ' etc
    
    ' set up other options @@@
    xPLSys.PassCONFIG = True
    xPLSys.PassHBEAT = True
    xPLSys.PassNOMATCH = True
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
    If xPL_WaitForConfig = False Then
        On Error GoTo udppresetfailed
        udpBridge.LocalPort = xPLSys.Configs("LOCALPORT")
        udpBridge.RemoteHost = xPLSys.Configs("REMOTEIP")
        udpBridge.RemotePort = xPLSys.Configs("REMOTEPORT")
        udpBridge.SendData "HI"
    End If
    
udppresetfailed:
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

Private Sub udpBridge_DataArrival(ByVal bytesTotal As Long)

    Dim xPL_Input As String
    Dim MsgType As String
    Dim Source As String
    Dim Target As String
    Dim Schema As String
    Dim strInstance As String
    Dim strMsg As String
    Dim ConfCounts(9) As Integer
    Dim MD5Check As String
    Dim w As Integer
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    
    ' get data
    On Error GoTo udpfailed
    Me.udpBridge.GetData xPL_Input, vbString
    On Error GoTo 0
    If xPL_Ready = False Then Exit Sub
    
    'Decrypt the Data Block before handling
    xPL_Input = oBlowfish.DecryptString(xPL_Input, xPLSys.Configs("ENCRYPTION"), False)
    
    ' check source
    If udpBridge.RemoteHostIP <> xPLSys.Configs("REMOTEIP") Then Exit Sub ' not a valid source
    
    ' check message
    If xPL_Extract(xPL_Input) = False Then Exit Sub ' not valid
    
    ' get message source, instance, class, type
    MsgType = xPL_Message(0).Section
    Source = xPL_GetParam2(False, "SOURCE", False)
    Target = xPL_GetParam2(False, "TARGET", False)
    Schema = xPL_Message(1).Section
    
    ' check MD5
    If xPL_CheckCache(oMD5.MD5(xPL_Input)) = True Then Exit Sub ' ignore
        
    ' hops
    x = InStr(1, xPL_Input, "hop=", vbTextCompare)
    z = Val(Mid$(xPL_Input, x + 4, 1))
    z = z + 1
    If z > 9 Then Exit Sub ' too many hops
    Mid$(xPL_Input, x + 4, 1) = Mid$(Str$(z), 2, 1)

    ' send
    Call xPL_AddToCache(oMD5.MD5(xPL_Input))
    xPLSys.SendxPLRaw (xPL_Input)
    Call xPL_Display(0, xPL_Input)

udpfailed:
    On Error GoTo 0

End Sub

' check cache
Function xPL_CheckCache(MD5Data) As Boolean
    
    Dim x As Integer
    
    ' check
    xPL_CheckCache = False
    For x = 1 To xPL_CacheCount
        If xPL_Cache(x).MD5 = MD5Data Then
            If xPL_Cache(x).Date >= DateAdd("s", -5, Now()) Then
                xPL_CheckCache = True
                Exit Function
            End If
        End If
    Next x

End Function

' add to cache
Sub xPL_AddToCache(MD5Data)

    Dim x As Integer
    
    ' find old slot
    For x = 1 To xPL_CacheCount
        If xPL_Cache(x).Date < DateAdd("s", -5, Now()) Then GoTo gotslot
    Next x
    
    ' new slot
    xPL_CacheCount = xPL_CacheCount + 1
    ReDim Preserve xPL_Cache(xPL_CacheCount)
    x = xPL_CacheCount

gotslot:
    xPL_Cache(x).Date = Now()
    xPL_Cache(x).MD5 = MD5Data

End Sub

