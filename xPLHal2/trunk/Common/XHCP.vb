'**************************************
'* xPL Common Components - XHCP Protocol Handler
'*
'* Version 2.2
'*
'* Copyright (C) 2003 Tony Tofts 
'* Copyright (C) 2003-2007 John Bent, Ian Jeffery 
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
Imports System.Text.RegularExpressions

Partial Class xplCommon

    Public Class xhcpEngine

        Public Shared WelcomeBanner() As Byte
        Public Shared Password As String = ""
        Private Const XHCP_PORT As Integer = 3865
        Private Sock As Socket
        Public Shared ThreadCollection As Collection

        Public Shared Function Version() As String
            Return System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
        End Function

        Public Sub New()
            ThreadCollection = New Collection
            If xPLHalMaster = "" Then
                ' We are the master server
                Password = ""
                WelcomeBanner = Encoding.UTF8.GetBytes("200 " & MySourceTag & " Version " & System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString() & " XHCP 1.5.0" & vbCrLf)
                xhcpThread.InitReplication()
                Sock = New Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp)
                Sock.Bind(New IPEndPoint(IPAddress.Any, XHCP_PORT))
                Sock.Listen(10)
                Sock.BeginAccept(New AsyncCallback(AddressOf Sock_Accept), Sock)
            Else
                ' Connect to our master server
                Dim t As New Thread(New ThreadStart(AddressOf xhcpThread.InitReplication))
                t.Start()
            End If
        End Sub

        Private Sub Sock_Accept(ByVal ar As IAsyncResult)
            Dim newSock As Socket = Sock.EndAccept(ar)
            Try
                Dim c As New xhcpThread
                Dim t As New Thread(New ThreadStart(AddressOf c.HandleConnection))
                c.s = newSock
                c.GUID = Guid.NewGuid.ToString
                t.Start()
                ThreadCollection.Add(c, c.GUID)
            Catch ex As Exception
            End Try
            Sock.BeginAccept(New AsyncCallback(AddressOf Sock_Accept), Sock)
        End Sub

        Public Sub StopXHCP()
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Shutting down XHCP Engine.")
                xhcpThread.DoQuit = True
                Sock.Shutdown(SocketShutdown.Both)
                Sock.Close()
                Sock = Nothing
            Catch ex As Exception
            End Try
            Try
                For Each c As xhcpThread In ThreadCollection
                    Try
                        c.s.Close()
                    Catch ex As Exception
                    End Try
                Next
            Catch ex As Exception
            End Try
            Try
                If Not xhcpThread.ReplClient Is Nothing Then
                    xhcpThread.ReplClient.Shutdown(SocketShutdown.Both)
                    xhcpThread.ReplClient.Close()
                End If
            Catch ex As Exception

            End Try

        End Sub
    End Class

    Public Class xhcpThread
        Public Shared DoQuit As Boolean = False
        Public Shared ReplClient As Socket
        Private Shared ReplFiles() As String
        Private Shared ReplFilesMutex As New Mutex
        Private IsAuthenticated As Boolean
        Public GUID As String

        Private Enum xplHalModes
            Norm
            Repl
        End Enum

        Private Const XH201 As String = "201 Reload successful" & vbCrLf
        Private Const XH202 As String = "202 "
        Private Const XH203 As String = "203 OK" & vbCrLf
        Private Const XH204 As String = "204 List of settings follow" & vbCrLf
        Private Const XH205 As String = "205 List of options follow" & vbCrLf
        Private Const XH206 As String = "206 Setting updated" & vbCrLf
        Private Const XH207 As String = "207 Error log follows" & vbCrLf
        Private Const XH208 As String = "208 Requested setting follows" & vbCrLf
        Private Const XH209 As String = "209 Configuration document follows" & vbCrLf
        Private Const XH210 As String = "210 Requested script or rule follows" & vbCrLf
        Private Const XH211 As String = "211 Script saved successfully" & vbCrLf
        Private Const XH212 As String = "212 List of scripts follows" & vbCrLf
        Private Const XH213 As String = "213 XPL message transmitted" & vbCrLf
        Private Const XH214 As String = "214 Script/rule successfully deleted" & vbCrLf
        Private Const XH215 As String = "215 Configuration document saved" & vbCrLf
        Private Const XH216 As String = "216 List of XPL devices follows" & vbCrLf
        Private Const XH217 As String = "217 List of config items follows" & vbCrLf
        Private Const XH218 As String = "218 List of events follows" & vbCrLf
        Private Const XH219 As String = "219 Event added successfully" & vbCrLf
        Private Const XH220 As String = "220 Configuration items received successfully" & vbCrLf
        Private Const XH221 As String = "221 Closing transmission channel - goodbye." & vbCrLf
        Private Const XH222 As String = "222 Event information follows" & vbCrLf
        Private Const XH223 As String = "223 Event deleted successfully" & vbCrLf
        Private Const XH224 As String = "224 List of subs follows" & vbCrLf
        Private Const XH225 As String = "225 Error log cleared" & vbCrLf
        Private Const XH226 As String = "226 X10 device information updated" & vbCrLf
        Private Const XH227 As String = "227 X10 device information follows" & vbCrLf
        Private Const XH228 As String = "228 X10 device deleted" & vbCrLf
        Private Const XH229 As String = "229 Requested sub follows" & vbCrLf
        Private Const xh230 As String = "230 Replication mode active" & vbCrLf
        Private Const XH231 As String = "231 List of global variables follows" & vbCrLf
        Private Const XH232 As String = "232 Global value updated" & vbCrLf
        Private Const XH233 As String = "233 Global deleted" & vbCrLf
        Private Const XH234 As String = "234 Configuration item value(s) follow" & vbCrLf
        Private Const XH235 As String = "235 Device configuration deleted"
        Private Const XH237 As String = "237 List of Determinator Rules follows" & vbCrLf
        Private Const XH238 As String = "238 Rule added successfully" & vbCrLf
        Private Const XH239 As String = "239 Statistics follow" & vbCrLf
        Private Const XH240 As String = "240 List of determinator groups follows" & vbCrLf
        Private Const XH291 As String = "291 Global value follows" & vbCrLf
        Private Const XH292 As String = "292 List of x10 device states follows" & vbCrLf
        Private Const XH311 As String = "311 Enter script, end with <CrLf>.<CrLf>" & vbCrLf
        Private Const XH313 As String = "313 Send message to be transmitted, end with <CrLf>.<CrLf>" & vbCrLf
        Private Const XH315 As String = "315 Enter configuration document, end with <CrLf>.<CrLf>" & vbCrLf
        Private Const XH319 As String = "319 Enter event data, end with <CrLf>.<CrLf>" & vbCrLf
        Private Const XH320 As String = "320 Enter configuration items, end with <CrLf>.<CrLf>" & vbCrLf
        Private Const XH326 As String = "326 Enter X10 device information, end with <CrLf>.<CrLf>" & vbCrLf
        Private Const XH338 As String = "338 Send rule, end with <CrLf>.<CrLf>" & vbCrLf
        Private Const XH401 As String = "401 Reload failed" & vbCrLf
        Private Const XH403 As String = "403 Script not executed" & vbCrLf
        Private Const XH405 As String = "405 No such setting" & vbCrLf
        Private Const XH410 As String = "410 No such script or rule" & vbCrLf
        Private Const XH416 As String = "416 No config available for specified device"
        Private Const XH417 As String = "417 No such device" & vbCrLf
        Private Const XH418 As String = "418 No vendor information available for specified device" & vbCrLf
        Private Const XH422 As String = "422 No such event" & vbCrLf
        Private Const XH429 As String = "429 No such sub-routine" & vbCrLf
        Private Const XH491 As String = "491 No such global" & vbCrLf ' & trt
        Private Const XH500 As String = "500 Command not recognised" & vbCrLf
        Private Const XH501 As String = "501 Syntax error" & vbCrLf
        Private Const XH502 As String = "502 Access denied"
        Private Const XH503 As String = "503 Internal error - command not performed" & vbCrLf
        Private Const XH530 As String = "530 A replication client is already active"
        Private Const XH600 As String = "600 Replication data follows" & vbCrLf

        Private xMode As xplHalModes

        Public s As Socket

        Private Sub SendStatusLine(ByRef str As String)
            s.Send(Encoding.UTF8.GetBytes(str))
            s.Send(Encoding.ASCII.GetBytes(vbCrLf))
        End Sub

        Public Sub HandleConnection()
            Try
                Dim str As String, params() As String
                Dim onQuit As Boolean = False
                If xhcpEngine.Password = "" Then
                    IsAuthenticated = True
                Else
                    IsAuthenticated = False
                End If
                ' Send the welcome banner
                s.Send(xhcpEngine.WelcomeBanner)
                Logger.AddLogEntry(AppInfo, "xhcp", "XHCP Connection accepted.")
                Do
                    str = GetLine(s)
                    If DoQuit Then
                        onQuit = True
                        s.Close()
                        Logger.AddLogEntry(AppInfo, "xhcp", "XHCP Connection ended normally.")
                        Exit Sub
                    End If
                    str = str.Substring(0, str.Length - 2)

                    If str.Length = 0 Then
                        onQuit = True
                    Else
                        params = str.Split(CChar(" "))
                        If params.Length > 0 Then
                            params(0) = params(0).ToLower()
                            Select Case params(0)
                                Case "authinfo"
                                    If params.Length <> 2 Then
                                        xhcpSyntaxError()
                                    Else
                                        If System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(params(1), "SHA1") = xhcpEngine.Password Then
                                            IsAuthenticated = True
                                            s.Send(xhcpEngine.WelcomeBanner)
                                        Else
                                            IsAuthenticated = False
                                            SendStatusLine(XH502)
                                        End If
                                    End If
                                Case "quit"
                                    onQuit = True
                                Case Else
                                    If Not IsAuthenticated Then
                                        SendStatusLine(XH502)
                                    Else
                                        Select Case params(0)
                                            Case "addevent"
                                                xhcpAddEvent()
                                            Case "setrule"
                                                If params.Length = 2 Then
                                                    xhcpSetRule(params(1))
                                                Else
                                                    xhcpSetRule("")
                                                End If

                                            Case "addsingleevent"
                                                xhcpAddSingleEvent()
                                            Case "addx10device"
                                                xhcpAddX10Device()
                                            Case "capabilities"
                                                If params.Length = 2 Then
                                                    xhcpCapabilities(params(1))
                                                Else
                                                    xhcpCapabilities(Nothing)
                                                End If
                                            Case "clearerrlog"
                                                xhcpClearErrLog()
                                            Case "deldevconfig"
                                                If params.Length = 2 Then
                                                    xhcpDelDevConfig(params(1))
                                                End If
                                            Case "delevent"
                                                If params.Length > 1 Then
                                                    xhcpDeleteEvent(Right(str, Len(str) - InStr(str, " ")))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "delglobal"
                                                If params.Length > 1 Then
                                                    xhcpDelGlobal(Right(str, Len(str) - InStr(str, " ")))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "delrule"
                                                If params.Length < 2 Then
                                                    xhcpSyntaxError()
                                                Else
                                                    Dim sline As String = ""
                                                    For i As Integer = 1 To UBound(params)
                                                        sline = sline & " " & params(i)
                                                    Next
                                                    xhcpDelRule(sline.Trim())
                                                End If
                                            Case "delscript"
                                                If params.Length <> 2 Then
                                                    xhcpSyntaxError()
                                                Else
                                                    xhcpDelScript(params(1))
                                                End If
                                            Case "delx10device"
                                                If params.Length = 2 Then
                                                    xhcpDelX10Device(params(1))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "getconfigxml"
                                                xhcpGetConfigXml()
                                            Case "getdevconfig"
                                                If params.Length = 2 Then
                                                    xhcpGetDevConfig(params(1))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "getdevconfigvalue"
                                                If params.Length = 3 Then
                                                    xhcpGetDevConfigValue(params(1), params(2))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "geterrlog"
                                                xhcpGetErrLog()
                                            Case "getevent"
                                                If str.IndexOf(" ") > 0 Then
                                                    xhcpGetEvent(Right(str, Len(str) - InStr(str, " ")))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "getglobal" ' trt
                                                If params.Length = 2 Then
                                                    xhcpGetGlobal(params(1))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "getrule"
                                                If params.Length <> 2 Then
                                                    xhcpSyntaxError()
                                                Else
                                                    xhcpGetRule(params(1))
                                                End If
                                            Case "getscript"
                                                If params.Length < 2 Then
                                                    xhcpSyntaxError()
                                                Else
                                                    xhcpGetScript(str)
                                                End If
                                            Case "getsetting"
                                                If params.Length = 2 Then
                                                    xhcpGetSetting(params(1))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "getsource"
                                                s.Send(Encoding.ASCII.GetBytes(XH202 & MySourceTag & vbCrLf))
                                            Case "getsub"
                                                If params.Length = 2 Then
                                                    xhcpGetSub(params(1))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "getx10device"
                                                If params.Length > 1 Then
                                                    xhcpGetX10Device(Right(str, Len(str) - InStr(str, " ")))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "listalldevs"
                                                xhcpListAllDevs()
                                            Case "listdevices"
                                                xhcpListDevices(params)
                                            Case "listevents"
                                                xhcpListEvents()
                                            Case "listglobals"
                                                xhcpListGlobals()
                                            Case "listoptions"
                                                If params.Length = 2 Then
                                                    xhcpListOptions(params(1))
                                                Else
                                                    s.Send(Encoding.ASCII.GetBytes(XH501))
                                                End If
                                            Case "listrulegroups"
                                                xhcpListRuleGroups()
                                            Case "listrules"
                                                If params.Length < 2 Then
                                                    xhcpListRules("")
                                                Else
                                                    xhcpListRules(str)
                                                End If
                                            Case "listscripts"
                                                xhcpListScripts(s, params)
                                            Case "listsettings"
                                                xhcpListSettings()
                                            Case "listsingleevents"
                                                xhcpListSingleEvents()
                                            Case "listsubs"
                                                xhcpListSubs()
                                            Case "listsubsex"
                                                xhcpListSubsEx()
                                            Case "listx10states" ' trt
                                                If params.Length = 1 Then
                                                    xhcplistx10states("0")
                                                Else
                                                    xhcplistx10states(params(1))
                                                End If
                                            Case "mode"
                                                If params.Length = 2 Then
                                                    xhcpMode(params(1))
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "putconfigxml"
                                                xhcpPutConfigXml()
                                            Case "putdevconfig"
                                                If params.Length = 2 Then
                                                    xhcpPutDevConfig(params(1))
                                                Else
                                                    s.Send(Encoding.ASCII.GetBytes(XH501))
                                                End If
                                            Case "putscript"
                                                If params.Length <> 2 Then
                                                    s.Send(Encoding.ASCII.GetBytes(XH501))
                                                Else
                                                    xhcpPutScript(s, params(1))
                                                End If

                                            Case "reload"
                                                xPLScriptEngine.InitScriptEngine()
                                                s.Send(Encoding.ASCII.GetBytes(XH201))

                                            Case "runrule"
                                                If params.Length >= 2 Then
                                                    xhcpRunRule(str)
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "runsub"
                                                If params.Length = 2 Then
                                                    xhcpRunSub(params(1), Nothing)
                                                ElseIf params.Length = 3 Then
                                                    xhcpRunSub(params(1), params(2))
                                                End If
                                            Case "sendxplmsg"
                                                xhcpSendXplMsg()
                                            Case "setglobal"
                                                If params.Length >= 3 Then
                                                    xhcpSetGlobal(params(1), str)
                                                Else
                                                    xhcpSyntaxError()
                                                End If
                                            Case "setsetting"
                                                If params.Length <> 3 Then
                                                    s.Send(Encoding.ASCII.GetBytes(XH501))
                                                Else
                                                    xhcpSetSetting(params(1), params(2))
                                                End If
                                            Case "status"
                                                xhcpStatus()
                                            Case Else
                                                s.Send(Encoding.ASCII.GetBytes(XH500))
                                        End Select
                                    End If
                            End Select
                        End If
                    End If
                Loop Until onQuit
                Logger.AddLogEntry(AppInfo, "xhcp", "XHCP Connection Ended Normally.")
                s.Send(Encoding.ASCII.GetBytes(XH221))
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "xhcp", "XHCP Connection crashed out!!")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message)
            End Try

            Try
                s.Close()
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "xhcp", "Error closing the socket")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message)
            End Try

            If xMode = xplHalModes.Repl Then
                ReplClient = Nothing
            End If

            If xhcpEngine.ThreadCollection.Contains(GUID) Then
                Try
                    xhcpEngine.ThreadCollection.Remove(GUID)
                    Logger.AddLogEntry(AppInfo, "xhcp", "Cleaned up an old XHCP Session: " & GUID.ToString)
                Catch ex As Exception
                    Logger.AddLogEntry(AppError, "xhcp", "Failed to clean up an old XHCP Session: " & GUID.ToString)
                    Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message)
                End Try
            Else
                Logger.AddLogEntry(AppWarn, "xhcp", "Old XHCP Session seems to already be dead? " & GUID.ToString)
            End If
        End Sub

        Private Sub xhcpStatus()
            Logger.AddLogEntry(AppInfo, "xhcp", "Status Request")
            s.Send(Encoding.ASCII.GetBytes(XH239))
            s.Send(Encoding.ASCII.GetBytes("threadcollectionsize=" & xhcpEngine.ThreadCollection.Count.ToString & vbCrLf))
            EndMultiLine()
        End Sub

        Private Sub xhcpListRuleGroups()
            s.Send(Encoding.ASCII.GetBytes(XH240))
            Logger.AddLogEntry(AppInfo, "xhcp", "List all Determinator Groups")
            Try
                Dim NestedLevel As Integer = 0
                Dim FoundGroup As Boolean
                Do
                    FoundGroup = False
                    For Each DetRule In Determinator.Rules
                        If DetRule.IsGroup Then
                            If CharCount(DetRule.RuleName, "/") = NestedLevel Then
                                s.Send(Encoding.UTF8.GetBytes(DetRule.RuleGUID & vbTab & DetRule.RuleName & vbTab & vbCrLf))
                                FoundGroup = True
                            End If
                        End If
                    Next
                    NestedLevel += 1
                Loop Until Not FoundGroup
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "xhcp", "Failed to Fetch Determinator Groups.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.ToString)
            End Try
            EndMultiLine()
        End Sub

        Private Sub xhcpCapabilities(ByVal subSystem As String)
            Logger.AddLogEntry(AppInfo, "xhcp", "Ask for xPLHal Capabilities")
            If subSystem Is Nothing Then
                s.Send(Encoding.ASCII.GetBytes("236 "))
            Else
                s.Send(Encoding.ASCII.GetBytes("241 "))
            End If

            ' xPL configuration manager enabled?
            If xPLConfigDisabled Then
                s.Send(Encoding.ASCII.GetBytes("0"))
            Else
                s.Send(Encoding.ASCII.GetBytes("1"))
            End If

            ' xAP support no longer included.
            s.Send(Encoding.ASCII.GetBytes("-"))

            ' Scripting language, determinators, events and server platform
            s.Send(Encoding.ASCII.GetBytes("P11W0"))

            s.Send(Encoding.ASCII.GetBytes(vbCrLf))
            If Not subSystem Is Nothing Then
                Select Case subSystem.ToLower()
                    Case "scripting"
                        s.Send(Encoding.ASCII.GetBytes("S" & vbTab & "powershell" & vbTab & "5.6" & vbTab & "ps1" & vbTab & "http://www.microsoft.com/windowsserver2003/technologies/management/powershell/default.mspx" & vbCrLf))
                        s.Send(Encoding.ASCII.GetBytes("P" & vbTab & "python" & vbTab & "5.6" & vbTab & "py" & vbTab & "http://www.codeplex.com/Wiki/View.aspx?ProjectName=IronPython" & vbCrLf))
                End Select
                EndMultiLine()
            End If
        End Sub

        Private Sub xhcpSyntaxError()
            s.Send(Encoding.ASCII.GetBytes(XH501))
            Logger.AddLogEntry(AppWarn, "xhcp", "XHCP Syntax Error")
        End Sub

        Private Shared Function GetLine(ByVal s As Socket) As String
            Dim buff(255) As Byte
            Dim bytes_read As Integer
            Dim inbuff As String = ""
            Do
                bytes_read = s.Receive(buff, SocketFlags.Peek)
                If bytes_read > 0 Then
                    If InStr(Encoding.ASCII.GetString(buff), vbCrLf) > 0 Then
                        bytes_read = s.Receive(buff, CInt(InStr(Encoding.ASCII.GetString(buff), vbCrLf) + 1), SocketFlags.None)
                    Else
                        bytes_read = s.Receive(buff, bytes_read, SocketFlags.None)
                    End If
                    inbuff = inbuff & Encoding.ASCII.GetString(buff).Substring(0, bytes_read)
                Else
                    inbuff = ""
                End If
            Loop Until inbuff.IndexOf(vbCrLf) >= 0 Or inbuff = "" Or inbuff.Length > 2048
            Return (inbuff)
        End Function

        Private Sub xhcpGetScript(ByVal scriptname As String)
            scriptname = scriptname.Substring(scriptname.IndexOf(" ") + 1, scriptname.Length - scriptname.IndexOf(" ") - 1)
            Dim filename As String = ScriptEngineFolder & "\" & scriptname
            Logger.AddLogEntry(AppInfo, "xhcp", "Get Details for a Script called: " & scriptname)
            If Not File.Exists(filename) Then
                s.Send(Encoding.ASCII.GetBytes(XH410))
                Logger.AddLogEntry(AppWarn, "xhcp", "Script does not exist")
            Else
                Try
                    Dim fs As TextReader
                    Dim myString As String
                    fs = File.OpenText(filename)
                    s.Send(Encoding.ASCII.GetBytes(XH210))
                    myString = fs.ReadLine()
                    While Not myString Is Nothing
                        s.Send(Encoding.UTF8.GetBytes(myString & vbCrLf))
                        myString = fs.ReadLine()
                    End While
                    fs.Close()
                    EndMultiLine()
                    Logger.AddLogEntry(AppWarn, "xhcp", "Script Details sent Okay")
                Catch ex As Exception
                    Logger.AddLogEntry(AppError, "xhcp", "Failed to Fetch Script Details.")
                    Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.ToString)
                End Try
            End If
        End Sub

        Private Sub xhcpPutScript(ByVal s As Socket, ByVal scriptname As String)
            Try
                Dim fs As TextWriter
                Dim myString As String

                'if backup is enabled, make backup of previous version..
                If xPLCache.Contains("xplhal.backupscript") Then
                    If xPLCache.ObjectValue("xplhal.backupscript") = "1" Then
                        'if target script exists, backup it first..
                        If RenameOldScriptIfExists(ScriptEngineFolder & "\" & scriptname) Then
                            Logger.AddLogEntry(AppInfo, "xhcp", "Renamed existing script and created a new script called " & scriptname)
                        Else
                            Logger.AddLogEntry(AppInfo, "xhcp", "Create a new Script called: " & scriptname)
                        End If
                    Else
                        Logger.AddLogEntry(AppInfo, "xhcp", "Added or replaced a script called: " & scriptname)
                    End If
                Else
                    Logger.AddLogEntry(AppInfo, "xhcp", "Added or replaced a script called: " & scriptname)
                End If

                fs = File.CreateText(ScriptEngineFolder & "\" & scriptname)
                s.Send(Encoding.ASCII.GetBytes(XH311))
                Do
                    myString = GetLine(s)
                    If Not myString = "." & vbCrLf Then
                        fs.Write(myString)
                    End If
                Loop Until myString = "." & vbCrLf
                fs.Close()
                s.Send(Encoding.ASCII.GetBytes(XH211))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to store new script.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.ToString)
            End Try
        End Sub

        Private Sub xhcpListRules(ByVal groupName As String)
            If Not groupName = String.Empty Then
                groupName = groupName.Substring(groupName.IndexOf(" ") + 1, groupName.Length - groupName.IndexOf(" ") - 1)
            End If
            Logger.AddLogEntry(AppInfo, "xhcp", "List All Determinators")
            s.Send(Encoding.ASCII.GetBytes(XH237))
            Try
                For Each Detrule In Determinator.Rules
                    If Not Detrule.IsGroup Then
                        If groupName = "{ALL}" Or Detrule.GroupName = groupName Then
                            s.Send(Encoding.UTF8.GetBytes(Detrule.RuleGUID & vbTab & Detrule.RuleName & vbTab))
                            If Detrule.Enabled Then
                                s.Send(Encoding.ASCII.GetBytes("Y" & vbCrLf))
                            Else
                                s.Send(Encoding.ASCII.GetBytes("N" & vbCrLf))
                            End If
                        End If
                    End If
                Next
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "xhcp", "Failed to list determinators.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.ToString)
            End Try
            EndMultiLine()
        End Sub

        Private Sub xhcpSetRule(ByVal ruleGuid As String)
            s.Send(Encoding.ASCII.GetBytes(XH338))
            If ruleGuid = "" Then
                ruleGuid = System.Guid.NewGuid.ToString.Replace("-", "")
            End If
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Create a new Determinator called: " & ruleGuid)
                Dim myString As String = GetLine(s)
                Dim fs As TextWriter = File.CreateText(DataFileFolder & "\Determinator\" & ruleGuid & ".xml")
                While Not myString = ("." & vbCrLf)
                    fs.Write(myString)
                    myString = GetLine(s)
                End While
                fs.Close()
                Determinator.LoadRule(ruleGuid)
                s.Send(Encoding.UTF8.GetBytes("238 " & ruleGuid & vbCrLf))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Error creating determinator: " & ruleGuid)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.ToString)
                Try
                    Logger.AddLogEntry(AppError, "xhcp", "Trying to delete temporary file")
                    File.Delete(DataFileFolder & "\Determinator\" & ruleGuid & ".xml")
                Catch ex2 As Exception
                    Logger.AddLogEntry(AppError, "xhcp", "Failed to delete temporary determinator file. ")
                    Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.ToString)
                End Try
            End Try
        End Sub

        Private Sub xhcpGetRule(ByVal ruleGuid As String)
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Get Details for Determinator with GUID: " & ruleGuid)
                If File.Exists(DataFileFolder & "\Determinator\" & ruleGuid & ".xml") Then
                    s.Send(Encoding.ASCII.GetBytes(XH210))
                    Dim str As String
                    Dim myfile As TextReader = File.OpenText(DataFileFolder & "\Determinator\" & ruleGuid & ".xml")
                    str = myfile.ReadLine
                    While Not str Is Nothing
                        s.Send(Encoding.UTF8.GetBytes(str & vbCrLf))
                        str = myfile.ReadLine
                    End While
                    myfile.Close()
                    EndMultiLine()
                Else
                    s.Send(Encoding.ASCII.GetBytes(XH410))
                End If
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Error getting determinator: " & ruleGuid)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.ToString)
            End Try
        End Sub

        Private Sub xhcpDelRule(ByVal ruleGuid As String)
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Delete Determinator with GUID: " & ruleGuid)
                If Determinator.DeleteRule(ruleGuid, True) Then
                    s.Send(Encoding.UTF8.GetBytes(XH214))
                Else
                    s.Send(Encoding.UTF8.GetBytes(XH410))
                End If
            Catch ex As Exception
                s.Send(Encoding.UTF8.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Error deleting determinator: " & ruleGuid)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.ToString)
            End Try
        End Sub

        Private Sub xhcpListScripts(ByVal s As Socket, ByVal params() As String)
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "List all Scripts")
                Dim SOption As SearchOption
                Dim pathName As String = ScriptEngineFolder

                If params.Length = 2 Then
                    If params(1) = "{ALL}" Then
                        SOption = SearchOption.AllDirectories
                    Else
                        SOption = SearchOption.TopDirectoryOnly

                        If Not params(1).Trim.StartsWith("\") Then
                            pathName &= "\" & params(1)
                        Else
                            pathName &= params(1)
                        End If
                    End If
                End If

                Dim d As New DirectoryInfo(pathName)
                Dim dirs() As DirectoryInfo
                Dim f() As FileInfo, Counter As Integer
                Dim sb As New StringBuilder
                sb.Append(XH212)
                dirs = d.GetDirectories("*", SOption)
                f = d.GetFiles
                For Counter = 0 To dirs.Length - 1
                    sb.Append(dirs(Counter).Name & "\" & vbCrLf)
                Next
                For Counter = 0 To f.Length - 1
                    sb.Append(f(Counter).Name & vbCrLf)
                Next
                s.Send(Encoding.ASCII.GetBytes(sb.ToString))
                EndMultiLine()
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Error getting list of scripts. ")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.ToString)
            End Try
        End Sub

        Private Sub xhcpSendXplMsg()
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Send an xPL Message")
                Dim inbuff As String, str As String
                inbuff = ""
                Dim xplMsg As xpllib.XplMsg
                s.Send(Encoding.ASCII.GetBytes(XH313))
                Do
                    str = GetLine(s)
                    If Not str = ("." & vbCrLf) Then
                        inbuff = inbuff & str
                    End If
                Loop Until str = vbCrLf Or str = ("." & vbCrLf)
                inbuff = inbuff.Replace(vbCrLf, Chr(10))
                xplMsg = New xpllib.XplMsg(inbuff)
                xplMsg.Send()
                s.Send(Encoding.ASCII.GetBytes(XH213))
                Logger.AddLogEntry(AppInfo, "xhcp", "xPL Message Sent.")
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to send xPL Message ")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpDelScript(ByVal scriptname As String)
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Delete Script: " & scriptname)
                Dim filename As String = ScriptEngineFolder & "\" & scriptname
                If Not File.Exists(filename) Then
                    s.Send(Encoding.ASCII.GetBytes(XH410))
                Else
                    File.Delete(filename)
                    s.Send(Encoding.ASCII.GetBytes(XH214))
                End If
                Logger.AddLogEntry(AppInfo, "xhcp", "Script Deleted.")
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to Run Script: " & scriptname)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpRunRule(ByVal rulename As String)
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Run Determinator: " & rulename)
                rulename = rulename.Substring(7, rulename.Length - 7).Trim
                Determinator.ExecuteRule(rulename)
                s.Send(Encoding.ASCII.GetBytes(XH203))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Error executing determinator " & rulename)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpRunSub(ByVal scriptName As String, ByVal params As String)
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Run Script: " & scriptName)

                RunScript(scriptName, params)
                s.Send(Encoding.ASCII.GetBytes(XH203))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to Run Script: " & scriptName)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpListSettings()
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "List All Settings")
                s.Send(Encoding.ASCII.GetBytes(XH204))
                For Each setting As CacheEntry In xPLCache.Filtered("xplhal.")
                    s.Send(Encoding.ASCII.GetBytes(setting.ObjectName & vbTab))
                    s.Send(Encoding.ASCII.GetBytes(setting.ObjectValue & vbTab))
                Next
                s.Send(Encoding.ASCII.GetBytes(vbCrLf))
                EndMultiLine()
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to List Settings.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpListOptions(ByVal settingname As String)
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "List Options")
                'Dim Counter As Integer, i As Integer
                'i = CInt(xPLHalSettings(settingname.ToLower()))
                'If i > 0 Then
                '    s.Send(Encoding.ASCII.GetBytes(XH205))
                '    For Counter = 0 To xPLHals(i).ValuesCount
                '        s.Send(Encoding.ASCII.GetBytes(xPLHals(i).Values(Counter).Name & vbTab & xPLHals(i).Values(Counter).Desc & vbCrLf))
                '    Next
                '    s.Send(Encoding.ASCII.GetBytes("." & vbCrLf))
                'Else
                s.Send(Encoding.ASCII.GetBytes(XH405))
                'End If
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to List Options.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpSetSetting(ByVal SettingName As String, ByVal SettingValue As String)
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Set Global Cache Entry for: " & SettingName)
                SettingName = "xplhal." & SettingName
                If Not xPLCache.Contains(SettingName) Then
                    s.Send(Encoding.ASCII.GetBytes(XH405))
                Else
                    SettingValue = SettingValue.Substring(10, SettingValue.Length - 10)
                    SettingValue = SettingValue.Substring(SettingName.Length + 1, SettingValue.Length - SettingName.Length - 1)
                    s.Send(Encoding.ASCII.GetBytes(XH206))
                    xPLCache.ObjectValue(SettingName) = SettingValue
                    Logger.AddLogEntry(AppInfo, "xhcp", "Set Global Cache Entry:" & SettingName & " to: " & SettingValue)
                End If

            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppWarn, "xhcp", "Failed to Set Global Cache Entry for:" & SettingName)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try

        End Sub

        Private Sub xhcpGetSetting(ByVal ObjectName As String)
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Get Setting with name: " & ObjectName)
                ObjectName = "xplhal." & ObjectName
                If Not xPLCache.Contains(ObjectName) Then
                    s.Send(Encoding.ASCII.GetBytes(XH405))
                Else
                    s.Send(Encoding.ASCII.GetBytes(XH208))
                    s.Send(Encoding.ASCII.GetBytes(xPLCache.ObjectValue(ObjectName).ToString))
                    s.Send(Encoding.ASCII.GetBytes(vbCrLf))
                    EndMultiLine()
                End If
                Logger.AddLogEntry(AppInfo, "xhcp", "Global Cache Entry Requested:" & ObjectName)
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Cannot access Global Cache" & ObjectName)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub



        Private Sub xhcpGetErrLog()
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Get xPLHal Error Log")
                s.Send(Encoding.ASCII.GetBytes(XH207))
                'If File.Exists(xPLHalRootFolder & "\xplhal.log") Then
                '    Dim fs As TextReader = File.OpenText(xPLHalRootFolder & "\xplhal.log")
                'Dim myString As String = fs.ReadLine()
                Dim myString As String = "In this version of xPLHal Server, the log cannot be viewed when the service is running."
                myString = myString & "the log can be viewed at:" & xPLHalRootFolder & "\xplhal.log on the xPLHal server."
                'While Not myString Is Nothing
                '    s.Send(Encoding.ASCII.GetBytes(myString & vbCrLf))
                '    myString = fs.ReadLine
                'End While
                'fs.Close()
                'End If
                EndMultiLine()
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to Read Error log.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub


        Private Sub EndMultiLine()
            s.Send(Encoding.ASCII.GetBytes("." & vbCrLf))
        End Sub

        Private Sub xhcpGetConfigXml()
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Get xPLHal Configuration from XML File")
                Dim fs As TextReader = File.OpenText(DataFileFolder & "\xplhal.xml")
                Dim myString As String = fs.ReadLine()
                s.Send(Encoding.ASCII.GetBytes(XH209))
                While Not myString Is Nothing
                    s.Send(Encoding.ASCII.GetBytes(myString & vbCrLf))
                    myString = fs.ReadLine()
                End While
                fs.Close()
                EndMultiLine()
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to Read xPLHal Configuration.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpPutConfigXml()
            'Try
            '    Dim filename As String = Path.GetTempFileName
            '    Dim str As String
            '    Dim fs As TextWriter = File.CreateText(filename)
            '    s.Send(Encoding.ASCII.GetBytes(XH315))
            '    Do
            '        str = GetLine(s)
            '        If Not str = ("." & vbCrLf) Then
            '            fs.Write(str)
            '        End If
            '    Loop Until str = ("." & vbCrLf) Or str = ""
            '    fs.Close()
            '    File.Copy(DataFileFolder & "\xplhal.xml", DataFileFolder & "\xplhal.xml.old", True)
            '    File.Copy(filename, DataFileFolder & "\xplhal.xml", True)
            '    File.Delete(filename)
            '    LoadSettings(True)
            '    s.Send(Encoding.ASCII.GetBytes(XH215))
            'Catch ex As Exception
            '   Logger.AddLogEntry(AppInfo,"xhcp", "PutConfigXml(): " & ex.ToString())
            '    s.Send(Encoding.ASCII.GetBytes(XH503))
            'End Try
        End Sub

        Private Sub xhcpGetDevConfigValue(ByVal deviceName As String, ByVal valueName As String)
            Try
                s.Send(Encoding.ASCII.GetBytes(XH234))
                Logger.AddLogEntry(AppInfo, "xhcp", "Get value of setting: " & valueName & " for Device: " & deviceName)
                Dim entry = xPLCache.ObjectValue("config." & deviceName & ".current." & valueName)
                If entry IsNot Nothing Then
                    Dim configval As String = valueName.Trim & "=" & entry.Trim
                    s.Send(Encoding.ASCII.GetBytes(configval & vbCrLf))
                End If
                EndMultiLine()

            Catch ex As Exception
                Logger.AddLogEntry(AppError, "xhcp", "Failed to retrieve Config for device: " & deviceName)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpListAllDevs()
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Listing All xPLDevices.")
                s.Send(Encoding.UTF8.GetBytes(XH216))
                For Each device In DevManager.AllDevices
                    s.Send(Encoding.UTF8.GetBytes(device.VDI & vbCrLf))
                Next
                EndMultiLine()
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "xhcp", "Failed while listing xPLDevices.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpListDevices(ByVal params() As String)
            Try
                Dim param As String
                Dim ShowDevice As Boolean
                If params.Length = 2 Then
                    param = params(1).ToLower()
                Else
                    param = ""
                End If

                Logger.AddLogEntry(AppInfo, "xhcp", "Listing xPLDevices with Parameters.")
                s.Send(Encoding.ASCII.GetBytes(XH216))
                For Each device In DevManager.AllDevices
                    ShowDevice = True
                    If param = "awaitingconfig" And Not device.ConfigType Then
                        ShowDevice = False
                    End If
                    If param = "configured" And device.ConfigType Then
                        ShowDevice = False
                    End If

                    If param = "missingconfig" And Not device.ConfigMissing Then
                        ShowDevice = False
                    End If

                    If ShowDevice And Not device.Suspended Then
                        s.Send(Encoding.ASCII.GetBytes(device.VDI & vbTab))
                        s.Send(Encoding.ASCII.GetBytes(device.Expires.ToString() & vbTab))
                        s.Send(Encoding.ASCII.GetBytes(device.Interval.ToString() & vbTab))

                        ' COnfig type
                        If device.ConfigType Then
                            s.Send(Encoding.ASCII.GetBytes("Y" & vbTab))
                        Else
                            s.Send(Encoding.ASCII.GetBytes("N" & vbTab))
                        End If

                        ' Config done
                        If device.ConfigDone Then
                            s.Send(Encoding.ASCII.GetBytes("Y" & vbTab))
                        Else
                            s.Send(Encoding.ASCII.GetBytes("N" & vbTab))
                        End If

                        ' Waiting config
                        If device.WaitingConfig Then
                            s.Send(Encoding.ASCII.GetBytes("Y" & vbTab))
                        Else
                            s.Send(Encoding.ASCII.GetBytes("N" & vbTab))
                        End If

                        ' Suspended
                        If device.Suspended Then
                            s.Send(Encoding.ASCII.GetBytes("Y" & vbTab))
                        Else
                            s.Send(Encoding.ASCII.GetBytes("N" & vbTab))
                        End If

                        s.Send(Encoding.ASCII.GetBytes(vbCrLf))
                    End If
                Next
                EndMultiLine()
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "xhcp", "Failed while listing xPLDevices.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
                s.Send(Encoding.ASCII.GetBytes(XH503))
            End Try
        End Sub

        Private Sub xhcpGetDevConfig(ByVal devname As String)
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Listing config for Device:" & devname)
                devname = devname.ToLower()
                If Not DevManager.Contains(devname) Then
                    s.Send(Encoding.ASCII.GetBytes(XH417))
                    Exit Sub
                End If
                'If Not DevManager.CheckVendor(devname) Then
                '    s.Send(Encoding.ASCII.GetBytes(XH418))
                '    Exit Sub
                'End If

                Dim targetdevice As xPLDevice = DevManager.GetDevice(devname)
                If targetdevice.ConfigSource = "" Then
                    SendStatusLine(XH416)
                    Exit Sub
                End If
                s.Send(Encoding.ASCII.GetBytes(XH217))

                ' Read the config "file"
                Dim rgxConfig As New Regex("config\." & devname & "\.options.([a-z0-9]{1,16})")

                Dim strMsg As String = ""
                For Each entry As CacheEntry In xPLCache.FilterbyRegEx(rgxConfig)
                    Dim nameparts As String() = rgxConfig.Split(entry.ObjectName)
                    If nameparts.Length >= 2 Then
                        If nameparts(2) = "" Then  'only interested in the root config option.
                            Dim confName As String = nameparts(1)
                            Dim confType As String = xPLCache.ObjectValue(entry.ObjectName & ".type")
                            Dim confCount As String = xPLCache.ObjectValue(entry.ObjectName & ".count")
                            s.Send(Encoding.ASCII.GetBytes(confName & vbTab & confType & vbTab & confCount & vbCrLf))
                        End If
                    End If
                Next

                EndMultiLine()
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to get Dev Config.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpListSingleEvents()
            Try
                s.Send(Encoding.ASCII.GetBytes(XH218))
                For Each evententry As xPLEvent In EventLauncher.ListAllEvents("single")
                    With evententry
                        s.Send(Encoding.ASCII.GetBytes(.Tag & vbTab))
                        s.Send(Encoding.ASCII.GetBytes(.RunSub & vbTab))
                        s.Send(Encoding.ASCII.GetBytes(.Param & vbTab))

                        s.Send(Encoding.ASCII.GetBytes(.StartTime.ToString("HH:mm") & vbTab))
                        s.Send(Encoding.ASCII.GetBytes(.EndTime.ToString("HH:mm") & vbTab))
                        s.Send(Encoding.ASCII.GetBytes(.DoW & vbTab))
                        s.Send(Encoding.UTF8.GetBytes(vbTab))
                    End With
                    s.Send(Encoding.ASCII.GetBytes(vbCrLf))
                Next
                EndMultiLine()
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to List Single Issue Events")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpListEvents()
            Try
                s.Send(Encoding.ASCII.GetBytes(XH218))
                For Each evententry As xPLEvent In EventLauncher.ListAllEvents("recurring")
                    With evententry
                        s.Send(Encoding.ASCII.GetBytes(.Tag & vbTab))
                        s.Send(Encoding.ASCII.GetBytes(.RunSub & vbTab))
                        s.Send(Encoding.ASCII.GetBytes(.Param & vbTab))

                        s.Send(Encoding.ASCII.GetBytes(.StartTime.ToString("HH:mm") & vbTab))
                        s.Send(Encoding.ASCII.GetBytes(.EndTime.ToString("HH:mm") & vbTab))
                        s.Send(Encoding.ASCII.GetBytes(.DoW & vbTab))
                        s.Send(Encoding.UTF8.GetBytes(.EventRunTime.ToString("dd/MMM/yyyy HH:mm") & vbTab))
                    End With
                    s.Send(Encoding.ASCII.GetBytes(vbCrLf))
                Next
                EndMultiLine()
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to List All Events")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpPutDevConfig(ByVal vdi As String)
            Try
                Dim str As String, buff As String = ""
                vdi = vdi.ToLower()
                If Not DevManager.Contains(vdi) Then
                    s.Send(Encoding.ASCII.GetBytes(XH417))
                    Exit Sub
                End If

                s.Send(Encoding.ASCII.GetBytes(XH320))
                Do
                    str = GetLine(s)
                    If Not str = "" And Not str = ("." & vbCrLf) Then
                        buff &= str
                    End If
                Loop Until str = "" Or str = ("." & vbCrLf)

                'This needs to be rewritten to update the GOC, 
                'then flush the device changes from there to the device using a config.response message.


                DevManager.StoreNewConfig(vdi, buff)
                s.Send(Encoding.ASCII.GetBytes(XH220))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to set Device Config.")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpAddSingleEvent()
            Try
                Dim evTag, evSubName, evParams As String, evDate As Date
                evSubName = ""
                evParams = ""
                evTag = ""
                Dim str As String, LHS As String, RHS As String
                s.Send(Encoding.ASCII.GetBytes(XH319))
                Do
                    str = GetLine(s)
                    If str.IndexOf("=") > 0 Then
                        LHS = str.Substring(0, str.IndexOf("="))
                        RHS = Right(str, Len(str) - InStr(str, "="))
                        RHS = RHS.Replace(vbCrLf, "")
                        Select Case LHS.ToLower
                            Case "date"
                                evDate = CDate(RHS)
                            Case "params"
                                evParams = RHS
                            Case "subname"
                                evSubName = RHS
                            Case "tag"
                                evTag = RHS
                        End Select
                    End If
                Loop Until str = "" Or str = ("." & vbCrLf)

                EventLauncher.Add(EventLauncher.BuildSingleEvent(evDate, evSubName, evParams, evTag))
                s.Send(Encoding.ASCII.GetBytes(XH219))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to Add Single Issue Event")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpAddEvent()
            Try
                Dim evTag As String = "", evSubName As String = "", evParams As String = "", evStartTIme As String = "", evEndTime As String = "", evInterval As String = "", evRand As String = "", evDow As String = "", evDate As String = ""
                Dim str As String, LHS As String, RHS As String
                s.Send(Encoding.ASCII.GetBytes(XH319))
                Do
                    str = GetLine(s)
                    If str.IndexOf("=") > 0 Then
                        LHS = str.Substring(0, str.IndexOf("="))
                        RHS = Right(str, Len(str) - InStr(str, "="))
                        RHS = RHS.Replace(vbCrLf, "")
                        Select Case LHS.ToLower
                            Case "dow"
                                evDow = RHS
                            Case "endtime"
                                evEndTime = RHS
                            Case "interval"
                                evInterval = RHS
                            Case "params"
                                evParams = RHS
                            Case "rand"
                                evRand = RHS
                            Case "starttime"
                                evStartTIme = RHS
                            Case "subname"
                                evSubName = RHS
                            Case "tag"
                                evTag = RHS
                            Case "date"
                                evDate = RHS
                        End Select
                    End If
                Loop Until str = "" Or str = ("." & vbCrLf)

                If evDate = "" Then
                    evDow = evDow.Replace("1", "Y").Replace("0", "N")
                    EventLauncher.Add(EventLauncher.BuildRecurringEvent(evStartTIme, evEndTime, CInt(evInterval), CInt(evRand), evDow, evSubName, evParams, evTag, True))
                Else
                    EventLauncher.Add(EventLauncher.BuildSingleEvent(CDate(evDate), evSubName, evParams, evTag))
                End If
                s.Send(Encoding.ASCII.GetBytes(XH219))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to Add Recurring Event")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpGetEvent(ByVal evTag As String)
            Try
                Dim eventEntry As xPLEvent = EventLauncher.GetEvent(evTag.Trim)
                If eventEntry IsNot Nothing Then
                    With eventEntry
                        s.Send(Encoding.ASCII.GetBytes(XH222))
                        s.Send(Encoding.ASCII.GetBytes("tag=" & .Tag & vbCrLf))
                        s.Send(Encoding.ASCII.GetBytes("subname=" & .RunSub & vbCrLf))
                        s.Send(Encoding.ASCII.GetBytes("params=" & .Param & vbCrLf))
                        If .Recurring Then
                            s.Send(Encoding.ASCII.GetBytes("starttime=" & .StartTime.ToString("HH:mm:ss") & vbCrLf))
                            s.Send(Encoding.ASCII.GetBytes("endtime=" & .EndTime.ToString("HH:mm:ss") & vbCrLf))
                            s.Send(Encoding.ASCII.GetBytes("interval=" & .Interval & vbCrLf))
                            s.Send(Encoding.ASCII.GetBytes("rand=" & .RandomTime & vbCrLf))
                            s.Send(Encoding.ASCII.GetBytes("dow=" & .DoW & vbCrLf))
                        Else
                            s.Send(Encoding.ASCII.GetBytes("date=" & .EventDateTime.ToString("dd-MMM-yyyy HH:mm") & vbCrLf))
                        End If
                        s.Send(Encoding.ASCII.GetBytes("runtime=" & .EventRunTime.ToString("dd/MMM/yyyy HH:mm") & vbCrLf))
                    End With
                    EndMultiLine()
                Else
                    s.Send(Encoding.ASCII.GetBytes(XH422))
                    Exit Sub
                End If
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to Retrieve Event from Event Launcher")
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpDeleteEvent(ByVal evTag As String)
            Try
                Dim eventEntry As xPLEvent = EventLauncher.GetEvent(evTag.Trim)
                If eventEntry IsNot Nothing Then
                    EventLauncher.Remove(evTag)
                    s.Send(Encoding.ASCII.GetBytes(XH223))
                Else
                    s.Send(Encoding.ASCII.GetBytes(XH422))
                End If
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Failed to Remove Event: " & evTag)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpListSubs()
            If ScriptLoader.xplScripts IsNot Nothing Then
                Try
                    Logger.AddLogEntry(AppInfo, "xhcp", "List of all Subs Requested")
                    s.Send(Encoding.ASCII.GetBytes(XH224))
                    For Each xscript As ScriptLoader.ScriptDetail In ScriptLoader.xplScripts
                        Dim scriptname As String = xscript.ScriptName
                        For Each func As KeyValuePair(Of String, String) In xscript.Functions
                            's.Send(Encoding.ASCII.GetBytes(scriptname.ToLower() & vbTab & func.Key.ToLower() & vbTab & func.Value & vbCrLf))
                            s.Send(Encoding.ASCII.GetBytes(scriptname.ToLower() & "$" & func.Key.ToLower() & vbCrLf))
                        Next
                    Next
                    EndMultiLine()
                Catch ex As Exception
                    s.Send(Encoding.ASCII.GetBytes(XH503))
                    Logger.AddLogEntry(AppError, "xhcp", "Failed to Access scriptcache")
                    Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
                End Try
            Else
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "ScriptCache Has not been initialised")
            End If
        End Sub

        Private Sub xhcpListSubsEx()
            If ScriptLoader.xplScripts IsNot Nothing Then
                Try
                    Logger.AddLogEntry(AppInfo, "xhcp", "List of all Subs Requested (extended)")
                    s.Send(Encoding.ASCII.GetBytes(XH224))
                    For Each xscript As ScriptLoader.ScriptDetail In ScriptLoader.xplScripts
                        Dim scriptname As String = xscript.ScriptName
                        For Each func As KeyValuePair(Of String, String) In xscript.Functions
                            s.Send(Encoding.ASCII.GetBytes(scriptname.ToLower() & vbTab & func.Key.ToLower() & vbTab & func.Value & vbCrLf))
                        Next
                    Next
                    EndMultiLine()
                Catch ex As Exception
                    s.Send(Encoding.ASCII.GetBytes(XH503))
                    Logger.AddLogEntry(AppError, "xhcp", "Failed to Access scriptcache")
                    Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
                End Try
            Else
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "ScriptCache Has not been initialised")
            End If
        End Sub

        Private Sub xhcpGetGlobal(ByVal ObjectName As String) ' trt
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Global Cache Entry Requested:" & ObjectName)
                ObjectName = ObjectName
                If Not xPLCache.Contains(ObjectName) Then
                    s.Send(Encoding.ASCII.GetBytes(XH491))
                    Logger.AddLogEntry(AppWarn, "xhcp", "Global Cache Entry Not Found")
                Else
                    s.Send(Encoding.ASCII.GetBytes(XH291))
                    s.Send(Encoding.ASCII.GetBytes(xPLCache.ObjectValue(ObjectName).ToString))
                    s.Send(Encoding.ASCII.GetBytes(vbCrLf))
                    EndMultiLine()
                End If
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppWarn, "xhcp", "Cannot access Global Cache" & ObjectName)
                Logger.AddLogEntry(AppError, "xhcp", "Cause: " & ex.Message())
            End Try
        End Sub

        Private Sub xhcpSetGlobal(ByVal ObjectName As String, ByVal ObjectValue As String)
            Try
                ObjectName = ObjectName
                ObjectValue = ObjectValue.Substring(10, ObjectValue.Length - 10)
                ObjectValue = ObjectValue.Substring(ObjectName.Length + 1, ObjectValue.Length - ObjectName.Length - 1)
                s.Send(Encoding.ASCII.GetBytes(XH232))
                xPLCache.Add(ObjectName, ObjectValue, False)
                Logger.AddLogEntry(AppInfo, "xhcp", "Set Global Cache Entry:" & ObjectName & " to: " & ObjectValue)
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppWarn, "xhcp", "Failed to Set Global Cache Entry for:" & ObjectName)
                Logger.AddLogEntry(AppWarn, "xhcp", "Cause:" & ex.Message)
            End Try
        End Sub

        Private Sub xhcplistx10states(ByVal location As String)  ' trt
            Try
                s.Send(Encoding.ASCII.GetBytes(XH405))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
            End Try
        End Sub

        Private Sub xhcpClearErrLog()
            Try
                'If File.Exists(DataFileFolder & "\error_log.txt") Then
                '    File.Delete(DataFileFolder & "\error_log.txt")
                'End If
                s.Send(Encoding.ASCII.GetBytes(XH225))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
            End Try
        End Sub

        Private Sub xhcpAddX10Device()
            Try
                s.Send(Encoding.ASCII.GetBytes(XH405))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
            End Try
        End Sub

        Private Sub xhcpGetX10Device(ByVal devicename As String)
            Try
                s.Send(Encoding.ASCII.GetBytes(XH405))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
            End Try
        End Sub

        Private Sub xhcpDelX10Device(ByVal address As String)
            Try
                s.Send(Encoding.ASCII.GetBytes(XH405))
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
            End Try
        End Sub

        Private Sub xhcpGetSub(ByVal subname As String)
            Try
                If Not ScriptLoader.xplScripts.Contains(subname) Then
                    s.Send(Encoding.ASCII.GetBytes(XH429))
                Else
                    Dim struc As ScriptLoader.ScriptDetail, fs As TextReader, myString As String, b As Boolean = False, mySub As String
                    struc = CType(ScriptLoader.xplScripts.Item(subname), ScriptLoader.ScriptDetail)
                    s.Send(Encoding.ASCII.GetBytes(XH229))
                    fs = File.OpenText(struc.Source)
                    myString = fs.ReadLine
                    While Not myString Is Nothing
                        If Not b Then
                            ' We're looking for the start of the sub/function
                            If myString.Trim.ToLower.StartsWith("sub ") Or myString.Trim.ToLower.StartsWith("function ") Then
                                ' Get the name and see if it's the one we're looking for
                                mySub = myString.Trim.ToLower
                                mySub = Right(mySub, Len(mySub) - InStr(mySub, " "))
                                If mySub.StartsWith(subname.ToLower & "(") Or mySub.StartsWith(subname.ToLower & " ") Or mySub = subname.ToLower Then
                                    b = True
                                End If
                            End If
                        End If
                        If b Then
                            s.Send(Encoding.ASCII.GetBytes(myString & vbCrLf))
                            If myString.ToLower.Trim.StartsWith("end sub") Or myString.ToLower.Trim.StartsWith("end function") Then
                                b = False
                            End If
                        End If

                        myString = fs.ReadLine
                    End While
                    fs.Close()
                    EndMultiLine()
                End If
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH501))
            End Try
        End Sub

        Private Sub xhcpDelDevConfig(ByVal devName As String)
            Try
                For Each entry As CacheEntry In xPLCache.ChildNodes("config." & devName)
                    xPLCache.Remove(entry.ObjectName)
                Next
                SendStatusLine(XH235)
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
            End Try
        End Sub

        Private Sub xhcpMode(ByVal mmm As String)
            Try
                Select Case mmm.ToLower
                    Case "norm"
                        xMode = xplHalModes.Norm
                        s.Send(xhcpEngine.WelcomeBanner)
                    Case "repl"
                        Try
                            xMode = xplHalModes.Repl
                            s.Send(Encoding.ASCII.GetBytes(xh230))
                            ReplClient = s
                            FullReplication()
                            While s.Connected And Not DoQuit
                                Thread.Sleep(10000)
                                PartialReplication()
                            End While
                        Catch ex As Exception
                        End Try
                        ReplClient = Nothing
                    Case Else
                        s.Send(Encoding.ASCII.GetBytes(XH501))
                End Select
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
            End Try
        End Sub

        Public Shared Sub NeedToReplicateFile(ByVal filename As String)
            ReplFilesMutex.WaitOne()
            ReDim Preserve ReplFiles(ReplFiles.Length)
            ReplFiles(ReplFiles.Length - 1) = filename
            ReplFilesMutex.ReleaseMutex()
        End Sub

        Public Shared Sub InitReplication()
            If xPLHalMaster = "" Then
                ReplFilesMutex.WaitOne()
                ReDim ReplFiles(-1)
                ReplFilesMutex.ReleaseMutex()
            Else
                Dim s As New Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp)
                Dim str, filename As String
                Dim filesize As Integer
                While Not DoQuit
                    Try
                        s.Connect(New IPEndPoint(Dns.GetHostEntry(xPLHalMaster).AddressList(0), 3865))
                        ' OK, I'm not it anymore.
                        str = GetLine(s)
                        If str.StartsWith("200") Then
                            _xPLHalActive = False
                        End If
                        s.Send(Encoding.UTF8.GetBytes("MODE REPL" & vbCrLf))
                        str = GetLine(s)
                        While s.Connected
                            str = GetLine(s)
                            If str.StartsWith("600") Then
                                filename = GetLine(s)
                                filesize = CInt(GetLine(s))
                                Dim fs As FileStream = File.Open(DataFileFolder & "\" & filename, FileMode.Create)
                                Dim buff(filesize) As Byte
                                Dim totalbytes As Integer = 0, bytes_read As Integer
                                While totalbytes < filesize
                                    bytes_read = s.Receive(buff, totalbytes, filesize - totalbytes, SocketFlags.None)
                                    totalbytes += bytes_read
                                End While
                                fs.Write(buff, 0, filesize)
                                fs.Close()
                            End If
                        End While
                    Catch ex As Exception
                        _xPLHalActive = True
                        s.Close()
                        ' OK, I'm it!
                        Thread.Sleep(30000)
                    End Try
                End While
            End If
        End Sub

        Private Shared Sub PartialReplication()
            Dim Counter As Integer
            ReplFilesMutex.WaitOne()
            For Counter = 0 To ReplFiles.Length - 1
                PushFile(ReplFiles(Counter))
            Next
            ReDim ReplFiles(-1)
            ReplFilesMutex.ReleaseMutex()
        End Sub

        Private Shared Sub FullReplication()
            ' THis sub replicates all data to the replication client
            ReplFilesMutex.WaitOne()
            ReDim ReplFiles(-1)
            Dim Counter As Integer


            ' Send all scripts
            Dim files() As String
            files = Directory.GetFiles(DataFileFolder & "\scripts")
            For Counter = 0 To files.Length - 1

                PushFile("scripts\" & Path.GetFileName(files(Counter)))
            Next
            files = Directory.GetFiles(DataFileFolder & "\scripts\headers")
            For Counter = 0 To files.Length - 1
                PushFile("scripts\headers\" & Path.GetFileName(files(Counter)))
            Next
            files = Directory.GetFiles(DataFileFolder & "\scripts\user")
            For Counter = 0 To files.Length - 1
                PushFile("scripts\user\" & Path.GetFileName(files(Counter)))
            Next
            ReplFilesMutex.ReleaseMutex()
        End Sub

        Private Shared Sub PushFile(ByVal filename As String)
            If ReplClient Is Nothing Then Exit Sub
            Try
                Dim fs As FileStream = File.Open(DataFileFolder & "\" & filename, FileMode.Open)
                ReplClient.Send(Encoding.ASCII.GetBytes(XH600))
                ReplClient.Send(Encoding.ASCII.GetBytes(filename & vbCrLf))
                ReplClient.Send(Encoding.ASCII.GetBytes(fs.Length.ToString & vbCrLf))
                Dim buff(CInt(fs.Length) - 1) As Byte
                fs.Read(buff, 0, CInt(fs.Length))
                ReplClient.Send(buff)
                fs.Close()
            Catch ex As Exception
            End Try
        End Sub

        Private Sub xhcpListGlobals()
            Try
                Logger.AddLogEntry(AppInfo, "xhcp", "Listing all Objects in Global Cache")
                s.Send(Encoding.ASCII.GetBytes(XH231))
                s.Send(Encoding.ASCII.GetBytes(xPLCache.ListAllObjects))
                EndMultiLine()
            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppError, "xhcp", "Cannot access Global Cache")
            End Try
        End Sub

        Private Sub xhcpDelGlobal(ByVal ObjectName As String)
            Try
                xPLCache.Remove(ObjectName)
                s.Send(Encoding.ASCII.GetBytes(XH233))
                Logger.AddLogEntry(AppInfo, "xhcp", "Deleted Entry From Global Cache:" & ObjectName)

            Catch ex As Exception
                s.Send(Encoding.ASCII.GetBytes(XH503))
                Logger.AddLogEntry(AppWarn, "xhcp", "Failed to Delete Entry From Global Cache:" & ObjectName)
            End Try
        End Sub

        Public Function CharCount(ByVal s As String, ByVal charToFind As String) As Integer
            Dim i As Integer = 0
            For Counter As Integer = 0 To s.Length - 1
                If s.Substring(Counter, 1) = charToFind Then
                    i += 1
                End If
            Next
            Return i
        End Function

        Public Function RenameOldScriptIfExists(ByVal filename As String) As Boolean
            If Not File.Exists(filename) Then Return False
            Dim i As Integer = 1

            'rename .ps1 to ps1.x.bak
            Do
                If Not File.Exists(filename & "." & i.ToString() & ".bak") Then
                    File.Move(filename, filename & "." & i.ToString() & ".bak")
                    Return True
                Else
                    i = i + 1
                End If
            Loop
        End Function
    End Class
End Class
