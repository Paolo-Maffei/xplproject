VERSION 5.00
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xPL.ocx"
Begin VB.Form xPL_Template 
   Caption         =   "xPL Template"
   ClientHeight    =   6630
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   7950
   Icon            =   "xPL_Template.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   6630
   ScaleWidth      =   7950
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin xPL.xPLCtl xPLSys 
      Left            =   3120
      Top             =   360
      _ExtentX        =   1508
      _ExtentY        =   1720
   End
   Begin VB.TextBox txtStatus 
      Alignment       =   2  'Center
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   2040
      Locked          =   -1  'True
      TabIndex        =   9
      Top             =   6000
      Width           =   2175
   End
   Begin VB.TextBox txtNextDawn 
      Alignment       =   2  'Center
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   2040
      Locked          =   -1  'True
      TabIndex        =   8
      Top             =   5280
      Width           =   2175
   End
   Begin VB.TextBox txtNextDusk 
      Alignment       =   2  'Center
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   2040
      Locked          =   -1  'True
      TabIndex        =   7
      Top             =   5640
      Width           =   2175
   End
   Begin VB.CommandButton cmdSend 
      Caption         =   "Send &Now"
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
      Index           =   0
      Left            =   6240
      TabIndex        =   6
      Top             =   5160
      Width           =   1215
   End
   Begin VB.CommandButton cmdSend 
      Caption         =   "Set &Day"
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
      Left            =   6240
      TabIndex        =   5
      Top             =   5640
      Width           =   1215
   End
   Begin VB.CommandButton cmdSend 
      Caption         =   "Set N&ight"
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
      Index           =   2
      Left            =   6240
      TabIndex        =   4
      Top             =   6120
      Width           =   1215
   End
   Begin VB.Timer StatusTimer 
      Enabled         =   0   'False
      Interval        =   60000
      Left            =   3840
      Top             =   3600
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
   Begin VB.Label lblxAP 
      Alignment       =   1  'Right Justify
      Caption         =   "Status"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   4
      Left            =   480
      TabIndex        =   12
      Top             =   6000
      Width           =   1215
   End
   Begin VB.Label lblxAP 
      Alignment       =   1  'Right Justify
      Caption         =   "Next Dawn"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   2
      Left            =   480
      TabIndex        =   11
      Top             =   5280
      Width           =   1215
   End
   Begin VB.Label lblxAP 
      Alignment       =   1  'Right Justify
      Caption         =   "Next Dusk"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   3
      Left            =   480
      TabIndex        =   10
      Top             =   5640
      Width           =   1215
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
'* xPL Dawn/Dusk
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

Private Sub cmdSend_Click(Index As Integer)

    Dim strMsg As String
    
    ' action
    Select Case Index
    Case 1 ' set day
        If StatusIsDay = False Then
            ' move to day and set next dawn/dusk
            Call CalculateDuskDawn(DateAdd("d", 0, Now()))
            If Dusk < Now() Then
                Call CalculateDuskDawn(DateAdd("d", 1, Now()))
                NextDusk = Dusk
                Call CalculateDuskDawn(DateAdd("d", 2, Now()))
                NextDawn = Dawn
            Else
                Call CalculateDuskDawn(DateAdd("d", 0, Now()))
                NextDusk = Dusk
                Call CalculateDuskDawn(DateAdd("d", 1, Now()))
                NextDawn = Dawn
            End If
            txtNextDawn = Format(NextDawn, "dd/mm/yy hh:mm")
            txtNextDusk = Format(NextDusk, "dd/mm/yy hh:mm")
            StatusIsDay = True ' day
            txtStatus = "DAY"
        End If
    Case 2 ' set night
        If StatusIsDay = True Then
            ' move to night and set next dusk/dawn
            Call CalculateDuskDawn(DateAdd("d", 0, Now()))
            If Dawn < Now() Then
                Call CalculateDuskDawn(DateAdd("d", 1, Now()))
                NextDusk = Dusk
                Call CalculateDuskDawn(DateAdd("d", 1, Now()))
                NextDawn = Dawn
            Else
                Call CalculateDuskDawn(DateAdd("d", 1, Now()))
                NextDusk = Dusk
                Call CalculateDuskDawn(DateAdd("d", 0, Now()))
                NextDawn = Dawn
            End If
            txtNextDawn = Format(NextDawn, "dd/mm/yy hh:mm")
            txtNextDusk = Format(NextDusk, "dd/mm/yy hh:mm")
            StatusIsDay = False ' day
            txtStatus = "NIGHT"
        End If
    End Select
    
    ' send now
    strMsg = "Type=DAWNDUSK" + Chr$(10)
    Select Case StatusIsDay
    Case True ' day
        strMsg = strMsg + "Status=DAWN"
    Case False ' night
        strMsg = strMsg + "Status=DUSK"
    End Select
    Call xPLSys.SendXplMsg("xpl-stat", "*", "dawndusk.basic", strMsg)
    
End Sub

Private Sub StatusTimer_Timer()

    ' check if dawn has passed
    If Now() > NextDawn Then
        ' send dawn message
        Call xPLSys.SendXplMsg("xpl-trig", "*", "dawndusk.basic", "type=DAWNDUSK" + Chr$(10) + "Status=DAWN")
        ' get next dawn
        Call CalculateDuskDawn(DateAdd("d", 1, Now()))
        NextDawn = Dawn
        StatusIsDay = True ' day
        txtNextDawn = Format(NextDawn, "dd/mm/yy hh:mm")
        txtStatus = "DAY"
    End If
    
    ' check if dusk has passed
    If Now() > NextDusk Then
        ' send dusk message
        Call xPLSys.SendXplMsg("xpl-trig", "*", "danwdusk.basic", "type=DAWNDUSK" + Chr$(10) + "Status=DUSK")
        ' get next dusk
        Call CalculateDuskDawn(DateAdd("d", 1, Now()))
        NextDusk = Dusk
        StatusIsDay = False ' night
        txtNextDusk = Format(NextDusk, "dd/mm/yy hh:mm")
        txtStatus = "NIGHT"
    End If

    ' set current status
    Select Case StatusIsDay
    Case True ' day
        xPLSys.StatusSchema = "Type=DAYNIGHT" & Chr$(10) & "Status=DAY" + Chr$(10)
    Case False ' night
        xPLSys.StatusSchema = "Type=DAYNIGHT" & Chr$(10) & "Status=NIGHT" + Chr$(10)
    End Select

End Sub

' process message
Private Sub xPLSys_Received(Msg As xPL.xPLMsg)
    
    Dim strMsg As String
    
    ' check
    If xPL_Ready = False Then Exit Sub
    If UCase(Msg.Schema) <> "DAWNDUSK.REQUEST" Then Exit Sub
    If UCase(Msg.xPLType) <> "XPL-CMND" Then Exit Sub
    If UCase(xPL_GetParam(Msg, "COMMAND", True)) <> "STATUS" Then Exit Sub
       
    ' process message here @@@
    Select Case UCase(xPL_GetParam(Msg, "QUERY", True))
    Case "DAYNIGHT"
        ' day night
        strMsg = "Type=DAYNIGHT" & Chr$(10)
        Select Case StatusIsDay
        Case True ' day
            strMsg = strMsg + "Status=DAY"
        Case False ' night
            strMsg = strMsg + "Status=NIGHT"
        End Select
        Call xPLSys.SendXplMsg("xpl-stat", "*", "dawndusk.basic", strMsg)
    Case "DAWNDUSK"
        ' dawn dusk
        strMsg = "Type=DAWNDUSK" & Chr$(10)
        Select Case StatusIsDay
        Case True ' day
            strMsg = strMsg & "Status=DAWN"
        Case False ' night
            strMsg = strMsg & "Status=DUSK"
        End Select
        Call xPLSys.SendXplMsg("xpl-stat", "*", "dawndusk.basic", strMsg)
    End Select
    
End Sub

' process config item
Private Sub xPLSys_Config(Item As String, Value As String, Number As Integer)

    ' process config items @@@
    Select Case UCase(Item)
    Case "LONGITUDE"
        Longitude = Val(Value)
    Case "LATITUDE"
        Latitude = Val(Value)
    Case "DAWNADJUST"
        DawnAdj = Val(Value)
        If DawnAdj < -360 Then DawnAdj = -360
        If DawnAdj > 360 Then DawnAdj = 360
    Case "DUSKADJUST"
        DuskAdj = Val(Value)
        If DuskAdj < -360 Then DuskAdj = -360
        If DuskAdj > 360 Then DuskAdj = 360
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
    ' calculate dawn dusk
    StatusTimer.Enabled = False
    If CalculateDuskDawn(Now()) = False Then
        ' no dusk/dawn for given longitude/latitude
        Unload Me
        Exit Sub
    End If
    
    ' has dusk already passed?
    If Dusk <= Now() Then
        ' yes, send initial dusk message
        Call xPLSys.SendXplMsg("xpl-trig", "*", "dawndusk.basic", "type=DAWNDUSK" + Chr$(10) + "Status=DUSK")
        ' get tomorrows dawn/dusk
        Call CalculateDuskDawn(DateAdd("d", 1, Now()))
        NextDawn = Dawn
        NextDusk = Dusk
        StatusIsDay = False ' night
        txtStatus = "NIGHT"
    Else
        ' no, has dawn already passed?
        If Dawn <= Now() Then
            ' yes, send initial dawn message
            Call xPLSys.SendXplMsg("xpl-trig", "*", "dawndusk.basic", "type=DAWNDUSK" + Chr$(10) + "Status=DAWN")
            ' save today dusk
            NextDusk = Dusk
            ' get tomorrows dawn
            Call CalculateDuskDawn(DateAdd("d", 1, Now()))
            NextDawn = Dawn
            StatusIsDay = True ' day
            txtStatus = "DAY"
        Else
            ' no, so send initial dusk message
            Call xPLSys.SendXplMsg("xpl-trig", "*", "dawndusk.basic", "type=DAWNDUSK" + Chr$(10) + "Status=DUSK")
            ' get todays dawn/dusk
            NextDawn = Dawn
            NextDusk = Dusk
            StatusIsDay = False ' night
            txtStatus = "NIGHT"
        End If
    End If
    txtNextDawn = Format(NextDawn, "dd/mm/yy hh:mm")
    txtNextDusk = Format(NextDusk, "dd/mm/yy hh:mm")
    
    ' start timer
    Call StatusTimer_Timer
    StatusTimer.Enabled = True
    
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
    xPL_Source = "TONYT-DAWNDUSK" ' set vendor-device here @@@
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
    xPL_Title = "DawnDusk" ' application title @@@
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
    Call xPLSys.ConfigsAdd("LONGITUDE", "CONFIG", 1)
    Call xPLSys.ConfigsAdd("LATITUDE", "CONFIG", 1)
    Call xPLSys.ConfigsAdd("DAWNADJUST", "OPTION", 1)
    Call xPLSys.ConfigsAdd("DUSKADJUST", "OPTION", 1)
'    etc

    ' add default extra config values if possible @@@
    Longitude = -1
    xPLSys.Configs("LONGITUDE") = Longitude
    Latitude = 50
    xPLSys.Configs("LATITUDE") = Latitude
    DawnAdj = 0
    xPLSys.Configs("DAWNADJUST") = DawnAdj
    DuskAdj = 0
    xPLSys.Configs("DUSKADJUST") = DuskAdj
'    etc

    ' add default filters @@@
    Call xPLSys.FiltersAdd("xpl-cmnd.*.*.*.dawndusk.*")
    ' etc
    
    ' add default groups (not recommended) @@@
'    Call xPLSys.GroupsAdd("MYGROUP")
    ' etc
    
    ' set up other options @@@
    xPLSys.PassCONFIG = False
    xPLSys.PassHBEAT = False
    xPLSys.PassNOMATCH = False
    xPLSys.StatusSchema = "dawndusk.basic" ' schema for status in heartbeat
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

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, Y As Single)
        
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

