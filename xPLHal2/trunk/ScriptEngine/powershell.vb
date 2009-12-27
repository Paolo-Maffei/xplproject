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
Imports GOCManager.xPLCache
Imports EventSystem
Imports System.Net
Imports System.ServiceModel

Public Class PowerShell
    Private Shared ScriptDetails As New Collection
    Private Shared runspace As Runspace
    Private Shared Sys As New HalObjects()

    Private Shared Sub InitRunSpace()
        'close 'n release
        If Not runspace Is Nothing Then
            runspace.Close()
            runspace = Nothing
        End If

        Try
            'delme
            xPLEngine.xPLHandler.SendMessage("xpl-trig", "", "test.reply", "pos=initthread2 start")

            runspace = RunspaceFactory.CreateRunspace()
            runspace.Open()

            'expose the system class
            runspace.SessionStateProxy.SetVariable("Sys", Sys)

            'delme
            xPLEngine.xPLHandler.SendMessage("xpl-trig", "", "test.reply", "pos=initthread2 end")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "script", "Unable to initialise a Powershell thread. " & Err.Description)
            Logger.AddLogEntry(AppError, "script", "Cause: " & ex.Message)
        End Try
    End Sub


    Public Shared Sub LoadScripts(ByVal ScriptFolder As String)
        Dim fs As TextReader

        If (Not System.IO.Directory.Exists(ScriptFolder)) Then
            Logger.AddLogEntry(AppWarn, "script", "Powershell scripts folder doesn't exist, trying to create.")
            Try
                System.IO.Directory.CreateDirectory(ScriptFolder)
                Logger.AddLogEntry(AppInfo, "script", "Powershell scripts folder created OK.")
            Catch ex As Exception
                Logger.AddLogEntry(AppCrit, "script", "Powershell scripts folder doesn't exist, and we couldn't create one.")
                Logger.AddLogEntry(AppCrit, "script", "Cause: " & ex.Message)
            End Try
        Else
            Logger.AddLogEntry(AppInfo, "script", "Powershell scripts folder found OK.")
        End If

        Dim Scriptfiles As ReadOnlyCollection(Of String)
        Scriptfiles = My.Computer.FileSystem.GetFiles(ScriptFolder, FileIO.SearchOption.SearchAllSubDirectories, New String() {"*.ps1"})
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
                            .Language = ScriptingLanguage.Powershell
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

        'init/re-init runspace
        InitRunSpace()
    End Sub

    Private Shared Function ParseScriptForParameters(ByVal strSource As String) As Dictionary(Of String, String)
        'parse script. get all functions and their (optional) parameters..
        
        Dim rgxParams As New Regex("function (?<name>\w*).*?{\s*(?<pstr>param\s*\((?<params>[\s\S]*?)\))?.*?}", RegexOptions.Singleline)
        Dim dict As New Dictionary(Of String, String)

        If rgxParams.IsMatch(strSource) Then
            'yep, there are functions in there...
            Dim mc As MatchCollection = rgxParams.Matches(strSource)
            Dim mIdx As Integer

            For mIdx = 0 To mc.Count - 1
                dict.Add(mc.Item(mIdx).Groups(1).Value.ToString(), mc.Item(mIdx).Groups(3).Value.ToString())
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
        Private xPLScript As String
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


        Public Function Debug() As Boolean
            Try
                If Not ScriptLoader.xplScripts.Contains(sScript) Then Return False
                Dim ActiveScript As ScriptDetail = ScriptLoader.xplScripts(sScript)

                ' Create the script object
                Dim dsi As New WCFDebugService.DebugScriptInfo()
                dsi.SourceFile = ActiveScript.SourceFile.Substring(ScriptEngineFolder.Length)
                dsi.ScriptName = ActiveScript.ScriptName
                dsi.Source = ActiveScript.Source
                dsi.GlobalScriptSource = GetGlobalScript()
                dsi.HalIPAddress = GetLocalIPAddress()
                If Not XplMessage Is Nothing Then
                    dsi.xPLMessageString = XplMessage.RawXPL
                End If

                ' Create a client
                Dim client As WCFDebugService.WCFDebugServiceClient = New WCFDebugService.WCFDebugServiceClient()

                'Change the IP address according to the value of the global "xplhal.debugger"
                Dim value As String = xPLCache.ObjectValue("xplhal.debugger")
                If Not value.Contains(":") Then
                    value += ":" & client.Endpoint.ListenUri.Port.ToString()
                End If
                client.Endpoint.Address = New EndpointAddress("http://" & value & client.Endpoint.ListenUri.LocalPath)

                'if this causes an exception, the debugger is not alive.
                '(doing it this way, timeouts are acceptable)
                'run the script normally then.
                Dim response As Net.WebResponse = System.Net.WebRequest.Create(client.Endpoint.Address.Uri).GetResponse()

                'transfer session to debugger
                client.SetDebugScriptInfo(dsi)
                client.Close()
            Catch we As Net.WebException
                'ok, no debugger found, run script normally then.
                Logger.AddLogEntry(AppWarn, "script", "Debugging enabled but could not connect to the debugger. Running script normally.")
                Return Run()
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "script", "Error debugging Powershell script. Cause: " & ex.Message)
            End Try
        End Function

        Public Function Run() As Boolean
            Try
                If Not XplMessage Is Nothing Then
                    If XplMessage.Class = "test" And XplMessage.Type = "basic" Then
                        'delme
                        xPLEngine.xPLHandler.SendMessage("xpl-trig", "", "test.reply", "pos=about to create pipeline object")
                    End If
                End If

                If Not ScriptLoader.xplScripts.Contains(sScript) Then Return False
                Dim ActiveScript As ScriptDetail = ScriptLoader.xplScripts(sScript)

                'expose the xpl message
                runspace.SessionStateProxy.SetVariable("Msg", XplMessage)

                'create pipeline and load scripts
                Dim PowershellPipeline As Pipeline = runspace.CreatePipeline()

                PowershellPipeline.Commands.AddScript(GetGlobalScript())
                PowershellPipeline.Commands.AddScript(ActiveScript.Source)
                PowershellPipeline.Commands(0).MergeMyResults(PipelineResultTypes.Error, PipelineResultTypes.Output)

                If sSubName <> "" Then
                    'replace commas with spaces
                    ScriptParams = ScriptParams.Replace(",", " ")
                    PowershellPipeline.Commands.AddScript(sSubName & " " & ScriptParams)
                End If

                PowershellPipeline.Commands.Add("Out-String")

                Dim results = PowershellPipeline.Invoke()
                Dim output As New StringBuilder
                For Each obj As PSObject In results
                    output.AppendLine(obj.ToString().Trim())
                Next

                If Not XplMessage Is Nothing Then
                    If XplMessage.Class = "test" And XplMessage.Type = "basic" Then
                        'delme
                        xPLEngine.xPLHandler.SendMessage("xpl-trig", "", "test.reply", "pos=end using pipeline object")
                    End If
                End If

                Logger.AddLogEntry(AppInfo, "script", output.ToString())
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "script", "Error Executing Script '" + sScript + "'")
                Logger.AddLogEntry(AppError, "script", "cause: " & ex.Message)
                Return False
            End Try

            Return True
        End Function
    End Class
End Class
