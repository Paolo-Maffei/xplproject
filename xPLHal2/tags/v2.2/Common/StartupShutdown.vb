'**************************************
'* xPL Common Components - Startup & Shutdown partial class
'*
'* Version 1.04
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

Imports Microsoft.Win32
Imports CommonCode
Imports xPLWebServices
Imports DeterminatorEngine
Imports xPLLogging
Imports xPLLogging.LogLevel
Imports xPLEngine
Imports GOCManager
Imports GOCManager.xPLCache
Imports System.Threading
Imports Scripts
Imports DeviceManager
Imports System.Text
Imports System.IO
Imports System.Net.Sockets
Imports System.Net
Imports System.Xml
Imports DeterminatorEngine.Determinator
Imports EventSystem

Partial Public Class xplCommon
    'Stop the Windows Service...
    Public Shared Event StopService()

    'xPLHal Subsystems
    Public Shared WithEvents xPL As xPLHandler
    Public Shared WithEvents xHCPHandler As xhcpEngine
    Public Shared WithEvents GOC As xPLCache
    Public Shared WithEvents DetEngine As Determinator
    Public Shared WithEvents xPLDevices As DevManager
    Public Shared WithEvents xPLScriptEngine As ScriptLoader
    Public Shared WithEvents EventSystem As EventLauncher

    'System Timers
    Public Shared WithEvents EventTimer As New System.Timers.Timer
    Public Shared WithEvents HouseKeepingTimer As New System.Timers.Timer

    'Global Flags
    Public Shared RunningAsService As Boolean = False
    Public Shared xPLConfigDisabled As Boolean
    Public Shared ProjectName As String = "xPL"
    Public Shared ProductName As String = "xPLHal"
    Public Shared MySourceTag As String = ""
    Public Shared xPLHalRootFolder As String = System.AppDomain.CurrentDomain.BaseDirectory
    Public Shared DataFileFolder As String = xPLHalRootFolder & "\data"
    Public Shared ScriptEngineFolder As String = DataFileFolder & "\scripts"
    Public Shared rulesFolder As String = DataFileFolder & "\determinator\"
    Public Shared vendorFileFolder As String = DataFileFolder & "\vendors"
    Public Shared ConfigFileFolder As String = DataFileFolder & "\configs"
    Public Shared xPLLog As New Logger(xPLHalRootFolder & "\xplhal.log")
    Public xPLSMTPDisabled As Boolean
    'Public xPLHalBooting As Boolean

    ' xpl master/slave
    Public Shared xPLHalMaster As String = ""
    Private Shared _xPLHalActive As Boolean = False

    Public Shared Sub AddEventhandlers()
        AddHandler xPLHandler.ParseMessageForCache, AddressOf AddxPLMessagetoCache
        AddHandler xPLHandler.ParseMessageForRules, AddressOf RunDetsInXPLMessage
        AddHandler xPLHandler.ProcessConfigList, AddressOf DoxPLConfigList
        AddHandler xPLHandler.ProcessConfigHeartBeat, AddressOf DoxPLConfigHeartBeat
        AddHandler xPLHandler.ProcessCurrentConfig, AddressOf DoxPLCurrentConfig
        AddHandler xPLHandler.RemoveDevice, AddressOf RemoveDevice
        AddHandler xPLHandler.ProcessHeartbeat, AddressOf ProcessHeartbeat
        AddHandler xPLHandler.xPLNetworkConfig, AddressOf DoxPLNetworkConfig
        AddHandler xPLCache.CacheChanged, AddressOf RunDetsAfterCacheChange
        AddHandler DevManager.SendxPLConfigRequest, AddressOf SendConfigRequest
        AddHandler DevManager.SendxPLMessage, AddressOf SendxPLMessage
        AddHandler EventLauncher.ExecuteRule, AddressOf ExecuteRule
        AddHandler EventLauncher.RunScript, AddressOf RunScript
        AddHandler ScriptLoader._executerule, AddressOf ExecuteRule
        AddHandler ScriptLoader._sendxplmessage, AddressOf SendxPLMessage
        AddHandler ScriptLoader._updateglobal, AddressOf updateglobal
    End Sub

    Public Shared Function CreateDataFoldersOK() As Boolean
        CreateDataFoldersOK = True
        System.IO.Directory.SetCurrentDirectory(xPLHalRootFolder)

        If (Not System.IO.Directory.Exists(DataFileFolder)) Then
            Logger.AddLogEntry(AppWarn, "core", "xPLHal Data Folder doesn't exist, trying to create.")
            Try
                System.IO.Directory.CreateDirectory(DataFileFolder)
                Logger.AddLogEntry(AppInfo, "core", "xPLHal Data Folder created OK.")
            Catch ex As Exception
                Logger.AddLogEntry(AppCrit, "core", "xPLHal Data Folder doesn't exist, and we couldn't create one.")
                Logger.AddLogEntry(AppCrit, "core", "Cause: " & ex.Message)
                CreateDataFoldersOK = False
            End Try
        Else
            Logger.AddLogEntry(AppInfo, "core", "xPLHal Data Folder found OK.")
        End If

        If (Not System.IO.Directory.Exists(ScriptEngineFolder)) Then
            Logger.AddLogEntry(AppWarn, "core", "xPLHal Scripts Folder doesn't exist, trying to create.")
            Try
                System.IO.Directory.CreateDirectory(ScriptEngineFolder)
                Logger.AddLogEntry(AppInfo, "core", "xPLHal Scripts Folder created OK.")
            Catch ex As Exception
                Logger.AddLogEntry(AppCrit, "core", "xPLHal Scripts Folder doesn't exist, and we couldn't create one.")
                Logger.AddLogEntry(AppCrit, "core", "Cause: " & ex.Message)
                CreateDataFoldersOK = False
            End Try
        Else
            Logger.AddLogEntry(AppInfo, "core", "Scripts Folder found OK.")
        End If

        If (Not System.IO.Directory.Exists(rulesFolder)) Then
            Logger.AddLogEntry(AppWarn, "core", "Determinator Folder doesn't exist, trying to create.")
            Try
                System.IO.Directory.CreateDirectory(rulesFolder)
                Logger.AddLogEntry(AppInfo, "core", "Determinator Folder created OK.")
            Catch ex As Exception
                Logger.AddLogEntry(AppCrit, "core", "Determinator Folder doesn't exist, and we couldn't create one.")
                Logger.AddLogEntry(AppCrit, "core", "Cause: " & ex.Message)
                CreateDataFoldersOK = False
            End Try
        Else
            Logger.AddLogEntry(AppInfo, "core", "Determinator Rules Folder found OK.")
        End If

        'If (Not System.IO.Directory.Exists(vendorFileFolder)) Then
        '    Logger.AddLogEntry(AppWarn, "core", "Vendor Data Folder doesn't exist, trying to create.")
        '    Try
        '        System.IO.Directory.CreateDirectory(vendorFileFolder)
        '        Logger.AddLogEntry(AppInfo, "core", "Vendor Data Folder created OK.")
        '    Catch ex As Exception
        '        Logger.AddLogEntry(AppCrit, "core", "Vendor Data Folder doesn't exist, and we couldn't create one.")
        '        Logger.AddLogEntry(AppCrit, "core", "Cause: " & ex.Message)
        '        CreateDataFoldersOK = False
        '    End Try
        'Else
        '    Logger.AddLogEntry(AppInfo, "core", "Vendor Data Folder found OK.")
        'End If

        'If (Not System.IO.Directory.Exists(ConfigFileFolder)) Then
        '    Logger.AddLogEntry(AppWarn, "core", "Device Config Folders do not exist, trying to create.")
        '    Try
        '        System.IO.Directory.CreateDirectory(ConfigFileFolder)
        '        System.IO.Directory.CreateDirectory(ConfigFileFolder & "\Current")
        '    Catch ex As Exception
        '        Logger.AddLogEntry(AppCrit, "core", "Device Config Folders do not exist, and we couldn't create them.")
        '        Logger.AddLogEntry(AppCrit, "core", "Cause: " & ex.Message)
        '        CreateDataFoldersOK = False
        '    End Try
        'Else
        '    Logger.AddLogEntry(AppInfo, "core", "Device Config Folder found OK.")
        'End If
    End Function

    Public Shared Sub StartxPLHalSystems()
        If CreateDataFoldersOK() Then
            Logger.AddLogEntry(AppInfo, "core", "Found Data Folders (or Created new ones)")
        Else
            Logger.AddLogEntry(AppCrit, "core", "Cannot Create xPLHal Data Folders (check permissions) - This Error is Critical, Stopping")
            StopxPLHalSystems(True)
        End If

        Try
            xPLHandler.Connect()
            Logger.AddLogEntry(AppInfo, "core", "xPL Network ver " & xPLHandler.Version & " Started")
            Logger.AddLogEntry(AppInfo, "core", "xPL Handler is using xpllib ver " & xPLHandler.LibVersion)
            MySourceTag = xPLHandler.MySourceTag
        Catch ex As Exception
            Logger.AddLogEntry(AppCrit, "core", "Cannot Start xPL Network - This Error is Critical, Stopping")
            Logger.AddLogEntry(AppCrit, "core", "Cause: " & ex.Message)
            StopxPLHalSystems(True)
            Exit Sub
        End Try

        Try
            xPLCache.DataFilePath = DataFileFolder
            xPLCache.Load()
            Logger.AddLogEntry(AppInfo, "core", "Global Object Cache Loaded")
        Catch ex As Exception
            Logger.AddLogEntry(AppCrit, "core", "Cannot Load Global Object Cache - This Error is Critical, Stopping")
            Logger.AddLogEntry(AppCrit, "core", "Cause: " & ex.Message)
            StopxPLHalSystems(True)
            Exit Sub
        End Try

        Try
            DevManager.xPLConfigDisabled = False
            Logger.AddLogEntry(AppInfo, "core", "Device Manager ver " & DevManager.Version & " Started")
        Catch ex As Exception
            Logger.AddLogEntry(AppCrit, "core", "Cannot Create Device Manager - This Error is Critical, Stopping ")
            Logger.AddLogEntry(AppCrit, "core", "Cause: " & ex.Message)
            StopxPLHalSystems(True)
        End Try

        Try
            xHCPHandler = New xhcpEngine
            Logger.AddLogEntry(AppInfo, "core", "xHCP ver " & xhcpEngine.Version & " Started")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "Cannot Launch xHCP - xPLHal Manager will be unable to connect")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try

        Try
            xPLScriptEngine = New Scripts.ScriptLoader
            ScriptLoader.DataFileFolder = DataFileFolder
            ScriptLoader.ScriptEngineFolder = ScriptEngineFolder
            xPLScriptEngine.InitScriptEngine()
            Logger.AddLogEntry(AppInfo, "core", "Script Engine ver " & ScriptLoader.Version & " Started.")
        Catch ex As Exception
            Logger.AddLogEntry(AppCrit, "core", "Cannot Start Script Engine - This Error is Critical, Stopping ")
            Logger.AddLogEntry(AppCrit, "core", "Cause: " & ex.Message)
            StopxPLHalSystems(True)
        End Try

        'Try
        '    Dim myEndPoint As New Uri("http://" & My.Computer.Name & ":8080/xplhal")
        '    Dim ListenerArray() As Uri = {myEndPoint}
        '    xPLWebServiceHost = New ServiceHost(GetType(xPLWebService), ListenerArray)
        '    xPLWebServiceHost.Open()
        '   Logger.AddLogEntry(AppInfo,"core", "WebServices Host Loaded.")
        'Catch ex As Exception
        '   Logger.AddLogEntry(AppError, "core", "Cannot Create WebServices Host. ")
        '   Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        'End Try

        Try
            Determinator.xPLSourceTag = xPLHandler.MySourceTag
            Determinator.DataFileFolder = rulesFolder
            Determinator.InitRulesEngine()
            Logger.AddLogEntry(AppInfo, "core", "Determinator Engine ver " & Determinator.version & " Loaded.")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "Cannot Create Determinator Engine. ")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try

        Try
            EventLauncher.DataFileFolder = DataFileFolder
            EventLauncher.Load()
            Logger.AddLogEntry(AppInfo, "event", "Event Launcher Loaded.")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "event", "Cannot Create Event Launcher. ")
            Logger.AddLogEntry(AppError, "event", "Cause: " & ex.Message)
        End Try

        Try
            StartTimers()
            Logger.AddLogEntry(AppInfo, "core", "Housekeeping and Event Timers Started")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "Timer System did not start properly")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try

        Try
            AddEventhandlers()
            Logger.AddLogEntry(AppInfo, "core", "Event Handlers Registered")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "Event Handlers did not Register properly")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try
    End Sub

    Public Shared Sub StopxPLHalSystems(ByVal FailDuringBoot As Boolean)
        Try
            StopTimers()
            Logger.AddLogEntry(AppInfo, "core", "Housekeeping and Event Timers Stopped")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "Timer System did not shutdown cleanly")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try

        Try
            xHCPHandler.StopXHCP()
            Logger.AddLogEntry(AppInfo, "core", "xHCP Stopped")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "xHCP did not shutdown cleanly")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try

        Try
            xPLHandler.Disconnect()
            Logger.AddLogEntry(AppInfo, "core", "xPL Network Disconnected and Stopped")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "xPL Network Connection did not shutdown cleanly")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try

        Try
            xPLCache.Save()
            Logger.AddLogEntry(AppInfo, "core", "Global Object Cache Saved and Unloaded.")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "Cannot Save Global Object Cache - changes will have been lost")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try

        Try
            EventLauncher.Save()
            Logger.AddLogEntry(AppInfo, "core", "Event Launcher Settings Saved and Unloaded.")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "Event Launcher  did not shutdown cleanly. ")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try

        Try
            xPLScriptEngine.StopScriptEngine()
            Logger.AddLogEntry(AppInfo, "core", "Script Engine Stopped.")
        Catch ex As Exception
            Logger.AddLogEntry(AppCrit, "core", "Script Engine did not shutdown cleanly")
            Logger.AddLogEntry(AppCrit, "core", "Cause: " & ex.Message)
        End Try

        'Try
        '    xPLWebServiceHost.Close()
        '   Logger.AddLogEntry(AppInfo,"core", "xPL Web Services Host Stopped")
        'Catch ex As Exception
        '   Logger.AddLogEntry(AppError, "core", "xPL Web Services Host did not shutdown cleanly")
        '   Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        'End Try

        If RunningAsService And FailDuringBoot Then
            RaiseEvent StopService()
        End If
    End Sub


    Public Shared Sub StartTimers()

        With EventTimer
            .AutoReset = True
            .Interval = 10000   'ten second interval
            .Enabled = True
        End With

        With HouseKeepingTimer
            .AutoReset = True
            .Interval = 300000   '5 minute interval
            .Enabled = True
        End With

    End Sub

    Public Shared Sub StopTimers()
        EventTimer.Stop()
        EventTimer.Dispose()
        HouseKeepingTimer.Stop()
        HouseKeepingTimer.Dispose()
    End Sub


    Public Shared Sub SaveReg(ByVal sSetting As String, ByVal sValue As String)
        Dim HKLMRoot As RegistryKey = Registry.LocalMachine
        Dim HKLMXPL As RegistryKey = HKLMRoot.OpenSubKey("Software\\" & ProjectName & "\\" & ProductName, True)

        If HKLMXPL Is Nothing Then
            Try
                Dim HKLMSoft As RegistryKey = HKLMRoot.OpenSubKey("Software", True)
                HKLMSoft.CreateSubKey(ProjectName & "\\" & ProductName)
                HKLMXPL = HKLMRoot.OpenSubKey("Software\\" & ProjectName & "\\" & ProductName, True)
                HKLMSoft.Close()
            Catch ex As Exception
            End Try
        End If

        HKLMXPL.SetValue(sSetting, sValue)

        'flush through the changes
        HKLMXPL.Flush()
        HKLMXPL.Close()
        HKLMRoot = Nothing
    End Sub

    Public Shared Function LoadReg(ByVal sSetting As String) As String
        Dim HKLMRoot As RegistryKey = Registry.LocalMachine
        Dim SettingsKey As String = "Software\\" & ProjectName & "\\" & ProductName
        Dim xPLHalRegKey As RegistryKey = HKLMRoot.OpenSubKey(SettingsKey)
        If xPLHalRegKey IsNot Nothing Then
            LoadReg = CType(xPLHalRegKey.GetValue(sSetting), String)
            xPLHalRegKey.Close()
        Else
            LoadReg = ""
        End If
        HKLMRoot = Nothing
    End Function

End Class
