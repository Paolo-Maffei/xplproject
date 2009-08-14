'* xPLHal Control Protocol
'*
'* Version 1.2 Revision 21
'*
'* Copyright (C) 2003-2004 John Bent & Tony Tofts
'* http://www.xplhal.com/
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
Option Strict On

Imports System.IO
Imports System.Net
Imports System.Net.Sockets
Imports System.Text
Imports System.Threading

Public Class xhcp

    Public Shared WelcomeBanner() As Byte
    Public Shared Password As String
    Private Const XHCP_PORT As Integer = 3865
  Private Sock As Socket
  Public Shared ThreadCollection As Collection

    Public Shared EnableLogging As Boolean

  Public Sub New()
    ThreadCollection = New Collection
    If xPLHalMaster = "" Then
      ' We are the master server
      Password = ""
      WelcomeBanner = Encoding.UTF8.GetBytes("200 " & xPLHalSource & " Version " & System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString() & " XHCP 1.5.0" & vbCrLf)
      xhcpThread.InitReplication()
      Sock = New Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp)
      Sock.Bind(New IPEndPoint(IPAddress.Any, XHCP_PORT))
      Sock.Listen(10)
      Sock.BeginAccept(New AsyncCallback(AddressOf Sock_Accept), Sock)
    Else
      ' COnnect to our master server
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
      c.EnableLogging = EnableLogging
      t.Start()
      ThreadCollection.Add(c, c.GUID)
    Catch ex As Exception
    End Try
    Sock.BeginAccept(New AsyncCallback(AddressOf Sock_Accept), Sock)
  End Sub

  Public Sub StopXHCP()    
    Try
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
    Public EnableLogging As Boolean

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
            If xhcp.Password = "" Then
                IsAuthenticated = True
            Else
                IsAuthenticated = False
            End If
            ' Send the welcome banner
            s.Send(xhcp.WelcomeBanner)
            If EnableLogging Then
                xhcpLog.LogEvent("Connection accepted.")
            End If

            Do
                str = GetLine(s)
                If DoQuit Then
                    onQuit = True
                    s.Close()
                    Exit Sub
                End If
                str = str.Substring(0, str.Length - 2)
                If EnableLogging Then
                    xhcpLog.LogEvent("<-- " & str)
                End If
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
                                    If System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(params(1), "SHA1") = xhcp.Password Then
                                        IsAuthenticated = True
                                        s.Send(xhcp.WelcomeBanner)
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
                                                xhcpsetrule(params(1))
                                            Else
                                                xhcpsetRule("")
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
                      If params.Length <> 2 Then
                        xhcpSyntaxError()
                      Else
                        xhcpDelRule(params(1))
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
                      s.Send(Encoding.ASCII.GetBytes(XH202 & xPLHalSource & vbCrLf))
                      'Case "getsub"
                      'If params.Length = 2 Then
                      'xhcpGetSub(params(1))
                      'Else
                      'xhcpSyntaxError()
                      'End If
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
                      If InitScripts() Then
                        s.Send(Encoding.ASCII.GetBytes(XH201))
                      Else
                        s.Send(Encoding.ASCII.GetBytes(XH401))
                      End If
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
                    Case "sendxapmsg"
                      xhcpSendxAPMsg()
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

            s.Send(Encoding.ASCII.GetBytes(XH221))
        Catch ex As Exception
        End Try
        s.Close()
        If xMode = xplHalModes.Repl Then
            ReplClient = Nothing
    End If
    xhcp.ThreadCollection.Remove(GUID)
    End Sub

  Private Sub xhcpStatus()
    s.Send(Encoding.ASCII.GetBytes(XH239))
    s.Send(Encoding.ASCII.GetBytes("threadcollectionsize=" & xhcp.ThreadCollection.Count.ToString & vbCrLf))
    s.Send(Encoding.ASCII.GetBytes("total_messages=" & TotalMessagesRx & vbCrLf))
    EndMultiLine()
  End Sub

  Private Sub xhcpListRuleGroups()
    s.Send(Encoding.ASCII.GetBytes(XH240))
    Try
      Dim NestedLevel As Integer = 0
      Dim FoundGroup As Boolean
      Do
        FoundGroup = False
        For Counter As Integer = 0 To Determinator.RuleCount - 1
          If xplDeterminator.Rules(Counter).IsGroup Then
            If CharCount(xplDeterminator.Rules(Counter).RuleName, "/") = NestedLevel Then
              s.Send(Encoding.UTF8.GetBytes(Determinator.Rule(Counter).RuleGUID & vbTab & Determinator.Rule(Counter).RuleName & vbTab & vbCrLf))
              FoundGroup = True
            End If
          End If
        Next
        NestedLevel += 1
      Loop Until Not FoundGroup
    Catch ex As Exception
    End Try
    EndMultiLine()
  End Sub

  Private Sub xhcpCapabilities(ByVal subSystem As String)
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
    ' xAP support enabled?
    If xAPSupport Then
      s.Send(Encoding.ASCII.GetBytes("1"))
    Else
      s.Send(Encoding.ASCII.GetBytes("0"))
    End If
    ' Scripting language, determinators, events and server platform
    s.Send(Encoding.ASCII.GetBytes("V11W0"))

    s.Send(Encoding.ASCII.GetBytes(vbCrLf))
    If Not subSystem Is Nothing Then
      Select Case subSystem.ToLower()
        Case "scripting"
          s.Send(Encoding.ASCII.GetBytes("V" & vbTab & "VBScript" & vbTab & "5.6" & vbTab & "vbs" & vbTab & "http://msdn2.microsoft.com/en-us/library/t0aew7h6.aspx" & vbCrLf))
      End Select
      EndMultiLine()
    End If
  End Sub

  Private Sub xhcpSyntaxError()
    s.Send(Encoding.ASCII.GetBytes(XH501))
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
    Loop Until inbuff.IndexOf(vbCrLf) >= 0 Or inbuff = ""
    Return (inbuff)
  End Function

  Private Sub xhcpGetScript(ByVal scriptname As String)
    scriptname = scriptname.Substring(scriptname.IndexOf(" ") + 1, scriptname.Length - scriptname.IndexOf(" ") - 1)
    Dim filename As String = xPLHalScripts & "\" & scriptname
    If Not File.Exists(filename) Then
      s.Send(Encoding.ASCII.GetBytes(XH410))
    Else
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
    End If
  End Sub

  Private Sub xhcpPutScript(ByVal s As Socket, ByVal scriptname As String)
    Try
      Dim fs As TextWriter
      Dim myString As String
      fs = File.CreateText(xPLHalScripts & "\" & scriptname)
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
      xhcpLog.LogEvent("err (PutScript()): " & ex.ToString())
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpListRules(ByVal groupName As String)
    If Not groupName = String.Empty Then
      groupName = groupName.Substring(groupName.IndexOf(" ") + 1, groupName.Length - groupName.IndexOf(" ") - 1)
    End If
    s.Send(Encoding.ASCII.GetBytes(XH237))
    Try
      For Counter As Integer = 0 To Determinator.RuleCount - 1
        If Not xplDeterminator.Rules(Counter).IsGroup Then
          If groupName = "{ALL}" Or xplDeterminator.Rules(Counter).GroupName = groupName Then
            s.Send(Encoding.UTF8.GetBytes(Determinator.Rule(Counter).RuleGUID & vbTab & Determinator.Rule(Counter).RuleName & vbTab))
            If Determinator.Rule(Counter).Enabled Then
              s.Send(Encoding.ASCII.GetBytes("Y" & vbCrLf))
            Else
              s.Send(Encoding.ASCII.GetBytes("N" & vbCrLf))
            End If
          End If
        End If
      Next
    Catch ex As Exception
    End Try
    EndMultiLine()
  End Sub

  Private Sub xhcpSetRule(ByVal ruleGuid As String)
    s.Send(Encoding.ASCII.GetBytes(XH338))
    If ruleGuid = "" Then
      ruleGuid = System.Guid.NewGuid.ToString.Replace("-", "")
    End If
    Try
      Dim myString As String = GetLine(s)
      Dim fs As TextWriter = File.CreateText(xPLHalData & "\Determinator\" & ruleGuid & ".xml")
      While Not myString = ("." & vbCrLf)
        fs.Write(myString)
        myString = GetLine(s)
      End While
      fs.Close()
      Determinator.LoadRule(ruleGuid)
      s.Send(Encoding.UTF8.GetBytes("238 " & ruleGuid & vbCrLf))
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
      Try
        File.Delete(xPLHalData & "\Determinator\" & ruleGuid & ".xml")
      Catch ex2 As Exception
      End Try
    End Try
  End Sub

  Private Sub xhcpGetRule(ByVal ruleGuid As String)
    Try
      If File.Exists(xPLHalData & "\Determinator\" & ruleGuid & ".xml") Then
        s.Send(Encoding.ASCII.GetBytes(XH210))
        Dim str As String
        Dim myfile As TextReader = File.OpenText(xPLHalData & "\Determinator\" & ruleGuid & ".xml")
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
    End Try
  End Sub
  Private Sub xhcpDelRule(ByVal ruleGuid As String)
    Try
      If Determinator.DeleteRule(ruleGuid, True) Then
        s.Send(Encoding.UTF8.GetBytes(XH214))
      Else
        s.Send(Encoding.UTF8.GetBytes(XH410))
      End If
    Catch ex As Exception
      s.Send(Encoding.UTF8.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpListScripts(ByVal s As Socket, ByVal params() As String)
    Try
      Dim pathName As String = xPLHalScripts
      If params.Length = 2 Then
        If Not params(1).Trim.StartsWith("\") Then
          pathName &= "\" & params(1)
        Else
          pathName &= params(1)
        End If
      End If
      Dim d As New DirectoryInfo(pathName)
      Dim dirs() As DirectoryInfo
      Dim f() As FileInfo, Counter As Integer
      Dim sb As New StringBuilder
      sb.Append(XH212)
      dirs = d.GetDirectories
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
    End Try
  End Sub

  Private Sub xhcpSendXplMsg()
    Try
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
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpSendxAPMsg()
    Try
      Dim inbuff As String, str As String
      inbuff = ""
      Dim xapMsg As xpllib.xAPMsg
      s.Send(Encoding.ASCII.GetBytes(XH313))
      Do
        str = GetLine(s)
        If Not str = ("." & vbCrLf) Then
          inbuff &= str
        End If
      Loop Until str = vbCrLf Or str = ("." & vbCrLf)
      inbuff = inbuff.Replace(vbCrLf, vbLf)
      xapMsg = New xpllib.xAPMsg(inbuff)
      xapMsg.Send()
      s.Send(Encoding.ASCII.GetBytes(XH213))
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpDelScript(ByVal scriptname As String)
    Try
      Dim filename As String = xPLHalScripts & "\" & scriptname
      If Not File.Exists(filename) Then
        s.Send(Encoding.ASCII.GetBytes(XH410))
      Else
        File.Delete(filename)
        s.Send(Encoding.ASCII.GetBytes(XH214))
      End If
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpRunRule(ByVal rulename As String)
    Try
      rulename = rulename.Substring(7, rulename.Length - 7).Trim
      xplDeterminator.ExecuteRule(rulename)
      s.Send(Encoding.ASCII.GetBytes(XH203))
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
      WriteErrorLog("Error execuring determinator " & rulename & ": " & ex.ToString)
    End Try
  End Sub

  Private Sub xhcpRunSub(ByVal scriptName As String, ByVal params As String)
    Try
      ' If no parameters, execute directly
      If params Is Nothing Then
        If RunScript(scriptName, False, "") Then
          s.Send(Encoding.ASCII.GetBytes(XH203))
        Else
          s.Send(Encoding.ASCII.GetBytes(XH403))
        End If
      Else
        If RunScript(scriptName, True, params) Then
          s.Send(Encoding.ASCII.GetBytes(XH203))
        Else
          s.Send(Encoding.ASCII.GetBytes(XH403))
        End If
      End If
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpListSettings()
    Try
      Dim Counter As Integer
      s.Send(Encoding.ASCII.GetBytes(XH204))
      For Counter = 1 To xPLHalCount
        s.Send(Encoding.ASCII.GetBytes(xPLHals(Counter).SubID & vbTab))
        s.Send(Encoding.ASCII.GetBytes(xPLHals(Counter).Name & vbTab))
        s.Send(Encoding.ASCII.GetBytes(xPLHals(Counter).Desc & vbTab))

        If xPLHals(Counter).Name.Substring(0, 1) <> "%" Then
          s.Send(Encoding.ASCII.GetBytes(xPLHals(Counter).Values(xPLHals(Counter).Value).Name & vbTab))
          s.Send(Encoding.ASCII.GetBytes(xPLHals(Counter).Values(xPLHals(Counter).Value).Desc))
        Else
          s.Send(Encoding.ASCII.GetBytes("0" & vbTab & "0"))
        End If
        s.Send(Encoding.ASCII.GetBytes(vbCrLf))
      Next
      EndMultiLine()
    Catch ex As Exception
      xhcpLog.LogEvent("ListGlobals(): " & ex.ToString())
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpListOptions(ByVal settingname As String)
    Try
      Dim Counter As Integer, i As Integer
      i = CInt(xPLHalsHash(settingname.ToUpper()))
      If i > 0 Then
        s.Send(Encoding.ASCII.GetBytes(XH205))
        For Counter = 0 To xPLHals(i).ValuesCount
          s.Send(Encoding.ASCII.GetBytes(xPLHals(i).Values(Counter).Name & vbTab & xPLHals(i).Values(Counter).Desc & vbCrLf))
        Next
        s.Send(Encoding.ASCII.GetBytes("." & vbCrLf))
      Else
        s.Send(Encoding.ASCII.GetBytes(XH405))
      End If
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpSetSetting(ByVal sName As String, ByVal sValue As String)
    Try
      Dim Counter As Integer, i As Integer
      sName = sName.ToUpper()
      sValue = sValue.ToUpper()
      If Not xPLHalsHash.ContainsKey(sName) Then
        s.Send(Encoding.ASCII.GetBytes(XH405))
      Else
        i = CInt(xPLHalsHash(sName))
        For Counter = 0 To xPLHals(i).ValuesCount
          If xPLHals(i).Values(Counter).Name.ToUpper() = sValue Then
            SYSClass.Setting(sName) = Counter
            s.Send(Encoding.ASCII.GetBytes(XH206))
          End If
        Next
      End If
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpGetErrLog()
    Try
      s.Send(Encoding.ASCII.GetBytes(XH207))
      If File.Exists(xPLHalData & "\error_log.txt") Then
        Dim fs As TextReader = File.OpenText(xPLHalData & "\error_log.txt")
        Dim myString As String = fs.ReadLine()
        While Not myString Is Nothing
          s.Send(Encoding.ASCII.GetBytes(myString & vbCrLf))
          myString = fs.ReadLine
        End While
        fs.Close()
      End If
      EndMultiLine()
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpGetSetting(ByVal sName As String)
    Try
      Dim i As Integer
      sName = sName.ToUpper
      If Not xPLHalsHash.ContainsKey(sName) Then
        s.Send(Encoding.ASCII.GetBytes(XH405))
      Else
        i = CInt(xPLHalsHash(sName))
        s.Send(Encoding.ASCII.GetBytes(XH208))
        s.Send(Encoding.ASCII.GetBytes(xPLHals(i).Value.ToString() & vbTab))
        s.Send(Encoding.ASCII.GetBytes(xPLHals(i).Values(xPLHals(i).Value).Name & vbTab))
        s.Send(Encoding.ASCII.GetBytes(xPLHals(i).Values(xPLHals(i).Value).Desc))
        s.Send(Encoding.ASCII.GetBytes(vbCrLf))
        EndMultiLine()
      End If
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub EndMultiLine()
    s.Send(Encoding.ASCII.GetBytes("." & vbCrLf))
  End Sub

  Private Sub xhcpGetConfigXml()
    Try
      Dim fs As TextReader = File.OpenText(xPLHalData & "\xplhal.xml")
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
    End Try
  End Sub

  Private Sub xhcpPutConfigXml()
    Try
      Dim filename As String = Path.GetTempFileName
      Dim str As String
      Dim fs As TextWriter = File.CreateText(filename)
      s.Send(Encoding.ASCII.GetBytes(XH315))
      Do
        str = GetLine(s)
        If Not str = ("." & vbCrLf) Then
          fs.Write(str)
        End If
      Loop Until str = ("." & vbCrLf) Or str = ""
      fs.Close()
      File.Copy(xPLHalData & "\xplhal.xml", xPLHalData & "\xplhal.xml.old", True)
      File.Copy(filename, xPLHalData & "\xplhal.xml", True)
      File.Delete(filename)
      LoadSettings(True)
      s.Send(Encoding.ASCII.GetBytes(XH215))
    Catch ex As Exception
      xhcpLog.LogEvent("PutConfigXml(): " & ex.ToString())
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpGetDevConfigValue(ByVal deviceName As String, ByVal valueName As String)
    s.Send(Encoding.ASCII.GetBytes(XH234))
    Try
      deviceName = deviceName.Replace(".", "_")
      Dim fs As TextReader = File.OpenText(xPLHalData & "\configs\current\" & deviceName & ".cfg")
      Dim myString As String = fs.ReadLine
      Dim lhs As String
      valueName = valueName.ToLower
      While Not myString Is Nothing
        If myString.IndexOf("=") > 0 Then
          lhs = myString.Substring(0, myString.IndexOf("=")).ToLower
          If lhs = valueName Then
            s.Send(Encoding.ASCII.GetBytes(myString & vbCrLf))
          End If
        End If
        myString = fs.ReadLine
      End While
      fs.Close()
    Catch ex As Exception
    End Try
    EndMultiLine()
  End Sub

  Private Sub xhcpListAllDevs()
    Try
      s.Send(Encoding.UTF8.GetBytes(XH216))
      For Counter As Integer = 0 To xPLDevs.Length - 1
        s.Send(Encoding.UTF8.GetBytes(xPLDevs(Counter).VDI & vbCrLf))
      Next
      EndMultiLine()
    Catch ex As Exception
      If EnableLogging Then
        WriteErrorLog("LISTALLDEVS: " & ex.ToString)
      End If
    End Try
  End Sub

  Private Sub xhcpListDevices(ByVal params() As String)
    Try
      Dim param As String
      Dim Counter As Integer
      Dim ShowDevice As Boolean
      If params.Length = 2 Then
        param = params(1).ToLower()
      Else
        param = ""
      End If

      s.Send(Encoding.ASCII.GetBytes(XH216))
      For Counter = 0 To xPLDeviceCount
        ShowDevice = True
        If param = "awaitingconfig" And Not xPLDevices(Counter).ConfigType Then
          ShowDevice = False
        End If
        If param = "configured" And xPLDevices(Counter).ConfigType Then
          ShowDevice = False
        End If

        If param = "missingconfig" And Not xPLDevices(Counter).ConfigMissing Then
          ShowDevice = False
        End If


        If ShowDevice And Not xPLDevices(Counter).Suspended Then
          s.Send(Encoding.ASCII.GetBytes(xPLDevices(Counter).VDI & vbTab))
          s.Send(Encoding.ASCII.GetBytes(xPLDevices(Counter).Expires.ToString("yyyyMMdd HH:mm") & vbTab))
          s.Send(Encoding.ASCII.GetBytes(xPLDevices(Counter).Interval.ToString() & vbTab))

          ' COnfig type
          If xPLDevices(Counter).ConfigType Then
            s.Send(Encoding.ASCII.GetBytes("Y" & vbTab))
          Else
            s.Send(Encoding.ASCII.GetBytes("N" & vbTab))
          End If

          ' Config done
          If xPLDevices(Counter).ConfigDone Then
            s.Send(Encoding.ASCII.GetBytes("Y" & vbTab))
          Else
            s.Send(Encoding.ASCII.GetBytes("N" & vbTab))
          End If

          ' Waiting config
          If xPLDevices(Counter).WaitingConfig Then
            s.Send(Encoding.ASCII.GetBytes("Y" & vbTab))
          Else
            s.Send(Encoding.ASCII.GetBytes("N" & vbTab))
          End If

          ' Suspended
          If xPLDevices(Counter).Suspended Then
            s.Send(Encoding.ASCII.GetBytes("Y" & vbTab))
          Else
            s.Send(Encoding.ASCII.GetBytes("N" & vbTab))
          End If

          s.Send(Encoding.ASCII.GetBytes(vbCrLf))
        End If
      Next
      EndMultiLine()
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpGetDevConfig(ByVal devname As String)
    Try
      Dim i As Integer
      devname = devname.ToUpper()
      If Not xPLDevice.ContainsKey(devname) Then
        s.Send(Encoding.ASCII.GetBytes(XH417))
        Exit Sub
      End If
      If Not CheckVendor(devname) Then
        s.Send(Encoding.ASCII.GetBytes(XH418))
        Exit Sub
      End If
      i = CInt(xPLDevice(devname))
      If xPLDevices(i).ConfigSource = "" Then
        SendStatusLine(XH416)
        Exit Sub
      End If
      s.Send(Encoding.ASCII.GetBytes(XH217))

      ' Read the config file
      Dim xml As New XmlTextReader(xPLHalVendorFiles & "\" & xPLDevices(i).ConfigSource)
      While xml.Read
        Select Case xml.NodeType
          Case XmlNodeType.Element
            Select Case xml.Name
              Case "configitem"
                If xml.GetAttribute("type") <> "" Then
                  s.Send(Encoding.ASCII.GetBytes(xml.GetAttribute("key") & vbTab & xml.GetAttribute("type") & vbTab & xml.GetAttribute("number") & vbCrLf))
                End If
            End Select
        End Select
      End While
      xml.Close()
      EndMultiLine()
    Catch ex As Exception
      xhcpLog.LogEvent("xhcpGetDevConfig(): " & ex.ToString())
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpListSingleEvents()
    Try
      Dim Counter As Integer
      s.Send(Encoding.ASCII.GetBytes(XH218))
      For Counter = 0 To xPLEvents.xPLEventsCount
        If xPLEvents.xPLEvents(Counter).Active And Not xPLEvents.xPLEvents(Counter).Recurring And Not xPLEvents.xPLEvents(Counter).RunSub = "{suspended-determinator}" Then
          s.Send(Encoding.ASCII.GetBytes(xPLEvents.xPLEvents(Counter).Tag & vbTab))
          s.Send(Encoding.ASCII.GetBytes(xPLEvents.xPLEvents(Counter).RunSub & vbTab))
          s.Send(Encoding.ASCII.GetBytes(xPLEvents.xPLEvents(Counter).Param & vbTab))
          s.Send(Encoding.ASCII.GetBytes(xPLEvents.xPLEvents(Counter).EventDateTime.ToString("dd/MMM/yyyy HH:mm") & vbTab))
          s.Send(Encoding.ASCII.GetBytes(vbCrLf))
        End If
      Next
      EndMultiLine()
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpListEvents()
    Try
      Dim Counter As Integer
      s.Send(Encoding.ASCII.GetBytes(XH218))
      For Counter = 0 To xPLEvents.xPLEventsCount
        If xPLEvents.xPLEvents(Counter).Active And xPLEvents.xPLEvents(Counter).Recurring Then
          s.Send(Encoding.ASCII.GetBytes(xPLEvents.xPLEvents(Counter).Tag & vbTab))
          s.Send(Encoding.ASCII.GetBytes(xPLEvents.xPLEvents(Counter).RunSub & vbTab))
          s.Send(Encoding.ASCII.GetBytes(xPLEvents.xPLEvents(Counter).Param & vbTab))

          s.Send(Encoding.ASCII.GetBytes(xPLEvents.xPLEvents(Counter).StartTime.ToString("HH:mm") & vbTab))
          s.Send(Encoding.ASCII.GetBytes(xPLEvents.xPLEvents(Counter).EndTime.ToString("HH:mm") & vbTab))
          s.Send(Encoding.ASCII.GetBytes(xPLEvents.xPLEvents(Counter).DoW & vbTab))
          If xPLEvents.xPLEvents(Counter).Recurring Then
            s.Send(Encoding.UTF8.GetBytes(xPLEvents.xPLEvents(Counter).EventRunTime.ToString("dd/MMM/yyyy HH:mm") & vbTab))
          Else
            s.Send(Encoding.UTF8.GetBytes(vbTab))
          End If

          s.Send(Encoding.ASCII.GetBytes(vbCrLf))
        End If
      Next
      EndMultiLine()
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpPutDevConfig(ByVal vdi As String)
    Try
      Dim i As Integer, str As String, buff As String = ""
      vdi = vdi.ToUpper()
      If Not xPLDevice.ContainsKey(vdi) Then
        s.Send(Encoding.ASCII.GetBytes(XH417))
        Exit Sub
      End If
      i = CInt(xPLDevice(vdi))
      s.Send(Encoding.ASCII.GetBytes(XH320))
      Do
        str = GetLine(s)
        If Not str = "" And Not str = ("." & vbCrLf) Then
          buff &= str
        End If
      Loop Until str = "" Or str = ("." & vbCrLf)
      ConfigSend(i, buff)
      s.Send(Encoding.ASCII.GetBytes(XH220))
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
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

      SYSClass.SingleEvent(evDate, evSubName, evParams, evTag)
      s.Send(Encoding.ASCII.GetBytes(XH219))
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
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
        SYSClass.RecurringEvent(evStartTIme, evEndTime, CInt(evInterval), CInt(evRand), evDow, evSubName, evParams, evTag, True)
      Else
        SYSClass.SingleEvent(CDate(evDate), evSubName, evParams, evTag)
      End If
      s.Send(Encoding.ASCII.GetBytes(XH219))
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpGetEvent(ByVal evTag As String)
    Try
      Dim i As Integer
      evTag = evTag.ToUpper()
      If Not xPLEvents.xPLEventsHash.ContainsKey(evTag.Trim) Then
        s.Send(Encoding.ASCII.GetBytes(XH422))
        Exit Sub
      End If
      i = CInt(xPLEvents.xPLEventsHash(evTag.Trim))
      s.Send(Encoding.ASCII.GetBytes(XH222))
      s.Send(Encoding.ASCII.GetBytes("tag=" & xPLEvents.xPLEvents(i).Tag & vbCrLf))
      s.Send(Encoding.ASCII.GetBytes("subname=" & xPLEvents.xPLEvents(i).RunSub & vbCrLf))
      s.Send(Encoding.ASCII.GetBytes("params=" & xPLEvents.xPLEvents(i).Param & vbCrLf))
      If xPLEvents.xPLEvents(i).Recurring Then
        s.Send(Encoding.ASCII.GetBytes("starttime=" & xPLEvents.xPLEvents(i).StartTime.ToString("HH:mm:ss") & vbCrLf))
        s.Send(Encoding.ASCII.GetBytes("endtime=" & xPLEvents.xPLEvents(i).EndTime.ToString("HH:mm:ss") & vbCrLf))
        s.Send(Encoding.ASCII.GetBytes("interval=" & xPLEvents.xPLEvents(i).Interval & vbCrLf))
        s.Send(Encoding.ASCII.GetBytes("rand=" & xPLEvents.xPLEvents(i).RandomTime & vbCrLf))
        s.Send(Encoding.ASCII.GetBytes("dow=" & xPLEvents.xPLEvents(i).DoW & vbCrLf))
      Else
        s.Send(Encoding.ASCII.GetBytes("date=" & xPLEvents.xPLEvents(i).EventDateTime.ToString("dd-MMM-yyyy HH:mm") & vbCrLf))
      End If
      s.Send(Encoding.ASCII.GetBytes("runtime=" & xPLEvents.xPLEvents(i).EventRunTime.ToString("dd/MMM/yyyy HH:mm") & vbCrLf))
      EndMultiLine()
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpDeleteEvent(ByVal evTag As String)
    Try
      evTag = evTag.ToUpper()
      If SYSClass.EventExists(evTag) Then
        SYSClass.EventDelete(evTag)
        s.Send(Encoding.ASCII.GetBytes(XH223))
      Else
        s.Send(Encoding.ASCII.GetBytes(XH422))
      End If
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpListSubs()
    Try
      Dim str As String
      s.Send(Encoding.ASCII.GetBytes(XH224))

      For Each str In chkScript.Keys
        s.Send(Encoding.ASCII.GetBytes(str & vbCrLf))
      Next
      EndMultiLine()
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpGetGlobal(ByVal globalname As String) ' trt
    Try
      globalname = globalname.ToUpper
      If Not xPLGlobals.Exists(globalname) Then
        s.Send(Encoding.ASCII.GetBytes(XH491))
      Else
        s.Send(Encoding.ASCII.GetBytes(XH291))
        s.Send(Encoding.ASCII.GetBytes(xPLGlobals.Value(globalname).ToString))
        s.Send(Encoding.ASCII.GetBytes(vbCrLf))
        EndMultiLine()
      End If
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpSetGlobal(ByVal globalname As String, ByVal globalValue As String)
    Try
      globalname = globalname.ToUpper
      globalValue = globalValue.Substring(10, globalValue.Length - 10)
      globalValue = globalValue.Substring(globalname.Length + 1, globalValue.Length - globalname.Length - 1)
      s.Send(Encoding.ASCII.GetBytes(XH232))
      xPLGlobals.Value(globalname) = globalValue
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcplistx10states(ByVal location As String)  ' trt
    Try
      Dim loc As Double
      loc = Val(location)
      Dim x, y As Integer
      s.Send(Encoding.ASCII.GetBytes(XH292))
      For x = 1 To 26
        For y = 1 To 16
          If X10Cache(x, y).DeviceType <> -1 Then
            If loc = 0 Or X10Cache(x, y).Location = loc Then
              s.Send(Encoding.ASCII.GetBytes(X10Cache(x, y).Device & vbTab))
              s.Send(Encoding.ASCII.GetBytes(X10Cache(x, y).Label & vbTab))
              s.Send(Encoding.ASCII.GetBytes(X10Cache(x, y).Change & vbTab))
              s.Send(Encoding.ASCII.GetBytes(X10Cache(x, y).State.ToString & vbTab))
              s.Send(Encoding.ASCII.GetBytes(X10Cache(x, y).OnImage & vbTab))
              s.Send(Encoding.ASCII.GetBytes(X10Cache(x, y).OffImage & vbTab))
              If X10Cache(x, y).IsLight Then
                s.Send(Encoding.ASCII.GetBytes("Y" & vbTab))
              Else
                s.Send(Encoding.ASCII.GetBytes("N" & vbTab))
              End If
              s.Send(Encoding.ASCII.GetBytes(vbCrLf))
            End If
          End If
        Next
      Next
      EndMultiLine()
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpClearErrLog()
    Try
      If File.Exists(xPLHalData & "\error_log.txt") Then
        File.Delete(xPLHalData & "\error_log.txt")
      End If
      s.Send(Encoding.ASCII.GetBytes(XH225))
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpAddX10Device()
    Try
      Dim str, lhs, rhs As String
      Dim devName, Location, OnImage, OffImage, devLabel As String, IsLight As Boolean
      devName = ""
      devLabel = ""
      Location = ""
      OnImage = ""
      OffImage = ""
      s.Send(Encoding.ASCII.GetBytes(XH326))
      Do
        str = GetLine(s)
        If str.IndexOf("=") > 0 Then
          lhs = str.Substring(0, str.IndexOf("="))
          rhs = Right(str, Len(str) - InStr(str, "="))
          rhs = rhs.Replace(vbCrLf, "")
          Select Case lhs.ToLower
            Case "device"
              devName = rhs
            Case "islight"
              Select Case rhs.ToLower
                Case "true", "yes", "1"
                  IsLight = True
                Case "false", "no", "0"
                  IsLight = False
              End Select
            Case "label"
              devLabel = rhs
            Case "location"
              Location = rhs
            Case "offimage"
              OffImage = rhs
            Case "onimage"
              OnImage = rhs
          End Select
        End If
      Loop Until str = "" Or str = ("." & vbCrLf)
      X10Class.LoadDevice(devName, 0, IsLight, False, 0, 0, devLabel, 0, 0, Location, OnImage, OffImage, True)

      s.Send(Encoding.ASCII.GetBytes(XH226))
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpGetX10Device(ByVal devicename As String)
    Try
      Dim x, y As Integer
      Dim bFound As Boolean = False
      devicename = devicename.ToUpper()
      For x = 1 To 26
        For y = 1 To 16
          If X10Cache(x, y).DeviceType <> -1 Then
            If X10Cache(x, y).Device.ToUpper() = devicename Then
              s.Send(Encoding.ASCII.GetBytes(XH227))
              bFound = True
              s.Send(Encoding.ASCII.GetBytes("device=" & X10Cache(x, y).Device & vbCrLf))
              s.Send(Encoding.ASCII.GetBytes("isLight=" & X10Cache(x, y).IsLight & vbCrLf))
              s.Send(Encoding.ASCII.GetBytes("label=" & X10Cache(x, y).Label & vbCrLf))
              s.Send(Encoding.ASCII.GetBytes("offImage=" & X10Cache(x, y).OffImage & vbCrLf))
              s.Send(Encoding.ASCII.GetBytes("onImage=" & X10Cache(x, y).OnImage & vbCrLf))

              EndMultiLine()
            End If
          End If
        Next
      Next
      If Not bFound Then
        s.Send(Encoding.ASCII.GetBytes(XH417))
      End If
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpDelX10Device(ByVal address As String)
    Try
      Dim x, y As Integer
      address = address.ToUpper
      For x = 1 To 26
        For y = 1 To 16
          If X10Cache(x, y).Device = address Then
            X10Cache(x, y).DeviceType = -1
          End If
        Next
      Next
      s.Send(Encoding.ASCII.GetBytes(XH228))
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub
  Private Sub xhcpGetSub(ByVal subname As String)
    Try
      If Not chkScript.ContainsKey(subname.ToUpper) Then
        s.Send(Encoding.ASCII.GetBytes(XH429))
      Else
        Dim struc As xPLScriptStruc, fs As TextReader, myString As String, b As Boolean = False, mySub As String
        struc = CType(chkScript.Item(subname.ToUpper), xPLScriptStruc)
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
      Dim filename As String = xPLHalData & "\configs\current\" & devName.Replace(".", "_") & ".cfg"
      If File.Exists(filename) Then
        File.Delete(filename)
      End If
      filename = xPLHalData & "\configs\" & devName.Replace(".", "_") & ".cfg"
      If File.Exists(filename) Then
        File.Delete(filename)
      End If
      filename = xPLHalData & "\vendor\" & devName.Substring(0, devName.IndexOf(".")) & ".cache.xml"
      If File.Exists(filename) Then
        File.Delete(filename)
      End If
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
          s.Send(xhcp.WelcomeBanner)
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
            xPLHalIsActive = False
          End If
          s.Send(Encoding.UTF8.GetBytes("MODE REPL" & vbCrLf))
          str = GetLine(s)
          While s.Connected
            str = GetLine(s)
            If str.StartsWith("600") Then
              filename = GetLine(s)
              filesize = CInt(GetLine(s))
              Dim fs As FileStream = File.Open(xPLHalData & "\" & filename, FileMode.Create)
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
          xPLHalIsActive = True
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
    files = Directory.GetFiles(xPLHalData & "\scripts")
    For Counter = 0 To files.Length - 1

      PushFile("scripts\" & Path.GetFileName(files(Counter)))
    Next
    files = Directory.GetFiles(xPLHalData & "\scripts\headers")
    For Counter = 0 To files.Length - 1
      PushFile("scripts\headers\" & Path.GetFileName(files(Counter)))
    Next
    files = Directory.GetFiles(xPLHalData & "\scripts\user")
    For Counter = 0 To files.Length - 1
      PushFile("scripts\user\" & Path.GetFileName(files(Counter)))
    Next
    ReplFilesMutex.ReleaseMutex()
  End Sub

  Private Shared Sub PushFile(ByVal filename As String)
    If ReplClient Is Nothing Then Exit Sub
    Try
      Dim fs As FileStream = File.Open(xPLHalData & "\" & filename, FileMode.Open)
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
      Dim o As Object
      s.Send(Encoding.ASCII.GetBytes(XH231))

      For Each o In xPLGlobals.Globals.Keys
        s.Send(Encoding.ASCII.GetBytes(CStr(o) & "=" & CStr(xPLGlobals.Value(CStr(o))) & vbCrLf))
      Next

      EndMultiLine()
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
    End Try
  End Sub

  Private Sub xhcpDelGlobal(ByVal globalName As String)
    Try
      xPLGlobals.Delete(globalName.ToUpper)
      s.Send(Encoding.ASCII.GetBytes(XH233))
    Catch ex As Exception
      s.Send(Encoding.ASCII.GetBytes(XH503))
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

End Class


Public Class xhcpLog

    Public Shared Sub LogEvent(ByVal s As String)
        Dim fs As TextWriter = File.AppendText("c:\xhcp.log")
        fs.WriteLine(DateTime.Now().ToString("dd/MM/yy HH:mm:ss") & " " & s)
        fs.Close()
    End Sub

End Class
