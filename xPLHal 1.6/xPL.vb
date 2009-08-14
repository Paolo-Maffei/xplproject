'**************************************
'* xPLHal 
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
Option Strict On

Public Class XPL

    ' routine to convert source.instance safely
    Public Function SrcInst(ByVal strConvert As String) As String
        Dim x As Integer
        Try
            x = InStr(1, strConvert, "_", vbBinaryCompare)
            Return Left(strConvert, x - 1) + "." + Mid(strConvert, x + 1)
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

    ' routine to return a body param count
  Public Function GetParamCount(ByVal strMsg As String) As Integer
    Dim x, y, z As Integer
    x = InStr(1, strMsg, Chr(10) & "}" & Chr(10), CompareMethod.Binary)
    If x = 0 Then Return 0
    x = x + 3
    y = InStr(1, strMsg, "=", CompareMethod.Binary)
    While y > 0
      z = z + 1
      x = InStr(y, strMsg, Chr(10), CompareMethod.Binary)
      y = InStr(x, strMsg, "=", CompareMethod.Binary)
    End While
    Return z - 3
  End Function

  ' routine to return a body param name by index
  Public Function GetParamName(ByVal strMsg As String, ByVal ParamIndex As Integer) As String
    Dim x, y, z As Integer
    If ParamIndex < 1 Or ParamIndex > GetParamCount(strMsg) Then Return ""
    x = InStr(1, strMsg, Chr(10) & "}" & Chr(10), CompareMethod.Binary)
    If x = 0 Then Return ""
    x = x + 3
    x = InStr(x, strMsg, Chr(10) & "{" & Chr(10), CompareMethod.Binary) + 2
    While x > 0
      z = z + 1
      y = InStr(x, strMsg, "=", CompareMethod.Binary)
      If z = ParamIndex Then
        Return Mid(strMsg, x + 1, y - x - 1)
      End If
      x = InStr(y, strMsg, Chr(10), CompareMethod.Binary)
    End While
    Return ""
  End Function

  ' routine to return a body param value by index
  Public Function GetParamValue(ByVal strMsg As String, ByVal ParamIndex As Integer, ByVal TrimParam As Boolean) As String
    Dim x, y, z As Integer
    If ParamIndex < 1 Or ParamIndex > GetParamCount(strMsg) Then Return ""
    x = InStr(1, strMsg, Chr(10) & "}" & Chr(10), CompareMethod.Binary)
    If x = 0 Then Return ""
    x = x + 3
    y = InStr(x, strMsg, "=", CompareMethod.Binary)
    While y > 0
      z = z + 1
      x = InStr(y, strMsg, Chr(10), CompareMethod.Binary)
      If z = ParamIndex Then
        If x > 0 Then
          If TrimParam Then
            Return Trim(Mid(strMsg, y + 1, x - y - 1))
          Else
            Return Mid(strMsg, y + 1, x - y - 1)
          End If
        Else
          Return ""
        End If
      End If
      y = InStr(x, strMsg, "=", CompareMethod.Binary)
    End While
    Return ""
  End Function

  ' routine to return a param
  Public Function GetParam(ByVal strMsg As String, ByVal strParam As String, ByVal TrimParam As Boolean) As String
    Dim x, y As Integer
    ' find
    Try
      Select Case strParam.toupper()
        Case "{SCHEMA}"
          x = InStr(1, strMsg, Chr(10) & "}" & Chr(10), CompareMethod.Binary)
          y = InStr(x, strMsg, Chr(10) & "{" & Chr(10), CompareMethod.Binary)
          If x > 0 And y > 0 Then
            Return Trim(Mid(strMsg, x + 3, y - x - 3))
          End If
        Case "{MSGTYPE}"
          x = InStr(1, strMsg, Chr(10) & "{" & Chr(10), CompareMethod.Binary)
          If x > 0 Then
            Return Trim(Left(strMsg, x - 1))
          End If
        Case Else
          x = InStr(strMsg, Chr(10) & strParam & "=", CompareMethod.Text)
          If x = 0 Then Return Nothing
          x = x + Len(strParam) + 2
          y = InStr(x, strMsg, Chr(10), CompareMethod.Binary)
          If TrimParam Then
            Return Trim(Mid(strMsg, x, y - x))
          Else
            Return Mid(strMsg, x, y - x)
          End If
      End Select
    Catch ex As Exception
      Return Nothing
        End Try
        Return Nothing
  End Function

  ' routine to send a xPL message
  Public Sub SendMsg(ByVal strMsgType As String, ByVal strTarget As String, ByVal strSchema As String, ByVal strMsg As String)    
      Call xPLSendMsg(strMsgType, strTarget, strSchema, strMsg)    
  End Sub

  ' routine to load a message body
  Public Function LoadBody(ByVal strBody As String) As Object
        Dim strMsg As String
        strMsg = ""
    Dim strLine As String
    Dim x As Integer
    Dim f As Integer

    ' try to load body
    If strBody = "" Then Return ""
    Try
      If Dir(xPLHalScripts & "\Messages\" & strBody) = "" Then Return ""
      f = FreeFile()
      FileOpen(f, xPLHalScripts & "\Messages\" & strBody, OpenMode.Input, OpenAccess.Read, OpenShare.Default)
      While Not EOF(f)
        strLine = LineInput(f)
        x = InStr(1, strLine, "=", CompareMethod.Binary)
        If x > 1 And x < strLine.Length Then
          strMsg = strMsg & Left$(strLine, x) & Mid$(strLine, x + 1, 128) & Chr(10)
        End If
      End While
      FileClose(f)
      Return strMsg
    Catch ex As Exception
      Return ""
    End Try

  End Function

End Class
