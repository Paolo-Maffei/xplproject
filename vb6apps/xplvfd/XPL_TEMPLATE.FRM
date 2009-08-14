VERSION 5.00
Object = "{865E599C-546C-4B46-87BA-244B1D56A96B}#15.0#0"; "xPL.ocx"
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "MSCOMM32.OCX"
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
      Left            =   3000
      Top             =   2880
      _ExtentX        =   1720
      _ExtentY        =   1720
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
      Index           =   1
      Left            =   4080
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   1
      Top             =   720
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
      Height          =   4215
      Index           =   0
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   720
      Width           =   3735
   End
   Begin MSCommLib.MSComm comVFD 
      Index           =   0
      Left            =   2160
      Top             =   4800
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
   End
   Begin MSCommLib.MSComm comVFD 
      Index           =   1
      Left            =   2760
      Top             =   4800
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
   End
   Begin MSCommLib.MSComm comVFD 
      Index           =   2
      Left            =   3360
      Top             =   4800
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
   End
   Begin MSCommLib.MSComm comVFD 
      Index           =   3
      Left            =   3960
      Top             =   4800
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
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
    
    Dim strVFDCommand As String
    Dim strOSDText1 As String
    Dim strOSDCommand As String
    Dim strOSDDelay As String
    Dim strOSDZone As String
    Dim loopcounter As Integer
    Dim tmrStart, tmrClear, tmrNow

    ' check
    If xPL_Ready = False Then Exit Sub
    
    ' process message here @@@
    ' get the OSD commands
    strOSDText1 = ""
    strOSDZone = ""
    strOSDText1 = xPL_GetParam(Msg, "TEXT", True)
    strOSDCommand = xPL_GetParam(Msg, "COMMAND", True)
    strOSDDelay = xPL_GetParam(Msg, "DELAY", True)
    strOSDZone = xPL_GetParam(Msg, "ZONE", True)
    
    'Handle OSD Type Messages
    If strOSDText1 <> "" Then
       strVFDCommand = Trim(strOSDText1)
    End If
    
    If Trim(xPL_VFD1_Port) <> "" And (strOSDZone = xPL_VFD1_ZoneName Or strOSDZone = "*" Or Trim(strOSDZone) = "") Then
       comVFD(0).Output = Chr(&HE) & Chr(&HC)
       comVFD(0).Output = strVFDCommand
    End If
    
    If Trim(xPL_VFD2_Port) <> "" And (strOSDZone = xPL_VFD2_ZoneName Or strOSDZone = "*" Or Trim(strOSDZone) = "") Then
       comVFD(1).Output = Chr(&HE) & Chr(&HC)
       comVFD(1).Output = strVFDCommand
    End If
    
    If Trim(xPL_VFD3_Port) <> "" And (strOSDZone = xPL_VFD3_ZoneName Or strOSDZone = "*" Or Trim(strOSDZone) = "") Then
       comVFD(2).Output = Chr(&HE) & Chr(&HC)
       comVFD(2).Output = strVFDCommand
    End If
    
    If Trim(xPL_VFD4_Port) <> "" And (strOSDZone = xPL_VFD4_ZoneName Or strOSDZone = "*" Or Trim(strOSDZone) = "") Then
       comVFD(3).Output = Chr(&HE) & Chr(&HC)
       comVFD(3).Output = strVFDCommand
    End If
    
    'now set the timer to clear the screen
    If strOSDDelay = "" Then strOSDDelay = "10"
    
    tmrNow = Timer    'get the time now.
    tmrClear = tmrNow + Val(strOSDDelay)
clrloop: While tmrNow < tmrClear
            tmrNow = Timer
            DoEvents
            GoTo clrloop
         Wend
         Call Clear_VFD
End Sub


' process config item
Private Sub xPLSys_Config(Item As String, Value As String, Occurance As Integer)

    ' process config items @@@
    ' IF you want to use your own variables
    ' OR you want to take some action
    Select Case UCase(Item)
           Case "VFD1PORT"
                xPL_VFD1_Port = UCase(Value)
           Case "VFD2PORT"
                xPL_VFD2_Port = UCase(Value)
           Case "VFD3PORT"
                xPL_VFD3_Port = UCase(Value)
           Case "VFD4PORT"
                xPL_VFD4_Port = UCase(Value)
           Case "ZONE1LBL"
                xPL_VFD1_ZoneName = UCase(Value)
           Case "ZONE2LBL"
                xPL_VFD2_ZoneName = UCase(Value)
           Case "ZONE3LBL"
                xPL_VFD3_ZoneName = UCase(Value)
           Case "ZONE4LBL"
                xPL_VFD4_ZoneName = UCase(Value)
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
    
    If Trim(xPL_VFD1_Port) <> "" Then
       comVFD(0).CommPort = xPL_VFD1_Port
       comVFD(0).Settings = "19200,E,8,1"
       comVFD(0).PortOpen = True
       comVFD(0).Output = Chr(&HE) & Chr(&HC)
       comVFD(0).Output = "VFD Display One Initialised." & Chr(&HA) & Chr(&HD) & "xPL Rocks Your World!"
    End If
    
    If Trim(xPL_VFD2_Port) <> "" Then
       comVFD(1).CommPort = xPL_VFD2_Port
       comVFD(1).Settings = "19200,E,8,1"
       comVFD(1).PortOpen = True
       comVFD(1).Output = Chr(&HE) & Chr(&HC)
       comVFD(1).Output = "VFD Display Two Initialised." & Chr(&HA) & Chr(&HD) & "xPL Rocks Your World!"
    End If
    
    If Trim(xPL_VFD3_Port) <> "" Then
       comVFD(2).CommPort = xPL_VFD3_Port
       comVFD(2).Settings = "19200,E,8,1"
       comVFD(2).PortOpen = True
       comVFD(2).Output = Chr(&HE) & Chr(&HC)
       comVFD(2).Output = "VFD Display Three Initialised." & Chr(&HA) & Chr(&HD) & "xPL Rocks Your World!"
    End If
    
    If Trim(xPL_VFD4_Port) <> "" Then
       comVFD(3).CommPort = xPL_VFD4_Port
       comVFD(3).Settings = "19200,E,8,1"
       comVFD(3).PortOpen = True
       comVFD(3).Output = Chr(&HE) & Chr(&HC)
       comVFD(3).Output = "VFD Display Three Initialised." & Chr(&HA) & Chr(&HD) & "xPL Rocks Your World!"
    End If
 
    ' flag as configured
    xPL_Ready = True
    
End Sub

' display message received - remove if display not required @@@
Private Sub xPLSys_xPLRX(Msg As String)
    
    ' display message
    Call xPL_Display(0, Msg)
    
End Sub

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
    xPL_Source = "WMUTE-VFDOSD.DEFAULT" ' set default vendor-device.instance @@@
    If Dir(App.Path + "\source.cfg") <> "" Then
        x = FreeFile
        Open App.Path + "\source.cfg" For Input As #x
        Input #x, xPL_Source
        Close #x
    End If
    xPL_WaitForConfig = True ' set to false if config not required (not recommended) @@@
    xPL_Ready = False
    xPL_Title = "Template" ' application title @@@
    Me.Caption = xPL_Title + " " + xPL_Source
    Me.lblxPL(0) = "xPL RX" ' receive box label @@@
    Me.lblxPL(1) = "xPL TX" ' receive box label @@@
    Me.mPopRestore.Caption = xPL_Source
    
    ' pre initialise
    If xPLSys.Initialise(xPL_Source, xPL_WaitForConfig, 5) = False Then
        ' failed to pre-initialise
        Unload Me
        Exit Sub
    End If
    
    ' add extra configs (set config/reconf/option as needed) @@@
     Call xPLSys.ConfigsAdd("VFD1PORT", "RECONF", 1)
     Call xPLSys.ConfigsAdd("VFD2PORT", "RECONF", 1)
     Call xPLSys.ConfigsAdd("VFD3PORT", "RECONF", 1)
     Call xPLSys.ConfigsAdd("VFD4PORT", "RECONF", 1)
     Call xPLSys.ConfigsAdd("ZONE1LBL", "RECONF", 1)
     Call xPLSys.ConfigsAdd("ZONE2LBL", "RECONF", 1)
     Call xPLSys.ConfigsAdd("ZONE3LBL", "RECONF", 1)
     Call xPLSys.ConfigsAdd("ZONE4LBL", "RECONF", 1)

    ' add default extra config values if possible @@@
     xPLSys.Configs("ZONE1LBL") = "ZoneOne"
     xPLSys.Configs("ZONE2LBL") = "ZoneTwo"
     xPLSys.Configs("ZONE3LBL") = "ZoneThree"
     xPLSys.Configs("ZONE4LBL") = "ZoneFour"

    ' add default filters @@@
    Call xPLSys.FiltersAdd("*.*.*.*.*.*")
    ' etc
    
    ' set up other options @@@
    xPLSys.PassCONFIG = True
    xPLSys.PassHBEAT = False
    xPLSys.PassNOMATCH = True
    xPLSys.StatusSchema = "" ' schema for status in heartbeat
    xPLSys.StatusMsg = "" ' message for status in heartbeat
    
    ' initialise other stuff here prior to start @@@
    
    ' initialise xPL
    If xPLSys.Start = False Then
        ' failed to initialise
        Unload Me
        Exit Sub
    End If
    
    ' initialise other stuff here after start @@@
    Call Clear_VFD

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


Private Sub Clear_VFD()
   If Trim(xPL_VFD1_Port) <> "" Then
      comVFD(0).Output = Chr(&HE) & Chr(&HC) & Chr(&H16)
   End If
    
   If Trim(xPL_VFD2_Port) <> "" Then
      comVFD(1).Output = Chr(&HE) & Chr(&HC) & Chr(&H16)
   End If
    
   If Trim(xPL_VFD3_Port) <> "" Then
      comVFD(2).Output = Chr(&HE) & Chr(&HC) & Chr(&H16)
   End If
    
   If Trim(xPL_VFD4_Port) <> "" Then
      comVFD(3).Output = Chr(&HE) & Chr(&HC) & Chr(&H16)
   End If
End Sub


