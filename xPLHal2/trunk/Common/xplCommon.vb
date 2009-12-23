'**************************************
'* xPL Common Components
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
Imports Scripts.ScriptLoader

Partial Public Class xplCommon

    Public Shared Function Version() As String
        Return System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
    End Function

    Shared Property xPLHalIsActive() As Boolean
        Get
            xPLHalIsActive = _xPLHalActive
        End Get
        Set(ByVal value As Boolean)
            If value Then
                _xPLHalActive = True
                xPLHandler.HandlerActive = True
            End If
        End Set
    End Property


    Public Shared Sub Housekeeping() Handles HouseKeepingTimer.Elapsed
        Logger.AddLogEntry(AppInfo, "house", "Housekeeping: Flushed Expired Devices.")
        xPLCache.FlushExpiredEntries()
        DevManager.FlushExpired()
    End Sub

    Public Shared Sub RunEvents() Handles EventTimer.Elapsed
        Logger.AddLogEntry(AppInfo, "house", "Housekeeping: Check for Events to Launch.")
        EventLauncher.RunEvents()
    End Sub

    Public Shared Sub DoxPLNetworkConfig()
        MySourceTag = xPLHandler.MySourceTag
        Logger.AddLogEntry(AppInfo, "xplnet", "xPL Network reconfigured. New Instance: " & MySourceTag)
    End Sub

    Public Shared Sub DoxPLConfigList(ByVal _msgsource As String, ByVal e As xpllib.XplMsg)
        Logger.AddLogEntry(AppInfo, "xplnet", "Processing config.list for " & _msgsource)
        DevManager.ProcessConfigList(_msgsource, e)
    End Sub

    Public Shared Sub DoxPLConfigHeartBeat(ByVal _msgsource As String, ByVal e As xpllib.XplMsg)
        Logger.AddLogEntry(AppInfo, "xplnet", "Processing config.app for " & _msgsource)
        DevManager.ProcessConfigHeartBeat(_msgsource, e)
    End Sub

    Public Shared Sub DoxPLCurrentConfig(ByVal _msgsource As String, ByVal e As xpllib.XplMsg)
        Logger.AddLogEntry(AppInfo, "xplnet", "Storing current config values for " & _msgsource)
        DevManager.ProcessCurrentConfig(_msgsource, e)
    End Sub

    Public Shared Sub SendConfigRequest(ByVal _devicetag As String)
        ' Send this message -> ("xpl-cmnd", devtag, "config.list", "command=request")
        xPLHandler.xPLSendMsg("xpl-cmnd", _devicetag, "config.list", "command=request")
        Logger.AddLogEntry(AppInfo, "xplnet", "Requested Device Config from:" & _devicetag)
    End Sub

    Public Shared Sub SendxPLMessage(ByVal _msgtype As String, ByVal _sourcetag As String, ByVal _msgclass As String, ByVal _msgbody As String)
        xPLHandler.xPLSendMsg(_msgtype, _sourcetag, _msgclass, _msgbody)
    End Sub

    Public Shared Sub AddxPLMessagetoCache(ByVal e As xpllib.XplMsg)
        Dim xPLCacheParser As New xPLParser
        xPLCacheParser.xPLMessage = e
        Try
            Dim ParseThread As Thread
            ParseThread = New Thread(AddressOf xPLCacheParser.Parse)
            ParseThread.Start()
            Logger.AddLogEntry(AppInfo, "core", "Create xPLCacheParser Thread.")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "Failed to Create xPLCacheParser Thread.")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try
    End Sub

    Public Shared Sub ProcessHeartbeat(ByVal _msgsource As String, ByVal e As xpllib.XplMsg)
        DevManager.ProcessHeartbeats(_msgsource, e)
    End Sub

    Public Shared Sub RemoveDevice(ByVal _msgsource As String)
        DevManager.Remove(_msgsource)
    End Sub


    Public Shared Sub RunDetsInXPLMessage(ByVal e As xpllib.XplMsg)
        Dim ruleHandler As New DeterminatorProcessor
        ruleHandler.Message = e
        Try
            Dim ruleThread As New Thread(AddressOf ruleHandler.Start)
            ruleThread.Start()
            Logger.AddLogEntry(AppInfo, "core", "Created Determinator Processing Thread.")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "Cannot Create Determinator Processing Thread.")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try
    End Sub

    Public Shared Sub RunDetsAfterCacheChange(ByVal objectname As String)
        Logger.AddLogEntry(AppInfo, "core", "Checking Rules after value changed on: " & objectname.Trim)
        Determinator.CacheChanged(objectname)
    End Sub

    Public Shared Sub RunScriptsInXPLMessage(ByVal e As xpllib.XplMsg)
        'Dim ruleHandler As New ScriptsProcessor
        'ruleHandler.Message = e

        If e.Class = "test" And e.Type = "basic" Then
            'delme
            xPLHandler.SendMessage("xpl-trig", "", "test.reply", "pos=RunScriptsInXPLMessage")
        End If

        Try
            'Dim ruleThread As New Thread(AddressOf ruleHandler.Start)
            'ruleThread.Start()
            Dim ruleThread As New Thread(AddressOf xPLScriptEngine.Start)
            ruleThread.Start(e)
            Logger.AddLogEntry(AppInfo, "core", "Created Script Processing Thread.")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "core", "Cannot Create Script Processing Thread.")
            Logger.AddLogEntry(AppError, "core", "Cause: " & ex.Message)
        End Try
    End Sub


    Public Shared Sub ExecuteRule(ByVal rulename As String, ByVal offset As Integer, ByVal RunIfDisabled As Boolean)
        Logger.AddLogEntry(AppInfo, "core", "Running Rule: " & rulename.Trim)
        Determinator.ExecuteRule(rulename, offset, RunIfDisabled)
    End Sub

    Public Shared Sub RunScript(ByVal strScript As String, ByVal strParams As Object)
        Logger.AddLogEntry(AppInfo, "core", "Running Script: " & strScript.Trim)
        ScriptLoader.RunScript(strScript, strParams)
    End Sub

    Public Shared Sub UpdateGlobal(ByVal globalname As String, ByVal globalvalue As String)
        Logger.AddLogEntry(AppInfo, "core", "Updating Cache Value: " & globalname.Trim)
        xPLCache.Add(globalname, globalvalue, False)
    End Sub
End Class
