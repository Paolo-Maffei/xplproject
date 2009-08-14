'* xPL DawnDusk Service
'*
'* Version 1.3
'*
'* Original version:
'* Copyright (C) 2003 John Bent
'* http://www.xpl.myby.co.uk/
'*
'* Version 1.2 and up:
'* Modifications by Tom Van den Panhuyzen  -  tomvdp at gmail(dot)com
'* http://blog.boxedbits.com/xpl
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

Imports System.ServiceProcess
Imports System.Globalization
Imports xpllib

Public Class xplDawnDusk
    Inherits System.ServiceProcess.ServiceBase

    Private myXplListener As xpllib.XplListener
    Private mySunrise As sunrise
    Private statusIsDay As Boolean

#Region " Component Designer generated code "

    Public Sub New()
        MyBase.New()

        ' This call is required by the Component Designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call

    End Sub

    'UserService overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    ' The main entry point for the process
    <MTAThread()> _
    Shared Sub Main()
        Dim ServicesToRun() As System.ServiceProcess.ServiceBase

        ' More than one NT Service may run within the same process. To add
        ' another service to this process, change the following line to
        ' create a second service object. For example,
        '
        '   ServicesToRun = New System.ServiceProcess.ServiceBase () {New Service1, New MySecondUserService}
        '
        ServicesToRun = New System.ServiceProcess.ServiceBase() {New xplDawnDusk}

        System.ServiceProcess.ServiceBase.Run(ServicesToRun)
    End Sub

    'Required by the Component Designer
    Private components As System.ComponentModel.IContainer

    ' NOTE: The following procedure is required by the Component Designer
    ' It can be modified using the Component Designer.  
    ' Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        components = New System.ComponentModel.Container
        Me.ServiceName = "xPLDawnDusk"
    End Sub

#End Region

    Protected Overrides Sub OnStart(ByVal args() As String)
        Try
            'Setup the sunrise class
            mySunrise = New sunrise

            'Initialize listener
            myXplListener = New xpllib.XplListener("johnb", "dawndusk", EventLog)
            myXplListener.ConfigItems.Define("latitude", "50.9")
            myXplListener.ConfigItems.Define("longitude", "-4.4")
            myXplListener.Filters.Add(New XplListener.XplFilter(xpllib.XplMessageTypes.Command, "*", "*", "*", "dawndusk", "request"))

            'read the config items latitude & longitude
            ReadConfigItems()

            'is it day or night ?
            statusIsDay = IsDay()

            'ready to start receiving events
            AddHandler myXplListener.XplMessageReceived, AddressOf myXplListener_XplMessageReceived
            AddHandler myXplListener.XplConfigDone, AddressOf myXplListener_XplConfigDone
            AddHandler myXplListener.XplReConfigDone, AddressOf myXplListener_XplReConfigDone

            'ready to add extra info to hbeats & check passing of dusk & dawn
            myXplListener.XplHBeatItems = AddressOf myXplListener_OnHBeatItems
            myXplListener.XplOnTimer = AddressOf myXpl_OnTimer

            myXplListener.Listen()
        Catch ex As Exception
            If Not EventLog Is Nothing Then
                EventLog.WriteEntry("xPL initialisation failed: " & ex.ToString())
            End If
        End Try
    End Sub

    Protected Overrides Sub OnStop()
        myXplListener.Dispose()
    End Sub

    Public Function myXplListener_OnHBeatItems() As String
        Dim s As String
        s = "schema=dawndusk.basic" & Chr(10)
        s = s & "type=daynight" & Chr(10)
        Select Case IsDay()
            Case True ' day
                s = s & "status=day" & Chr(10)
            Case False ' night
                s = s & "status=night" & Chr(10)
        End Select
        Return (s)
    End Function

    Private Sub ReadConfigItems()
        Try
            mySunrise.Latitude = Double.Parse(myXplListener.ConfigItems.Item("latitude").Value, NumberStyles.AllowDecimalPoint Or NumberStyles.AllowLeadingSign Or NumberStyles.AllowLeadingWhite Or NumberStyles.AllowTrailingWhite, NumberFormatInfo.InvariantInfo)
            mySunrise.Longitude = Double.Parse(myXplListener.ConfigItems.Item("longitude").Value, NumberStyles.AllowDecimalPoint Or NumberStyles.AllowLeadingSign Or NumberStyles.AllowLeadingWhite Or NumberStyles.AllowTrailingWhite, NumberFormatInfo.InvariantInfo)
        Catch ex As Exception
            EventLog.WriteEntry("Error parsing ConfigItems latitude and longitude:" & Environment.NewLine & ex.Message, EventLogEntryType.Error)
        End Try
    End Sub

    Private Function IsDay() As Boolean
        If DateTime.Now > mySunrise.Sunrise(Date.Today) And DateTime.Now < mySunrise.Sunset(Date.Today) Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Sub myXpl_OnTimer()
        Dim x As XplMsg

        If Not statusIsDay And IsDay() Then  'dawn has passed
            statusIsDay = True
            x = myXplListener.GetPreparedXplMessage(XplMsg.xPLMsgType.trig, True)
            x.Class = "dawndusk"
            x.Type = "basic"
            x.AddKeyValuePair("type", "dawndusk")
            x.AddKeyValuePair("status", "dawn")
            x.Send()

        ElseIf statusIsDay And Not IsDay() Then  'dusk has passed
            statusIsDay = False
            x = myXplListener.GetPreparedXplMessage(XplMsg.xPLMsgType.trig, True)
            x.Class = "dawndusk"
            x.Type = "basic"
            x.AddKeyValuePair("type", "dawndusk")
            x.AddKeyValuePair("status", "dusk")
            x.Send()
        End If
    End Sub

    Private Sub myXplListener_XplMessageReceived(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs)
        Dim q As String = e.XplMsg.GetKeyValue("query").ToLower()
        Dim x As XplMsg

        If q <> "daynight" And q <> "dawndusk" Then Exit Sub

        x = myXplListener.GetPreparedXplMessage(XplMsg.xPLMsgType.stat, True)
        x.Class = "dawndusk"
        x.Type = "basic"

        If q = "daynight" Then
            x.AddKeyValuePair("type", "daynight")
            If IsDay() Then
                x.AddKeyValuePair("status", "day")
            Else
                x.AddKeyValuePair("status", "night")
            End If
        Else
            x.AddKeyValuePair("type", "dawndusk")
            If IsDay() Then
                x.AddKeyValuePair("status", "dawn")
            Else
                x.AddKeyValuePair("status", "dusk")
            End If
        End If

        x.AddKeyValuePair("sunrise", mySunrise.Sunrise(Date.Today).ToString("HH:mm:ss"))
        x.AddKeyValuePair("sunset", mySunrise.Sunset(Date.Today).ToString("HH:mm:ss"))

        x.Send()
    End Sub

    Private Sub myXplListener_XplConfigDone(ByVal e As XplListener.XplLoadStateEventArgs)
        ReadConfigItems()
    End Sub

    Private Sub myXplListener_XplReConfigDone(ByVal e As XplListener.XplLoadStateEventArgs)
        ReadConfigItems()
    End Sub
End Class
