Attribute VB_Name = "Utility"
Option Explicit

Public Type xPL_Hub

    Port As Long
    Refreshed As Date
    Interval As Integer
    Confirmed As Boolean
    VDI As String
    
End Type

Public Const MAX_HUBS = 64

Public HubIP As String
Public HubPort As Long
Public xPL_hubs(MAX_HUBS) As xPL_Hub

Public xPL_style As Integer

Public HubRunning As Boolean

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

Type RECT
   Left As Long
   Top As Long
   Right As Long
   Bottom As Long
End Type

Public WaitingClose As Boolean

Declare Function GetWindowRect Lib "user32" (ByVal hwnd As Long, lpRect As RECT) As Long
Declare Function MoveWindow Lib "user32" (ByVal hwnd As Long, ByVal x As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal bRepaint As Long) As Long
Declare Function GetDesktopWindow Lib "user32" () As Long
Declare Function EnumWindows Lib "user32" (ByVal lpEnumFunc As Long, ByVal lParam As Long) As Long
Declare Function EnumChildWindows Lib "user32" (ByVal hWndParent As Long, ByVal lpEnumFunc As Long, ByVal lParam As Long) As Long
Declare Function EnumThreadWindows Lib "user32" (ByVal dwThreadId As Long, ByVal lpfn As Long, ByVal lParam As Long) As Long
Declare Function GetWindowThreadProcessId Lib "user32" (ByVal hwnd As Long, lpdwProcessId As Long) As Long
Declare Function GetClassName Lib "user32" Alias "GetClassNameA" (ByVal hwnd As Long, ByVal lpClassName As String, ByVal nMaxCount As Long) As Long
Declare Function GetWindowText Lib "user32" Alias "GetWindowTextA" (ByVal hwnd As Long, ByVal lpString As String, ByVal cch As Long) As Long

Public Declare Function ShowWindow Lib "user32" (ByVal hwnd As Long, ByVal nCmdShow As Long) As Long

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
Public InTray As Boolean

Public AppCount As Integer
Public ApplhWnd() As Long
Public AppTitle() As String

Public StartCount As Integer
Public AppCheck As Integer

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

Function EnumWinProc(ByVal lhWnd As Long, ByVal lParam As Long) As Long
         
    Dim retVal As Long, ProcessID As Long, ThreadID As Long
    Dim WinClassBuf As String * 255, WinTitleBuf As String * 255
    Dim WinClass As String, WinTitle As String
    Dim strTitle As String
    Dim x As Integer
    Dim Y As Integer
    Dim z As Integer
         
    retVal = GetClassName(lhWnd, WinClassBuf, 255)
    WinClass = StripNulls(WinClassBuf)  ' remove extra Nulls & spaces
    retVal = GetWindowText(lhWnd, WinTitleBuf, 255)
    WinTitle = StripNulls(WinTitleBuf)
    If WinClass = "ThunderFormDC" And WinTitle = "Hub" Then
        Call AddApplication(lhWnd, "Hub")
    End If
    If WinClass = "ThunderRT6FormDC" Then
        x = InStr(1, WinTitle, "-", vbBinaryCompare)
        Y = InStr(1, WinTitle, ".", vbBinaryCompare)
        If x > 0 And Y > x + 1 And Y < Len(WinTitle) Then
             strTitle = WinTitle
             x = InStr(1, strTitle, " ", vbBinaryCompare)
             While x > 0
                    strTitle = Mid(strTitle, x + 1)
                    x = InStr(1, strTitle, " ", vbBinaryCompare)
             Wend
             Call AddApplication(lhWnd, strTitle)
        Else
             If WinTitle = "Hub" Then
                 Call AddApplication(lhWnd, "Hub")
             End If
        End If
    End If
    
    EnumWinProc = True
    
End Function

Public Function StripNulls(OriginalStr As String) As String
    ' This removes the extra Nulls so String comparisons will work
    If (InStr(OriginalStr, Chr(0)) > 0) Then
        OriginalStr = Left(OriginalStr, InStr(OriginalStr, Chr(0)) - 1)
    End If
    StripNulls = OriginalStr
End Function

Public Sub AddApplication(lhWnd As Long, strTitle As String)

    Dim x As Integer
    
    ' add to list of managed
    For x = 1 To AppCount
        If ApplhWnd(x) = lhWnd Then
            AppTitle(x) = strTitle
            xPL.mnuApps(x).Caption = strTitle
            Exit Sub
        End If
    Next x
    AppCount = AppCount + 1
    ReDim Preserve ApplhWnd(AppCount)
    ApplhWnd(AppCount) = lhWnd
    ReDim Preserve AppTitle(AppCount)
    AppTitle(AppCount) = strTitle
    x = xPL.mnuApps.Count
    Load xPL.mnuApps(x)
    xPL.mnuApps(x).Caption = strTitle
    xPL.mnuApps(x).Visible = True
        
End Sub

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




