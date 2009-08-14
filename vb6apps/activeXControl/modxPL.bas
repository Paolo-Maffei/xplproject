Attribute VB_Name = "modxPL"
'**************************************
'* xPL OCX
'*
'* Copyright (C) 2005 Ian Lowe
'* http://www.xplproject.org.uk
'* Based on work
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
'* As a special exception, the copyright holders of this library give you
'* permission to link this library with independent modules to produce an
'* executable, regardless of the license terms of these independent
'* modules, and to copy and distribute the resulting executable under
'* terms of your choice, provided that you also meet, for each linked
'* independent module, the terms and conditions of the license of that
'* module. An independent module is a module which is not derived from
'* or based on this library. If you modify this library, you may extend
'* this exception to your version of the library, but you are not
'* obligated to do so. If you do not wish to do so, delete this
'* exception statement from your version.
'**************************************

Option Explicit

Public xPL_Port As Long
Public xPL_IP As String
Public xPL_BCast As String
Public xPL_HBeatCount As Integer
Public xPL_JoinedNetwork As Boolean
Public App_Version As String

Public Type xPL_MsgType
    Name As String
    value As String
End Type

Public Type xPL_SectionType
    Section As String
    Details() As xPL_MsgType
    DC As Integer
End Type

Public Type xPL_SourceType
    Valid As Boolean
    Vendor As String
    Device As String
    Instance As String
    OldInstance As String
End Type

Public Type xPL_ConfigType
    Item As String
    Type As String
    Number As Integer
    value() As String
    Default() As String
    ConfCount As Integer
End Type

Public xPL_Message() As xPL_SectionType
Public xPL_Bodies As Integer
Public xPL_Sources() As String
Public xPL_SourceCount As Integer
Public xPL_Source As xPL_SourceType
Public xPL_PreInitDone As Boolean
Public xPL_HBeat As String
Public xPL_Interval As Long
Public xPL_Counter As Long
Public xPL_Configured As Boolean
Public xPL_Targets() As String
Public xPL_TargetCount As Integer
Public xPL_Configs() As xPL_ConfigType
Public xPL_ConfigCount As Integer
Public xPL_ConfigList As String
Public xPL_StatusSchema As String
Public xPL_StatusMsg As String
Public xPL_PassNOMATCH As Boolean
Public xPL_PassHBEAT As Boolean
Public xPL_PassCONFIG As Boolean
Public xPL_Msg As String

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
Private Declare Function RegSetValueEx Lib "advapi32.dll" Alias _
    "RegSetValueExA" (ByVal hKey As Long, _
    ByVal lpValueName As String, ByVal Reserved As Long, _
    ByVal dwType As Long, lpData As Any, _
    ByVal cbData As Long) As Long
Private Declare Function RegDeleteKey Lib "advapi32.dll" Alias _
   "RegDeleteKeyA" (ByVal hKey As Long, ByVal lpSubKey As String) As Long
Private Declare Function RegCreateKeyEx Lib "advapi32.dll" Alias _
    "RegCreateKeyExA" (ByVal hKey As Long, _
    ByVal lpSubKey As String, ByVal Reserved As Long, _
    ByVal lpClass As Long, ByVal dwOptions As Long, _
    ByVal samDesired As Long, ByVal lpSecurityAttributes As Long, _
    phkResult As Long, lpdwDisposition As Long) As Long
   
Const KEY_WRITE = &H20006
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
        If xPL_Bodies < 1 Then xPL_Extract = False
        Exit Function
    End If
    xPL_Bodies = xPL_Bodies + 1
    ReDim Preserve xPL_Message(xPL_Bodies)
    xPL_Message(xPL_Bodies).DC = -1
    xPL_Message(xPL_Bodies).Section = LCase(Trim(Left$(strExtract, y - 1)))
    If xPL_Bodies = 0 Then
        Select Case UCase(xPL_Message(0).Section)
        Case "XPL-CMND"
        Case "XPL-STAT"
        Case "XPL-TRIG"
        Case Else
            xPL_Message(0).Section = ""
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
    xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC).Name = LCase(Trim(Left$(strExtract, x - 1)))
    
    ' get value
    strExtract = Mid$(strExtract, x + 1)
    x = InStr(1, strExtract, vbLf, vbBinaryCompare)
    xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC).value = Left$(strExtract, x - 1)
    If xPL_Bodies = 0 Then
        xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC).value = LCase(Trim(xPL_Message(xPL_Bodies).Details(xPL_Message(xPL_Bodies).DC).value))
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
    Dim y As Integer
    
    ' get bodies to check
    x = 0 ' header
    If inBody = True Then x = 1
    
    ' find name match
    For y = 0 To xPL_Message(x).DC
        If UCase(xPL_Message(x).Details(y).Name) Like UCase(strName) Then
            ' got match
            xPL_GetParam = xPL_Message(x).Details(y).value
            If WithStrip = True Then xPL_GetParam = Trim(xPL_GetParam)
            Exit Function
        End If
    Next y

End Function

' routine to check source/target
Public Function xPLSourceChk(source As String) As xPL_SourceType

    Dim l As Integer
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer

    ' validate
    xPLSourceChk.Valid = False
    If Len(source) > 34 Then Exit Function
    For l = 1 To Len(source)
        Select Case UCase(Mid$(source, l, 1))
        Case "A" To "Z", "0" To "9"
        Case "-"
            If x > 0 Then Exit Function
            If l = 1 Or l > 9 Then Exit Function
            x = l
        Case "."
            If y > 0 Then Exit Function
            If y > 18 Or y = Len(source) Then Exit Function
            y = l
        Case Else
            Exit Function
        End Select
    Next l
    If x = 0 Then Exit Function
    If y = 0 Then Exit Function
    If y < x Then Exit Function
    x = x + 1
    z = Len(source)
    If z - y > 16 Or z - y < 1 Then Exit Function
    If y - x > 8 Or y - x < 1 Then Exit Function
    xPLSourceChk.Valid = True
    xPLSourceChk.Vendor = Mid$(source, 1, x - 2)
    xPLSourceChk.Device = Mid$(source, x, y - x)
    xPLSourceChk.Instance = Mid$(source, y + 1)

End Function

Public Function xPLSchemaChk(Schema As String) As Boolean

    Dim l As Integer
    Dim x As Integer
    Dim y As Integer

    ' validate
    xPLSchemaChk = False
    If Len(Schema) > 17 Then Exit Function
    For l = 1 To Len(Schema)
        Select Case UCase(Mid$(Schema, l, 1))
        Case "A" To "Z", "0" To "9"
        Case "."
            If x > 0 Then Exit Function
            If l = 1 Or l > 9 Or l = Len(Schema) Then Exit Function
            x = l
        Case Else
            Exit Function
        End Select
    Next l
    xPLSchemaChk = True
    
End Function

Public Function xPLMessageChk(Message As String) As Boolean

    Dim l As Integer
    Dim x As Integer
    Dim y As Integer
    Dim z As Integer
    
    ' validate
    xPLMessageChk = False
    x = 1
    y = InStr(x, Message, Chr$(10), vbBinaryCompare)
    While y > 0
        If y - x < 2 Then Exit Function
        z = InStr(x, Message, "=", vbBinaryCompare)
        If z = 0 Or z > y Then Exit Function
        If z = x Then Exit Function
        If z - x > 16 Then Exit Function
        For l = x To z - 1
            Select Case UCase(Mid$(Message, l, 1))
            Case "A" To "Z", "0" To "9", "-"
            Case Else
                Exit Function
            End Select
        Next l
        x = y + 1
        y = InStr(x, Message, Chr$(10), vbBinaryCompare)
    Wend
    xPLMessageChk = True
    
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
    
    ' prepare
    length = 256
    ReDim resBinary(0 To length - 1) As Byte
    
    ' read the registry key
    retVal = RegQueryValueEx(handle, ValueName, 0, valueType, resBinary(0), _
        length)

    ' return a value corresponding to the value type
    Select Case valueType
        Case REG_SZ, REG_EXPAND_SZ
            ' copy everything but the trailing null char
            If length > 0 Then
                resString = Space$(length - 1)
                CopyMemory ByVal resString, resBinary(0), length - 1
                GetRegistryValue = resString
            Else
                GetRegistryValue = DefaultValue
            End If
        Case Else
            GetRegistryValue = DefaultValue
    End Select
    If GetRegistryValue = Empty Then GetRegistryValue = DefaultValue
    If IsNull(GetRegistryValue) Then GetRegistryValue = DefaultValue
    
    ' close the registry key
    RegCloseKey handle

End Function

' Read a Registry value
Function GetRegistryValueNum(ByVal hKey As Long, ByVal KeyName As String, ByVal ValueName As String, Optional DefaultValue As Variant) As Variant
    Dim handle As Long
    Dim resLong As Long
    Dim resString As String
    Dim resBinary() As Byte
    Dim length As Long
    Dim retVal As Long
    Dim valueType As Long
    
    ' Prepare the default result
    GetRegistryValueNum = IIf(IsMissing(DefaultValue), Empty, DefaultValue)
    
    ' Open the key, exit if not found.
    If RegOpenKeyEx(hKey, KeyName, 0, KEY_READ, handle) Then
        Exit Function
    End If
    
    ' prepare a 1K receiving resBinary
    length = 256
    ReDim resBinary(0 To length - 1) As Byte
    
    ' read the registry key
    retVal = RegQueryValueEx(handle, ValueName, 0, valueType, resBinary(0), _
        length)
    
    ' return a value corresponding to the value type
    Select Case valueType
        Case REG_DWORD
            CopyMemory resLong, resBinary(0), 4
            GetRegistryValueNum = resLong
        Case Else
            GetRegistryValueNum = 0
    End Select
    If GetRegistryValueNum = Empty Then GetRegistryValueNum = 0
    If IsNull(GetRegistryValueNum) Then GetRegistryValueNum = 0
    
    ' close the registry key
    RegCloseKey handle

End Function

' write registry value
Function SetRegistryValue(ByVal hKey As Long, ByVal KeyName As String, _
    ByVal ValueName As String, value As Variant) As Boolean
    Dim handle As Long
    Dim lngValue As Long
    Dim strValue As String
    Dim binValue() As Byte
    Dim length As Long
    Dim retVal As Long
    
    If RegOpenKeyEx(hKey, KeyName, 0, KEY_WRITE, handle) Then
        Exit Function
    End If

    Select Case VarType(value)
        Case vbInteger, vbLong
            lngValue = value
            retVal = RegSetValueEx(handle, ValueName, 0, _
                    REG_DWORD, lngValue, 4)
        Case vbString
            strValue = value
            retVal = RegSetValueEx(handle, ValueName, 0, _
                    REG_SZ, ByVal strValue, Len(strValue))
        Case vbArray + vbByte
            binValue = value
            length = UBound(binValue) - LBound(binValue) + 1
            retVal = RegSetValueEx(handle, ValueName, 0, _
                REG_BINARY, binValue(LBound(binValue)), length)
        Case Else
            strValue = value
            retVal = RegSetValueEx(handle, ValueName, 0, _
                    REG_SZ, ByVal strValue, Len(strValue))
    End Select
    
    RegCloseKey handle
    SetRegistryValue = (retVal = 0)

End Function

' check key
Function CheckRegistryKey(ByVal hKey As Long, _
   ByVal KeyName As String) As Boolean

    Dim handle As Long

    If RegOpenKeyEx(hKey, KeyName, 0, KEY_READ, handle) = 0 Then
        CheckRegistryKey = True
        RegCloseKey handle
    End If
    
End Function

' create key
Function CreateRegistryKey(ByVal hKey As Long, _
    ByVal KeyName As String) As Boolean

    Dim handle As Long, disposition As Long
    
    If RegCreateKeyEx(hKey, KeyName, 0, 0, 0, 0, 0, handle, disposition) Then
        Err.Raise 1001, , "Nelze vytvorit klíc v registru"
    Else
        CreateRegistryKey = (disposition = REG_OPENED_EXISTING_KEY)
        RegCloseKey handle
    End If
End Function

' delete key
Sub DeleteRegistryKey(ByVal hKey As Long, ByVal KeyName As String)

   RegDeleteKey hKey, KeyName

End Sub

' check config items
Sub CheckRegistry()

    ' check each level
    If CheckRegistryKey(&H80000002, "SOFTWARE\xPL") = False Then
        Call CreateRegistryKey(&H80000002, "SOFTWARE\xPL")
    End If
    If CheckRegistryKey(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor) = False Then
        Call CreateRegistryKey(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor)
    End If
    If CheckRegistryKey(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device) = False Then
        Call CreateRegistryKey(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device)
    End If
    If CheckRegistryKey(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.Instance) = False Then
        Call CreateRegistryKey(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.Instance)
    End If
    
End Sub


' save xpl to registry
Sub SavexPL()
    
    Dim x As Integer
    Dim y As Integer
    
    ' delete old settings
    Call DeleteRegistryKey(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.OldInstance)
    xPL_Source.OldInstance = xPL_Source.Instance
    
    ' save new settings
    Call CheckRegistry
    Call SetRegistryValue(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.Instance, "xPLHubPort", xPL_Port)
    For x = 1 To xPL_ConfigCount
        If xPL_Configs(x).Number = 1 Then
            ' single item
            Call SetRegistryValue(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.Instance, xPL_Configs(x).Item, xPL_Configs(x).value(1))
        Else
            ' multi item
            For y = 1 To UBound(xPL_Configs(x).value)
                Call SetRegistryValue(&H80000002, "SOFTWARE\xPL\" & xPL_Source.Vendor & "\" & xPL_Source.Device & "\" & xPL_Source.Instance, xPL_Configs(x).Item & y, xPL_Configs(x).value(y))
            Next y
        End If
    Next x

End Sub
