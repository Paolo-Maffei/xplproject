VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "xPLASP"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'**************************************
'* xPL Web
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

Option Explicit

Const MAX_SOCKET_BUFFER As Long = 8192

Private MyScriptingContext As ScriptingContext
Private MyApplication As Application
Private MyRequest As Request
Private MyResponse As Response
Private MyServer As Server
Private MySession As Session

Private xHCPSocket As Long

Public Sub OnStartPage(PassedScriptingContext As ScriptingContext)
    
    Set MyScriptingContext = PassedScriptingContext
    Set MyApplication = MyScriptingContext.Application
    Set MyRequest = MyScriptingContext.Request
    Set MyResponse = MyScriptingContext.Response
    Set MyServer = MyScriptingContext.Server
    Set MySession = MyScriptingContext.Session

End Sub

Public Sub OnEndPage()
    
    Set MyScriptingContext = Nothing
    Set MyApplication = Nothing
    Set MyRequest = Nothing
    Set MyResponse = Nothing
    Set MyServer = Nothing
    Set MySession = Nothing

End Sub

' routine to send an xpl message
Public Sub Send(ByVal varType As Variant, ByVal varTarget As Variant, ByVal varSchema As Variant, ByVal varMsg As Variant)

    Dim strType As String
    Dim strTarget As String
    Dim strSchema As String
    Dim strMsg As String
    
    ' send
    strType = varType
    strTarget = varTarget
    strSchema = varSchema
    strMsg = varMsg
    If Len(strMsg) < 3 Then Exit Sub
    strMsg = Replace(strMsg, "\n", Chr(10))
    strMsg = Replace(strMsg, "\" & Chr(10), "\n")
    Call xPL_SendMsg(strType, strTarget, strSchema, strMsg)

End Sub

' general routine to send a message
Private Sub xPL_SendMsg(strType As String, strTarget As String, strSchema As String, strMessage As String)

    Dim xPLMessageBody As String
    Dim strStyle As String
    Dim x As Integer
    Dim Socket As Long ' Handle to the socket
    Dim strBuffer As String * MAX_SOCKET_BUFFER ' Temporary buffer to hold data from the socket
    Dim bytes_read As Long
    
    ' xPL send message
    If strType = "" Then
        xPLMessageBody = "xpl-cmnd" & Chr$(10) & "{" & Chr$(10)
    Else
        xPLMessageBody = strType & Chr$(10) & "{" & Chr$(10)
    End If
    xPLMessageBody = xPLMessageBody & "hop=1" & Chr$(10)
    xPLMessageBody = xPLMessageBody & "source=TONYT-WEB.HAPC" & Chr$(10)
    If strTarget = "" Then
        xPLMessageBody = xPLMessageBody & "target=*" & Chr$(10)
    Else
        xPLMessageBody = xPLMessageBody & "target=" & strTarget & Chr$(10)
    End If
    xPLMessageBody = xPLMessageBody & "}" & Chr$(10)
    If strSchema = "" Then
        xPLMessageBody = xPLMessageBody & "X10" & "." & "BASIC" & Chr$(10) & "{" & Chr$(10)
    Else
        xPLMessageBody = xPLMessageBody & strSchema & Chr$(10) & "{" & Chr$(10)
    End If
    If Right$(strMessage, 1) <> Chr$(10) Then strMessage = strMessage + Chr$(10)
    xPLMessageBody = xPLMessageBody & strMessage
    xPLMessageBody = xPLMessageBody & "}" & Chr$(10)

    ' send
    bytes_read = sqSendUDPPacket("255.255.255.255", 3865, xPLMessageBody, Len(xPLMessageBody))

End Sub

Private Sub Class_Initialize()

    ' init
    Call sqInit
    
End Sub

Private Sub Class_Terminate()

    ' close
    Call sqCleanup

End Sub

