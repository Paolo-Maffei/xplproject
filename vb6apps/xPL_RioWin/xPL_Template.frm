VERSION 5.00
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xPL.ocx"
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Object = "{6BF52A50-394A-11D3-B153-00C04F79FAA6}#1.0#0"; "wmp.dll"
Begin VB.Form xPL_Template 
   Caption         =   "xPL Template"
   ClientHeight    =   5100
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   7950
   Icon            =   "xPL_Template.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   5100
   ScaleWidth      =   7950
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer tmrNextTrack 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   5400
      Top             =   4560
   End
   Begin InetCtlsObjects.Inet RioQuery 
      Left            =   3720
      Top             =   3480
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      AccessType      =   1
      Protocol        =   4
      URL             =   "http://"
   End
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
   Begin WMPLibCtl.WindowsMediaPlayer RioPlay 
      Height          =   615
      Left            =   3240
      TabIndex        =   4
      Top             =   4320
      Visible         =   0   'False
      Width           =   1095
      URL             =   ""
      rate            =   1
      balance         =   0
      currentPosition =   0
      defaultFrame    =   ""
      playCount       =   1
      autoStart       =   0   'False
      currentMarker   =   0
      invokeURLs      =   0   'False
      baseURL         =   ""
      volume          =   50
      mute            =   0   'False
      uiMode          =   "full"
      stretchToFit    =   0   'False
      windowlessVideo =   0   'False
      enabled         =   -1  'True
      enableContextMenu=   -1  'True
      fullScreen      =   0   'False
      SAMIStyle       =   ""
      SAMILang        =   ""
      SAMIFilename    =   ""
      captioningID    =   ""
      enableErrorDialogs=   0   'False
      _cx             =   1931
      _cy             =   1085
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
'* xPL RioWin
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

Private Sub RioPlay_Manual()

    Dim w As Long
    
    ' unflag paused
    Paused = False
    
    ' check for playing
    If PlayNext = 0 Then
        RioPlay.Controls.stop
        Playing = 0
        Call CollectTags
        Call SendTags(True, False)
        Call xPLSys.SendXplMsg("xpl-stat", "*", "audio.rio", "status=stopped")
        Exit Sub
    End If
    
    ' play next
    Playing = PlayNext
    If Random = True Then
        PlayNext = Int(RioListCount * Rnd) + 1
    Else
        PlayNext = PlayNext + 1
    End If
    If PlayNext > RioListCount Then PlayNext = 0
    
    ' get playing tags
    Call CollectTags
    
    ' play
    RioPlay.URL = "http://" & xPLSys.Configs("SERVER") & ":" & xPLSys.Configs("PORT") & "/content/" & RioList(Playing)
    RioPlay.Controls.play
        
    ' flag
    Call SendTags(True, True)
    
End Sub

' send messages
Private Sub SendTags(SendPlaying As Boolean, SendPlayNext As Boolean)
    
    Dim xPLMsg As String
    
    ' send next
    If SendPlayNext = True Then
        xPLMsg = "Status=NEXT" & Chr$(10) & "Type=" & PlayNextTags.Codec & Chr$(10) & "Artist=" & PlayNextTags.Artist & Chr$(10) & "Album=" & PlayNextTags.Album & Chr$(10) & "Track=" & PlayNextTags.Track
        Call xPLSys.SendXplMsg("xpl-stat", "*", "audio.rio", xPLMsg)
    End If
    
    ' send playing
    If SendPlaying = True Then
        xPLMsg = "Status=PLAYING" & Chr$(10) & "Type=" & PlayingTags.Codec & Chr$(10) & "Artist=" & PlayingTags.Artist & Chr$(10) & "Album=" & PlayingTags.Album & Chr$(10) & "Track=" & PlayingTags.Track
        Call xPLSys.SendXplMsg("xpl-stat", "*", "audio.rio", xPLMsg)
    End If
        
End Sub

' collect tags
Private Sub CollectTags()

    ' playing
    PlayingTags.Track = ""
    PlayingTags.Album = ""
    PlayingTags.Codec = ""
    PlayingTags.Artist = ""
    If Playing <> 0 Then PlayingTags = GetTags(RioList(Playing))
    
    ' next
    PlayNextTags.Track = ""
    PlayNextTags.Album = ""
    PlayNextTags.Codec = ""
    PlayNextTags.Artist = ""
    If PlayNext <> 0 Then PlayNextTags = GetTags(RioList(PlayNext))

End Sub

' get tags
Private Function GetTags(WhichTag As String) As TagsType
    
    Dim strRio() As Byte
    Dim strRioLen As Long
    Dim wait As Long
    Dim Temp As String
    Dim x As Long
    Dim y As Integer
    Dim z As Integer
    
    ' set tags
    RioQuery.RequestTimeout = 10
    RioQuery.Execute "http://" & xPLSys.Configs("SERVER") & ":" & xPLSys.Configs("PORT") & "/tags/" & WhichTag
    While RioQuery.StillExecuting = True
        wait = DoEvents
    Wend
    If RioQuery.ResponseCode <> 0 Then Exit Function
    strRioLen = RioQuery.GetHeader("Content-length")
    strRio = RioQuery.GetChunk(strRioLen, icByteArray)
    x = 1
    y = strRio(x)
    For z = x + 1 To x + y
        GetTags.Artist = GetTags.Artist + Chr$(strRio(z))
    Next z
    x = z + 1
    y = strRio(x)
    For z = x + 1 To x + y
        Temp = Temp + Chr$(strRio(z))
    Next z
    x = z + 1
    y = strRio(x)
    For z = x + 1 To x + y
        GetTags.Codec = GetTags.Codec + Chr$(strRio(z))
    Next z
    x = z + 1
    y = strRio(x)
    For z = x + 1 To x + y
        Temp = Temp + Chr$(strRio(z))
    Next z
    x = z + 1
    y = strRio(x)
    For z = x + 1 To x + y
        Temp = Temp + Chr$(strRio(z))
    Next z
    x = z + 1
    y = strRio(x)
    For z = x + 1 To x + y
        Temp = Temp + Chr$(strRio(z))
    Next z
    x = z + 1
    y = strRio(x)
    For z = x + 1 To x + y
        Temp = Temp + Chr$(strRio(z))
    Next z
    x = z + 1
    y = strRio(x)
    For z = x + 1 To x + y
        Temp = Temp + Chr$(strRio(z))
    Next z
    x = z + 1
    y = strRio(x)
    For z = x + 1 To x + y
        GetTags.Track = GetTags.Track + Chr$(strRio(z))
    Next z
    x = z + 1
    y = strRio(x)
    For z = x + 1 To x + y
        GetTags.Album = GetTags.Album + Chr$(strRio(z))
    Next z
    If Len(GetTags.Album) > 128 Then GetTags.Album = Left$(GetTags.Album, 128)
    If Len(GetTags.Artist) > 128 Then GetTags.Artist = Left$(GetTags.Artist, 128)
    If Len(GetTags.Codec) > 128 Then GetTags.Codec = Left$(GetTags.Codec, 128)
    If Len(GetTags.Track) > 128 Then GetTags.Track = Left$(GetTags.Track, 128)
    
End Function

Private Sub RioPlay_StatusChange()

    ' next track
    If RioPlay.Status = "Stopped" Then Me.tmrNextTrack.Enabled = True
    
End Sub

Private Sub tmrNextTrack_Timer()
    
    ' run it
    Me.tmrNextTrack.Enabled = False
    Call RioPlay_Manual
    
End Sub

' process message
Private Sub xPLSys_Received(Msg As xPLMsg)

    Dim Value(1) As String
    Dim Playlist As String
    Dim RioX As Integer
    Dim RioY As Integer
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    
    ' check
    If xPL_Ready = False Then Exit Sub
    
    ' process message here @@@
    ' etc
    RioY = Msg.NamePairs - 1
    For RioX = 0 To RioY
        Value(0) = Msg.Values(RioX)
        Value(1) = ""
        z = InStr(1, Value(0), " ", vbBinaryCompare)
        If z > 0 Then
            Value(1) = Mid$(Value(0), z + 1)
            Value(0) = Left$(Value(0), z - 1)
        End If
        Select Case UCase(Value(0))
        Case "PLAY"
            Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "command=play")
            If Playing = 0 Then
                If RioListCount > 0 Then
                    Playing = 0
                    PlayNext = 1
                    Call RioPlay_Manual
                End If
            Else
                If Paused = True Then
                    RioPlay.Controls.play
                    Paused = False
                End If
            End If
        Case "STOP"
            Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "command=stop")
            Playing = 0
            PlayNext = 0
            RioPlay.Controls.stop
            Call RioPlay_Manual
            Call xPLSys.SendXplMsg("xpl-stat", "*", "audio.rio", "status=stopped")
        Case "VOLUME"
            x = 0
            If Left$(Value(1), 1) = "+" Or Left$(Value(1), 1) = ">" Then x = 1
            If Left$(Value(1), 1) = "-" Or Left$(Value(1), 1) = "<" Then x = -1
            If x = 0 Then
                y = Val(Value(1))
            Else
                y = Val(Mid$(Value(1), 2))
            End If
            If y < 0 Then y = 0
            If y > 100 Then y = 100
            If x = 0 Then
                RioPlay.settings.Volume = y
            Else
                RioPlay.settings.Volume = RioPlay.settings.Volume + (y * x)
            End If
            Volume = RioPlay.settings.Volume
        Case "SKIP"
            Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "command=skip")
            Call RioPlay_Manual
        Case "BACK"
            Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "command=back")
            If Random <> True And Playing > 0 Then
                PlayNext = Playing - 1
                Playing = Playing - 2
                Call RioPlay_Manual
            End If
        Case "RANDOM"
            Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "command=random")
            Random = Not Random
        Case "CLEAR"
            Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "command=clear")
            Playing = 0
            PlayNext = 0
            RioListCount = 0
            Call RioPlay_Manual
        Case "POWER"
            Select Case UCase(Value(1))
            Case "OFF"
                Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "extended=power off")
                Playing = 0
                PlayNext = 0
                Call RioPlay_Manual
                Call xPLSys.SendXplMsg("xpl-stat", "*", "audio.rio", "status=power off")
            Case "ON"
                Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "extended=power on")
                RioPlay.settings.Volume = Val(xPLSys.Configs("VOLUME"))
                Volume = RioPlay.settings.Volume
                Call xPLSys.SendXplMsg("xpl-stat", "*", "audio.rio", "status=power on")
            End Select
        Case "LIGHT"
            ' not supported
        Case "SHOUTCAST"
            Playing = 0
            PlayNext = 0
            RioListCount = 0
            Call RioPlay_Manual
            Call xPLSys.SendXplMsg("xpl-stat", "*", "audio.rio", "status=stopped")
            For x = 1 To StreamCount
                If LCase(Value(1)) = LCase(Streams(x)) Then
                    RioPlay.URL = StreamUrls(x)
                    RioPlay.Controls.play
                    x = StreamCount
                End If
            Next x
        Case "ALBUM"
            Call AddTracks("source", Value(1))
        Case "ARTIST"
            Call AddTracks("artist", Value(1))
        Case "TRACK"
            Call AddTracks("title", Value(1))
        Case "GENRE"
            Call AddTracks("genre", Value(1))
        Case "PLAYLIST"
            Playlist = GetPlaylist(Value(1))
            If Playlist <> "" Then Call AddTracks("playlist", Playlist)
        Case "ANNOUNCE"
            ' not implemented
        Case "ANNOUNCEVOLUME"
            ' not implemented
        Case "MUTE"
            Select Case UCase(Value(1))
            Case "OFF"
                Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "extended=mute off")
                If Volume <> 0 Then
                    RioPlay.settings.Volume = Volume
                End If
            Case "ON"
                Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "extended=mute on")
                If RioPlay.settings.Volume <> 0 Then
                    RioPlay.settings.Volume = Volume
                    RioPlay.settings.Volume = 0
                End If
            End Select
        Case "PAUSE"
            Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "extended=pause")
            RioPlay.Controls.pause
            Paused = True
            Call xPLSys.SendXplMsg("xpl-stat", "*", "audio.rio", "status=paused")
        End Select
    Next RioX
     
End Sub



'    sprintf(xplstat,"Status=PLAYING\nType=SHOUTCAST\nStation=%s",StreamTitle);
'    Globals::Xpl.sendxpl("xpl-stat","*","audio.rio",xplstat);


Private Sub AddTracks(Source As String, Value As String)

    Dim strRio() As String
    Dim strRioLen As Long
    Dim wait As Long
    Dim x As Long
    Dim y As Integer
    
    ' get data
    RioQuery.RequestTimeout = 10
    If Source <> "playlist" Then
        RioQuery.Execute "http://" & xPLSys.Configs("SERVER") & ":" & xPLSys.Configs("PORT") & "/results?_extended=1&" & Source & "=" & Value
    Else
        RioQuery.Execute "http://" & xPLSys.Configs("SERVER") & ":" & xPLSys.Configs("PORT") & "/content/" & Value & "?_extended=1"
    End If
    While RioQuery.StillExecuting = True
        wait = DoEvents
    Wend
    If RioQuery.ResponseCode <> 0 Then Exit Sub
    strRioLen = RioQuery.GetHeader("Content-length")
    strRio = Split(RioQuery.GetChunk(strRioLen, icString), Chr$(10), , vbBinaryCompare)
    If UBound(strRio) = -1 Then Exit Sub
    ReDim Preserve RioList(RioListCount + UBound(strRio))
    For x = 1 To UBound(strRio)
        RioListCount = RioListCount + 1
        y = InStr(1, strRio(x - 1), "=T", vbBinaryCompare)
        RioList(RioListCount) = Left$(strRio(x - 1), y - 1)
    Next x

End Sub

' get playlists
Private Function GetPlaylist(Playlist As String) As String

    Dim strRio() As String
    Dim strRioLen As Long
    Dim wait As Long
    Dim x As Long
    Dim y As Integer
    
    ' get data
    GetPlaylist = ""
    RioQuery.RequestTimeout = 10
    RioQuery.Execute "http://" & xPLSys.Configs("SERVER") & ":" & xPLSys.Configs("PORT") & "/content/100?_extended=1"
    While RioQuery.StillExecuting = True
        wait = DoEvents
    Wend
    If RioQuery.ResponseCode <> 0 Then Exit Function
    strRioLen = RioQuery.GetHeader("Content-length")
    strRio = Split(RioQuery.GetChunk(strRioLen, icString), Chr$(10), , vbBinaryCompare)
    If UBound(strRio) = -1 Then Exit Function
    For x = 1 To UBound(strRio) - 1
        y = InStr(1, strRio(x), "=P", vbBinaryCompare)
        GetPlaylist = Left$(strRio(x), y - 1)
        strRio(x) = Mid$(strRio(x), y + 2)
        While Right$(strRio(x), 1) <> "("
            strRio(x) = Left$(strRio(x), Len(strRio(x)) - 1)
        Wend
        strRio(x) = Left$(strRio(x), Len(strRio(x)) - 2)
        If LCase(strRio(x)) = LCase(Playlist) Then Exit Function
    Next x
    GetPlaylist = ""
    
End Function

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
    RioPlay.settings.Volume = Val(xPLSys.Configs("VOLUME"))
    Volume = RioPlay.settings.Volume
    Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "extended=power on")
    Call xPLSys.SendXplMsg("xpl-stat", "*", "audio.rio", "status=power on")

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
    
    Dim strInput As String
    Dim strTitle As String
    Dim f As Integer
    Dim x As Integer
    
    ' initialise
    InTray = True
    If InStr(1, Command() & " ", "/hide ", vbTextCompare) > 0 Then InTray = False
    xPL_Source = "TONYT-RIOWIN" ' set vendor-device here @@@
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
    xPL_Title = "RioPlay xPL" ' application title @@@
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
'    Call xPLSys.ConfigsAdd("LATITUDE", "CONFIG",1)
    Call xPLSys.ConfigsAdd("SERVER", "RECONF", 1)
    Call xPLSys.ConfigsAdd("PORT", "RECONF", 1)
    Call xPLSys.ConfigsAdd("ZONE", "OPTION", 1)
    Call xPLSys.ConfigsAdd("OSD", "OPTION", 1)
    Call xPLSys.ConfigsAdd("TTS", "OPTION", 1)
    Call xPLSys.ConfigsAdd("VOLUME", "OPTION", 1)
'    etc

    ' add default extra config values if possible @@@
    ' xPLSys.Configs("LATITUDE") = "1.04532"
    xPLSys.Configs("SERVER") = "localhost"
    xPLSys.Configs("PORT") = "12078"
    xPLSys.Configs("VOLUME") = "50"
    Volume = RioPlay.settings.Volume
'    etc

    ' add default filters @@@
    Call xPLSys.FiltersAdd("*.*.*.*.audio.rio")
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
    RioPlay.settings.autoStart = False
    RioPlay.settings.enableErrorDialogs = False
    RioPlay.network.bufferingTime = 5
    RioPlay.settings.invokeURLs = True
    
    ' initialise xPL
    If xPLSys.Start = False Then
        ' failed to initialise
        Call MsgBox("Sorry, unable to start xPL sub-system.", vbCritical + vbOKOnly, "xPL Start Failed")
        Unload Me
        Exit Sub
    End If
    
    ' initialise other stuff here after start @@@
    If Dir(App.Path + "\streams.cfg") <> "" Then
        f = FreeFile
        Open App.Path + "\streams.cfg" For Input As #f
        ReDim Streams(StreamCount)
        ReDim StreamUrls(StreamCount)
        While Not EOF(f)
            Line Input #1, strInput
            If LCase(Left$(strInput, 7)) = "<title>" Then
                strTitle = Mid$(strInput, 8)
            Else
                If strTitle <> "" Then
                    StreamCount = StreamCount + 1
                    ReDim Preserve Streams(StreamCount)
                    ReDim Preserve StreamUrls(StreamCount)
                    Streams(StreamCount) = strTitle
                    StreamUrls(StreamCount) = strInput
                End If
            End If
        Wend
        Close #f
    End If

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
    On Error Resume Next
    RioPlay.Controls.stop
    RioPlay.Close
    On Error GoTo 0
    Call xPLSys.SendXplMsg("xpl-trig", "*", "audio.rio", "extended=power off")
    Call xPLSys.SendXplMsg("xpl-stat", "*", "audio.rio", "status=power off")
    
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


