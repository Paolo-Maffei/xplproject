Imports System.Runtime.InteropServices
Imports xPLLogging
Imports EventSystem
Imports GOCManager
Imports GOCManager.xPLCache
Imports DeterminatorEngine
Imports System.IO
Imports Scripts.ScriptLoader
Imports DeviceManager
Imports System.Text.RegularExpressions
Imports Scripts
Imports xpllib
Imports xPLEngine


Public Class HalObjects
    Implements IHalObjects

    Dim SingleEventData As SingleEventInfo
    Dim RecurringEventData As RecurringEventInfo
    <StructLayout(LayoutKind.Sequential)> _
    Public Structure SingleEventInfo
        Public [Date] As DateTime
        Public Tag As String
        Public SubName As String
        Public Parms As String
        Public Random As Integer
    End Structure

    <StructLayout(LayoutKind.Sequential)> _
    Public Structure RecurringEventInfo
        Public StartTime As DateTime
        Public EndTime As DateTime
        Public Tag As String
        Public SubName As String
        Public Parms As String
        Public Random As Integer
        Public DOW As String
        Public Interval As Integer
    End Structure

    <StructLayout(LayoutKind.Sequential)> _
    Public Structure XPLDeviceConfig
        Public Name As String
        Public Type As String
        Public Number As Integer
    End Structure

    <StructLayout(LayoutKind.Sequential)> _
    Public Structure XplHalSetting
        Public Value As String
        Public Name As String
        Public Description As String
    End Structure

    <StructLayout(LayoutKind.Sequential)> _
    Public Structure XplEvent
        Public Tag As String
        Public SubName As String
        Public Parms As String
        Public StartTime As DateTime
        Public EndTime As DateTime
        Public DOW As String
        Public RunTime As String
    End Structure

    <StructLayout(LayoutKind.Sequential)> _
    Public Structure XplSetting
        Public SubID As String
        Public Name As String
        Public Desc As String
        Public CurrentValue As String
        Public CurrentValueDesc As String
    End Structure

    <StructLayout(LayoutKind.Sequential)> _
    Public Structure XplSingleEvent
        Public Tag As String
        Public SubName As String
        Public Parms As String
        Public [Date] As DateTime
    End Structure

    <StructLayout(LayoutKind.Sequential)> _
    Public Structure XPLDevice
        Public Vdi As String
        Public Expires As String
        Public Interval As String
        Public Configtype As String
        Public Configdone As String
        Public Waitingconfig As String
        Public Suspended As String
    End Structure

    <StructLayout(LayoutKind.Sequential)> _
    Public Structure RuleGroup
        Public GroupGuid As String
        Public GroupName As String
    End Structure

    <StructLayout(LayoutKind.Sequential)> _
    Public Structure Rule
        Public RuleGuid As String
        Public RuleName As String
        Public Enabled As Boolean
    End Structure

    <StructLayout(LayoutKind.Sequential)> _
   Public Structure SubRoutine
        Public ScriptName As String
        Public FunctionName As String
        Public Parameters As String
    End Structure

    ''' <summary>Adds a recurring event.</summary>
    ''' <param name="eventdata">A <paramref name="eventdata"/>RecurringEventInfo object containing the event data.</param>
    ''' <returns>"True" if successful, "False" if an error occurred.</returns>
    ''' <remarks>Adds a recurring event.</remarks>
    Public Function AddRecurringEvent(ByVal eventdata As RecurringEventInfo) As Boolean Implements IHalObjects.AddRecurringEvent
        Return EventLauncher.Add(EventLauncher.BuildRecurringEvent(eventdata.StartTime, eventdata.EndTime, eventdata.Interval, eventdata.Random, eventdata.DOW, eventdata.SubName, eventdata.Parms, eventdata.Tag, True))
    End Function

    Public Function AddSingleEvent(ByVal eventdata As SingleEventInfo) As Boolean Implements IHalObjects.AddSingleEvent
        Return EventLauncher.Add(EventLauncher.BuildSingleEvent(eventdata.[Date], eventdata.SubName, eventdata.Parms, eventdata.Tag))
    End Function

    ''' <summary>Clears the XPLHal Error Log. This is not supported in this version of xPLHal.</summary>
    ''' <returns>null</returns>
    ''' <remarks>Clears the XPLHal Error Log.</remarks>
    Public Function ClearErrorLog() As Object Implements IHalObjects.ClearErrorLog
        'not implemented in xplHAL
        Return Nothing
    End Function

    Public Function DeleteDeviceConfig(ByVal vdi As String) As Object Implements IHalObjects.DeleteDeviceConfig
        Dim action As Boolean
        For Each entry As CacheEntry In xPLCache.ChildNodes("config." & vdi)
            xPLCache.Remove(entry.ObjectName)
            action = True
        Next
        Return action
    End Function

    Public Function DeleteEvent(ByVal tag As String) As Object Implements IHalObjects.DeleteEvent
        Dim eventEntry As EventSystem.xPLEvent = EventLauncher.GetEvent(tag.Trim)
        If eventEntry IsNot Nothing Then
            EventLauncher.Remove(tag)
            Return True
        Else
            Return False
        End If
    End Function

    Public Function DeleteGlobal(ByVal globalname As String) As Object Implements IHalObjects.DeleteGlobal
        Return xPLCache.Remove(globalname)
    End Function

    Public Function DeleteRule(ByVal ruleguid As String) As Object Implements IHalObjects.DeleteRule
        Return Determinator.DeleteRule(ruleguid, True)
    End Function

    Public Function DeleteScript(ByVal scriptname As String) As Object Implements IHalObjects.DeleteScript
        Dim filename As String = ScriptEngineFolder & "\" & scriptname
        If Not File.Exists(filename) Then
            Return False
        Else
            File.Delete(filename)
            Return True
        End If
    End Function

    Public Function GetDeviceConfig(ByVal vdi As String) As Object Implements IHalObjects.GetDeviceConfig
        vdi = vdi.ToLower()
        If Not DevManager.Contains(vdi) Then Return False

        Dim targetdevice As DeviceManager.xPLDevice = DevManager.GetDevice(vdi)
        If targetdevice.ConfigSource = "" Then Return False

        ' Read the config "file"
        Dim rgxConfig As New Regex("config\." & vdi & "\.options.([a-z0-9]{1,16})")
        Dim devlist As New List(Of XPLDeviceConfig)
        Dim devconf As XPLDeviceConfig = New XPLDeviceConfig()

        Dim strMsg As String = ""
        For Each entry As CacheEntry In xPLCache.FilterbyRegEx(rgxConfig)
            Dim nameparts As String() = rgxConfig.Split(entry.ObjectName)
            If nameparts.Length >= 2 Then
                If nameparts(2) = "" Then  'only interested in the root config option.
                    devconf.Name = nameparts(1)
                    devconf.Type = xPLCache.ObjectValue(entry.ObjectName & ".type")
                    devconf.Number = xPLCache.ObjectValue(entry.ObjectName & ".count")
                    devlist.Add(devconf)
                End If
            End If
        Next
        Return devlist
    End Function

    Public Function GetDeviceConfigValue(ByVal vdi As String, ByVal configitem As String) As Object Implements IHalObjects.GetDeviceConfigValue
        Dim entry = xPLCache.ObjectValue("config." & vdi & ".current." & configitem)
        If entry IsNot Nothing Then
            Return configitem.Trim & "=" & entry.Trim()
        End If
        Return Nothing
    End Function

    Public Function GetErrorLog() As Object Implements IHalObjects.GetErrorLog
        'not implemented in xplHAL
        Return Nothing
    End Function

    Public Function GetEvent(ByVal tag As String) As Object Implements IHalObjects.GetEvent
        Dim eventEntry As EventSystem.xPLEvent = EventLauncher.GetEvent(tag.Trim())

        If eventEntry IsNot Nothing Then
            With eventEntry
                If .Recurring Then
                    Dim newEvent As New XplEvent
                    'return recurring struct
                    newEvent.StartTime = .StartTime
                    newEvent.EndTime = .EndTime
                    newEvent.SubName = .RunSub
                    newEvent.Tag = .Tag
                    newEvent.RunTime = .EventRunTime
                    newEvent.DOW = .DoW
                    newEvent.Parms = .Param

                    Return newEvent
                Else
                    Dim newEvent As New XplSingleEvent
                    'return single struct
                    newEvent.Date = .EventDateTime
                    newEvent.SubName = .RunSub
                    newEvent.Tag = .Tag
                    newEvent.Parms = .Param

                    Return newEvent
                End If
            End With
        End If

        Return Nothing
    End Function

    Public Function GetGlobal(ByVal globalname As String) As Object Implements IHalObjects.GetGlobal
        If xPLCache.Contains(globalname) Then
            Return xPLCache.ObjectValue(globalname).ToString()
        Else
            Return Nothing
        End If
    End Function

    Public Function GetReplicationInfo() As Object Implements IHalObjects.GetReplicationInfo
        'not implemented
        Return Nothing
    End Function

    Public Function GetRule(ByVal ruleguid As String) As Object Implements IHalObjects.GetRule
        If File.Exists(DataFileFolder & "\Determinator\" & ruleguid & ".xml") Then
            Dim myfile As TextReader = File.OpenText(DataFileFolder & "\Determinator\" & ruleguid & ".xml")
            Dim str = myfile.ReadToEnd()
            While Not str Is Nothing
                Return str
            End While

            myfile.Close()
        End If

        Return Nothing
    End Function

    Public Function GetScript(ByVal scriptname As String) As Object Implements IHalObjects.GetScript
        scriptname = scriptname.ToLower()
        If ScriptLoader.xplScripts.Contains(scriptname) Then
            Dim script As ScriptDetail = ScriptLoader.xplScripts(scriptname)
            Return script.Source
        End If

        Return Nothing
    End Function

    Public Function GetSetting(ByVal setting As String) As Object Implements IHalObjects.GetSetting
        setting = "xplhal." & setting
        If Not xPLCache.Contains(setting) Then
            Return Nothing
        Else
            Return xPLCache.ObjectValue(setting).ToString()
        End If
    End Function

    Public Function ListDevices(ByVal options As String) As Object Implements IHalObjects.ListDevices
        Dim ShowDevice As Boolean
        Dim devlist As New List(Of XPLDevice)

        options = options.ToLower()
        For Each device In DevManager.AllDevices
            ShowDevice = True
            If options = "awaitingconfig" And Not device.ConfigType Then
                ShowDevice = False
            End If
            If options = "configured" And device.ConfigType Then
                ShowDevice = False
            End If

            If options = "missingconfig" And Not device.ConfigMissing Then
                ShowDevice = False
            End If

            If ShowDevice And Not device.Suspended Then
                Dim dev As New XPLDevice()
                With dev
                    .Vdi = device.VDI
                    .Expires = device.Expires
                    .Interval = device.Interval
                    .Configtype = device.ConfigType
                    .Configdone = device.ConfigDone
                    .Waitingconfig = device.WaitingConfig
                    .Suspended = device.Suspended
                End With
                devlist.Add(dev)
            End If
        Next

        Return devlist
    End Function

    Public Function ListEvents() As Object Implements IHalObjects.ListEvents
        Dim devlist As New List(Of XplEvent)

        For Each evententry As XplEvent In EventLauncher.ListAllEvents("recurring")
            With evententry
                Dim ev As New XplEvent()
                ev.StartTime = .StartTime
                ev.EndTime = .EndTime
                ev.SubName = .SubName
                ev.Parms = .Parms
                ev.StartTime = .StartTime
                ev.Tag = .Tag
                ev.DOW = .DOW
                ev.RunTime = .RunTime
                devlist.Add(ev)
            End With
        Next
        Return devlist
    End Function

    Public Function ListGlobals() As System.Collections.Generic.Dictionary(Of String, String) Implements IHalObjects.ListGlobals
        Return xPLCache.ListAllObjectsDictionary()
    End Function

    Public Function ListOptions(ByVal setting As String) As Object Implements IHalObjects.ListOptions
        'not implemented by xplHAL
        Return Nothing
    End Function

    Public Function ListRuleGroups() As Object Implements IHalObjects.ListRuleGroups
        Dim NestedLevel As Integer = 0
        Dim FoundGroup As Boolean
        Dim grouplist As New List(Of RuleGroup)

        Do
            FoundGroup = False
            For Each DetRule In Determinator.Rules
                If DetRule.IsGroup Then
                    If CharCount(DetRule.RuleName, "/") = NestedLevel Then
                        Dim rulegroup As New RuleGroup
                        rulegroup.GroupGuid = DetRule.RuleGUID
                        rulegroup.GroupName = DetRule.RuleName
                        grouplist.Add(rulegroup)
                        FoundGroup = True
                    End If
                End If
            Next
            NestedLevel += 1
        Loop Until Not FoundGroup

        Return grouplist
    End Function

    Public Function CharCount(ByVal s As String, ByVal charToFind As String) As Integer
        Dim i As Integer = 0
        For Counter As Integer = 0 To s.Length - 1
            If s.Substring(Counter, 1) = charToFind Then
                i += 1
            End If
        Next
        Return i
    End Function

    Public Function ListRules() As Object Implements IHalObjects.ListRules
        Return ListRules("")
    End Function

    Public Function ListRules(ByVal groupname As String) As Object Implements IHalObjects.ListRules
        Dim list As New List(Of Rule)

        If Not groupname = String.Empty Then
            groupname = groupname.Substring(groupname.IndexOf(" ") + 1, groupname.Length - groupname.IndexOf(" ") - 1)
        End If

        For Each Detrule In Determinator.Rules
            If Not Detrule.IsGroup Then
                If groupname = "{ALL}" Or Detrule.GroupName = groupname Then
                    Dim rule As New Rule
                    rule.RuleGuid = Detrule.RuleGUID
                    rule.RuleName = Detrule.RuleName
                    rule.Enabled = Detrule.Enabled
                    list.Add(rule)
                End If
            End If
        Next

        Return list
    End Function


    Public Function ListScripts() As Object Implements IHalObjects.ListScripts
        Return ListScripts("")
    End Function

    Public Function ListScripts(ByVal path As String) As Object Implements IHalObjects.ListScripts
        'check this. will not work!

        Dim list As New List(Of String)
        For Each xscript As ScriptLoader.ScriptDetail In ScriptLoader.xplScripts
            list.Add(xscript.ScriptName)
        Next

        Return list
    End Function

    Public Function ListSettings() As Object Implements IHalObjects.ListSettings
        Dim list As New List(Of XplSetting)

        For Each setting As CacheEntry In xPLCache.Filtered("xplhal.")
            Dim xs As New XplSetting
            xs.SubID = "unknown"
            xs.Name = "unknown"
            xs.Desc = "unknown"
            xs.CurrentValueDesc = setting.ObjectName
            xs.CurrentValue = setting.ObjectValue
            list.Add(xs)
        Next

        Return list
    End Function

    Public Function ListSingleEvents() As Object Implements IHalObjects.ListSingleEvents
        Dim list As New List(Of SingleEventInfo)

        For Each evententry As EventSystem.xPLEvent In EventLauncher.ListAllEvents("single")
            With evententry
                Dim sei = New SingleEventInfo
                sei.Date = .EventDateTime
                sei.SubName = .RunSub
                sei.Tag = .Tag
                sei.Parms = .Param
                list.Add(sei)
            End With
        Next

        Return list
    End Function


    Public Function ListSubs() As Object Implements IHalObjects.ListSubs
        Return ListSubs("")
    End Function

    Public Function ListSubs(ByVal path As String) As Object Implements IHalObjects.ListSubs
        Dim list As New List(Of SubRoutine)

        For Each xscript As ScriptLoader.ScriptDetail In ScriptLoader.xplScripts
            If xscript.SourceFile.Substring(ScriptEngineFolder.Length).StartsWith(path) Then
                If Not xscript.Functions Is Nothing Then
                    For Each xfunc As KeyValuePair(Of String, String) In xscript.Functions
                        Dim sr As New SubRoutine()
                        sr.ScriptName = xscript.ScriptName
                        sr.FunctionName = xfunc.Key
                        sr.Parameters = xfunc.Value
                        list.Add(sr)
                    Next
                Else

                End If
            End If
        Next

        Return list
    End Function

    Public Function PutScript(ByVal scriptname As String, ByVal script As String) As Object Implements IHalObjects.PutScript
        Try
            'if backup is enabled, make backup of previous version..
            If xPLCache.Contains("xplhal.backupscript") Then
                If xPLCache.ObjectValue("xplhal.backupscript") = "1" Then
                    'if target script exists, backup it first..
                    If RenameOldScriptIfExists(ScriptEngineFolder & "\" & scriptname) Then
                        Logger.AddLogEntry(LogLevel.AppInfo, "xhcp", "Renamed existing script and created a new script called " & scriptname)
                    Else
                        Logger.AddLogEntry(LogLevel.AppInfo, "xhcp", "Create a new Script called: " & scriptname)
                    End If
                End If
            End If

            'if target script exists, backup it first..
            If RenameOldScriptIfExists(ScriptEngineFolder & "\" & scriptname) Then
                Logger.AddLogEntry(LogLevel.AppInfo, "xhcp", "Renamed existing script and created a new script called " & scriptname)
            Else
                Logger.AddLogEntry(LogLevel.AppInfo, "xhcp", "Create a new Script called: " & scriptname)
            End If

            Dim fs As TextWriter
            fs = File.CreateText(ScriptEngineFolder & "\" & scriptname)
            fs.Write(script)
            fs.Close()

            Return True
        Catch ex As Exception
            Logger.AddLogEntry(LogLevel.AppError, "xhcp", "Failed to store new script.")
            Logger.AddLogEntry(LogLevel.AppError, "xhcp", "Cause: " & ex.ToString)
            Return False
        End Try
    End Function

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <exclude/>
    ''' <param name="filename"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function RenameOldScriptIfExists(ByVal filename As String) As Boolean
        If Not File.Exists(filename) Then Return False
        Dim i As Integer = 1

        'rename .ps1 to ps1.x.bak
        Do
            If Not File.Exists(filename & "." & i.ToString() & ".bak") Then
                File.Move(filename, filename & "." & i.ToString() & ".bak")
                Return True
            Else
                i += 1
            End If
        Loop
    End Function


    'Public Function ReloadScripts() As Boolean Implements IHalObjects.ReloadScripts
    '    'Return InitScriptEngine()
    'End Function

    Public Function RunRule(ByVal ruleguid As String) As Object Implements IHalObjects.RunRule
        ruleguid = ruleguid.Substring(7, ruleguid.Length - 7).Trim()
        Determinator.ExecuteRule(ruleguid)
        Return True
    End Function

    Public Function RunSub(ByVal scriptname As String, ByVal param As String) As Object Implements IHalObjects.RunSub
        Return RunScript(scriptname, param)
    End Function

    Public Function SendXplMsg(ByVal t As String, ByVal target As String, ByVal body As String) As Object Implements IHalObjects.SendXplMsg
        Return SendXplMsg(t, target, Nothing, body)
    End Function

    Public Function SendXplMsg(ByVal t As String, ByVal target As String, ByVal schema As String, ByVal body As String) As Object Implements IHalObjects.SendXplMsg
        'needs work
        Dim str As String = t & vbLf & "{" & vbLf
        str &= "hop=1" & vbLf & "source=" & xPLHandler.MySourceTag & vbLf
        str &= "target=" & target & vbLf & "}" & vbLf & schema & vbLf & "{" & vbLf & body & vbLf & "}" & vbLf
        Dim msg As New xpllib.XplMsg(str)

        msg.Send()
       
        Return Nothing
    End Function

    Public Function SetGlobal(ByVal key As String, ByVal value As String) As Object Implements IHalObjects.SetGlobal
        If Not xPLCache.Contains(key) Then
            xPLCache.Add(key, value, False)
            Return True
        Else
            xPLCache.ObjectValue(key) = value
            Return False
        End If
    End Function

    Public Function SetRule(ByVal ruleguid As String, ByVal xml As String) As Object Implements IHalObjects.SetRule
        If ruleguid = "" Then
            ruleguid = System.Guid.NewGuid.ToString.Replace("-", "")
        End If
        Try
            Logger.AddLogEntry(LogLevel.AppInfo, "xhcp", "Create a new Determinator called: " & ruleguid)
            Dim fs As TextWriter = File.CreateText(DataFileFolder & "\Determinator\" & ruleguid & ".xml")
            fs.Write(xml)
            fs.Close()
            Determinator.LoadRule(ruleguid)
            Return True
        Catch ex As Exception
            Logger.AddLogEntry(LogLevel.AppError, "xhcp", "Error creating determinator: " & ruleguid)
            Logger.AddLogEntry(LogLevel.AppError, "xhcp", "Cause: " & ex.ToString)
            Try
                Logger.AddLogEntry(LogLevel.AppError, "xhcp", "Trying to delete temporary file")
                File.Delete(DataFileFolder & "\Determinator\" & ruleguid & ".xml")
            Catch ex2 As Exception
                Logger.AddLogEntry(LogLevel.AppError, "xhcp", "Failed to delete temporary determinator file. ")
                Logger.AddLogEntry(LogLevel.AppError, "xhcp", "Cause: " & ex.ToString)
            End Try
        End Try
        Return False
    End Function

    Public Function SetSetting(ByVal settingname As String, ByVal settingvalue As String) As Object Implements IHalObjects.SetSetting
        settingname = "xplhal." & settingname
        If Not xPLCache.Contains(settingname) Then
            Return False
        Else
            settingvalue = settingvalue.Substring(10, settingvalue.Length - 10)
            settingvalue = settingvalue.Substring(settingname.Length + 1, settingvalue.Length - settingname.Length - 1)
            xPLCache.ObjectValue(settingname) = settingvalue
            Logger.AddLogEntry(LogLevel.AppInfo, "xhcp", "Set Global Cache Entry:" & settingname & " to: " & settingvalue)
        End If

        Return True
    End Function
End Class
