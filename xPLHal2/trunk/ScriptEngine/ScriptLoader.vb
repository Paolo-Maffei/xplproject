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
Imports GOCManager

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
    Public Shared PowershellEngine As New PowerShell

    Private _isInitialized As Boolean

    Public Enum ScriptingLanguage
        Powershell
        Python
    End Enum

    Public Structure ScriptDetail
        Public ScriptName As String
        Public Language As ScriptingLanguage
        Public SourceFile As String             ' containing script file
        Public Source As String                 ' script code

        'xPL message the processor reacted on
        '(or might have)
        Public Message As xpllib.XplMsg

        'contains the available functions present 
        'in the file and their parameters
        Public Functions As Dictionary(Of String, String)
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
            _isInitialized = True
            Return True
        Else
            _isInitialized = False
            Logger.AddLogEntry(AppError, "script", "Failed to Load - Scripting Subsystem is not available.")
        End If
    End Function


    Public Shared Function LoadPython() As Boolean
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

    Public Shared Function LoadPowershell() As Boolean
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

    Public ReadOnly Property IsInitialized() As Boolean
        Get
            Return _isInitialized
        End Get
    End Property


    Public Sub RunStartupScript()
        If xplScripts.Contains("xplhal_startup") Then
            'global script exists. find out what language...
            Dim ScriptDetails As ScriptDetail = xplScripts("xplhal_startup")
            Select Case ScriptDetails.Language
                Case ScriptingLanguage.Powershell
                    PowershellEngine.RunStartupScript()
                Case ScriptingLanguage.Python
                    PythonEngine.RunStartupScript()
            End Select
        End If
    End Sub

    Public Sub RunShutdownScript()
        If xplScripts.Contains("xplhal_shutdown") Then
            'global script exists. find out what language...
            Dim ScriptDetails As ScriptDetail = xplScripts("xplhal_shutdown")
            Select Case ScriptDetails.Language
                Case ScriptingLanguage.Powershell
                    PowershellEngine.RunShutdownScript()
                Case ScriptingLanguage.Python
                    PythonEngine.RunShutdownScript()
            End Select
        End If
    End Sub


    Public Sub StopScriptEngine()

    End Sub

    Public Shared Sub AddHandlers(ByVal scRunner As PowerShell.ScriptRunner)
        AddHandler scRunner._executerule, AddressOf executerule
        AddHandler scRunner._sendxplmessage, AddressOf sendxplmessage
        AddHandler scRunner._updateglobal, AddressOf updateglobal
    End Sub




    Public Sub Start(ByVal Message As xpllib.XplMsg)
        'called when a new Xpl message arrives
        'and reacting has to be done.
        ProcessMessage(Message)
    End Sub


    Public Shared Function RunScript(ByVal strScript As String) As Boolean
        Return RunScript(strScript, "", Nothing)
    End Function

    Public Shared Function RunScript(ByVal strScript As String, ByVal strParams As String) As Boolean
        Return RunScript(strScript, strParams, Nothing)
    End Function

    Public Shared Function RunScript(ByVal strScript As String, ByVal Message As xpllib.XplMsg) As Boolean
        Return RunScript(strScript, Nothing, Message)
    End Function

    Public Shared Function RunScript(ByVal strScript As String, ByVal strParams As Object, ByVal Message As xpllib.XplMsg) As Boolean
        Dim SubName As String = ""

        If Not Message Is Nothing Then
            If Message.Class = "test" And Message.Type = "basic" Then
                'delme
                xPLEngine.xPLHandler.SendMessage("xpl-trig", "", "test.reply", "pos=RunScript()")
            End If
        End If

        'strScript could be a function inside a scriptfile.
        Dim pos As Integer = strScript.IndexOf("$")
        If pos > 0 Then
            'script name is in the form of "scripname$subname"
            SubName = strScript.Substring(strScript.IndexOf("$") + 1, strScript.Length - pos - 1)
            strScript = strScript.Substring(0, pos)
        End If

        If xplScripts.Contains(strScript.ToLower()) Then
            Dim ScriptDetails As ScriptDetail = xplScripts(strScript.ToLower)
            Select Case ScriptDetails.Language
                Case ScriptingLanguage.Powershell
                    Try

                        Dim ScriptThread As New PowerShell.ScriptRunner
                        Dim t As Thread

                        If xplScripts.Contains(strScript.ToLower) Then
                            'AddHandlers(ScriptThread)
                            ScriptThread.XplMessage = Message

                            If xPLCache.ObjectValue("xplhal.debugger") Is Nothing Then
                                t = New Thread(AddressOf ScriptThread.Run)
                            Else
                                t = New Thread(AddressOf ScriptThread.Debug)
                            End If

                            ScriptThread.ScriptName = strScript
                            ScriptThread.ScriptParams = strParams

                            If SubName <> "" Then
                                ScriptThread.sSubName = SubName
                            End If

                            t.Start()
                            Logger.AddLogEntry(AppInfo, "script", "Trying to run a powershell script called: " & strScript)

                            'If Not Message Is Nothing Then
                            '    If Message.Class = "test" And Message.Type = "basic" Then
                            '        'delme
                            '        xPLEngine.xPLHandler.SendMessage("xpl-trig", "", "test.reply", "pos=script thread started")
                            '    End If
                            'End If

                            Return True ' ok
                        Else
                            Logger.AddLogEntry(AppError, "script", "Unable to find a script called: " & strScript)
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
                            ScriptThread.ScriptParams = strParams
                            t.Start()
                            Logger.AddLogEntry(AppInfo, "script", "Ran a Python script called: " & strScript)
                            Return True ' ok
                        Else
                            Logger.AddLogEntry(AppError, "script", "Unable to find a Python script called: " & strScript)
                            Return False ' doesnt exist
                        End If
                    Catch ex As Exception
                        Return False ' error
                    End Try
            End Select
        Else
            Logger.AddLogEntry(AppError, "script", "Unable to find a script called: " & strScript)
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


    'try to find available scripts matching an event tree
    Public Sub ProcessMessage(ByVal Message As xpllib.XplMsg)
        Dim period As String
        Dim mode As String

        If Message.Class = "test" And Message.Type = "basic" Then
            'delme
            xPLEngine.xPLHandler.SendMessage("xpl-trig", "", "test.reply", "pos=about to process message")
        End If

        period = GOCManager.xPLCache.ObjectValue("xplhal.period")
        mode = GOCManager.xPLCache.ObjectValue("xplhal.mode")

        Dim scriptname As String = ""
        Dim subType As String = ""

        If Message.Class.ToUpper() = "HBEAT" Or Message.Class.ToUpper() = "CONFIG" Then
            Select Case Message.Class.ToUpper()
                Case "HBEAT"
                    subType = subType + "heartbeat"
                Case "CONFIG"
                    subType = subType + "config"
            End Select
        Else
            Select Case Message.MsgType
                Case xpllib.XplMsg.xPLMsgType.cmnd
                    subType = "command"
                Case xpllib.XplMsg.xPLMsgType.trig
                    subType = "trigger"
                Case xpllib.XplMsg.xPLMsgType.stat
                    subType = "status"
            End Select
        End If

        'now try to find available scripts matching this tree

        '<source>_<instance>_<class>_<type>_<mode>_<period>_<Message Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}_{5}_{6}_{7}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Class, Message.Type, mode, period, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<class>_<type>_<mode>_<Message Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}_{5}_{6}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Class, Message.Type, mode, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<class>_<type>_<period>_<Message Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}_{5}_{6}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Class, Message.Type, period, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<class>_<type>_<Message Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}_{5}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Class, Message.Type, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<class>_<mode>_<period>_<Message Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}_{5}_{6}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Class, mode, period, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<class>_<mode>_<Message_Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}_{5}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Class, mode, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<class>_<period>_<Message Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}_{5}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Class, period, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<type>_<mode>_<period>_<Message Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}_{5}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Type, mode, period, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<type>_<mode>_<Message Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}_{5}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Type, mode, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<type>_<period>_<Message Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}_{5}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Type, period, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<type>_<Message TYpe>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}_{4}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, Message.Type, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>_<instance>_<Message Type>(xPLMessage)
        scriptname = String.Format("{0}_{1}_{2}_{3}", Message.SourceVendor, Message.SourceDevice, Message.SourceInstance, subType)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)

        '<source>(xPLMessage)
        scriptname = String.Format("{0}_{1}", Message.SourceVendor, Message.SourceDevice)
        If xplScripts.Contains(scriptname) Then RunScript(scriptname, Message)
    End Sub

End Class
