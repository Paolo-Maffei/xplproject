VERSION 5.00
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xPL.ocx"
Begin VB.Form xPL_Template 
   Caption         =   "xPL Template"
   ClientHeight    =   6750
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   11820
   Icon            =   "xPL_Template.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   6750
   ScaleWidth      =   11820
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin xPL.xPLCtl xPLSys 
      Left            =   4680
      Top             =   6000
      _ExtentX        =   1085
      _ExtentY        =   1085
   End
   Begin VB.CommandButton cmdCurrent 
      Caption         =   "Current"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   6480
      TabIndex        =   12
      Top             =   6000
      Width           =   1575
   End
   Begin VB.Timer xPLExpire 
      Interval        =   60000
      Left            =   3600
      Top             =   6000
   End
   Begin VB.CommandButton cmdAdd 
      Enabled         =   0   'False
      Height          =   615
      Left            =   11040
      Picture         =   "xPL_Template.frx":058A
      Style           =   1  'Graphical
      TabIndex        =   10
      Top             =   4680
      Width           =   615
   End
   Begin VB.CommandButton cmdDelete 
      Enabled         =   0   'False
      Height          =   615
      Left            =   11040
      Picture         =   "xPL_Template.frx":09CC
      Style           =   1  'Graphical
      TabIndex        =   9
      Top             =   120
      Width           =   615
   End
   Begin VB.CommandButton cmdRefresh 
      Caption         =   "Refresh"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   600
      TabIndex        =   8
      Top             =   5880
      Width           =   1575
   End
   Begin VB.CommandButton cmdSend 
      Caption         =   "Send"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   10080
      TabIndex        =   7
      Top             =   6000
      Width           =   1575
   End
   Begin VB.TextBox txtValue 
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   6480
      TabIndex        =   6
      Top             =   5400
      Width           =   5175
   End
   Begin VB.ComboBox cmbItems 
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   360
      Left            =   6480
      TabIndex        =   5
      Top             =   4800
      Width           =   4455
   End
   Begin VB.ListBox Configs 
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3660
      ItemData        =   "xPL_Template.frx":0E0E
      Left            =   6480
      List            =   "xPL_Template.frx":0E10
      TabIndex        =   4
      Top             =   840
      Width           =   5175
   End
   Begin VB.ListBox Devices 
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2910
      Index           =   1
      ItemData        =   "xPL_Template.frx":0E12
      Left            =   120
      List            =   "xPL_Template.frx":0E14
      TabIndex        =   1
      Top             =   2760
      Width           =   6135
   End
   Begin VB.ListBox Devices 
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1485
      Index           =   0
      ItemData        =   "xPL_Template.frx":0E16
      Left            =   120
      List            =   "xPL_Template.frx":0E18
      TabIndex        =   0
      Top             =   600
      Width           =   6135
   End
   Begin VB.Label lblRefresh 
      Alignment       =   2  'Center
      Caption         =   "*** New Data Available ***"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H000000FF&
      Height          =   255
      Left            =   0
      TabIndex        =   11
      Top             =   6480
      Visible         =   0   'False
      Width           =   2655
   End
   Begin VB.Label lblxPL 
      Alignment       =   2  'Center
      Caption         =   "Devices Waiting Configuration"
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
      Index           =   0
      Left            =   120
      TabIndex        =   3
      Top             =   240
      Width           =   6015
   End
   Begin VB.Label lblxPL 
      Alignment       =   2  'Center
      Caption         =   "Configured Devices"
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
      Index           =   1
      Left            =   120
      TabIndex        =   2
      Top             =   2400
      Width           =   6135
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
'* xPL Config Manager
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

Private Sub cmbItems_Click()

    ' add available
    If Me.cmbItems.Text <> "" Then
        Me.cmdAdd.Enabled = True
    Else
        Me.cmdAdd.Enabled = False
    End If

End Sub

Private Sub cmdAdd_Click()

    Dim n As Integer
    Dim Number As Integer
    Dim Style As String
    Dim x As Integer
    
    ' check how many
    For x = 0 To xPLDevices(Current).ConfiguredCount
        If UCase(xPLDevices(Current).Configured(x).Item) = UCase(Me.cmbItems.Text) Then n = n + 1
    Next x
    For x = 0 To xPLDevices(Current).ConfigCount
        If UCase(xPLDevices(Current).Configs(x).Item) = UCase(Me.cmbItems.Text) Then
            Number = xPLDevices(Current).Configs(x).Number
            Style = xPLDevices(Current).Configs(x).Type
            x = xPLDevices(Current).ConfigCount
        End If
    Next x
    If n + 1 > Number Then
        Call MsgBox("Sorry, only" & Str$(Number) & " of this item allowed!", vbOKOnly + vbExclamation, "Not Allowed")
        Exit Sub
    End If
    
    ' add
    xPLDevices(Current).ConfiguredCount = xPLDevices(Current).ConfiguredCount + 1
    ReDim Preserve xPLDevices(Current).Configured(xPLDevices(Current).ConfiguredCount)
    xPLDevices(Current).Configured(xPLDevices(Current).ConfiguredCount).Item = Me.cmbItems.Text
    xPLDevices(Current).Configured(xPLDevices(Current).ConfiguredCount).Value = ""
    xPLDevices(Current).Configured(xPLDevices(Current).ConfiguredCount).Number = Number
    
    ' display
    Me.Configs.Clear
    For x = 0 To xPLDevices(Current).ConfiguredCount
        Me.Configs.AddItem xPLDevices(Current).Configured(x).Item & "=" & xPLDevices(Current).Configured(x).Value
    Next x
    Me.Configs.ListIndex = xPLDevices(Current).ConfiguredCount
    Me.txtValue = ""
    Me.txtValue.Enabled = True
    Me.txtValue.SetFocus
    
End Sub

Private Sub cmdCurrent_Click()
    
    ' check config
    If Current = -1 Then Exit Sub
    
    ' request current config
    Call xPLSys.SendXplMsg("xpl-cmnd", xPLDevices(Current).VDI, "config.current", "command=request")
    
End Sub

Private Sub cmdDelete_Click()

    Dim x As Integer
    
    ' delete item
    If Current = -1 Then Exit Sub
    If CurrentConfig = -1 Then Exit Sub
    xPLDevices(Current).ConfiguredCount = xPLDevices(Current).ConfiguredCount - 1
    For x = CurrentConfig To xPLDevices(Current).ConfiguredCount
        xPLDevices(Current).Configured(x).Item = xPLDevices(Current).Configured(x + 1).Item
        xPLDevices(Current).Configured(x).Number = xPLDevices(Current).Configured(x + 1).Number
        xPLDevices(Current).Configured(x).Type = xPLDevices(Current).Configured(x + 1).Type
        xPLDevices(Current).Configured(x).Value = xPLDevices(Current).Configured(x + 1).Value
    Next x
    Me.Configs.Clear
    For x = 0 To xPLDevices(Current).ConfiguredCount
        Me.Configs.AddItem xPLDevices(Current).Configured(x).Item & "=" & xPLDevices(Current).Configured(x).Value
    Next x
    Me.Configs.ListIndex = -1
    CurrentConfig = -1
    Me.cmbItems.SetFocus
    Me.cmdDelete.Enabled = False
    
End Sub

Private Sub cmdRefresh_Click()

    Dim l As Integer
    
    ' clear lists
    Me.Devices(0).Clear
    Me.Devices(1).Clear
    Me.Configs.Clear
    Me.cmbItems.Clear
    Me.cmdAdd.Enabled = False
    Me.lblRefresh.Visible = False
    Current = -1
    CurrentConfig = -1
    Me.cmdDelete.Enabled = False
    Me.cmbItems = ""
    Me.txtValue = ""
    
    ' find waiting
    For l = 0 To xPLDeviceCount
        If xPLDevices(l).ConfigType = True And xPLDevices(l).Suspended = False Then
            Me.Devices(0).AddItem xPLDevices(l).VDI
        End If
    Next l

    ' find configured
    For l = 0 To xPLDeviceCount
        If xPLDevices(l).ConfigType = False And xPLDevices(l).Suspended = False Then
            Me.Devices(1).AddItem xPLDevices(l).VDI
        End If
    Next l

End Sub

Private Sub cmdSend_Click()

    Dim strMsg As String
    Dim x As Integer
    
    ' check config
    If Current = -1 Then Exit Sub
    For x = 0 To xPLDevices(Current).ConfiguredCount
        If xPLDevices(Current).Configured(x).Number = 1 Then
            If xPLDevices(Current).Configured(x).Value = "" Then
                Me.Configs.ListIndex = x
    '            Me.txtValue.Enabled = True
                Me.txtValue.SetFocus
                Exit Sub
            End If
        End If
    Next x
    
    ' send config
    For x = 0 To xPLDevices(Current).ConfiguredCount
        strMsg = strMsg & xPLDevices(Current).Configured(x).Item & "=" & xPLDevices(Current).Configured(x).Value & vbCrLf
    Next x
    Call ConfigSend(Current, strMsg)
    Call MsgBox("Configuration Sent!", vbOKOnly + vbExclamation, "Send")
    
End Sub

Private Sub Configs_Click()

    ' display in combo and value
    If Current = -1 Then Exit Sub
    CurrentConfig = Configs.ListIndex
    Me.cmbItems.Text = xPLDevices(Current).Configured(CurrentConfig).Item
    Me.txtValue = xPLDevices(Current).Configured(CurrentConfig).Value
    Me.cmdDelete.Enabled = True
    
End Sub

Private Sub Configs_GotFocus()
    
    ' allow text
    If Me.Configs.ListIndex <> -1 Then
        Me.txtValue.Enabled = True
    Else
        Me.txtValue.Enabled = False
    End If

End Sub

Private Sub Devices_Click(Index As Integer)

    Dim strDevice As String
    Dim l As Integer
    
    ' show details
    Current = -1
    strDevice = Devices(Index).Text
    For l = 0 To xPLDeviceCount
        If xPLDevices(l).VDI = strDevice Then
            Current = l
            l = xPLDeviceCount
        End If
    Next l
    Me.cmbItems = ""
    Me.cmbItems.Clear
    Me.cmdAdd.Enabled = False
    Me.Configs.Clear
    CurrentConfig = -1
    Me.cmdDelete.Enabled = False
    Me.cmdCurrent.Enabled = False
    If Current = -1 Then Exit Sub
    For l = 0 To xPLDevices(Current).ConfigCount
        Me.cmbItems.AddItem xPLDevices(Current).Configs(l).Item
    Next l
    For l = 0 To xPLDevices(Current).ConfiguredCount
        Me.Configs.AddItem xPLDevices(Current).Configured(l).Item & "=" & xPLDevices(Current).Configured(l).Value
    Next l
    Me.cmdCurrent.Enabled = True
    
End Sub

Private Sub Devices_GotFocus(Index As Integer)

    ' unhighlight
    Me.cmbItems = ""
    Me.cmbItems.Clear
    Me.Configs.Clear
    Me.Devices(1 - Index).ListIndex = -1
    Current = -1
    
End Sub

Private Sub txtValue_Change()

    Dim x As Integer
    
    ' update value
    If Current = -1 Then Exit Sub
    xPLDevices(Current).Configured(Me.Configs.ListIndex).Value = Me.txtValue
    Me.Configs.Clear
    For x = 0 To xPLDevices(Current).ConfiguredCount
        Me.Configs.AddItem xPLDevices(Current).Configured(x).Item & "=" & xPLDevices(Current).Configured(x).Value
    Next x
    Me.Configs.ListIndex = CurrentConfig
                
End Sub

' process message
Private Sub xPLSys_Received(Msg As xPL.xPLMsg)

    Dim msgSourceVendor As String
    Dim msgSourceDevice As String
    Dim msgSourceInstance As String
    Dim msgType As String
    Dim msgSchemaClass As String
    Dim msgSchemaType As String
    Dim x As Integer
    
    ' check
    If xPL_Ready = False Then Exit Sub
    If UCase(Msg.Source) = UCase(xPL_Source) Then Exit Sub
    
    ' is it a heartbeat
    If UCase(Left$(Msg.Schema, 6)) = "HBEAT." Or UCase(Left$(Msg.Schema, 7)) = "CONFIG." Then
        msgSourceVendor = UCase(Msg.Source)
        x = InStr(1, msgSourceVendor, ".", vbBinaryCompare)
        msgSourceInstance = Mid$(msgSourceVendor, x + 1)
        msgSourceVendor = Left$(msgSourceVendor, x - 1)
        x = InStr(1, msgSourceVendor, "-", vbBinaryCompare)
        msgSourceDevice = Mid$(msgSourceVendor, x + 1)
        msgSourceVendor = Left$(msgSourceVendor, x - 1)
        x = InStr(1, Msg.Schema, ".", vbBinaryCompare)
        msgSchemaClass = UCase(Left$(Msg.Schema, x - 1))
        msgSchemaType = UCase(Mid$(Msg.Schema, x + 1))
        Call ConfigProcess(UCase(Msg.Source), Msg, msgSourceVendor, msgSourceDevice, msgSourceInstance, UCase(Msg.xPLType), msgSchemaClass, msgSchemaType)
    End If
    
End Sub

' process config item
Private Sub xPLSys_Config(Item As String, Value As String, Occurance As Integer)

    ' process config items @@@
    ' IF you want to use your own variables
    ' OR you want to take some action
    Select Case UCase(Item)
'    Case "LATITUDE"

    End Select
    
End Sub

' configuration process complete
Private Sub xPLSys_Configured(Source As String)
    
    Dim f As Integer
    
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
    f = FreeFile
    Open App.Path + "\source.cfg" For Output As #f
    Print #f, xPL_Source
    Close #f
    
    ' application specific processing @@@
    ' e.g. do calculations, set com ports etc etc
    
    ' flag as configured
    xPL_Ready = True
    
End Sub

' initial startup sequence
Private Sub Form_Load()

    Dim x As Integer
    
    ' initialise
    InTray = True
    If InStr(1, Command() & " ", "/hide ", vbTextCompare) > 0 Then InTray = False
    xPL_Source = "TONYT-CONFIG" ' set vendor-device here @@@
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
    xPL_WaitForConfig = False ' set to false if config not required (not recommended) @@@
    xPL_Ready = False
    xPL_Title = "Config Manager" ' application title @@@
    Me.Caption = xPL_Title + " " + xPL_Source
    Me.lblxPL(0) = "Devices Waiting Configuration" ' receive box label @@@
    Me.lblxPL(1) = "Configured Devices" ' receive box label @@@
    Me.mPopRestore.Caption = xPL_Source
    
    ' pre initialise
    If xPLSys.Initialise(xPL_Source, xPL_WaitForConfig, 5) = False Then
        ' failed to pre-initialise
        Call MsgBox("Sorry, unable to initialise xPL sub-system.", vbCritical + vbOKOnly, "xPL Init Failed")
        Unload Me
        Exit Sub
    End If
    
    ' add extra configs (set config/reconf/option as needed) @@@
'    Call xPLSys.ConfigsAdd("LATITUDE", "CONFIG")
'    etc

    ' add default extra config values if possible @@@
    ' xPLSys.Configs("LATITUDE") = "1.04532"
'    etc

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
    xPLDeviceCount = -1
    
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
'    Me.WindowState = vbMinimized
    
    ' flag as configured
    If xPL_WaitForConfig = False Then xPL_Ready = True
    
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
        If Me.WindowState = vbMinimized Then
            Result = SetForegroundWindow(Me.hwnd)
            Me.PopupMenu Me.mPopupSys
        End If
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

Public Sub ConfigProcess(ByVal msgSource As String, Msg As xPL.xPLMsg, ByVal msgSourceVendor As String, ByVal msgSourceDevice As String, ByVal msgSourceInstance As String, ByVal msgType As String, ByVal msgSchemaClass As String, ByVal msgSchemaType As String)

    Dim strMsg As String
    Dim f As Integer
    Dim l As Integer
    Dim x As Integer
    Dim y As Integer
    Dim z(1) As Integer
    Dim p As Integer
    Dim n As Integer
    Dim RequestSent As Boolean
    Dim strType As String
    Dim strValue As String
    Dim strNumber As String
    Dim strInput As String
    Dim ThisConf As String
    Dim NextConf As String
    
    ' are we interested
    If msgType <> "XPL-STAT" Then Exit Sub

    ' check if device exists
    x = -1
    If xPLDeviceCount > -1 Then
        For l = 0 To xPLDeviceCount
            If xPLDevices(l).VDI = msgSource Then
                x = l
                l = xPLDeviceCount
            End If
        Next l
    End If

    ' create if new
    If x = -1 And (msgSchemaType = "BASIC" Or msgSchemaType = "APP") Then
        xPLDeviceCount = xPLDeviceCount + 1
        ReDim Preserve xPLDevices(xPLDeviceCount)
        x = xPLDeviceCount
        xPLDevices(x).VDI = UCase(msgSource)
        xPLDevices(x).ConfigDone = False
        xPLDevices(x).ConfigMissing = True
        xPLDevices(x).ConfigSource = ""
        xPLDevices(x).ConfigType = False
        If msgSchemaClass = "CONFIG" Then xPLDevices(x).ConfigType = True
        xPLDevices(x).Suspended = False
        xPLDevices(x).WaitingConfig = False
        xPLDevices(x).Suspended = False
        xPLDevices(x).ConfigCount = -1
        xPLDevices(x).ConfiguredCount = -1
        If Dir(App.Path & "\Vendor\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml") <> "" Then
            xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
            xPLDevices(x).ConfigMissing = False
            Call UpdateConfigs(x)
        Else
            If Dir(App.Path & "\Vendor\" & msgSourceVendor & "-" & msgSourceDevice & ".xml") <> "" Then
                xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".xml"
                xPLDevices(x).ConfigMissing = False
                Call UpdateConfigs(x)
            End If
        End If
        Call RetrieveConfigs(x)
        xPLDevices(x).Current = False
        Call xPLSys.SendXplMsg("xpl-cmnd", msgSource, "CONFIG.LIST", "COMMAND=REQUEST")
        Call xPLSys.SendXplMsg("xpl-cmnd", msgSource, "CONFIG.CURRENT", "COMMAND=REQUEST")
        RequestSent = True
        Me.lblRefresh.Visible = True
    Else
        If msgSchemaType = "BASIC" Or msgSchemaType = "APP" Then
            If xPLDevices(x).Suspended = True Then
                Call xPLSys.SendXplMsg("xpl-cmnd", msgSource, "CONFIG.LIST", "COMMAND=REQUEST")
                Call xPLSys.SendXplMsg("xpl-cmnd", msgSource, "CONFIG.CURRENT", "COMMAND=REQUEST")
                RequestSent = True
            End If
        End If
    End If
    If x = -1 Then Exit Sub ' no processing
    
    ' process type
    Select Case msgSchemaClass
    Case "HBEAT"
        Select Case msgSchemaType
        Case "BASIC", "APP"
            xPLDevices(x).Interval = Val(xPL_GetParam(Msg, "interval", True))
            xPLDevices(x).Expires = DateAdd("n", (2 * xPLDevices(x).Interval) + 1, Now)
            xPLDevices(x).ConfigType = False
            xPLDevices(x).Suspended = False
            xPLDevices(x).WaitingConfig = False
            xPLDevices(x).ConfigDone = True
            If xPLDevices(x).Current = False And RequestSent = False Then
                Call xPLSys.SendXplMsg("xpl-cmnd", msgSource, "CONFIG.LIST", "COMMAND=REQUEST")
                Call xPLSys.SendXplMsg("xpl-cmnd", msgSource, "CONFIG.CURRENT", "COMMAND=REQUEST")
            End If
        Case "END"
            xPLDevices(x).Suspended = True
            xPLDevices(x).ConfigDone = False
            xPLDevices(x).ConfigMissing = False
            xPLDevices(x).WaitingConfig = False
        End Select
        Exit Sub
    Case "CONFIG"
        Select Case msgSchemaType
        Case "LIST"
            f = FreeFile()
            Open App.Path & "\Vendor\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml" For Output As #f
            Print #f, "<configuration>" & vbNewLine
            For y = 0 To Msg.NamePairs - 1
                strType = Trim(Msg.Names(y))
                strValue = Trim(Msg.Values(y))
                strNumber = "1"
                z(0) = InStr(1, strValue, "[", vbBinaryCompare)
                z(1) = InStr(1, strValue, "]", vbBinaryCompare)
                If z(0) > 0 And z(1) > 0 Then
                    strNumber = Mid$(strValue, z(0) + 1, z(1) - z(0) - 1)
                    strValue = Trim(Left$(strValue, z(0) - 1))
                End If
                If strNumber = "1" Then
                    Print #f, "  <configitem key=" & Chr(34) & LCase(strValue) & Chr(34) & " type=" & Chr(34) & LCase(strType) & Chr(34) & " />" & vbNewLine
                Else
                    Print #f, "  <configitem key=" & Chr(34) & LCase(strValue) & Chr(34) & " type=" & Chr(34) & LCase(strType) & Chr(34) & " number=" & Chr(34) & strNumber & Chr(34) & " />" & vbNewLine
                End If
            Next
            Print #f, "</configuration>" & vbNewLine
            Close #f
            xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
            xPLDevices(x).ConfigMissing = False
            Call UpdateConfigs(x)
            Call RetrieveConfigs(x)
            Exit Sub
        Case "BASIC", "APP"
            xPLDevices(x).Interval = Val(xPL_GetParam(Msg, "interval", True))
            xPLDevices(x).Expires = DateAdd("n", (2 * xPLDevices(x).Interval) + 1, Now)
            xPLDevices(x).Suspended = False
            xPLDevices(x).ConfigDone = False
            xPLDevices(x).ConfigType = True
            If xPLDevices(x).Current = False And RequestSent = False Then
                Call xPLSys.SendXplMsg("xpl-cmnd", msgSource, "CONFIG.CURRENT", "COMMAND=REQUEST")
            End If
            If xPLDevices(x).ConfigMissing = True Then
                If RequestSent = False Then
                    Call xPLSys.SendXplMsg("xpl-cmnd", msgSource, "CONFIG.LIST", "COMMAND=REQUEST")
                    RequestSent = True
                End If
                xPLDevices(x).WaitingConfig = False
                xPLDevices(x).ConfigMissing = True
                xPLDevices(x).ConfigSource = ""
                xPLDevices(x).ConfigDone = False
                Exit Sub
            End If
        Case "CURRENT"
            ' load current
            xPLDevices(x).ConfiguredCount = -1
            ReDim Preserve xPLDevices(x).Configured(0)
            For y = 0 To Msg.NamePairs - 1
                xPLDevices(x).ConfiguredCount = xPLDevices(x).ConfiguredCount + 1
                ReDim Preserve xPLDevices(x).Configured(xPLDevices(x).ConfiguredCount)
                xPLDevices(x).Configured(xPLDevices(x).ConfiguredCount).Item = Msg.Names(y)
                xPLDevices(x).Configured(xPLDevices(x).ConfiguredCount).Value = Msg.Values(y)
                For l = 0 To xPLDevices(x).ConfiguredCount
                    If UCase(xPLDevices(x).Configs(l).Item) = UCase(Msg.Names(y)) Then
                        xPLDevices(x).Configured(xPLDevices(x).ConfiguredCount).Number = xPLDevices(x).Configs(l).Number
                        l = xPLDevices(x).ConfiguredCount
                    End If
                Next l
            Next y
            If x = Current Then
                Me.Configs.Clear
                For y = 0 To xPLDevices(x).ConfiguredCount
                    Me.Configs.AddItem xPLDevices(x).Configured(y).Item & "=" & xPLDevices(x).Configured(y).Value
                Next y
            End If
            Exit Sub
        Case "END"
            xPLDevices(x).Suspended = True
            xPLDevices(x).ConfigDone = False
            xPLDevices(x).ConfigMissing = False
            xPLDevices(x).WaitingConfig = False
            Exit Sub
        End Select
    End Select

    ' check for existing config
    If Dir(App.Path & "\Configs\" & msgSourceVendor & "-" & msgSourceDevice & "_" & msgSourceInstance & ".cfg") <> "" Then
        ThisConf = msgSourceInstance
        While ThisConf <> ""
            f = FreeFile()
            Open App.Path & "\Configs\" & msgSourceVendor & "-" & msgSourceDevice & "_" & msgSourceInstance & ".cfg" For Input As #f
            strMsg = ""
            NextConf = ""
            While Not EOF(f)
                Line Input #f, strInput
                If strInput <> "" Then
                    strMsg = strMsg + strInput + Chr(10)
                    p = InStr(1, UCase(strInput), "NEWCONF=", vbBinaryCompare)
                    If p > 0 Then
                        NextConf = Mid(strInput, p + 8)
                    End If
                End If
            Wend
            Close #f
            If NextConf <> "" And UCase(NextConf) <> UCase(ThisConf) Then
                n = -1
                If xPLDeviceCount > -1 Then
                    For l = 0 To xPLDeviceCount
                        If xPLDevices(l).VDI = UCase(msgSourceVendor) & "-" & UCase(msgSourceDevice) & "." & UCase(NextConf) Then
                            n = l
                            l = xPLDeviceCount
                        End If
                    Next l
                End If
                If n <> -1 Then
                    xPLDevices(x).Suspended = True
                    xPLDevices(x).ConfigDone = False
                    xPLDevices(x).ConfigMissing = False
                    xPLDevices(x).WaitingConfig = False
                    Call UpdateConfigs(x)
                    x = n
                End If
                xPLDevices(x).VDI = UCase(msgSourceVendor) & "-" & UCase(msgSourceDevice) & "." & UCase(NextConf)
                ThisConf = NextConf
            Else
                Call xPLSys.SendXplMsg("xpl-cmnd", UCase(msgSourceVendor) & "-" & UCase(msgSourceDevice) & "." & UCase(msgSourceInstance), "config.response", strMsg)
                ThisConf = ""
            End If
        Wend
        Me.lblRefresh.Visible = True
        Call RetrieveConfigs(x)
        xPLDevices(x).ConfigMissing = False
        xPLDevices(x).WaitingConfig = False
        xPLDevices(x).ConfigDone = True
        If Dir(App.Path & "\Vendor\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml") <> "" Then
            xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
        Else
            If Dir(App.Path & "\Vendor\" & msgSourceVendor & "-" & msgSourceDevice & ".xml") <> "" Then
                xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".xml"
            Else
                xPLDevices(x).ConfigSource = ""
            End If
            Exit Sub
        End If
        Exit Sub
    End If

    ' check if i have a cached options list
    If Dir(App.Path & "\Vendor\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml") <> "" Then
        ' flag as waiting
        xPLDevices(x).WaitingConfig = True
        xPLDevices(x).ConfigMissing = False
        xPLDevices(x).ConfigDone = False
        xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
        Call UpdateConfigs(x)
        Exit Sub
    End If

    ' check if i have a vendor options list
    If Dir(App.Path & "\Vendor\" & msgSourceVendor & "-" & msgSourceDevice & ".xml") <> "" Then
        ' flag as waiting
        xPLDevices(x).WaitingConfig = True
        xPLDevices(x).ConfigMissing = False
        xPLDevices(x).ConfigDone = False
        xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".xml"
        Call UpdateConfigs(x)
        Exit Sub
    End If

    ' request a list of options
    If RequestSent = False Then
        Call xPLSys.SendXplMsg("xpl-cmnd", msgSource, "CONFIG.LIST", "COMMAND=REQUEST")
    End If
    xPLDevices(x).WaitingConfig = False
    xPLDevices(x).ConfigMissing = True
    xPLDevices(x).ConfigSource = ""
    xPLDevices(x).ConfigDone = False

End Sub

Public Function RetrieveConfigs(d As Integer) As Boolean
    
    Dim strFilename As String
    Dim strMsg As String
    Dim strItem As String
    Dim strValue As String
    Dim strTemp As String
    Dim f As Integer
    Dim x As Integer
    Dim y As Integer
    
    ' find file
    RetrieveConfigs = False
    If d = Current Then Exit Function
    strFilename = xPLDevices(d).VDI + ".cfg"
    x = InStr(1, strFilename, ".", vbBinaryCompare)
    Mid$(strFilename, x, 1) = "_"
    If Dir(App.Path & "\Configs\" & strFilename) = "" Then
        ' clear
        If xPLDevices(d).ConfigCount > -1 Then
            xPLDevices(d).ConfiguredCount = xPLDevices(d).ConfigCount
            ReDim Preserve xPLDevices(d).Configured(xPLDevices(d).ConfiguredCount)
            ' add all
            For x = 0 To xPLDevices(d).ConfigCount
                xPLDevices(d).Configured(x).Item = xPLDevices(d).Configs(x).Item
                xPLDevices(d).Configured(x).Value = xPLDevices(d).Configs(x).Value
            Next x
        End If
        Exit Function
    End If
    ' retrieve
    f = FreeFile
    Open App.Path & "\Configs\" & strFilename For Input As #f
    While Not EOF(f)
        Input #f, strTemp
        If strTemp <> "" Then strMsg = strMsg & strTemp & Chr(10)
    Wend
    Close #f
    ' clear
    xPLDevices(d).ConfiguredCount = -1
    ReDim Preserve xPLDevices(d).Configured(0)
    ' extract
    x = InStr(1, strMsg, "=", vbBinaryCompare)
    While x > 0
        strItem = Left$(strMsg, x - 1)
        strMsg = Mid$(strMsg, x + 1)
        x = InStr(1, strMsg, Chr(10), vbBinaryCompare)
        strValue = Left$(strMsg, x - 1)
        strMsg = Mid$(strMsg, x + 1)
        xPLDevices(d).ConfiguredCount = xPLDevices(d).ConfiguredCount + 1
        ReDim Preserve xPLDevices(d).Configured(xPLDevices(d).ConfiguredCount)
        xPLDevices(d).Configured(xPLDevices(d).ConfiguredCount).Item = strItem
        xPLDevices(d).Configured(xPLDevices(d).ConfiguredCount).Value = strValue
        x = InStr(1, strMsg, "=", vbBinaryCompare)
    Wend
    RetrieveConfigs = True
    
End Function

Public Sub UpdateConfigs(d As Integer)
    
    Dim f As Integer
    Dim strInput As String
    Dim x As Integer
    Dim y As Integer
    
    ' find file
    If d = Current Then Exit Sub
    If xPLDevices(d).ConfigMissing = True Then Exit Sub
    xPLDevices(d).ConfigCount = -1
    f = FreeFile
    Open App.Path & "\Vendor\" & xPLDevices(d).ConfigSource For Input As #f
    While Not EOF(f)
        Line Input #f, strInput
        x = InStr(1, strInput, "key=", vbBinaryCompare)
        If x > 0 Then
            x = x + 5
            y = InStr(x, strInput, Chr$(34), vbBinaryCompare)
            xPLDevices(d).ConfigCount = xPLDevices(d).ConfigCount + 1
            ReDim Preserve xPLDevices(d).Configs(xPLDevices(d).ConfigCount)
            xPLDevices(d).Configs(xPLDevices(d).ConfigCount).Item = Mid$(strInput, x, y - x)
            x = InStr(1, strInput, "type=", vbBinaryCompare)
            x = x + 6
            y = InStr(x, strInput, Chr$(34), vbBinaryCompare)
            xPLDevices(d).Configs(xPLDevices(d).ConfigCount).Type = Mid$(strInput, x, y - x)
            xPLDevices(d).Configs(xPLDevices(d).ConfigCount).Number = 1
            x = InStr(x, strInput, "number=", vbBinaryCompare)
            If x > 0 Then
                x = x + 8
                y = InStr(x, strInput, Chr$(34), vbBinaryCompare)
                xPLDevices(d).Configs(xPLDevices(d).ConfigCount).Number = Val(Mid$(strInput, x, y - x))
            End If
        End If
    Wend
    Close #f
            
End Sub

Public Sub ConfigSend(ByVal intDevice As Integer, ByVal strMsg As String)

    Dim strFilename As String
    Dim strInstance As String
    Dim VDI As String
    Dim f As Integer
    Dim x As Integer
    Dim y As Integer

    ' store base config
    VDI = xPLDevices(intDevice).VDI
    If Right$(strMsg, 2) <> vbCrLf Then strMsg = strMsg + vbCrLf
    strFilename = UCase(xPLDevices(intDevice).VDI)
    x = InStr(1, strFilename, ".", vbBinaryCompare)
    strFilename = Left(strFilename, x - 1) & "_" & Mid(strFilename, x + 1) & ".cfg"
    If LCase(Mid$(xPLDevices(intDevice).VDI, x + 1)) <> "default" Then
        f = FreeFile
        Open App.Path & "\Configs\" & strFilename For Output As #f
        Print #f, strMsg
        Close #f
    End If
    
    ' store for new instance, if found
    x = InStr(1, strMsg, "NEWCONF=", vbTextCompare)
    If x > 0 Then
        x = x + 8
        y = InStr(x, strMsg, vbCrLf, vbBinaryCompare)
        If y > x + 1 Then
            strInstance = Mid$(strMsg, x, y - x)
            x = InStr(1, strFilename, "_", vbBinaryCompare)
            VDI = Left$(xPLDevices(intDevice).VDI, x) & strInstance
            x = InStr(1, strFilename, "_", vbBinaryCompare)
            strFilename = Left(strFilename, x - 1) & "_" & strInstance & ".cfg"
            If UCase(strInstance) <> "DEFAULT" Then
                f = FreeFile
                Open App.Path & "\Configs\" & strFilename For Output As #f
                Print #f, strMsg
                Close #f
            End If
        End If
    End If

    ' send config
    strMsg = Replace(strMsg, vbCrLf, Chr(10), 1, -1)
    Call xPLSys.SendXplMsg("xpl-cmnd", xPLDevices(intDevice).VDI, "config.response", strMsg)
    xPLDevices(intDevice).ConfigMissing = False
    xPLDevices(intDevice).WaitingConfig = False
    xPLDevices(intDevice).ConfigDone = True
    
    ' update device
    If UCase(xPLDevices(intDevice).VDI) <> UCase(VDI) Then
        xPLDevices(intDevice).VDI = UCase(VDI)
    End If
    
    ' send config.current to new/existing instance
    xPLDevices(intDevice).Current = False
    Call xPLSys.SendXplMsg("xpl-cmnd", xPLDevices(intDevice).VDI, "config.current", "command=request")

End Sub

Private Sub xPLExpire_Timer()
    
    Dim x As Integer
    
    ' check for expired
    For x = 0 To xPLDeviceCount
        If xPLDevices(x).Expires < Now And xPLDevices(x).Suspended = False Then
            xPLDevices(x).Suspended = True
            Me.lblRefresh.Visible = True
        End If
    Next x
    
End Sub
