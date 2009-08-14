'**************************************
'* xPL xPLHal 
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
Public Class XAP

    ' routine to return a body count
    Public Function BodyCount(ByVal strMsg As Object) As Object
        Dim x As Integer
        x = xAP_SectionCount(strMsg) - 1
        If x < 0 Then x = 0
        Return x
    End Function

    ' routine to return a param by name
    Public Function GetParam(ByVal strMsg As Object, ByVal Section As Object, ByVal Param As Object) As Object
        Return xAP_GetParam(strMsg, Section, Param)
    End Function

    ' routine to return param count
    Public Function GetParamCount(ByVal strMsg As Object, ByVal Section As Object) As Object
        Dim strBody As String
        Dim x, y As Integer
        If Section < 0 Then Return ""
        If Section > xAP_SectionCount(strMsg) Then Return ""
        x = xAP_GetSection(strMsg, Section) + 3
        If x = 3 Then Return 0
        y = InStr(x, strMsg, Chr(10) & "}")
        strBody = Mid(strMsg, x, y - x + 1)
        x = 0
        y = 1
        While y > 0
            y = InStr(y + 1, strBody, Chr(10), CompareMethod.Binary)
            If y > 0 Then x = x + 1
        End While
        Return x
    End Function

    ' routine to return a param name by index
    Public Function GetParamName(ByVal strMsg As Object, ByVal Section As Object, ByVal ParamIndex As Object) As Object
        Dim strBody As String
        Dim x, y As Integer
        If Section < 0 Then Return ""
        If Section > xAP_SectionCount(strMsg) Then Return ""
        If ParamIndex < 1 Then Return ""
        If ParamIndex > GetParamCount(strMsg, Section) Then Return ""
        x = xAP_GetSection(strMsg, Section) + 3
        If x = 3 Then Return 0
        y = InStr(x, strMsg, Chr(10) & "}")
        strBody = Mid(strMsg, x, y - x + 1)
        x = ParamIndex - 1
        While x > 0
            y = InStr(1, strBody, Chr(10), CompareMethod.Binary)
            strBody = Mid(strBody, y + 1)
            x = x - 1
        End While
        y = InStr(1, strBody, "=", CompareMethod.Binary)
        If y = 0 Then Return ""
        Return Left(strBody, y - 1)
    End Function

    ' routine to return a param value by index
    Public Function GetParamValue(ByVal strMsg As Object, ByVal Section As Object, ByVal ParamIndex As Object) As Object
        Dim strBody As String
        Dim x, y As Integer
        If Section < 0 Then Return ""
        If Section > xAP_SectionCount(strMsg) Then Return ""
        If ParamIndex < 1 Then Return ""
        If ParamIndex > GetParamCount(strMsg, Section) Then Return ""
        x = xAP_GetSection(strMsg, Section) + 3
        If x = 3 Then Return 0
        y = InStr(x, strMsg, Chr(10) & "}")
        strBody = Mid(strMsg, x, y - x + 1) ' chr(10)???
        x = ParamIndex - 1
        While x > 0
            y = InStr(1, strBody, Chr(10), CompareMethod.Binary)
            strBody = Mid(strBody, y + 1)
            x = x - 1
        End While
        y = InStr(1, strBody, "=", CompareMethod.Binary)
        If y = 0 Then Return ""
        strBody = Mid(strBody, y + 1)
        y = InStr(1, strBody, Chr(10), CompareMethod.Binary)
        If y = 0 Then Return ""
        Return Left(strBody, y - 1)
    End Function

    ' routine to return a section name
    Public Function GetSection(ByVal strMsg As Object, ByVal Section As Object) As Object
        Dim x, y As Integer
        If Section < 0 Then Return ""
        If Section > xAP_SectionCount(strMsg) Then Return ""
        If Section > 0 Then
            x = Section
            While x > 0
                y = InStr(1, strMsg, Chr(10) & "}", CompareMethod.Binary)
                strMsg = Mid(strMsg, y + 3)
                x = x - 1
            End While
        End If
        y = InStr(1, strMsg, Chr(10) & "{", CompareMethod.Binary)
        Return Left(strMsg, y - 1)
    End Function

    ' routine to send a message
    Public Sub SendMsg(ByVal UID As Object, ByVal strClass As Object, ByVal strSource As Object, ByVal strTarget As Object, ByVal strMsg As String)
        Dim xAPMsg As String
        Try
            If Right(strMsg, 1) <> Chr(10) Then strMsg = strMsg + Chr(10)
            If Len(UID.ToString) = 0 Then Exit Sub
            If Len(strClass.ToString) = 0 Then Exit Sub
            If Len(strSource.ToString) = 0 Then Exit Sub
            xAPMsg = "xap-header" & Chr(10) & "{" & Chr(10)
            xAPMsg = xAPMsg & "v=12" & Chr(10)
            xAPMsg = xAPMsg & "hop=1" & Chr(10)
            xAPMsg = xAPMsg & "uid=" & UID & Chr(10)
            xAPMsg = xAPMsg & "class=" & strClass & Chr(10)
            xAPMsg = xAPMsg & "source=" & strSource & Chr(10)
            If Len(strTarget.ToString) > 0 Then
                xAPMsg = xAPMsg & "target=" & strTarget & Chr(10)
            End If
            xAPMsg = xAPMsg & "}" & Chr(10)
            xAPMsg = xAPMsg & strMsg
            Dim x As New xpllib.xAPMsg(xAPMsg)
            x.Send()
        Catch ex As Exception
        End Try
    End Sub

    ' routine to send a heartbeat message
    Public Sub HBeatMsg(ByVal UID As Object, ByVal strClass As Object, ByVal strSource As Object, ByVal strInterval As Object, ByVal strPort As Object, ByVal PID As Object, ByVal strHeader As Object, ByVal strMsg As String)
        Dim xAPMsg As String
        Try
            If Right(strMsg, 1) <> Chr(10) Then strMsg = strMsg + Chr(10)
            If Len(UID.ToString) = 0 Then Exit Sub
            If Len(strClass.ToString) = 0 Then Exit Sub
            If Len(strSource.ToString) = 0 Then Exit Sub
            If Len(strInterval.ToString) = 0 Then Exit Sub
            xAPMsg = "xap-hbeat" & Chr(10) & "{" & Chr(10)
            xAPMsg = xAPMsg & "v=12" & Chr(10)
            xAPMsg = xAPMsg & "hop=1" & Chr(10)
            xAPMsg = xAPMsg & "uid=" & UID & Chr(10)
            xAPMsg = xAPMsg & "class=" & strClass & Chr(10)
            xAPMsg = xAPMsg & "source=" & strSource & Chr(10)
            xAPMsg = xAPMsg & "interval=" & strInterval & Chr(10)
            If Len(strPort.ToString) > 0 Then
                xAPMsg = xAPMsg & "port=" & strPort & Chr(10)
            End If
            If Len(PID.ToString) > 0 Then
                xAPMsg = xAPMsg & "pid=" & PID & Chr(10)
            End If
            If Len(strHeader.ToString) > 0 Then
                xAPMsg = xAPMsg & strHeader
                If Right$(xAPMsg, 1) <> Chr(10) Then xAPMsg = xAPMsg & Chr(10)
            End If
            xAPMsg = xAPMsg & "}" & Chr(10)
            If Len(strMsg.ToString) > 0 Then
                xAPMsg = xAPMsg & strMsg
            End If
            Dim x As New xpllib.xAPMsg(xAPMsg)
            x.Send()
        Catch ex As Exception
        End Try
    End Sub

End Class
