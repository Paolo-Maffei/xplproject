'**************************************
'* xPL Network Engine 
'*
'* Version 2.2
'*
'* Copyright (C) 2003-2008 Ian Lowe, Tony Tofts
'*
'* http://www.xplhal.org
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
'**************************************

Imports xpllib
Imports xPLLogging
Imports xPLLogging.LogLevel
Imports System.Threading

Public Class xPLHandler
    Public Shared WithEvents xPLNetwork As New XplListener("xpl", "xplhal2")
    Public Shared HandlerActive As Boolean = False

    '* Events raise by this DLL
    Public Shared Event AddtoCache(ByVal _cachename As String, ByVal _cachevalue As String, ByVal _expires As Boolean)
    Public Shared Event ParseMessageForRules(ByVal e As xpllib.XplMsg)
    Public Shared Event ParseMessageForCache(ByVal e As xpllib.XplMsg)
    Public Shared Event ParseMessageForScripts(ByVal e As xpllib.XplMsg)
    Public Shared Event RunDeterminator(ByVal _rulename As String)
    Public Shared Event ProcessConfigHeartBeat(ByVal _msgsource As String, ByVal e As xpllib.XplMsg)
    Public Shared Event ProcessConfigList(ByVal _msgsource As String, ByVal e As xpllib.XplMsg)
    Public Shared Event ProcessCurrentConfig(ByVal _msgsource As String, ByVal e As xpllib.XplMsg)
    Public Shared Event ProcessHeartbeat(ByVal _msgsource As String, ByVal e As xpllib.XplMsg)
    Public Shared Event RemoveDevice(ByVal _msgsource As String)
    Public Shared Event xPLNetworkConfig()


    Public Shared Function LibVersion() As String
        Return XplListener.XPL_LIB_VERSION.ToString()
    End Function

    Public Shared Function Version() As String
        Return System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
    End Function

    Public Shared Sub Connect()
        xPLNetwork.Filters.AlwaysPassMessages = True
        xPLNetwork.InstanceName = My.Computer.Name
        Logger.AddLogEntry(AppInfo, "xplnet", "xPL Instance Name set to: " & xPLNetwork.InstanceName)
        xPLNetwork.Listen()
    End Sub

    Public Shared Sub Disconnect()
        xPLNetwork.Dispose()
    End Sub

    Shared Property MySourceTag() As String
        Get
            MySourceTag = xPLNetwork.VendorId & "-" & xPLNetwork.DeviceId & "." & xPLNetwork.InstanceName
        End Get

        Set(ByVal value As String)
            xPLNetwork.InstanceName = value
        End Set
    End Property

    Private Shared Sub xPLConfigDone(ByVal e As XplListener.XplLoadStateEventArgs) Handles xPLNetwork.XplConfigDone
        If e.ConfigurationLoadedFromXML Then
            Logger.AddLogEntry(AppInfo, "xplnet", "xPL Library loaded it's config from XML File ")
        Else
            Logger.AddLogEntry(AppInfo, "xplnet", "xPL Library configured by xPL Config Message ")
            RaiseEvent xPLNetworkConfig()
        End If
    End Sub

    Private Shared Sub xPlReConfigDone(ByVal e As XplListener.XplLoadStateEventArgs) Handles xPLNetwork.XplReConfigDone
        RaiseEvent xPLNetworkConfig()
    End Sub


    Public Shared Sub SendMessage(ByVal strMsgType As String, ByVal strTarget As String, ByVal strSchema As String, ByVal strMsg As String)

        'THIS NEEDS re-written to support xpllib 4.4

        'Dim xplmsgtype As xpllib.XplMsg.xPLMsgType
        'Select Case strMsgType
        '    Case "xpl-cmnd"
        '        xplmsgtype = XplMsg.xPLMsgType.cmnd
        '    Case "xpl-stat"
        '        xplmsgtype = XplMsg.xPLMsgType.stat
        '    Case "xpl-trig"
        '        xplmsgtype = XplMsg.xPLMsgType.trig
        'End Select

        'Dim targetall As Boolean
        'If strTarget = "*" Then
        '    targetall = True
        'Else
        '    targetall = False
        'End If

        'Dim x As XplMsg = xPLNetwork.GetPreparedXplMessage(xplmsgtype, targetall)

        xPLSendMsg(strMsgType, strTarget, strSchema, strMsg)

    End Sub

    ' "Old School" (pre xpllib4.4) general routine to send a message
    Public Shared Sub xPLSendMsg(ByVal strMsgType As String, ByVal strTarget As String, ByVal strSchema As String, ByVal strMessage As String)
        Dim xPLMessage As String
        Dim xPLMsg As xpllib.XplMsg
        Try
            ' Add a trailing Lf if it is missing
            If Right(strMessage, 1) <> vbLf Then
                strMessage &= vbLf
            End If

            If Len(strMsgType) = 0 Then strMsgType = "xpl-cmnd"
            If Len(strTarget) = 0 Then strTarget = "*"
            If Len(strSchema) = 0 Then Exit Sub
            If Len(strMessage) = 0 Then Exit Sub
            xPLMessage = strMsgType & vbLf & "{" & Chr(10)
            xPLMessage = xPLMessage & "hop=1" & Chr(10)
            xPLMessage = xPLMessage & "source=" & MySourceTag.ToLower & Chr(10)
            xPLMessage = xPLMessage & "target=" & strTarget & Chr(10)
            xPLMessage = xPLMessage & "}" & Chr(10)
            xPLMessage = xPLMessage & strSchema & Chr(10) & "{" & Chr(10)
            xPLMessage = xPLMessage & strMessage
            xPLMessage = xPLMessage & "}" & Chr(10)
            xPLMsg = New xpllib.XplMsg(xPLMessage)
            xPLMsg.Send()
            Logger.AddLogEntry(AppInfo, "xplnet", "Sent xPL Message - Schema(" & strSchema & ")")
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "xplnet", "Cannot Send xPL Message.")
            Logger.AddLogEntry(AppError, "xplnet", "Cause: " & ex.Message)
        End Try
    End Sub

    Private Shared Sub HandleIncomingMessage(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs) Handles xPLNetwork.XplMessageReceived
        If e.XplMsg.Class = "test" And e.XplMsg.Type = "basic" Then
            'delme
            SendMessage("xpl-trig", "", "test.reply", "pos=just after message had arrived")
        End If


        If HandlerActive Then
            Logger.AddLogEntry(AppInfo, "xplnet", "xPL Message Arrived, Processing...")

            RaiseEvent ParseMessageForCache(e.XplMsg)
            RaiseEvent ParseMessageForRules(e.XplMsg)
            RaiseEvent ParseMessageForScripts(e.XplMsg)

            'If e.XplMsg.Class = "test" And e.XplMsg.Type = "basic" Then
            '    'delme
            '    SendMessage("xpl-trig", "", "test.reply", "pos=events raised")
            'End If

            Dim msgSource As String = e.XplMsg.SourceTag
            Dim msgTarget As String = e.XplMsg.TargetTag
            Dim msgSchema As String = e.XplMsg.Class & "." & e.XplMsg.Type
            If e.XplMsg.MsgTypeString <> "xpl-cmnd" Then
                Select Case msgSchema
                    Case "config.list"
                        RaiseEvent ProcessConfigList(msgSource, e.XplMsg)

                    Case "config.current"
                        RaiseEvent ProcessCurrentConfig(msgSource, e.XplMsg)

                    Case "config.app", "config.basic"
                        RaiseEvent ProcessConfigHeartBeat(msgSource, e.XplMsg)

                    Case "hbeat.basic", "hbeat.app"
                        If msgSource = MySourceTag Then
                            RaiseEvent AddtoCache("xplhal." & msgSource & ".alive", Now.ToString, False)
                        End If
                        RaiseEvent ProcessHeartbeat(msgSource, e.XplMsg)

                    Case "hbeat.end"
                        RaiseEvent RemoveDevice(msgSource)

                End Select
            End If
        Else
            Logger.AddLogEntry(AppWarn, "xplnet", "xPL Message Arrived, but we are not active yet.")
        End If

    End Sub

End Class
