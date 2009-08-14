Imports System.Collections.ObjectModel
Imports System.Management.Automation
Imports System.Management.Automation.Runspaces
Imports System.IO
Imports System.Text.RegularExpressions
Imports Scripts.ScriptLoader

Imports xPLLogging
Imports xPLLogging.LogLevel
Imports System.Text
Imports GOCManager


Public Class PowerShell

    Private Shared ScriptDetails As New Collection

    Public Shared Sub LoadScripts(ByVal ScriptFolder As String)
        Dim fs As TextReader

        Dim rgxPowershellHeader As New Regex("#xpl powershell script,(\w*),(true|false),(.*)")

        If (Not System.IO.Directory.Exists(ScriptFolder)) Then
            Logger.AddLogEntry(AppWarn, "script", "Powershell Scripts Folder doesn't exist, trying to create.")
            Try
                System.IO.Directory.CreateDirectory(ScriptFolder)
                Logger.AddLogEntry(AppInfo, "script", "Powershell Scripts Folder created OK.")
            Catch ex As Exception
                Logger.AddLogEntry(AppCrit, "script", "Powershell Scripts Folder doesn't exist, and we couldn't create one.")
                Logger.AddLogEntry(AppCrit, "script", "Cause: " & ex.Message)
            End Try
        Else
            Logger.AddLogEntry(AppInfo, "script", "Powershell Scripts Folder found OK.")
        End If

        Dim Scriptfiles As ReadOnlyCollection(Of String)
        Scriptfiles = My.Computer.FileSystem.GetFiles(ScriptFolder, FileIO.SearchOption.SearchAllSubDirectories, New String() {"*.ps1"})
        For Each ScriptFile In Scriptfiles
            fs = File.OpenText(ScriptFile)

            Dim strHeader, strSource As String
            strHeader = fs.ReadLine()
            strSource = fs.ReadToEnd

            If strHeader IsNot Nothing And strSource IsNot Nothing Then
                If rgxPowershellHeader.IsMatch(strHeader) Then
                    Dim HeaderParts() As String = rgxPowershellHeader.Split(strHeader.ToString)
                    Dim CodeType As String = "shell"
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
                            Logger.AddLogEntry(AppInfo, "script", "Added a powershell script called: " & subName)
                        Catch ex As Exception
                            Logger.AddLogEntry(AppWarn, "script", "Could not add  powershell script: " & subName)
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

        Private xPLScript As String
        Private sScript As String = ""
        Private bHasParams As Boolean = False
        Private sParams As String = ""

        Private PowerShellRunspace As Runspace = RunspaceFactory.CreateRunspace
        Private PowershellPipeline As Pipeline

        Public xPLHalCache As String

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

        Public Function InitThread() As Boolean
            Try
                xPLHalCache = xPLCache.ListAllObjects
                PowerShellRunspace.Open()

                PowerShellRunspace.SessionStateProxy.SetVariable("xplhal", Me)
                PowershellPipeline = PowerShellRunspace.CreatePipeline
                Return True
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "script", "Unable to Initialise a Powershell thread. " & Err.Description)
                Logger.AddLogEntry(AppError, "script", "Cause: " & ex.Message)
                Return False
            End Try
            Return True
        End Function

        Public Function Run() As Boolean
            Try
                If Not ScriptLoader.xplScripts.Contains(sScript) Then Return False
                Dim ActiveScript As ScriptDetail = ScriptLoader.xplScripts(sScript)
                PowershellPipeline.Commands.AddScript(ActiveScript.Source)
                Dim results = PowershellPipeline.Invoke()
                Dim output As New StringBuilder
                For Each obj As PSObject In results
                    output.AppendLine(obj.ToString)
                Next

            Catch ex As Exception
                Logger.AddLogEntry(AppError, "script", "Error Executing Script '" + sScript + "'")
                Logger.AddLogEntry(AppError, "script", "cause: " & ex.Message)
                Return False
            End Try
            Return True
        End Function

    End Class

End Class

