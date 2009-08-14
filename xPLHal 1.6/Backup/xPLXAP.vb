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
Module xPLXAP

    ' xpl hub control
    Public xAPSupport As Boolean

    Public Function xAP_GetParam(ByVal Msg As String, ByVal Body As Integer, ByVal Param As String) As String
        Dim x, y As Integer
        Dim section As String
        x = xAP_GetSection(Msg, Body) + 3
        If x = 0 Then Return ""
        y = InStr(x, Msg, Chr(10) & "}")
        section = Mid(Msg, x, y - x + 1)
        x = InStr(1, section.ToUpper, Param.ToUpper & "=", CompareMethod.Binary)
        If x = 0 Then Return ""
        section = Mid(section, x + Len(Param) + 1)
        x = InStr(1, section, Chr(10), CompareMethod.Binary)
        If x = 0 Then Return ""
        Return Left(section, x - 1)
    End Function

    Public Function xAP_SectionCount(ByVal Msg As String) As Integer
        Dim x, y As Integer
        x = 1
        y = 0
        While x > 0
            x = InStr(x + 1, Msg, Chr(10) & "}", CompareMethod.Binary)
            If x > 0 Then y = y + 1
        End While
        Return y
    End Function

    Public Function xAP_GetSection(ByVal Msg As String, ByVal Body As Integer) As Integer
        If Body < 0 Or Body > xAP_SectionCount(Msg) - 1 Then Return 0
        Dim x, y As Integer
        x = 1
        For y = 0 To Body
            x = InStr(x + 1, Msg, Chr(10) & "{" & Chr(10), CompareMethod.Binary)
        Next y
        Return x
    End Function

End Module
