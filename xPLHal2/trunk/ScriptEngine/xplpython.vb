Imports System.IO
Imports System.Text.RegularExpressions
Imports System.Collections.ObjectModel
Imports Scripts.ScriptLoader

Imports xPLLogging
Imports xPLLogging.LogLevel
Imports IronPython.Hosting
Imports Microsoft.Scripting.Hosting
Imports Microsoft.Scripting

Public Class xplpython
    Private Shared Sys As New HalObjects()

    Public Shared Sub LoadScripts(ByVal ScriptFolder As String)
        Dim fs As TextReader

        If (Not System.IO.Directory.Exists(ScriptFolder)) Then
            Logger.AddLogEntry(AppWarn, "script", "Python Scripts Folder doesn't exist, trying to create.")
            Try
                System.IO.Directory.CreateDirectory(ScriptFolder)
                Logger.AddLogEntry(AppInfo, "script", "Python Scripts Folder created OK.")
            Catch ex As Exception
                Logger.AddLogEntry(AppCrit, "script", "Python Scripts Folder doesn't exist, and we couldn't create one.")
                Logger.AddLogEntry(AppCrit, "script", "Cause: " & ex.Message)
            End Try
        Else
            Logger.AddLogEntry(AppInfo, "script", "Python Scripts Folder found OK.")
        End If

        Dim Scriptfiles As ReadOnlyCollection(Of String)
        Scriptfiles = My.Computer.FileSystem.GetFiles(ScriptFolder, FileIO.SearchOption.SearchAllSubDirectories, New String() {"*.py"})
        For Each ScriptFile In Scriptfiles
            fs = File.OpenText(ScriptFile)

            Dim strSource As String = fs.ReadToEnd
            fs.Close()

            If strSource IsNot Nothing Then
                Dim scriptname As String = Path.GetFileNameWithoutExtension(ScriptFile)
                If Not xplScripts.Contains(scriptname) Then
                    Try
                        Dim newscript As New ScriptDetail
                        With newscript
                            .ScriptName = scriptname
                            .Language = ScriptingLanguage.Python
                            .SourceFile = ScriptFile
                            .Source = strSource
                            .Functions = ParseScriptForParameters(strSource)
                        End With

                        'add script to collection
                        xplScripts.Add(newscript, scriptname)
                    Catch ex As Exception
                        Logger.AddLogEntry(AppWarn, "script", "Could not add powershell script: " & scriptname)
                        Logger.AddLogEntry(AppWarn, "script", "cause: " & ex.Message)
                    End Try
                Else
                    Logger.AddLogEntry(AppWarn, "script", "Could not add script " & scriptname & " because another script already exists with this name.")
                End If
            End If
        Next

    End Sub

    Private Shared Function ParseScriptForParameters(ByVal strSource As String) As Dictionary(Of String, String)
        'parse script. get all functions and their (optional) parameters..

        Dim rgxParams As New Regex("def (?<name>\w*).*?\((?<arg>[^\)]+)\):")
        Dim dict As New Dictionary(Of String, String)

        If rgxParams.IsMatch(strSource) Then
            'yep, there are functions in there...
            Dim mc As MatchCollection = rgxParams.Matches(strSource)
            Dim mIdx As Integer

            For mIdx = 0 To mc.Count - 1
                dict.Add(mc.Item(mIdx).Groups(1).Value.ToString(), mc.Item(mIdx).Groups(2).Value.ToString())
            Next
        End If

        Return dict
    End Function

    Public Sub RunStartupScript()
        RunScript("xplhal_startup")
    End Sub

    Public Sub RunShutdownScript()
        RunScript("xplhal_shutdown")
    End Sub


    Public Class ScriptRunner
        Private PythEngine = Python.CreateEngine
        Private sScript As String = ""
        Private sParams As String = ""
        Private xMessage As xpllib.XplMsg
        Public sSubName As String

        Public Event _sendxplmessage(ByVal _msgtype As String, ByVal _sourcetag As String, ByVal _msgclass As String, ByVal _msgbody As String)
        Public Event _updateglobal(ByVal _name As String, ByVal _value As String)
        Public Event _executerule(ByVal _rulename As String, ByVal _offset As Integer, ByVal _runifdisabled As Boolean)

        Property ScriptParams() As String
            Get
                ScriptParams = sParams
            End Get
            Set(ByVal value As String)
                sParams = value
            End Set
        End Property

        Property ScriptName() As String
            Get
                ScriptName = sScript
            End Get
            Set(ByVal value As String)
                sScript = value
            End Set
        End Property

        Property XplMessage() As xpllib.XplMsg
            Get
                XplMessage = xMessage
            End Get
            Set(ByVal value As xpllib.XplMsg)
                xMessage = value
            End Set
        End Property

        Public Function Run() As Boolean
            Try
                If Not ScriptLoader.xplScripts.Contains(sScript.ToUpper) Then Return False
                Dim pythonsource As ScriptSource = PythEngine.CreateScriptSourceFromString(sScript, SourceCodeKind.Statements)

                Dim scriptscope = PythEngine.CreateScope()
                scriptscope.addtopath(ScriptEngineFolder)
                scriptscope.SetVariable("Msg", XplMessage)
                scriptscope.SetVariable("Sys", Sys)
                scriptscope.SetVariable("Params", ScriptParams)
                pythonsource.Execute(scriptscope)

            Catch ex As Exception
                Logger.AddLogEntry(AppError, "script", "Error Executing Python Script: " & sScript)
                Logger.AddLogEntry(AppError, "script", "Cause: " & Err.Description)
                Return False
            End Try
            Return True
        End Function
    End Class
End Class

