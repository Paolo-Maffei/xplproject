Attribute VB_Name = "modxPL"
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

Option Explicit

' application specific definitions @@@
Public URLEncode(255) As Boolean

' standard definitions
Public xPL_Source As String
Public xPL_Title As String
Public xPL_WaitForConfig As Boolean
Public xPL_Ready As Boolean

Public xPL_COMPassThru As Boolean

Public Type xPL_MsgType
    Name As String
    Value As String
End Type

Public Type xPL_SectionType
    Section As String
    Details() As xPL_MsgType
    DC As Integer
End Type

Public xPL_Message() As xPL_SectionType
Public xPL_Bodies As Integer

' this stuff is for icon tray
Public Type NOTIFYICONDATA
    cbSize As Long
    hwnd As Long
    uId As Long
    uFlags As Long
    uCallBackMessage As Long
    hIcon As Long
    szTip As String * 64
End Type
Public IconInit As Boolean
Public Const NIM_ADD = &H0
Public Const NIM_MODIFY = &H1
Public Const NIM_DELETE = &H2
Public Const NIF_MESSAGE = &H1
Public Const NIF_ICON = &H2
Public Const NIF_TIP = &H4
Public Const WM_MOUSEMOVE = &H200
Public Const WM_LBUTTONDOWN = &H201     'Button down
Public Const WM_LBUTTONUP = &H202       'Button up
Public Const WM_LBUTTONDBLCLK = &H203   'Double-click
Public Const WM_RBUTTONDOWN = &H204     'Button down
Public Const WM_RBUTTONUP = &H205       'Button up
Public Const WM_RBUTTONDBLCLK = &H206   'Double-click
Public Declare Function SetForegroundWindow Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function Shell_NotifyIcon Lib "shell32" Alias "Shell_NotifyIconA" (ByVal dwMessage As Long, pnid As NOTIFYICONDATA) As Boolean
Public nid As NOTIFYICONDATA
Public InTray As Boolean

' routine to encode string
Public Function EncodeURL(URL As String) As String

    Dim i As Integer
    
    ' encode
    For i = 1 To Len(URL)
        If Mid$(URL, i, 1) = " " Then
            EncodeURL = EncodeURL & "+"
        Else
            If URLEncode(Asc(Mid$(URL, i, 1))) = True Then
                EncodeURL = EncodeURL & Mid$(URL, i, 1)
            Else
                EncodeURL = EncodeURL & "%" & Hex(Asc(Mid$(URL, i, 1)))
            End If
        End If
    Next i
    
End Function

' routine to flag safe chars
Public Sub SetupURLs()

    Dim i As Integer

    ' flag
    For i = 0 To 47
        URLEncode(i) = False
    Next i
    For i = 48 To 57
        URLEncode(i) = True
    Next i
    For i = 58 To 64
        URLEncode(i) = False
    Next i
    For i = 65 To 90
        URLEncode(i) = True
    Next i
    For i = 91 To 96
        URLEncode(i) = False
    Next i
    For i = 97 To 122
        URLEncode(i) = True
    Next i
    For i = 123 To 255
        URLEncode(i) = False
    Next i


End Sub

' routine to get a parameter
Public Function xPL_GetParam(Msg As xPL.xPLMsg, strName As String, WithStrip As Boolean) As Variant

    Dim x As Integer
    Dim y As Integer
    
    ' find name match
    For y = 0 To Msg.NamePairs - 1
        If UCase(Msg.Names(y)) Like UCase(strName) Then
            ' got match
            xPL_GetParam = Msg.Values(y)
            If WithStrip = True Then xPL_GetParam = Trim(xPL_GetParam)
            Exit Function
        End If
    Next y

End Function

' routine to extract message parts
Public Function xPL_Extract(strMsg As String) As Boolean

    Dim strExtract As String
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    
    ' initialise
    xPL_Extract = True
    strExtract = strMsg
    On Error GoTo extract_failed
    xPL_Bodies = -1
extract_next_part:
    ' get section
    y = InStr(1, strExtract, vbLf + "{" + vbLf, vbBinaryCompare)
    If y = 0 Then
        On Error GoTo 0
        If xPL_Bodies = -1 Then xPL_Extract = False
        Exit Function
    End If
    xPL_Bodies = xPL_Bodies + 1
    ReDim Preserve xPL_Message(xPL_Bodies)
    xPL_Message(xPL_Bodies).DC = -1
    xPL_Message(xPL_Bodies).Section = UCase(Trim(Left$(strExtract, y - 1)))
    If xPL_Bodies = 0 Then
        Select Case xPL_Message(xPL_Bodies).Section
        Case "XPL-CMND"
        Case "XPL-STAT"
        Case "XPL-TRIG"
        Case Else
            GoTo extract_failed
        End Select
    End If
    strExtract = Mid$(strExtract, y + 3)

extract_next_name:
    ' get name of name/value pair
    x = InStr(1, strExtract, "=", vbBinaryCompare)
    z = InStr(1, strExtract, "!", vbBinaryCompare)
    If z <> 0 And z < x Then x = z
    xPL_Message(xPL_Bodies).DC = xPL_Message(xPL_Bodies).DC + 1
    ReDim Preserve xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC)
    xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC).Name = UCase(Trim(Left$(strExtract, x - 1)))
    
    ' get value
    strExtract = Mid$(strExtract, x + 1)
    x = InStr(1, strExtract, vbLf, vbBinaryCompare)
    xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC).Value = Left$(strExtract, x - 1)
    If xPL_Bodies = 0 Then
        xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC).Value = UCase(Trim(xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC).Value))
    End If
    
    ' process next section/name
    strExtract = Mid$(strExtract, x)
    If InStr(1, strExtract, vbLf + "}" + vbLf, vbBinaryCompare) = 1 Then
        ' next part
        strExtract = Mid$(strExtract, 4)
        GoTo extract_next_part
    End If
    strExtract = Mid$(strExtract, 2)
    GoTo extract_next_name

extract_failed:
    ' corrupt
    On Error GoTo 0
    xPL_Extract = False
    xPL_Bodies = -1
    
End Function

Public Function xPL_BuildInstance(strInstance As String) As String
    
    Dim strHost As String
    Dim NewInst As String
    Dim x As Integer
    
    ' build
    strHost = UCase(strInstance)
    For x = 1 To Len(strHost)
        Select Case Mid$(strHost, x, 1)
        Case "0" To "9", "A" To "Z"
            NewInst = NewInst + Mid$(strHost, x, 1)
        End Select
    Next x
    NewInst = Left$(NewInst, 10)
    If NewInst = "" Then NewInst = "INSTANCE"
    xPL_BuildInstance = NewInst & Format(Now, "hhmmss")
    
End Function
