'**************************************
'* xPL Windows Service 
'*
'* Version 1.04
'*
'* Copyright (C) 2008 Ian Lowe
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
Imports CommonCode
Imports System.ServiceProcess

Public Class xPLService

    Public WithEvents CommonServices As New xplCommon

    Protected Overrides Sub OnStart(ByVal args() As String)
        Dim RegLogLevel As String = xplCommon.LoadReg("LoggingLevel")
        If RegLogLevel <> "" Then
            Logger.CurrentLogLevel = Int(RegLogLevel)
        Else
            Logger.CurrentLogLevel = LogLevel.AppInfo
        End If
        xplCommon.RunningAsService = True
        Logger.RunningAsService = True
        Logger.StartLogging()
        Logger.AddLogEntry(AppInfo, "core", "xPLHal for Windows Build: " & My.Application.Info.Version.ToString, True)
        Logger.AddLogEntry(AppWarn, "core", "xPLHal is Running as a Windows Service.", True)

        xplCommon.StartxPLHalSystems()

        xplCommon.xPLHalIsActive = True
        Logger.AddLogEntry(AppInfo, "core", "Startup Complete ", True)
    End Sub

    Protected Overrides Sub OnStop() Handles CommonServices.StopService
        xplCommon.StopxPLHalSystems(False)
        Logger.StopLogging()
    End Sub

End Class
