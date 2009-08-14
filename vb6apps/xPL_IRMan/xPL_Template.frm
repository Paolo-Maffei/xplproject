VERSION 5.00
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xPL.ocx"
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "MSCOMM32.OCX"
Begin VB.Form xPL_Template 
   Caption         =   "xPL Template"
   ClientHeight    =   6525
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4005
   Icon            =   "xPL_Template.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   6525
   ScaleWidth      =   4005
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin MSCommLib.MSComm xPLIRMan 
      Left            =   1800
      Top             =   5760
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
   End
   Begin xPL.xPLCtl xPLSys 
      Left            =   600
      Top             =   240
      _ExtentX        =   1720
      _ExtentY        =   1720
   End
   Begin VB.CommandButton cmdIrBase 
      Caption         =   "&IR Codes"
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
      Left            =   2640
      TabIndex        =   4
      Top             =   6000
      Width           =   1215
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
      Height          =   4200
      Index           =   1
      Left            =   120
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
      Height          =   855
      Index           =   0
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   4800
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
      Height          =   615
      Index           =   1
      Left            =   120
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
'* xPL IRMan
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

' the com control could be replaced with another com ocx
' in which case the other com port settings may not be required

Option Explicit

Private Sub cmdIrBase_Click()

    ' show settings form
    IRManIR.Show 1

End Sub

Private Sub xPLIRMan_OnComm()
    
    Dim str As String
    Dim str2 As String
    Static init As Boolean
    Static HexCode As String
    Dim x As Integer

tryagain:
    str = xPLIRMan.Input
    If str = "OK" Then
        init = True
        Exit Sub
    End If
    If init = False Then Exit Sub
    
    For x = 1 To Len(str)
        str2 = Hex(Asc(Mid$(str, x, 1)))
        If Len(str2) = 1 Then str2 = "0" + str2
        HexCode = HexCode + str2
        If Len(HexCode) >= 12 Then
            Call xPLIRMan_KeyPressed(Left$(HexCode, 12))
            HexCode = Mid$(HexCode, 13)
        End If
    Next x
    If xPLIRMan.InputLen > 0 Then GoTo tryagain
    
End Sub

Private Sub xPLIRMan_KeyPressed(ByVal HexCode As String)
    
    Dim Msg As String
    Dim x As Long
    
    ' are we learning
    If Learning = True Then
        ' store and display
        IRMan(IRManIR.cmbCodes.ListIndex + 1).IRCode = HexCode
        IRManIR.txtIrCode = HexCode
        IRManIR.cmdSave.Enabled = True
        Learning = False
        IRManIR.cmbCodes.Enabled = True
        IRManIR.txtDevice.Locked = False
        IRManIR.txtButton.Locked = False
        IRManIR.cmdDelete.Enabled = True
        IRManIR.cmdNew.Enabled = True
        IRManIR.cmdLearn.Enabled = True
        IRManIR.cmdSave.Enabled = True
        IRManIR.cmdReload.Enabled = True
        IRManIR.cmdSave.SetFocus
        IRManIR.cmdCancel.Visible = False
        Exit Sub
    End If
    
    ' send xpl
    If Len(HexCode) < 2 Then Exit Sub
    Me.txtMsg(0) = HexCode
    Msg = ""
    If xPLSys.Configs("ZONE") <> "" Then
        Msg = Msg & "zone=" & xPLSys.Configs("ZONE") & Chr$(10)
    Else
        x = InStr(1, xPL_Source, ".", vbBinaryCompare)
        Msg = Msg & "zone=" & Mid$(xPL_Source, x + 1) & Chr$(10)
    End If
    For x = 1 To IRManCodes
        If IRMan(x).IRCode = HexCode Then
            ' got match
            Msg = Msg & "device=" & IRMan(x).Device & Chr$(10)
            Msg = Msg & "keys=" & IRMan(x).Button & Chr$(10)
            GoTo gotirmatch
        End If
    Next x
    Msg = Msg & "device=" & xPL_Source & Chr$(10)
    Msg = Msg & "keys=" & HexCode & Chr$(10)
    
gotirmatch:
    Call xPLSys.SendXplMsg("xpl-trig", "*", "remote.basic", Msg)

End Sub

' process message
Private Sub xPLSys_Received(Msg As xPL.xPLMsg)

    Dim strMsg As String
    Dim x As Integer
    
    ' check
    If xPL_Ready = False Then Exit Sub
    
    ' process message here @@@
    
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
    
    Dim d As Date
    Dim t(1) As Variant
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
    
    
    ' configure port
    On Error Resume Next
    xPLIRMan.PortOpen = False
    On Error GoTo 0
    xPLIRMan.CommPort = Val(xPLSys.Configs("COMPORT")) ' port no
    
    ' further application specific processing @@@
    
    
    ' flag as configured
    xPL_Ready = True
    
    ' open port
    On Error GoTo openportfails
    xPLIRMan.PortOpen = True
    On Error GoTo 0
    d = Now
    While Now < DateAdd("s", 2, d)
        DoEvents
    Wend
    t(0) = "I"
    t(1) = "R"
    Me.xPLIRMan.Output = t(0)
    While Now < DateAdd("s", 1, d)
        DoEvents
    Wend
    Me.xPLIRMan.Output = t(1)

    Exit Sub
    
openportfails:
    On Error GoTo 0
    
End Sub


' display message received - remove if display not required @@@
Private Sub xPLSys_xPLRX(Msg As String)
    
    ' display message
 '   Call xPL_Display(0, Msg)
    
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
    xPL_Source = "TONYT-IRMAN" ' set vendor-device here @@@
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
    xPL_Title = "IRMan" ' application title @@@
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
    Call xPLSys.ConfigsAdd("ZONE", "RECONF", 1)
    
    ' some app's may only need comport, as rest may be known fixed settings
'    Call xPLSys.ConfigsAdd("LATITUDE","OPTION")
'    etc

    ' add default extra config values if possible @@@
    xPLSys.Configs("COMPORT") = "1"
    xPLSys.Configs("ZONE") = ""
'    etc

    ' add default filters @@@
   ' Call xPLSys.FiltersAdd("XPL-CMND.*.*.*.REMOTE.BASIC")
    ' etc
    
    ' add default groups (not recommended) @@@
'    Call xPLSys.GroupsAdd("MYGROUP")
    ' etc
    
    ' set up other options @@@
    xPLSys.PassCONFIG = False
    xPLSys.PassHBEAT = False
    xPLSys.PassNOMATCH = True
    xPLSys.StatusSchema = "" ' schema for status in heartbeat
    xPLSys.StatusMsg = "" ' message for status in heartbeat
    
    ' initialise other stuff here prior to start @@@
    Call LoadIRDatabase
    
    ' initialise xPL
    If xPLSys.Start = False Then
        ' failed to initialise
        Call MsgBox("Sorry, unable to start xPL sub-system.", vbCritical + vbOKOnly, "xPL Start Failed")
        Unload Me
        Exit Sub
    End If
    
    ' initialise other stuff here after start @@@
    Me.xPLIRMan.RThreshold = 1
    Me.xPLIRMan.SThreshold = 1
    Me.xPLIRMan.Handshaking = comNone
    Me.xPLIRMan.Settings = "9600,n,8,1"
    Me.xPLIRMan.CommPort = 4
    Me.xPLIRMan.DTREnable = True
    Me.xPLIRMan.RTSEnable = True
    Me.xPLIRMan.OutBufferSize = 1
    
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
    
    Dim d As Date
    
    ' close com port, if open
    On Error Resume Next
    xPLIRMan.PortOpen = False
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

