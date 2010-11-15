'* xPL Comfort Service
'*
'* Copyright (C) 2004-2005 John Bent
'* http://www.xpl.myby.co.uk/
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

Public Class xPLComfort
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
        '   ServicesToRun = New System.ServiceProcess.ServiceBase () {New xPLComfort, New MySecondUserService}
        '
        ServicesToRun = New System.ServiceProcess.ServiceBase () {New xPLComfort}

        System.ServiceProcess.ServiceBase.Run(ServicesToRun)
    End Sub

    'Required by the Component Designer
    Private components As System.ComponentModel.IContainer

    ' NOTE: The following procedure is required by the Component Designer
    ' It can be modified using the Component Designer.  
    ' Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        components = New System.ComponentModel.Container()
        Me.ServiceName = "xPLComfort"
    End Sub

#End Region

  Private myComfort As comfort

  Protected Overrides Sub OnStart(ByVal args() As String)
    Try
      myComfort = New comfort
      myComfort.EventLog = EventLog
      myComfort.Initialise()
    Catch ex As Exception
      EventLog.WriteEntry("Error initialising xPL Comfort: " & ex.ToString, EventLogEntryType.Error)
      Throw ex
    End Try
  End Sub

  Protected Overrides Sub OnStop()
    Try
      myComfort.Shutdown()
    Catch ex As Exception
      EventLog.WriteEntry("Error shutting down xPL Comfort: " & ex.ToString, EventLogEntryType.Error)
    End Try
    myComfort = Nothing
    GC.Collect()
    GC.WaitForPendingFinalizers()
  End Sub

End Class
