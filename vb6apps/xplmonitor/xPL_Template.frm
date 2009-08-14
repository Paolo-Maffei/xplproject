VERSION 5.00
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xpl.ocx"
Begin VB.Form xPL_Template 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "xPL Template"
   ClientHeight    =   7230
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   6735
   Icon            =   "xPL_Template.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   7230
   ScaleWidth      =   6735
   StartUpPosition =   3  'Windows Default
   Begin xPL.xPLCtl xPLSys 
      Left            =   7080
      Top             =   5760
      _ExtentX        =   661
      _ExtentY        =   1508
   End
   Begin VB.CheckBox chkLog 
      Caption         =   "Log All Messages?"
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
      Left            =   720
      TabIndex        =   11
      Top             =   6720
      Width           =   2175
   End
   Begin VB.CommandButton cmdPrev 
      Caption         =   "Prev"
      Enabled         =   0   'False
      Height          =   375
      Left            =   3360
      TabIndex        =   10
      Top             =   6720
      Width           =   975
   End
   Begin VB.CommandButton cmdNext 
      Caption         =   "Next"
      Enabled         =   0   'False
      Height          =   375
      Left            =   4425
      TabIndex        =   9
      Top             =   6720
      Width           =   975
   End
   Begin VB.CheckBox chkRawFormat 
      Caption         =   "Friendly Display"
      Height          =   255
      Left            =   4200
      TabIndex        =   4
      Top             =   6000
      Value           =   1  'Checked
      Width           =   1695
   End
   Begin VB.CheckBox chkLiveUpdate 
      Caption         =   "Live Update"
      Height          =   375
      Left            =   4200
      TabIndex        =   3
      Top             =   6255
      Value           =   1  'Checked
      Width           =   1815
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
      Height          =   5655
      Index           =   0
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   2
      Top             =   120
      Width           =   6495
   End
   Begin VB.Label Label1 
      Caption         =   "xPL Messages:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   240
      TabIndex        =   8
      Top             =   5880
      Width           =   1755
   End
   Begin VB.Label lblMsgCount 
      Alignment       =   1  'Right Justify
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2040
      TabIndex        =   7
      Top             =   5880
      Width           =   1095
   End
   Begin VB.Label lblMsgView 
      Alignment       =   1  'Right Justify
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2040
      TabIndex        =   6
      Top             =   6240
      Width           =   1095
   End
   Begin VB.Label Label2 
      Caption         =   "Viewing:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   840
      TabIndex        =   5
      Top             =   6240
      Width           =   945
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
      Left            =   3960
      TabIndex        =   1
      Top             =   7440
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
      Left            =   0
      TabIndex        =   0
      Top             =   7440
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

Dim intMsgCount As Integer          'global received message count
Dim intCurrView As Integer          'what message are we viewing?
Dim arrMsgStore                     'Array for storing inbound messages

Option Explicit

' process message
Private Sub xPLSys_Received(Msg As xPLMsg)

    ' check
    If xPL_Ready = False Then Exit Sub
    
    ' process message here @@@
    ' etc
    
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
    
    ' flag as configured
    xPL_Ready = True
    
End Sub

' display message received - remove if display not required @@@
Private Sub xPLSys_xPLRX(Msg As String)
    
    intMsgCount = intMsgCount + 1               'increment message count
    lblMsgCount.Caption = intMsgCount           'post new message count
    arrMsgStore(intMsgCount) = Msg              'always save raw data
    ReDim Preserve arrMsgStore(intMsgCount + 1) 'make the array bigger for next time
    If chkLiveUpdate.Value = 1 Then
       UpdateDisplay
       intCurrView = intMsgCount
    End If

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
    xPL_Source = "WMUTE-MONITOR.DEFAULT" ' set default vendor-device.instance @@@
    If Dir(App.Path + "\source.cfg") <> "" Then
        x = FreeFile
        Open App.Path + "\source.cfg" For Input As #x
        Input #x, xPL_Source
        Close #x
    End If
    'This is a general purpose monitor application, so no config required.
    xPL_WaitForConfig = False ' set to false if config not required (not recommended) @@@
    xPL_Ready = False
    xPL_Title = "xPL Monitor" ' application title @@@
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
'    Call xPLSys.ConfigsAdd("LATITUDE", "CONFIG",1)
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
    ReDim arrMsgStore(1)          'Initialise the message buffer
    
    ' initialise xPL
    If xPLSys.Start = False Then
        ' failed to initialise
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
    End If
    'Me.WindowState = vbMinimized
    
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

Public Function CleanString(strRaw)

Dim intCounter As Integer
Dim strClean As String

strClean = ""                                       'Initialise the new sring
For intCounter = 1 To Len(strRaw)
    Select Case Mid(strRaw, intCounter, 1)
           Case Chr(2)
                strClean = strClean & "<STX>"       'xAP start character
           Case Chr(10)
                strClean = strClean & vbCrLf        'xAP LF Character
           Case Chr(3)
                strClean = strClean & "<ETX>"       'xAP end character
           Case Else
                strClean = strClean & Mid(strRaw, intCounter, 1)
    End Select
Next

CleanString = strClean

End Function

Public Sub UpdateDisplay(Optional intRecNum As Integer)
    
    If chkLiveUpdate.Value = 1 Then
        intCurrView = intMsgCount                                   'update the current view variable
        If chkRawFormat.Value = 0 Then
            txtMsg(0).Text = arrMsgStore(intMsgCount)               'post the latest raw data
        Else
            txtMsg(0).Text = CleanString(arrMsgStore(intMsgCount))  'post the latest "clean" data
        End If
    Else
        If chkRawFormat.Value = 0 Then
            txtMsg(0).Text = arrMsgStore(intRecNum)               'post the requested raw data
        Else
            txtMsg(0).Text = CleanString(arrMsgStore(intRecNum))  'post the requested "clean" data
        End If
    End If
    lblMsgView.Caption = intCurrView    'Show what we are viewing, not how many messages are here
End Sub

Private Sub chkLiveUpdate_Click()
If chkLiveUpdate.Value = 0 Then         'No live update
    If intCurrView < intMsgCount And intMsgCount > 1 Then
        cmdNext.Enabled = True
    Else
        cmdNext.Enabled = False
    End If
    If intCurrView <= 1 Then
        cmdPrev.Enabled = False
    Else
        cmdPrev.Enabled = True
    End If
Else                                    'Live update
    cmdNext.Enabled = False
    cmdPrev.Enabled = False
    UpdateDisplay
End If
End Sub

Private Sub chkRawFormat_Click()
   UpdateDisplay (intCurrView)
End Sub

Private Sub cmdNext_Click()
If intCurrView + 1 <= intMsgCount Then
   intCurrView = intCurrView + 1
   UpdateDisplay (intCurrView)
End If

If intCurrView < intMsgCount Then
    cmdNext.Enabled = True
Else
    cmdNext.Enabled = False
End If
If intCurrView <= 1 Then
    cmdPrev.Enabled = False
Else
    cmdPrev.Enabled = True
End If
End Sub

Private Sub cmdPrev_Click()
If intCurrView - 1 >= 1 Then
   intCurrView = intCurrView - 1
   UpdateDisplay (intCurrView)
End If

If intCurrView < intMsgCount Then
    cmdNext.Enabled = True
Else
    cmdNext.Enabled = False
End If
If intCurrView <= 1 Then
    cmdPrev.Enabled = False
Else
    cmdPrev.Enabled = True
End If
    
End Sub

