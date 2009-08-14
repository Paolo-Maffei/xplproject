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

    Public Shared Sub LoadScripts(ByVal ScriptFolder As String)
        Dim fs As TextReader
        Dim rgxPythonHeader As New Regex("#xpl python script,(\w*),(true|false),(.*)")

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

            Dim strHeader, strSource As String
            strHeader = fs.ReadLine()
            strSource = fs.ReadToEnd

            If strHeader IsNot Nothing And strSource IsNot Nothing Then
                If rgxPythonHeader.IsMatch(strHeader) Then
                    Dim HeaderParts() As String = rgxPythonHeader.Split(strHeader.ToString)
                    Dim CodeType As String = "python"
                    If HeaderParts.Length >= 3 Then
                        Dim subName As String = HeaderParts(1).ToString.ToLower.Trim
                        Dim paramString As String = HeaderParts(3).ToString.ToLower.Trim

                        Dim newscript As New ScriptDetail
                        With newscript
                            .ScriptName = subName
                            .Language = ScriptingLanguage.Powershell
                            .SourceFile = ScriptEngineFolder & "\" & ScriptFile
                            .Source = strSource
                            If CodeType = "function" Then
                                .IsSub = False
                            Else
                                .IsSub = True
                            End If
                            If CountParams(paramString) > 0 Then
                                .HasParams = True
                            Else
                                .HasParams = False
                            End If
                        End With
                        Try
                            xplScripts.Add(newscript, subName)
                            Logger.AddLogEntry(AppInfo, "script", "Added a python script called: " & subName)
                        Catch ex As Exception
                            Logger.AddLogEntry(AppWarn, "script", "Could not add python script: " & subName)
                            Logger.AddLogEntry(AppWarn, "script", "cause: " & ex.Message)
                        End Try
                    Else
                        Logger.AddLogEntry(AppWarn, "script", "Did not find valid Script header: " & ScriptFile)
                    End If
                Else
                    Logger.AddLogEntry(AppWarn, "script", "Did not find valid Script header: " & ScriptFile)
                End If
            End If
            fs.Close()
        Next

    End Sub

    ' routine to calculate number of params in a sub or function
    Private Shared Function CountParams(ByVal _paramString As String) As Integer
        Dim Params() As String = Split(_paramString, ",")
        Return Params.Count
    End Function


    Public Class ScriptRunner
        Private PythEngine = Python.CreateEngine
        Private sScript As String = ""
        Private bHasParams As Boolean = False
        Private sParams As String = ""

        Public Event _sendxplmessage(ByVal _msgtype As String, ByVal _sourcetag As String, ByVal _msgclass As String, ByVal _msgbody As String)
        Public Event _updateglobal(ByVal _name As String, ByVal _value As String)
        Public Event _executerule(ByVal _rulename As String, ByVal _offset As Integer, ByVal _runifdisabled As Boolean)

        Property ScriptHasParams() As Boolean
            Get
                ScriptHasParams = bHasParams
            End Get
            Set(ByVal value As Boolean)
                bHasParams = value
            End Set
        End Property

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

        Public Function Run() As Boolean
            Try
                If Not ScriptLoader.xplScripts.Contains(sScript.ToUpper) Then Return False
                Dim pythonsource As ScriptSource = PythEngine.CreateScriptSourceFromString(sScript, SourceCodeKind.Statements)
                If bHasParams = True Then
                    Dim scriptscope = PythEngine.CreateScope()
                    scriptscope.addtopath(ScriptEngineFolder)
                    scriptscope.SetVariable("params", sParams)
                    scriptscope.SetVariable("xplhal", Me)
                    pythonsource.Execute(scriptscope)
                Else
                    pythonsource.Execute()
                End If
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "script", "Error Executing Python Script: " & sScript)
                Logger.AddLogEntry(AppError, "script", "Cause: " & Err.Description)
                Return False
            End Try
            Return True
        End Function


    End Class


End Class

