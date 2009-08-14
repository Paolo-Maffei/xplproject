VERSION 5.00
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "MSCOMM32.OCX"
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xPL.ocx"
Begin VB.Form xPL_Template 
   Caption         =   "xPL Template"
   ClientHeight    =   5130
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   7950
   Icon            =   "xPL_Template.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   5130
   ScaleWidth      =   7950
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer tmrSendProbe 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   3240
      Top             =   4440
   End
   Begin VB.Timer tmrAutoProbe 
      Enabled         =   0   'False
      Interval        =   60000
      Left            =   2520
      Top             =   4320
   End
   Begin xPL.xPLCtl xPLSys 
      Left            =   3240
      Top             =   360
      _ExtentX        =   1508
      _ExtentY        =   1508
   End
   Begin MSCommLib.MSComm xPLCOM 
      Left            =   3960
      Top             =   4320
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
'* xPL Framework with COM Port Support
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

Private Sub tmrAutoProbe_Timer()
    
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    Dim Zone As String
    Dim Probe As String
    Dim ProbeMsg As String
    
    For z = 1 To 16
        If ProbeAutos(z).Interval > 0 Then
            ProbeAutos(z).Counter = ProbeAutos(z).Counter - 1
            If ProbeAutos(z).Counter < 1 Then
                ' probe
                Zone = UCase(ProbeAutos(z).ZoneName)
                Probe = UCase(ProbeAutos(z).ProbeName)
                For x = 1 To 8
                    If Zone = Probes(x).ZoneName Then
                        Zone = Trim(x)
                        Exit For
                    End If
                Next x
                If x = 9 Then
                    ProbeAutos(z).Interval = 0
                    GoTo cancelauto ' not found
                End If
                If Probe <> "ALL" Then
                    For y = 1 To 6
                        If Probe = Probes(x).ProbeNames(y) Then
                            Probe = Trim(y)
                            Exit For
                        End If
                    Next y
                    If y = 7 Then
                        ProbeAutos(z).Interval = 0
                        GoTo cancelauto
                    End If
                End If
                            
                ' send query to probe
                Select Case Probe
                Case "ALL"
                    ProbeMsg = "#QA" & Zone & vbCr
                Case Else
                    ProbeMsg = "#Q" & Zone & Probe & vbCr
                End Select
                PushProbe (ProbeMsg)
                
                ' reset
                ProbeAutos(z).Counter = ProbeAutos(z).Interval
            End If
        End If
cancelauto:
    Next z
    
End Sub

Private Sub tmrSendProbe_Timer()
        
    Dim strMsg As String
    strMsg = PopProbe
    If strMsg <> "" Then
        On Error Resume Next
        xPLCOM.Output = strMsg
        On Error GoTo 0
        ResponseWait = True
    Else
        ResponseWait = False
    End If
    
End Sub

' process message
Private Sub xPLSys_Received(Msg As xPL.xPLMsg)

    Dim strMsg As String
    Dim x As Integer
    Dim y As Integer
    Dim Zone As String
    Dim Probe As String
    Dim ProbeMsg As String

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
    If LCase(Msg.Schema) <> "probe.basic" Then Exit Sub
    Zone = UCase(xPL_GetParam(Msg, "ZONE", True))
    Probe = UCase(xPL_GetParam(Msg, "PROBE", True))
    For x = 1 To 8
        If Zone = Probes(x).ZoneName Then
            Zone = Trim(x)
            Exit For
        End If
    Next x
    If x = 9 Then Exit Sub ' not found
    If Probe <> "ALL" Then
        For y = 1 To 6
            If Probe = Probes(x).ProbeNames(y) Then
                Probe = Trim(y)
                Exit For
            End If
        Next y
        If y = 7 Then Exit Sub
    End If
        
    ' send query to probe
    Select Case Probe
    Case "ALL"
        ProbeMsg = "#QA" & Zone & vbCr
    Case Else
        ProbeMsg = "#Q" & Zone & Probe & vbCr
    End Select
    PushProbe (ProbeMsg)

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
    
    Dim f As Integer
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    Dim str As String
    
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
    
    ' get zone and probe names, and alerts
    For x = 1 To 8
        If UCase(xPLSys.Configs("ZONES", x)) <> "" Then
            Probes(x).ZoneName = UCase(xPLSys.Configs("ZONES", x))
        Else
            Probes(x).ZoneName = Trim(x)
        End If
        str = UCase(xPLSys.Configs("PROBES", x))
        For y = 1 To 6
            If str <> "" Then
                z = InStr(1, str, ",", vbBinaryCompare)
                If z > 0 Then
                    If z > 1 Then
                        Probes(x).ProbeNames(y) = UCase(Trim(Left$(str, z - 1)))
                        str = Mid(str, z + 1)
                    Else
                        Probes(x).ProbeNames(y) = Trim(y)
                        str = Mid(str, z + 1)
                    End If
                Else
                    Probes(x).ProbeNames(y) = UCase(Trim(str))
                    str = ""
                End If
            Else
                Probes(x).ProbeNames(y) = Trim(y)
            End If
        Next y
        str = LCase(xPLSys.Configs("HIALERT", x))
        For y = 1 To 2
            If str <> "" Then
                z = InStr(1, str, ",", vbBinaryCompare)
                If z > 0 Then
                    If z > 1 Then
                        Probes(x).HiAlert(y) = Val(Trim(Left$(str, z - 1)))
                        str = Mid(str, z + 1)
                    Else
                        Probes(x).HiAlert(y) = 250
                        str = Mid(str, z + 1)
                    End If
                Else
                    Probes(x).HiAlert(y) = Val(Trim(str))
                    str = ""
                End If
            Else
                Probes(x).HiAlert(y) = 250
            End If
        Next y
        str = LCase(xPLSys.Configs("LOALERT", x))
        For y = 1 To 2
            If str <> "" Then
                z = InStr(1, str, ",", vbBinaryCompare)
                If z > 0 Then
                    If z > 1 Then
                        Probes(x).LoAlert(y) = Val(Trim(Left$(str, z - 1)))
                        str = Mid(str, z + 1)
                    Else
                        Probes(x).LoAlert(y) = -250
                        str = Mid(str, z + 1)
                    End If
                Else
                    Probes(x).LoAlert(y) = Val(Trim(str))
                    str = ""
                End If
            Else
                Probes(x).LoAlert(y) = -250
            End If
        Next y
    Next x
    
    tmrAutoProbe.Enabled = False
    Dim tmpAuto As ProbeAutoStruc
    For x = 1 To 16
        str = Trim(UCase(xPLSys.Configs("AUTO", x)))
        tmpAuto.ZoneName = ""
        tmpAuto.ProbeName = ""
        tmpAuto.Interval = 0
        tmpAuto.Counter = 0
        y = InStr(1, str, ",", vbBinaryCompare)
        If y > 0 Then
            tmpAuto.ZoneName = Left(str, y - 1)
            str = Mid(str, y + 1)
            y = InStr(1, str, ",", vbBinaryCompare)
            If y > 0 Then
                tmpAuto.ProbeName = Left(str, y - 1)
                tmpAuto.Interval = Val(Mid(str, y + 1))
            End If
        End If
        If tmpAuto.ZoneName <> "" And tmpAuto.ProbeName <> "" And tmpAuto.Interval > 0 Then
            ProbeAutos(x).Counter = tmpAuto.Interval
            ProbeAutos(x).Interval = tmpAuto.Interval
            ProbeAutos(x).ZoneName = tmpAuto.ZoneName
            ProbeAutos(x).ProbeName = tmpAuto.ProbeName
        Else
            ProbeAutos(x).Counter = 10
            ProbeAutos(x).Interval = 0
            ProbeAutos(x).ZoneName = ""
            ProbeAutos(x).ProbeName = ""
        End If
    Next x
    tmrAutoProbe.Enabled = True
    
    ' configure port
    If xPLCOM.PortOpen = False Then GoTo notopen
    On Error Resume Next
    xPLCOM.PortOpen = False
    On Error GoTo 0
    If Val(xPLSys.Configs("COMPORT")) < 0 Then
        Dim d As Date
        d = DateAdd("s", 7, Now)
        Me.Caption = xPL_Title + " " + xPL_Source + " Disconnecting COM Port..."
        While d > Now
            DoEvents
        Wend
        Me.Caption = xPL_Title + " " + xPL_Source
    End If
notopen:
    On Error GoTo openportfails
    xPLCOM.Settings = "9600,n,8,1"
    xPLCOM.DTREnable = False
    xPLCOM.RTSEnable = False
    xPLCOM.Handshaking = comNone
    xPLCOM.RThreshold = 1 ' receive all
    xPLCOM.InputMode = comInputModeText ' always text
    xPLCOM.CommPort = Abs(Val(xPLSys.Configs("COMPORT"))) ' port no
    On Error GoTo 0
    
    ' further application specific processing @@@

    ' flag as configured
    xPL_Ready = True
    
    ' open port
    On Error GoTo openportfails
    xPLCOM.PortOpen = True
    On Error GoTo 0
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
    Dim str As String
    Dim Zone As String
    Dim Probe As String
    Dim Status As String
    Dim strCheckSum As String
    Dim IsTemp As Boolean
    Dim IsAlert As String
    Dim chkAlert As Double
    
    ' get data
    If xPLCOM.CommEvent <> comEvReceive Then Exit Sub
lookformoredata:
    If xPLCOM.InBufferCount = 0 Then Exit Sub ' no data
    xPLCOM.InputLen = xPLCOM.InBufferCount
    xPLCOMCmd = xPLCOMCmd + xPLCOM.Input
            
'    ' process pass thru
'    If xPL_COMPassThru = True Then
'        ' looking for xPL message
'lookfornextmsg:
'        While Left$(xPLCOMCmd, 1) <> Chr$(2) And Len(xPLCOMCmd) > 0
'            xPLCOMCmd = Mid$(xPLCOMCmd, 2)
'        Wend
'        If Len(xPLCOMCmd) = 0 Then GoTo lookformoredata ' no data
'        w = InStr(1, xPLCOMCmd, Chr$(3), vbBinaryCompare)
'        If w = 0 Then GoTo lookformoredata ' incomplete message, wait
'        strMsg = Left$(xPLCOMCmd, w)
'        xPLCOMCmd = Mid$(xPLCOMCmd, w + 1)
'        ' check I didn't send it
'        strMsg = Mid$(strMsg, 2)
'        strMsg = Left$(strMsg, Len(strMsg) - 1)
'        ' unpack it
'        Msg = xPLSys.xPLExtract(strMsg)
'        If Msg.NamePairs = 0 Then Exit Sub ' not valid
'        If xPL_GetParam(Msg, "SOURCE", True) = UCase(xPL_Source) Then
'            Exit Sub ' not interested in talking to myself
'        End If
'        ' build message
'        strMsg = Msg.xPLType & Chr$(10) & "{" & Chr$(10)
'        If Msg.Hop + 1 > 10 Then Exit Sub ' too many hops
'        strMsg = strMsg & "hop=" & Msg.Hop + 1 & Chr$(10)
'        strMsg = strMsg & "source=" & Msg.Source & Chr$(10)
'        strMsg = strMsg & "target=" & Msg.Target & Chr$(10)
'        strMsg = strMsg & "}" & Chr$(10)
'        strMsg = strMsg & Msg.Schema & Chr$(10) & "{" & Chr$(10)
'        For x = 0 To Msg.NamePairs - 1
'            strMsg = strMsg & LCase(Msg.Names(x)) & "=" & Msg.Values(x) & Chr$(10)
'        Next x
'        strMsg = strMsg & "}" & Chr$(10)
'        ' send it
'        xPLSys.SendxPLRaw (strMsg)
'        ' display it
'        Call xPL_Display(0, Chr$(2) & strMsg & Chr$(3))
'        GoTo lookfornextmsg
'    End If
    
    If Right$(xPLCOMCmd, 1) <> vbCr Then GoTo lookformoredata
'    Debug.Print Now & " - " & xPLCOMCmd
    
    ' process input @@@
    If Left$(xPLCOMCmd, 2) <> "#R" Then GoTo skipthis
    IsTemp = False
    IsAlert = ""
    If Mid$(xPLCOMCmd, 3, 1) = "A" Then
        ' all
        Zone = LCase(Probes(Val(Mid$(xPLCOMCmd, 4, 1))).ZoneName)
        Probe = "all"
        Status = Mid$(xPLCOMCmd, 6, 6)
    Else
        ' single
        Zone = LCase(Probes(Val(Mid$(xPLCOMCmd, 3, 1))).ZoneName)
        Probe = LCase(Probes(Val(Mid$(xPLCOMCmd, 3, 1))).ProbeNames(Val(Mid$(xPLCOMCmd, 4, 1))))
        Status = LCase(UCase(Mid$(xPLCOMCmd, 6)))
        If Right$(Status, 1) = vbCr Then Status = Left$(Status, Len(Status) - 1)
        Select Case LCase(Status)
        Case "y", "yes", "n", "no"
        Case Else ' temp
            IsTemp = True
            chkAlert = Val(Status)
            If UCase(xPLSys.Configs("CORF")) = "F" Then
                ' F = 9/5 × (C) + 32
                chkAlert = ((9 / 5) * chkAlert) + 32
                chkAlert = Int(chkAlert * 10) / 10
                Status = chkAlert & " f"
            End If
            Select Case Val(Mid$(xPLCOMCmd, 4, 1))
            Case 5
                If chkAlert >= Probes(Val(Mid$(xPLCOMCmd, 3, 1))).HiAlert(1) Then IsAlert = "HIGH"
                If chkAlert <= Probes(Val(Mid$(xPLCOMCmd, 3, 1))).LoAlert(1) Then IsAlert = "LOW"
            Case 6
                If chkAlert >= Probes(Val(Mid$(xPLCOMCmd, 3, 1))).HiAlert(2) Then IsAlert = "HIGH"
                If chkAlert <= Probes(Val(Mid$(xPLCOMCmd, 3, 1))).LoAlert(2) Then IsAlert = "LOW"
            End Select
        End Select
    End If
    
    If IsTemp = False Then
        ' status
        Call xPLSys.SendXplMsg("xpl-stat", "*", "probe.basic", "zone=" & Zone & Chr(10) & "probe=" & Probe & Chr(10) & "status=" & Status & Chr(10))
    Else
        ' temp
        If IsAlert = "" Then
            Call xPLSys.SendXplMsg("xpl-stat", "*", "probe.basic", "zone=" & Zone & Chr(10) & "probe=" & Probe & Chr(10) & "current=" & Status & Chr(10))
        Else
            Call xPLSys.SendXplMsg("xpl-stat", "*", "probe.basic", "zone=" & Zone & Chr(10) & "probe=" & Probe & Chr(10) & "current=" & Status & Chr(10) & "alert=" & IsAlert & Chr(10))
        End If
    End If
    
    
skipthis:
    xPLCOMCmd = "" ' this line clears buffer, remove if necessary
     
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

    Dim x, y As Integer
    Dim t As Long
    
    ' initialise
    InTray = True
    If InStr(1, Command() & " ", "/hide ", vbTextCompare) > 0 Then InTray = False
    xPL_Source = "AEC-PROBE" ' set vendor-device here @@@
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
    xPL_Title = "xPL Probe" ' application title @@@
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
 '   Call xPLSys.ConfigsAdd("STATUS", "RECONF", 1)
    Call xPLSys.ConfigsAdd("ZONES", "OPTION", 8)
    Call xPLSys.ConfigsAdd("PROBES", "OPTION", 8)
    Call xPLSys.ConfigsAdd("HIALERT", "OPTION", 8)
    Call xPLSys.ConfigsAdd("LOALERT", "OPTION", 8)
    Call xPLSys.ConfigsAdd("AUTO", "OPTION", 16)
    Call xPLSys.ConfigsAdd("CORF", "OPTION", 1)
    ' some app's may only need comport, as rest may be known fixed settings
'    Call xPLSys.ConfigsAdd("LATITUDE","OPTION")
'    etc

    ' add default extra config values if possible @@@
    xPLSys.Configs("COMPORT") = "1"
  '  xPLSys.Configs("STATUS") = "30"
    For x = 1 To 8
        xPLSys.Configs("ZONE", x) = Trim(x)
        Probes(x).ZoneName = Trim(x)
        xPLSys.Configs("PROBES", x) = "1,2,3,4,5,6"
        For y = 1 To 6
            Probes(x).ProbeNames(y) = Trim(y)
        Next y
        xPLSys.Configs("HIALERT", x) = "250,250"
        Probes(x).HiAlert(1) = 250
        Probes(x).HiAlert(2) = 250
        xPLSys.Configs("LOALERT", x) = "-250,-250"
        Probes(x).LoAlert(1) = -250
        Probes(x).LoAlert(2) = -250
    Next x
    For x = 1 To 16
        xPLSys.Configs("AUTO", x) = ""
        ProbeAutos(x).Counter = 10
        ProbeAutos(x).Interval = 0
    Next x
    xPLSys.Configs("CORF") = "C"
'    etc

    ' add default filters @@@
    Call xPLSys.FiltersAdd("xpl-cmnd.aec.probe.*.probe.basic")
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
    ReDim ProbeQueue(0)
    tmrSendProbe.Enabled = True
    tmrAutoProbe.Enabled = True
    
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

Public Sub PushProbe(What As String)
    
    While ProbeQueue(0) = "lock"
        DoEvents
    Wend
    ProbeQueue(0) = "lock"
    ReDim Preserve ProbeQueue(UBound(ProbeQueue) + 1)
    ProbeQueue(UBound(ProbeQueue)) = What
    ProbeQueue(0) = ""
    If ResponseWait = False Then
        tmrSendProbe.Enabled = False
        Call tmrSendProbe_Timer
        tmrSendProbe.Interval = 1000
        tmrSendProbe.Enabled = True
    End If
       
End Sub

Public Function PopProbe() As String
    
    Dim x As Integer
    
    PopProbe = ""
    While ProbeQueue(0) = "lock"
        DoEvents
    Wend
    If UBound(ProbeQueue) = 0 Then Exit Function
    ProbeQueue(0) = "lock"
    PopProbe = ProbeQueue(1)
    For x = 2 To UBound(ProbeQueue)
        ProbeQueue(x - 1) = ProbeQueue(x)
    Next x
    ReDim Preserve ProbeQueue(UBound(ProbeQueue) - 1)
    ProbeQueue(0) = ""

End Function
