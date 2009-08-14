'**************************************
'* xPLHal Service Version
'*
'* Copyright (C) 2003 Tony Tofts
'* http://www.xplhal.com
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
Option Strict On

Imports System.ServiceProcess

Public Class xPLHal
    Inherits System.ServiceProcess.ServiceBase

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
        Debugger.Break()
        ServicesToRun = New System.ServiceProcess.ServiceBase() {New xPLHal()}

        System.ServiceProcess.ServiceBase.Run(ServicesToRun)
    End Sub

    'Required by the Component Designer
    Private components As System.ComponentModel.IContainer

    ' NOTE: The following procedure is required by the Component Designer
    ' It can be modified using the Component Designer.  
    ' Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        components = New System.ComponentModel.Container()
        Me.ServiceName = "xPLHal"
    End Sub

#End Region


  Private WithEvents xPLHalListener As xpllib.XplListener

  Private xPLxhcp As xhcp
  Private xapHub As hubxap

    Protected Overrides Sub OnStart(ByVal args() As String)
        ' initialise
    xPLHalBooting = True
    TotalMessagesRx = 0
        Call InitxPLHal()
        xPLHalBooting = False
        Try
            xPLxhcp = New xhcp
        Catch ex As Exception
            WriteErrorLog("Failed to Create XHCP: " & ex.ToString)
        End Try
    End Sub

    Protected Overrides Sub OnStop()
        ' xplhal_unload script
        If xPLHalIsActive = True Then Call RunScript("xPLHal_Unload", False, "")

        ' stop xap hub
        If xAPSupport = True Then
            Try
                xapHub.StopHub()
            Catch ex As Exception
            End Try
    End If

    ' Stop listener
    xPLHalListener.Dispose()

    ' stop xhcp
    xPLxhcp.StopXHCP()

    ' save globals
    xPLGlobals.Save()

    ' save events
    xPLEvents.Save()

    ' save x10 cache
    Call SaveX10Cache()

    ' save devices
    Call SaveDevices()

    ' save groups
    Call SaveGroups()

    GC.Collect()
    GC.WaitForPendingFinalizers()
    End Sub

    ' initialise listener
    Private Sub InitxPLHalListener()
        Try
      xPLHalListener = New xpllib.XplListener("xpl-xplhal", 1, EventLog)
      xPLHalListener.Filters.MatchTarget = False
      xPLHalListener.Filters.AlwaysPassMessages = True
            xPLHalListener.XplOnTimer = AddressOf xPLHalListener_OnTimer
            xPLHalListener.Listen()
            xPLHalSource = xPLHalListener.Source.ToUpper + "." + xPLHalListener.InstanceName.ToUpper
        Catch ex As Exception
            Call WriteErrorLog("Error Initialising xPL (" & Err.Description & ")")
        End Try
    End Sub

    ' intialise xplhal
    Private Sub InitxPLHal()

        ' system paths
        xPLHalData = System.Reflection.Assembly.GetExecutingAssembly.Location
        Try
            xPLHalData = xPLHalData.Substring(0, InStrRev(xPLHalData, "\")) & "Data"
            MkDir(xPLHalData)
        Catch ex As Exception
        End Try
        Try
            xPLHalScripts = xPLHalData & "\Scripts"
            MkDir(xPLHalScripts)
        Catch ex As Exception
        End Try
        Try
            MkDir(xPLHalScripts & "\Headers")
        Catch ex As Exception
        End Try
        Try
            MkDir(xPLHalScripts & "\User")
        Catch ex As Exception
        End Try
        Try
            MkDir(xPLHalScripts & "\Messages")
        Catch ex As Exception
        End Try
        Try
            xPLHalVendorFiles = xPLHalData & "\Vendor"
            MkDir(xPLHalVendorFiles)
        Catch ex As Exception
        End Try
        Try
            xPLHalConfigFiles = xPLHalData & "\Configs"
            MkDir(xPLHalConfigFiles)
        Catch ex As Exception
        End Try
        Try
            MkDir(xPLHalConfigFiles & "\Current")
            ' copy existing config
            Dim strCfg As String
            strCfg = Dir(xPLHalConfigFiles & "\*.cfg")
            While strCfg <> ""
                Try
                    FileCopy(xPLHalConfigFiles & "\" & strCfg, xPLHalConfigFiles & "\Current\" & strCfg)
                Catch ex As Exception
                End Try
                strCfg = Dir()
            End While
        Catch ex As Exception
        End Try

        ' load devices
        Try
            Call LoadDevices()
        Catch ex As Exception
            WriteErrorLog("Failed to Load Devices: " & ex.ToString)
        End Try

        ' load globals
        Try
            xPLGlobals.Load()
        Catch ex As Exception
            WriteErrorLog("Failed to Load Globals: " & ex.ToString)
        End Try

        ' load events
        Try
            xPLEvents.Load()
        Catch ex As Exception
            WriteErrorLog("Failed to Load Events: " & ex.ToString)
        End Try

        ' load x10 cache
        Try
            Call LoadX10Cache()
        Catch ex As Exception
            WriteErrorLog("Failed to Load X10 Cache: " & ex.ToString)
        End Try

        ' load settings
        Try
            Call LoadSettings(False)
        Catch ex As Exception
            WriteErrorLog("Failed to Load Settings: " & ex.ToString)
        End Try

        ' load groups
        Try
            Call LoadGroups()
        Catch ex As Exception
            WriteErrorLog("Failed to Load Groups: " & ex.ToString)
        End Try
                
        ' load determinator
        Try
            Determinator = New xplDeterminator
        Catch ex As Exception
            WriteErrorLog("Failed to Load Determinator Engine: " & ex.ToString)
        End Try

        ' load scripts
        Try
            Call InitScripts()
        Catch ex As Exception
            WriteErrorLog("Failed to Initialise Scripts: " & ex.ToString)
        End Try

        ' start listening
        Try
            Call InitxPLHalListener()
        Catch ex As Exception
            WriteErrorLog("Failed to Start Listener: " & ex.ToString)
        End Try

        ' start xap hub
        If xAPSupport = True Then
            Try
                xapHub = New hubxap
            Catch ex As Exception
                WriteErrorLog("Failed to Create xAP Hub: " & ex.ToString)
            End Try
            Try
                xapHub.StartHub()
            Catch ex As Exception
                Call WriteErrorLog("Unable to start xPL xAP Hub as requested so xAP Support will be inoperative! A hub already running?")
            End Try
        End If

        ' xplhal load event script
        If xPLHalIsActive = True Then
            Try
                Call RunScript("xPLHal_Load", False, "")
            Catch ex As Exception
                WriteErrorLog("Failed to Run Load Script: " & ex.ToString)
            End Try
        End If

    End Sub

    Private Sub xPLHalListener_xPLMessageReceived(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs) Handles xPLHalListener.XplMessageReceived    
    If Not xPLHalIsActive Then Exit Sub

    Dim xPLThread As Scripting
    Dim t As Thread
    Dim msgSource As String
    Dim msgTarget As String
    Dim msgSchemaClass As String

    Determinator.ProcessXplMessage(e.XplMsg)
    msgSchemaClass = e.XplMsg.Schema.msgClass.ToUpper
    msgSource = e.XplMsg.Source.Vendor.ToUpper + "-" + e.XplMsg.Source.Device.ToUpper + "." + e.XplMsg.Source.Instance.ToUpper
    msgTarget = e.XplMsg.Target.Vendor.ToUpper + "-" + e.XplMsg.Target.Device.ToUpper + "." + e.XplMsg.Target.Instance.ToUpper
    Select Case msgSchemaClass
      Case "CONFIG"
        ' process config
        If msgTarget = xPLHalSource Then
          ' process message to myself
          If e.XplMsg.Schema.msgType.ToUpper = "RESPONSE" Then
            If e.XplMsg.GetParam(1, "newconf") <> "" Then xPLHalSource = xPLHalListener.Source.ToUpper + "." + e.XplMsg.GetParam(1, "newconf").ToUpper
          End If
          Exit Sub
        End If
        Call ConfigProcess(msgSource, e.XplMsg, e.XplMsg.Source.Vendor.ToUpper, e.XplMsg.Source.Device.ToUpper, e.XplMsg.Source.Instance.ToUpper, e.XplMsg.XPL_Msg(0).Section.ToUpper, e.XplMsg.Schema.msgClass.ToUpper, e.XplMsg.Schema.msgType.ToUpper)
      Case "CONTROL"
        ' Is it for us?
        If msgTarget = xPLHalSource Then
          ' Is it config.basic?
          If e.XplMsg.Schema.msgType.ToUpper = "BASIC" Then
            ProcessControlMessage(e.XplMsg)
          End If
        End If
      Case "HBEAT"
        ' if hbeat/config message process
        If msgSource = xPLHalListener.Source.ToUpper Then xPLGlobals.Value("XPLHAL_ALIVE") = Now
        Call ConfigProcess(msgSource, e.XplMsg, e.XplMsg.Source.Vendor.ToUpper, e.XplMsg.Source.Device.ToUpper, e.XplMsg.Source.Instance.ToUpper, e.XplMsg.XPL_Msg(0).Section.ToUpper, e.XplMsg.Schema.msgClass.ToUpper, e.XplMsg.Schema.msgType.ToUpper)
    End Select

    ' get determinator devices
    Call AddDeterminatorDevice(msgSource)

    ' process message in own thread
    xPLThread = New Scripting
    t = New Thread(AddressOf xPLThread.ProcessMessage)
    '     t.ApartmentState = ApartmentState.STA
    xPLThread.e = e
    xPLThread.Source = xPLHalListener.Source.ToUpper
    t.Start()
    TotalMessagesRx += 1
    End Sub

    Public Sub xPLHalListener_OnTimer()

        Dim strScript As String
        Dim x, y As Integer

        If xPLHalIsActive = False Then Exit Sub

        ' check for expired devices
        Try
            For x = 0 To xPLDeviceCount
                If xPLDevices(x).Expires < Now And xPLDevices(x).Suspended = False Then
                    ' expired
                    xPLDevices(x).Suspended = True
                    xPLDevices(x).ConfigDone = False
                    xPLDevices(x).ConfigMissing = False
                    xPLDevices(x).WaitingConfig = False                    
          Call RunScript(GetScriptSub(xPLDevices(x).VDI & "_Expired"), False, "")
                End If
            Next
        Catch ex As Exception
            WriteErrorLog("Error checking for expired devices (" & Err.Description & ")")
        End Try

        ' check for expired determinator devices
        Try
            For x = 0 To xPLDevCount
                If xPLDevs(x).Expires < Now And xPLDevs(x).Suspended = False Then
                    ' expired
                    xPLDevs(x).Suspended = True
                End If
            Next
        Catch ex As Exception
            WriteErrorLog("Error checking for expired list devices (" & Err.Description & ")")
        End Try

        ' run events
        Call xPLEvents.RunEvents()

        ' process x10 timeouts on motion type devices
        Try
            For x = 1 To 26
                For y = 1 To 16
                    If X10Cache(x, y).DeviceType = X10_MOTION Then
                        If X10Cache(x, y).Timeout <> 0 Then
                            If X10Cache(x, y).Active = True Then
                                If X10Cache(x, y).Expires < Now Then
                                    X10Cache(x, y).Active = False
                                    strScript = "X10_" & X10Cache(x, y).Device & "_TIMEOUT"
                                    '                                Debug.WriteLine("Timeout: " + strScript)
                                    Call RunScript(strScript, False, "")
                                End If
                            End If
                        End If
                    End If
                Next
            Next
        Catch ex As Exception
            WriteErrorLog("Error checking for X10 motion timeout (" & Err.Description & ")")
        End Try
    End Sub

End Class

