'**************************************
'* xPL Device Manager
'*
'* Version 2.2
'*
'* Copyright (C) 2009 Ian Lowe
'* http://www.xplhal.org/
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

Imports xPLLogging
Imports xPLLogging.LogLevel
Imports System.Xml
Imports System.Xml.Linq
Imports GOCManager
Imports System.IO
Imports GOCManager.xPLCache
Imports System.Text.RegularExpressions

Public Class xPLDevice
    Private devVDI As String = ""                   ' vendor / device / instance = unique id
    Private devExpires As Date                      ' time expires
    Private devInterval As Integer = 5              ' current heartbeat interval
    Private devConfigType As Boolean = False        ' true = config. false = hbeat.
    Private devConfigDone As Boolean = False        ' false = new waiting check, true = sent/not required
    Private devWaitingConfig As Boolean = False     ' false = waiting check or not needed, true = manual intervention
    Private devConfigListSent As Boolean = False       ' Have we asked this device for it's config?
    Private devConfigSource As String = ""          ' v-d.xml / v-d.cache.xml or empty
    Private devConfigMissing As Boolean = False     ' true = no config file, no response from device, false = have/waiting config
    Private devSuspended As Boolean = False         ' lost heartbeat
    Private devCurrent As Boolean = False           ' asked for current

    Property VDI() As String
        Get
            VDI = devVDI
        End Get
        Set(ByVal value As String)
            devVDI = value
        End Set
    End Property

    Property Expires() As Date
        Get
            Expires = devExpires
        End Get
        Set(ByVal value As Date)
            devExpires = value
        End Set
    End Property

    Property Interval() As Integer
        Get
            Interval = devInterval
        End Get
        Set(ByVal value As Integer)
            devInterval = value
        End Set
    End Property

    Property ConfigType() As Boolean
        Get
            ConfigType = devConfigType
        End Get
        Set(ByVal value As Boolean)
            devConfigType = value
        End Set
    End Property

    Property ConfigDone() As Boolean
        Get
            ConfigDone = devConfigDone
        End Get
        Set(ByVal value As Boolean)
            devConfigDone = value
        End Set
    End Property

    Property WaitingConfig() As Boolean
        Get
            ConfigMissing = devConfigMissing
        End Get
        Set(ByVal value As Boolean)
            devConfigMissing = value
        End Set
    End Property

    Property ConfigSource() As String
        Get
            ConfigSource = devConfigSource
        End Get
        Set(ByVal value As String)
            devConfigSource = value
        End Set
    End Property

    Property ConfigMissing() As Boolean
        Get
            ConfigMissing = devConfigMissing
        End Get
        Set(ByVal value As Boolean)
            devConfigMissing = value
        End Set
    End Property

    Property ConfigListSent() As Boolean
        Get
            ConfigListSent = devConfigListSent
        End Get
        Set(ByVal value As Boolean)
            devConfigListSent = value
        End Set
    End Property

    Property Suspended() As Boolean
        Get
            Suspended = devSuspended
        End Get
        Set(ByVal value As Boolean)
            devSuspended = value
        End Set
    End Property

    Property Current() As Boolean
        Get
            Current = devCurrent
        End Get
        Set(ByVal value As Boolean)
            devCurrent = value
        End Set
    End Property

End Class

Public Class DevManager
    Private Shared GOC As xPLCache

    Public Shared xPLConfigDisabled As Boolean = True

    Public Shared Event SendxPLConfigRequest(ByVal _devtag As String)
    Public Shared Event SendxPLMessage(ByVal _msgtype As String, ByVal _sourcetag As String, ByVal _msgclass As String, ByVal _msgbody As String)

    Public Shared Function Version() As String
        Return System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
    End Function

    Public Shared Sub Add(ByVal dev As xPLDevice)
        If Contains(dev.VDI) Then
            Update(dev)
        Else
            Dim newtag As String = "device." & dev.VDI & "."
            xPLCache.Add(newtag & "vdi", dev.VDI, False)
            xPLCache.Add(newtag & "configdone", dev.ConfigDone, False)
            xPLCache.Add(newtag & "configmissing", dev.ConfigMissing, False)
            xPLCache.Add(newtag & "configsource", dev.ConfigSource, False)
            xPLCache.Add(newtag & "configtype", dev.ConfigType, False)
            xPLCache.Add(newtag & "waitingconfig", dev.WaitingConfig, False)
            xPLCache.Add(newtag & "current", dev.Current, False)
            xPLCache.Add(newtag & "configlistsent", dev.ConfigListSent, False)
            xPLCache.Add(newtag & "suspended", dev.Suspended, False)
            xPLCache.Add(newtag & "interval", dev.Interval.ToString, False)
            xPLCache.Add(newtag & "expires", DateAdd(DateInterval.Minute, (2 * dev.Interval) + 1, Now).ToString, False)
        End If
    End Sub


    Public Shared Function RemoveConfig(ByVal devtag As String) As Boolean
        If ContainsConfig(devtag) And devtag <> "" Then
            For Each entry As CacheEntry In xPLCache.ChildNodes("config." & devtag)
                xPLCache.Remove(entry.ObjectName)
            Next
            RemoveConfig = True
        Else
            RemoveConfig = False
        End If
    End Function

    Public Shared Function Remove(ByVal devtag As String) As Boolean
        If Contains(devtag) And devtag <> "" Then
            For Each entry As CacheEntry In xPLCache.ChildNodes("device." & devtag)
                xPLCache.Remove(entry.ObjectName)
            Next
            Remove = True
        Else
            Remove = False
        End If
    End Function

    Public Shared Function Contains(ByVal devtag As String) As Boolean
        Return (xPLCache.ChildNodes("device." & devtag).Count > 0)
    End Function

    Public Shared Function ContainsConfig(ByVal devtag As String) As Boolean
        Return (xPLCache.ChildNodes("config." & devtag).Count > 0)
    End Function

    Public Shared Sub Update(ByVal dev As xPLDevice)
        If Contains(dev.VDI) Then
            Remove(dev.VDI)
        End If
        Dim newDevice As xPLDevice = dev
        Add(newDevice)
    End Sub

    Public Shared Sub Suspend(ByVal devtag As String)
        If Contains(devtag) Then
            Dim DevicetoSuspend As String = "device." & devtag & ".suspended"
            xPLCache.Add(DevicetoSuspend, True, False)
        End If
    End Sub

    Public Shared Function GetDevice(ByVal devtag As String) As xPLDevice
        If Contains(devtag) Then
            Dim targetdevice As New xPLDevice
            Dim goctag As String = "device." & devtag & "."
            With targetdevice
                .ConfigDone = xPLCache.ObjectValue(goctag & "configdone")
                .ConfigMissing = xPLCache.ObjectValue(goctag & "configmissing")
                .ConfigSource = xPLCache.ObjectValue(goctag & "configsource")
                .ConfigType = xPLCache.ObjectValue(goctag & "configtype")
                .Current = xPLCache.ObjectValue(goctag & "current")
                .Expires = xPLCache.ObjectValue(goctag & "expires")
                .Interval = xPLCache.ObjectValue(goctag & "interval")
                .VDI = xPLCache.ObjectValue(goctag & "vdi")
                .WaitingConfig = xPLCache.ObjectValue(goctag & "waitingconfig")
                .ConfigListSent = xPLCache.ObjectValue(goctag & "configlistsent")
                .Suspended = xPLCache.ObjectValue(goctag & "suspended")
                .Expires = xPLCache.ObjectValue(goctag & "expires")
            End With
            Return targetdevice
        Else
            Return Nothing
        End If
    End Function

    Public Shared Function AllDevices() As Collection
        Dim rgxGetDevices As New Regex("device\.(.*)\.vdi")

        AllDevices = New Collection
        For Each entry As CacheEntry In xPLCache.FilterbyRegEx(rgxGetDevices)
            Dim DeviceNameParts() As String = rgxGetDevices.Split(entry.ObjectName)
            If DeviceNameParts.Length >= 3 Then
                Dim devName As String = DeviceNameParts(1).ToString.ToLower.Trim

                Dim newdev As xPLDevice = GetDevice(devName)
                If newdev IsNot Nothing Then
                    AllDevices.Add(newdev)
                End If
            End If
        Next
        Return (AllDevices)
    End Function

    Public Shared Function Count() As Integer
        Dim alldevs As Collection = AllDevices()
        Return alldevs.Count
    End Function

    Public Shared Sub FlushExpired()
        Try
            For Each entry As xPLDevice In AllDevices()
                With entry
                    If .Suspended Then
                        Remove(entry.VDI)
                    Else
                        If .Expires < Now And .Suspended = False Then
                            Dim targetName As String = "device." & entry.VDI & "."
                            xPLCache.Add(targetName & "suspended", True, False)
                            xPLCache.Add(targetName & "configdone", False, False)
                            xPLCache.Add(targetName & "configmissing", False, False)
                            xPLCache.Add(targetName & "waitingconfig", False, False)
                        End If
                    End If
                End With
            Next
        Catch ex As Exception
            Logger.AddLogEntry(AppWarn, "devman", "We had a problem flushing old devices")
            Logger.AddLogEntry(AppWarn, "devman", "Cause:" & ex.Message)
        End Try
    End Sub

    Public Shared Sub StoreNewConfig(ByVal msgSource As String, ByVal newvalues As String)

        If DevManager.Contains(msgSource) Then
            Dim configvals = newvalues.Split
            For Each entry As String In configvals
                ' 22-may-2011 Tieske, fixed bug 51; http://xplproject.org.uk/bugs/index.php?do=details&task_id=51&project=2
                Dim key As String = Split(entry, "=")(0).ToLower
                Dim val As String = Right(entry, Len(entry) - (Len(key) + 1))
                Dim GOCPath As String = "config." & msgSource & ".current."

                xPLCache.Add(GOCPath & key, val, False)
            Next

            'Okay, now send it to the device... but one last check first...
            If xPLCache.ChildNodes("config." & msgSource & ".current").Count > 0 Then
                SendConfigResponse(msgSource, True)
            End If
        Else
            Logger.AddLogEntry(AppWarn, "devman", "Manager asked us to store config for a device we don't have?")
        End If

    End Sub

    Public Shared Sub ProcessHeartbeats(ByVal msgSource As String, ByVal e As xpllib.XplMsg)
        Dim msgType As String = e.MsgTypeString
        Dim msgSchemaClass As String = e.Class
        Dim msgSchemaType As String = e.Type

        Dim targetDevice As xPLDevice = GetDevice(msgSource)
        If targetDevice Is Nothing Then
            'this handles a new application that identifies itself with a hbeat straight away.
            'it must either be storing it's config locally, can't be configured, or is configured somewhere else.

            targetDevice = New xPLDevice
            With targetDevice
                .VDI = msgSource                                ' vendor / device / instance = unique id
                .ConfigDone = True                              ' false = new waiting check, true = sent/not required
                .ConfigMissing = True                           ' true = no config file, no response from device, false = have/waiting config
                .ConfigSource = "objectcache"                   ' v-d.xml / v-d.cache.xml or empty
                .ConfigType = False                             ' true = config. false = hbeat.
                .WaitingConfig = False                          ' false = waiting check or not needed, true = manual intervention
                .Current = False                                ' asked for current config
                .ConfigListSent = True                          ' Have we asked this device for it's config?
                .Suspended = False                              ' lost heartbeat
                .Interval = Val(e.GetKeyValue("interval"))      ' current heartbeat interval
                .Expires = DateAdd(DateInterval.Minute, (2 * .Interval) + 1, Now)   ' time expires
            End With
            Update(targetDevice)

            'Throw it a config request anyway, see what turns up..
            RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.list", "command=request")
            RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.current", "command=request")

            Logger.AddLogEntry(AppInfo, "devman", "Added a new device in response to an hbeat")
        Else
            Dim targetdevName As String = "device." & msgSource & ".expires"
            xPLCache.Add(targetdevName, DateAdd(DateInterval.Minute, (2 * targetDevice.Interval) + 1, Now).ToString, False)
        End If

    End Sub


    Public Shared Sub ProcessConfigList(ByVal msgSource As String, ByVal e As xpllib.XplMsg)

        Dim targetDevice As xPLDevice = GetDevice(msgSource)
        If targetDevice Is Nothing Then
            targetDevice = New xPLDevice
            With targetDevice
                .VDI = msgSource                                ' vendor / device / instance = unique id
                .ConfigDone = False                             ' false = new waiting check, true = sent/not required
                .ConfigMissing = False                          ' true = no config file, no response from device, false = have/waiting config
                .ConfigSource = "objectcache"                   ' v-d.xml / v-d.cache.xml or empty
                .ConfigType = True                              ' true = config. false = hbeat.
                .WaitingConfig = False                          ' false = waiting check or not needed, true = manual intervention
                .Current = False                                ' asked for current config
                .ConfigListSent = True                          ' Have we asked this device for it's config?
                .Suspended = False                              ' lost heartbeat
                .Interval = Val(e.GetKeyValue("interval"))      ' current heartbeat interval
                .Expires = DateAdd(DateInterval.Minute, (2 * .Interval) + 1, Now)   ' time expires
            End With
            Update(targetDevice)
            Logger.AddLogEntry(AppInfo, "devman", "Added a new device direct from config.list")
        End If

        'Place the config.list options into the GOC - properly!!
        Dim rgxMultipleItems As New Regex("([a-z0-9]{1,16})\[(\d{1,2})\]")
        For Each keypair As xpllib.XplMsg.KeyValuePair In e.KeyValues
            Dim valueParts() = rgxMultipleItems.Split(keypair.Value.ToLower)
            Dim GOCPath As String = "config." & msgSource & ".options."
            Dim ConfigObject As String = ""
            Dim ConfigObjectType As String = ""
            Dim ConfigObjectCount As String = ""
            If valueParts.Length >= 2 Then
                ConfigObject = valueParts(1).ToLower
                ConfigObjectType = keypair.Key.ToLower
                ConfigObjectCount = valueParts(2).ToString
            Else
                ConfigObject = keypair.Value.ToLower
                ConfigObjectType = keypair.Key.ToLower
                ConfigObjectCount = ""
            End If
            xPLCache.Add(GOCPath & ConfigObject, "", False)
            xPLCache.Add(GOCPath & ConfigObject & ".type", ConfigObjectType, False)
            xPLCache.Add(GOCPath & ConfigObject & ".count", ConfigObjectCount, False)
        Next

        'Send the Config response - if we have a config.
        If xPLCache.ChildNodes("config." & msgSource & ".current").Count > 0 Then  'we have a config!
            xPLCache.Add("device." & msgSource & ".configdone", True, False)
            ' IRL Removed as an experiment
            ' See forum thread http://xplproject.org.uk/forums/viewtopic.php?f=1&t=951
            ' SendConfigResponse(msgSource, False)
        End If
    End Sub


    Public Shared Sub ProcessConfigHeartBeat(ByVal msgSource As String, ByVal e As xpllib.XplMsg)
        Dim msgType As String = e.MsgTypeString
        Dim msgSchemaClass As String = e.Class
        Dim msgSchemaType As String = e.Type

        Dim targetDevice As xPLDevice = GetDevice(msgSource)
        If targetDevice Is Nothing Then
            'this handles a new application that identifies itself with a hbeat straight away.
            'it must either be storing it's config locally, can't be configured, or is configured somewhere else.

            targetDevice = New xPLDevice
            With targetDevice
                .VDI = msgSource                                ' vendor / device / instance = unique id
                .ConfigDone = False                             ' false = new waiting check, true = sent/not required
                .ConfigMissing = True                           ' true = no config file, no response from device, false = have/waiting config
                .ConfigSource = "xplmessage"                    ' v-d.xml / v-d.cache.xml or empty
                .ConfigType = True                              ' true = config. false = hbeat.
                .WaitingConfig = True                           ' false = waiting check or not needed, true = manual intervention
                .Current = False                                ' asked for current config
                .ConfigListSent = False                         ' Have we asked this device for it's config?
                .Suspended = False                              ' lost heartbeat
                .Interval = Val(e.GetKeyValue("interval"))      ' current heartbeat interval
                .Expires = DateAdd(DateInterval.Minute, (2 * .Interval) + 1, Now)   ' time expires
            End With
            Update(targetDevice)
        Else
            Dim targetdevName As String = "device." & msgSource & ".expires"
            xPLCache.Add(targetdevName, DateAdd(DateInterval.Minute, (2 * targetDevice.Interval) + 1, Now).ToString, False)
            xPLCache.Add(targetdevName & ".configdone", "objectcache", False)
        End If

        If targetDevice.ConfigListSent = False Then
            Dim targetdevName As String = "device." & msgSource
            RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.list", "command=request")
            xPLCache.Add(targetdevName & ".configlistsent", True, False)
        End If

        'If targetDevice.Current = False Then
        '    Dim targetdevName As String = "device." & msgSource
        '    RaiseEvent SendxPLMessage("xpl-cmnd", msgSource, "config.current", "command=request")
        '    xPLCache.Add(targetdevName & ".current", True, False)
        'End If

    End Sub

    Public Shared Sub ProcessCurrentConfig(ByVal msgSource As String, ByVal e As xpllib.XplMsg)

        Dim targetDevice As xPLDevice = GetDevice(msgSource)
        If targetDevice Is Nothing Then
            targetDevice = New xPLDevice
            With targetDevice
                .VDI = msgSource                                ' vendor / device / instance = unique id
                .ConfigDone = True                              ' false = new waiting check, true = sent/not required
                .ConfigMissing = False                          ' true = no config file, no response from device, false = have/waiting config
                .ConfigSource = "objectcache"                   ' v-d.xml / v-d.cache.xml or empty
                .ConfigType = True                              ' true = config. false = hbeat.
                .WaitingConfig = False                          ' false = waiting check or not needed, true = manual intervention
                .Current = True                                 ' asked for current config
                .ConfigListSent = True                          ' Have we asked this device for it's config?
                .Suspended = False                              ' lost heartbeat
                .Interval = Val(e.GetKeyValue("interval"))      ' current heartbeat interval
                .Expires = DateAdd(DateInterval.Minute, (2 * .Interval) + 1, Now)   ' time expires
            End With
            Update(targetDevice)
        Else
            Dim targetdevName As String = "config." & msgSource
            xPLCache.Add(targetdevName & ".expires", DateAdd(DateInterval.Minute, (2 * targetDevice.Interval) + 1, Now).ToString, False)
            xPLCache.Add(targetdevName & ".current", True, False)
        End If

        'Place the current config values into the GOC 
        For Each keypair As xpllib.XplMsg.KeyValuePair In e.KeyValues
            Dim GOCPath As String = "config." & msgSource & ".current."
            xPLCache.Add(GOCPath & keypair.Key.ToLower, keypair.Value.ToLower, False)
        Next
    End Sub


    Private Shared Sub SendConfigResponse(ByVal _msgsource As String, ByVal RemoveOldDevice As Boolean)
        Dim rgxConfig As New Regex("config\." & _msgsource & "\.current\.([a-z0-9]{1,16})")
        Dim rgxAllConfigs As New Regex("config\.([a-z0-9]{1,8}-[a-z0-9]{1,8}\.[a-z0-9]{1,16})")

        Dim strMsg As String = ""
        For Each entry As CacheEntry In xPLCache.FilterbyRegEx(rgxConfig)
            Dim nameparts As String() = rgxConfig.Split(entry.ObjectName)
            If nameparts.Length >= 2 Then
                strMsg = strMsg & nameparts(1) & "=" & entry.ObjectValue & Chr(10)
            End If
        Next

        If strMsg <> "" Then
            RaiseEvent SendxPLMessage("xpl-cmnd", _msgsource, "config.response", strMsg)
            Dim targetdevName As String = "config." & _msgsource & "."
            xPLCache.Add(targetdevName & "configmissing", False, False)
            xPLCache.Add(targetdevName & "waitingconfig", False, False)
            xPLCache.Add(targetdevName & "configdone", False, False)
        End If
        Logger.AddLogEntry(AppInfo, "devman", "Sending configuration for device:" & _msgsource)

        If RemoveOldDevice Then
            Remove(_msgsource)
            RemoveConfig(_msgsource)
        End If

    End Sub

End Class
