VERSION 5.00
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "MSCOMM32.OCX"
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xPL.ocx"
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
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
   Begin InetCtlsObjects.Inet xPLInetLookup 
      Left            =   4680
      Top             =   120
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      Protocol        =   4
      URL             =   "http://"
   End
   Begin InetCtlsObjects.Inet xPLInetAdd 
      Left            =   6720
      Top             =   120
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      Protocol        =   4
      URL             =   "http://"
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
    ' etc
    
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
    Static BarCodeCom As String
    Dim BarCodeMsg As String
    Dim BarCodeProduct As String
    Dim strMsg As String
    Dim Msg As xPL.xPLMsg
    Dim l As Long
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
    If Right$(xPLCOMCmd, 1) = Chr$(13) Then
        xPLCOMCmd = Left$(xPLCOMCmd, Len(xPLCOMCmd) - 1)
        For x = 0 To 15
            If UCase(xPLCOMCmd) = UCase(xPLSys.Configs("BARCODES", x)) Then
                BarCodeCom = xPLSys.Configs("COMMANDS", x)
                Call xPL_Display(0, "Command=" + BarCodeCom)
                xPLCOMCmd = ""
                x = 16
            End If
        Next x
        If xPLCOMCmd <> "" Then
            Call xPL_Display(0, "Barcode=" + xPLCOMCmd)
            If xPLSys.Configs("SERVER", 1) <> "" Then
                BarCodeProduct = GetProduct(xPLCOMCmd)
            Else
                BarCodeProduct = ""
            End If
            Call xPL_Display(0, "Barcode=" + xPLCOMCmd & vbCrLf & "Product=" & BarCodeProduct)
            BarCodeMsg = "barcode=" + xPLCOMCmd + Chr$(10)
            If BarCodeProduct <> "" Then BarCodeMsg = BarCodeMsg + "product=" + BarCodeProduct + Chr$(10)
            If BarCodeCom <> "" Then BarCodeMsg = BarCodeMsg + "command=" + BarCodeCom + Chr$(10)
            Call xPLSys.SendXplMsg("xpl-trig", "*", "barcode.basic", BarCodeMsg)
        End If
        xPLCOMCmd = ""
    End If

End Sub

' get product
Function GetProduct(Barcode As String) As String
    
    Dim strText As String
    Dim strAdd As String
    Dim strUser As String
    Dim strPwd As String
    Dim strResponse As String
    Dim x As Integer
    Dim y As Integer
    
    ' lookup
    xPLInetLookup.RequestTimeout = 10
    On Error GoTo lookupfailed
    xPLInetLookup.Execute xPLSys.Configs("SERVER") + "/?" & EncodeURL(Barcode)
    On Error GoTo 0
    While xPLInetLookup.StillExecuting
        x = DoEvents
    Wend
    If xPLInetLookup.ResponseCode <> 0 Then
        GetProduct = ""
        Exit Function
    End If
    strText = xPLInetLookup.GetChunk(1000)
    x = InStr(1, strText, "<body>", vbBinaryCompare)
    strText = Mid$(strText, x + 8)
    y = InStr(1, strText, "</body>", vbBinaryCompare)
    strText = Left$(strText, y - 3)
    If strText = "FAILED" Or Len(strText) > 128 Then
        ' get & update
        If UCase(xPLSys.Configs("INTERACTIVE")) = "N" Or xPLSys.Configs("USERNAME") = "" Or xPLSys.Configs("PASSWORD") = "" Or Len(strText) > 128 Then
            ' unknown
            strText = ""
        Else
            strText = InputBox("Product:", "New Product", "")
            If strText <> "" Then
                ' add product
                strAdd = strText
                strUser = xPLSys.Configs("USERNAME")
                strPwd = xPLSys.Configs("PASSWORD")
                xPLInetAdd.RequestTimeout = 15
                On Error GoTo lookupfailed
                xPLInetAdd.Execute xPLSys.Configs("SERVER") & "/?user=" & EncodeURL(xPLSys.Configs("USERNAME")) & "&pwd=" & EncodeURL(xPLSys.Configs("PASSWORD")) & "&barcode=" & EncodeURL(Barcode) & "&desc=" & EncodeURL(strAdd)
                On Error GoTo 0
                While xPLInetAdd.StillExecuting
                    x = DoEvents
                Wend
                If xPLInetAdd.ResponseCode <> 0 Then
                    Call MsgBox("Sorry, unable to Add to database (" & xPLSys.Configs("SERVER") & ")!", vbOKOnly + vbCritical, "Failed")
                Else
                    strResponse = xPLInetAdd.GetChunk(1000)
                    If InStr(1, strResponse, "UNAUTHORISED", vbBinaryCompare) > 0 Then
                        Call MsgBox("Sorry, unauthorised to add to database (" & xPLSys.Configs("SERVER") & ")!", vbOKOnly + vbCritical, "Failed")
                    End If
                    If InStr(1, strResponse, "FAILED", vbBinaryCompare) > 0 Then
                        Call MsgBox("Sorry, failed to add to database (" & xPLSys.Configs("SERVER") & ")!", vbOKOnly + vbCritical, "Failed")
                    End If
                End If
            End If
        End If
    End If
    GetProduct = strText
    Exit Function

lookupfailed:
    On Error GoTo 0
    GetProduct = ""
    
End Function

' display message received - remove if display not required @@@
Private Sub xPLSys_xPLRX(Msg As String)
    
    ' display message
  '  Call xPL_Display(0, Msg)
    
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
    xPL_Source = "TONYT-BARCODE" ' set vendor-device here @@@
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
    xPL_Title = "xPL Barcode Reader" ' application title @@@
    Me.Caption = xPL_Title + " " + xPL_Source
    Me.lblxPL(0) = "Barcode Scanner" ' receive box label @@@
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
    Call xPLSys.ConfigsAdd("COMMANDS", "OPTION", 16)
    Call xPLSys.ConfigsAdd("BARCODES", "OPTION", 16)
    Call xPLSys.ConfigsAdd("SERVER", "OPTION", 1)
    Call xPLSys.ConfigsAdd("USERNAME", "OPTION", 1)
    Call xPLSys.ConfigsAdd("PASSWORD", "OPTION", 1)
    Call xPLSys.ConfigsAdd("INTERACTIVE", "OPTION", 1)
    Call xPLSys.ConfigsAdd("COMPORT", "RECONF", 1)
    Call xPLSys.ConfigsAdd("BAUD", "OPTION", 1)
    Call xPLSys.ConfigsAdd("DATABITS", "OPTION", 1)
    Call xPLSys.ConfigsAdd("PARITY", "OPTION", 1)
    Call xPLSys.ConfigsAdd("STOPBITS", "OPTION", 1)
    Call xPLSys.ConfigsAdd("FLOWCONTROL", "OPTION", 1)
    Call xPLSys.ConfigsAdd("RTSENABLE", "OPTION", 1)
    Call xPLSys.ConfigsAdd("DTRENABLE", "OPTION", 1)
    ' some app's may only need comport, as rest may be known fixed settings
'    Call xPLSys.ConfigsAdd("LATITUDE","OPTION")
'    etc

    ' add default extra config values if possible @@@
    xPLSys.Configs("SERVER") = "barcodes.xplhal.com"
    xPLSys.Configs("INTERACTIVE") = "N"
    xPLSys.Configs("COMPORT") = "1"
    xPLSys.Configs("BAUD") = "9600"
    xPLSys.Configs("DATABITS") = "7"
    xPLSys.Configs("PARITY") = "E"
    xPLSys.Configs("STOPBITS") = "1"
    xPLSys.Configs("FLOWCONTROL") = "N"
    xPLSys.Configs("RTSENABLE") = "N"
    xPLSys.Configs("DTRENABLE") = "N"
'    etc

    ' add default filters @@@
    Call xPLSys.FiltersAdd("*.*.*.*.*.*")
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
    
    ' initialise xPL
    If xPLSys.Start = False Then
        ' failed to initialise
        Call MsgBox("Sorry, unable to start xPL sub-system.", vbCritical + vbOKOnly, "xPL Start Failed")
        Unload Me
        Exit Sub
    End If
    
    ' initialise other stuff here after start @@@
    Call SetupURLs
    
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

