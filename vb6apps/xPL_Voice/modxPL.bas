Attribute VB_Name = "modxPL"
'**************************************
'* xPL Voice
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
Public Activated As Boolean
Public CurrentContext As String

' standard definitions
Public xPL_Source As String
Public xPL_Title As String
Public xPL_WaitForConfig As Boolean
Public xPL_Ready As Boolean

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

' routine to get a parameter
Public Function xPL_GetParam(msg As xPLMsg, strName As String, WithStrip As Boolean) As Variant

    Dim x As Integer
    Dim y As Integer
    
    ' find name match
    For y = 0 To msg.NamePairs - 1
        If UCase(msg.Names(y)) Like UCase(strName) Then
            ' got match
            xPL_GetParam = msg.Values(y)
            If WithStrip = True Then xPL_GetParam = Trim(xPL_GetParam)
            Exit Function
        End If
    Next y

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


