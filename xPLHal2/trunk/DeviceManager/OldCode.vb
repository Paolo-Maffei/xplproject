'Private Shared filestore As String
'Private Shared xPLDeviceStore As New Collection
'Public Shared DataFileFolder As String
'Public Shared ConfigFileFolder As String
'Public Shared vendorFileFolder As String

'' function to check for vendor file
'Public Shared Function CheckVendor(ByVal devtag As String) As Boolean
'    If Contains(devtag.ToLower) Then
'        Dim DeviceToCheck = xPLDeviceStore(devtag)
'        If Dir(vendorFileFolder & "\" & DeviceToCheck.ConfigSource) <> "" Then
'            Return True
'        Else
'            If DeviceToCheck.ConfigMissing Then
'                Return False
'            Else
'                DeviceToCheck.ConfigSource = ""
'                DeviceToCheck.ConfigMissing = True
'                Try
'                    RaiseEvent SendxPLConfigRequest(devtag)
'                Catch ex As Exception

'                End Try
'                Return False
'            End If
'        End If
'    Else
'        Return False
'    End If
'End Function

'Public Shared Sub LoadDevices()
'    filestore = DataFileFolder & "\xplhal_devices.xml"
'    If Dir(filestore) <> "" Then
'        ' got xml devices so load
'        Try
'            Dim xml As New Xml.XmlTextReader(filestore)
'            While xml.Read()
'                Select Case xml.NodeType
'                    Case XmlNodeType.Element
'                        Select Case xml.Name
'                            Case "device"
'                                Dim newdevice As New xPLDevice
'                                With newdevice
'                                    .ConfigDone = xml.GetAttribute("configdone")
'                                    .ConfigMissing = xml.GetAttribute("configmissing")
'                                    .ConfigSource = xml.GetAttribute("configsource")
'                                    .ConfigType = xml.GetAttribute("configtype")
'                                    .Current = xml.GetAttribute("current")
'                                    .Expires = xml.GetAttribute("expires")
'                                    .Interval = xml.GetAttribute("interval")
'                                    .VDI = xml.GetAttribute("vdi")
'                                    .WaitingConfig = xml.GetAttribute("waitingconfig")
'                                    .ConfigListSent = xml.GetAttribute("ConfigListSent")
'                                    .Suspended = False
'                                    If .Expires < DateTime.Now().AddMinutes(.Interval + 2) Then
'                                        .Expires = DateTime.Now().AddMinutes(.Interval + 2)
'                                    End If
'                                End With
'                                Add(newdevice)
'                        End Select
'                End Select
'            End While
'            xml.Close()
'        Catch ex As Exception
'            Logger.AddLogEntry(AppError, "devman", "Error Reading Devices XML.")
'            Logger.AddLogEntry(AppError, "devman", "Cause: " & ex.Message)
'            Exit Sub
'        End Try
'    Else
'        Logger.AddLogEntry(AppError, "devman", "Devices File not found. Creating new one at: " & filestore)
'        Dim newDeviceStore As New XDocument
'        newDeviceStore.Add(<devices>
'                           </devices>)
'        newDeviceStore.Save(filestore)
'    End If

'End Sub

'Public Shared Sub SaveDevices()
'    Dim xmlOutput = New XElement("devices")
'    For Each device As xPLDevice In AllDevices()
'        If Not device.Suspended Then
'            ' save this device
'            With device
'                xmlOutput.Add(<device
'                                  vdi=<%= .VDI %>
'                                  interval=<%= .Interval %>
'                                  expires=<%= .Expires %>
'                                  configdone=<%= .ConfigDone %>
'                                  configmissing=<%= .ConfigMissing %>
'                                  configsource=<%= .ConfigSource %>
'                                  configtype=<%= .ConfigType %>
'                                  current=<%= .Current %>
'                                  waitingconfig=<%= .WaitingConfig %>
'                                  ConfigListSent=<%= .ConfigListSent %>
'                              />)
'            End With
'        End If
'    Next

'    ' save device states
'    Try
'        xmlOutput.Save(filestore)
'    Catch ex As Exception
'        Logger.AddLogEntry(AppError, "devman", "Error Writing Device List to XML.")
'        Logger.AddLogEntry(AppError, "devman", "Cause: " & ex.Message)
'    End Try
'End Sub

'Public Shared Sub ConfigSend(ByVal devtag As String, ByVal strMsg As String)

'    Dim fs As TextWriter
'    Dim strFilename As String
'    Dim strInstance As String
'    Dim VDI As String
'    Dim x As Integer
'    Dim y As Integer
'    Dim targetdevice As xPLDevice = DevManager.GetDevice(devtag)
'    'Dim z As Integer

'    ' store base config
'    VDI = targetdevice.VDI
'    If Right$(strMsg, 2) <> vbCrLf Then strMsg = strMsg + vbCrLf
'    strFilename = targetdevice.VDI
'    x = InStr(strFilename, ".", CompareMethod.Binary)
'    strFilename = Left(strFilename, x - 1) & "_" & Mid(strFilename, x + 1) & ".cfg"

'    If Mid$(targetdevice.VDI, x + 1) <> "default" Then
'        fs = File.CreateText(ConfigFileFolder & "\" & strFilename)
'        fs.WriteLine(strMsg)
'        fs.Close()
'    End If
'    ' store for new instance, if found
'    x = InStr(1, strMsg, "newconf=", CompareMethod.Text)
'    If x > 0 Then
'        x = x + 8
'        y = InStr(x, strMsg, vbCrLf, CompareMethod.Binary)
'        If y > x + 1 Then
'            strInstance = strMsg.Substring(x - 1, y - x).Trim
'            x = InStr(targetdevice.VDI, ".", CompareMethod.Binary)
'            VDI = Left(targetdevice.VDI, x) & strInstance
'            x = InStr(strFilename, "_", CompareMethod.Binary)
'            strFilename = Left(strFilename, x - 1) & "_" & strInstance & ".cfg"
'            If strInstance <> "default" Then
'                fs = File.CreateText(ConfigFileFolder & "\" & strFilename)
'                fs.WriteLine(strMsg)
'                fs.Close()
'            Else
'                ' not allowed to newconf to DEFAULT
'                Exit Sub
'            End If
'        End If
'    Else
'        ' not allowed to send a config with no newconf=
'        Exit Sub
'    End If

'    ' send config
'    strMsg = Replace(strMsg, vbCrLf, Chr(10), 1, -1)
'    RaiseEvent SendxPLMessage("xpl-cmnd", targetdevice.VDI, "config.response", strMsg)
'    targetdevice.ConfigMissing = False
'    targetdevice.WaitingConfig = False
'    targetdevice.ConfigDone = True

'    ' update device
'    If targetdevice.VDI <> VDI Then
'        DevManager.Remove(targetdevice.VDI)
'        If DevManager.Contains(VDI) = True Then
'            ' existing device
'            targetdevice.Suspended = True
'            DevManager.Remove(VDI)
'        End If

'        'DODGY DODGY DODGY - not sure what this is doing. it may break.
'        DevManager.Add(targetdevice)

'        targetdevice.VDI = VDI
'    End If

'    ' send config.current request to new/existing instance
'    targetdevice.Current = False
'    RaiseEvent SendxPLMessage("xpl-cmnd", targetdevice.VDI, "config.current", "command=request")

'End Sub

'Public Shared Sub OldProcessConfigs(ByVal msgSource As String, ByVal e As xpllib.XplMsg)
'    Dim f As Integer
'    Dim z(1) As Integer
'    Dim strType As String
'    Dim strValue As String
'    Dim strNumber As String

'    Dim msgSourceVendor As String = e.SourceVendor
'    Dim msgSourceDevice As String = e.SourceDevice
'    Dim msgSourceInstance As String = e.SourceInstance
'    Dim msgType As String = e.MsgTypeString
'    Dim msgSchemaClass As String = e.Class
'    Dim msgSchemaType As String = e.Type


'    ' check if device exists
'    If DevManager.Contains(msgSource) Then
'        Dim targetdevice As xPLDevice = DevManager.GetDevice(msgSource)
'        Select Case msgSchemaType.ToLower
'            Case "basic", "app"
'                targetdevice.Interval = Val(e.GetKeyValue("interval"))
'                targetdevice.Expires = DateAdd(DateInterval.Minute, (2 * targetdevice.Interval) + 1, Now)
'                targetdevice.Suspended = False
'                targetdevice.ConfigDone = False
'                targetdevice.ConfigType = True
'                If targetdevice.Current = False And targetdevice.ConfigListSent = False Then
'                    Try
'                        RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.current", "command=request")
'                        targetdevice.ConfigListSent = True
'                    Catch ex As Exception

'                    End Try
'                End If

'                'We didn't get a config list from this app - ask it again.
'                If targetdevice.ConfigMissing = True Then
'                    Try
'                        RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.list", "command=request")
'                    Catch ex As Exception

'                    End Try
'                    targetdevice.WaitingConfig = False
'                    targetdevice.ConfigMissing = True
'                    targetdevice.ConfigSource = ""
'                    targetdevice.ConfigDone = False
'                End If

'                'Device is back from a suspend - has it's config changed?
'                If targetdevice.Suspended = True Then
'                    Try
'                        RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.list", "command=request")
'                        RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.current", "command=request")
'                        targetdevice.ConfigListSent = True
'                    Catch ex As Exception

'                    End Try
'                End If

'            Case "end"
'                Remove(msgSource)

'            Case "current"
'                Dim strCurrent As String
'                strCurrent = ""
'                Dim strFilename As String
'                Dim fs As TextWriter
'                Dim msgContents = e.KeyValues
'                For Each entry In msgContents
'                    strCurrent = strCurrent & entry.Key & "=" & entry.Value & vbCrLf
'                Next
'                If strCurrent = "" Then Exit Sub
'                strFilename = e.SourceTag & ".cfg"
'                fs = File.CreateText(ConfigFileFolder & "\Current\" & strFilename)
'                fs.WriteLine(strCurrent)
'                fs.Close()
'                If Dir(ConfigFileFolder & "\" & strFilename) <> "" Then
'                    fs = File.CreateText(ConfigFileFolder & "\" & strFilename)
'                    fs.WriteLine(strCurrent)
'                    fs.Close()
'                End If
'                targetdevice.Current = True

'            Case "list"
'                f = FreeFile()
'                FileOpen(f, vendorFileFolder & "\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml", OpenMode.Output, OpenAccess.Write, OpenShare.Default)
'                Print(f, "<configuration>" & vbNewLine)
'                Dim msgContents = e.KeyValues
'                For Each entry In msgContents
'                    strType = entry.Key.Trim
'                    strValue = entry.Value.Trim
'                    strNumber = "1"
'                    z(0) = InStr(strValue, "[", CompareMethod.Binary)
'                    z(1) = InStr(strValue, "]", CompareMethod.Binary)
'                    If z(0) > 0 And z(1) > 0 Then
'                        strNumber = strValue.Substring(z(0), z(1) - z(0) - 1)
'                        strValue = Left(strValue, z(0) - 1).Trim
'                    End If
'                    If strNumber = "1" Then
'                        Print(f, "  <configitem key=" & Chr(34) & strValue.ToLower & Chr(34) & " type=" & Chr(34) & strType.ToLower & Chr(34) & " />" & vbNewLine)
'                    Else
'                        Print(f, "  <configitem key=" & Chr(34) & strValue.ToLower & Chr(34) & " type=" & Chr(34) & strType.ToLower & Chr(34) & " number=" & Chr(34) & strNumber & Chr(34) & " />" & vbNewLine)
'                    End If
'                Next
'                Print(f, "</configuration>" & vbNewLine)
'                FileClose(f)
'                targetdevice.ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
'                targetdevice.ConfigMissing = False
'        End Select
'    Else
'        'new device... 
'        Dim targetdevice As xPLDevice = New xPLDevice
'        With targetdevice
'            .VDI = msgSource
'            .ConfigDone = False
'            .ConfigMissing = True
'            .ConfigSource = ""
'            .ConfigType = False
'            If msgSchemaClass = "config" Then
'                .ConfigType = True
'            End If
'            .Suspended = False
'            .WaitingConfig = False
'            .Suspended = False
'            If Dir(vendorFileFolder & "\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml") <> "" Then
'                .ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
'                .ConfigMissing = False
'            Else
'                If Dir(vendorFileFolder & "\" & msgSourceVendor & "-" & msgSourceDevice & ".xml") <> "" Then
'                    .ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".xml"
'                    .ConfigMissing = False
'                End If
'            End If
'            .Current = False
'        End With
'        DevManager.Add(targetdevice)

'        Try
'            RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.list", "command=request")
'            RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.current", "command=request")
'            targetdevice.ConfigListSent = True
'        Catch ex As Exception

'        End Try


'    End If

'End Sub

'Private Shared Sub CheckConfigFiles(ByVal _device As xPLDevice, ByVal e As xpllib.XplMsg)
'    Dim strInput As String
'    Dim strMsg As String
'    Dim ThisConf As String
'    Dim NextConf As String
'    Dim msgSourceVendor As String = e.SourceVendor
'    Dim msgSourceDevice As String = e.SourceDevice
'    Dim msgSourceInstance As String = e.SourceInstance
'    Dim msgType As String = e.MsgTypeString
'    Dim msgSchemaClass As String = e.Class
'    Dim msgSchemaType As String = e.Type

'    ' check for existing config
'    If Dir(ConfigFileFolder & "\" & _device.VDI & ".cfg") <> "" And msgSourceInstance <> "default" Then
'        ThisConf = msgSourceInstance
'        While ThisConf <> ""
'            Dim f As Integer = FreeFile()
'            FileOpen(f, ConfigFileFolder & "\" & _device.VDI & ".cfg", OpenMode.Input, OpenAccess.Read, OpenShare.Default)
'            strMsg = ""
'            NextConf = ""
'            While Not EOF(f)
'                strInput = LineInput(f)
'                If strInput <> "" Then
'                    strMsg = strMsg + strInput + Chr(10)
'                    Dim p As Integer = InStr(1, strInput, "newconf=", CompareMethod.Binary)
'                    If p > 0 Then
'                        NextConf = Mid(strInput, p + 8)
'                    End If
'                End If
'            End While
'            FileClose(f)
'            If NextConf <> "" And NextConf <> ThisConf Then
'                DevManager.Remove(msgSourceVendor & "-" & msgSourceDevice & "." & ThisConf)
'                Try
'                    ' xPLDevice.Add(msgSourceVendor & "-" & msgSourceDevice & "." & NextConf, x)
'                    'DODGY DODGY DODGY. No *IDEA* what this is trying to do.

'                Catch ex As Exception
'                    _device.Suspended = True
'                    _device.ConfigDone = False
'                    _device.ConfigMissing = False
'                    _device.WaitingConfig = False
'                End Try
'                _device.VDI = msgSourceVendor & "-" & msgSourceDevice & "." & NextConf

'                Try
'                    'uncommented this - not sure what it's doing?
'                    RaiseEvent SendxPLMessage("xpl-cmnd", msgSourceVendor & "-" & msgSourceDevice & "." & ThisConf, "config.response", strMsg)
'                Catch ex As Exception

'                End Try
'                ThisConf = NextConf
'            Else
'                Try
'                    RaiseEvent SendxPLMessage("xpl-cmnd", msgSourceVendor & "-" & msgSourceDevice & "." & msgSourceInstance, "config.response", strMsg)
'                    ThisConf = ""
'                Catch ex As Exception

'                End Try
'            End If
'        End While

'        _device.ConfigMissing = False
'        _device.WaitingConfig = False
'        _device.ConfigDone = True
'        If Dir(vendorFileFolder & "\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml") <> "" Then
'            _device.ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
'        Else
'            If Dir(vendorFileFolder & "\" & msgSourceVendor & "-" & msgSourceDevice & ".xml") <> "" Then
'                _device.ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".xml"
'            Else
'                _device.ConfigSource = ""
'            End If
'            Exit Sub
'        End If
'        Exit Sub
'    End If

'    ' check if i have a cached options list
'    If Dir(vendorFileFolder & "\" & msgSourceVendor & "-" & msgSourceDevice & ".cache.xml") <> "" Then
'        ' flag as waiting
'        _device.WaitingConfig = True
'        _device.ConfigMissing = False
'        _device.ConfigDone = False
'        _device.ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".cache.xml"
'        Exit Sub
'    End If

'    ' check if i have a vendor options list
'    If Dir(vendorFileFolder & "\" & msgSourceVendor & "-" & msgSourceDevice & ".xml") <> "" Then
'        ' flag as waiting
'        _device.WaitingConfig = True
'        _device.ConfigMissing = False
'        _device.ConfigDone = False
'        _device.ConfigSource = msgSourceVendor & "-" & msgSourceDevice & ".xml"
'        Exit Sub
'    End If


'    'This seems redundant - let's chop it and see what happens...
'    '' request a list of options
'    'If ConfigListSent = False Then
'    '    RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.list", "command=request")
'    'End If
'    'RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.current", "command=request")
'    '_device.WaitingConfig = False
'    '_device.ConfigMissing = True
'    '_device.ConfigSource = ""
'    '_device.ConfigDone = False
'End Sub