'**************************************
'* xPL Web Services Delivery Module
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

Imports xPLLogging.Logger
Imports xPLLogging.LogLevel
Imports System.ServiceModel
Imports xPLLogging

Public Class xPLWebService
    Implements xPLWebServiceContract

    Private xplLog As New xPLLogging.Logger("webservices.log")

    Public Function DisplayCacheObject(ByVal ObjectName As String) As String Implements xPLWebServiceContract.DisplayCacheObject
        DisplayCacheObject = ""
        Try
            ObjectName = ObjectName
            'If xPLCache.Contains(ObjectName) Then
            '    DisplayCacheObject = CacheManager.ObjectValue(ObjectName)
            'End If
            Logger.AddLogEntry(AppInfo, "webs", "Global Cache Entry Requested:" & ObjectName)
        Catch ex As Exception
            Logger.AddLogEntry(AppWarn, "webs", "Cannot access Global Cache" & ObjectName)
        End Try
    End Function

    Public Function DisplayCache() As String Implements xPLWebServiceContract.DisplayCache
        'DisplayCache = xPLCache.ListAllObjectsXML.ToString
        Return ("Not Implemented Yet")
    End Function

    Public Sub SetCacheObjectValue(ByVal ObjectName As String, ByVal ObjectValue As String) Implements xPLWebServiceContract.SetCacheObjectValue
        Try
            ObjectName = ObjectName
            ObjectValue = ObjectValue.Substring(10, ObjectValue.Length - 10)
            ObjectValue = ObjectValue.Substring(ObjectName.Length + 1, ObjectValue.Length - ObjectName.Length - 1)
            'CacheManager.ObjectValue(ObjectName) = ObjectValue
            Logger.AddLogEntry(AppInfo, "webs", "Set Global Cache Entry:" & ObjectName & " to: " & ObjectValue)
        Catch ex As Exception
            Logger.AddLogEntry(AppWarn, "webs", "Failed to Set Global Cache Entry for:" & ObjectName)
        End Try
    End Sub

    Public Sub RunDeterminator(ByVal oName As String) Implements xPLWebServiceContract.RunDeterminator

    End Sub

    Public Sub CreateCacheObject(ByVal oName As String, ByVal oValue As String) Implements xPLWebServiceContract.CreateCacheObject

    End Sub
End Class
