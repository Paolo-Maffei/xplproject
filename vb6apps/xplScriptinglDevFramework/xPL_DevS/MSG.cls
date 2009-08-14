VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSG"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' routine to return a body param count
Public Function GetParamCount(ByVal strMsg As Variant) As Variant
    Dim x, y, z As Integer
    x = InStr(1, strMsg, Chr(10) & "}" & Chr(10), vbBinaryCompare)
    If x = 0 Then
        GetParamCount = 0
        Exit Function
    End If
    x = x + 3
    y = InStr(1, strMsg, "=", vbBinaryCompare)
    While y > 0
        z = z + 1
        x = InStr(y, strMsg, Chr(10), vbBinaryCompare)
        y = InStr(x, strMsg, "=", vbBinaryCompare)
    Wend
    GetParamCount = z
End Function

' routine to return a body param name by index
Public Function GetParamName(ByVal strMsg As Variant, ByVal ParamIndex As Variant) As Variant
    Dim x, y, z As Integer
    x = InStr(1, strMsg, Chr(10) & "}" & Chr(10), vbBinaryCompare)
    If x = 0 Then
        GetParamName = ""
        Exit Function
    End If
    x = x + 3
    While x > 0
        z = z + 1
        y = InStr(x, strMsg, "=", vbBinaryCompare)
        If z = ParamIndex Then
            GetParamName = Mid(strMsg, x + 1, y - x - 1)
            Exit Function
        End If
        x = InStr(y, strMsg, Chr(10), vbBinaryCompare)
    Wend
    GetParamName = ""
End Function

' routine to return a body param value by index
Public Function GetParamValue(ByVal strMsg As Variant, ByVal ParamIndex As Variant, ByVal TrimParam As Variant) As Variant
    Dim x, y, z As Integer
    x = InStr(1, strMsg, Chr(10) & "}" & Chr(10), vbBinaryCompare)
    If x = 0 Then
        GetParamValue = ""
        Exit Function
    End If
    x = x + 3
    y = InStr(1, strMsg, "=", vbBinaryCompare)
    While y > 0
        z = z + 1
        x = InStr(y, strMsg, Chr(10), vbBinaryCompare)
        If z = ParamIndex Then
            If x > 0 Then
                If TrimParam Then
                    GetParamValue = Trim(Mid(strMsg, y + 1, x - y - 1))
                Else
                    GetParamValue = Mid(strMsg, y + 1, x - y - 1)
                End If
                Exit Function
            Else
                GetParamValue = ""
                Exit Function
            End If
        End If
        y = InStr(x, strMsg, "=", vbBinaryCompare)
    Wend
    GetParamValue = ""
End Function

' routine to return a param
Public Function GetParam(ByVal strMsg As Variant, ByVal strParam As Variant, ByVal TrimParam As Variant) As Variant
    Dim x, y As Integer
    ' find
    On Error GoTo getparamfailed
    Select Case UCase(strParam)
        Case "{SCHEMA}"
            x = InStr(1, strMsg, Chr(10) & "}" & Chr(10), vbBinaryCompare)
            y = InStr(x, strMsg, Chr(10) & "{" & Chr(10), vbBinaryCompare)
            If x > 0 And y > 0 Then
                GetParam = Trim(Mid(strMsg, x + 3, y - x - 3))
                On Error GoTo 0
                Exit Function
            End If
        Case "{MSGTYPE}"
            x = InStr(1, strMsg, Chr(10) & "{" & Chr(10), vbBinaryCompare)
            If x > 0 Then
                GetParam = Trim(Left(strMsg, x - 1))
                On Error GoTo 0
                Exit Function
            End If
        Case Else
            x = InStr(1, strMsg, Chr(10) & strParam & "=", vbTextCompare)
            If x = 0 Then
                GetParam = ""
                On Error GoTo 0
                Exit Function
            End If
            x = x + Len(strParam) + 2
            y = InStr(x, strMsg, Chr(10), vbBinaryCompare)
            If TrimParam Then
                GetParam = Trim(Mid(strMsg, x, y - x))
                On Error GoTo 0
                Exit Function
            Else
                GetParam = Mid(strMsg, x, y - x)
                On Error GoTo 0
                Exit Function
            End If
    End Select
getparamfailed:
    On Error GoTo 0
    GetParam = ""
    Exit Function
End Function

' routine to send a xPL message
Public Sub SendMsg(ByVal strMsgType As Variant, ByVal strTarget As Variant, ByVal strSchema As Variant, ByVal strMsg As Variant)
    Dim xplMsgType As String
    Dim xplTarget As String
    Dim xplSchema As String
    Dim xplMsg As String
    If Right(strMsg, 1) <> Chr(10) Then strMsg = strMsg + Chr(10)
    If strMsgType = "" Then strMsgType = "xpl-cmnd"
    If strTarget = "" Then strTarget = "*"
    xplMsgType = strMsgType
    xplTarget = strTarget
    xplSchema = strSchema
    xplMsg = strMsg
    Call xPL_Template.xPLSys.SendXplMsg(xplMsgType, xplTarget, xplSchema, xplMsg)
End Sub

