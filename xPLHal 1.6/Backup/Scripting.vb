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
Public Class Scripting

    Private Structure xPLScriptStruc
        Private Source As String ' containing script file
        Private IsSub As Boolean ' true = sub, false = function
        Private Params As Short ' no of parameters
    End Structure
    Private sc As MSScriptControl.ScriptControl
    Private xPLClass As New XPL
    Private X10Class As New X10
    Private SYSClass As New SYS
    Public e As xpllib.XplListener.XplEventArgs
    Public Source As String
    Public xPLHalRunScriptName As String
    Public xPLHalRunHasParams As String
    Public xPLHalRunParams As Object

    Public xapmsg As String
    Public xapsub As String

    Public Sub ProcessMessage()
        Dim msgMessage As String
        Dim msgType As String
        Dim msgSourceVendor As String
        Dim msgSourceDevice As String
        Dim msgSourceInstance As String
        Dim msgSchemaClass As String
        Dim msgSchemaType As String
        Dim msgSource As String
        Dim msgSchema As String
        Dim msgTarget As String
        Dim chkSource As String
        Dim chkSchema As String
        Dim x As Integer

        ' collect message
        If xPLHalSource.Length = 0 Then Exit Sub
        msgMessage = e.XplMsg.Content
        msgType = e.XplMsg.XPL_Msg(0).Section.ToUpper
        msgSourceVendor = e.XplMsg.Source.Vendor.ToUpper
        msgSourceDevice = e.XplMsg.Source.Device.ToUpper
        msgSourceInstance = e.XplMsg.Source.Instance.ToUpper
        msgSchemaClass = e.XplMsg.Schema.msgClass.ToUpper
        msgSchemaType = e.XplMsg.Schema.msgType.ToUpper
        msgTarget = e.XplMsg.GetParam(0, "target").ToUpper
        msgSource = msgSourceVendor + "-" + msgSourceDevice + "." + msgSourceInstance
        msgSchema = msgSchemaClass + "." + msgSchemaType

        ' Check source script exists, if not then create
        chkSource = msgSourceVendor + "_" + msgSourceDevice + "_" + msgSourceInstance
        If xPLAutoScripts = True And Dir(xPLHalScripts + "\" + chkSource + ".xpl") = "" And msgSourceInstance.ToUpper <> "DEFAULT" Then
            ' create blank source script
            x = FreeFile()
            FileOpen(x, xPLHalScripts + "\" + chkSource + ".xpl", OpenMode.Output, OpenAccess.Write, OpenShare.Default)
            Print(x, "' source script for " + msgSource)
            FileClose(x)
        End If

        ' Check schema script exists, if not then create
        chkSchema = msgSchemaClass + "_" + msgSchemaType
        If xPLAutoScripts = True And Dir(xPLHalScripts + "\" + chkSchema + ".xpl") = "" Then
            ' create blank schema script
            x = FreeFile()
            FileOpen(x, xPLHalScripts + "\" + chkSchema + ".xpl", OpenMode.Output, OpenAccess.Write, OpenShare.Default)
            Print(x, "' schema script for " + msgSchema)
            FileClose(x)
        End If

        ' special intercepts
        Select Case msgType
            Case "XPL-CMND"
                Select Case msgSchema
                    Case "SENDMSG.SMTP"
                        If xPLSMTPDisabled = False Then
                            Dim str As String = SendSMTPMsg.HandleXplMessage(e.XplMsg)
                            If str = "" Then
                                xPLSendMsg("xpl-trig", "*", "sendmsg.smtp", "status=mail sent")
                            Else
                                xPLSendMsg("xpl-trig", "*", "sendmsg.smtp", "status=mail failed" & Chr(10) & "error=" & str)
                            End If
                        End If
                End Select
            Case "XPL-TRIG"
            Case "XPL-STAT"
        End Select

        ' find group in target
        If Left$(msgTarget, 10).ToUpper = "XPL-GROUP." And msgTarget.Length > 10 Then
            ' got a group, does it already exist
            If xPLHalGroups.ContainsKey(Mid$(msgTarget, 11).ToUpper) = False Then
                ' add
                xPLHalGroups.Add(Mid$(msgTarget, 11).ToUpper, DateTime.Now)
            Else
                ' update
                xPLHalGroups(Mid$(msgTarget, 11).ToUpper) = DateTime.Now
            End If
        End If

        ' find correct schema
        If xPLSchemaCount = 0 Or xPLHalCount = 0 Then Exit Sub
        For x = 1 To xPLSchemaCount
            If msgType Like xPLSchemas(x).Type Then
                If msgSourceVendor Like xPLSchemas(x).Vendor Then
                    If msgSourceDevice Like xPLSchemas(x).Device Then
                        If msgSourceInstance Like xPLSchemas(x).Instance Then
                            If msgSchemaClass Like xPLSchemas(x).SchemaClass Then
                                If msgSchemaType Like xPLSchemas(x).SchemaType Then
                                    If xPLSchemas(x).IsX10 = False Then
                                        ' standard scripting
                                        If ScriptingStd(msgMessage, xPLSchemas(x).SubDef, msgType, msgSourceVendor, msgSourceDevice, msgSourceInstance, msgSchemaClass, msgSchemaType) = True Then
                                            If xPLMatchAll = True Then
                                                If xPLSchemas(x).ActionContinue = False Then Exit Sub
                                            Else
                                                Exit Sub
                                            End If
                                        End If
                                    Else
                                        ' x10 scripting
                                        If ScriptingX10(msgMessage, xPLSchemas(x).SubDef, msgType, msgSourceVendor, msgSourceDevice, msgSourceInstance, msgSchemaClass, msgSchemaType, e.XplMsg.GetParam(1, "command").ToUpper.Trim, e.XplMsg.GetParam(1, "house").ToUpper.Trim, e.XplMsg.GetParam(1, "device").ToUpper.Trim) = True Then
                                            If xPLMatchAll = True Then
                                                If xPLSchemas(x).ActionContinue = False Then Exit Sub
                                            Else
                                                Exit Sub
                                            End If
                                        End If
                                    End If
                                End If
                            End If
                        End If
                    End If
                End If
            End If
        Next x

        ' no match
        If msgSchemaClass = "X10" Then
            ' try x10 standard
            Call ScriptingX10(msgMessage, "DXF", msgType, msgSourceVendor, msgSourceDevice, msgSourceInstance, msgSchemaClass, msgSchemaType, e.XplMsg.GetParam(1, "command").ToUpper.Trim, e.XplMsg.GetParam(1, "house").ToUpper.Trim, e.XplMsg.GetParam(1, "device").ToUpper.Trim)
        End If

    End Sub

    ' standard xplhal scripting
    Public Function ScriptingStd(ByVal strMsg As String, ByVal subs As String, ByVal MsgType As String, ByVal SrcVendor As String, ByVal SrcDevice As String, ByVal SrcInstance As String, ByVal SrcSchemaClass As String, ByVal srcSchemaType As String) As Boolean
        Dim strSub As String
        Dim x As Short
        Dim y As Short

        strSub = ""
        For x = 0 To subs.Length - 1
            Select Case subs.Substring(x, 1)
                Case "F" ' message type
                    If SrcSchemaClass = "HBEAT" Or SrcSchemaClass = "CONFIG" Then
                        Select Case SrcSchemaClass
                            Case "HBEAT"
                                strSub = strSub + "Heartbeat_"
                            Case "CONFIG"
                                strSub = strSub + "Config_"
                        End Select
                    Else
                        Select Case MsgType
                            Case "XPL-CMND"
                                strSub = strSub + "Command_"
                            Case "XPL-STAT"
                                strSub = strSub + "Status_"
                            Case "XPL-TRIG"
                                strSub = strSub + "Trigger_"
                            Case Else
                                Exit Function
                        End Select
                    End If
                Case "V" ' vendor
                    strSub = strSub + SrcVendor + "_"
                Case "S" ' device
                    strSub = strSub + SrcDevice + "_"
                Case "I" ' instance
                    strSub = strSub + SrcInstance + "_"
                Case "C" ' class
                    strSub = strSub + SrcSchemaClass + "_"
                Case "T" ' type
                    strSub = strSub + srcSchemaType + "_"
                Case Else ' setting
                    For y = 1 To xPLHalCount
                        If xPLHals(y).SubID = subs.Substring(x, 1) Then
                            strSub = strSub + xPLHals(y).Values(xPLHals(y).Value).Name + "_"
                            Exit For
                        End If
                    Next
            End Select
        Next
        strSub = strSub.Substring(0, strSub.Length - 1)
        Call InitThread()
        Return scRunScript(strSub, True, strMsg)

    End Function

    ' x10 xplhal scripting
    Public Function ScriptingX10(ByVal strMsg As String, ByVal subs As String, ByVal MsgType As String, ByVal SrcVendor As String, ByVal SrcDevice As String, ByVal SrcInstance As String, ByVal SrcSchemaClass As String, ByVal srcSchemaType As String, ByVal x10_Cmd As String, ByVal strHouses As String, ByVal strDevices As String) As Boolean
        Dim x10Cmd As String
        Dim strDevice As String
        Dim lstDevices(26, 16) As Boolean
        Dim x10Result As Boolean
        Dim y As Integer
        Dim z As Integer
        Select Case x10_Cmd
            Case "SELECT"
                x10Cmd = X10_SELECT
            Case "ON"
                x10Cmd = X10_ON
            Case "OFF"
                x10Cmd = X10_OFF
            Case "DIM"
                x10Cmd = X10_DIM
            Case "BRIGHT"
                x10Cmd = X10_BRIGHT
            Case "ALL_LIGHTS_ON"
                x10Cmd = X10_ALL_LIGHTS_ON
            Case "ALL_LIGHTS_OFF"
                x10Cmd = X10_ALL_LIGHTS_OFF
            Case "ALL_UNITS_OFF"
                x10Cmd = X10_ALL_UNITS_OFF
            Case "STATUS"
                x10Cmd = X10_STATUS_REQUEST
            Case "STATUS_ON"
                x10Cmd = X10_STATUS_ON
            Case "STATUS_OFF"
                x10Cmd = X10_STATUS_OFF
            Case Else
                Return False
        End Select
        If strDevices <> "" And strHouses <> "" Then Return False
        If strDevices = "" And strHouses = "" Then Return False
        x10Result = False
        If strHouses <> "" Then
            ' process by house, for valid commands
            Select Case x10Cmd
                Case X10_ON, X10_OFF
                Case X10_DIM, X10_BRIGHT
                Case X10_ALL_LIGHTS_ON, X10_ALL_LIGHTS_OFF
                Case X10_ALL_UNITS_OFF
                Case Else
                    Return x10Result
            End Select
            For y = 1 To Len(strHouses)
                If Mid(strHouses, y, 1) >= "A" And Mid(strHouses, y, 1) <= "Z" Then
                    If RunX10Script(MsgType, subs, x10_Cmd, strMsg, Mid(strHouses, y, 1), "", SrcVendor, SrcDevice, SrcInstance, SrcSchemaClass, srcSchemaType) = True Then x10Result = True
                    If MsgType = "XPL-TRIG" Then x10HouseSet(Mid(strHouses, y, 1), x10Cmd) ' x10 state
                End If
            Next y
        Else
            ' extract device list
            If Right(strDevices, 1) <> "," Then strDevices = strDevices + ","
            While strDevices <> ""
                y = InStr(1, strDevices, ",", vbBinaryCompare)
                strDevice = Left(strDevices, y - 1)
                strDevices = Mid(strDevices, y + 1)
                If Len(strDevice) < 4 Then
                    If Left(strDevice, 1) >= "A" And Left(strDevice, 1) <= "Z" Then
                        If Val(Mid(strDevice, 2)) >= 1 And Val(Mid(strDevice, 2)) <= 16 Then
                            ' got valid device
                            lstDevices(Asc(Left(strDevice, 1)) - 64, Val(Mid(strDevice, 2))) = True
                        End If
                    End If
                End If
            End While
            ' validate command allows device & excecute per housecode
            For y = 1 To 26
                For z = 1 To 16
                    If lstDevices(y, z) = True Then
                        Select Case x10Cmd
                            Case X10_SELECT, X10_ON, X10_OFF, X10_ALL_UNITS_OFF, X10_ALL_LIGHTS_ON, X10_ALL_LIGHTS_OFF
                                If RunX10Script(MsgType, subs, x10_Cmd, strMsg, "", Chr(64 + y) & z, SrcVendor, SrcDevice, SrcInstance, SrcSchemaClass, srcSchemaType) = True Then x10Result = True
                                If MsgType = "XPL-TRIG" Then x10DeviceSet(Chr(64 + y) & z, x10Cmd)
                            Case X10_DIM, X10_BRIGHT
                                If MsgType = "XPL-TRIG" Then x10DeviceSet(Chr(64 + y) & z, X10_ON)
                            Case X10_STATUS_REQUEST ' valid, but does nothing
                            Case X10_STATUS_ON, X10_STATUS_OFF
                                If RunX10Script(MsgType, subs, x10_Cmd, strMsg, "", Chr(64 + y) & z, SrcVendor, SrcDevice, SrcInstance, SrcSchemaClass, srcSchemaType) = True Then x10Result = True
                                If MsgType = "XPL-TRIG" Then x10DeviceSet(Chr(64 + y) & z, x10Cmd)
                            Case Else
                                ' not supported for device
                        End Select
                    End If
                Next z
            Next y
        End If
        Return x10Result
    End Function

    Private Function RunX10Script(ByVal MsgType As String, ByVal subs As String, ByVal strCmd As String, ByVal strMsg As String, ByVal strHouse As String, ByVal strDevice As String, ByVal SrcVendor As String, ByVal SrcDevice As String, ByVal SrcInstance As String, ByVal SrcSchemaClass As String, ByVal srcSchemaType As String) As Boolean
        Dim strSub As String
        Dim x As Short
        Dim y As Short
        strSub = "X10_"
        For x = 0 To subs.Length - 1
            Select Case subs.Substring(x, 1)
                Case "H" ' house code
                    If strHouse = "" And InStr(subs, "D", CompareMethod.Binary) = 0 Then
                        strSub = strSub + Left(strDevice, 1)
                    Else
                        strSub = strSub + strHouse + "_"
                    End If
                Case "D" ' device code
                    If strDevice = "" And InStr(subs, "H", CompareMethod.Binary) = 0 Then Return False
                    strSub = strSub + strDevice + "_"
                Case "X" ' x10 command
                    strSub = strSub + strCmd + "_"
                Case "F" ' message type
                    Select Case MsgType
                        Case "XPL-CMND"
                            strSub = strSub + "Command_"
                        Case "XPL-STAT"
                            strSub = strSub + "Status_"
                        Case "XPL-TRIG"
                            If SrcSchemaClass.ToUpper = "X10" And srcSchemaType.ToUpper = "CONFIRM" Then
                                strSub = strSub + "Confirm_"
                            Else
                                strSub = strSub + "Trigger_"
                            End If
                        Case Else
                            Exit Function
                    End Select
                Case "V" ' vendor
                    strSub = strSub + SrcVendor + "_"
                Case "S" ' device
                    strSub = strSub + SrcDevice + "_"
                Case "I" ' instance
                    strSub = strSub + SrcInstance + "_"
                Case "C" ' class
                    strSub = strSub + SrcSchemaClass + "_"
                Case "T" ' type
                    strSub = strSub + srcSchemaType + "_"
                Case Else ' setting
                    For y = 1 To xPLHalCount
                        If xPLHals(y).SubID = subs.Substring(x, 1) Then
                            strSub = strSub + xPLHals(y).Values(xPLHals(y).Value).Name + "_"
                            Exit For
                        End If
                    Next
            End Select
        Next
        strSub = strSub.Substring(0, strSub.Length - 1)

        Call InitThread()
        Return scRunScript(strSub, True, strMsg)

    End Function

    ' execute script for xplhal
    Public Sub xPLHalRunScript()
        Call scRunScript(xPLHalRunScriptName, xPLHalRunHasParams, xPLHalRunParams)
    End Sub

    ' execute script
    Public Function scRunScript(ByVal strScript As String, ByVal HasParams As Boolean, ByVal strParams As Object) As Boolean
        Try
            If Not chkScript.ContainsKey(strScript.ToUpper) Then Return False
            If HasParams = True Then
                Call sc.Run(strScript, strParams)
            Else
                Call sc.Run(strScript)
            End If
        Catch ex As Exception
            Call WriteErrorLog("Error Executing Script '" + strScript + "' (" & Err.Description & ")")
            Return False
        End Try
        Return True
    End Function

    ' add scripts to this class
    Public Sub InitThread()
        sc = New MSScriptControl.ScriptControl
        sc.Language = "VBScript"
        If Len(xPLScripts) > 0 Then
            Try
                sc.AddCode(xPLScripts)
            Catch ex As Exception
                Call WriteErrorLog("Unable to Load Scripts (" & Err.Description & ")")
            End Try
        End If
        sc.AddObject("xPL", xPLClass)  ' xPL function library
        sc.AddObject("SYS", SYSClass) ' System function library
        sc.AddObject("X10", X10Class) ' x10 function library
        sc.AddObject("XAP", XAPClass) ' xAP support library
        sc.AllowUI = False
        CType(sc, MSScriptControl.IScriptControl).Timeout = 90000
    End Sub

    Public Sub xAP_Scripting()
        Call InitThread()
        Call scRunScript(xapsub, True, xapmsg)
    End Sub

End Class
