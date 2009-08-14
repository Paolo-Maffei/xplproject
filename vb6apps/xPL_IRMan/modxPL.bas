Attribute VB_Name = "modxPL"
'**************************************
'* xPL IRMan
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
Public Type IRManStruc
    Device As String
    Button As String
    IRCode As String
End Type
Public IRMan() As IRManStruc
Public IRManCodes As Integer
Public Learning As Boolean
Public LearnCancel As Boolean
Public IRManPath As String
Public Sending As Boolean

Public Buffer(128) As String
Public BufferHead As Integer
Public BufferTail As Integer

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
Public Function xPL_GetParam(Msg As xPLMsg, strName As String, WithStrip As Boolean) As Variant

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

' routine to load ir data
Public Sub LoadIRDatabase()

    Dim x As Integer
    Dim strIRMan As String
    Dim strIRManLoad As IRManStruc

    ' load code database
    IRManCodes = 0
    IRManPath = App.Path
    If Right$(IRManPath, 1) <> "\" Then IRManPath = IRManPath + "\"
    IRManPath = IRManPath + "IRMan.cfg"
    If Dir(IRManPath, vbNormal) <> "" Then
        ' got database, so load
        Open IRManPath For Input As #1
        While Not EOF(1)
            Line Input #1, strIRMan
            x = InStr(1, strIRMan, ",", vbBinaryCompare)
            If x > 1 Then
                ' got device
                strIRManLoad.Device = Left$(strIRMan, x - 1)
                strIRMan = Mid$(strIRMan, x + 1)
                x = InStr(1, strIRMan, ",", vbBinaryCompare)
                If x > 1 Then
                    ' got button
                    strIRManLoad.Button = Left$(strIRMan, x - 1)
                    strIRMan = Mid$(strIRMan, x + 1)
                    If Len(strIRMan) > 10 Then
                        ' got it code
                        strIRManLoad.IRCode = strIRMan
                        ' load it up
                        IRManCodes = IRManCodes + 1
                        ReDim Preserve IRMan(IRManCodes)
                        IRMan(IRManCodes).Device = strIRManLoad.Device
                        IRMan(IRManCodes).Button = strIRManLoad.Button
                        IRMan(IRManCodes).IRCode = strIRManLoad.IRCode
                    End If
                End If
            End If
        Wend
        Close #1
    End If

End Sub

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



