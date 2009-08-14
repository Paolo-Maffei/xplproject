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
Module Config

    Public Sub ConfigProcess(ByVal msgSource As String, ByVal e As xpllib.XplMsg, ByVal msgSourceVendor As String, ByVal msgSourceDevice As String, ByVal msgSourceInstance As String, ByVal msgType As String, ByVal msgSchemaClass As String, ByVal msgSchemaType As String)

        Dim strMsg As String
        Dim f As Integer
        Dim x, y, z(1) As Integer
        Dim p As Integer
        Dim RequestSent As Boolean
        Dim strType As String
        Dim strValue As String
        Dim strNumber As String
        Dim strInput As String
        Dim ThisConf As String
        Dim NextConf As String

        ' are we interested
        If msgType <> "XPL-STAT" Then Exit Sub

        ' check if device exists
        x = -1
        If xPLDeviceCount > -1 Then
            If xPLDevice.ContainsKey(msgSource.ToUpper) = True Then
                x = xPLDevice(msgSource.ToUpper)
            End If
        End If

        ' processing for disabled scenario
        If xPLConfigDisabled = True Then
            Select Case msgSchemaClass
                Case "HBEAT"
                    If msgSchemaType <> "END" Then
                        If x = -1 And (msgSchemaType = "BASIC" Or msgSchemaType = "APP") Then
                            xPLDeviceCount = xPLDeviceCount + 1
                            ReDim Preserve xPLDevices(xPLDeviceCount)
                            x = xPLDeviceCount
                            xPLDevices(x).VDI = msgSource.ToUpper
                            xPLDevices(x).ConfigDone = True
                            xPLDevices(x).ConfigMissing = False
                            xPLDevices(x).ConfigSource = ""
                            xPLDevices(x).ConfigType = False
                            xPLDevices(x).Suspended = False
                            xPLDevices(x).WaitingConfig = False
                            xPLDevices(x).Suspended = False
                            xPLDevice.Add(msgSource, x)
                        End If
                        xPLDevices(x).Interval = Val(e.GetParam(1, "interval"))
                        xPLDevices(x).Expires = DateAdd(DateInterval.Minute, (2 * xPLDevices(x).Interval) + 1, Now)
                        xPLDevices(x).ConfigType = False
                        xPLDevices(x).Suspended = False
                        xPLDevices(x).WaitingConfig = False
                        xPLDevices(x).ConfigDone = True
                    Else
                        ' closing
                        If x <> -1 Then
                            xPLDevices(x).Suspended = True
                            xPLDevices(x).ConfigDone = False
                            xPLDevices(x).ConfigMissing = False
                            xPLDevices(x).WaitingConfig = False
                        End If
                    End If
            End Select
            Exit Sub
        End If

        ' create if new
        If x = -1 And (msgSchemaType = "BASIC" Or msgSchemaType = "APP") Then
            xPLDeviceCount = xPLDeviceCount + 1
            ReDim Preserve xPLDevices(xPLDeviceCount)
            x = xPLDeviceCount
            xPLDevices(x).VDI = msgSource.ToUpper
            xPLDevices(x).ConfigDone = False
            xPLDevices(x).ConfigMissing = True
            xPLDevices(x).ConfigSource = ""
            xPLDevices(x).ConfigType = False
            If msgSchemaClass = "CONFIG" Then xPLDevices(x).ConfigType = True
            xPLDevices(x).Suspended = False
            xPLDevices(x).WaitingConfig = False
            xPLDevices(x).Suspended = False
            If Dir(xPLHalVendorFiles & "\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml") <> "" Then
                xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
                xPLDevices(x).ConfigMissing = False
            Else
                If Dir(xPLHalVendorFiles & "\" & msgSourceVendor & "-" & msgSourceDevice & ".xml") <> "" Then
                    xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".xml"
                    xPLDevices(x).ConfigMissing = False
                End If
            End If
            xPLDevice.Add(msgSource, x)
            xPLDevices(x).Current = False
            xPLSendMsg("xpl-cmnd", msgSource, "CONFIG.LIST", "COMMAND=REQUEST")
            xPLSendMsg("xpl-cmnd", msgSource, "CONFIG.CURRENT", "COMMAND=REQUEST")
            RequestSent = True
        Else
            If msgSchemaType = "BASIC" Or msgSchemaType = "APP" Then
                If xPLDevices(x).Suspended = True Then
                    xPLSendMsg("xpl-cmnd", msgSource, "CONFIG.LIST", "COMMAND=REQUEST")
                    xPLSendMsg("xpl-cmnd", msgSource, "CONFIG.CURRENT", "COMMAND=REQUEST")
                    RequestSent = True
                End If
            End If
        End If
        If x = -1 Then Exit Sub ' no processing 

        ' process type
        Select Case msgSchemaClass
            Case "HBEAT"
                Select Case msgSchemaType
                    Case "BASIC", "APP"
                        xPLDevices(x).Interval = Val(e.GetParam(1, "interval"))
                        xPLDevices(x).Expires = DateAdd(DateInterval.Minute, (2 * xPLDevices(x).Interval) + 1, Now)
                        xPLDevices(x).ConfigType = False
                        xPLDevices(x).Suspended = False
                        xPLDevices(x).WaitingConfig = False
                        xPLDevices(x).ConfigDone = True
                        ' If xPLDevices(x).Current = False And RequestSent = False Then
                        '     xPLSendMsg("xpl-cmnd", msgSource, "CONFIG.LIST", "COMMAND=REQUEST")
                        '     xPLSendMsg("xpl-cmnd", msgSource, "CONFIG.CURRENT", "COMMAND=REQUEST")
                        ' End If
                    Case "END"
                        xPLDevices(x).Suspended = True
                        xPLDevices(x).ConfigDone = False
                        xPLDevices(x).ConfigMissing = False
                        xPLDevices(x).WaitingConfig = False
                        Call RunScript(GetScriptSub(xPLDevices(x).VDI + "_Terminated"), False, "")
                End Select
                Exit Sub
            Case "CONFIG"
                Select Case msgSchemaType
                    Case "LIST"
                        f = FreeFile()
                        FileOpen(f, xPLHalVendorFiles & "\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml", OpenMode.Output, OpenAccess.Write, OpenShare.Default)
                        Print(f, "<configuration>" & vbNewLine)
                        For y = 0 To e.XPL_Msg(1).DC
                            strType = e.XPL_Msg(1).Details(y).keyName.Trim
                            strValue = e.XPL_Msg(1).Details(y).Value.Trim
                            strNumber = "1"
                            z(0) = InStr(strValue, "[", CompareMethod.Binary)
                            z(1) = InStr(strValue, "]", CompareMethod.Binary)
                            If z(0) > 0 And z(1) > 0 Then
                                strNumber = strValue.Substring(z(0), z(1) - z(0) - 1)
                                strValue = Left(strValue, z(0) - 1).Trim
                            End If
                            If strNumber = "1" Then
                                Print(f, "  <configitem key=" & Chr(34) & strValue.ToLower & Chr(34) & " type=" & Chr(34) & strType.ToLower & Chr(34) & " />" & vbNewLine)
                            Else
                                Print(f, "  <configitem key=" & Chr(34) & strValue.ToLower & Chr(34) & " type=" & Chr(34) & strType.ToLower & Chr(34) & " number=" & Chr(34) & strNumber & Chr(34) & " />" & vbNewLine)
                            End If
                        Next
                        Print(f, "</configuration>" & vbNewLine)
                        FileClose(f)
                        xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
                        xPLDevices(x).ConfigMissing = False
                        Exit Sub
                    Case "BASIC", "APP"
                        xPLDevices(x).Interval = Val(e.GetParam(1, "interval"))
                        xPLDevices(x).Expires = DateAdd(DateInterval.Minute, (2 * xPLDevices(x).Interval) + 1, Now)
                        xPLDevices(x).Suspended = False
                        xPLDevices(x).ConfigDone = False
                        xPLDevices(x).ConfigType = True
                        If xPLDevices(x).Current = False And RequestSent = False Then
                            xPLSendMsg("xpl-cmnd", msgSource, "CONFIG.CURRENT", "COMMAND=REQUEST")
                        End If
                        If xPLDevices(x).ConfigMissing = True Then
                            If RequestSent = False Then
                                xPLSendMsg("xpl-cmnd", msgSource, "CONFIG.LIST", "COMMAND=REQUEST")
                                RequestSent = True
                            End If
                            xPLDevices(x).WaitingConfig = False
                            xPLDevices(x).ConfigMissing = True
                            xPLDevices(x).ConfigSource = ""
                            xPLDevices(x).ConfigDone = False
                            Exit Sub
                        End If
                    Case "CURRENT"
                        Dim strCurrent As String
                        strCurrent = ""
                        Dim strFilename As String
                        Dim fs As TextWriter
                        Dim c As Integer
                        For c = 0 To e.XPL_Msg(1).DC
                            strCurrent = strCurrent & e.XPL_Msg(1).Details(c).keyName & "=" & e.XPL_Msg(1).Details(c).Value & vbCrLf
                        Next c
                        If strCurrent = "" Then Exit Sub
                        strFilename = e.Source.Vendor & "-" & e.Source.Device & "_" & e.Source.Instance & ".cfg"
                        fs = File.CreateText(xPLHalConfigFiles & "\Current\" & strFilename)
                        fs.WriteLine(strCurrent)
                        fs.Close()
                        If Dir(xPLHalConfigFiles & "\" & strFilename) <> "" Then
                            fs = File.CreateText(xPLHalConfigFiles & "\" & strFilename)
                            fs.WriteLine(strCurrent)
                            fs.Close()
                        End If
                        xPLDevices(x).Current = True
                        Exit Sub
                    Case "END"
                        xPLDevices(x).Suspended = True
                        xPLDevices(x).ConfigDone = False
                        xPLDevices(x).ConfigMissing = False
                        xPLDevices(x).WaitingConfig = False
                        Call RunScript(GetScriptSub(xPLDevices(x).VDI + "_Terminated"), False, "")
                        Exit Sub
                    Case Else
                        Exit Sub
                End Select
        End Select

        ' check for existing config
        If Dir(xPLHalConfigFiles & "\" & msgSourceVendor & "-" & msgSourceDevice & "_" & msgSourceInstance & ".cfg") <> "" And msgSourceInstance.ToUpper <> "DEFAULT" Then
            ThisConf = msgSourceInstance
            While ThisConf <> ""
                f = FreeFile()
                FileOpen(f, xPLHalConfigFiles & "\" & msgSourceVendor & "-" & msgSourceDevice & "_" & ThisConf & ".cfg", OpenMode.Input, OpenAccess.Read, OpenShare.Default)
                strMsg = ""
                NextConf = ""
                While Not EOF(f)
                    strInput = LineInput(f)
                    If strInput <> "" Then
                        strMsg = strMsg + strInput + Chr(10)
                        p = InStr(1, strInput.ToUpper, "NEWCONF=", CompareMethod.Binary)
                        If p > 0 Then
                            NextConf = Mid(strInput, p + 8)
                        End If
                    End If
                End While
                FileClose(f)
                If NextConf <> "" And NextConf.ToUpper <> ThisConf.ToUpper Then
                    xPLDevice.Remove(msgSourceVendor.ToUpper & "-" & msgSourceDevice.ToUpper & "." & ThisConf.ToUpper)
                    Try
                        xPLDevice.Add(msgSourceVendor.ToUpper & "-" & msgSourceDevice.ToUpper & "." & NextConf.ToUpper, x)
                    Catch ex As Exception
                        xPLDevices(x).Suspended = True
                        xPLDevices(x).ConfigDone = False
                        xPLDevices(x).ConfigMissing = False
                        xPLDevices(x).WaitingConfig = False
                        x = xPLDevice(msgSourceVendor.ToUpper & "-" & msgSourceDevice.ToUpper & "." & NextConf.ToUpper)
                    End Try
                    xPLDevices(x).VDI = msgSourceVendor.ToUpper & "-" & msgSourceDevice.ToUpper & "." & NextConf.ToUpper
                    'Call xPLSendMsg("xpl-cmnd", msgSourceVendor.ToUpper & "-" & msgSourceDevice.ToUpper & "." & ThisConf.ToUpper, "config.response", strMsg)
                    ThisConf = NextConf
                Else
                    Call xPLSendMsg("xpl-cmnd", msgSourceVendor.ToUpper & "-" & msgSourceDevice.ToUpper & "." & msgSourceInstance.ToUpper, "config.response", strMsg)
                    ThisConf = ""
                End If
            End While
            xPLDevices(x).ConfigMissing = False
            xPLDevices(x).WaitingConfig = False
            xPLDevices(x).ConfigDone = True
            If Dir(xPLHalVendorFiles & "\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml") <> "" Then
                xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
            Else
                If Dir(xPLHalVendorFiles & "\" & msgSourceVendor & "-" & msgSourceDevice & ".xml") <> "" Then
                    xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".xml"
                Else
                    xPLDevices(x).ConfigSource = ""
                End If
                Exit Sub
            End If
            Exit Sub
        End If

        ' check if i have a cached options list
        If Dir(xPLHalVendorFiles & "\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml") <> "" Then
            ' flag as waiting
            xPLDevices(x).WaitingConfig = True
            xPLDevices(x).ConfigMissing = False
            xPLDevices(x).ConfigDone = False
            xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
            Exit Sub
        End If

        ' check if i have a vendor options list
        If Dir(xPLHalVendorFiles & "\" & msgSourceVendor & "-" & msgSourceDevice & ".xml") <> "" Then
            ' flag as waiting
            xPLDevices(x).WaitingConfig = True
            xPLDevices(x).ConfigMissing = False
            xPLDevices(x).ConfigDone = False
            xPLDevices(x).ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".xml"
            Exit Sub
        End If

        ' request a list of options
        If RequestSent = False Then
            xPLSendMsg("xpl-cmnd", msgSource, "CONFIG.LIST", "COMMAND=REQUEST")
        End If
        xPLSendMsg("xpl-cmnd", msgSource, "CONFIG.CURRENT", "COMMAND=REQUEST")
        xPLDevices(x).WaitingConfig = False
        xPLDevices(x).ConfigMissing = True
        xPLDevices(x).ConfigSource = ""
        xPLDevices(x).ConfigDone = False

    End Sub

    Public Sub ConfigSend(ByVal intDevice As Integer, ByVal strMsg As String)

        Dim fs As TextWriter
        Dim strFilename As String
        Dim strInstance As String
        Dim VDI As String
        Dim x As Integer
        Dim y As Integer
        'Dim z As Integer

        ' store base config
        VDI = xPLDevices(intDevice).VDI
        If Right$(strMsg, 2) <> vbCrLf Then strMsg = strMsg + vbCrLf
        strFilename = xPLDevices(intDevice).VDI.ToUpper
        x = InStr(strFilename, ".", CompareMethod.Binary)
        strFilename = Left(strFilename, x - 1) & "_" & Mid(strFilename, x + 1) & ".cfg"
        If Mid$(xPLDevices(intDevice).VDI.ToUpper, x + 1) <> "DEFAULT" Then
            fs = File.CreateText(xPLHalConfigFiles & "\" & strFilename)
            fs.WriteLine(strMsg)
            fs.Close()
        End If
        ' store for new instance, if found
        x = InStr(1, strMsg, "NEWCONF=", CompareMethod.Text)
        If x > 0 Then
            x = x + 8
            y = InStr(x, strMsg, vbCrLf, CompareMethod.Binary)
            If y > x + 1 Then
                strInstance = strMsg.Substring(x - 1, y - x).Trim
                x = InStr(xPLDevices(intDevice).VDI, ".", CompareMethod.Binary)
                VDI = Left(xPLDevices(intDevice).VDI, x) & strInstance
                x = InStr(strFilename, "_", CompareMethod.Binary)
                strFilename = Left(strFilename, x - 1) & "_" & strInstance & ".cfg"
                If strInstance.ToUpper <> "DEFAULT" Then
                    fs = File.CreateText(xPLHalConfigFiles & "\" & strFilename)
                    fs.WriteLine(strMsg)
                    fs.Close()
                Else
                    ' not allowed to newconf to DEFAULT
                    Exit Sub
                End If
            End If
        Else
            ' not allowed to send a config with no newconf=
            Exit Sub
        End If

        ' send config
        strMsg = Replace(strMsg, vbCrLf, Chr(10), 1, -1)
        Call xPLSendMsg("xpl-cmnd", xPLDevices(intDevice).VDI, "config.response", strMsg)
        xPLDevices(intDevice).ConfigMissing = False
        xPLDevices(intDevice).WaitingConfig = False
        xPLDevices(intDevice).ConfigDone = True

        ' update device
        If xPLDevices(intDevice).VDI.ToUpper <> VDI.ToUpper Then
            xPLDevice.Remove(xPLDevices(intDevice).VDI.ToUpper)
            If xPLDevice.ContainsKey(VDI.ToUpper) = True Then
                ' existing device
                xPLDevices(xPLDevice(VDI.ToUpper)).Suspended = True
                xPLDevice.Remove(VDI.ToUpper)
            End If
            xPLDevice.Add(VDI.ToUpper, intDevice)
            xPLDevices(intDevice).VDI = VDI.ToUpper
        End If

        ' send config.current request to new/existing instance
        xPLDevices(intDevice).Current = False
        Call xPLSendMsg("xpl-cmnd", xPLDevices(intDevice).VDI, "CONFIG.CURRENT", "COMMAND=REQUEST")

    End Sub

    Public Sub SaveDevices()

        ' save device states
        Dim xml As New Xml.XmlTextWriter(xPLHalData + "\xplhal_devices.xml", System.Text.Encoding.ASCII)
        Dim x As Integer

        xml.Formatting = Formatting.Indented
        xml.WriteStartDocument()
        xml.WriteStartElement("devices")
        For x = 0 To xPLDeviceCount
            If xPLDevices(x).Suspended = False Then
                ' save this device
                Try
                    xml.WriteStartElement("device")
                    xml.WriteAttributeString("vdi", xPLDevices(x).VDI)
                    xml.WriteAttributeString("interval", xPLDevices(x).Interval)
                    xml.WriteAttributeString("expires", xPLDevices(x).Expires)
                    xml.WriteAttributeString("configdone", xPLDevices(x).ConfigDone)
                    xml.WriteAttributeString("configmissing", xPLDevices(x).ConfigMissing)
                    xml.WriteAttributeString("configsource", xPLDevices(x).ConfigSource)
                    xml.WriteAttributeString("configtype", xPLDevices(x).ConfigType)
                    xml.WriteAttributeString("current", xPLDevices(x).Current)
                    xml.WriteAttributeString("waitingconfig", xPLDevices(x).WaitingConfig)
                    xml.WriteEndElement()
                Catch ex As Exception
                    Call WriteErrorLog("Error Writing Device " & xPLDevices(x).VDI & " to XML (" & Err.Description & ")")
                End Try
            End If
        Next
        For x = 0 To xPLDevCount
            If xPLDevs(x).Suspended = False Then
                ' save this device
                Try
                    If xPLDeviceCount > -1 Then
                        If xPLDevice.ContainsKey(xPLDevs(x).VDI) = False Then
                            xml.WriteStartElement("dev")
                            xml.WriteAttributeString("vdi", xPLDevs(x).VDI)
                            xml.WriteAttributeString("expires", xPLDevs(x).Expires)
                            xml.WriteEndElement()
                        End If
                    Else
                        xml.WriteStartElement("dev")
                        xml.WriteAttributeString("vdi", xPLDevs(x).VDI)
                        xml.WriteAttributeString("expires", xPLDevs(x).Expires)
                        xml.WriteEndElement()
                    End If
                Catch ex As Exception
                    Call WriteErrorLog("Error Writing Device List " & xPLDevs(x).VDI & " to XML (" & Err.Description & ")")
                End Try
            End If
        Next
        xml.WriteEndElement()
        xml.WriteEndDocument()
        xml.Flush()
        xml.Close()

    End Sub

    Public Sub LoadDevices()

        Dim x As Integer

        ' load devices
        xPLDevCount = -1
        xPLDeviceCount = -1
        ReDim xPLDevices(0)
        If Dir(xPLHalData & "\xplhal_devices.xml") <> "" Then
            ' got xml devices so load
            Try
                Dim xml As New Xml.XmlTextReader(xPLHalData & "\xplhal_devices.xml")
                While xml.Read()
                    Select Case xml.NodeType
                        Case XmlNodeType.Element
                            Select Case xml.Name
                                Case "device"
                                    xPLDeviceCount = xPLDeviceCount + 1
                                    x = xPLDeviceCount
                                    ReDim Preserve xPLDevices(x)
                                    xPLDevices(x).ConfigDone = xml.GetAttribute("configdone")
                                    xPLDevices(x).ConfigMissing = xml.GetAttribute("configmissing")
                                    xPLDevices(x).ConfigSource = xml.GetAttribute("configsource")
                                    xPLDevices(x).ConfigType = xml.GetAttribute("configtype")
                                    xPLDevices(x).Current = xml.GetAttribute("current")
                                    xPLDevices(x).Expires = xml.GetAttribute("expires")
                                    xPLDevices(x).Interval = xml.GetAttribute("interval")
                                    xPLDevices(x).VDI = xml.GetAttribute("vdi")
                                    xPLDevices(x).WaitingConfig = xml.GetAttribute("waitingconfig")
                                    xPLDevices(x).Suspended = False
                                    If xPLDevices(x).Expires < DateTime.Now().AddMinutes(xPLDevices(x).Interval + 2) Then
                                        xPLDevices(x).Expires = DateTime.Now().AddMinutes(xPLDevices(x).Interval + 2)
                                    End If
                                    xPLDevice.Add(xPLDevices(x).VDI, x)
                                    Call AddDeterminatorDevice(xPLDevices(x).VDI)
                                Case "dev"
                                    xPLDevCount = xPLDevCount + 1
                                    x = xPLDevCount
                                    ReDim Preserve xPLDevs(x)
                                    xPLDevs(x).Expires = xml.GetAttribute("expires")
                                    xPLDevs(x).VDI = xml.GetAttribute("vdi")
                                    xPLDevs(x).Suspended = False
                                    xPLDev.Add(xPLDevs(x).VDI, x)
                            End Select
                    End Select
                End While
                xml.Close()
            Catch ex As Exception
                Call WriteErrorLog("Error Reading Devices XML (" & Err.Description & ")")
                xPLDeviceCount = -1
                ReDim xPLDevices(0)
                Exit Sub
            End Try
        End If

    End Sub

    Public Sub AddDeterminatorDevice(ByVal Source As String)

        Dim x As Integer

        ' find device
        If Source = "" Then Exit Sub
        x = -1
        If xPLDevCount > -1 Then
            If xPLDev.ContainsKey(Source) = True Then
                x = xPLDev(Source)
            End If
        End If

        ' add new device
        If x = -1 Then
            xPLDevCount = xPLDevCount + 1
            ReDim Preserve xPLDevs(xPLDevCount)
            x = xPLDevCount
            xPLDevs(x).VDI = Source
            xPLDev.Add(Source, x)
        End If

        ' flag
        xPLDevs(x).Expires = DateTime.Now.AddDays(2)
        xPLDevs(x).Suspended = False

    End Sub

End Module
