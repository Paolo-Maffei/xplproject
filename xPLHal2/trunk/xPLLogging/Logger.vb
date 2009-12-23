'**************************************
'* xPL Logging Engine
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

Imports System.IO
Imports System.Reflection

'Log Level for Error Logging
Public Enum LogLevel
    AppInfo = 4
    AppWarn = 3
    AppError = 2
    AppCrit = 1
End Enum

Public Class Logger

    Private Shared _logfilepath As String = System.AppDomain.CurrentDomain.BaseDirectory
    Private Shared _logname As String = _logfilepath & "\default.log"
    Private Shared _loglevel As Integer = LogLevel.AppError
    Private Shared _logisactive As Boolean = False
    Private Shared _runasservice As Boolean = False
    Private Shared _logfile As StreamWriter

    Shared Property CurrentLogLevel() As Integer
        Get
            CurrentLogLevel = _loglevel
        End Get
        Set(ByVal value As Integer)
            _loglevel = value
        End Set
    End Property


    Shared Property LogName() As String
        Get
            LogName = _logname
        End Get
        Set(ByVal value As String)
            If _logname IsNot Nothing Then
                _logname = value
            End If
        End Set
    End Property


    Shared Property LogFilePath() As String
        Get
            LogFilePath = _logfilepath
        End Get
        Set(ByVal value As String)
            _logfilepath = value
        End Set
    End Property

    Shared ReadOnly Property LoggingActive() As Boolean
        Get
            LoggingActive = _logisactive
        End Get
    End Property

    Shared Property RunningAsService() As Boolean
        Get
            RunningAsService = _runasservice
        End Get
        Set(ByVal value As Boolean)
            _runasservice = value
        End Set
    End Property

    Public Shared Sub StartLogging()
        If _logname = "" Then
            _logname = _logfilepath & "\default.log"
        End If

        _logisactive = True

        If Not File.Exists(_logname) Then
            Try
                _logfile = File.CreateText(_logname)
            Catch ex As Exception
                _logisactive = False
            End Try
        Else
            Try
                _logfile = File.AppendText(_logname)
                _logfile.AutoFlush = True
            Catch ex As Exception
                _logisactive = False
            End Try
        End If

        If _logisactive Then
            AddLogEntry(LogLevel.AppInfo, "Started Logging.", True)
        End If

    End Sub

    Public Shared Sub LogError(ByVal logtxt As String)
        Dim CurrentThreshold As Integer = CType(System.Enum.Parse(GetType(LogLevel), CurrentLogLevel), LogLevel)
        Dim ThisMessage As Integer = LogLevel.AppError

        If _logisactive Then
            If ThisMessage <= CurrentThreshold Then
                Dim timeStamp As String = Now.ToString
                _logfile.WriteLine(timeStamp & ", " & logtxt & LogLevel.AppError.ToString)
                If Not _runasservice Then
                    Console.WriteLine(timeStamp & " " & logtxt & LogLevel.AppError.ToString)
                End If
            End If
        End If
    End Sub

    Public Shared Sub AddLogEntry(ByVal loglvl As LogLevel, ByVal sysmodule As String, ByVal logtxt As String, Optional ByVal OverRideLevel As Boolean = False)
        Dim CurrentThreshold As Integer = CType(System.Enum.Parse(GetType(LogLevel), CurrentLogLevel), LogLevel)
        Dim ThisMessage As Integer = CType(System.Enum.Parse(GetType(LogLevel), loglvl), LogLevel)

        If _logisactive Then
            If ThisMessage <= CurrentThreshold Or OverRideLevel Then
                Dim timeStamp As String = Now.ToString
                _logfile.WriteLine(timeStamp & ", " & loglvl.ToString & ", " & sysmodule & ", " & logtxt)
                If Not _runasservice Then
                    Console.WriteLine(timeStamp & " " & loglvl.ToString & ", " & sysmodule & ", " & logtxt)
                End If
            End If
        End If
    End Sub

    Public Shared Sub StopLogging()

        AddLogEntry(LogLevel.AppInfo, "Stopped Logging Engine.", True)

        Try
            _logfile.Close()
        Catch ex As Exception

        End Try
        _logisactive = False
    End Sub

    Public Sub New(Optional ByVal _systemname As String = "default.log")
        _logname = _systemname
    End Sub

End Class

