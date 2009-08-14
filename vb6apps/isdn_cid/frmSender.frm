VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "mswinsck.ocx"
Begin VB.Form frmSender 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "xPL ISDN CID Sender"
   ClientHeight    =   660
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   3510
   Icon            =   "frmSender.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   660
   ScaleWidth      =   3510
   StartUpPosition =   3  'Windows Default
   Visible         =   0   'False
   Begin MSWinsockLib.Winsock udpSender 
      Left            =   60
      Top             =   45
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
      Protocol        =   1
   End
End
Attribute VB_Name = "frmSender"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'This Application And it 's source code are (c) 2003 Ian Lowe, Wintermute Consultancy.
'This program is free software; you can redistribute it and/or modify it under the terms
'of the GNU General Public License as published by the Free Software Foundation; either
'version 2 of the License, or (at your option) any later version.

'This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
'without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
'See the GNU General Public License for more details.

'ISDNCID Variables passed on the Command Line
Dim strTarget As String
Dim strNumber As String
Dim strName As String
Dim strDialled As String
Dim strCallTime As String
Dim strCallDate As String
Dim strMSN As String
Dim strCIPValue As String

'Call Setup or TearDown?
Dim boolCallStart As Boolean

'These parameters are only valid at call clearance.
Dim strReason As String
Dim strSavedFile As String
Dim strCallType As String
Dim strFAXPages As String


'2) The message type is numbered as follows:
'0 None
'1 Rejected
'2 Echoed
'3 Answered by answering machine
'4 Voice message
'5 BrokenFax
'6 Fax
'7 ReadVoice (Not will)
'8 ReadFax (Not will)
'9 Answered by another phone/application

Private Sub Send_Message()
    Dim strxplPacket As String
    strxplPacket = "xpl-trig" & Chr(10) & "{" & Chr(10) & "hop=1" & Chr(10)
    strxplPacket = strxplPacket & "source=WMUTE-SENDER.ISDNCID" & Chr(10)
    strxplPacket = strxplPacket & "target=*" & Chr(10) & "}" & Chr(10)
    strxplPacket = strxplPacket & "CID.ISDNCID" & Chr(10) & "{" & Chr(10)
    strxplPacket = strxplPacket & "CALLTYPE=Inbound" & Chr(10)
    strxplPacket = strxplPacket & "PHONE=" & Trim(strNumber) & Chr(10)
    strxplPacket = strxplPacket & "NAME=" & Trim(strName) & Chr(10)
    strxplPacket = strxplPacket & "CALLED=" & Trim(strDialled) & Chr(10)
    strxplPacket = strxplPacket & "TIME=" & Trim(strCallTime) & Chr(10)
    strxplPacket = strxplPacket & "DATE=" & Trim(strCallDate) & Chr(10)
    strxplPacket = strxplPacket & "ISDNMSN=" & Trim(strMSN) & Chr(10)
    If boolCallStart Then
        strxplPacket = strxplPacket & "STATUS=Call Start" & Chr(10)
        strxplPacket = strxplPacket & "SQLLOG=" & LogCall() & Chr(10)
        strxplPacket = strxplPacket & "}" & Chr(10)
    Else
        strxplPacket = strxplPacket & "STATUS=Call End" & Chr(10)
        Select Case Trim(strCallType)
            Case "6"
               strxplPacket = strxplPacket & "REASON=Fax" & Chr(10)
               strxplPacket = strxplPacket & "FAXPAGES=" & Trim(strFAXPages) & Chr(10)
               strxplPacket = strxplPacket & "SAVEFILE=" & Trim(strSavedFile) & Chr(10)
            Case "5"
               strxplPacket = strxplPacket & "REASON=Fax (Incomplete)" & Chr(10)
               strxplPacket = strxplPacket & "FAXPAGES=" & Trim(strFAXPages) & Chr(10)
               strxplPacket = strxplPacket & "SAVEFILE=" & Trim(strSavedFile) & Chr(10)
            Case "9"
               strxplPacket = strxplPacket & "REASON=Answered by Another Ext" & Chr(10)
               strxplPacket = strxplPacket & "RINGTIME=" & Trim(strFAXPages) & " Seconds" & Chr(10)
            Case "3"
               strxplPacket = strxplPacket & "REASON=Message Recorded" & Chr(10)
               strxplPacket = strxplPacket & "MESSAGE=" & Trim(strFAXPages) & " Seconds" & Chr(10)
               strxplPacket = strxplPacket & "SAVEFILE=" & Trim(strSavedFile) & Chr(10)
            Case "4"
               strxplPacket = strxplPacket & "REASON=Message Recorded" & Chr(10)
               strxplPacket = strxplPacket & "MESSAGE=" & Trim(strFAXPages) & " Seconds" & Chr(10)
               strxplPacket = strxplPacket & "SAVEFILE=" & Trim(strSavedFile) & Chr(10)
            Case Else
               strxplPacket = strxplPacket & "REASON=Unanswered Call" & Chr(10)
               strxplPacket = strxplPacket & "RINGTIME=" & Trim(strFAXPages) & " Seconds" & Chr(10)
        End Select
        strxplPacket = strxplPacket & "}" & Chr(10)
    End If
    On Error Resume Next    ' Trap known Win98 error
    udpSender.SendData strxplPacket
End Sub

Function LogCall() As String

Dim cid As ADODB.Connection
Dim rs As ADODB.Recordset
Dim sSQL As String

    Set cid = New ADODB.Connection '// Assigns an object reference
    cid.Open "DSN=Hypatia", "hypatia", "wintermute"
    
    'Chop Date into US Format
    sSQL = "'" & Mid(strCallDate, 4, 2) & "/" & Mid(strCallDate, 1, 2) & "/" & Mid(strCallDate, 7, 4)
    sSQL = sSQL & " " & strCallTime & "', '" & strNumber & "', " & strMSN
   
    Set rs = New ADODB.Recordset
    rs.Open "Exec sp_InsertCallLog " & sSQL, cid, adOpenKeyset, adLockPessimistic
    
    Do Until rs.EOF = True
        LogCall = Str(rs(0))
        rs.MoveNext
    Loop
    Set rs = Nothing
    Set cid = Nothing

End Function



Public Sub Form_Load()

Dim xpl_SubNet As String
Dim strCmdLine As String
Dim intCmdLineLen As Integer
Dim intParamPos As Integer
Dim intLoop As Integer
    
    xpl_SubNet = "255.255.255.255"
    
    With udpSender
        .RemoteHost = xpl_SubNet
        .RemotePort = 3865
    End With

    strCmdLine = UCase(Command())
    intCmdLineLen = Len(strCmdLine)
    
    If InStr(strCmdLine, "/C=") <> 0 Then
       intParamPos = InStr(strCmdLine, "/C=") + 3
       strNumber = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> " " Then
              strNumber = strNumber + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    
    If InStr(strCmdLine, "/N=#") <> 0 Then
       intParamPos = InStr(strCmdLine, "/N=#") + 4
       strName = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> "#" Then
              strName = strName + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    
    If InStr(strCmdLine, "/M=") <> 0 Then
       intParamPos = InStr(strCmdLine, "/M=") + 3
       strDialled = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> " " Then
              strDialled = strDialled + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    
    If InStr(strCmdLine, "/T=") <> 0 Then
       intParamPos = InStr(strCmdLine, "/T=") + 3
       strCallTime = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> " " Then
              strCallTime = strCallTime + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    If Len(Trim(strCallTime)) = 0 Then
       strCallTime = "CAPI-NOT-SUPPORTED"
    End If
    
    If InStr(strCmdLine, "/D=") <> 0 Then
       intParamPos = InStr(strCmdLine, "/D=") + 3
       strCallDate = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> " " Then
              strCallDate = strCallDate + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    If Len(Trim(strCallDate)) = 0 Then
       strCallDate = "CAPI-NOT-SUPPORTED"
    End If
    
    
    If InStr(strCmdLine, "/L=") <> 0 Then
       intParamPos = InStr(strCmdLine, "/L=") + 3
       strMSN = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> " " Then
              strMSN = strMSN + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    
    If InStr(strCmdLine, "/I=") <> 0 Then
       intParamPos = InStr(strCmdLine, "/I=") + 3
       strCIPValue = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> " " Then
              strCIPValue = strCIPValue + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    
    If InStr(strCmdLine, "/R=") <> 0 Then
       intParamPos = InStr(strCmdLine, "/R=") + 3
       strReason = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> " " Then
              strReason = strReason + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    
    If InStr(strCmdLine, "/F=") <> 0 Then
       intParamPos = InStr(strCmdLine, "/F=#") + 4
       strSavedFile = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> "#" Then
              strSavedFile = strSavedFile + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    
    If InStr(strCmdLine, "/Y=") <> 0 Then
       intParamPos = InStr(strCmdLine, "/Y=") + 3
       strCallType = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> " " Then
              strCallType = strCallType + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    
    If InStr(strCmdLine, "/P=") <> 0 Then
       intParamPos = InStr(strCmdLine, "/P=") + 3
       strFAXPages = ""
       For intLoop = intParamPos To intCmdLineLen
           If Mid(strCmdLine, intLoop, 1) <> " " Then
              strFAXPages = strFAXPages + Mid(strCmdLine, intLoop, 1)
           Else
              intLoop = intCmdLineLen
           End If
       Next
    End If
    
    If InStr(strCmdLine, "/START") <> 0 Then
        boolCallStart = True
    Else
        boolCallStart = False
    End If
    
    Send_Message
    End
        
End Sub
