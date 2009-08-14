'**************************************
'* xPLHal2 Scripting Engine
'*
'* Version 2.2
'*
'* Copyright (C) 2003-2007 John Bent, Ian Jeffery, Tony Tofts 
'* Copyright (C) 2008-2009 Ian Lowe 
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

Imports System.Reflection
Imports System.Text
Imports System.Text.RegularExpressions
Imports System.Threading
Imports System.IO

'Import the Script Engines
'Imports IronPython.Hosting
'Imports IronPython.Runtime.Types
'Imports Microsoft.Scripting
'Imports Microsoft.Scripting.Hosting

'Legacy, now retired.
'Imports MSScriptControl


Public Class ScriptLoader
    Public Shared DataFileFolder As String = ""
    Public Shared ScriptEngineFolder As String = ""
    Public Shared xplScripts As New Collection
    Public Shared PythonEngine As New xplpython
    Public Shared PowershellEnginer As New PowerShell

    Public Enum ScriptingLanguage
        Powershell
        Python
    End Enum

    Public Structure ScriptDetail
        Public ScriptName As String
        Public Language As ScriptingLanguage
        Public SourceFile As String             ' containing script file
        Public Source As String                 ' script code
        Public IsSub As Boolean                 ' true = sub, false = function
        Public HasParams As Boolean             ' true = sub, false = function
        Public Params As Short                  ' no of parameters
    End Structure

    Public Shared Event _sendxplmessage(ByVal _msgtype As String, ByVal _sourcetag As String, ByVal _msgclass As String, ByVal _msgbody As String)
    Public Shared Event _updateglobal(ByVal _name As String, ByVal _value As String)
    Public Shared Event _executerule(ByVal _rulename As String, ByVal _offset As Integer, ByVal _runifdisabled As Boolean)

    Public Shared Function Version() As String
        Return System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
    End Function

    Public Function InitScriptEngine() As Boolean
        xplScripts.Clear()
        If LoadPython() And LoadPowershell() Then
            Logger.AddLogEntry(AppInfo, "script", "Scripting Subsystem loaded successfully.")
            Return True
        Else
            Logger.AddLogEntry(AppError, "script", "Failed to Load - Scripting Subsystem in not available.")
        End If
    End Function

    Public Function LoadPython() As Boolean
        Dim PythonPath As String = ScriptEngineFolder & "\Python\"
        Try
            Logger.AddLogEntry(AppInfo, "script", "Python loaded successfully. wonders will never cease...")
            xplpython.LoadScripts(PythonPath)
            Return True
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "script", "Failed to Load Python Subsystem.")
            Logger.AddLogEntry(AppError, "script", "Cause:" & ex.Message)
            Return False
        End Try
        Return True
    End Function

    Public Function LoadPowershell() As Boolean
        Dim PowershellPath As String = ScriptEngineFolder & "\Powershell\"

        Try
            PowerShell.LoadScripts(PowershellPath)
            Logger.AddLogEntry(AppInfo, "script", "Powershell loaded successfully. let's see if it lasts...")
            Return True
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "script", "Failed to Load Powershell Subsystem.")
            Logger.AddLogEntry(AppError, "script", "Cause:" & ex.Message)
            Return False
        End Try
        Return True
    End Function

    Public Sub StopScriptEngine()

    End Sub

    Public Sub AddHandlers(ByVal scRunner As PowerShell.ScriptRunner)
        AddHandler scRunner._executerule, AddressOf executerule
        AddHandler scRunner._sendxplmessage, AddressOf sendxplmessage
        AddHandler scRunner._updateglobal, AddressOf updateglobal
    End Sub

    Public Function RunScript(ByVal strScript As String, ByVal HasParams As Boolean, ByVal strParams As Object) As Boolean

        If xplScripts.Contains(strScript.ToLower) Then
            Dim ScriptDetails As ScriptDetail = xplScripts(strScript.ToLower)
            Select Case ScriptDetails.Language
                Case ScriptingLanguage.Powershell
                    Try
                        Dim ScriptThread As New PowerShell.ScriptRunner
                        Dim t As Thread

                        If xplScripts.Contains(strScript.ToLower) Then
                            AddHandlers(ScriptThread)
                            ScriptThread.InitThread()
                            t = New Thread(AddressOf ScriptThread.Run)
                            ScriptThread.ScriptName = strScript
                            ScriptThread.ScriptHasParams = HasParams
                            ScriptThread.ScriptParams = strParams
                            t.Start()
                            Logger.AddLogEntry(AppInfo, "script", "Ran a Powershell Script called: " & strScript)
                            Return True ' ok
                        Else
                            Logger.AddLogEntry(AppError, "script", "Unable to find a Script called: " & strScript)
                            Return False ' doesnt exist
                        End If
                    Catch ex As Exception
                        Return False ' error
                    End Try
                Case ScriptingLanguage.Python
                    Try
                        Dim ScriptThread As New xplpython.ScriptRunner
                        Dim t As Thread

                        If xplScripts.Contains(UCase(strScript)) Then
                            t = New Thread(AddressOf ScriptThread.Run)
                            ScriptThread.ScriptName = strScript
                            ScriptThread.ScriptHasParams = HasParams
                            ScriptThread.ScriptParams = strParams
                            t.Start()
                            Logger.AddLogEntry(AppInfo, "script", "Ran a Python Script called: " & strScript)
                            Return True ' ok
                        Else
                            Logger.AddLogEntry(AppError, "script", "Unable to find a Python Script called: " & strScript)
                            Return False ' doesnt exist
                        End If
                    Catch ex As Exception
                        Return False ' error
                    End Try
            End Select
        Else
            Logger.AddLogEntry(AppError, "script", "Unable to find a Script called: " & strScript)
            Return False ' doesnt exist
        End If
    End Function


    Public Shared Sub sendxplmessage(ByVal msgtype As String, ByVal sourcetag As String, ByVal msgclass As String, ByVal msgbody As String)
        RaiseEvent _sendxplmessage(msgtype, sourcetag, msgclass, msgbody)
    End Sub

    Public Shared Sub updateglobal(ByVal name As String, ByVal newvalue As String)
        RaiseEvent _updateglobal(name, newvalue)
    End Sub

    Public Shared Sub executerule(ByVal rulename As String, ByVal offset As Integer, ByVal RunIfDisabled As Boolean)
        RaiseEvent _executerule(rulename, offset, RunIfDisabled)
    End Sub

End Class

