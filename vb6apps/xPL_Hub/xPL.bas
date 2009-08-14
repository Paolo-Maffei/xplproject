Attribute VB_Name = "xPL"
'**************************************
'* xPL Hub
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

' standard types
Public Type xPL_MsgType
    Name As String
    Value As String
End Type

Public Type xPL_SectionType
    Section As String
    Details() As xPL_MsgType
    DC As Integer
End Type

' standard working definitions
Public xPL_Message() As xPL_SectionType
Public xPL_Bodies As Integer
Public InTray As Boolean

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

' taskbar stuff
Private Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long) As Long
Private Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Private Const GWL_EXSTYLE = (-20)
Private Const WS_EX_APPWINDOW = &H40000

Private Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" _
    (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, _
    ByVal samDesired As Long, phkResult As Long) As Long
Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As _
    Long
Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias _
    "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, _
    ByVal lpReserved As Long, lpType As Long, lpData As Any, _
    lpcbData As Long) As Long
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (dest As _
    Any, source As Any, ByVal numBytes As Long)
   
Const KEY_READ = &H20019
Const REG_OPENED_EXISTING_KEY = &H2

Const REG_SZ = 1
Const REG_EXPAND_SZ = 2
Const REG_BINARY = 3
Const REG_DWORD = 4
Const REG_MULTI_SZ = 7
Const ERROR_MORE_DATA = 234

' routine to extract message parts
Public Function xPL_Extract(strMsg As String) As Boolean

    Dim strExtract As String
    Dim x As Integer
    Dim Y As Integer
    Dim z As Integer
    
    ' initialise
    xPL_Extract = True
    strExtract = strMsg
    On Error GoTo extract_failed
    xPL_Bodies = -1
extract_next_part:
    ' get section
    Y = InStr(1, strExtract, vbLf + "{" + vbLf, vbBinaryCompare)
    If Y = 0 Then
        On Error GoTo 0
        If xPL_Bodies = -1 Then xPL_Extract = False
        Exit Function
    End If
    xPL_Bodies = xPL_Bodies + 1
    ReDim Preserve xPL_Message(xPL_Bodies)
    xPL_Message(xPL_Bodies).DC = -1
    xPL_Message(xPL_Bodies).Section = UCase(Trim(Left$(strExtract, Y - 1)))
    If xPL_Bodies = 0 Then
        Select Case xPL_Message(xPL_Bodies).Section
        Case "XPL-CMND"
        Case "XPL-STAT"
        Case "XPL-TRIG"
        Case Else
            GoTo extract_failed
        End Select
    End If
    strExtract = Mid$(strExtract, Y + 3)

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
        xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC).Value = Trim(xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC).Value)
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

' routine to get a parameter
Public Function xPL_GetParam(inBody As Boolean, strName As String, WithStrip As Boolean) As Variant

    Dim x As Integer
    Dim Y As Integer
    
    ' get bodies to check
    x = 0 ' header
    If inBody = True Then x = 1
    
    ' find name match
    For Y = 0 To xPL_Message(x).DC
        If UCase(xPL_Message(x).Details(Y).Name) Like UCase(strName) Then
            ' got match
            xPL_GetParam = xPL_Message(x).Details(Y).Value
            If WithStrip = True Then xPL_GetParam = Trim(xPL_GetParam)
            Exit Function
        End If
    Next Y

End Function


' function to get command line paramater
Public Function GetCommandLine(MaxArgs As Integer, WhichArg As Integer)
    
    Dim C As String
    Dim CmdLine As String
    Dim CmdLnLen As Integer
    Dim InArg As Boolean
    Dim I As Integer
    Dim NumArgs As Integer
    Dim x As Integer
    
    ' get command line arguments
    If IsMissing(MaxArgs) Then MaxArgs = 10
    If IsMissing(WhichArg) Then WhichArg = 1
    ReDim argarray(MaxArgs)
    NumArgs = 0
    InArg = False
    CmdLine = Command()
'    x = InStr(1, CmdLine, "/manager", vbTextCompare)
'    If x > 0 Then
'        xPL_style = 2  ' hidden from view
'        CmdLine = Left$(CmdLine, x - 1) + Mid$(CmdLine, x + 8)
'    End If
    x = InStr(1, CmdLine, "/taskbar", vbTextCompare)
    If x > 0 Then
        xPL_style = 1  ' taskbar
        CmdLine = Left$(CmdLine, x - 1) + Mid$(CmdLine, x + 8)
    End If
    CmdLnLen = Len(CmdLine)
    For I = 1 To CmdLnLen
        C = Mid(CmdLine, I, 1)
        If (C <> " " And C <> vbTab) Then
            If Not InArg Then
                If NumArgs = MaxArgs Then Exit For
                NumArgs = NumArgs + 1
                InArg = True
            End If
            argarray(NumArgs) = argarray(NumArgs) & C
        Else
            InArg = False
        End If
    Next I
    ReDim Preserve argarray(NumArgs)
    If NumArgs = 0 Then
        GetCommandLine = ""
    Else
        GetCommandLine = argarray(WhichArg)
    End If
    
End Function

Public Sub ShowMeInTaskBar()

    ' show
    SetWindowLong Hub.hwnd, GWL_EXSTYLE, (GetWindowLong(Hub.hwnd, GWL_EXSTYLE) Or WS_EX_APPWINDOW)

End Sub

' Read a Registry value
Function GetRegistryValue(ByVal hKey As Long, ByVal KeyName As String, ByVal ValueName As String, Optional DefaultValue As Variant) As Variant
    Dim handle As Long
    Dim resLong As Long
    Dim resString As String
    Dim resBinary() As Byte
    Dim length As Long
    Dim retVal As Long
    Dim valueType As Long
    
    ' Prepare the default result
    GetRegistryValue = IIf(IsMissing(DefaultValue), Empty, DefaultValue)
    
    ' Open the key, exit if not found.
    If RegOpenKeyEx(hKey, KeyName, 0, KEY_READ, handle) Then
        Exit Function
    End If
    
    ' prepare a 1K receiving resBinary
    length = 1024
    ReDim resBinary(0 To length - 1) As Byte
    
    ' read the registry key
    retVal = RegQueryValueEx(handle, ValueName, 0, valueType, resBinary(0), _
        length)
    ' if resBinary was too small, try again
    If retVal = ERROR_MORE_DATA Then
        ' enlarge the resBinary, and read the value again
        ReDim resBinary(0 To length - 1) As Byte
        retVal = RegQueryValueEx(handle, ValueName, 0, valueType, resBinary(0), _
            length)
    End If
    
    ' return a value corresponding to the value type
    Select Case valueType
        Case REG_DWORD
            CopyMemory resLong, resBinary(0), 4
            GetRegistryValue = resLong
        Case REG_SZ, REG_EXPAND_SZ
            ' copy everything but the trailing null char
            resString = Space$(length - 1)
            CopyMemory ByVal resString, resBinary(0), length - 1
            GetRegistryValue = resString
        Case REG_BINARY
            ' resize the result resBinary
            If length <> UBound(resBinary) + 1 Then
                ReDim Preserve resBinary(0 To length - 1) As Byte
            End If
            GetRegistryValue = resBinary()
        Case REG_MULTI_SZ
            ' copy everything but the 2 trailing null chars
            resString = Space$(length - 2)
            CopyMemory ByVal resString, resBinary(0), length - 2
            GetRegistryValue = resString
        Case Else
    End Select
    
    ' close the registry key
    RegCloseKey handle
End Function



