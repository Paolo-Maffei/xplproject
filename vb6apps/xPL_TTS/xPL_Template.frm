VERSION 5.00
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xPL.ocx"
Begin VB.Form xPL_Template 
   Caption         =   "xPL Template"
   ClientHeight    =   6540
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4005
   Icon            =   "xPL_Template.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   6540
   ScaleWidth      =   4005
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin xPL.xPLCtl xPLSys 
      Left            =   720
      Top             =   240
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
      Height          =   1335
      Index           =   1
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   1
      Top             =   5040
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
      Height          =   4335
      Index           =   0
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   600
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
      Visible         =   0   'False
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
'* xPL TTS
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
Private Sub xPLSys_Received(Msg As xPL.xPLMsg)
    
    Dim xPL_Text As String
    Dim xPL_Volume As Integer
    Dim msgVolume As String
    Dim xPL_Speed As Integer
    Dim msgSpeed As String
    Dim xPL_Voice As String
    Dim msgVoice As String
    Dim xPL_Soundcard As String
    Dim msgSoundcard As String
    Dim x(2) As Integer
    Dim s(2) As Integer
    
    ' check
    If xPL_Ready = False Then Exit Sub
    
    ' process message here @@@
    
    ' get speech
    xPL_Text = xPL_GetParam(Msg, "SPEECH", True)
    If xPL_Text = "" Then Exit Sub
    
    ' get default parameters
    xPL_Volume = Int(xPLSys.Configs("VOLUME"))
    If xPL_Volume < 0 Or xPL_Volume > 100 Then xPL_Volume = 100
    xPL_Speed = Int(xPLSys.Configs("SPEED"))
    If xPL_Speed < -10 Or xPL_Speed > 10 Then xPL_Speed = 0
    xPL_Voice = UCase(xPLSys.Configs("VOICE"))
    
    ' get message parameters
    msgVolume = xPL_GetParam(Msg, "VOLUME", True)
    msgSpeed = xPL_GetParam(Msg, "SPEED", True)
    msgVoice = UCase(xPL_GetParam(Msg, "VOICE", True))
    msgSoundcard = xPL_GetParam(Msg, "SOUNDCARD", True)
    
    ' check parameters
    If msgVolume <> "" And Val(msgVolume) >= 0 And Val(msgVolume) <= 100 Then xPL_Volume = Val(msgVolume)
    If msgSpeed <> "" And Val(msgSpeed) >= -10 And Val(msgSpeed) <= 10 Then xPL_Speed = Val(msgSpeed)
    If msgVoice <> "" Then xPL_Voice = msgVoice
    For x(0) = 1 To xPL_VoiceCount
        If xPL_Voice = xPL_Voices(x(0)) Then
            x(1) = x(0)
            x(0) = xPL_VoiceCount + 1
        End If
        If x(2) = 0 Then
            If InStr(1, xPL_Voices(x(0)), xPL_Voice, vbBinaryCompare) > 0 Then x(2) = x(0)
        End If
    Next x(0)
    x(0) = 0
    If x(2) > 0 Then x(0) = x(2)
    If x(1) > 0 Then x(0) = x(1)
    If x(0) = 0 Then
        x(1) = 0
        For x(0) = 1 To xPL_VoiceCount
            If xPL_Voice = xPL_Voices(x(0)) Then
                x(1) = x(0)
                x(0) = xPL_VoiceCount + 1
            End If
        Next x(0)
        x(0) = x(1)
        If x(0) = 0 Then x(0) = 1
    End If
    If msgSoundcard <> "" Then xPL_Soundcard = msgSoundcard
    For s(0) = 1 To xPL_AudioCount
        If xPL_Soundcard = xPL_Audios(s(0)) Then
            s(1) = s(0)
            s(0) = xPL_AudioCount + 1
        End If
        If s(2) = 0 Then
            If InStr(1, xPL_Audios(s(0)), xPL_Soundcard, vbBinaryCompare) > 0 Then s(2) = s(0)
        End If
    Next s(0)
    s(0) = 0
    If s(2) > 0 Then s(0) = s(2)
    If s(1) > 0 Then s(0) = s(1)
    If s(0) = 0 Then
        s(1) = 0
        For s(0) = 1 To xPL_AudioCount
            If xPL_Soundcard = xPL_Audios(s(0)) Then
                s(1) = s(0)
                s(0) = xPL_AudioCount + 1
            End If
        Next s(0)
        s(0) = s(1)
        If s(0) = 0 Then s(0) = 1
    End If
    
    ' process tts message
    Call xPL_TTS(xPL_Text, xPL_Volume, xPL_Speed, x(0) - 1, s(0) - 1)
    
End Sub

' speech
Private Sub xPL_TTS(strMsg As String, intVolume As Integer, intSpeed As Integer, intVoice As Integer, intAudio As Integer)

    Dim m_speakFlags As SpeechVoiceSpeakFlags
    
    ' speak
    xPL_Speech.Volume = intVolume
    xPL_Speech.Rate = intSpeed
    Set xPL_Speech.AudioOutput = xPL_Speech.GetAudioOutputs().Item(intAudio)
    Set xPL_Speech.Voice = xPL_Speech.GetVoices().Item(intVoice)
    m_speakFlags = SVSFlagsAsync 'Or SVSFPurgeBeforeSpeak 'Or SVSFIsXML
    On Error Resume Next
    xPL_Speech.Speak strMsg, m_speakFlags
    On Error GoTo 0
    Call xPL_Display(1, strMsg)
    
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

    Dim Token As ISpeechObjectToken
    Dim x As Integer
    
    ' initialise
    InTray = True
    If InStr(1, Command() & " ", "/hide ", vbTextCompare) > 0 Then InTray = False
    xPL_Source = "TONYT-TTS" ' set vendor-device here @@@
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
    xPL_Title = "xPL TTS" ' application title @@@
    Me.Caption = xPL_Title + " " + xPL_Source
    Me.lblxPL(0) = "xPL RX" ' receive box label @@@
'    Me.lblxPL(1) = "xPL TX" ' receive box label @@@
    Me.mPopRestore.Caption = xPL_Source
    
    ' pre initialise
    If xPLSys.Initialise(xPL_Source, xPL_WaitForConfig, 5) = False Then
        ' failed to pre-initialise
        Call MsgBox("Sorry, unable to initialise xPL sub-system.", vbCritical + vbOKOnly, "xPL Init Failed")
        Unload Me
        Exit Sub
    End If
    
    ' add extra configs (set config/reconf/option as needed) @@@
'    Call xPLSys.ConfigsAdd("TEST", "CONFIG", 1)
'    etc

    ' add default extra config values if possible @@@
    Call xPLSys.ConfigsAdd("VOLUME", "OPTION", 1)
    xPLSys.Configs("VOLUME") = "100"
    Call xPLSys.ConfigsAdd("SPEED", "OPTION", 1)
    xPLSys.Configs("SPEED") = "0"
    Call xPLSys.ConfigsAdd("VOICE", "OPTION", 1)
    xPLSys.Configs("VOICE") = ""
    Call xPLSys.ConfigsAdd("SOUNDCARD", "OPTION", 1)
    xPLSys.Configs("SOUNDCARD") = ""
'    etc

    ' add default filters @@@
    Call xPLSys.FiltersAdd("xpl-cmnd.*.*.*.tts.*")
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
    Set xPL_Speech = New SpVoice
    xPL_VoiceCount = 0
    For Each Token In xPL_Speech.GetVoices
        xPL_VoiceCount = xPL_VoiceCount + 1
        xPL_Voices(xPL_VoiceCount) = UCase(Token.GetDescription())
    Next
    xPLSys.Configs("VOICE") = xPL_Voices(1)
    xPL_AudioCount = 0
    For Each Token In xPL_Speech.GetAudioOutputs
        xPL_AudioCount = xPL_AudioCount + 1
        xPL_Audios(xPL_AudioCount) = Token.GetDescription
    Next
    If xPL_AudioCount > 0 Then
        xPLSys.Configs("SOUNDCARD") = xPL_Audios(1)
    End If
    
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
    
    ' tidy up stuff here @@@
    Set xPL_Speech = Nothing
    
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

